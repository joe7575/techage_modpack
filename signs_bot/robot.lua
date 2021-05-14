--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Signs Bot: The Robot itself

]]--

local lib = signs_bot.lib

-- Called when robot is started
function signs_bot.place_robot(pos1, pos2, param2)	
	local node1 = tubelib2.get_node_lvm(pos1)
	local node2 = tubelib2.get_node_lvm(pos2)
	if lib.check_pos(pos1, node1, node2, param2) then
		minetest.set_node(pos1, {name = "signs_bot:robot", param2 = param2})
	end
end

-- Called when robot is removed
function signs_bot.remove_robot(mem)	
	local pos = mem.robot_pos
	local node = tubelib2.get_node_lvm(pos)
	if node.name == "signs_bot:robot" then
		minetest.remove_node(pos)
		local pos1 = {x=pos.x, y=pos.y-1, z=pos.z}
		node = tubelib2.get_node_lvm(pos1)
		if node.name == "signs_bot:robot_foot" or node.name == "signs_bot:robot_leg" then
			if node.name == "signs_bot:robot_foot" then
				minetest.swap_node(pos1, mem.stored_node or {name = "air"})
			else
				minetest.remove_node(pos1)
			end
			pos1 = {x=pos.x, y=pos.y-2, z=pos.z}
			node = tubelib2.get_node_lvm(pos1)
			if node.name == "signs_bot:robot_foot" then
				minetest.swap_node(pos1, mem.stored_node or {name = "air"})
			end
		else
			minetest.swap_node(pos, mem.stored_node or {name = "air"})
		end
	end
end

minetest.register_node("signs_bot:robot", {
	-- up, down, right, left, back, front
	tiles = {
		"signs_bot_robot_top.png",
		"signs_bot_robot_bottom.png",
		"signs_bot_robot_right.png",
		"signs_bot_robot_left.png",
		"signs_bot_robot_front.png",
		"signs_bot_robot_back.png",
		
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -5/16,  3/16, -5/16,   5/16,  8/16, 5/16},
			{ -3/16,  2/16, -3/16,   3/16,  3/16, 3/16},
			{ -6/16, -7/16, -6/16,   6/16,  2/16, 6/16},
			{ -6/16, -8/16, -3/16,   6/16, -7/16, 3/16},
		},
	},
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = signs_bot.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	drop = "",
	groups = {cracky=1, not_in_creative_inventory = 1,
		plant = 1, -- prevents the transformation from wet soil to soil
	},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("signs_bot:robot_leg", {
	tiles = {"signs_bot_robot.png^[transformR90]"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -1/8, -4/8, -1/8,   1/8, 4/8, 1/8},
		},
	},
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = signs_bot.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	drop = "",
	groups = {cracky=1, not_in_creative_inventory = 1},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("signs_bot:robot_foot", {
	tiles = {"signs_bot_robot.png^[transformR90]"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -1/8, -4/8, -1/8,   1/8, 4/8, 1/8},
			{ -2/8, -4/8, -2/8,   2/8, -3/8, 2/8},
		},
	},
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = signs_bot.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	drop = "",
	groups = {cracky=1, not_in_creative_inventory = 1,
		plant = 1, -- prevents the transformation from wet soil to soil
	},
	sounds = default.node_sound_metal_defaults(),
})
