NanoBasic / [nanobasic]
=======================

## Nanobasic Mod for Luanti (Minetest)

NanoBasic is a BASIC interpreter to monitor and control Minetest/Luanti machines.
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
    DATA constant-list                                      ; numbers only, only at the end of the program
    RESTORE [ number ]                                      ; number is offset (0..n), not line number
    RETURN
    END
    BREAK
    TRON, TROFF
    FREE
    AND, NOT, OR, RND, MOD, LEN, VAL, SPC, TIME, SLEEP
    LEN, MID$, LEFT$, RIGHT$, STR$, HEX$, STRING$, NIL
    CMD, CMD$

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

Supported data types are:

- Signed Integer, 32 bit (-2,147,483,648 to 2,147,483,647)
- String
- Array (one dimension)
- Constant (numeric only)

The Basic language is inspired by the original Microsoft Basic known from Home Computers in the 80s.

This mod requires the Lua package nanobasic, which has to be installed with:

```bash
$ luarocks --lua-version 5.1 install nanobasic
```

For more info to LuaRocks, see: https://luarocks.org/

To enable this `unsafe` package, add 'nanobasic' to the list of trusted mods in
minetest.conf:

```text
secure.trusted_mods = <other mods>,nanobasic
```

Or, if not available, add the following line:

```text
secure.trusted_mods = nanobasic
```

An example of how NanoBasic can be used can be found here:
https://github.com/joe7575/techage/blob/master/logic/basic_terminal.lua

## Dependencies

There are no dependencies.

## License

Copyright (C) 2024-2025 Joachim Stolberg

Licensed under the MIT license. See LICENSE.txt


## History

**v1.0.0 (2025-01-01)**
- First release

