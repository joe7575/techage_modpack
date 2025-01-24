/*

Copyright 2024-2025 Joachim Stolberg

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the “Software”), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

#include <stdlib.h>
#include <time.h>
#include <errno.h>
#include <string.h>
#include <assert.h>

#include "lua.h"
#include "lauxlib.h"

#include "nb.h"
#include "nb_int.h"

// byte nibble vs ASCII char
#define NTOA(n)                 ((n) > 9   ? (n) + 55 : (n) + 48)
#define ATON(a)                 ((a) > '9' ? (a) - 55 : (a) - 48)
#define MAX_LINES               20
#define MAX_LINE_LEN            61
#define LAST_LINE               ((MAX_LINES - 1) * MAX_LINE_LEN)

#define SETCUR                  (NB_XFUNC + 0)
#define GETCURX                 (NB_XFUNC + 1)
#define GETCURY                 (NB_XFUNC + 2)
#define CLRSCR                  (NB_XFUNC + 3)
#define CLRLINE                 (NB_XFUNC + 4)

typedef struct {
    void *pv_vm;
    char *p_src;
    int src_pos;
    char screen_buffer[MAX_LINES * MAX_LINE_LEN];
    uint8_t xpos;
    uint8_t ypos;
} nb_cpu_t;

// Used to connect compile/run with nb_print, which should work on the same CPU instance
static nb_cpu_t *p_Cpu = NULL;

/**************************************************************************************************
** Static helper functions
**************************************************************************************************/
static char *hash_uint16(uint16_t val, char *s) {
    *s++ = 48 + (val % 64);
    val = val / 64;
    *s++ = 48 + (val % 64);
    val = val / 64;
    *s++ = 48 + val;
    return s;
}

static void *check_vm(lua_State *L) {
    void *ud = luaL_checkudata(L, 1, "nb_cpu");
    luaL_argcheck(L, ud != NULL, 1, "'NanoBasic object' expected");
    return ud;
}

static uint16_t table_to_bytes(lua_State *L, uint8_t idx, uint8_t *p_dest, uint16_t max_size) {
    if(lua_istable(L, idx)) {
        size_t num = lua_objlen(L, idx);
        num = MIN(num, max_size);
        for(size_t i = 0; i < num; i++) {
            lua_rawgeti(L, idx, i+1);
            p_dest[i] = luaL_checkinteger(L, -1);
            lua_pop(L, 1);
        }
        return num;
    }
    return 0;
}

static void bin_to_str(char *p_dst_str, uint8_t *p_src_bin, uint32_t str_size) {
    for(int i = 0; i < str_size/2; i++) {
        *p_dst_str++ = NTOA(*p_src_bin >> 4);
        *p_dst_str++ = NTOA(*p_src_bin & 0x0f);
        p_src_bin++;
    }
}

static void str_to_bin(uint8_t *p_dst_bin, char *p_src_str, uint32_t str_size) {
    for(int i = 0; i < str_size/2; i++) {
        *p_dst_bin++ = (ATON(p_src_str[0]) << 4) + ATON(p_src_str[1]);
        p_src_str += 2;
    }
}

/**************************************************************************************************
** External NanoBasic functions
**************************************************************************************************/
char *nb_get_code_line(void *fp, char *line, int max_line_len)
{
    nb_cpu_t *C = (nb_cpu_t *)fp;
    if(C->p_src == NULL) {
        return NULL;
    }
    if(C->p_src[C->src_pos] == '\0') {
        return NULL;
    }
    int len = 0;
    while(C->p_src[C->src_pos] != '\n' && C->p_src[C->src_pos] != '\0' && len < max_line_len) {
        line[len++] = C->p_src[C->src_pos++];
    }
    line[len] = '\0';
    if(C->p_src[C->src_pos] == '\n') {
        C->src_pos++;
    }
    return line;
}

static void new_line(nb_cpu_t *C) {
    C->xpos = 0;
    C->ypos++;
    if(C->ypos >= MAX_LINES) {
        C->ypos = MAX_LINES - 1;
        memmove(C->screen_buffer, C->screen_buffer + MAX_LINE_LEN, LAST_LINE);
        memset(C->screen_buffer + LAST_LINE, ' ', MAX_LINE_LEN);
        C->screen_buffer[LAST_LINE + MAX_LINE_LEN - 1] = '\0';
    }
}

void nb_print(const char * format, ...)
{
    char buffer[MAX_LINE_LEN + 1];
    uint8_t pos;
    va_list args;

    if(p_Cpu != NULL) {
        va_start(args, format);
        vsnprintf(buffer, sizeof(buffer), format, args);
        va_end(args);
        buffer[MAX_LINE_LEN] = '\0';
        for(int i = 0; i < strlen(buffer); i++) {
            if (buffer[i] >= ' ' && buffer[i] <= '~') {
                p_Cpu->screen_buffer[p_Cpu->ypos * MAX_LINE_LEN + p_Cpu->xpos] = buffer[i];
                p_Cpu->xpos++;
                if(p_Cpu->xpos >= MAX_LINE_LEN) {
                    new_line(p_Cpu);
                }
            } else if(buffer[i] == '\n') {
                // new line
                new_line(p_Cpu);
            } else if(buffer[i] == '\t') {
                // tabulator to next 10th position
                pos = p_Cpu->xpos;
                p_Cpu->xpos = (p_Cpu->xpos + 10) / 10 * 10;
                memset(p_Cpu->screen_buffer + p_Cpu->ypos * MAX_LINE_LEN + pos, ' ', p_Cpu->xpos - pos);
            }
        }
    }
}

/**************************************************************************************************
** Lua API functions
**************************************************************************************************/
static int version(lua_State *L) {
    lua_pushstring(L, SVERSION);
    return 1;
}

static int free_mem(lua_State *L) {
    char s[80];
    sprintf(s, "%u/%u/%u bytes free (code/data/heap)\n", cfg_MAX_CODE_SIZE, cfg_NUM_VARS * 4, cfg_MEM_HEAP_SIZE);
    lua_pushlstring(L, s, strlen(s));
    return 1;
}

static int add_function(lua_State *L) {
    char *name = (char *)luaL_checkstring(L, 1);
    uint8_t return_type = luaL_checkinteger(L, 3);
    uint8_t types[8];
    uint8_t num = table_to_bytes(L, 2, types, sizeof(types));
    uint8_t res = nb_define_external_function(name, num, types, return_type);
    lua_pushinteger(L, res);
    return 1;
}

static int create(lua_State *L) {   
    size_t size;
    char *p_src = (char*)lua_tolstring(L, 1, &size);
    nb_cpu_t *C = (nb_cpu_t *)lua_newuserdata(L, sizeof(nb_cpu_t));
    if(C != NULL) {
        C->pv_vm = nb_create();
        if(C->pv_vm == NULL) {
            lua_pop(L, 1);
            lua_pushnil(L);
            lua_pushinteger(L, -1);
            return 2;
        }
        C->p_src = p_src;
        C->src_pos = 0;
        memset(C->screen_buffer, ' ', MAX_LINES * MAX_LINE_LEN);
        for(int i = 1; i < MAX_LINES; i++) {
            C->screen_buffer[i * MAX_LINE_LEN - 1] = '\n';
        }
        C->screen_buffer[MAX_LINES * MAX_LINE_LEN - 1] = '\0';
        C->xpos = 0;
        C->ypos = 0;
        p_Cpu = C;
        uint16_t errors = nb_compile(C->pv_vm, (void *)C);
        p_Cpu = NULL;
        if(errors > 0) {
            luaL_getmetatable(L, "nb_cpu");
            lua_setmetatable(L, -2);
            lua_pushinteger(L, errors);
            return 2;
        }
        luaL_getmetatable(L, "nb_cpu");
        lua_setmetatable(L, -2);
        lua_pushinteger(L, 0);
        return 2;
    }
    lua_pop(L, 1);
    lua_pushnil(L);
    lua_pushinteger(L, -2);
    return 2;
}

static int run(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    uint16_t cycles = (uint16_t)luaL_checkinteger(L, 2);
    uint8_t x, y;

    int res = NB_BUSY;
    if(C != NULL) {
        p_Cpu = C;
        while(cycles > 0 && res >= NB_BUSY) {
            res = nb_run(C->pv_vm, &cycles);
            if(res >= NB_XFUNC) {
                switch(res) {
                case SETCUR:
                    y = nb_pop_num(C->pv_vm);
                    x = nb_pop_num(C->pv_vm);
                    C->xpos = MAX(1, MIN(x, MAX_LINE_LEN)) - 1;
                    C->ypos = MAX(1, MIN(y, MAX_LINES)) - 1;
                    break;
                case GETCURX:
                    nb_push_num(C->pv_vm, C->xpos + 1);
                    break;
                case GETCURY:
                    nb_push_num(C->pv_vm, C->ypos + 1);
                    break;
                case CLRSCR:
                    memset(C->screen_buffer, ' ', sizeof(C->screen_buffer));
                    C->screen_buffer[sizeof(C->screen_buffer) - 1] = '\0';
                    C->xpos = 0;
                    C->ypos = 0;
                    break;
                case CLRLINE:
                    y = nb_pop_num(C->pv_vm);
                    if(y > 0) {
                        C->ypos = MAX(1, MIN(y, MAX_LINES)) - 1;
                    } else {
                        C->xpos = 0;
                    }
                    memset(C->screen_buffer + C->ypos * MAX_LINE_LEN, ' ', MAX_LINE_LEN);
                    break;
                default:
                    p_Cpu = NULL;
                    lua_pushinteger(L, res);
                    return 1;
                }
            }
        }
        if(res == NB_END) {
            nb_print("Ready.\n");
        }
        p_Cpu = NULL;
        lua_pushinteger(L, res);
        return 1;
    }
    lua_pushinteger(L, -1);
    return 1;
}

static int get_screen_buffer(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        for(int i = 1; i < MAX_LINES; i++) {
            C->screen_buffer[i * MAX_LINE_LEN - 1] = '\n';
        }
        C->screen_buffer[MAX_LINES * MAX_LINE_LEN - 1] = '\0';
        lua_pushlstring(L, C->screen_buffer, MAX_LINES * MAX_LINE_LEN);
        return 1;
    }
    return 0;
}

static int clear_screen(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        memset(C->screen_buffer, ' ', sizeof(C->screen_buffer));
        C->screen_buffer[sizeof(C->screen_buffer) - 1] = '\0';
        C->xpos = 0;
        C->ypos = 0;
     }
    return 0;
}

static int print(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        const char *s = luaL_checkstring(L, 2);
        p_Cpu = C;
        nb_print("%s", s);
        p_Cpu = NULL;
        return 0;
    }
    return 0;
}

static int reset(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        nb_reset(C->pv_vm);
        lua_pushboolean(L, 1);
        return 1;
    }
    lua_pushboolean(L, 0);
    return 1;
}

static int destroy(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        nb_destroy(C->pv_vm);
        C->pv_vm = NULL; 
    }
    return 0;
}

static int dump_code(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        nb_dump_code(C->pv_vm);
        return 0;
    }
    return 0;
}

static int output_symbol_table(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        nb_output_symbol_table(C->pv_vm);
        return 0;
    }
    return 0;
}

/*
** Store/resore the VM
*/
static int pack_vm(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        size_t size = sizeof(nb_cpu_t) * 2 + sizeof(t_VM) * 2;
        // pack the VM into a Lua string by means of bin_to_str (binary to HEX string conversion)
        char s[size];
        bin_to_str(s, (uint8_t*)C, sizeof(nb_cpu_t) * 2);
        bin_to_str(s + sizeof(nb_cpu_t) * 2, (uint8_t*)C->pv_vm, sizeof(t_VM) * 2);
        lua_pushlstring(L, s, size);
        //printf("pack_vm %ld\n", size);
        return 1;
    }
    return 0;
}

static int unpack_vm(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if((C != NULL) && (lua_isstring(L, 2))) {
        size_t size;
        const char *s = lua_tolstring(L, 2, &size);
        if(size == (sizeof(nb_cpu_t) * 2 + sizeof(t_VM) * 2)) {
            // unpack the VM from a Lua string by means of str_to_bin (HEX string to binary conversion)
            nb_cpu_t cpu;
            t_VM *p_vm = malloc(sizeof(t_VM));
            if(p_vm == NULL) {
                lua_pushboolean(L, 0);
                return 1;
            }
            str_to_bin((uint8_t*)&cpu, (char*)s, sizeof(nb_cpu_t) * 2);
            str_to_bin((uint8_t*)p_vm, (char*)s + sizeof(nb_cpu_t) * 2, sizeof(t_VM) * 2);
            C->pv_vm = p_vm;
            C->p_src = cpu.p_src;
            C->src_pos = cpu.src_pos;
            memcpy(C->screen_buffer, cpu.screen_buffer, sizeof(cpu.screen_buffer));
            C->xpos = cpu.xpos;
            C->ypos = cpu.ypos;
            //printf("unpack_vm %ld\n", size);
            lua_pushboolean(L, 1);
            return 1;
        }
    }
    printf("unpack_vm failed (size mismatch)\n");
    lua_pushboolean(L, 0);
    return 1;
}

/*
** API functions for external NanoBasic functions
*/
static int get_label_address(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        char *name = (char *)luaL_checkstring(L, 2);
        uint16_t res = nb_get_label_address(C->pv_vm, name);
        lua_pushinteger(L, res);
        return 1;
    }
    return 0;
}

static int set_pc(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        uint16_t addr = luaL_checkinteger(L, 2);
        nb_set_pc(C->pv_vm, addr);
        return 0;
    }
    return 0;
}

static int stack_depth(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        uint8_t res = nb_stack_depth(C->pv_vm);
        lua_pushinteger(L, res);
        return 1;
    }
    return 0;
}

static int peek_num(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        uint8_t idx = luaL_checkinteger(L, 2);
        uint32_t res = nb_peek_num(C->pv_vm, idx);
        lua_pushinteger(L, res);
        return 1;
    }
    return 0;
}

static int pop_num(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        uint32_t res = nb_pop_num(C->pv_vm);
        lua_pushinteger(L, res);
        return 1;
    }
    return 0;
}

static int push_num(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        uint32_t value = luaL_checkinteger(L, 2);
        nb_push_num(C->pv_vm, value);
        return 0;
    }
    return 0;
}

static int push_str(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        char *str = (char *)luaL_checkstring(L, 2);
        nb_push_str(C->pv_vm, str);
        return 0;
    }
    return 0;
}

static int pop_str(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        char str[128];
        char *ptr = nb_pop_str(C->pv_vm, str, (uint8_t)sizeof(str));
        if(ptr != NULL) {
            lua_pushstring(L, ptr);
            return 1;
        }
    }
    return 0;
}

static int pop_arr_addr(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        uint16_t ref = nb_pop_arr_ref(C->pv_vm);
        lua_pushinteger(L, ref);
        return 1;
    }
    return 0;
}

static int read_arr(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        uint16_t addr = luaL_checkinteger(L, 2);
        uint8_t arr[256];
        uint16_t bytes = nb_read_arr(C->pv_vm, addr, arr, sizeof(arr));
        if(bytes > 0) {
            lua_newtable(L);
            for(uint16_t i = 0; i < bytes; i++) {
                lua_pushinteger(L, arr[i]);
                lua_rawseti(L, -2, i+1);
            }
            return 1;
        }
    }
    return 0;
}

static int write_arr(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        uint16_t addr = luaL_checkinteger(L, 2);
        uint8_t arr[256];
        uint16_t num = table_to_bytes(L, 3, arr, sizeof(arr));
        uint16_t res = nb_write_arr(C->pv_vm, addr, arr, num);
        lua_pushinteger(L, res);
        return 1;
    }
    return 0;
}

/*
** Debug interface
*/
static int get_variable_list(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    uint16_t start_idx;
    uint8_t idx = 0;
    uint8_t type;

    if(C != NULL) {
        sym_t *p_sym = nb_get_symbol_table(&start_idx);
        lua_newtable(L);
        for(int i = start_idx; i < cfg_MAX_NUM_SYM; i++) {
            if(p_sym[i].name[0] != '\0' && p_sym[i].type != LABEL) {
                // tbl[name] = {type, idx}
                type = (p_sym[i].type == ID) ? NB_NUM : (p_sym[i].type == SID) ? NB_STR : NB_ARR;
                lua_newtable(L);
                lua_pushinteger(L, type);
                lua_rawseti(L, -2, 1);
                lua_pushinteger(L, idx++);
                lua_rawseti(L, -2, 2);
                lua_setfield(L, -2, p_sym[i].name);
            }
        }
        return 1;
    }
    return 0;
}

// read_variable(type, var, idx)  (idx for arrays elements)
static int read_variable(lua_State *L) {
    nb_cpu_t *C = check_vm(L);
    if(C != NULL) {
        uint8_t type = luaL_checkinteger(L, 2);
        uint8_t var = luaL_checkinteger(L, 3);
        uint8_t idx = luaL_checkinteger(L, 4);
        if(type == NB_NUM) {
            uint32_t val = nb_get_number(C->pv_vm, var);
            printf("read num %d = %d\n", var, val);
            lua_pushinteger(L, val);
            return 1;
        } else if(type == NB_STR) {
            char *ptr = nb_get_string(C->pv_vm, var);
            if(ptr != NULL) {
                printf("read str %d = %s\n", var, ptr);
                lua_pushstring(L, ptr);
                return 1;
            }
        } else if(type == NB_ARR) {
            uint32_t val = nb_get_arr_elem(C->pv_vm, var, idx);
            printf("read arr %d(%d) = %d\n", var, idx, val);
            lua_pushinteger(L, val);
            return 1;
        }
    }
    return 0;
}

/*
** Helper functions
*/
static int hash_node_position(lua_State *L) {
    int16_t x, y, z;
    char s[12];
    char *ptr = s;
    
    if(lua_istable(L, 1)) {
        lua_getfield(L, 1, "x");
        lua_getfield(L, 1, "y");
        lua_getfield(L, 1, "z");
        x = luaL_checkint(L, -3);
        y = luaL_checkint(L, -2);
        z = luaL_checkint(L, -1);
        lua_settop(L, 0);

        ptr = hash_uint16(x + 32768, ptr);
        ptr = hash_uint16(y + 32768, ptr);
        ptr = hash_uint16(z + 32768, ptr);
        *ptr = '\0';

        lua_pushlstring(L, s, 9);
        return 1;
    }
    return 0;
}

/* msleep(): Sleep for the requested number of milliseconds. */
static int msleep(lua_State *L) {
    uint32_t msec = luaL_checkinteger(L, 1);
    struct timespec ts;
    int res;

    ts.tv_sec = msec / 1000;
    ts.tv_nsec = (msec % 1000) * 1000000;

    do {
        res = nanosleep(&ts, &ts);
    } while (res && errno == EINTR);
    lua_pushinteger(L, res);
    return 1;
}

static const luaL_Reg R[] = {
    {"version",                 version},
    {"free_mem",                free_mem},
    {"add_function",            add_function},
    {"create",                  create},
    {"reset",                   reset},
    {"destroy",                 destroy},
    {"pack_vm",                 pack_vm},
    {"unpack_vm",               unpack_vm},
    {"get_variable_list",       get_variable_list},
    {"run",                     run},
    {"get_screen_buffer",       get_screen_buffer},
    {"clear_screen",            clear_screen},
    {"print",                   print},
    {"dump_code",               dump_code},
    {"output_symbol_table",     output_symbol_table},
    {"get_label_address",       get_label_address},
    {"set_pc",                  set_pc},
    {"stack_depth",             stack_depth},
    {"peek_num",                peek_num},
    {"pop_num",                 pop_num},
    {"push_num",                push_num},
    {"pop_str",                 pop_str},
    {"push_str",                push_str},
    {"pop_arr_addr",            pop_arr_addr},
    {"read_variable",           read_variable},
    {"read_arr",                read_arr},
    {"write_arr",               write_arr},
    {"hash_node_position",      hash_node_position},
    {"msleep",                  msleep},
    {NULL, NULL}
};

/* }====================================================== */
LUALIB_API int luaopen_nanobasiclib(lua_State *L) {
    nb_init();
    assert(nb_define_external_function("setcur", 2, (uint8_t[]){NB_NUM, NB_NUM}, NB_NONE) == SETCUR);
    assert(nb_define_external_function("getcurx", 0, (uint8_t[]){}, NB_NUM) == GETCURX);
    assert(nb_define_external_function("getcury", 0, (uint8_t[]){}, NB_NUM) == GETCURY);
    assert(nb_define_external_function("clrscr", 0, (uint8_t[]){}, NB_NONE) == CLRSCR);
    assert(nb_define_external_function("clrline", 1, (uint8_t[]){NB_NUM}, NB_NONE) == CLRLINE);
    luaL_newmetatable(L, "nb_cpu");
    luaL_register(L, NULL, R);
    return 1;
}
