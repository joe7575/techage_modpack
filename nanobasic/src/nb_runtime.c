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

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <assert.h>
#include <time.h>
#include "nb.h"
#include "nb_int.h"

#define STRBUF1  0x7FF1 // temporary string buffers
#define STRBUF2  0x7FF2

#define PUSH(x) vm->stack[(uint16_t)(vm->sp++) % cfg_STACK_SIZE] = (x)
#define POP()   vm->stack[(uint16_t)(--vm->sp) % cfg_STACK_SIZE]
#define TOP()   vm->stack[(uint16_t)(vm->sp - 1) % cfg_STACK_SIZE]
#define PEEK(x) vm->stack[(uint16_t)(vm->sp + (x)) % cfg_STACK_SIZE]

#define PPUSH(x) vm->paramstack[(uint8_t)(vm->psp++) % cfg_STACK_SIZE] = x
#define PPOP()   vm->paramstack[(uint8_t)(--vm->psp) % cfg_STACK_SIZE]

/***************************************************************************************************
**    static function-prototypes
***************************************************************************************************/
static char *get_string(t_VM *vm, uint16_t addr);
#ifdef cfg_STRING_SUPPORT
static char *alloc_temp_string(t_VM *vm, uint16_t *p_addr);
static uint16_t realloc_string(t_VM *vm);
#endif

/***************************************************************************************************
**    global functions
***************************************************************************************************/
void nb_reset(void *pv_vm) {
    t_VM *vm = pv_vm;
    vm->pc = 1;
    vm->sp = 0;
    vm->psp = 0;
    memset(vm->variables, 0, sizeof(vm->variables));
    memset(vm->stack, 0, sizeof(vm->stack));
    memset(vm->paramstack, 0, sizeof(vm->paramstack));
    memset(vm->heap, 0, sizeof(vm->heap));
    nb_mem_init(vm);
}

/*
** Debug Interface
*/
int32_t nb_get_number(void *pv_vm, uint8_t var) {
    t_VM *vm = pv_vm;
    if(var >= cfg_NUM_VARS) {
        return 0;
    }
    return vm->variables[var];
}

#ifdef cfg_STRING_SUPPORT
char *nb_get_string(void *pv_vm, uint8_t var) {
    t_VM *vm = pv_vm;
    if(var >= cfg_NUM_VARS) {
        return 0;
    }
    return get_string(vm, vm->variables[var]);
}
#endif

int32_t nb_get_arr_elem(void *pv_vm, uint8_t var, uint16_t idx) {
    t_VM *vm = pv_vm;
    if(var >= cfg_NUM_VARS) {
        return 0;
    }
    uint16_t addr = vm->variables[var];
    return ACS32(vm->heap[(addr & 0x7FFF) + idx * sizeof(uint32_t)]);
}

/*
** External function interface
*/
int32_t nb_pop_num(void *pv_vm) {
    t_VM *vm = pv_vm;
    if(vm->psp == 0) {
        return 0;
    }
    return PPOP();
}

// @param idx = stack position (1..n) 1 = top of stack
int32_t nb_peek_num(void *pv_vm, uint8_t idx) {
    t_VM *vm = pv_vm;
    if(vm->psp < idx) {
        return -1;
    }
    return vm->paramstack[(vm->psp - idx) % cfg_STACK_SIZE];
}

void nb_push_num(void *pv_vm, int32_t value) {
    t_VM *vm = pv_vm;
    if(vm->psp < cfg_STACK_SIZE) {
        PPUSH(value);
    }
}

#ifdef cfg_STRING_SUPPORT
char *nb_pop_str(void *pv_vm, char *str, uint8_t len) {
    t_VM *vm = pv_vm;
    if(vm->psp == 0) {
        return NULL;
    }
    uint16_t addr = PPOP();
    strncpy(str, get_string(vm, addr), len);
    return str;
}

void nb_push_str(void *pv_vm, char *str) {
    t_VM *vm = pv_vm;
    uint16_t addr;
    char *ptr;
    if(vm->psp < cfg_STACK_SIZE) {
        ptr = alloc_temp_string(vm, &addr);
        strncpy(ptr, str, sizeof(vm->strbuf1));
        PPUSH(addr);
    }
}
#endif

uint16_t nb_pop_arr_ref(void *pv_vm) {
    t_VM *vm = pv_vm;
    if(vm->psp == 0) {
        return 0;
    }
    return (uint16_t)PPOP();
}

uint16_t nb_read_arr(void *pv_vm, uint16_t addr, uint8_t *arr, uint16_t bytes) {
    t_VM *vm = pv_vm;
    if(addr < 0x8000) {
        memset(arr, 0, bytes);
        return 0;
    }
    uint16_t size = nb_mem_get_blocksize(vm, addr);
    if(size == 0) {
        memset(arr, 0, bytes);
        return 0;
    }
    size = MIN(size, bytes);
    memcpy(arr, &vm->heap[addr & 0x7FFF], size);
    return size;
}

uint16_t nb_write_arr(void *pv_vm, uint16_t addr, uint8_t *arr, uint16_t bytes) {
    t_VM *vm = pv_vm;
    if(addr < 0x8000) {
        return 0;
    }
    uint16_t size = nb_mem_get_blocksize(vm, addr);
    if(size == 0) {
        return 0;
    }
    size = MIN(size, bytes);
    memcpy(&vm->heap[addr & 0x7FFF], arr, size);
    return size;
}

uint8_t nb_stack_depth(void *pv_vm) {
    t_VM *vm = pv_vm;
    return vm->psp;
}

void nb_set_pc(void * pv_vm, uint16_t addr) {
    t_VM *vm = pv_vm;
    PUSH(vm->pc);
    vm->pc = addr;
}

/*
** Run the programm
*/
uint16_t nb_run(void *pv_vm, uint16_t *p_cycles) {
    int32_t tmp1, tmp2;
    uint16_t idx;
    uint16_t addr, size;
    uint16_t offs1;
#ifdef cfg_DATA_ACCESS
    uint16_t offs2, size1, size2;
#endif
    uint8_t  var, val;
#ifdef cfg_STRING_SUPPORT
    char *ptr, *str1, *str2;
#endif
    t_VM *vm = pv_vm;

    while((*p_cycles)-- > 1)
    {
        //printf("[nanobasic] %08lX %04X = %02X\n", (uint64_t)vm, vm->pc, vm->code[vm->pc]);
        switch (vm->code[vm->pc])
        {
        case k_END:
            return NB_END;
        case k_PRINT_STR_N1:
            tmp1 = POP();
            nb_print("%s", get_string(vm, tmp1));
            vm->pc += 1;
            break;
        case k_PRINT_VAL_N1:
            nb_print("%d ", POP());
            vm->pc += 1;
            break;
        case k_PRINT_NEWL_N1:
            nb_print("\n");
            vm->pc += 1;
            break;
        case k_PRINT_TAB_N1:
            nb_print("\t");
            vm->pc += 1;
            break;
        case k_PRINT_SPACE_N1:
            nb_print(" ");
            vm->pc += 1;
            break;
        case k_PRINT_BLANKS_N1:
            val = POP();
            for(uint8_t i = 0; i < val; i++) {
                nb_print(" ");
            }
            vm->pc += 1;
            break;
        case k_PRINT_LINENO_N3:
            tmp1 = ACS16(vm->code[vm->pc + 1]);
            nb_print("[%u] ", tmp1);
            vm->pc += 3;
            break;
        case k_PUSH_STR_Nx:
            tmp1 = vm->code[vm->pc + 1]; // string length
            PUSH(vm->pc + 2);  // push string address
            vm->pc += tmp1 + 2;
            break;
        case k_PUSH_NUM_N5:
            PUSH(ACS32(vm->code[vm->pc + 1]));
            vm->pc += 5;
            break;
        case k_PUSH_NUM_N2:
            PUSH(vm->code[vm->pc + 1]);
            vm->pc += 2;
            break;
        case k_PUSH_VAR_N2:
            var = vm->code[vm->pc + 1];
            PUSH(vm->variables[var]);
            vm->pc += 2;
            break;
        case k_POP_VAR_N2:
            var = vm->code[vm->pc + 1];
            vm->variables[var] = POP();
            vm->pc += 2;
            break;
#ifdef cfg_STRING_SUPPORT
        case k_POP_STR_N2:
            var  = vm->code[vm->pc + 1];
            addr = realloc_string(vm);
            vm->variables[var] = addr;
            vm->pc += 2;
            break;
#endif
        case k_DIM_ARR_N2:
            var = vm->code[vm->pc + 1];
#ifdef cfg_STRING_SUPPORT
            if(vm->variables[var] > 0x7FFF) {
                nb_mem_free(vm, vm->variables[var]);
            }
#else
             if(vm->variables[var] > 0) {
                nb_print("Error: Array already dimensioned\n");
                return NB_ERROR;
            }
#endif
            size = POP();
            addr = nb_mem_alloc(vm, (size + 1) * sizeof(uint32_t));
            if(addr == 0) {
                nb_print("Error: Out of memory\n");
                return NB_ERROR;
            }
            memset(&vm->heap[addr & 0x7FFF], 0, (size + 1) * sizeof(uint32_t));
            vm->variables[var] = addr;
            vm->pc += 2;
            break;
        case k_BREAK_INSTR_N3:
            tmp1 = ACS16(vm->code[vm->pc + 1]);
            PPUSH(tmp1);
            vm->pc += 3; 
            return NB_BREAK;
        case k_ADD_N1:
            tmp2 = POP();
            TOP() = TOP() + tmp2;
            vm->pc += 1;
            break;
        case k_SUB_N1:
            tmp2 = POP();
            TOP() = TOP() - tmp2;
            vm->pc += 1;
            break;
        case k_MUL_N1:
            tmp2 = POP();
            TOP() = TOP() * tmp2;
            vm->pc += 1;
            break;
        case k_DIV_N1:
            tmp2 = POP();
            if(tmp2 == 0) {
                nb_print("Error: Division by zero\n");
                PUSH(0);
            } else {
                TOP() = TOP() / tmp2;
            }
            vm->pc += 1;
            break;
        case k_MOD_N1:
            tmp2 = POP();
            if(tmp2 == 0) {
                PUSH(0);
            } else {
                tmp2 = TOP() % tmp2;
                TOP() = tmp2;
            }
            vm->pc += 1;
            break;
        case k_AND_N1:
            tmp2 = POP();
            TOP() = TOP() && tmp2;
            vm->pc += 1;
            break;
        case k_OR_N1:
            tmp2 = POP();
            TOP() = TOP() || tmp2;
            vm->pc += 1;
            break;
        case k_NOT_N1:
            TOP() = !TOP();
            vm->pc += 1;
            break;
        case k_NEG_N1:
            TOP() = -TOP();
            vm->pc += 1;
            break;
        case k_EQUAL_N1:
            tmp2 = POP();
            TOP() = TOP() == tmp2;
            vm->pc += 1;
            break;
        case k_NOT_EQUAL_N1:
            tmp2 = POP();
            TOP() = TOP() != tmp2;
            vm->pc += 1;
            break;
        case k_LESS_N1:
            tmp2 = POP();
            TOP() = TOP() < tmp2;
            vm->pc += 1;
            break;
        case k_LESS_EQU_N1:
            tmp2 = POP();
            TOP() = TOP() <= tmp2;
            vm->pc += 1;
            break;
        case k_GREATER_N1:
            tmp2 = POP();
            TOP() = TOP() > tmp2;
            vm->pc += 1;
            break;
        case k_GREATER_EQU_N1:
            tmp2 = POP();
            TOP() = TOP() >= tmp2;
            vm->pc += 1;
            break;
        case k_GOTO_N3:
            vm->pc = ACS16(vm->code[vm->pc + 1]);
            break;
        case k_GOSUB_N3:
            if(vm->sp < cfg_STACK_SIZE) {
                PUSH(vm->pc + 3);
                vm->pc = ACS16(vm->code[vm->pc + 1]);
            } else {
                nb_print("Error: Call stack overflow\n");
                return NB_ERROR;
            }
            break;
        case k_RETURN_N1:
            vm->pc = (uint16_t)POP();
            break;
        case k_RETI_N1:
            vm->pc = (uint16_t)POP();
            return NB_RETI;
        case k_FOR_N1:
            if(++vm->nested_loop_idx > cfg_MAX_FOR_LOOPS) {
                nb_print("Error: too many nested 'for' loops");
                return NB_ERROR;
            }
            vm->pc += 1;
            break;
        case k_NEXT_N4:
            // ID = ID + stack[-1]
            // IF ID <= stack[-2] GOTO start
            tmp1 = ACS16(vm->code[vm->pc + 1]);
            var = vm->code[vm->pc + 3];
            vm->variables[var] = vm->variables[var] + TOP();
            if(vm->variables[var] <= PEEK(-2)) {
              vm->pc = tmp1;
            } else {
              vm->pc += 4;
              (void)POP();  // remove step value
              (void)POP();  // remove loop end value
              vm->nested_loop_idx--;
            }
            break;
        case k_IF_N3:
            if(POP() == 0) {
              vm->pc = ACS16(vm->code[vm->pc + 1]);
            } else {
              vm->pc += 3;
            }
            break;
        case k_READ_NUM_N1:
            if(vm->data_start_addr + vm->data_read_offs + 4 > vm->code_size) {
                nb_print("Error: Out of data\n");
                return NB_ERROR;
            }
            tmp1 = ACS32(vm->code[vm->data_start_addr + vm->data_read_offs]);
            if(tmp1 & k_DATA_STR_TAG) {
                nb_print("Error: Data type mismatch\n");
                return NB_ERROR;
            }
            PUSH(tmp1);
            vm->data_read_offs += 4;
            vm->pc += 1;
            break;
        case k_READ_STR_N1:
            if(vm->data_start_addr + vm->data_read_offs + 4 > vm->code_size) {
                nb_print("Error: Out of data\n");
                return NB_ERROR;
            }
            tmp1 = ACS32(vm->code[vm->data_start_addr + vm->data_read_offs]);
            if((tmp1 & k_DATA_STR_TAG) != k_DATA_STR_TAG) {
                nb_print("Error: Data type mismatch\n");
                return NB_ERROR;
            }
            PUSH(tmp1 & ~k_DATA_STR_TAG);
            vm->data_read_offs += 4;
            vm->pc += 1;
            break;
        case k_RESTORE_N1:
            offs1 = POP() * sizeof(uint32_t);
            vm->data_read_offs = offs1;
            vm->pc += 1;
            break;
        case k_ON_GOTO_N2:
            idx = POP();
            val = vm->code[vm->pc + 1];
            vm->pc += 2;
            if(idx == 0 || idx > val) {
                vm->pc += val * 3;
            } else {
                vm->pc += (idx - 1) * 3;
            }
            break;
        case k_ON_GOSUB_N2:
            idx = POP();
            val = vm->code[vm->pc + 1];
            vm->pc += 2;
            if(idx == 0 || idx > val) {
                vm->pc += val * 3;  // skip all addresses
            } else {
                if(vm->sp < cfg_STACK_SIZE) {
                    PUSH(vm->pc + val * 3);  // return address to the next instruction
                    vm->pc += (idx - 1) * 3;  // jump to the selected address
                } else {
                    nb_print("Error: Call stack overflow\n");
                    return NB_ERROR;
                }
            }
            break;
        case k_SET_ARR_ELEM_N2:
            var = vm->code[vm->pc + 1];
            addr = vm->variables[var] & 0x7FFF;
            tmp1 = POP();
            tmp2 = POP() * sizeof(uint32_t);
            if(tmp2 >= nb_mem_get_blocksize(vm, addr)) {
                nb_print("Error: Array index out of bounds\n");
                return NB_ERROR;
            }
            ACS32(vm->heap[addr + tmp2]) = tmp1;
            vm->pc += 2;
            break;
        case k_GET_ARR_ELEM_N2:
            var = vm->code[vm->pc + 1];
            addr = vm->variables[var] & 0x7FFF;
            tmp1 = POP() * sizeof(uint32_t);
            if(tmp1 >= nb_mem_get_blocksize(vm, addr)) {
                nb_print("Error: Array index out of bounds\n");
                return NB_ERROR;
            }
            PUSH(ACS32(vm->heap[addr + tmp1]));
            vm->pc += 2;
            break;
#ifdef cfg_DATA_ACCESS            
        case k_SET_ARR_1BYTE_N2:
            var = vm->code[vm->pc + 1];
            addr = vm->variables[var] & 0x7FFF;
            tmp1 = POP();
            tmp2 = POP();
            if(tmp2 >= nb_mem_get_blocksize(vm, addr)) {
                nb_print("Error: Array index out of bounds\n");
                return NB_ERROR;
            }
            ACS8(vm->heap[addr + tmp2]) = tmp1;
            vm->pc += 2;
            break;
        case k_GET_ARR_1BYTE_N2:
            var = vm->code[vm->pc + 1];
            addr = vm->variables[var] & 0x7FFF;
            tmp1 = POP();
            if(tmp1 >= nb_mem_get_blocksize(vm, addr)) {
                nb_print("Error: Array index out of bounds\n");
                return NB_ERROR;
            }
            PUSH(ACS8(vm->heap[addr + tmp1]));
            vm->pc += 2;
            break;
        case k_SET_ARR_2BYTE_N2:
            var = vm->code[vm->pc + 1];
            addr = vm->variables[var] & 0x7FFF;
            tmp1 = POP();
            tmp2 = POP();
            if(tmp2 + 1 >= nb_mem_get_blocksize(vm, addr)) {
                nb_print("Error: Array index out of bounds\n");
                return NB_ERROR;
            }
            ACS16(vm->heap[addr + tmp2]) = tmp1;
            vm->pc += 2;
            break;
        case k_GET_ARR_2BYTE_N2:
            var = vm->code[vm->pc + 1];
            addr = vm->variables[var] & 0x7FFF;
            tmp1 = POP();
            if(tmp1 + 1 >= nb_mem_get_blocksize(vm, addr)) {
                nb_print("Error: Array index out of bounds\n");
                return NB_ERROR;
            }
            PUSH(ACS16(vm->heap[addr + tmp1]));
            vm->pc += 2;
            break;
        case k_SET_ARR_4BYTE_N2:
            var = vm->code[vm->pc + 1];
            addr = vm->variables[var] & 0x7FFF;
            tmp1 = POP();
            tmp2 = POP();
            if(tmp2 + 3 >= nb_mem_get_blocksize(vm, addr)) {
                nb_print("Error: Array index out of bounds\n");
                return NB_ERROR;
            }
            ACS32(vm->heap[addr + tmp2]) = tmp1;
            vm->pc += 2;
            break;
        case k_GET_ARR_4BYTE_N2:
            var = vm->code[vm->pc + 1];
            addr = vm->variables[var] & 0x7FFF;
            tmp1 = POP();
            if(tmp1 + 3 >= nb_mem_get_blocksize(vm, addr)) {
                nb_print("Error: Array index out of bounds\n");
                return NB_ERROR;
            }
            PUSH(ACS32(vm->heap[addr + tmp1]));
            vm->pc += 2;
            break;
        case k_COPY_N1:
            // copy(arr, offs, arr, offs, bytes)
            size = POP();  // number of bytes
            offs2 = POP();  // source offset
            tmp2 = POP() & 0x7FFF;  // source address
            offs1 = POP();  // destination offset
            tmp1 = POP() & 0x7FFF;  // destination address
            size1 = nb_mem_get_blocksize(vm, tmp1);
            size2 = nb_mem_get_blocksize(vm, tmp2);
            if(size + offs1 > size1 || size + offs2 > size2) {
                nb_print("Error: Array index out of bounds\n");
                return NB_ERROR;
            }
            memcpy(&vm->heap[tmp1 + offs1], &vm->heap[tmp2 + offs2], size);
            vm->pc += 1;
            break;
#endif
        case k_PARAM_N1:
        case k_PARAMS_N1:
            if(vm->psp > 0) {
                    tmp1 = PPOP();
            } else {
                    tmp1 = 0;
            }
            PUSH(tmp1);
            vm->pc += 1;
            break;
        case k_XFUNC_N2:
            val = vm->code[vm->pc + 1];
            vm->pc += 2;
            return NB_XFUNC + val;
        case k_PUSH_PARAM_N1:
            PPUSH(POP());
            vm->pc += 1;
            break;
#ifdef cfg_STRING_SUPPORT
        case k_ERASE_ARR_N2:
            var = vm->code[vm->pc + 1];
            addr = vm->variables[var];
            if(addr > 0x7FFF) {
                nb_mem_free(vm, addr);
            }
            vm->variables[var] = 0;
            vm->pc += 2;
            break;
#endif
        case k_FREE_N1:
            nb_print(" %u/%u/%u bytes free (code/data/heap)", cfg_MAX_CODE_SIZE - vm->code_size,
                sizeof(vm->variables) - (vm->num_vars * sizeof(uint32_t)), nb_mem_get_free(vm));
        case k_RND_N1:
            tmp1 = POP();
            if(tmp1 == 0) {
                PUSH(0);
            } else {
                PUSH(rand() % (tmp1 + 1));
            }
            vm->pc += 1;
            break;
#ifdef cfg_STRING_SUPPORT
        case k_ADD_STR_N1:
            tmp2 = POP();
            tmp1 = POP();
            str1 = get_string(vm, tmp1);
            str2 = get_string(vm, tmp2);
            ptr = alloc_temp_string(vm, &addr);
            strncpy(ptr, str1, k_MAX_LINE_LEN-1);
            strncat(ptr, str2, k_MAX_LINE_LEN-1);
            PUSH(addr);
            vm->pc += 1;
            break;
        case k_STR_EQUAL_N1:
            tmp2 = POP();
            tmp1 = POP();
            PUSH(strcmp(get_string(vm, tmp1), get_string(vm, tmp2)) == 0 ? 1 : 0);
            vm->pc += 1;
            break;
        case k_STR_NOT_EQU_N1 :
            tmp2 = POP();
            tmp1 = POP();
            PUSH(strcmp(get_string(vm, tmp1), get_string(vm, tmp2)) == 0 ? 0 : 1);
            vm->pc += 1;
            break;
        case k_STR_LESS_N1:
            tmp2 = POP();
            tmp1 = POP();
            PUSH(strcmp(get_string(vm, tmp1), get_string(vm, tmp2)) < 0 ? 1 : 0);
            vm->pc += 1;
            break;
        case k_STR_LESS_EQU_N1:
            tmp2 = POP();
            tmp1 = POP();
            PUSH(strcmp(get_string(vm, tmp1), get_string(vm, tmp2)) <= 0 ? 1 : 0);
            vm->pc += 1;
            break;
        case k_STR_GREATER_N1:
            tmp2 = POP();
            tmp1 = POP();
            PUSH(strcmp(get_string(vm, tmp1), get_string(vm, tmp2)) > 0 ? 1 : 0);
            vm->pc += 1;
        case k_STR_GREATER_EQU_N1:
            tmp2 = POP();
            tmp1 = POP();
            PUSH(strcmp(get_string(vm, tmp1), get_string(vm, tmp2)) >= 0 ? 1 : 0);
            vm->pc += 1;
            break;
        case k_LEFT_STR_N1:
            tmp2 = POP();  // number of characters
            tmp1 = POP();  // string address
            tmp2 = MIN(k_MAX_LINE_LEN - 1, tmp2);
            ptr = alloc_temp_string(vm, &addr);
            strncpy(ptr, get_string(vm, tmp1), tmp2);
            ptr[tmp2] = 0;
            PUSH(addr);
            vm->pc += 1;
            break;
        case k_RIGHT_STR_N1:
            tmp2 = POP();  // number of characters
            tmp1 = POP();  // string address
            str1 = get_string(vm, tmp1);
            size = strlen(str1);
            tmp2 = MIN(size, tmp2);
            ptr = alloc_temp_string(vm, &addr);
            strncpy(ptr, str1 + size - tmp2, tmp2);
            ptr[tmp2] = 0;
            PUSH(addr);
            vm->pc += 1;
            break;
        case k_MID_STR_N1:
            tmp2 = POP();  // number of characters
            tmp1 = POP() - 1;  // start position
            idx = POP();   // string address
            str1 = get_string(vm, idx);
            size = strlen(str1);
            tmp1 = MIN(size, tmp1);
            tmp2 = MIN(size - tmp1, tmp2);
            ptr = alloc_temp_string(vm, &addr);
            strncpy(ptr, str1 + tmp1, tmp2);
            ptr[tmp2] = 0;
            PUSH(addr);
            vm->pc += 1;
            break;
        case k_STR_LEN_N1:
            tmp1 = POP();
            PUSH(strlen(get_string(vm, tmp1)));
            vm->pc += 1;
            break;
        case k_STR_TO_VAL_N1:
            tmp1 = POP();
            PUSH(atoi(get_string(vm, tmp1)));
            vm->pc += 1;
            break;
        case k_VAL_TO_STR_N1:
            tmp1 = POP();
            snprintf(alloc_temp_string(vm, &addr), sizeof(vm->strbuf1), "%d", tmp1);
            PUSH(addr);
            vm->pc += 1;
            break;
        case k_VAL_TO_HEX_N1:
            tmp1 = POP();
            snprintf(alloc_temp_string(vm, &addr), sizeof(vm->strbuf1), "%X", tmp1);
            PUSH(addr);
            vm->pc += 1;
            break;
        case k_INSTR_N1:
            tmp2 = POP();  // string address
            tmp1 = POP();  // search string
            val = POP();   // start position
            val = MAX(val, 1);
            str1 = get_string(vm, tmp1);
            str2 = get_string(vm, tmp2);
            val = MIN(val, strlen(str1));
            str2 = strstr(&str1[val-1], str2);
            if(str2 == NULL) {
                PUSH(0);
            } else {
                PUSH(str2 - str1 + 1);
            }
            vm->pc += 1;
            break;
#endif
#ifdef cfg_STRING_SUPPORT
        case k_ALLOC_STR_N1:
            tmp2 = POP();  // address of the fill char
            tmp2 = get_string(vm, tmp2)[0];
            tmp1 = POP();  // string length
            tmp1 = MIN(k_MAX_LINE_LEN - 1, tmp1);
            ptr = alloc_temp_string(vm, &addr);
            memset(ptr, tmp2, tmp1);
            ptr[tmp1] = 0;
            PUSH(addr);
            vm->pc += 1;
            break;
#endif
        default:
            nb_print("Error: unknown opcode '%u'\n", vm->code[vm->pc]);
            return NB_ERROR;
        }
    }
    return NB_BUSY;
}

void nb_destroy(void * pv_vm) {
    free(pv_vm);
}

/***************************************************************************************************
* Static functions
***************************************************************************************************/
static char *get_string(t_VM *vm, uint16_t addr) {
#ifdef cfg_STRING_SUPPORT
    if(addr == STRBUF1) {
        return vm->strbuf1;
    } else if(addr == STRBUF2) {
        return vm->strbuf2;
    } else 
#endif
    if(addr >= 0x8000) {
        if(vm->heap[addr & 0x7FFF] == 0) {
            return "";
        }
        return (char*)&vm->heap[addr & 0x7FFF];
    } else if(addr == 0) {
        return "";
    } else {
        if(vm->code[addr] == 0) {
            return "";
        }
        return (char*)&vm->code[addr];
    }
}

#ifdef cfg_STRING_SUPPORT
static char *alloc_temp_string(t_VM *vm, uint16_t *p_addr) {
    if(vm->strbuf1_used) {
        vm->strbuf1_used = false;
        *p_addr = STRBUF2;
        return vm->strbuf2;
    } else {
        vm->strbuf1_used = true;
        *p_addr = STRBUF1;
        return vm->strbuf1;
    }
}

static uint16_t realloc_string(t_VM *vm) {
    uint8_t var  = vm->code[vm->pc + 1];
    uint16_t addr = POP();
    char *ptr = get_string(vm, addr);
    uint16_t len = strlen(ptr) + 1;

    if(vm->variables[var] > 0x7FFF) { // heap buffer
        if(addr >= STRBUF1) { // no static string
            // Allocate a new buffer and copy the string
            uint16_t addr1 = nb_mem_realloc(vm, vm->variables[var], len);
            if(addr1 == 0) {
                nb_print("Error: Out of memory\n");
                return NB_ERROR;
            }
            memcpy(&vm->heap[addr1 & 0x7FFF], ptr, len);
            return addr1;
        } else {
            // Free the old buffer and use the static string
            nb_mem_free(vm, vm->variables[var]);
            return addr;
        }
    }
    if(addr >= STRBUF1) { // no static string
        // Allocate a new buffer and copy the string
        uint16_t addr1 = nb_mem_alloc(vm, len);
        if(addr1 == 0) {
            nb_print("Error: Out of memory\n");
            return NB_ERROR;
        }
        memcpy(&vm->heap[addr1 & 0x7FFF], ptr, len);
        return addr1;
    } else {
        // Use the new buffer
        return addr;
    }
}
#endif
