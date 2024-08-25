--[[

	Hyperloop Mod
	=============

	Copyright (C) 2017-2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

]]--

-- for lazy programmers
--local SP = function(pos) if pos then return minetest.pos_to_string(pos) end end
--local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local S = hyperloop.S

local Tube = hyperloop.Tube
local Stations = hyperloop.Stations


Tube:register_on_tube_update(function(node, pos, out_dir, peer_pos, peer_in_dir)
	if node.name == "hyperloop:station" then
		if out_dir <= 5 then
			Stations:update_connections(pos, out_dir, peer_pos)
			local s = hyperloop.get_connection_string(pos)
			M(pos):set_string("infotext", S("Station connected to ")..s)
		end
	elseif node.name == "hyperloop:junction" then
		Stations:update_connections(pos, out_dir, peer_pos)
		local s = hyperloop.get_connection_string(pos)
		M(pos):set_string("infotext", S("Junction connected to ")..s)
	elseif Tube.secondary_node_names[node.name] then
		if out_dir == 5 then
			Stations:update_connections(pos, out_dir, peer_pos)
			local s = hyperloop.get_connection_string(pos)
			M(pos):set_string("conn_to", s)
		end
	end
end)

minetest.register_node("hyperloop:junction", {
	description = S("Hyperloop Junction Block"),
	tiles = {
		"hyperloop_junction_top.png",
		"hyperloop_junction_top.png",
		"hyperloop_station_connection.png",
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		hyperloop.check_network_level(pos, placer)
		M(pos):set_string("infotext", S("Junction"))
		Stations:set(pos, "Junction", {
				owner = placer:get_player_name(), junction = true})
		Tube:after_place_node(pos)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Tube:after_dig_node(pos)
		Stations:delete(pos)
	end,

	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	sunlight_propagates = true,
	groups = {cracky = 1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

-- for tube viaducts
minetest.register_node("hyperloop:pillar", {
	description = S("Hyperloop Pillar"),
	tiles = {"hyperloop_tube_locked.png^[transformR90]"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -3/8, -4/8, -3/8,   3/8, 4/8, 3/8},
		},
	},
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2, stone = 2},
	sounds = default.node_sound_metal_defaults(),
})
