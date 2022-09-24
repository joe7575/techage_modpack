--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Signs Bot: Robot command interpreter

]]--

-- for lazy programmers
local M = minetest.get_meta

-- Load support for I18n.
local S = signs_bot.S

local MP = minetest.get_modpath("signs_bot")
local ci = dofile(MP.."/interpreter.lua")

local lib = signs_bot.lib

-- Possible command results
signs_bot.BUSY = ci.BUSY
signs_bot.DONE = ci.DONE
signs_bot.NEW = ci.NEW
signs_bot.ERROR = ci.ERROR
signs_bot.TURN_OFF = ci.TURN_OFF

-- API functions
signs_bot.check_label = ci.check_label

local tCommands = {}
local SortedKeys = {}
local SortedMods = {}
local tMods = {}
local ExpensiveCmnds = {}

function signs_bot.steps(mem, first, last)
	if not mem.steps then
		mem.steps = first - 1
	end
	mem.steps = mem.steps + 1
	if mem.steps >= last then
		mem.steps = nil
		return ci.DONE, last
	end
	return ci.BUSY, mem.steps
end

--
-- Command register API function
--
function signs_bot.register_botcommand(name, def)
	tCommands[name] = def
	tCommands[name].name = name
	if def.expensive then
		ExpensiveCmnds[name] = true
	end
	if not SortedKeys[def.mod] then
		SortedKeys[def.mod] = {}
		SortedMods[#SortedMods+1] = def.mod
		tMods[#tMods+1] = def.mod
	end
	local idx = #SortedKeys[def.mod] + 1
	SortedKeys[def.mod][idx] = name
	if def.num_param and def.cmnd then
		ci.register_command(name, def.num_param, def.cmnd, def.check)
	end
end

function signs_bot.get_commands()
	local tbl = {}
	for _,mod in ipairs(SortedMods) do
		tbl[#tbl+1] = mod.." "..S("commands:")
		for _,cmnd in ipairs(SortedKeys[mod]) do
			local item = tCommands[cmnd]
			tbl[#tbl+1] = "    "..item.name.." "..item.params
		end
	end
	return tbl
end

function signs_bot.get_help_text(cmnd)
	if cmnd then
		cmnd = unpack(string.split(cmnd, " "))
		local item = tCommands[cmnd]
		if item then
			return item.description
		end
	end
	return S("unknown command")
end

function signs_bot.check_commands(pos, text)
	return ci.check_script(text)
end

--
-- Bot Commands
--

local function check_sign(pos, mem)
	local meta = M(pos)
	local cmnd = meta:get_string("signs_bot_cmnd")
	if cmnd ~= "" then  -- command block?
		if meta:get_int("err_code") ~= 0 then -- code not valid?
			return false
		end

		local node = tubelib2.get_node_lvm(pos)
		-- correct sign direction?
		if mem.robot_param2 == node.param2 then
			return true
		end
		-- special sign node?
		if node.name == "signs_bot:bot_flap" or node.name == "signs_bot:box" then
			return true
		end
	end
	return false
end

-- Function returns 2 values:
--  - true if a sensor could be available, else false
--  - the sign pos or nil
local function scan_surrounding(mem)
	local pos1 = lib.next_pos(mem.robot_pos, mem.robot_param2)
	if check_sign(pos1, mem) then
		return true, pos1
	end
	local pos2 = {x=pos1.x, y=pos1.y+1, z=pos1.z}
	if check_sign(pos2, mem) then
		return true, pos2
	end
	if minetest.find_node_near(mem.robot_pos, 1, {
			"signs_bot:box", "signs_bot:bot_sensor"}) then  -- something around?
		return true
	end
	return false
end

local function activate_sensor(pos, param2)
	local pos1 = lib.next_pos(pos, param2)
	local node = tubelib2.get_node_lvm(pos1)
	if node.name == "signs_bot:bot_sensor" then
		node.name = "signs_bot:bot_sensor_on"
		minetest.swap_node(pos1, node)
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.after_place_node then
			ndef.after_place_node(pos1)
		end
	end
end

local function bot_error(base_pos, mem, err, cmd)
	minetest.sound_play('signs_bot_error', {pos = base_pos})
	minetest.sound_play('signs_bot_error', {pos = mem.robot_pos})
	err = err or "unknown"
	if cmd then
		signs_bot.infotext(base_pos, err .. ":\n'" .. cmd .. "'")
		mem.error = err .. ": '" .. cmd .. "'"
	else
		signs_bot.infotext(base_pos, err)
		mem.error = err
	end
	return false
end

local function power_consumption(mem, cmnd)
	if mem.capa then
		if ExpensiveCmnds[cmnd] then
			mem.capa = mem.capa - 2
		else
			mem.capa = mem.capa - 1
		end
		return mem.capa > 0
	end
	return true
end

function signs_bot.run_next_command(base_pos, mem)
	local res, err, cmd = ci.run_script(base_pos, mem)
	if res == ci.ERROR then
		return bot_error(base_pos, mem, err, cmd)
	elseif res == ci.EXIT then
		signs_bot.stop_robot(base_pos, mem)
		return false
	end
	if not power_consumption(mem) then
		signs_bot.stop_robot(base_pos, mem)
		mem.bot_state = "nopower"
		return bot_error(base_pos, mem, "No power")
	end
	return true
end

function signs_bot.reset(base_pos, mem)
	ci.reset_script(base_pos, mem)
end

signs_bot.register_botcommand("repeat", {
	mod = "core",
	params = "<num>",
	description = S("start of a 'repeat..end' block"),
})

signs_bot.register_botcommand("end", {
	mod = "core",
	params = "",
	description = S("end command of a 'repeat..end' block"),
})

signs_bot.register_botcommand("call", {
	mod = "core",
	params = "<label>",
	description = S("call a subroutine (with 'return' statement)"),
})

signs_bot.register_botcommand("return", {
	mod = "core",
	params = "",
	description = S("return from a subroutine"),
})

signs_bot.register_botcommand("jump", {
	mod = "core",
	params = "<label>",
	description = S("jump to a label"),
})

local function move(mem, any_sensor)
	local new_pos = signs_bot.move_robot(mem)
	if new_pos then  -- not blocked?
		mem.robot_pos = new_pos
		if any_sensor then
			activate_sensor(mem.robot_pos, (mem.robot_param2 + 1) % 4)
			activate_sensor(mem.robot_pos, (mem.robot_param2 + 3) % 4)
		end
	elseif mem.capa then
		mem.capa = mem.capa + 1
	end
end

signs_bot.register_botcommand("move", {
	mod = "move",
	params = "<steps>",
	num_param = 1,
	description = S([[Move the robot 1..999 steps forward
without paying attention to any signs.
Up and down movements also become
counted as steps.]]),
	check = function(steps)
		steps = tonumber(steps) or 1
		return steps > 0 and steps < 1000
	end,
	cmnd = function(base_pos, mem, steps)
		steps = tonumber(steps) or 1
		local res, idx = signs_bot.steps(mem, 1, steps)
		move(mem, scan_surrounding(mem))
		return res
	end,
})

signs_bot.register_botcommand("cond_move", {
	mod = "move",
	params = "",
	num_param = 0,
	description = S([[Walk until a sign or obstacle is
reached. Then continue with the next command.
When a sign has been reached,
the current program is ended
and the bot executes the
new program from the sign]]),
	cmnd = function(base_pos, mem)
		local any_sensor, sign_pos = scan_surrounding(mem)
		if not sign_pos then
			move(mem, any_sensor)
			return ci.BUSY
		else
			mem.script = M(sign_pos):get_string("signs_bot_cmnd").."\ncond_move"
			return ci.NEW
		end
	end,
})

signs_bot.register_botcommand("print", {
	mod = "debug",
	params = "<text>",
	num_param = 1,
	description = S([[Print given text as chat message.
For two or more words, use the '*' character
instead of spaces, like "Hello*world"]]),
	check = function(text)
		return text ~= ""
	end,
	cmnd = function(base_pos, mem, text)
		text = text:gsub("*", " ")
		local owner = M(base_pos):get_string("owner")
		if owner ~= "" and text ~= "" then
			minetest.chat_send_player(owner, "Bot: " .. text)
		end
		return signs_bot.DONE
	end,
})
