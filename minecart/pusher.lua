--[[

	Minecart
	========

	Copyright (C) 2019-2021 Joachim Stolberg

	MIT
	See license.txt for more information

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = minecart.S
local CYCLE_TIME = 4

local function node_timer(pos)
	local node = minetest.get_node(pos)
	local dir = minetest.facedir_to_dir(node.param2)
	minecart.punch_cart({x = pos.x, y = pos.y + 1, z = pos.z}, nil, 1, dir)
	return true
end


local function after_dig_node(pos, oldnode, oldmetadata, digger)
	techage.remove_node(pos, oldnode, oldmetadata)
end

minetest.register_node("minecart:cart_pusher", {
	description = S("Cart Pusher"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16,-8/16,-8/16,  8/16,  8/16, 8/16},
			{-1/16, 8/16,-4/16,  1/16, 10/16, 4/16},
		},
	},
	tiles = {
		-- up, down, right, left, back, front
		"default_steel_block.png^minecart_pusher_top.png",
		"default_steel_block.png",
		"default_steel_block.png^minecart_pusher.png",
		"default_steel_block.png^minecart_pusher.png",
		"default_steel_block.png^minecart_pusher.png",
		"default_steel_block.png^minecart_pusher.png",
	},
	after_place_node = function(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,

	on_timer = node_timer,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = true,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_craft({
	output = "minecart:cart_pusher",
	recipe = {
		{"dye:black", "default:steel_ingot", "dye:yellow"},
		{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	},
})
