--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Sensor/Actuator Connection Tool

]]--

-- Load support for I18n.
local S = signs_bot.S

local lib = signs_bot.lib

local function get_current_data(pointed_thing)
	local pos = pointed_thing.under
	local ntype = signs_bot.get_node_type(pos)
	return pos, ntype
end

local function get_stored_data(placer)
	local meta = placer:get_meta()
	local spos = meta:get_string("signs_bot_spos")
	local name = meta:get_string("signs_bot_name")
	if spos ~= "" then
		return minetest.string_to_pos(spos), name
	end
end

local function store_data(placer, pos, name)
	local meta = placer:get_meta()
	if pos then
		local spos = minetest.pos_to_string(pos)
		meta:set_string("signs_bot_spos", spos)
		meta:set_string("signs_bot_name", name)
	else
		meta:set_string("signs_bot_spos", "")
		meta:set_string("signs_bot_name", "")
	end
end

-- Write actuator_pos data to sensor_pos
local function pairing(actuator_pos, sensor_pos, invert)
	local signal = signs_bot.get_signal(actuator_pos)
	if invert then
		signal = ({on = "off", off = "on"})[signal]
	end
	
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
	local invert = false
	if placer:get_player_control().aux1 then
		invert = true
	end

	if pointed_thing.type == "node" then
		local pos1,ntype1 = get_stored_data(placer)
		local pos2,ntype2 = get_current_data(pointed_thing)

		if ntype1 == "actuator" and (ntype2 == "sensor" or ntype2 == "repeater") then
			pairing(pos1, pos2, invert)
			store_data(placer, nil, nil)
			minetest.sound_play('signs_bot_pong', {to_player = placer:get_player_name()})
		elseif (ntype1 == "actuator" or ntype1 == "repeater") and ntype2 == "sensor" then
			pairing(pos1, pos2, invert)
			store_data(placer, nil, nil)
			minetest.sound_play('signs_bot_pong', {to_player = placer:get_player_name()})
		elseif ntype2 == "actuator" and (ntype1 == "sensor" or ntype1 == "repeater") then
			pairing(pos2, pos1, invert)
			store_data(placer, nil, nil)
			minetest.sound_play('signs_bot_pong', {to_player = placer:get_player_name()})
		elseif (ntype2 == "actuator" or ntype2 == "repeater") and ntype1 == "sensor" then
			pairing(pos2, pos1, invert)
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
	description = S("Sensor Connection Tool"),
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
