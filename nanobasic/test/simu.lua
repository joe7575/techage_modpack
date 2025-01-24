--[[
  VM2 a 16-bit virtual machine for use in the game Minetest.
  Copyright (C) 2023-2024 Joachim Stolberg <iauit@gmx.de>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]--

-- Parameters types
local NB_NONE     = 0
local NB_NUM      = 1
local NB_STR      = 2
local NB_ARR      = 3

-- Return values of 'nb_run()'
local NB_END      = 0  -- programm end reached
local NB_ERROR    = 1  -- error in programm
local NB_BREAK    = 2  -- break command
local NB_BUSY     = 3  -- programm still running
local NB_XFUNC    = 4  -- 'call' external function

local nblib = require("nanobasiclib")

local script = [[1 REM NanoBasic example for a configuration with line numbers
2 REM and only core functionality
10 ' This is a comment
20 REM this is a comment too
30 ' Variable declaration
40 a = 10
50 let B$ = string$(10, "*")
60 dim Arr(10)
70 Arr(0) = 2: Arr(2) = 4: Arr(4) = 6: Arr(6) = 8: Arr(8) = 10
100 ' For loops
110 FOR i = 0 to a
120   PRINT i,
130 next i
140 print  ' newline
150 FOR j = 0 to 10 step 2
160   PRINT Arr(j),
170 next j
180 print
200 ' If statement
210 IF a = 10 THEN PRINT "a is 10" ELSE PRINT "a is not 10"
220 ' Gosub statement
230 gosub 300
240 ' For loop with data statement
250 FOR i = 1 to 8
260   read var1, var2
270   PRINT var1 "+" var2 "=" var1 + var2
280 next
290 end
300 ' Subroutine
310 PRINT "subroutine at line 300"
320 return
400 ' Data statement
410 DATA 1, 2, 3, 4, 5, 6, 7, 8
420 DATA 9, 10, 11, 12, 13, 14, 15, 16
]]

local function test()
    print("Version: V" .. nblib.version())
    print(nblib.free_mem())
    local vm, sts = nblib.create(script)
    print("Create: ", sts, vm)
    if sts ~= 0 then
        print("Error:", sts)
        return
    end
    print(nblib.run(vm, 1000))
    print(nblib.get_screen_buffer(vm))
    local s = nblib.pack_vm(vm)
    print(#s)
    nblib.unpack_vm(vm, s)
    print(nblib.reset(vm))
    print(nblib.run(vm, 1000))
    print(nblib.get_screen_buffer(vm))
    nblib.destroy(vm)
end

test()

