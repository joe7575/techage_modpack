--[[

	Signs Bot
	=========

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Bot Sensor
	(passive node, the Bot detects the sensor and sends the signal)
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("signs_bot")
local I,_ = dofile(MP.."/intllib.lua")

local lib = signs_bot.lib

local function update_infotext(pos, dest_pos, cmnd)
	M(pos):set_string("infotext", I("Bot Sensor: Connected with ")..S(dest_pos).." / "..cmnd)
end	

minetest.register_node("signs_bot:bot_sensor", {
	description = I("Bot Sensor"),
	inventory_image = "signs_bot_sensor_bot_inv.png",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -11/32, -1/2, -11/32, 11/32, -5/16, 11/32},
		},
	},
	tiles = {
		-- up, down, right, left, back, front
		"signs_bot_sensor2.png^signs_bot_sensor_bot.png",
		"signs_bot_sensor2.png",
		"signs_bot_sensor2.png",
		"signs_bot_sensor2.png",
		"signs_bot_sensor2.png",
		"signs_bot_sensor2.png",
	},
	
	after_place_node = function(pos, placer)
		local meta = M(pos)
		meta:set_string("infotext", I("Bot Sensor: Not connected"))
	end,
	
	update_infotext = update_infotext,
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {sign_bot_sensor = 1, cracky = 1},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("signs_bot:bot_sensor_on", {
	description = I("Bot Sensor"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -11/32, -1/2, -11/32, 11/32, -5/16, 11/32},
		},
	},
	tiles = {
		-- up, down, right, left, back, front
		"signs_bot_sensor2.png^signs_bot_sensor_bot_on.png",
		"signs_bot_sensor2.png",
		"signs_bot_sensor2.png",
		"signs_bot_sensor2.png",
		"signs_bot_sensor2.png",
		"signs_bot_sensor2.png",
	},
	
	-- Called from the Bot
	after_place_node = function(pos)
		minetest.get_node_timer(pos):start(1)
		signs_bot.send_signal(pos)
		signs_bot.lib.activate_extender_nodes(pos, true)
	end,
		
	on_timer = function(pos)
		local node = lib.get_node_lvm(pos)
		node.name = "signs_bot:bot_sensor"
		minetest.swap_node(pos, node)
		return false
	end,
	
	update_infotext = update_infotext,
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	is_ground_content = false,
	diggable = false,
	groups = {sign_bot_sensor = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_metal_defaults(),
})


minetest.register_craft({
	output = "signs_bot:bot_sensor",
	recipe = {
		{"", "", ""},
		{"dye:black", "group:wood", "dye:yellow"},
		{"default:steel_ingot", "default:mese_crystal_fragment", "default:steel_ingot"}
	}
})

if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "bot_sensor", {
		name = I("Bot Sensor"),
		data = {
			item = "signs_bot:bot_sensor",
			text = table.concat({
				I("The Bot Sensor detects any bot and sends a signal, if a bot is nearby."),
				I("the sensor range is one node/meter."), 
				I("The sensor direction does not care."),
			}, "\n")		
		},
	})
end
