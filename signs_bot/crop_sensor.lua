--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Crop Sensor

]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta

-- Load support for I18n.
local S = signs_bot.S

local lib = signs_bot.lib

local CYCLE_TIME = 4

local function update_infotext(pos, dest_pos, dest_idx)
	M(pos):set_string("infotext", S("Crop Sensor: Connected with").." "..P2S(dest_pos).." / "..dest_idx)
end

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return false
	end
	if string.sub(node.name, 1,21) == "signs_bot:crop_sensor" then
		node.name = name
		minetest.swap_node(pos, node)
		return true
	end
	return false
end

local function node_timer(pos)
	local pos1 = lib.next_pos(pos, M(pos):get_int("param2"))
	local node = minetest.get_node_or_nil(pos1)
	if node and signs_bot.FarmingCrop[node.name] then
		if swap_node(pos, "signs_bot:crop_sensor_on") then
			signs_bot.send_signal(pos)
			signs_bot.lib.activate_extender_nodes(pos, true)
			minetest.after(1, swap_node, pos, "signs_bot:crop_sensor")
		end
	end
	return true
end

minetest.register_node("signs_bot:crop_sensor", {
	description = S("Crop Sensor"),
	inventory_image = "signs_bot_sensor_crop_inv.png",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -11/32, -1/2, -11/32, 11/32, -5/16, 11/32},
		},
	},
	tiles = {
		-- up, down, right, left, back, front
		"signs_bot_sensor1.png^signs_bot_sensor_crop.png",
		"signs_bot_sensor1.png",
		"signs_bot_sensor1.png^[transformFXR90",
		"signs_bot_sensor1.png^[transformFXR90",
		"signs_bot_sensor1.png^[transformFXR90",
		"signs_bot_sensor1.png^[transformFXR180",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		meta:set_string("infotext", S("Crop Sensor: Not connected"))
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		local node = minetest.get_node(pos)
		meta:set_int("param2", (node.param2 + 2) % 4)
	end,

	on_timer = node_timer,
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

minetest.register_node("signs_bot:crop_sensor_on", {
	description = S("Crop Sensor"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -11/32, -1/2, -11/32, 11/32, -5/16, 11/32},
		},
	},
	tiles = {
		-- up, down, right, left, back, front
		"signs_bot_sensor1.png^signs_bot_sensor_crop_on.png",
		"signs_bot_sensor1.png",
		"signs_bot_sensor1.png^[transformFXR90",
		"signs_bot_sensor1.png^[transformFXR90",
		"signs_bot_sensor1.png^[transformFXR90",
		"signs_bot_sensor1.png^[transformFXR180",
	},

	on_timer = node_timer,
	update_infotext = update_infotext,
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	use_texture_alpha = signs_bot.CLIP,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	is_ground_content = false,
	drop = "signs_bot:crop_sensor",
	groups = {sign_bot_sensor = 1, cracky = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_craft({
	output = "signs_bot:crop_sensor",
	recipe = {
		{"", "", ""},
		{"dye:black", "group:stone", "dye:yellow"},
		{"default:steel_ingot", "default:mese_crystal_fragment", "default:steel_ingot"}
	}
})

minetest.register_lbm({
	label = "[signs_bot] Restart timer",
	name = "signs_bot:crop_sensor_restart",
	nodenames = {"signs_bot:crop_sensor", "signs_bot:crop_sensor_on"},
	run_at_every_load = true,
	action = function(pos, node)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		if node.name == "signs_bot:crop_sensor_on" then
			signs_bot.send_signal(pos)
			signs_bot.lib.activate_extender_nodes(pos, true)
		end
	end
})

if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "crop_sensor", {
		name = S("Crop Sensor"),
		data = {
			item = "signs_bot:crop_sensor",
			text = table.concat({
				S("The Crop Sensor sends cyclical signals when, for example, wheat is fully grown."),
				S("The sensor range is one node/meter."),
				S("The sensor has an active side (red) that must point to the crop/field."),

			}, "\n")
		},
	})
end
