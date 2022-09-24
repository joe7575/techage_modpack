--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Sensor Extender
	(passive node, the Sensor detects the extender)
]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta

-- Load support for I18n.
local S = signs_bot.S

local function update_infotext(pos, dest_pos, cmnd)
	M(pos):set_string("infotext", S("Sensor Extender: Connected with").." "..P2S(dest_pos).." / "..cmnd)
end

minetest.register_node("signs_bot:sensor_extender", {
	description = S("Sensor Extender"),
	inventory_image = "signs_bot_extender_inv.png",
	drawtype = "nodebox",
	node_box = {
		type = "connected",
		fixed = {
			{-6/32, -1/2, -6/32, 6/32, -5/16, 6/32},
		},
		connect_front = {{-1/16, -1/2, -12/16, 1/16, -6/16, 1/16}},
		connect_left =  {{-12/16, -1/2, -1/16, 1/16, -6/16, 1/16}},
		connect_back =  {{-1/16, -1/2, -1/16,  1/16, -6/16, 12/16}},
		connect_right = {{-1/16, -1/2, -1/16, 12/16, -6/16, 1/16}},
	},
	connects_to = {"group:sign_bot_sensor"},
	tiles = {
		-- up, down, right, left, back, front
		"signs_bot_extender.png",
		"signs_bot_extender.png",
		"signs_bot_extender_side.png",
		"signs_bot_extender_side.png",
		"signs_bot_extender_side.png",
		"signs_bot_extender_side.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		meta:set_string("infotext", S("Sensor Extender: Not connected"))
	end,

	update_infotext = update_infotext,
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	use_texture_alpha = signs_bot.CLIP,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {sign_bot_sensor = 1, cracky = 1},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("signs_bot:sensor_extender_on", {
	description = S("Sensor Extender"),
	drawtype = "nodebox",
	node_box = {
		type = "connected",
		fixed = {
			{-6/32, -1/2, -6/32, 6/32, -5/16, 6/32},
		},
		connect_front = {{-1/16, -1/2, -12/16, 1/16, -6/16, 1/16}},
		connect_left =  {{-12/16, -1/2, -1/16, 1/16, -6/16, 1/16}},
		connect_back =  {{-1/16, -1/2, -1/16,  1/16, -6/16, 12/16}},
		connect_right = {{-1/16, -1/2, -1/16, 12/16, -6/16, 1/16}},
	},
	connects_to = {"group:sign_bot_sensor"},
	tiles = {
		-- up, down, right, left, back, front
		"signs_bot_extender_on.png",
		"signs_bot_extender.png",
		"signs_bot_extender_side.png",
		"signs_bot_extender_side.png",
		"signs_bot_extender_side.png",
		"signs_bot_extender_side.png",
	},

	-- Called from the Sensor beside
	after_place_node = function(pos)
		minetest.get_node_timer(pos):start(1)
		signs_bot.send_signal(pos)
		signs_bot.lib.activate_extender_nodes(pos)
	end,

	on_timer = function(pos)
		local node = tubelib2.get_node_lvm(pos)
		node.name = "signs_bot:sensor_extender"
		minetest.swap_node(pos, node)
		return false
	end,

	update_infotext = update_infotext,
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	use_texture_alpha = signs_bot.CLIP,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	is_ground_content = false,
	diggable = false,
	groups = {sign_bot_sensor = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_metal_defaults(),
})


minetest.register_craft({
	output = "signs_bot:sensor_extender",
	recipe = {
		{"group:wood", "dye:yellow"},
		{"default:mese_crystal_fragment", "default:steel_ingot"}
	}
})

if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "sensor_extender", {
		name = S("Sensor Extender"),
		data = {
			item = "signs_bot:sensor_extender",
			text = table.concat({
				S("With the Sensor Extender, sensor signals can be sent to more than one actuator."),
				S("Place one or more extender nearby the sensor and connect each extender"),
				S("with one further actuator by means of the Connection Tool."),
			}, "\n")
		},
	})
end

