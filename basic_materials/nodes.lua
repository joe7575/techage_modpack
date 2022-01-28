local S = minetest.get_translator("basic_materials")
local sound_api = dofile(basic_materials.modpath .. "/sound_api_core/init.lua")
local chains_sbox = {type = "fixed",fixed = { -0.1, -0.5, -0.1, 0.1, 0.5, 0.1 }}

minetest.register_node("basic_materials:cement_block", {
	description = S("Cement"),
	tiles = {"basic_materials_cement_block.png"},
	is_ground_content = true,
	groups = {cracky=2, dig_stone = 1},
	sounds = sound_api.node_sound_stone_defaults(),
})

minetest.register_node("basic_materials:concrete_block", {
	description = S("Concrete Block"),
	tiles = {"basic_materials_concrete_block.png",},
	groups = {cracky=1, concrete=1, dig_stone = 1},
	sounds = sound_api.node_sound_stone_defaults(),
})

minetest.register_node("basic_materials:chain_steel", {
	description = S("Chain (steel, hanging)"),
	drawtype = "mesh",
	mesh = "basic_materials_chains.obj",
	tiles = {"basic_materials_chain_steel.png"},
	walkable = false,
	climbable = true,
	sunlight_propagates = true,
	paramtype = "light",
	inventory_image = "basic_materials_chain_steel_inv.png",
	groups = {cracky=3, dig_stone = 1},
	selection_box = chains_sbox,
})

minetest.register_node("basic_materials:chain_brass", {
	description = S("Chain (brass, hanging)"),
	drawtype = "mesh",
	mesh = "basic_materials_chains.obj",
	tiles = {"basic_materials_chain_brass.png"},
	walkable = false,
	climbable = true,
	sunlight_propagates = true,
	paramtype = "light",
	inventory_image = "basic_materials_chain_brass_inv.png",
	groups = {cracky=3, dig_stone = 1},
	selection_box = chains_sbox,
})

minetest.register_node("basic_materials:brass_block", {
	description = S("Brass Block"),
	tiles = { "basic_materials_brass_block.png" },
	is_ground_content = false,
	groups = {cracky=1, dig_stone = 1},
	sounds = sound_api.node_sound_metal_defaults()
})
