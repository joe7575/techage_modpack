--[[

	TechPack Stairway
	=================

	Copyright (C) 2019-2020 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	init.lua

]]--
minetest.register_node("techpack_stairway:grating", {
	description = "TechPack Grating",
	tiles = {
		'techpack_stairway_bottom.png',
		'techpack_stairway_bottom.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-17/32, -15/32, -17/32,  17/32, -14/32, 17/32}
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{-16/32, -16/32, -16/32,  16/32, -10/32, 16/32},
		},
	},
	
	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techpack_stairway:handrail1", {
	description = "TechPack Handrail 1",
	tiles = {
		'techpack_stairway_bottom.png',
		'techpack_stairway_bottom.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-17/32, -17/32, -17/32, -15/32,  17/32, 17/32},
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{ -16/32, -16/32, -16/32, -12/32, -6/32, 16/32},
		},
	},
	
	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techpack_stairway:handrail2", {
	description = "TechPack Handrail 2",
	tiles = {
		'techpack_stairway_bottom.png',
		'techpack_stairway_bottom.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ 15/32, -17/32, -17/32,  17/32,  17/32, 17/32},
			{-17/32, -17/32, -17/32, -15/32,  17/32, 17/32},
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{ 12/32, -16/32, -16/32,  16/32,  -6/32, 16/32},
			{-16/32, -16/32, -16/32, -12/32,  -6/32, 16/32},
		},
	},
	
	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techpack_stairway:handrail3", {
	description = "TechPack Handrail 3",
	tiles = {
		'techpack_stairway_bottom.png',
		'techpack_stairway_bottom.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-17/32, -17/32,  15/32,  17/32,  17/32, 17/32},
			{-17/32, -17/32, -17/32, -15/32,  17/32, 17/32},
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{ -16/32, -16/32,  12/32,  16/32, -6/32, 16/32},
			{ -16/32, -16/32, -16/32, -12/32, -6/32, 16/32},
		},
	},
	
	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techpack_stairway:handrail4", {
	description = "TechPack Handrail 4",
	tiles = {
		'techpack_stairway_bottom.png',
		'techpack_stairway_bottom.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-17/32, -17/32,  15/32,  17/32,  17/32, 17/32},
			{ 15/32, -17/32, -17/32,  17/32,  17/32, 17/32},
			{-17/32, -17/32, -17/32, -15/32,  17/32, 17/32},
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{ 12/32, -16/32, -16/32,  16/32, -6/32, 16/32},
			{-16/32, -16/32, -16/32, -12/32, -6/32, 16/32},
			{-16/32, -16/32,  12/32,  16/32, -6/32, 16/32},
		},
	},
	
	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techpack_stairway:bridge1", {
	description = "TechPack Bridge 1",
	tiles = {
		'techpack_stairway_bottom.png',
		'techpack_stairway_bottom.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-17/32, -17/32, -17/32, -15/32,  17/32, 17/32},
			{-17/32, -15/32, -17/32,  17/32, -14/32, 17/32}
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{-16/32, -16/32, -16/32,  16/32, -10/32, 16/32},
		},
	},
	
	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techpack_stairway:bridge2", {
	description = "TechPack Bridge 2",
	tiles = {
		'techpack_stairway_bottom.png',
		'techpack_stairway_bottom.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ 15/32, -17/32, -17/32,  17/32,  17/32, 17/32},
			{-17/32, -17/32, -17/32, -15/32,  17/32, 17/32},
			{-17/32, -15/32, -17/32,  17/32, -14/32, 17/32}
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{-16/32, -16/32, -16/32,  16/32, -10/32, 16/32},
		},
	},
	
	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techpack_stairway:bridge3", {
	description = "TechPack Bridge 3",
	tiles = {
		'techpack_stairway_bottom.png',
		'techpack_stairway_bottom.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-17/32, -17/32,  15/32,  17/32,  17/32, 17/32},
			{-17/32, -17/32, -17/32, -15/32,  17/32, 17/32},
			{-17/32, -15/32, -17/32,  17/32, -14/32, 17/32}
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{-16/32, -16/32, -16/32,  16/32, -10/32, 16/32},
		},
	},
	
	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techpack_stairway:bridge4", {
	description = "TechPack Bridge 4",
	tiles = {
		'techpack_stairway_bottom.png',
		'techpack_stairway_bottom.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-17/32, -17/32,  15/32,  17/32,  17/32, 17/32},
			{ 15/32, -17/32, -17/32,  17/32,  17/32, 17/32},
			{-17/32, -17/32, -17/32, -15/32,  17/32, 17/32},
			{-17/32, -15/32, -17/32,  17/32, -14/32, 17/32}
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{-16/32, -16/32, -16/32,  16/32, -10/32, 16/32},
		},
	},
	
	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techpack_stairway:stairway", {
	description = "TechPack Stairway",
	tiles = {
		'techpack_stairway_steps.png',
		'techpack_stairway_steps.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ 15/32, -1/32,  -1/32,  17/32,  49/32, 17/32},
			{-17/32, -1/32,  -1/32, -15/32,  49/32, 17/32},
			{-17/32, -1/32,  -1/32,  17/32,   1/32, 17/32},
			
			{ 15/32, -17/32, -17/32,  17/32,  33/32, 1/32},
			{-17/32, -17/32, -17/32, -15/32,  33/32, 1/32},
			{-17/32, -17/32, -17/32,  17/32, -15/32, 1/32},
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{-16/32, -16/32, -16/32,  16/32, -10/32,  0/32},
			{-16/32, -16/32,   0/32,  16/32,   2/32, 16/32},
		},
	},
		
	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techpack_stairway:ladder1", {
	description = "TechPack Ladder 1",
	tiles = {
		'techpack_stairway_steps.png',
		'techpack_stairway_steps.png',
		'techpack_stairway_ladder.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-17/32, -17/32,  15/32,  17/32,  17/32,  17/32},
			{-17/32, -17/32, -17/32, -15/32,  17/32,  17/32},
			{-17/32, -17/32, -17/32,  17/32,  17/32, -15/32},
			{ 15/32, -17/32, -17/32,  17/32,  17/32,  17/32},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, -8/16,  8/16, 8/16, 8/16},
	},

	climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techpack_stairway:ladder2", {
	description = "TechPack Ladder 2",
	tiles = {
		'techpack_stairway_steps.png',
		'techpack_stairway_steps.png',
		'techpack_stairway_ladder.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-17/32, -17/32,  15/32,  17/32,  17/32,  17/32},
			{-17/32, -17/32, -17/32, -15/32,  17/32,  17/32},
			--{-17/32, -17/32, -17/32,  17/32,  17/32, -15/32},
			{ 15/32, -17/32, -17/32,  17/32,  17/32,  17/32},
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, -8/16,  8/16, 8/16, 8/16},
	},
	
	climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techpack_stairway:ladder3", {
    description = "TechPack Ladder 3",
    tiles = {
        'techpack_stairway_steps.png',
        'techpack_stairway_steps.png',
        'techpack_stairway_ladder.png',
    },
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {
            {-17/32, -17/32,  15/32,  17/32,  17/32,  17/32},
            --{-17/32, -17/32, -17/32, -15/32,  17/32,  17/32},
            --{-17/32, -17/32, -17/32,  17/32,  17/32, -15/32},
            { 15/32, -17/32, -17/32,  17/32,  17/32,  17/32},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-8/16, -8/16, -8/16,  8/16, 8/16, 8/16},
    },

    climbable = true,
    paramtype2 = "facedir",
    paramtype = "light",
    sunlight_propagates = true,
    is_ground_content = false,
    groups = {cracky = 2},
    sounds = default.node_sound_metal_defaults(),
})



minetest.register_node("techpack_stairway:ladder4", {
	description = "TechPack Ladder 4",
	tiles = {
		'techpack_stairway_ladder.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			--{-17/32, -17/32,  15/32,  17/32,  17/32,  17/32},
			--{-17/32, -17/32, -17/32, -15/32,  17/32,  17/32},
			--{-17/32, -17/32, -17/32,  17/32,  17/32, -15/32},
			{ 15/32, -17/32, -17/32,  17/32,  17/32,  17/32},
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, -8/16,  8/16, 8/16, 8/16},
	},
	
	climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
})


minetest.register_node("techpack_stairway:lattice", {
	description = "TechPack Lattice",
	tiles = {
		'techpack_stairway_lattice.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, -7/16,  8/16,  8/16},
			{ 7/16, -8/16, -8/16,  8/16,  8/16,  8/16},
			{-8/16, -8/16, -8/16,  8/16, -7/16,  8/16},
			{-8/16,  7/16, -8/16,  8/16,  8/16,  8/16},
			{-8/16, -8/16, -8/16,  8/16,  8/16, -7/16},
			{-8/16, -8/16,  7/16,  8/16,  8/16,  8/16},
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, -8/16,  8/16, 8/16, 8/16},
	},
	
	paramtype2 = "facedir",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
})


minetest.register_craft({
	output = "techpack_stairway:grating 4",
	recipe = {
		{"", "", ""},
		{"dye:dark_grey", "", "default:coal_lump"},
		{"default:steel_ingot", "default:tin_ingot", "default:steel_ingot"},
	},
})

minetest.register_craft({
	output = "techpack_stairway:handrail1 4",
	recipe = {
		{"default:steel_ingot", "default:coal_lump", ""},
		{"default:tin_ingot", "", ""},
		{"default:steel_ingot", "dye:dark_grey", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:stairway 2",
	recipe = {
		{"", "", "default:steel_ingot"},
		{"dye:dark_grey", "default:tin_ingot", "default:coal_lump"},
		{"default:steel_ingot", "", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:ladder1 2",
	recipe = {
		{"", "default:steel_ingot", ""},
		{"dye:dark_grey", "default:tin_ingot", "default:coal_lump"},
		{"", "default:steel_ingot", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:ladder3 4",
	recipe = {
		{"", "", "default:steel_ingot"},
		{"dye:dark_grey", "default:tin_ingot", "default:coal_lump"},
		{"", "", "default:steel_ingot"},
	},
})

minetest.register_craft({
	output = "techpack_stairway:lattice 2",
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"dye:dark_grey", "default:tin_ingot", "default:coal_lump"},
		{"default:steel_ingot", "", "default:steel_ingot"},
	},
})


minetest.register_craft({
	output = "techpack_stairway:handrail2",
	recipe = {
		{"", "", ""},
		{"techpack_stairway:handrail1", "", "techpack_stairway:handrail1"},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:handrail3",
	recipe = {
		{"", "techpack_stairway:handrail1", ""},
		{"techpack_stairway:handrail1", "", ""},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:handrail4",
	recipe = {
		{"", "techpack_stairway:handrail1", ""},
		{"techpack_stairway:handrail1", "", "techpack_stairway:handrail1"},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:bridge1",
	recipe = {
		{"", "", ""},
		{"techpack_stairway:handrail1", "techpack_stairway:grating", ""},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:bridge2",
	recipe = {
		{"", "", ""},
		{"techpack_stairway:handrail1", "techpack_stairway:grating", "techpack_stairway:handrail1"},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:bridge3",
	recipe = {
		{"", "techpack_stairway:handrail1", ""},
		{"techpack_stairway:handrail1", "techpack_stairway:grating", ""},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:bridge4",
	recipe = {
		{"", "techpack_stairway:handrail1", ""},
		{"techpack_stairway:handrail1", "techpack_stairway:grating", "techpack_stairway:handrail1"},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:ladder2",
	recipe = {{"techpack_stairway:ladder1"}},
})
