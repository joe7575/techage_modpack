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
#include <stdarg.h>
#include <setjmp.h>
#include "nb.h"
#include "nb_int.h"

#define MAX_XFUNC_PARAMS    8
#define MAX_CODE_PER_LINE   50 // aprox. max. 50 bytes per line

// Expression result types
typedef enum type_t {
    e_NONE = NB_NONE,
    e_NUM = NB_NUM,
    e_STR = NB_STR,
    e_REF = NB_REF,
    e_ANY = NB_ANY,
    e_CNST,
} type_t;

// Define external function
typedef struct {
    uint8_t num_params;
    uint8_t return_type;
    uint8_t type[MAX_XFUNC_PARAMS];
} xfunc_t;

typedef struct {
    uint8_t idx;
    uint16_t pos;
} fwdecl_t;

typedef struct {
    void    *file_ptr;
    fwdecl_t a_forward_decl[cfg_MAX_FW_DECL];
    uint8_t  num_fw_decls;
    uint8_t *p_code;
    uint16_t pc;
    uint16_t linenum;
    uint16_t err_count;
    uint16_t sym_idx;
    char     a_line[k_MAX_LINE_LEN];
    char     a_buff[k_MAX_LINE_LEN];
    uint32_t a_data[cfg_MAX_NUM_DATA];
    uint8_t  data_idx;
    char    *p_pos;
    char    *p_next;
    uint32_t value;
    uint8_t  next_tok;
    bool     trace_on;
    bool     first_data_declaration;
    jmp_buf  jmp_buf;
} comp_inst_t;

static xfunc_t a_XFuncs[cfg_MAX_NUM_XFUNC] = {0};
static uint8_t NumXFuncs = 0;
static sym_t a_Symbol[cfg_MAX_NUM_SYM] = {0};
static uint8_t CurrVarIdx = 0;
static uint16_t StartOfVars = 0;
static comp_inst_t *pCi = NULL;

static bool get_line(void);
static uint8_t next_token(void);
static uint8_t lookahead(void);
static bool end_of_line(void);
static uint8_t next(void);
static void match(uint8_t expected);
#ifndef cfg_LINE_NUMBERS
static void label(void);
#endif
static void compile_line(void);
static void compile_stmts(void);
static void compile_stmt(void);
static void compile_for(void);
static void compile_if(void);
static void compile_goto(void);
static void compile_gosub(void);
static void compile_return(void);
static void compile_var(uint8_t type);
static void compile_dim(void);
static void remark(void);
static void compile_print(void);
static void debug_print(uint16_t lineno);
static void compile_string(void);
static void compile_end(void);
static type_t compile_xfunc(uint8_t type);
static void compile_break(void);
#ifdef cfg_DATA_ACCESS
static void compile_set1(void);
static void compile_set2(void);
static void compile_set4(void);
static void compile_copy(void);
static void compile_set(uint8_t instr);
static void compile_get(uint8_t tok, uint8_t instr);
static void compile_reti(void);
#endif
static void compile_erase(void);
static void compile_on(void);
static uint8_t list_of_numbers(void);
static void compile_data(void);
static void compile_read(void);
static void compile_restore(void);
static void compile_const(void);
static void compile_while(void);
static void compile_tron(void);
static void compile_troff(void);
static void compile_free(void);
static uint16_t sym_add(char *id, uint32_t val, uint8_t type);
static uint16_t sym_get(char *id);
static void error(char *err, char *id);
static uint8_t get_num_vars(void);
static void add_default_params(uint8_t num);
static void forward_declaration(uint16_t idx, uint16_t pos);
static void resolve_forward_declarations(void);
static void append_data_to_code(t_VM *vm);
static type_t compile_expression(type_t type);
static type_t compile_and_expr(void);
static type_t compile_not_expr(void);
static type_t compile_comp_expr(void);
static type_t compile_add_expr(void);
static type_t compile_term(void);
static type_t compile_neg_factor(void);
static type_t compile_factor(void);

/*************************************************************************************************
** API functions
*************************************************************************************************/
void nb_init(void) {
    // Add keywords
    sym_add("let", 0, LET);
    sym_add("dim", 0, DIM);
    sym_add("for", 0, FOR);
    sym_add("to", 0, TO);
    sym_add("step", 0, STEP);
    sym_add("next", 0, NEXT);
    sym_add("if", 0, IF);
    sym_add("then", 0, THEN);
    sym_add("else", 0, ELSE);
    sym_add("end", 0, END);
    sym_add("while", 0, WHILE);
    sym_add("loop", 0, LOOP);
    sym_add("endif", 0, ENDIF);
    sym_add("print", 0, PRINT);
    sym_add("goto", 0, GOTO);
    sym_add("gosub", 0, GOSUB);
    sym_add("return", 0, RETURN);
    sym_add("end", 0, END);
    sym_add("rem", 0, REM);
    sym_add("and", 0, AND);
    sym_add("or", 0, OR);
    sym_add("not", 0, NOT);
    sym_add("mod", 0, MOD);
    sym_add("break", 0, BREAK);
    sym_add("data", 0, DATA);
    sym_add("read", 0, READ);
    sym_add("restore", 0, RESTORE);
#ifdef cfg_DATA_ACCESS
    sym_add("set1", 0, SET1);
    sym_add("set2", 0, SET2);
    sym_add("set4", 0, SET4);
    sym_add("get1", 0, GET1);
    sym_add("get2", 0, GET2);
    sym_add("get4", 0, GET4);
    sym_add("copy", 0, COPY);
    sym_add("ref", 0, REF);
    sym_add("param$", 0, PARAMS);
    sym_add("param", 0, PARAM);
    sym_add("reti", 0, RETI);
#endif
#ifdef cfg_STRING_SUPPORT    
    sym_add("left$", 0, LEFTS);
    sym_add("right$", 0, RIGHTS);
    sym_add("mid$", 0, MIDS);
    sym_add("len", 0, LEN);
    sym_add("val", 0, VAL);
    sym_add("str$", 0, STRS);
    sym_add("spc", 0, SPC);
    sym_add("hex$", 0, HEXS);
    sym_add("nil", 0, NIL);
    sym_add("string$", 0, STRINGS);
#endif
    sym_add("const", 0, CONST);
    sym_add("erase", 0, ERASE);
    sym_add("instr", 0, INSTR);
    sym_add("on", 0, ON);
    sym_add("tron", 0, TRON);
    sym_add("troff", 0, TROFF);
    sym_add("free", 0, FREE);
    sym_add("rnd", 0, RND);
    StartOfVars = CurrVarIdx;
}

uint8_t nb_define_external_function(char *name, uint8_t num_params, uint8_t *types, uint8_t return_type) {
    if(NumXFuncs >= cfg_MAX_NUM_XFUNC) {
        nb_print("Error: too many external functions\n");
        return 0;
    }
    if(num_params > MAX_XFUNC_PARAMS) {
        nb_print("Error: too many parameters\n");
        return 0;
    }
    sym_add(name, NumXFuncs, XFUNC);
    a_XFuncs[NumXFuncs].num_params = num_params;
    a_XFuncs[NumXFuncs].return_type = return_type;
    for(uint8_t i = 0; i < num_params; i++) {
        a_XFuncs[NumXFuncs].type[i] = types[i];
    }
    StartOfVars = CurrVarIdx;
    return NB_XFUNC + NumXFuncs++;
}

void *nb_create(void) {
    t_VM *vm = malloc(sizeof(t_VM));
    if(vm != NULL) {
        memset(vm, 0, sizeof(t_VM));
        nb_mem_init(vm);
        vm->pc = 1;
        //srand(time(NULL));
    }
    return vm;
}

uint16_t nb_compile(void *pv_vm, void *fp) {
    t_VM *vm = pv_vm;
    uint16_t err_count = 0;

    pCi = malloc(sizeof(comp_inst_t));
    if(pCi == NULL) {
        printf("Error: out of memory\n");
        return 1;
    }
    memset(pCi, 0, sizeof(comp_inst_t));
    for(int i = StartOfVars; i < cfg_MAX_NUM_SYM; i++) {
        a_Symbol[i].name[0] = '\0';
        a_Symbol[i].type = 0;
        a_Symbol[i].value = 0;
    }

    pCi->p_code = vm->code;
    CurrVarIdx = 0;
    pCi->pc = 0;
    pCi->file_ptr = fp;
    pCi->linenum = 0;
    pCi->err_count = 0;
    pCi->trace_on = false;
    pCi->first_data_declaration = true;
    pCi->p_code[pCi->pc++] = 0; // The first byte is reserved (invalid label address)

    setjmp(pCi->jmp_buf);
    while(get_line()) {
        compile_line();
    }

    if(pCi->err_count > 0) {
        vm->code_size = 0;
        free(pCi);
        err_count = pCi->err_count;
        pCi = NULL;
        return err_count;
    }

    compile_end();
    append_data_to_code(vm);
    resolve_forward_declarations();

    vm->code_size = pCi->pc;
    vm->num_vars = get_num_vars();
    err_count = pCi->err_count;
    free(pCi);
    pCi = NULL;
    return err_count;
}

void nb_dump_code(void *pv_vm) {
    t_VM *vm = pv_vm;
    for(uint16_t i = 0; i < vm->code_size; i++) {
        printf("%02X ", vm->code[i]);
        if((i % 32) == 31) {
            printf("\n");
        } 
    }
    printf("\n");
}

void nb_output_symbol_table(void *pv_vm) {
    (void)pv_vm;
    uint8_t idx = 0;

    nb_print("#### Symbol table ####\n");
    nb_print("Variables:\n");
    for(uint16_t i = StartOfVars; i < cfg_MAX_NUM_SYM; i++) {
        if(a_Symbol[i].name[0] != '\0' && a_Symbol[i].type != LABEL)
        {
            nb_print("%2u: %-8s  %s\n", idx++, 
                (a_Symbol[i].type == ID) ? "(number)" : (a_Symbol[i].type == SID) ? "(string)" : 
                        (a_Symbol[i].type == e_CNST) ? "(const)": "(array)",
                a_Symbol[i].name);
        }
    }
#ifndef cfg_LINE_NUMBERS    
    nb_print("Labels:\n");
    for(uint16_t i = StartOfVars; i < cfg_MAX_NUM_SYM; i++) {
        if(a_Symbol[i].name[0] != '\0' && a_Symbol[i].type == LABEL)
        {
            nb_print("%16s: %u\n", a_Symbol[i].name, a_Symbol[i].value);
        }
    }
#endif
}

// return 0 if not found
uint16_t nb_get_label_address(void *pv_vm, char *name) {
    (void)pv_vm;
    char str[k_MAX_SYM_LEN];
    // Convert to lower case
    for(uint16_t i = 0; i < k_MAX_SYM_LEN; i++) {
        str[i] = tolower(name[i]);
        if(name[i] == '\0') {
            break;
        }
    }

    for(uint16_t i = StartOfVars; i < cfg_MAX_NUM_SYM; i++) {
        if(a_Symbol[i].name[0] != '\0' && a_Symbol[i].type == LABEL && strcmp(a_Symbol[i].name, str) == 0)
        {
            return a_Symbol[i].value;
        }
    }
    return 0;
}

sym_t *nb_get_symbol_table(uint16_t *p_start_idx) {
    *p_start_idx = StartOfVars;
    return a_Symbol;
}

/*************************************************************************************************
** Static functions
*************************************************************************************************/
static bool get_line(void) {
    if(nb_get_code_line(pCi->file_ptr, pCi->a_line, k_MAX_LINE_LEN) != NULL) {
        if(strlen(pCi->a_line) > (k_MAX_LINE_LEN - 2)) {
            error("line too long", NULL);
        }
        pCi->p_pos = pCi->p_next = pCi->a_line;

#ifndef cfg_LINE_NUMBERS        
        pCi->linenum++;
#else
        uint8_t tok = lookahead();
        if(tok == NUM) {
            match(NUM);
            if(pCi->value > 0 && pCi->value < 65536) {
                if(pCi->value > pCi->linenum) {
                    pCi->linenum = pCi->value;
                    pCi->sym_idx = sym_add(pCi->a_buff, pCi->pc, LABEL);
                } else {
                    error("line number out of order", NULL);
                }
            } else {
                error("line number out of range", NULL);
            }
        }
#endif
        return true;
    }
    return false;
}

static uint8_t next_token(void) {
    if(pCi->p_pos == NULL || *pCi->p_pos == '\0') {
        return 0; // End of line
    }
    pCi->p_next = nb_scanner(pCi->p_pos, pCi->a_buff);
    if(pCi->a_buff[0] == '\0') {
       return 0; // End of line
    }
    if(pCi->a_buff[0] == '\"') {
        return STR;
    }
    if(isdigit((int8_t)pCi->a_buff[0])) {
        pCi->value = atoi(pCi->a_buff);
       return NUM;
    }
    if(isalpha((int8_t)pCi->a_buff[0]) || pCi->a_buff[0] == '_') {
        uint16_t len = strlen(pCi->a_buff);
        uint8_t type = pCi->a_buff[len - 1] == '$' ? SID : ID;

        pCi->sym_idx = sym_add(pCi->a_buff, CurrVarIdx, type);
        return a_Symbol[pCi->sym_idx].type;
    }
    if(pCi->a_buff[0] == '=') {
        return EQ;
    }
    if(pCi->a_buff[0] == '<') {
        // parse '<=', '<>', and '<'
        if (pCi->a_buff[1] == '=') {
            return LQ;
        }
        if (pCi->a_buff[1] == '>') {
            return NQ;
        }
        return LE;
    }
    if(pCi->a_buff[0] == '>') {
        // parse '>=' or '>'
        if (pCi->a_buff[0] == '=') {
            return GQ;
        }
        return GR;
    }
    if(strlen(pCi->a_buff) == 1) {
        return pCi->a_buff[0]; // Single character
    }
    error("unknown character", pCi->a_buff);
    return 0;
}

static uint8_t lookahead(void) {
    if(pCi->p_pos == pCi->p_next) {
       pCi->next_tok = next_token();
    }
    //nb_print("lookahead: %s\n", pCi->a_buff);
    return pCi->next_tok;
}

#ifndef cfg_LINE_NUMBERS
static uint8_t lookfurther(void) {
    return pCi->p_next[0];
}
#endif

static bool end_of_line(void) {
    return lookahead() == 0;
}

static uint8_t next(void) {
    if(pCi->p_pos == pCi->p_next) {
       pCi->next_tok = next_token();
    }
    pCi->p_pos = pCi->p_next;
    return pCi->next_tok;
}

static void match(uint8_t expected) {
    uint8_t tok = next();
    if (tok == expected) {
    } else {
        error("syntax error", pCi->a_buff);
    }
}

#ifndef cfg_LINE_NUMBERS
static void label(void) {
  uint8_t tok = lookahead();
  if(tok == ID) { // Token recognized as variable?
    // Convert to label
    a_Symbol[pCi->sym_idx].type = LABEL;
    pCi->next_tok = LABEL;
    CurrVarIdx--;
  } else if(tok == LABEL) {
    // Already a label
  } else {
    error("label expected", pCi->a_buff);
  }
  match(LABEL);
}
#endif

static void compile_line(void) {
#ifndef cfg_LINE_NUMBERS    
    uint8_t tok = lookahead();
    if(tok == ID || tok == LABEL) {
        uint16_t idx = pCi->sym_idx;
        if(lookfurther() == ':') {
            label();
            match(':');
            a_Symbol[idx].value = pCi->pc;
        }
    }
#endif
    if(pCi->trace_on) {
        debug_print(pCi->linenum);
    }
    compile_stmts();
}

static void compile_stmts(void) {
    uint8_t tok = lookahead();
    while(tok && tok != ELSE) {
        compile_stmt();
        tok = lookahead();
        if(tok == ':') {
            match(':');
            tok = lookahead();
        }
        if(pCi->pc >= cfg_MAX_CODE_SIZE - MAX_CODE_PER_LINE) {
            error("code size exceeded", NULL);
            break;
        }
    }
}

static void compile_stmt(void) {
    uint8_t tok = next();
    if(pCi->first_data_declaration == false && tok != DATA) {
        error("data statement expected", NULL);
    }
    switch(tok) {
    case FOR: compile_for(); break;
    case IF: compile_if(); break;
    case LET: tok = next(); compile_var(tok); break;
    case ID: compile_var(tok); break;
    case SID: compile_var(tok); break;
    case ARR: compile_var(tok); break;
    case DIM: compile_dim(); break;
    case REM: remark(); break;
    case GOTO: compile_goto(); break;
    case GOSUB: compile_gosub(); break;
    case RETURN: compile_return(); break;
    case PRINT: compile_print(); break;
    case READ: compile_read(); break;
    case DATA: compile_data(); break;
    case RESTORE: compile_restore(); break;
    case CONST: compile_const(); break;
    case WHILE: compile_while(); break;
    case END: compile_end(); break;
    case XFUNC: compile_xfunc(e_NONE); break;
    case BREAK: compile_break(); break;
#ifdef cfg_DATA_ACCESS    
    case SET1: compile_set1(); break;
    case SET2: compile_set2(); break;
    case SET4: compile_set4(); break;
    case COPY: compile_copy(); break;
    case RETI: compile_reti(); break;
#endif
    case ERASE: compile_erase(); break;
    case ON: compile_on(); break;
    case TRON: compile_tron(); break;
    case TROFF: compile_troff(); break;
    case FREE: compile_free(); break;
    case ':': break;
    default: error("syntax error", pCi->a_buff); break;
    }
}

/* FOR ID '=' <Expression1> TO <Expression2> [STEP <Expression3>]
**   <Statement>...
** NEXT [ID]
**
** <Expression2>  and <Expression3> are pushed on the data stack
*/
static void compile_for(void) {
    uint16_t pc;
    uint8_t tok;
    uint16_t idx;

    pCi->p_code[pCi->pc++] = k_FOR_N1;
    // FOR ID
    match(ID);
    idx = pCi->sym_idx;
    match(EQ);
    compile_expression(e_NUM);
    pCi->p_code[pCi->pc++] = k_POP_VAR_N2;
    pCi->p_code[pCi->pc++] = a_Symbol[idx].value;
    match(TO);
    compile_expression(e_NUM);
    tok = lookahead();
    if(tok == STEP) {
        match(STEP);
        compile_expression(e_NUM);
    } else {
        pCi->p_code[pCi->pc++] = k_PUSH_NUM_N2;
        pCi->p_code[pCi->pc++] = 1;
    }

    pc = pCi->pc;
    while(get_line()) {
        tok = lookahead();
        if(tok == NEXT) {
            break;
        }
        compile_line();
    }

    // NEXT [ID]
    match(NEXT);
    tok = lookahead();
    if(tok == ID) {
        match(ID);
        if(idx != pCi->sym_idx) {
            error("mismatched 'for' and 'next'", NULL);
        }
    }
    pCi->p_code[pCi->pc++] = k_NEXT_N4;
    pCi->p_code[pCi->pc++] = pc & 0xFF;
    pCi->p_code[pCi->pc++] = (pc >> 8) & 0xFF;
    pCi->p_code[pCi->pc++] = a_Symbol[idx].value;
}

/*
** WHILE <Expression>
**    <Statement>...
** LOOP
*/
static void compile_while(void) {
    uint16_t pos1, pos2;
    uint8_t tok;

    pos1 = pCi->pc; // start of loop
    compile_expression(e_NUM);
    pCi->p_code[pCi->pc++] = k_IF_N3;
    pos2 = pCi->pc; // end of loop
    pCi->pc += 2;
    while(get_line()) {
        tok = lookahead();
        if(tok == LOOP) {
            break;
        }
        compile_line();
    }
    match(LOOP);
    pCi->p_code[pCi->pc++] = k_GOTO_N3;
    pCi->p_code[pCi->pc++] = pos1 & 0xFF;
    pCi->p_code[pCi->pc++] = (pos1 >> 8) & 0xFF;
    ACS16(pCi->p_code[pos2]) = pCi->pc;
}

/*
** IF <Expression> THEN
**    <Statement>...
** [ELSE
**    <Statement>...]
** ENDIF
*/
static void compile_if_V2(uint16_t pos1) {
    uint8_t tok = 0;
    uint16_t pos2; // endif

    while(get_line()) {
        tok = lookahead();
        if(tok == ELSE || tok == ENDIF) {
            break;
        }
        compile_line();
    }

    if(tok == ELSE) {
        pCi->p_code[pCi->pc++] = k_GOTO_N3;
        pos2 = pCi->pc; // end of else
        pCi->pc += 2;
        ACS16(pCi->p_code[pos1]) = pCi->pc;

        while(get_line()) {
            tok = lookahead();
            if(tok == ENDIF) {
                break;
            }
            compile_line();
        }

        ACS16(pCi->p_code[pos2]) = pCi->pc;
    } else {
        ACS16(pCi->p_code[pos1]) = pCi->pc;
    }
    match(ENDIF);
}

static void compile_if(void) {
    uint8_t tok;

    compile_expression(e_NUM);
    pCi->p_code[pCi->pc++] = k_IF_N3;
    uint16_t pos = pCi->pc; // end of if
    pCi->pc += 2;
    tok = lookahead();
    if(tok == THEN) {
        match(THEN);
        if(end_of_line()) {
            compile_if_V2(pos);
            return;
        }
        compile_stmts();
        ACS16(pCi->p_code[pos]) = pCi->pc;
    } else if(tok == GOTO) {
        match(GOTO);
        compile_goto();
        ACS16(pCi->p_code[pos]) = pCi->pc;
    } else {
        error("THEN or GOTO expected", pCi->a_buff);
    }
    tok = lookahead();
    if(tok == ELSE) {
        match(ELSE);
        pCi->p_code[pCi->pc++] = k_GOTO_N3; // goto END
        ACS16(pCi->p_code[pos]) = pCi->pc + 2;
        pos = pCi->pc; // end of else
        pCi->pc += 2;
        compile_stmts();
        ACS16(pCi->p_code[pos]) = pCi->pc;
    }
}

static void compile_goto(void) {
    uint16_t addr;
#ifdef cfg_LINE_NUMBERS
    match(NUM);
    pCi->sym_idx = sym_add(pCi->a_buff, 0, LABEL);
    addr = 0;
#else
    label();
    addr = a_Symbol[pCi->sym_idx].value;
#endif
    forward_declaration(pCi->sym_idx, pCi->pc + 1);
    pCi->p_code[pCi->pc++] = k_GOTO_N3;
    pCi->p_code[pCi->pc++] = addr & 0xFF;
    pCi->p_code[pCi->pc++] = (addr >> 8) & 0xFF;
}

static void compile_gosub(void) {
    uint16_t addr;
#ifdef cfg_LINE_NUMBERS
    match(NUM);
    pCi->sym_idx = sym_add(pCi->a_buff, 0, LABEL);
    addr = 0;
#else
    label();
    addr = a_Symbol[pCi->sym_idx].value;
#endif
    forward_declaration(pCi->sym_idx, pCi->pc + 1);
    pCi->p_code[pCi->pc++] = k_GOSUB_N3;
    pCi->p_code[pCi->pc++] = addr & 0xFF;
    pCi->p_code[pCi->pc++] = (addr >> 8) & 0xFF;
}

static void compile_return(void) {
    pCi->p_code[pCi->pc++] = k_RETURN_N1;
}

static void compile_var(uint8_t tok) {
    uint16_t idx = pCi->sym_idx;
    type_t type;

    if(tok == SID) { // let a$ = "string"
        match(EQ);
        compile_expression(e_STR);
        // Var[value] = pop()
        pCi->p_code[pCi->pc++] = k_POP_STR_N2;
        pCi->p_code[pCi->pc++] = a_Symbol[idx].value;
    } else if(tok == ID) { // let a = expression
        match(EQ);
        type = compile_expression(e_NUM);
        if(type == e_NUM) {
            // Var[value] = pop()
            pCi->p_code[pCi->pc++] = k_POP_VAR_N2;
            pCi->p_code[pCi->pc++] = a_Symbol[idx].value;
        } else if(type == e_STR) {
            // Var[value] = pop()
            pCi->p_code[pCi->pc++] = k_POP_STR_N2;
            pCi->p_code[pCi->pc++] = a_Symbol[idx].value;
        } else {
            error("type mismatch", pCi->a_buff);
        }
    } else if(tok == ARR) { // let rx(0) = 1
        match('(');
        compile_expression(e_NUM);
        match(')');
        match(EQ);
        compile_expression(e_NUM);
        pCi->p_code[pCi->pc++] = k_SET_ARR_ELEM_N2;
        pCi->p_code[pCi->pc++] = a_Symbol[idx].value;
    } else {
        error("unknown variable type", pCi->a_buff);
    }
}

static void compile_dim(void) {
    uint8_t tok = next();
    if(tok == ID || tok == ARR) {
        uint16_t idx = pCi->sym_idx;
        a_Symbol[idx].type = ARR;
        match('(');
        compile_expression(e_NUM);        
        match(')');
        pCi->p_code[pCi->pc++] = k_DIM_ARR_N2;
        pCi->p_code[pCi->pc++] = a_Symbol[idx].value;
    } else {
        error("unknown variable type", pCi->a_buff);
    }
}

static void remark(void) {
    // Skip to end of line
    pCi->p_pos[0] = '\0';
}

static void compile_print(void) {
    type_t type;
    bool add_newline = true;
    uint8_t tok = lookahead();
    if(tok == 0) {
        pCi->p_code[pCi->pc++] = k_PRINT_NEWL_N1;
        return;
    }
    while(tok && tok != ELSE && tok != ':') {
        add_newline = true;
        if(tok == STR) {
            compile_string();
            pCi->p_code[pCi->pc++] = k_PRINT_STR_N1;
        } else if(tok == SID) {
            pCi->p_code[pCi->pc++] = k_PUSH_VAR_N2;
            pCi->p_code[pCi->pc++] = a_Symbol[pCi->sym_idx].value;
            pCi->p_code[pCi->pc++] = k_PRINT_STR_N1;
            match(SID);
        } else if(tok == SPC) { // spc function
            match(SPC);
            match('(');
            compile_expression(e_NUM);
            match(')');
            pCi->p_code[pCi->pc++] = k_PRINT_BLANKS_N1;
        } else {
            type = compile_expression(e_ANY);
            if(type == e_NUM) {
                pCi->p_code[pCi->pc++] = k_PRINT_VAL_N1;
            } else if(type == e_STR) {
                pCi->p_code[pCi->pc++] = k_PRINT_STR_N1;
            } else {
                error("type mismatch", pCi->a_buff);
            }
        }
        tok = lookahead();
        if(tok == ',') {
            match(',');
            pCi->p_code[pCi->pc++] = k_PRINT_TAB_N1;
            add_newline = false;
            tok = lookahead();
        } else if(tok == ';') {
            match(';');
            tok = lookahead();
            add_newline = false;
        } else if(tok && tok != ELSE) {
            pCi->p_code[pCi->pc++] = k_PRINT_SPACE_N1;
        }
    }
    if(add_newline) {
        pCi->p_code[pCi->pc++] = k_PRINT_NEWL_N1;
    }
}

static void debug_print(uint16_t lineno) {
    pCi->p_code[pCi->pc++] = k_PRINT_LINENO_N3;
    pCi->p_code[pCi->pc++] = lineno & 0xFF;
    pCi->p_code[pCi->pc++] = (lineno >> 8) & 0xFF;
}

static void compile_string(void) {
    match(STR);
    // push string address
    uint16_t len = strlen(pCi->a_buff);
    pCi->a_buff[len - 1] = '\0';
    pCi->p_code[pCi->pc++] = k_PUSH_STR_Nx;
    pCi->p_code[pCi->pc++] = len - 1; // without quotes but with 0
    strcpy((char*)&pCi->p_code[pCi->pc], pCi->a_buff + 1);
    pCi->pc += len - 1;
}

static void compile_data(void) {
    uint8_t tok;
    if(pCi->first_data_declaration) {
        pCi->first_data_declaration = false;
    }
    
    while(1) {
        tok = next();
        if(tok == NUM) {
            pCi->a_data[pCi->data_idx++] = pCi->value & ~k_DATA_STR_TAG;
        } else if(tok == STR) {
            // without quotes but with 0
            uint16_t len = strlen(pCi->a_buff) - 1;
            pCi->a_buff[len] = '\0';
            if(pCi->pc + len >= cfg_MAX_CODE_SIZE) {
                error("code size exceeded", NULL);
            }
            memcpy(&pCi->p_code[pCi->pc], pCi->a_buff + 1, len);
            pCi->a_data[pCi->data_idx++] = pCi->pc | k_DATA_STR_TAG;
            pCi->pc += len;
        } else {
            error("syntax error", pCi->a_buff);
        }
        tok = lookahead();
        if(tok == ',') {
            match(',');
        } else {
            break;
        }
    }
}

static void compile_read(void) {
    uint8_t tok;
    uint16_t idx;

    while(1) {
        tok = lookahead();
        if(tok == ID) {
            match(ID);
            idx = pCi->sym_idx;
            pCi->p_code[pCi->pc++] = k_READ_NUM_N1;
            pCi->p_code[pCi->pc++] = k_POP_VAR_N2;
            pCi->p_code[pCi->pc++] = a_Symbol[idx].value;
        } else if(tok == SID) {
            match(SID);
            idx = pCi->sym_idx;
            pCi->p_code[pCi->pc++] = k_READ_STR_N1;
            pCi->p_code[pCi->pc++] = k_POP_STR_N2;
            pCi->p_code[pCi->pc++] = a_Symbol[idx].value;
        }
        tok = lookahead();
        if(tok == ',') {
            match(',');
        } else {
            break;
        }
    }
}

static void compile_restore(void) {
    uint8_t tok = lookahead();
    if(tok == NUM) {
        compile_expression(e_NUM);
    } else {
        pCi->p_code[pCi->pc++] = k_PUSH_NUM_N2;
        pCi->p_code[pCi->pc++] = 0;
    }
    pCi->p_code[pCi->pc++] = k_RESTORE_N1;
}

static void compile_end(void) {
    pCi->p_code[pCi->pc++] = k_END;
}

static type_t compile_xfunc(uint8_t type) {
    uint8_t idx = sym_get(pCi->a_buff);
    uint8_t tok;
    if(idx >= NumXFuncs) {
        error("unknown external function", pCi->a_buff);
    }
    if(type != e_ANY && type != a_XFuncs[idx].return_type) {
        error("syntax error", pCi->a_buff);
    }
    match('(');
    for(uint8_t i = 0; i < a_XFuncs[idx].num_params; i++) {
        compile_expression(a_XFuncs[idx].type[i]);
        pCi->p_code[pCi->pc++] = k_PUSH_PARAM_N1;
        tok = lookahead();
        if(tok == ',') {
            match(',');
        } else if(tok == ')') {
            add_default_params(a_XFuncs[idx].num_params - i - 1);
            break;
        } else {
            error("syntax error", pCi->a_buff);
        }
    }
    pCi->p_code[pCi->pc++] = k_XFUNC_N2;
    pCi->p_code[pCi->pc++] = idx;
    match(')');
    return a_XFuncs[idx].return_type;
}

static void compile_break(void) {
    pCi->p_code[pCi->pc++] = k_BREAK_INSTR_N3;
    ACS16(pCi->p_code[pCi->pc]) = pCi->linenum;
    pCi->pc += 2;
}

#ifdef cfg_DATA_ACCESS
static void compile_set1(void) {
    compile_set(k_SET_ARR_1BYTE_N2);
}

static void compile_set2(void) {
    compile_set(k_SET_ARR_2BYTE_N2);
}

static void compile_set4(void) {
    compile_set(k_SET_ARR_4BYTE_N2);
}

// copy(arr, offs, arr, offs, bytes)
static void compile_copy(void) {
    match('(');
    compile_expression(e_REF);
    match(',');
    compile_expression(e_NUM);
    match(',');
    compile_expression(e_REF);
    match(',');
    compile_expression(e_NUM);
    match(',');
    compile_expression(e_NUM);
    match(')');
    pCi->p_code[pCi->pc++] = k_COPY_N1;
}

static void compile_set(uint8_t instr) {
    uint8_t idx;
    match('(');
    match(ARR);
    idx = pCi->sym_idx;
    match(',');
    compile_expression(e_NUM);
    match(',');
    compile_expression(e_NUM);
    match(')');
    pCi->p_code[pCi->pc++] = instr;
    pCi->p_code[pCi->pc++] = a_Symbol[idx].value;
}

static void compile_get(uint8_t tok, uint8_t instr) {
    uint8_t idx;
    match(tok);
    match('(');
    match(ARR);
    idx = pCi->sym_idx;
    match(',');
    compile_expression(e_NUM);
    match(')');
    pCi->p_code[pCi->pc++] = instr;
    pCi->p_code[pCi->pc++] = a_Symbol[idx].value;
}

static void compile_reti(void) {
    pCi->p_code[pCi->pc++] = k_RETI_N1;
}   
#endif

static void compile_const(void) {
    uint32_t factor = 1;
    next();
    uint16_t idx = pCi->sym_idx;
    match(EQ);
    uint8_t tok = lookahead();
    if(tok == '-') {
        match('-');
        factor = -1;
    }
    match(NUM);
    a_Symbol[idx].type = e_CNST;
    a_Symbol[idx].value = pCi->value * factor;
}

static void compile_erase(void) {
    uint8_t tok = next();
    if(tok == SID || tok == ARR) {
        pCi->p_code[pCi->pc++] = k_ERASE_ARR_N2;
        pCi->p_code[pCi->pc++] = a_Symbol[pCi->sym_idx].value;
    } else {
        error("unknown variable type", pCi->a_buff);
    }
}

static void compile_on(void) {
    uint16_t pos;
    uint8_t num;

    compile_expression(e_NUM);
    uint8_t tok = lookahead();
    if(tok == GOSUB) {
        match(GOSUB);
        pCi->p_code[pCi->pc++] = k_ON_GOSUB_N2;
    } else if(tok == GOTO) {
        match(GOTO);
        pCi->p_code[pCi->pc++] = k_ON_GOTO_N2;
    } else {
        error("GOSUB or GOTO expected", pCi->a_buff);
    }
    pos = pCi->pc;
    pCi->p_code[pCi->pc++] = 0; // number of elements
    num = list_of_numbers();
    pCi->p_code[pos] = num;
}

static uint8_t list_of_numbers(void) {
    uint8_t num = 0;

    while(1) {
        compile_goto(); 
        num++;
        uint8_t tok = lookahead();
        if(tok == ',') {
            match(',');
        } else {
            break;
        }
    }
    return num;
}

static void compile_tron(void) {
    pCi->trace_on = true;
}

static void compile_troff(void) {
    pCi->trace_on = false;
}

static void compile_free(void) {
    pCi->p_code[pCi->pc++] = k_FREE_N1;
}

/**************************************************************************************************
 * Symbol table and other helper functions
 *************************************************************************************************/

/*
** Add symbol to symbol table
** id = symbol name
** val = value (in case of variable the index to vm->variables)
** type = type of symbol (ID, SID, ARR, LABEL)
*/
static uint16_t sym_add(char *id, uint32_t val, uint8_t type) {
    uint16_t start = 0;
    char sym[k_MAX_SYM_LEN];

    // Convert to lower case
    for(uint16_t i = 0; i < k_MAX_SYM_LEN; i++) {
        sym[i] = tolower(id[i]);
        if(sym[i] == '\0') {
            break;
        }
    }
    sym[k_MAX_SYM_LEN - 1] = '\0';

    // Search for existing symbol
    for(uint16_t i = 0; i < cfg_MAX_NUM_SYM; i++) {
        if(strcmp(a_Symbol[i].name, sym) == 0) {
            if(a_Symbol[i].value == 0 && a_Symbol[i].type == LABEL && val > 0) {
                a_Symbol[i].value = val;
            }
            return i;
        }
        if(a_Symbol[i].name[0] == '\0') {
            start = i;
            break;
        }
    }

    // Add new symbol
    for(uint16_t i = start; i < cfg_MAX_NUM_SYM; i++) {
        if(a_Symbol[i].name[0] == '\0') {
            strcpy(a_Symbol[i].name, sym);
            a_Symbol[i].value = val;
            a_Symbol[i].type = type;
            if(type != LABEL) {
                CurrVarIdx++;
            }
            return i;
        }
    }
    error("symbol table full", NULL);
    return 0;
}

static uint16_t sym_get(char *id) {
    char sym[k_MAX_SYM_LEN];

    // Convert to lower case
    for(uint16_t i = 0; i < k_MAX_SYM_LEN; i++) {
        sym[i] = tolower(id[i]);
        if(sym[i] == '\0') {
            break;
        }
    }
    sym[k_MAX_SYM_LEN - 1] = '\0';

    // Search for existing symbol
    for(uint16_t i = 0; i < cfg_MAX_NUM_SYM; i++) {
        if(strcmp(a_Symbol[i].name, sym) == 0) {
            return a_Symbol[i].value;
        }
        if(a_Symbol[i].name[0] == '\0') {
            break;
        }
    }
    error("unknown symbol", id);
    return 0;
}

static void error(char *err, char *id) {
    nb_print("Error in line %u: ", pCi->linenum);
    if(id != NULL && id[0] != '\0') {
        nb_print("%s '%s'\n", err, id);
    } else {
        nb_print("%s\n", err);
    }
    pCi->err_count++;
    pCi->p_pos = pCi->p_next;
    if(pCi->p_pos != NULL) {
        pCi->p_pos[0] = '\0';
    }
    longjmp(pCi->jmp_buf, 0);
}

static uint8_t get_num_vars(void) {
    uint8_t idx = 0;

    for(uint16_t i = StartOfVars; i < cfg_MAX_NUM_SYM; i++) {
        if(a_Symbol[i].name[0] != '\0' && a_Symbol[i].type != LABEL)
        {
            idx++;
        }
    }
    return idx;
}

static void add_default_params(uint8_t num) {
    for(uint8_t i = 0; i < num; i++) {
        pCi->p_code[pCi->pc++] = k_PUSH_NUM_N2;
        pCi->p_code[pCi->pc++] = 0;
        pCi->p_code[pCi->pc++] = k_PUSH_PARAM_N1;
    }
}

// idx = index of symbol (SmyIdx)
// pos = position in code array
static void forward_declaration(uint16_t idx, uint16_t pos) {
    if(pCi->num_fw_decls < cfg_MAX_FW_DECL) {
        pCi->a_forward_decl[pCi->num_fw_decls].idx = idx;
        pCi->a_forward_decl[pCi->num_fw_decls].pos = pos;
        pCi->num_fw_decls++;
    } else {
        error("too many forward declarations", NULL);
    }
}

static void resolve_forward_declarations(void) {
    uint16_t idx, pos, addr;
    for(uint8_t i = 0; i < pCi->num_fw_decls; i++) {
        idx = pCi->a_forward_decl[i].idx;
        pos = pCi->a_forward_decl[i].pos;
        if(a_Symbol[idx].type == LABEL) {
            addr = a_Symbol[idx].value;
            if(addr > 0) {
                pCi->p_code[pos + 0] = addr & 0xFF;
                pCi->p_code[pos + 1] = (addr >> 8) & 0xFF;
            } else {
#ifdef cfg_LINE_NUMBERS
                error("Line number not found", a_Symbol[idx].name);
#else
                error("Label not found", a_Symbol[idx].name);
#endif
            }
        } else {

            error("forward declaration not resolved", a_Symbol[idx].name);
        }
    }
    pCi->num_fw_decls = 0;
}

static void append_data_to_code(t_VM *vm) {
    pCi->p_code[pCi->pc++] = 0xFF;  // End tag before the data section starts
    vm->data_start_addr = pCi->pc;
    vm->data_read_offs = 0;
    
    if((pCi->pc + pCi->data_idx * 4) >= cfg_MAX_CODE_SIZE) {
        error("code size exceeded", NULL);
    }
    for(int i = 0; i < pCi->data_idx; i++) {
        ACS32(pCi->p_code[pCi->pc]) = pCi->a_data[i];
        pCi->pc += 4;
    }
}

/**************************************************************************************************
 * Expression compiler
 *************************************************************************************************/
static type_t compile_expression(type_t type) {
    type_t type1 = compile_and_expr();
    uint8_t op = lookahead();
    while(op == OR) {
        match(op);
        type_t type2 = compile_and_expr();
        if(type1 != e_NUM || type2 != e_NUM) {
            error("type mismatch", NULL);
        }
        pCi->p_code[pCi->pc++] = k_OR_N1;
        op = lookahead();
    }
    if(type != e_ANY && type1 != type) {
        error("type mismatch", pCi->a_buff);
    }
    return type1;
}

static type_t compile_and_expr(void) {
    type_t type1 = compile_not_expr();
    uint8_t op = lookahead();
    while(op == AND) {
        match(op);
        type_t type2 = compile_not_expr();
        if(type1 != e_NUM || type2 != e_NUM) {
            error("type mismatch", pCi->a_buff);
        }
        pCi->p_code[pCi->pc++] = k_AND_N1;
        op = lookahead();
    }
    return type1;
}

static type_t compile_not_expr(void) {
    type_t type;
    uint8_t op = lookahead();
    if(op == NOT) {
        match(op);
        type = compile_comp_expr();
        if(type != e_NUM) {
            error("type mismatch", pCi->a_buff);
        }
          pCi->p_code[pCi->pc++] = k_NOT_N1;
    } else {
        type = compile_comp_expr();
    }
    return type;
}

static type_t compile_comp_expr(void) {
    type_t type1 = compile_add_expr();
    uint8_t op = lookahead();
    while(op == EQ || op == NQ || op == LE || op == LQ || op == GR || op == GQ) {
        match(op);
        type_t type2 = compile_add_expr();
        if(type1 != type2) {
            error("type mismatch", pCi->a_buff);
        }
#ifdef cfg_STRING_SUPPORT        
        if(type1 == e_STR) {
            switch(op) {
            case EQ: pCi->p_code[pCi->pc++] = k_STR_EQUAL_N1; break;
            case NQ: pCi->p_code[pCi->pc++] = k_STR_NOT_EQU_N1; break;
            case LE: pCi->p_code[pCi->pc++] = k_STR_LESS_N1; break;
            case LQ: pCi->p_code[pCi->pc++] = k_STR_LESS_EQU_N1; break;
            case GR: pCi->p_code[pCi->pc++] = k_STR_GREATER_N1; break;
            case GQ: pCi->p_code[pCi->pc++] = k_STR_GREATER_EQU_N1; break;
            default: error("unknown operator", pCi->a_buff); break;
            }
        } else {
#else
        { 
#endif
            switch(op) {
            case EQ: pCi->p_code[pCi->pc++] = k_EQUAL_N1; break;
            case NQ: pCi->p_code[pCi->pc++] = k_NOT_EQUAL_N1; break;
            case LE: pCi->p_code[pCi->pc++] = k_LESS_N1; break;
            case LQ: pCi->p_code[pCi->pc++] = k_LESS_EQU_N1; break;
            case GR: pCi->p_code[pCi->pc++] = k_GREATER_N1; break;
            case GQ: pCi->p_code[pCi->pc++] = k_GREATER_EQU_N1; break;
            default: error("unknown operator", pCi->a_buff); break;
            }
        }
        op = lookahead();
    }
    return type1;
}

static type_t compile_add_expr(void) {
    type_t type1 = compile_term();
    uint8_t op = lookahead();
    while(op == '+' || op == '-') {
        match(op);
        type_t type2 = compile_term();
        if(type1 != type2) {
            error("type mismatch", pCi->a_buff);
        }
        if(op == '+') {
            if(type1 == e_NUM) {
              pCi->p_code[pCi->pc++] = k_ADD_N1;
            } else {
#ifdef cfg_STRING_SUPPORT                
                pCi->p_code[pCi->pc++] = k_ADD_STR_N1;
#else
                error("type mismatch", pCi->a_buff);
#endif
            }
        } else {
            if(type1 == e_NUM) {
              pCi->p_code[pCi->pc++] = k_SUB_N1;
            } else {
              error("type mismatch", pCi->a_buff);
            }
        }
        op = lookahead();
    }
    return type1;
}

static type_t compile_term(void) {
    type_t type1 = compile_neg_factor();
    uint8_t op = lookahead();
    while(op == '*' || op == '/' || op == MOD) {
        match(op);
        type_t type2 = compile_neg_factor();
        if(type1 != e_NUM || type2 != e_NUM) {
            error("type mismatch", pCi->a_buff);
        }
        if(op == '*') {
          pCi->p_code[pCi->pc++] = k_MUL_N1;
        } else if(op == MOD) {
          pCi->p_code[pCi->pc++] = k_MOD_N1;
        } else {
          pCi->p_code[pCi->pc++] = k_DIV_N1;
        }
        op = lookahead();
    }
    return type1;
}

static type_t compile_neg_factor(void) {
    type_t type = 0;
    uint8_t tok = lookahead();
    if(tok == '-') {
        match('-');
        type = compile_factor();
        pCi->p_code[pCi->pc++] = k_NEG_N1;
    } else {
        type = compile_factor();
    }
    return type;
}

static type_t compile_factor(void) {
    type_t type = 0;
    uint8_t val;
    uint8_t tok = lookahead();
    switch(tok) {
    case '(':
        match('(');
        type = compile_expression(e_NUM);
        match(')');
        break;
    case e_CNST:
        pCi->value = a_Symbol[pCi->sym_idx].value;
        match(e_CNST);
        if(pCi->value < 256)
        {
          pCi->p_code[pCi->pc++] = k_PUSH_NUM_N2;
          pCi->p_code[pCi->pc++] = pCi->value;
        }
        else
        {
          pCi->p_code[pCi->pc++] = k_PUSH_NUM_N5;
          pCi->p_code[pCi->pc++] = pCi->value & 0xFF;
          pCi->p_code[pCi->pc++] = (pCi->value >> 8) & 0xFF;
          pCi->p_code[pCi->pc++] = (pCi->value >> 16) & 0xFF;
          pCi->p_code[pCi->pc++] = (pCi->value >> 24) & 0xFF;
        }
        type = e_NUM;
        break;
    case NUM: // number, like 1234
        match(NUM);
        if(pCi->value < 256)
        {
          pCi->p_code[pCi->pc++] = k_PUSH_NUM_N2;
          pCi->p_code[pCi->pc++] = pCi->value;
        }
        else
        {
          pCi->p_code[pCi->pc++] = k_PUSH_NUM_N5;
          pCi->p_code[pCi->pc++] = pCi->value & 0xFF;
          pCi->p_code[pCi->pc++] = (pCi->value >> 8) & 0xFF;
          pCi->p_code[pCi->pc++] = (pCi->value >> 16) & 0xFF;
          pCi->p_code[pCi->pc++] = (pCi->value >> 24) & 0xFF;
        }
        type = e_NUM;
        break;
    case ID: // variable, like var1
        match(ID);
        pCi->p_code[pCi->pc++] = k_PUSH_VAR_N2;
        pCi->p_code[pCi->pc++] = a_Symbol[pCi->sym_idx].value;
        type = e_NUM;
        break;
    case ARR: // like A(0)
        val = a_Symbol[pCi->sym_idx].value;
        match(ARR);
        tok = lookahead();
        match('(');
        compile_expression(e_NUM);
        match(')');
        pCi->p_code[pCi->pc++] = k_GET_ARR_ELEM_N2;
        pCi->p_code[pCi->pc++] = val;
        type = e_NUM;
        break;
#ifdef cfg_DATA_ACCESS        
    case GET1: // get1 function
        compile_get(GET1, k_GET_ARR_1BYTE_N2);
        type = e_NUM;
        break;
    case GET2: // get2 function
        compile_get(GET2, k_GET_ARR_2BYTE_N2);
        type = e_NUM;
        break;
    case GET4: // get4 function
        compile_get(GET4, k_GET_ARR_4BYTE_N2);
        type = e_NUM;
        break;
    case REF: // ref(arr/str) function
        match(REF);
        match('(');
        tok = lookahead();
        if(tok == ARR || tok == SID) {
            match(tok);
        } else {
            error("syntax error", pCi->a_buff);
        }
        match(')');
        pCi->p_code[pCi->pc++] = k_PUSH_VAR_N2;
        pCi->p_code[pCi->pc++] = a_Symbol[pCi->sym_idx].value;
        type = e_REF;
        break;
#endif
    case PARAMS: // Move value from (external) parameter stack to the data stack
        match(PARAMS);
        match('(');
        match(')');
        pCi->p_code[pCi->pc++] = k_PARAMS_N1;
        type = e_STR;
        break;
    case PARAM: // Move value from (external) parameter stack to the data stack
        match(PARAM);
        match('(');
        match(')');
        pCi->p_code[pCi->pc++] = k_PARAM_N1;
        type = e_NUM;
        break;
    case STR: // string, like "Hello"
        match(STR);
        // push string address
        uint16_t len = strlen(pCi->a_buff);
        pCi->a_buff[len - 1] = '\0';
        pCi->p_code[pCi->pc++] = k_PUSH_STR_Nx;
        pCi->p_code[pCi->pc++] = len - 1; // without quotes but with 0
        strcpy((char*)&pCi->p_code[pCi->pc], pCi->a_buff + 1);
        pCi->pc += len - 1;
        type = e_STR;
        break;
    case SID: // string variable, like A$
        match(SID);
        pCi->p_code[pCi->pc++] = k_PUSH_VAR_N2;
        pCi->p_code[pCi->pc++] = a_Symbol[pCi->sym_idx].value;
        type = e_STR;
        break;
#ifdef cfg_STRING_SUPPORT        
    case LEFTS: // left function
        match(LEFTS);
        match('(');
        compile_expression(e_STR);
        match(',');
        compile_expression(e_NUM);
        match(')');
        pCi->p_code[pCi->pc++] = k_LEFT_STR_N1;
        type = e_STR;
        break;
    case RIGHTS: // right function
        match(RIGHTS);
        match('(');
        compile_expression(e_STR);
        match(',');
        compile_expression(e_NUM);
        match(')');
        pCi->p_code[pCi->pc++] = k_RIGHT_STR_N1;
        type = e_STR;
        break;
    case MIDS: // mid function
        match(MIDS);
        match('(');
        compile_expression(e_STR);
        match(',');
        compile_expression(e_NUM);
        match(',');
        type = compile_expression(e_NUM);
        match(')');
        pCi->p_code[pCi->pc++] = k_MID_STR_N1;
        type = e_STR;
        break;
    case LEN: // len function
        match(LEN);
        match('(');
        compile_expression(e_STR);
        match(')');
        pCi->p_code[pCi->pc++] = k_STR_LEN_N1;
        type = e_NUM;
        break;
    case VAL: // val function
        match(VAL);
        match('(');
        compile_expression(e_STR);
        match(')');
        pCi->p_code[pCi->pc++] = k_STR_TO_VAL_N1;
        type = e_NUM;
        break;
    case STRS: // str$ function
        match(STRS);
        match('(');
        compile_expression(e_NUM);
        match(')');
        pCi->p_code[pCi->pc++] = k_VAL_TO_STR_N1;
        type = e_STR;
        break;
    case HEXS: // hex function
        match(HEXS);
        match('(');
        compile_expression(e_NUM);
        match(')');
        pCi->p_code[pCi->pc++] = k_VAL_TO_HEX_N1;
        type = e_STR;
        break;
    case INSTR: // instr function
        match(INSTR);
        match('(');
        compile_expression(e_NUM);
        match(',');
        compile_expression(e_STR);
        match(',');
        compile_expression(e_STR);
        match(')');
        pCi->p_code[pCi->pc++] = k_INSTR_N1;
        type = e_NUM;
        break;
    case STRINGS: // string$ function
        match(STRINGS);
        match('(');
        compile_expression(e_NUM);
        match(',');
        tok = lookahead();
        compile_expression(e_STR);
        match(')');
        pCi->p_code[pCi->pc++] = k_ALLOC_STR_N1;
        type = e_STR;
        break;
#endif        
    case RND: // Random number
        match(RND);
        match('(');
        compile_expression(e_NUM);
        match(')');
        pCi->p_code[pCi->pc++] = k_RND_N1;
        type = e_NUM;
        break;
    case XFUNC:
        match(XFUNC);
        type = compile_xfunc(e_ANY);
        pCi->p_code[pCi->pc++] = k_PARAM_N1;
        break;
    case NIL:
        match(NIL);
        pCi->p_code[pCi->pc++] = k_PUSH_NUM_N2;
        pCi->p_code[pCi->pc++] = 0;
        type = e_REF;
        break;
    default:
        error("syntax error", pCi->a_buff);
        break;
    }
    return type;
}
