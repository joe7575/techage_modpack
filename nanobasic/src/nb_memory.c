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
#include "nb.h"
#include "nb_int.h"

#define NUM_BLOCKS(bytes)   ((bytes + k_MEM_BLOCK_SIZE + 1) / k_MEM_BLOCK_SIZE)
#define NUM_WORDS(bytes)    ((bytes + sizeof(uint32_t) + 1) / sizeof(uint32_t))
#define MIN(a, b)           ((a) < (b) ? (a) : (b))
#define HEADER_SIZE         2

void nb_mem_init(t_VM *p_vm) {
    for(int i = 0; i < cfg_MEM_HEAP_SIZE; i += k_MEM_BLOCK_SIZE) {
        p_vm->heap[i] = k_MEM_FREE_TAG;
    }
    p_vm->mem_start_addr = 0;
}

uint16_t nb_mem_alloc(t_VM *p_vm, uint16_t bytes) {
    if(bytes <= cfg_MAX_MEM_BLOCK_SIZE) {
        uint16_t num_blocks = NUM_BLOCKS(bytes);
        uint16_t num_words  = NUM_WORDS(bytes);
        uint16_t start = 0;
        uint16_t count = 0;
        uint16_t blocked = 0;

        for(int i = p_vm->mem_start_addr; i < cfg_MEM_HEAP_SIZE; i += k_MEM_BLOCK_SIZE) {
            if(blocked > 0) {
                blocked--;
                continue;
            }
            if(p_vm->heap[i] == k_MEM_FREE_TAG) {
                if(count == 0) {
                    start = i;
                    count = 1;
                    p_vm->mem_start_addr = i;
                } else {
                    count++;
                }
                if(count == num_blocks) {
                    p_vm->heap[start] = num_blocks;
                    p_vm->heap[start + 1] = num_words;
                    return 0x8000 + start + HEADER_SIZE;
                }
            } else {
                blocked = p_vm->heap[i] - 1;
                start = 0;
                count = 0;
            }
        }
    }
    return 0;
}

void nb_mem_free(t_VM *p_vm, uint16_t addr) {
    if(addr > 0x7FFF) {
        addr = (addr & 0x7FFF) - HEADER_SIZE;
        if(addr < cfg_MEM_HEAP_SIZE) {
            uint16_t size = p_vm->heap[addr] * k_MEM_BLOCK_SIZE;
            if((addr + size) <= cfg_MEM_HEAP_SIZE) {
                for(uint16_t i = 0; i < size; i += k_MEM_BLOCK_SIZE) {
                    p_vm->heap[addr + i] = k_MEM_FREE_TAG;
                }
                p_vm->mem_start_addr = MIN(p_vm->mem_start_addr, addr);
            }
        }
    }
}

// Allocate a bigger block if necessary
uint16_t nb_mem_realloc(t_VM *p_vm, uint16_t addr, uint16_t bytes) {
    if(addr > 0x7FFF && bytes <= cfg_MAX_MEM_BLOCK_SIZE) {
        uint16_t buff_size = (p_vm->heap[(addr & 0x7FFF) - 1] * sizeof(uint32_t)) - HEADER_SIZE;
        if(buff_size >= bytes) {
            return addr;
        }
        nb_mem_free(p_vm, addr);
        return nb_mem_alloc(p_vm, bytes);
    }
    return 0;
}

// size in bytes
uint16_t nb_mem_get_blocksize(t_VM *p_vm, uint16_t addr) {
    addr = (addr & 0x7FFF) - HEADER_SIZE;
    return (p_vm->heap[addr + 1] * sizeof(uint32_t)) - HEADER_SIZE;
}

uint16_t nb_mem_get_free(t_VM *p_vm) {
    uint16_t free = 0;
    for(int i = p_vm->mem_start_addr; i < cfg_MEM_HEAP_SIZE; i += k_MEM_BLOCK_SIZE) {
        if(p_vm->heap[i] == k_MEM_FREE_TAG) {
            free += k_MEM_BLOCK_SIZE;
        } else {
            i += (p_vm->heap[i] - 1) * k_MEM_BLOCK_SIZE;
        }
    }
    return free;
}

#ifdef TEST
void mem_dump(t_VM *p_vm) {
    uint8_t num_blocks = 0;

    nb_print("Memory dump:\n");
    for(int i = 0; i < 512; i += k_MEM_BLOCK_SIZE) {
        if(num_blocks == 0) {
            num_blocks = p_vm->heap[i];
            nb_print("%02d ", num_blocks);
            if(num_blocks > 0) {
                num_blocks--;
            }
        }
        else {
            num_blocks--;
            nb_print("xx ");
        }
        if((i + k_MEM_BLOCK_SIZE) % (k_MEM_BLOCK_SIZE * 32) == 0) {
            nb_print("\n");
        }
    }
    nb_print("\n");
}

void test_memory(t_VM *p_vm) {
    uint16_t addr1, addr2, addr3, addr4;

    mem_dump(p_vm);
    assert((addr1 = nb_mem_alloc(p_vm, 13)) != 0);
    assert((addr2 = nb_mem_alloc(p_vm, 14)) != 0);
    assert((addr3 = nb_mem_alloc(p_vm, 15)) != 0);
    assert((addr4 = nb_mem_alloc(p_vm, 128)) != 0);

    assert(nb_mem_get_blocksize(p_vm, addr1) == 14);
    assert(nb_mem_get_blocksize(p_vm, addr2) == 14);
    assert(nb_mem_get_blocksize(p_vm, addr3) == 18);
    assert(nb_mem_get_blocksize(p_vm, addr4) == 130);

    memset(p_vm->heap + (addr1 & 0x7FFF), 0x11, 13);
    memset(p_vm->heap + (addr2 & 0x7FFF), 0x22, 14);
    memset(p_vm->heap + (addr3 & 0x7FFF), 0x33, 15);
    memset(p_vm->heap + (addr4 & 0x7FFF), 0x44, 128);

    assert((uint64_t)(p_vm->heap + (addr1 & 0x7FFF)) % 4 == 0);
    assert((uint64_t)(p_vm->heap + (addr2 & 0x7FFF)) % 4 == 0);
    assert((uint64_t)(p_vm->heap + (addr3 & 0x7FFF)) % 4 == 0);
    assert((uint64_t)(p_vm->heap + (addr4 & 0x7FFF)) % 4 == 0);

    mem_dump(p_vm);
    nb_mem_free(p_vm, addr2);
    nb_mem_free(p_vm, addr4);
    mem_dump(p_vm);
    nb_mem_free(p_vm, addr1);
    nb_mem_free(p_vm, addr3);
    mem_dump(p_vm);

    assert((addr1 = nb_mem_alloc(p_vm, 29)) == 0x8002);
    assert((addr1 = nb_mem_realloc(p_vm, addr1, 14)) == 0x8002);
    mem_dump(p_vm);
    assert((addr2 = nb_mem_alloc(p_vm, 12)) == 0x8012);
    assert((addr2 = nb_mem_realloc(p_vm, addr2, 30)) == 0x8022);
    mem_dump(p_vm);
}

int main(void) {
    t_VM vm;
    test_memory(&vm);
    return 0;
}
#endif
