--[[

	Signs Bot
	=========

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Bot move commands

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("signs_bot")
local I,_ = dofile(MP.."/intllib.lua")

local lib = signs_bot.lib
local get_node_lvm = tubelib2.get_node_lvm


local function node_and_pos(pos)
	return get_node_lvm(pos), pos
end

-- Positions to check:
--   5 6  
--  [R]1  
--   3 2
--   4 
function signs_bot.move_robot(mem)
	local param2 = mem.robot_param2
	local pos = mem.robot_pos
	local node1, pos1 = node_and_pos(lib.next_pos(pos, param2))
	local node2, pos2 = node_and_pos({x=pos1.x, y=pos1.y-1, z=pos1.z})
	local node3, pos3 = node_and_pos({x=pos.x, y=pos.y-1, z=pos.z})
	
	--
	-- One step forward (pos1)
	--
	if lib.check_pos(pos1, node1, node2, param2) or
			lib.check_pos(pos1, node1, node3, param2) then
		if node3.name == "signs_bot:robot_foot" then
			minetest.swap_node(pos3, mem.stored_node or {name = "air"})
			minetest.remove_node(pos)
		elseif node3.name == "signs_bot:robot_leg" then
			local node4, pos4 = node_and_pos({x=pos.x, y=pos.y-2, z=pos.z})
			if node4.name == "signs_bot:robot_foot" then
				minetest.swap_node(pos4, mem.stored_node or {name = "air"})
			end
			minetest.remove_node(pos)
		else
			minetest.swap_node(pos, mem.stored_node or {name = "air"})
		end
		mem.stored_node = node1
		minetest.set_node(pos1, {name="signs_bot:robot", param2=param2})
		minetest.sound_play('signs_bot_step', {pos = pos1})
		return pos1
	end
	
	--
	-- One step up (pos5)
	--
	local node6, pos6 = node_and_pos({x=pos1.x, y=pos1.y+1, z=pos1.z})
	if lib.check_pos(pos6, node6, node1, param2) then
		local node5, pos5 = node_and_pos({x=pos.x, y=pos.y+1, z=pos.z})
		if node5.name == "air" then 
			if node3.name == "signs_bot:robot_leg" then 
				return nil
			elseif node3.name == "signs_bot:robot_foot" then 
				minetest.swap_node(pos3, {name="signs_bot:robot_leg"})
			else
				minetest.swap_node(pos, {name="signs_bot:robot_foot"})
			end
			minetest.set_node(pos5, {name="signs_bot:robot", param2=param2})
			minetest.sound_play('signs_bot_step', {pos = pos5})
			return pos5
		end
	end
	
	--
	-- One step down I (pos3)
	--
	local node4, pos4 = node_and_pos({x=pos.x, y=pos.y-2, z=pos.z})
	if lib.check_pos(pos3, node3, node4, param2) then  -- 
		minetest.remove_node(pos)
		minetest.set_node(pos3, {name="signs_bot:robot", param2=param2})
		minetest.sound_play('signs_bot_step', {pos = pos3})
		mem.stored_node = node3
		return pos3
	end
	--
	-- One step down II (pos3)
	--
	if node3.name == "signs_bot:robot_foot" or node3.name == "signs_bot:robot_leg" then
		minetest.remove_node(pos)
		minetest.set_node(pos3, {name="signs_bot:robot", param2=param2})
		minetest.sound_play('signs_bot_step', {pos = pos3})
		return pos3
	end
end	
	

local function backward_robot(mem)
	local param2 = mem.robot_param2
	local pos = mem.robot_pos
	local node1, pos1 = node_and_pos(lib.next_pos(pos, (param2 + 2) % 4))
	local node2, pos2 = node_and_pos({x=pos1.x, y=pos1.y-1, z=pos1.z})
	local node3, pos3 = node_and_pos({x=pos.x, y=pos.y-1, z=pos.z})
	local node4, pos4 = node_and_pos({x=pos.x, y=pos.y-2, z=pos.z})
	local new_pos = nil
	
	if lib.check_pos(pos1, node1, node2, param2) then
		if node3.name == "signs_bot:robot_foot" or node3.name == "signs_bot:robot_leg" then
			minetest.remove_node(pos3)
			if node4.name == "signs_bot:robot_foot" then
				minetest.remove_node(pos4)
			end
		end
		minetest.swap_node(pos, mem.stored_node or {name = "air"})
		minetest.set_node(pos1, {name="signs_bot:robot", param2=param2})
		minetest.sound_play('signs_bot_step', {pos = pos1})
		mem.stored_node = node1
		return pos1
	end
end	

signs_bot.register_botcommand("backward", {
	mod = "move",
	params = "",
	num_param = 0,
	description = I("Move the robot one step back"),
	cmnd = function(base_pos, mem)
		local new_pos = backward_robot(mem)
		if new_pos then  -- not blocked?
			mem.robot_pos = new_pos
		end
		return signs_bot.DONE
	end,
})

local function turn_robot(pos, param2, dir)
	if dir == "R" then
		param2 = (param2 + 1) % 4
	else
		param2 = (param2 + 3) % 4
	end
	minetest.swap_node(pos, {name="signs_bot:robot", param2=param2})
	minetest.sound_play('signs_bot_step', {pos = pos, gain = 0.6})
	return param2
end	

signs_bot.register_botcommand("turn_left", {
	mod = "move",
	params = "",
	num_param = 0,
	description = I("Turn the robot to the left"),
	cmnd = function(base_pos, mem)
		mem.robot_param2 = turn_robot(mem.robot_pos, mem.robot_param2, "L")
		return signs_bot.DONE
	end,
})

signs_bot.register_botcommand("turn_right", {
	mod = "move",
	params = "",
	num_param = 0,
	description = I("Turn the robot to the right"),
	cmnd = function(base_pos, mem)
		mem.robot_param2 = turn_robot(mem.robot_pos, mem.robot_param2, "R")
		return signs_bot.DONE
	end,
})

signs_bot.register_botcommand("turn_around", {
	mod = "move",
	params = "",
	num_param = 0,
	description = I("Turn the robot around"),
	cmnd = function(base_pos, mem)
		mem.robot_param2 = turn_robot(mem.robot_pos, mem.robot_param2, "R")
		mem.robot_param2 = turn_robot(mem.robot_pos, mem.robot_param2, "R")
		return signs_bot.DONE
	end,
})


-- Positions to check:
--   1
--  [R]  
--   2
local function robot_up(pos, param2)
	local node1, pos1 = node_and_pos({x=pos.x, y=pos.y+1, z=pos.z})
	local node2, pos2 = node_and_pos({x=pos.x, y=pos.y-1, z=pos.z})
	if lib.check_pos(pos1, node1, node2, param2) then
		if node2.name == "signs_bot:robot_leg" then 
			return nil
		elseif node2.name == "signs_bot:robot_foot" then 
			minetest.swap_node(pos, {name="signs_bot:robot_leg"})
		else
			minetest.swap_node(pos, {name="signs_bot:robot_foot"})
		end
		minetest.set_node(pos1, {name="signs_bot:robot", param2=param2})
		minetest.sound_play('signs_bot_step', {pos = pos1})
		return pos1
	end
	return nil
end	

signs_bot.register_botcommand("move_up", {
	mod = "move",
	params = "",
	num_param = 0,
	description = I("Move the robot upwards"),
	cmnd = function(base_pos, mem)
		local new_pos = robot_up(mem.robot_pos, mem.robot_param2)
		if new_pos then  -- not blocked?
			mem.robot_pos = new_pos
		end
		return signs_bot.DONE
	end,
})

-- Positions to check:
--  [R]  
--   1
--   2
--   3
local function robot_down(pos, param2)
	local node1, pos1 = node_and_pos({x=pos.x, y=pos.y-1, z=pos.z})
	local node2, pos2 = node_and_pos({x=pos.x, y=pos.y-2, z=pos.z})
	local node3, pos3 = node_and_pos({x=pos.x, y=pos.y-3, z=pos.z})
	if lib.check_pos(pos1, node1, node2, param2) 
	or (node1.name == "air" and lib.check_pos(pos2, node2, node3, param2))
	or (node1.name == "signs_bot:robot_leg" or node1.name == "signs_bot:robot_foot") then
		minetest.remove_node(pos)
		minetest.set_node(pos1, {name="signs_bot:robot", param2=param2})
		minetest.sound_play('signs_bot_step', {pos = pos1})
		return pos1
	end
	return nil
end	

signs_bot.register_botcommand("move_down", {
	mod = "move",
	params = "",
	num_param = 0,
	description = I("Move the robot down"),
	cmnd = function(base_pos, mem)
		local new_pos = robot_down(mem.robot_pos, mem.robot_param2)
		if new_pos then  -- not blocked?
			mem.robot_pos = new_pos
		end
		return signs_bot.DONE
	end,
})

signs_bot.register_botcommand("pause", {
	mod = "move",
	params = "<sec>",
	num_param = 1,
	description = I("Stop the robot for <sec> seconds\n(1..9999)"),
	check = function(sec)
		sec = tonumber(sec) or 1
		return sec and sec > 0 and sec < 10000
	end,
	cmnd = function(base_pos, mem, sec)
		if not mem.steps then
			mem.steps = tonumber(sec or 1)
		end
		mem.steps = mem.steps - 1
		if mem.steps == 0 then
			mem.steps = nil
			return signs_bot.DONE
		end
		if mem.capa then
			mem.capa = mem.capa + 1
		end
		return signs_bot.BUSY
	end,
})

signs_bot.register_botcommand("stop", {
	mod = "move",
	params = "",
	num_param = 0,
	description = I("Stop the robot."),
	cmnd = function(base_pos, mem, slot)
		if mem.capa then
			mem.capa = mem.capa + 2
		end
		return signs_bot.DONE
	end,
})

signs_bot.register_botcommand("turn_off", {
	mod = "move",
	params = "",
	num_param = 0,
	description = I("Turn the robot off\n"..
		"and put it back in the box."),
	cmnd = function(base_pos, mem)
		signs_bot.stop_robot(base_pos, mem)
		return signs_bot.TURN_OFF
	end,
})

	
	
