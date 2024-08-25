--[[

	Hyperloop Mod
	=============

	Copyright (C) 2017 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	History:
	see init.lua

]]--

-- Load support for intllib.
local S = hyperloop.S

local tilesL = {"hyperloop_alpsL.png", "hyperloop_seaL.png", "hyperloop_agyptL.png"}
local tilesR = {"hyperloop_alpsR.png", "hyperloop_seaR.png", "hyperloop_agyptR.png"}

-- determine facedir and pos on the right hand side from the given pos
local function right_hand_side(pos, placer)
	local facedir = hyperloop.get_facedir(placer)
	pos = hyperloop.new_pos(pos, facedir, "1R", 0)
	return facedir,pos
end

for idx = 1,3 do

	minetest.register_node("hyperloop:poster"..idx.."L", {
		description = S("Hyperloop Promo Poster ")..idx,
		tiles = {
			-- up, down, right, left, back, front
			"hyperloop_skin2.png",
			"hyperloop_skin2.png",
			"hyperloop_skin2.png",
			"hyperloop_skin2.png",
			"hyperloop_skin2.png",
			tilesL[idx],
		},
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{ -8/16, -8/16, -6/16,  8/16,  8/16, 8/16},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = { -8/16, -8/16, -6/16,  24/16,  8/16, 8/16},
		},

		after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos)
			local facedir
			facedir, pos = right_hand_side(pos, placer)
			meta:set_string("pos", minetest.pos_to_string(pos))
			if minetest.get_node_or_nil(pos).name == "air" then
				minetest.add_node(pos, {name="hyperloop:poster"..idx.."R", param2=facedir})
			end
		end,

		on_destruct = function(pos)
			local meta = minetest.get_meta(pos)
			pos = minetest.string_to_pos(meta:get_string("pos"))
			if pos ~= nil and minetest.get_node_or_nil(pos).name == "hyperloop:poster"..idx.."R" then
				minetest.remove_node(pos)
			end
		end,


		paramtype2 = "facedir",
		light_source = 4,
		is_ground_content = false,
		groups = {cracky = 2, stone = 2},
	})

	minetest.register_node("hyperloop:poster"..idx.."R", {
		description = S("Hyperloop Promo Poster ")..idx,
		tiles = {
			-- up, down, right, left, back, front
			"hyperloop_skin2.png",
			"hyperloop_skin2.png",
			"hyperloop_skin2.png",
			"hyperloop_skin2.png",
			"hyperloop_skin2.png",
			tilesR[idx],
		},
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{ -8/16, -8/16, -6/16,  8/16,  8/16, 8/16},
			},
		},
		paramtype2 = "facedir",
		light_source = 4,
		is_ground_content = false,
		groups = {cracky = 2, stone = 2, not_in_creative_inventory=1},
	})
end


minetest.register_node("hyperloop:sign", {
	description = S("Hyperloop Station Sign"),
	tiles = {
		-- up, down, right, left, back, front
		"hyperloop_sign_top.png",
		"hyperloop_sign.png",
	},
	light_source = 4,
	is_ground_content = false,
	groups = {cracky = 2, stone = 2},
})

minetest.register_node("hyperloop:signR", {
	description = S("Hyperloop Station Sign Right"),
	tiles = {
		-- up, down, right, left, back, front
		"hyperloop_sign3.png^[transformR90]",
		"hyperloop_sign3.png^[transformR90]",
		"hyperloop_sign3.png",
		"hyperloop_sign3.png",
		"hyperloop_sign2.png^[transformFX",
		"hyperloop_sign2.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -5/16, 6/16,  8/16,  5/16, 8/16},
		},
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		pos.y = pos.y - 1
		if minetest.get_node_or_nil(pos).name ~= "air" then
			local node = minetest.get_node(pos)
			node.name = "hyperloop:signR_ground"
			node.param2 = hyperloop.get_facedir(placer)
			pos.y = pos.y + 1
			minetest.swap_node(pos, node)
		end
	end,

	paramtype2 = "facedir",
	paramtype = 'light',
	light_source = 4,
	is_ground_content = false,
	groups = {cracky = 2, stone = 2},
})

minetest.register_node("hyperloop:signL", {
	description = S("Hyperloop Station Sign Left"),
	tiles = {
		-- up, down, right, left, back, front
		"hyperloop_sign3.png^[transformR90]",
		"hyperloop_sign3.png^[transformR90]",
		"hyperloop_sign3.png",
		"hyperloop_sign3.png",
		"hyperloop_sign2.png",
		"hyperloop_sign2.png^[transformFX",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -5/16, 6/16,  8/16,  5/16, 8/16},
		},
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		pos.y = pos.y - 1
		if minetest.get_node_or_nil(pos).name ~= "air" then
			local node = minetest.get_node(pos)
			node.name = "hyperloop:signL_ground"
			node.param2 = hyperloop.get_facedir(placer)
			pos.y = pos.y + 1
			minetest.swap_node(pos, node)
		end
	end,

	paramtype2 = "facedir",
	paramtype = 'light',
	light_source = 4,
	is_ground_content = false,
	groups = {cracky = 2, stone = 2},
})

minetest.register_node("hyperloop:signR_ground", {
	description = S("Hyperloop Station Sign Right"),
	tiles = {
		-- up, down, right, left, back, front
		"hyperloop_sign3.png^[transformR90]",
		"hyperloop_sign3.png^[transformR90]",
		"hyperloop_sign3.png",
		"hyperloop_sign3.png",
		"hyperloop_sign2_ground.png^[transformFX",
		"hyperloop_sign2_ground.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, -1/16,  8/16,  2/16, 1/16},
		},
	},
	paramtype2 = "facedir",
	drop = "hyperloop:signR",
	paramtype = 'light',
	light_source = 4,
	is_ground_content = false,
	groups = {cracky = 2, stone = 2, not_in_creative_inventory=1},
})

minetest.register_node("hyperloop:signL_ground", {
	description = S("Hyperloop Station Sign Left"),
	tiles = {
		-- up, down, right, left, back, front
		"hyperloop_sign3.png^[transformR90]",
		"hyperloop_sign3.png^[transformR90]",
		"hyperloop_sign3.png",
		"hyperloop_sign3.png",
		"hyperloop_sign2_ground.png",
		"hyperloop_sign2_ground.png^[transformFX",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, -1/16,  8/16,  2/16, 1/16},
		},
	},
	paramtype2 = "facedir",
	drop = "hyperloop:signL",
	paramtype = 'light',
	light_source = 4,
	is_ground_content = false,
	groups = {cracky = 2, stone = 2, not_in_creative_inventory=1},
})
