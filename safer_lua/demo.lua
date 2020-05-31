--[[

	SaferLua [safer_lua]
	====================

	Copyright (C) 2018-2020 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	Example demo code

]]--


-- demo function 1
local function output(self, s)
	print(self.meta.name, s)
end	

-- demo function 2
local function add(self, param1, param2)
	return param1 + param2
end	

-- for Lua interpreter errors
local function error(pos, s)
	print("[Safer Lua] "..(s or ""))
end

-- init function code block
local init = [[
  -- init code here
  
  sum = 0  
  $output("Hello world!")  
]]

-- loop function code block
local loop = [[
  -- loop code here
  
  sum = $add(1, sum)
  $output(sum)  
]]

-- runtime environment
local env = {
	output = output,
	add = add,
}

-- runtime meta data (protected for the running Lua script)
env.meta = {num = 1, name = "Joe"}

-- used for ingame positions
local pos = {x = 0, y = 0, z = 0}

-- elapsed game time
local elapsed = 1

-- compile the Lus script to byte code (only once)
local code = safer_lua.init(pos, init, loop, env, error)

if code then
	for i=1, 10 do
		-- execute the byte code
		safer_lua.run_loop(pos, elapsed, code, error)
	end
end
