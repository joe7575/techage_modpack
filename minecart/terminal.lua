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

local function is_player_nearby(pos)
	for _, object in pairs(minetest.get_objects_inside_radius(pos, 6)) do
		if object:is_player() then
			return true
		end
	end
end

local function formspec(pos, text)
	text = minetest.formspec_escape(text)
	text = text:gsub("\n", ",")
	
	return "size[11,9]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;10.8,0.5;#c6e8ff]"..
		"label[4.5,-0.1;"..minetest.colorize( "#000000", S("Cart List")).."]"..
		"style_type[table,field;font=mono]"..
		"table[0,0.5;10.8,8.6;output;"..text..";200]"
end

minetest.register_node("minecart:terminal", {
	description = S("Cart Terminal"),
	inventory_image = "minecart_terminal_front.png",
	tiles = {
		"minecart_terminal_top.png",
		"minecart_terminal_top.png",
		"minecart_terminal_side.png",
		"minecart_terminal_side.png",
		"minecart_terminal_back.png",
		"minecart_terminal_front.png",
		},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, 0/16,  8/16, 8/16, 8/16},
		},
	},
	
	after_place_node = function(pos, placer)
		local meta = M(pos)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", formspec(pos, ""))
		minetest.get_node_timer(pos):start(2)
	end,
	
	on_timer = function(pos, elapsed)
		if is_player_nearby(pos) then
			local text = minecart.get_cart_list(pos, M(pos):get_string("owner"))
			M(pos):set_string("formspec", formspec(pos, text))
		end
		return true
	end,
	
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = minecart.CLIP,
	on_rotate = screwdriver.disallow,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2, level = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_craft({
	output = "minecart:terminal",
	recipe = {
		{"", "default:obsidian_glass", "default:steel_ingot"},
		{"", "default:obsidian_glass", "default:copper_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	},
})
