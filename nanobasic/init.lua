--[[

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

]]--

nanobasic = {}

local IE = minetest.request_insecure_environment()

if not IE then
	error("\nAdd 'nanobasic' to the list of 'secure.trusted_mods' in minetest.conf!!!")
end

local nblib = IE.require("nanobasiclib")

if not nblib then
	error("\nInstall nanobasic via 'luarocks --lua-version 5.1 install nanobasic'!!")
end

if nblib.version() < "1.0.2" then
	error("\nUpdate nanobasic via 'luarocks --lua-version 5.1 install nanobasic'!!")
end

local M = minetest.get_meta
local VMList = {}
local UIDList = {}
local storage = minetest.get_mod_storage()

-- Parameters types
nanobasic.NB_NONE     = 0 -- no parameter
nanobasic.NB_NUM      = 1 -- number
nanobasic.NB_STR      = 2 -- string
nanobasic.NB_ARR      = 3 -- array
nanobasic.NB_ANY      = 4 -- any kind of parameter or none

-- Return values of 'nb_run()'
nanobasic.NB_END      = 0  -- programm end reached
nanobasic.NB_ERROR    = 1  -- error in programm
nanobasic.NB_BREAK    = 2  -- break command
nanobasic.NB_BUSY     = 3  -- programm still running
nanobasic.NB_XFUNC    = 4  -- 'call' external function

nanobasic.CallResults = {"END", "ERROR", "BUSY", "BREAK", "XFUNC"}

function nanobasic.version()
	return nblib.version()
end

-------------------------------------------------------------------------------
-- Wrapper for the nanobasic library in C
-------------------------------------------------------------------------------

--
-- Standard API
--

-- @return string with the size of free memory
function nanobasic.free_mem()
	return nblib.free_mem()
end

-- @param pos: node position
-- @param param_types: table with parameter types (NB_NUM, NB_STR, NB_ARR)
-- @param return_type: return type (NB_NONE, NB_NUM, NB_STR, NB_ARR)
-- @return 'nanobasic.run' result, if function was called
function nanobasic.add_function(name, param_types, return_type)
	return nblib.add_function(name, param_types, return_type)
end

-- @param pos: node position
-- @return true, if VM was successfully initialized
function nanobasic.create(pos, code)
	local sts
	local hash = nblib.hash_node_position(pos)
	VMList[hash], sts = nblib.create(code)
	return sts == 0
end

-- @param pos: node position
-- @param cycles: number of cycles to execute
-- @return number of executed cycles, or -1 if error
function nanobasic.run(pos, cycles)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.run(VMList[hash], cycles) or -1
end

-- @param pos: node position
function nanobasic.get_screen_buffer(pos)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.get_screen_buffer(VMList[hash])
end

-- @param pos: node position
function nanobasic.clear_screen(pos)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.clear_screen(VMList[hash])
end

-- @param pos: node position
-- @param text: string to be output
function nanobasic.print(pos, text)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.print(VMList[hash], text)
end

-- @param pos: node position
-- @return true, if VM was successfully reset
function nanobasic.reset(pos)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.reset(VMList[hash])
end

-- @param pos: node position
function nanobasic.destroy(pos)
	local hash = nblib.hash_node_position(pos)
	if VMList[hash] then
		nblib.destroy(VMList[hash])
		VMList[hash] = nil
	end
end

--
-- Helper functions
--
-- @param pos: node position
function nanobasic.dump_code(pos)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.dump_code(VMList[hash])
end

-- @param pos: node position
function nanobasic.output_symbol_table(pos)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.output_symbol_table(VMList[hash])
end

--
-- API for external functions
--

-- @param pos: node position
-- @param label: label to search for
-- @return address of the label, or 0 if not found
function nanobasic.get_label_address(pos, label)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.get_label_address(VMList[hash], label)
end

-- @param pos: node position
-- @param addr: address to set the program counter
-- @return true, if PC was successfully set
function nanobasic.set_pc(pos, addr)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.set_pc(VMList[hash], addr)
end

-- @param pos: node position
-- @return number of parameters on the parameter stack (0..n)
function nanobasic.stack_depth(pos)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.stack_depth(VMList[hash])
end

-- @param pos: node position
-- @param idx = stack position (1..n) 1 = top of stack
function nanobasic.peek_num(pos, idx)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.peek_num(VMList[hash], idx)
end

-- @param pos: node position
-- @return number from the parameter stack
function nanobasic.pop_num(pos)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.pop_num(VMList[hash])
end

-- @param pos: node position
-- @param number: push number on the parameter stack
function nanobasic.push_num(pos, number)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.push_num(VMList[hash], number)
end

-- @param pos: node position
-- @return string from the parameter stack
function nanobasic.pop_str(pos)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.pop_str(VMList[hash])
end

-- @param pos: node position
-- @param str: push string on the parameter stack
function nanobasic.push_str(pos, str)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.push_str(VMList[hash], str)
end

-- @param pos: node position
-- @param name: return variable index number used by the VM
function nanobasic.get_var_num(pos, name)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.get_var_num(VMList[hash], name)
end

function nanobasic.pop_arr_addr(pos)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.pop_arr_addr(VMList[hash])
end

-- @param pos: node position
-- @param addr: array address, determined via pop_arr_addr()
-- @return Array as table or nil
function nanobasic.read_arr(pos, addr)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.read_arr(VMList[hash], addr)
end

-- @param pos: node position
-- @param addr: array address, determined via pop_arr_addr()
-- @param tbl: Array as table
function nanobasic.write_arr(pos, addr, tbl)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.write_arr(VMList[hash], addr, tbl)
end

--
-- Debug API functions
--

-- @param pos: node position
function nanobasic.get_variable_list(pos)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.get_variable_list(VMList[hash])
end

-- @param pos: node position
-- @param type: variable type from get_variable_list()
-- @param var: variable index from get_variable_list()
-- @param idx: array index (or 0)
function nanobasic.read_variable(pos, _type, var, idx)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] and nblib.read_variable(VMList[hash], _type, var, idx)
end

-------------------------------------------------------------------------------
-- Further API functions
-------------------------------------------------------------------------------

-- @param pos: node position
-- @return hash value for the node position
function nanobasic.hash_node_position(pos)
	return nblib.hash_node_position(pos)
end

-- @param hash: hash value for the node position
-- @return node position as table (x,y,z)
function nanobasic.get_position_from_hash(hash)
	local x = (hash:byte(1) - 48) + (hash:byte(2) - 48) * 64 + (hash:byte(3) - 48) * 4096
	local y = (hash:byte(4) - 48) + (hash:byte(5) - 48) * 64 + (hash:byte(6) - 48) * 4096
	local z = (hash:byte(7) - 48) + (hash:byte(8) - 48) * 64 + (hash:byte(9) - 48) * 4096
	return {x = x - 32768, y = y - 32768, z = z - 32768}
end

-- @param pos: node position
-- @return true, if VM is loaded
function nanobasic.is_loaded(pos)
	local hash = nblib.hash_node_position(pos)
	return VMList[hash] ~= nil
end

-- Restore a previously backed up VM without starting it
-- (called from minetest.register_lbm)
-- @param pos: node position
function nanobasic.vm_restore(pos)
	local hash = nblib.hash_node_position(pos)
	if VMList[hash] == nil then
		local s = storage:get_string(hash)
		if s ~= "" then
			if nanobasic.create(pos, "") then
				print("vm_restore")
				nblib.unpack_vm(VMList[hash], s)
			end
		end
	end
end

-------------------------------------------------------------------------------
-- World maintenance
-------------------------------------------------------------------------------

-- Store the VM in mod storage
local function vm_store(hash, vm)
	print("vm_store")
	local s = nblib.pack_vm(vm)
	storage:set_string(hash, s)
end

minetest.register_on_shutdown(function()
	for hash, vm in pairs(VMList) do
		vm_store(hash, vm)
	end
end)

local function remove_unloaded_vms()
	local tbl = table.copy(VMList)
	local cnt = 0
	VMList = {}
	for hash, vm in pairs(tbl) do
		local pos = nanobasic.get_position_from_hash(hash)
		if minetest.get_node_or_nil(pos) then
			VMList[hash] = vm
			cnt = cnt + 1
		else
			vm_store(hash, vm)
		end
	end
	minetest.after(60, remove_unloaded_vms)
end

minetest.after(60, remove_unloaded_vms)
