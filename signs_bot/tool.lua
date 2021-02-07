--[[

	Signs Bot
	=========

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Sensor/Actuator Connection Tool

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("signs_bot")
local I,_ = dofile(MP.."/intllib.lua")

local lib = signs_bot.lib

local function get_current_data(pointed_thing)
	local pos = pointed_thing.under
	local ntype = signs_bot.get_node_type(pos)
	return pos, ntype
end

local function get_stored_data(placer)
	local spos = placer:get_attribute("signs_bot_spos")
	local name = placer:get_attribute("signs_bot_name")
	if spos ~= "" then
		return minetest.string_to_pos(spos), name
	end
end
	
local function store_data(placer, pos, name)
	if pos then
		local spos = minetest.pos_to_string(pos)
		placer:set_attribute("signs_bot_spos", spos)
		placer:set_attribute("signs_bot_name", name)
	else
		placer:set_attribute("signs_bot_spos", nil)
		placer:set_attribute("signs_bot_name", nil)
	end
end

-- Write actuator_pos data to sensor_pos
local function pairing(actuator_pos, sensor_pos)
	local signal = signs_bot.get_signal(actuator_pos)
	if signal then
		signs_bot.store_signal(sensor_pos, actuator_pos, signal)
		local node = tubelib2.get_node_lvm(sensor_pos)
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.update_infotext then
			ndef.update_infotext(sensor_pos, actuator_pos, signal)
		end
	end
end

local function use_tool(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local pos1,ntype1 = get_stored_data(placer)
		local pos2,ntype2 = get_current_data(pointed_thing)
		
		if ntype1 == "actuator" and (ntype2 == "sensor" or ntype2 == "repeater") then
			pairing(pos1, pos2)
			store_data(placer, nil, nil)
			minetest.sound_play('signs_bot_pong', {to_player = placer:get_player_name()})
		elseif (ntype1 == "actuator" or ntype1 == "repeater") and ntype2 == "sensor" then
			pairing(pos1, pos2)
			store_data(placer, nil, nil)
			minetest.sound_play('signs_bot_pong', {to_player = placer:get_player_name()})
		elseif ntype2 == "actuator" and (ntype1 == "sensor" or ntype1 == "repeater") then
			pairing(pos2, pos1)
			store_data(placer, nil, nil)
			minetest.sound_play('signs_bot_pong', {to_player = placer:get_player_name()})
		elseif (ntype2 == "actuator" or ntype2 == "repeater") and ntype1 == "sensor" then
			pairing(pos2, pos1)
			store_data(placer, nil, nil)
			minetest.sound_play('signs_bot_pong', {to_player = placer:get_player_name()})
		elseif ntype2 == "actuator" or ntype2 == "sensor" or ntype2 == "repeater" then
			store_data(placer, pos2, ntype2)
			minetest.sound_play('signs_bot_ping', {to_player = placer:get_player_name()})
		else
			store_data(placer, nil, nil)
			minetest.sound_play('signs_bot_error', {to_player = placer:get_player_name()})
		end
		return
	end
end
			

minetest.register_node("signs_bot:connector", {
	description = I("Sensor Connection Tool"),
	inventory_image = "signs_bot_tool.png",
	wield_image = "signs_bot_tool.png",
	groups = {cracky=1, book=1},
	on_use = use_tool,
	on_place = use_tool,
	node_placement_prediction = "",
	stack_max = 1,
})

minetest.register_craft({
	output = "signs_bot:connector",
	recipe = {
		{"dye:yellow", "default:mese_crystal", "dye:yellow"},
		{"", "default:stick", ""},
		{"", "default:stick", ""}
	}
})
