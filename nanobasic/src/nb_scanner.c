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
#include "nb.h"
#include "nb_int.h"

#define is_alpha(x)   (Ascii[x & 0x7F] & 0x01)
#define is_digit(x)   (Ascii[x & 0x7F] & 0x02)
#define is_wspace(x)  (Ascii[x & 0x7F] & 0x04)
#define is_alnum(x)   (Ascii[x & 0x7F] & 0x03)
#define is_comp(x)    (Ascii[x & 0x7F] & 0x08)
#define is_arith(x)   (Ascii[x & 0x7F] & 0x10)

static char Ascii[] = {
    //0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F  
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x04, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, // 0x00 - 0x0F
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x04, 0x00, 0x00, // 0x10 - 0x1F
    0x04, 0x10, 0x00, 0x00, 0x00, 0x10, 0x10, 0x00, 0x00, 0x00, 0x10, 0x10, 0x00, 0x10, 0x00, 0x10, // 0x20 - 0x2F
    0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x00, 0x00, 0x08, 0x08, 0x08, 0x00, // 0x30 - 0x3F
    0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, // 0x40 - 0x4F
    0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, // 0x50 - 0x5F
    0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, // 0x60 - 0x6F
    0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, // 0x70 - 0x7F
};

char *nb_scanner(char *p_in, char *p_out) {
    char c8;

    while(is_wspace(*p_in)) {
      p_in++;
    }

    while((c8 = *p_in) != 0) {
        if(c8 == '\'') {
            while(*p_in != '\n' && *p_in != '\r' && *p_in != '\0') {
                p_in++;
            }
            continue;
        }
        if(is_alpha(c8)) {
            *p_out++ = c8;
            p_in++;
            while(is_alnum(*p_in)) {
                *p_out++ = *p_in++;
            }
            if(*p_in == '$') { // String variable/function
                *p_out++ = *p_in++;
            }
            *p_out++ = '\0';
            return p_in;
        }

        if(is_digit(c8)) {
            *p_out++ = c8;
            p_in++;
            while(is_digit(*p_in)) {
                *p_out++ = *p_in++;
            }
            *p_out++ = '\0';
            return p_in;
        }

        if(is_comp(c8)) {
            *p_out++ = c8;
            p_in++;
            while(is_comp(*p_in)) {
                *p_out++ = *p_in++;
            }
            *p_out++ = '\0';
            return p_in;
        }

        if(is_arith(c8)) {
            *p_out++ = c8;
            p_in++;
            while(is_arith(*p_in)) {
                *p_out++ = *p_in++;
            }
            *p_out++ = '\0';
            return p_in;
        }

        if(c8 == '\"') {
            *p_out++ = c8;
            p_in++;
            while((c8 = *p_in) != '\"') {
                *p_out++ = c8;
                p_in++;
            }
            *p_out++ = c8;
            p_in++;
            *p_out++ = '\0';
            return p_in;
        }

        // End of string
        if((c8 == '\n') || (c8 == '\r')) {
            *p_out++ = '\0';
            return NULL;
        }
        
        // Single character
        *p_out++ = c8;
        p_in++;
        *p_out++ = '\0';
        return p_in;
    }

    // End of string
    if((c8 == '\n') || (c8 == '\r') || (c8 == '\0')) {
        *p_out = '\0';
        return NULL;
    }
    return NULL;
}

#ifdef TEST
int main(void) {
    char s[] = "LET A = 1234 * 2 - 1";
    char t[80];
    char *p = s;

    while(*p != 0) {
        p = nb_scanner(p,t);
        nb_print("%s\n",t);
    }

    strcpy(s,"\"Hello World\"");
    p = s;
    while(*p != 0) {
        p = nb_scanner(p,t);
        nb_print("%s\n",t);
    }
    
    strcpy(s,"A=1234*2-1");
    p = s;
    while(*p != 0) {
        p = nb_scanner(p,t);
        nb_print("%s\n",t);
    }

    return 0;
}
#endif
