--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Signs Bot: Command interpreter

]]--

-- Load support for I18n.
local S = signs_bot.S

local MAX_SIZE = 1000  -- max number of tokens

local tCmdDef = {}
local lCmdLookup = {}
local tSymbolTbl = {}
local CodeCache = {}

local api = {}

-- Possible command results
api.BUSY = 1     -- execute the same command again
api.DONE = 2     -- next command
api.NEW = 3      -- switch to a new script, provided as second value
api.ERROR = 4    -- stop execution with error, error message provided as second value
api.EXIT = 5     -- stop execution

-------------------------------------------------------------------------------
-- Compiler
-------------------------------------------------------------------------------
local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function get_line_tokens(script)
	local idx = 0
	script = script or ""
	script = script:gsub("\r\n", "\n")
	script = script:gsub("\r", "\n")
	local lines = string.split(script, "\n", true)
    return function()
		while idx < #lines do
			idx = idx + 1
			-- remove comments
			local line = string.split(lines[idx], "--", true, 1)[1] or ""
			-- remove blanks
			line = trim(line)
			if #line > 0 then
				-- split into tokens
				return idx, unpack(string.split(line, " "))
			end
		end
	end
end

local function dbg_out(opcode, num_param, code, pc)
	if num_param == 0 then
		print(">>"..lCmdLookup[opcode][3])
	elseif num_param == 1 then
		print(">>"..lCmdLookup[opcode][3].." "..code[pc+1])
	elseif num_param == 2 then
		print(">>"..lCmdLookup[opcode][3].." "..code[pc+1].." "..code[pc+2])
	else
		print(">>"..lCmdLookup[opcode][3].." "..code[pc+1].." "..code[pc+2].." "..code[pc+3])
	end
end

local function tokenizer(script)
	local tokens = {}
	for _, cmnd, param1, param2, param3 in get_line_tokens(script) do
		if tCmdDef[cmnd] then
			local num_param = tCmdDef[cmnd].num_param
			tokens[#tokens + 1] = cmnd
			if num_param >= 1 then
				tokens[#tokens + 1] = param1 or "nil"
			end
			if num_param >= 2 then
				tokens[#tokens + 1] = param2 or "nil"
			end
			if num_param >= 3 then
				tokens[#tokens + 1] = param3 or "nil"
			end
		elseif cmnd:find("%w+:") then
			tokens[#tokens + 1] = cmnd
		end
	end
	tokens[#tokens + 1] = "exit"
	return tokens
end

local function pass1(tokens)
	local pc = 1
	tSymbolTbl = {}
	for _, token in ipairs(tokens) do
		if token:find("%w+:") then
			tSymbolTbl[token] = pc
		else
			pc = pc + 1
		end
	end
end

local function pass2(tokens)
	local code = {}
	local num_param = 0
	for _, token in ipairs(tokens) do
		if num_param > 0 then
			code[#code + 1] = tonumber(token) or tSymbolTbl[token..":"] or token
			num_param = num_param - 1
		elseif tCmdDef[token] then
			num_param = tCmdDef[token].num_param
			code[#code + 1] = tCmdDef[token].opcode
		end
	end
	return code
end

local function compile(script)
	local tokens = tokenizer(script)
	pass1(tokens)
	return pass2(tokens)
end

local function gen_string_cmnd(code, pc, num_param, script)
	local tokens = tokenizer(script)
	pc = math.min(pc, #tokens)
	if num_param == 0 then
		return tokens[pc]
	elseif num_param == 1 then
		return tokens[pc] .. " " .. (tokens[pc+1] or "")
	elseif num_param == 2 then
		return tokens[pc] .. " " .. (tokens[pc+1] or "") .. " " .. (tokens[pc+2] or "")
	else
		return tokens[pc] .. " " .. (tokens[pc+1] or "") .. " " .. (tokens[pc+2] or "") .. " " .. (tokens[pc+3] or "")
	end
end

-------------------------------------------------------------------------------
-- Commands
-------------------------------------------------------------------------------
local function register_command(cmnd_name, num_param, cmnd_func, check_func)
	assert(num_param, cmnd_name..": num_param = "..dump(num_param))
	assert(cmnd_func, cmnd_name..": cmnd_func = "..dump(cmnd_func))
	assert(check_func or num_param == 0, cmnd_name..": check_func = "..dump(check_func))
	lCmdLookup[#lCmdLookup + 1] = {num_param, cmnd_func, cmnd_name}
	tCmdDef[cmnd_name] = {
		num_param = num_param,
		cmnd = cmnd_func,
		name = cmnd_name,
		check = check_func,
		opcode = #lCmdLookup,
	}
end

register_command("repeat", 1,
	function(base_pos, mem, cnt)
		mem.Stack[#mem.Stack + 1] = tonumber(cnt)
		mem.Stack[#mem.Stack + 1] = mem.pc + 1
		return api.DONE
	end,
	function(cnt)
		cnt = tonumber(cnt) or 0
		return cnt > 0 and cnt < 1000
	end
)

register_command("end", 0,
	function(base_pos, mem)
		if #mem.Stack < 2 then
			return api.ERROR
		end
		mem.Stack[#mem.Stack - 1] = mem.Stack[#mem.Stack - 1] - 1
		if mem.Stack[#mem.Stack - 1] > 0 then
			mem.pc = mem.Stack[#mem.Stack]
		else
			mem.Stack[#mem.Stack] = nil
			mem.Stack[#mem.Stack] = nil
		end
		return api.DONE
	end
)

register_command("call", 1,
	function(base_pos, mem, addr)
		if #mem.Stack > 99 then
			return api.ERROR, "call stack overrun"
		end
		mem.Stack[#mem.Stack + 1] = mem.pc + 2
		mem.pc = addr - 2
		return api.DONE
	end,
	function(addr)
		return addr and tSymbolTbl[addr..":"]
	end
)

register_command("return", 0,
	function(base_pos, mem)
		if #mem.Stack < 1 then
			return api.ERROR, "no return address"
		end
		mem.pc = (mem.Stack[#mem.Stack] or 1) - 1
		mem.Stack[#mem.Stack] = nil
		return api.DONE
	end
)

register_command("jump", 1,
	function(base_pos, mem, addr)
		mem.pc = addr - 2
		return api.DONE
	end,
	function(addr)
		return addr and tSymbolTbl[addr..":"]
	end
)

register_command("exit", 0,
	function(base_pos, mem)
		return api.EXIT
	end
)

-------------------------------------------------------------------------------
-- API functions
-------------------------------------------------------------------------------

function api.register_command(cmnd_name, num_param, cmnd_func, check_func)
	register_command(cmnd_name, num_param, cmnd_func, check_func)
end

function api.check_label(label)
	return label and tSymbolTbl[label..":"] ~= nil
end


-- function returns: true/false, error_string, line-num
function api.check_script(script)
	local tbl = {}
	local num_token = 0

	-- to fill the symbol table
	local tokens = tokenizer(script)
	pass1(tokens)

	for idx, cmnd, param1, param2, param3 in get_line_tokens(script) do
		if tCmdDef[cmnd] then
			num_token = num_token + 1 + tCmdDef[cmnd].num_param
			if num_token > MAX_SIZE then
				return false, S("Maximum programm size exceeded"), idx
			end
			param1 = tonumber(param1) or param1
			param2 = tonumber(param2) or param2
			param3 = tonumber(param3) or param3
			local num_param = (param1 and 1 or 0) + (param2 and 1 or 0) + (param3 and 1 or 0)
			if tCmdDef[cmnd].num_param < num_param then
				return false, S("Too many parameters"), idx
			end
			if tCmdDef[cmnd].num_param > 0 and not tCmdDef[cmnd].check(param1, param2, param3) then
				return false, S("Parameter error"), idx
			end
		elseif not cmnd:find("%w+:") then
			return false, S("Command error"), idx
		end
		tbl[cmnd] = (tbl[cmnd] or 0) + 1
	end
	if (tbl["end"] or 0) > (tbl["repeat"] or 0) then
		return false, S("'repeat' missing"), 0
	elseif (tbl["end"] or 0) < (tbl["repeat"] or 0) then
		return false, S("'end' missing"), 0
	end
	return true, S("Checked and approved"), 0
end

-- function returns: true/false, error-string
-- default_cmnd is used for the 'cond_move'
function api.run_script(base_pos, mem)
	local hash = minetest.hash_node_position(base_pos)
	CodeCache[hash] = CodeCache[hash] or compile(mem.script)
	local code = CodeCache[hash]
	mem.pc = mem.pc or 1
	mem.Stack = mem.Stack or {}
	local opcode = code[mem.pc]
	if opcode then
		local num_param, func = unpack(lCmdLookup[opcode])

		--dbg_out(opcode, num_param, code, mem.pc)
		local res, err = func(base_pos, mem, code[mem.pc+1], code[mem.pc+2], code[mem.pc+3])
		if res == api.DONE then
			mem.pc = mem.pc + 1 + num_param
		elseif res == api.NEW then
			CodeCache[hash] = compile(mem.script)
			mem.pc = 1
			mem.Stack = {}
		end
		return res, err, gen_string_cmnd(code, mem.pc, num_param, mem.script)
	end
	return api.EXIT
end

function api.reset_script(base_pos, mem)
	local hash = minetest.hash_node_position(base_pos)
	CodeCache[hash] = nil
	mem.pc = 1
	mem.Stack = {}
	mem.bot_falling = nil
end

return api
