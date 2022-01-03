--[[

	SaferLua [safer_lua]
	====================

	Copyright (C) 2018 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	environ.lua:

]]--

safer_lua.MaxCodeSize = 5000    -- size if source code in bytes
safer_lua.MaxTableSize = 1000   -- sum over all table sizes
safer_lua.MaxExeTime = 20000   -- max. execution time in us

local function memsize()
	return safer_lua.MaxTableSize
end

local function range(from, to)
    return function(expired_at,last)
		assert(expired_at > minetest.get_us_time(), "Runtime limit exceeded")
		if last >= to then 
			return nil
		else 
			return last+1
		end
	end, minetest.get_us_time() + safer_lua.MaxExeTime, from-1
end

local BASE_ENV = {
	Array = safer_lua.Array,
	Store = safer_lua.Store,
	Set = safer_lua.Set,
	memsize = memsize,
	range = range,
	math = {
		floor = math.floor,
		abs = math.abs,
		max = math.max,
		min = math.min,
		random = math.random,
	},
	string = {
		byte = string.byte,
		char = string.char,
		find = string.find,
		format = string.format,
		gmatch = string.gmatch,
		gsub = string.gsub,
		len = string.len,
		lower = string.lower,
		match = string.match,
		rep = string.rep,
		sub = string.sub,
		upper = string.upper,
		split = function(str, separator, include_empty, max_splits, sep_is_pattern) 
			if separator == "" then separator = " " end
			return safer_lua.Array(unpack(string.split(str, separator, include_empty, max_splits, sep_is_pattern))) 
		end,
		split2 = function(str, separator, include_empty, max_splits, sep_is_pattern) 
			if separator == "" then separator = " " end
			return unpack(string.split(str, separator, include_empty, max_splits, sep_is_pattern))
		end,
		trim = string.trim,
	},
	tonumber = tonumber,
	tostring = tostring,
	type = type,
	ticks = 0,
}

local function map(dest, source)
  for k,v in pairs(source) do
    dest[k] = v
  end
  return dest
end

local function calc_used_mem_size(env)
	local size = 0
	for key,val in pairs(env) do
		if type(val) == "table" and val.size ~= nil then
			size = size + val.size() or 0
		end
	end
	return size
end

function safer_lua.config(max_code_size, max_table_size)
	safer_lua.MaxCodeSize = max_code_size
	safer_lua.MaxTableSize = max_table_size
end	

local function format_error_str(str, label)
	local tbl = {}
	for s in str:gmatch("[^\r\n]+") do
		s = s:match("^%s*(.-)%s*$")
		if s:find("function 'xpcall'") then
			break
		elseif s:find(".-%.lua:%d+:(.+)") then
			local err = s:gsub(".-%.lua:%d+:%s*(.+)", "extern: %1")
			table.insert(tbl, err)
		elseif s:find('%[string ".-"%]') then
			local line, err = s:match('^%[string ".-"%]:(%d+): (.+)$')
			table.insert(tbl, label..":"..line..": "..err)
		elseif s:find('%(load%):(%d+):') then
			local line, err = s:match('%(load%):(%d+): (.+)$')
			table.insert(tbl, label..":"..line..": "..err)
		end
	end    
	return "Error: "..table.concat(tbl, "\n >> ")
end

local function format_error(err, label)
	if err:find("stack overflow") then
		return "Error: Stack overflow due to recursive function calls!"
	end
	return format_error_str(err, label)
end

local function compile(pos, text, label, err_clbk)
	if safer_lua:check(pos, text, label, err_clbk) == 0 then
		text = text:gsub("%$", "S:")
		local code, err = loadstring(text)
		if not code then
			err_clbk(pos, format_error(err, label)) 
		else
			return code
		end
	end
end

-------------------------------------------------------------------------------
-- Standard init/loop controller
-------------------------------------------------------------------------------
function safer_lua.init(pos, init, loop, environ, err_clbk)
	if (#init + #loop) > safer_lua.MaxCodeSize then
		err_clbk(pos, "Error: Code size limit exceeded")
		return
	end
	local code = compile(pos, init, "init", err_clbk, 0)
	if code then
		local env = table.copy(BASE_ENV)
		env.S = {}
		env.S = map(env.S, environ)
		setfenv(code, env)
		local res, err = xpcall(code, debug.traceback)
		if not res then
			err_clbk(pos, format_error(err, "init"))
		else
			env = getfenv(code)
			code = compile(pos, loop, "loop", err_clbk)
			if code then
				setfenv(code, env)
				return code
			end
		end
	end
end

function safer_lua.run_loop(pos, elapsed, code, err_clbk)
	local env = getfenv(code)
	env.elapsed = elapsed
	if elapsed < 0 then  -- event?
		env.event = true
	else
		env.event = false
		env.ticks = env.ticks + 1
	end
	local res, err = xpcall(code, debug.traceback)
	if calc_used_mem_size(env) > safer_lua.MaxTableSize then 
		err_clbk(pos, "Error: Data memory limit exceeded")
		return false
	end
	if not res then
		err_clbk(pos, format_error(err, "loop"))
		return false
	end
	return true
end

-------------------------------------------------------------------------------
-- Endless/Coroutine controller
-------------------------------------------------------------------------------
local function thread(pos, code, err_clbk)
	while true do
		local res, err = xpcall(code, debug.traceback)
		if not res then
			err_clbk(pos, format_error(err, "loop"))
			return false
		end
		local env = getfenv(code)
		if calc_used_mem_size(env) > safer_lua.MaxTableSize then 
			err_clbk(pos, "Error: Memory limit exceeded")
			return false
		end
		coroutine.yield()
	end
end	

function safer_lua.co_create(pos, init, loop, environ, err_clbk)
	local code = safer_lua.init(pos, init, loop, environ, err_clbk)
	return coroutine.create(thread), code
end

function safer_lua.co_resume(pos, co, code, err_clbk)
	local res, err = coroutine.resume(co, pos, code, err_clbk)
	if not res then
		err_clbk(pos, format_error(err, "loop"))
		return false
	end
	return true
end
