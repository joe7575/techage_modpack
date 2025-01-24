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
#include <errno.h>
#include <stdarg.h>
#include "nb.h"
#include "nb_int.h"

/* msleep(): Sleep for the requested number of milliseconds. */
int msleep(uint32_t msec)
{
    struct timespec ts;
    int res;

    ts.tv_sec = msec / 1000;
    ts.tv_nsec = (msec % 1000) * 1000000;

    do {
        res = nanosleep(&ts, &ts);
    } while (res && errno == EINTR);
    return res;
}

char *nb_get_code_line(void *fp, char *line, int max_line_len) {
    return fgets(line, max_line_len, fp);
}

void nb_print(const char * format, ...) {
    va_list args;
    va_start(args, format);
    vprintf(format, args);
    va_end(args);
}

int main(int argc, char* argv[]) {
    uint16_t res = NB_BUSY;
    uint16_t cycles;
    uint16_t errors;
    uint32_t timeout = 0;
#if defined(cfg_STRING_SUPPORT) && !defined(cfg_DATA_ACCESS)
    uint32_t startval = time(NULL);
#endif
#if defined(cfg_DATA_ACCESS) && !defined(cfg_STRING_SUPPORT)
    bool interrupted = false;
#endif
    if (argc != 2) {
        nb_print("Usage: %s <programm>\n", argv[0]);
        return 1;
    }
    nb_print("NanoBasic Compiler V1.0\n");
    nb_init();
#if defined(cfg_DATA_ACCESS) && !defined(cfg_STRING_SUPPORT)
    assert(nb_define_external_function("send", 3, (uint8_t[]){NB_NUM, NB_NUM, NB_REF}, NB_NONE) == NB_XFUNC + 0);
#elif defined(cfg_STRING_SUPPORT)
    assert(nb_define_external_function("setcur", 2, (uint8_t[]){NB_NUM, NB_NUM}, NB_NONE) == NB_XFUNC + 0);
    assert(nb_define_external_function("clrscr", 0, (uint8_t[]){}, NB_NONE) == NB_XFUNC + 1);
    assert(nb_define_external_function("clrline", 1, (uint8_t[]){NB_NUM}, NB_NONE) == NB_XFUNC + 2);
    assert(nb_define_external_function("time", 0, (uint8_t[]){}, NB_NUM) == NB_XFUNC + 3);
    assert(nb_define_external_function("sleep", 1, (uint8_t[]){NB_NUM}, NB_NONE) == NB_XFUNC + 4);
    assert(nb_define_external_function("input", 1, (uint8_t[]){NB_STR}, NB_NUM) == NB_XFUNC + 5);
    assert(nb_define_external_function("input$", 1, (uint8_t[]){NB_STR}, NB_STR) == NB_XFUNC + 6);
    assert(nb_define_external_function("cmd", 3, (uint8_t[]){NB_NUM, NB_ANY, NB_ANY}, NB_NUM) == NB_XFUNC + 7);
#endif

    void *instance = nb_create();

#ifdef cfg_LINE_NUMBERS
    FILE *fp = fopen("../examples/lineno.bas", "r");
#elif defined(cfg_DATA_ACCESS)
    FILE *fp = fopen("../examples/byte_access.bas", "r");
#elif !defined(cfg_STRING_SUPPORT)
    FILE *fp = fopen("../examples/heron.bas", "r");
#else
    //FILE *fp = fopen("../examples/temp.bas", "r");
    FILE *fp = fopen(argv[1], "r");
#endif
    if(fp == NULL) {
        nb_print("Error: could not open file\n");
        return -1;
    }

    errors = nb_compile(instance, fp);
    fclose(fp);

    if(errors > 0) {
        return 1;
    }

#if defined(cfg_DATA_ACCESS) && !defined(cfg_STRING_SUPPORT)
    uint16_t start = nb_get_label_address(instance, "start");
#endif
#if defined(cfg_LINE_NUMBERS)
    uint16_t error = nb_get_label_address(instance, "1000");
#else
    uint16_t error = 0;
#endif

    nb_output_symbol_table(instance);
    nb_print("\nNanoBasic Interpreter V%s\n", SVERSION);
    nb_dump_code(instance);

    while(res >= NB_BUSY) {
        cycles = 50;
        while(cycles > 0 && res >= NB_BUSY && timeout <= time(NULL)) {
            res = nb_run(instance, &cycles);
            if(res == NB_BREAK) {
                uint32_t lineno = nb_pop_num(instance);
                nb_print("Break in line %u\n", lineno);
                uint32_t val = nb_get_number(instance, 0);
                printf("read num %d = %d\n", 0, val);
#ifdef cfg_STRING_SUPPORT                
                char *ptr = nb_get_string(instance, 1);
                if(ptr != NULL) {
                    printf("read str %d = %s\n", 1, ptr);
                }
#endif
                val = nb_get_arr_elem(instance, 3, 0);
                printf("read arr %d(%d) = %d\n", 3, 0, val);
#if defined(cfg_DATA_ACCESS) && !defined(cfg_STRING_SUPPORT)
            } else if(res == NB_RETI) {
                interrupted = false;
            } else if(res == NB_XFUNC) {
                // send
                uint8_t arr[80];
                uint16_t ref = nb_pop_arr_ref(instance);
                nb_read_arr(instance, ref, arr, 80);
                uint32_t id = nb_pop_num(instance);
                uint8_t port = nb_pop_num(instance);
                nb_print("send on port %d: %u %02X %02X %02X %02X %08X\n", port, id, arr[0], arr[1], arr[2], arr[3], ACS32(arr[4]));
                if(start > 0 && !interrupted) {
                    nb_set_pc(instance, start);
                    nb_push_num(instance, 1);
                    nb_push_num(instance, 2);
                    nb_write_arr(instance, ref, (uint8_t*)"\x08\x07\x06\x05\x04\x03\x02\x01", 8);
                    interrupted = true;
                }    
#elif defined(cfg_STRING_SUPPORT)
            } else if(res == NB_XFUNC) {
                // setcur
                uint8_t y = nb_pop_num(instance);
                uint8_t x = nb_pop_num(instance);
                x = MAX(1, MIN(x, 60));
                y = MAX(1, MIN(y, 60));
                nb_print("\033[%u;%uH", y, x);
            } else if(res == NB_XFUNC + 1) {
                // clrscr
                nb_print("\033[2J");
            } else if(res == NB_XFUNC + 2) {
                // clrline
                nb_print("\033[2K");
            } else if(res == NB_XFUNC + 3) {
                // time
                nb_push_num(instance, time(NULL) - startval);
            } else if(res == NB_XFUNC + 4) {
                // sleep
                timeout = time(NULL) + nb_pop_num(instance);
            } else if(res == NB_XFUNC + 5) {
                // input
                char str[80];
                nb_pop_str(instance, str, 80);
                nb_print("%s?  ", str);
                //fgets(str, 80, stdin);
                //str[strlen(str)-1] = '\0';
                //nb_push_num(instance, atoi(str));
                nb_push_num(instance, 12);
            } else if(res == NB_XFUNC + 6) {
                // input$
                char str[80];
                nb_pop_str(instance, str, 80);
                nb_print("%s?  ", str);
                //fgets(str, 80, stdin);
                //str[strlen(str)-1] = '\0';
                //nb_push_str(instance, str);
                nb_push_str(instance, "Joe");
#endif
            } else if(res == NB_XFUNC + 7) {
                // cmd
                uint8_t depth = nb_stack_depth(instance);
                if(depth == 3) {
                    uint32_t val1 = nb_peek_num(instance, 3);
                    if(val1 >= 128) {
#ifdef cfg_STRING_SUPPORT                        
                        char buff[80];
                        char *str3 = nb_pop_str(instance, buff, 80);
                        uint32_t val2 = nb_pop_num(instance);
                        nb_print("cmd on port %u, %d, %s\n", val1, val2, str3);
#else
                        uint32_t val2 = nb_pop_num(instance);
                        nb_print("cmd on port %u, %d\n", val1, val2);
#endif
                    } else {
                        uint32_t val3 = nb_pop_num(instance);
                        uint32_t val2 = nb_pop_num(instance);
                        nb_print("cmd on port %u, %d, %d\n", val1, val2, val3);
                    }
                    nb_pop_num(instance);
                    nb_push_num(instance, -1);
                } else if(depth == 2) {
                    uint32_t val2 = nb_pop_num(instance);
                    uint32_t val1 = nb_pop_num(instance);
                    nb_print("cmd on port %u, %u\n", val1, val2);
                    nb_push_num(instance, 0);
                    nb_set_pc(instance, error);
                    nb_push_num(instance, 3);
                } else {
                    nb_print("Error: wrong number of parameters\n");
                    nb_push_num(instance, -3);
                }
            } else if(res >= NB_XFUNC) {
                nb_print("Unknown external function\n");
            }
        }
        msleep(100);
    }
    nb_destroy(instance);
    nb_print("Ready.\n");
    return 0;
}
