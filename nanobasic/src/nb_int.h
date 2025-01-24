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

#define k_MEM_BLOCK_SIZE    (8)     // Must be a multiple of 4 (real size is MIN_BLOCK_SIZE - 1)
#define k_MEM_FREE_TAG      (0)     // Also used for number of blocks
#define k_MAX_SYM_LEN       (10)    // Max. length of a symbol name incl. '\0'
#define k_MAX_LINE_LEN      (128)   // Max. length of a line/string
#define k_DATA_STR_TAG      (0x80000000) // To distinguish between strings and numbers in the data section


#define ACS8(x)   *(uint8_t*)&(x)
#define ACS16(x)  *(uint16_t*)&(x)
#define ACS32(x)  *(uint32_t*)&(x)
#define MIN(a,b)  ((a) < (b) ? (a) : (b))
#define MAX(a,b)  ((a) > (b) ? (a) : (b))

// Opcode definitions
enum {
    k_END,                // End of programm
    k_PRINT_STR_N1,       // (pop addr from stack)
    k_PRINT_VAL_N1,       // (pop value from stack)
    k_PRINT_NEWL_N1,      // 
    k_PRINT_TAB_N1,       // 
    k_PRINT_SPACE_N1,     // 
    k_PRINT_BLANKS_N1,    // (function spc)
    k_PRINT_LINENO_N3,    // (print line number for debugging purposes)
    k_PUSH_STR_Nx,        // nn S T R I N G 00 (push string address (16 bit))
    k_PUSH_NUM_N5,        // (push 4 byte const value)
    k_PUSH_NUM_N2,        // (push 1 byte const value)     
    k_PUSH_VAR_N2,        // (push variable)
    k_POP_VAR_N2,         // (pop variable)
    k_POP_STR_N2,         // (pop variable)
    k_DIM_ARR_N2,         // (pop variable, pop size)
    k_BREAK_INSTR_N3,     // (break with line number)
    k_ADD_N1,             // (add two values from stack)
    k_SUB_N1,             // (sub two values from stack)
    k_MUL_N1,             // (mul two values from stack)
    k_DIV_N1,             // (div two values from stack)
    k_MOD_N1,             // (mod two values from stack)
    k_AND_N1,             // (pop two values from stack)
    k_OR_N1,              // (pop two values from stack)
    k_NOT_N1,             // (pop one value from stack)
    k_NEG_N1,             // (negate)
    k_EQUAL_N1,           // (compare two values from stack)
    k_NOT_EQUAL_N1,       // (compare two values from stack)
    k_LESS_N1,            // (compare two values from stack)     
    k_LESS_EQU_N1,        // (compare two values from stack) 
    k_GREATER_N1,         // (compare two values from stack)      
    k_GREATER_EQU_N1,     // (compare two values from stack)
    k_GOTO_N3,            // (16 bit programm address)
    k_GOSUB_N3,           // (16 bit programm address)
    k_RETURN_N1,          // (pop return address)
    k_RETI_N1,            // (return from interrupt)
    k_FOR_N1,             // (check stack overflow)
    k_NEXT_N4,            // (16 bit programm address), (variable)
    k_IF_N3,              // (pop val, END address)
    k_READ_NUM_N1,        // (read const value from DATA section)
    k_READ_STR_N1,        // (read string address from DATA section)
    k_RESTORE_N1,         // (restore the data read pointer)
    k_ON_GOTO_N2,         // (on...goto with last number)
    k_ON_GOSUB_N2,        // (on...gosub with last number)
    k_SET_ARR_ELEM_N2,    // (set array element)
    k_GET_ARR_ELEM_N2,    // (get array element)
    k_SET_ARR_1BYTE_N2,   // (array: set one byte)
    k_GET_ARR_1BYTE_N2,   // (array: get one byte)
    k_SET_ARR_2BYTE_N2,   // (array: set one short)
    k_GET_ARR_2BYTE_N2,   // (array: get one short)
    k_SET_ARR_4BYTE_N2,   // (array: set one long)
    k_GET_ARR_4BYTE_N2,   // (array: get one long)
    k_COPY_N1,            // (copy)
    k_PARAM_N1,           // (pop and push value)
    k_PARAMS_N1,          // (pop and push string address)
    k_XFUNC_N2,           // (external function call)
    k_PUSH_PARAM_N1,      // (push value to parameter stack)
    k_ERASE_ARR_N2,       // (erase array)
    k_FREE_N1,            // (free memory)
    k_RND_N1,             // (random number)
    k_ADD_STR_N1,         // (add two strings from stack)
    k_STR_EQUAL_N1,       // (compare two values from stack)
    k_STR_NOT_EQU_N1,     // (compare two values from stack)
    k_STR_LESS_N1,        // (compare two values from stack)     
    k_STR_LESS_EQU_N1,    // (compare two values from stack) 
    k_STR_GREATER_N1,     // (compare two values from stack)      
    k_STR_GREATER_EQU_N1, // (compare two values from stack)
    k_LEFT_STR_N1,        // (left$)
    k_RIGHT_STR_N1,       // (right$)
    k_MID_STR_N1,         // (mid$)
    k_STR_LEN_N1,         // (len)
    k_STR_TO_VAL_N1,      // (val)
    k_VAL_TO_STR_N1,      // (str$)
    k_VAL_TO_HEX_N1,      // (hex$)
    k_INSTR_N1,           // (instr)
    k_ALLOC_STR_N1,       // (alloc string)
};

// Token types
enum {
    LET = 128, DIM, FOR, TO,    // 128 - 131
    STEP, NEXT, IF, THEN,       // 132 - 135
    PRINT, GOTO, GOSUB, RETURN, // 136 - 139
    END, REM, AND, OR,          // 140 - 143
    NOT, MOD, NUM, STR,         // 144 - 147
    ID, SID, EQ, NQ,            // 148 - 151
    LE, LQ, GR, GQ,             // 152 - 155
    XFUNC, ARR, BREAK, LABEL,   // 156 - 159
    SET1, SET2, SET4, GET1,     // 160 - 163    
    GET2, GET4, LEFTS, RIGHTS,  // 164 - 167
    MIDS, LEN, VAL, STRS,       // 168 - 171
    SPC, PARAM, COPY, CONST,    // 172 - 175
    ERASE, ELSE, HEXS, NIL,     // 176 - 179
    INSTR, ON, TRON, TROFF,     // 180 - 183
    FREE, RND, PARAMS, STRINGS, // 184 - 187
    WHILE, LOOP, ENDIF, DATA,   // 188 - 191
    READ, RESTORE, REF, RETI,   // 192 - 195
};

// Symbol table
typedef struct {
    char name[k_MAX_SYM_LEN];
    uint8_t  type;   // Token type
    uint8_t  res;    // Reserved for future use
    uint32_t value;  // Variable index (0..n) or label address
} sym_t;

// Virtual machine
typedef struct {
    uint16_t code_size; // size of the compiled byte code
    uint16_t num_vars;  // number of used variables
    uint16_t pc;        // Programm counter
    uint16_t sp;        // Stack pointer
    uint8_t  psp;       // Parameter stack pointer
    uint8_t  nested_loop_idx;
    int32_t  stack[cfg_STACK_SIZE];
    int32_t  paramstack[cfg_PARAMSTACK_SIZE];
    uint32_t variables[cfg_NUM_VARS];
    uint8_t  code[cfg_MAX_CODE_SIZE];
    uint16_t mem_start_addr;    // Search start address for a free memory block
    uint16_t data_start_addr;   // Data section start address
    uint16_t data_read_offs;    // Data section read offset
    uint8_t  heap[cfg_MEM_HEAP_SIZE];
#ifdef cfg_STRING_SUPPORT    
    char     strbuf1[k_MAX_LINE_LEN]; // temporary buffer for string operations
    char     strbuf2[k_MAX_LINE_LEN]; // temporary buffer for string operations
    bool     strbuf1_used;            // flag to indicate which buffer is used
#endif
} t_VM;

char *nb_scanner(char *p_in, char *p_out);
sym_t *nb_get_symbol_table(uint16_t *p_start_idx);
int32_t nb_get_number(void *pv_vm, uint8_t var);
char *nb_get_string(void *pv_vm, uint8_t var);
int32_t nb_get_arr_elem(void *pv_vm, uint8_t var, uint16_t idx);
void nb_mem_init(t_VM *p_vm);
uint16_t nb_mem_alloc(t_VM *p_vm, uint16_t bytes);
void nb_mem_free(t_VM *p_vm, uint16_t addr);
uint16_t nb_mem_realloc(t_VM *p_vm, uint16_t addr, uint16_t bytes);
uint16_t nb_mem_get_blocksize(t_VM *p_vm, uint16_t addr);
uint16_t nb_mem_get_free(t_VM *p_vm);
