NanoBasic
=========

A small BASIC compiler with virtual machine.
This software is written from scratch in C.

Most of the common BASIC keywords are supported:

```bnf
    PRINT expression-list [ ; | , ]
    FOR numeric_variable '=' numeric_expression TO numeric_expression [ STEP number ]
    IF relation-expression THEN statement-list [ ELSE statement-list ]
    IF relation-expression GOTO line-number [ ELSE statement-list ]
    GOTO line-number
    GOSUB line-number
    ON numeric_expression GOSUB line-number-list
    ON numeric_expression GOTO line-number-list
    LET variable = expression
    LET string-variable$ = string-expression$
    DIM array-variable "(" numeric_expression ")"
    ERASE ( array-variable | string-variable$ )
    READ variable-list
    DATA ( constant-list | string-list )       ; Only at the end of the program
    RESTORE [ number ]                         ; Number is offset (0..n), not line number
    RETURN
    END
    BREAK
    TRON, TROFF
    FREE
    AND, NOT, OR, RND, MOD, LEN, VAL, SPC, NIL
    LEN, CHR$, MID$, LEFT$, RIGHT$, STR$, HEX$, STRING$

    ; Basic V2 features:

    CONST variable = number
    IF relation-expression THEN
        statements...
    [ ELSE
        statements... ]
    ENDIF
    WHILE relation-expression
        statements...
    LOOP
    variable = expression                                  ; without LET
    string-variable$ = string-expression$                  ; without LET
```

Data processing features (optional):

```
    GET1, GET2, GET4, SET1, SET2, SET4, COPY, REF, RETI
```

Supported data types are:

- Signed Integer, 32 bit (-2,147,483,648 to 2,147,483,647)
- String (up to 120 characters)
- Array (one dimension, up to 128 elements)
- Constant (numeric only)

The compiler is able to generate a binary file that can be executed by the virtual machine.
The goal of NanoBasic was to be a small and fast, due to compiler and VM combination.
The main purpose of NanoBasic is to be embedded in other applications, to provide a
simple scripting language for configuration and as glue code.

The Basic language is inspired by the original Microsoft Basic known from Home Computers
in the 80s.

This software also provides a Lua binding for using NanoBasic from Lua. The goal
here is a Basic Computer as Luanti (Minetest) mod.
See [nanobasic-mod](https://github.com/joe7575/nanobasic-mod).

### License

Copyright (C) 2024-2025 Joachim Stolberg

The software is licensed under the MIT license.

### History

**2025-01-24 V1.0.2**
- Add RETI command
- Remove cfg_BASIC_V2 compiler switch

**2025-01-11 V1.0.1**
- Rework data access API and functions

**2025-01-02 V1.0.0**
- Fix string length bug

**2025-01-01 V1.0.0**
- First release
