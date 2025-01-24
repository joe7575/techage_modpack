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

//#define cfg_LINE_NUMBERS      // enable line numbers (or use labels)
#define cfg_STRING_SUPPORT     // enable string support
//#define cfg_DATA_ACCESS        // enable byte access to arrays

#define cfg_MAX_FOR_LOOPS       (4)   // nested FOR loops (2 values per FOR loop on the stack)
#define cfg_STACK_SIZE          (32)  // value for stack size (expression, call stack)
#define cfg_PARAMSTACK_SIZE     (8)   // value for parameter stack size
#define cfg_NUM_VARS            (256) // in the range 8..256
#define cfg_MAX_NUM_DATA        (200) // (list of constants)
#define cfg_MAX_CODE_SIZE       (1024 * 16) // in 1k steps
#define cfg_MEM_HEAP_SIZE       (1024 * 8) // in 1k steps
#define cfg_MAX_MEM_BLOCK_SIZE  (512) // in 8 byte steps
#define cfg_MAX_NUM_XFUNC       (32)  // number of external function definitions
#define cfg_MAX_FW_DECL         (32)  // number of forward declarations (goto/gosub label)

#ifdef cfg_LINE_NUMBERS
    #define cfg_MAX_NUM_SYM     (16000) // For keywords, variables, and line numbers
#else
    #define cfg_MAX_NUM_SYM     (256) // For keywords, variables, and labels
#endif

