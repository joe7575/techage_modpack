--[[

	Minecart
	========

	Copyright (C) 2019-2021 Joachim Stolberg 4

	MIT
	See license.txt for more information

]]--

local S = minecart.S


local function register_sign(def)
	minetest.register_node("minecart:"..def.name, {
		description = def.description,
		inventory_image = def.image,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{ -1/16, -8/16, -1/16,   1/16,-2/16, 1/16},
				{ -5/16, -2/16, -1/32,   5/16, 8/16, 1/32},
			},
		},
		paramtype2 = "facedir",
		tiles = {
			"default_steel_block.png",
			"default_steel_block.png",
			"default_steel_block.png",
			"default_steel_block.png",
			"default_steel_block.png",
			"default_steel_block.png^"..def.image,
		},

		after_place_node = minecart.delete_signs_waypoint,
		preserve_metadata = minecart.delete_signs_waypoint,

		on_rotate = screwdriver.disallow,
		paramtype = "light",
		use_texture_alpha = minecart.CLIP,
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, minecart_sign = 1},
		sounds = default.node_sound_wood_defaults(),
	})
end

register_sign({
	name = "speed1",
	description = S('Speed "1"'),
	image = "minecart_sign1.png",
})

register_sign({
	name = "speed2",
	description = S('Speed "2"'),
	image = "minecart_sign2.png",
})

register_sign({
	name = "speed4",
	description = S('Speed "4"'),
	image = "minecart_sign4.png",
})

register_sign({
	name = "speed8",
	description = S('No speed limit'),
	image = "minecart_sign8.png",
})

minetest.register_craft({
	output = "minecart:speed8 8",
	recipe = {
		{"default:tin_ingot", "dye:red", "default:tin_ingot"},
		{"", "default:steel_ingot", ""},
		{"", "default:steel_ingot", ""}
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "minecart:speed4",
	recipe = {"minecart:speed8"}
})

minetest.register_craft({
	type = "shapeless",
	output = "minecart:speed2",
	recipe = {"minecart:speed4"}
})

minetest.register_craft({
	type = "shapeless",
	output = "minecart:speed1",
	recipe = {"minecart:speed2"}
})

minetest.register_craft({
	type = "shapeless",
	output = "minecart:speed8",
	recipe = {"minecart:speed1"}
})

