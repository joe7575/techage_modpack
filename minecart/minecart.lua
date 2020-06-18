--[[

	Minecart
	========

	Copyright (C) 2019-2020 Joachim Stolberg

	MIT
	See license.txt for more information
	
]]--

local S = minecart.S
local MP = minetest.get_modpath("minecart")
local lib = dofile(MP.."/cart_lib1.lua")

lib:init(false)

local cart_entity = {
	initial_properties = {
		physical = false, -- otherwise going uphill breaks
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		visual = "mesh",
		mesh = "carts_cart.b3d",
		visual_size = {x=1, y=1},
		textures = {"carts_cart.png^minecart_cart.png"},
		static_save = false,
	},
    ------------------------------------ changed
	owner = nil,
	------------------------------------ changed
	driver = nil,
	punched = false, -- used to re-send velocity and position
	velocity = {x=0, y=0, z=0}, -- only used on punch
	old_dir = {x=1, y=0, z=0}, -- random value to start the cart on punch
	old_pos = nil,
	old_switch = 0,
	railtype = nil,
	cargo = {},
	on_rightclick = lib.on_rightclick,
	on_activate = lib.on_activate,
	on_detach_child = lib.on_detach_child,
	on_punch = lib.on_punch,
	on_step = lib.on_step,
}


minetest.register_entity("minecart:cart", cart_entity)

minecart.register_cart_names("minecart:cart", "minecart:cart")


minetest.register_craftitem("minecart:cart", {
	description = S("Minecart (Sneak+Click to pick up)"),
	inventory_image = minetest.inventorycube("carts_cart_top.png", "carts_cart_side.png^minecart_logo.png", "carts_cart_side.png^minecart_logo.png"),
	wield_image = "carts_cart_side.png",
	on_place = function(itemstack, placer, pointed_thing)
		-- use cart as tool
		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local udef = minetest.registered_nodes[node.name]
		if udef and udef.on_rightclick and
				not (placer and placer:is_player() and
				placer:get_player_control().sneak) then
			return udef.on_rightclick(under, node, placer, itemstack,
				pointed_thing) or itemstack
		end

		if not pointed_thing.type == "node" then
			return
		end
		
		return lib.add_cart(itemstack, placer, pointed_thing, "minecart:cart")
	end,
})

minetest.register_craft({
	output = "minecart:cart",
	recipe = {
		{"default:steel_ingot", "default:cobble", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	},
})

