--[[

	Hyperloop Mod
	=============

	Copyright (C) 2017 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	History:
	see init.lua

]]--

local Waypoints = {}

-- Load support for intllib.
local S = hyperloop.S
local NS = hyperloop.NS

minetest.register_node("hyperloop:waypoint", {
	description = S("Hyperloop Waypoint"),
	inventory_image = "hyperloop_waypoint_inv.png",
	tiles = {
		"hyperloop_waypoint.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -4/16, -8/16, -4/16,  4/16,  -7/16, 4/16},
		},
	},
	
	after_place_node = function(pos, placer)
		local name = placer:get_player_name()
		if Waypoints[name] then
			placer:hud_remove(Waypoints[name])
			Waypoints[name] = nil
		end
		Waypoints[name] = placer:hud_add({
			hud_elem_type = "waypoint",
			number = 0x99d8d9,
			name = "Hyperloop",
			text = "m",
			world_pos = pos
		})	
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local name = digger:get_player_name()
		if Waypoints[name] then
			digger:hud_remove(Waypoints[name])
			Waypoints[name] = nil
		end
	end,

	on_rotate = screwdriver.disallow,	
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,	
	sunlight_propagates = true,
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
	stack_max = 1,
})
