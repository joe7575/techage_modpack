--[[

	Tube Library 2
	==============

	Copyright (C) 2017-2020 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	tube_test.lua
	
	THIS FILE IS ONLY FOR TESTING PURPOSES

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Test tubes

local Tube = tubelib2.Tube:new({
	                -- North, East, South, West, Down, Up
	-- dirs_to_check = {1,2,3,4}, -- horizontal only
	-- dirs_to_check = {5,6},  -- vertical only
	dirs_to_check = {1,2,3,4,5,6},
	max_tube_length = 1000, 
	show_infotext = true,
	primary_node_names = {"tubelib2:tubeS", "tubelib2:tubeA"}, 
	secondary_node_names = {"default:chest", "default:chest_open", 
			"tubelib2:source", "tubelib2:junction", "tubelib2:teleporter"},
	after_place_tube = function(pos, param2, tube_type, num_tubes, tbl)
		minetest.swap_node(pos, {name = "tubelib2:tube"..tube_type, param2 = param2})
	end,
})

Tube:register_on_tube_update(function(node, pos, out_dir, peer_pos, peer_in_dir)
	local sdir = tubelib2.dir_to_string(out_dir)
	if not peer_pos then
		print(S(pos).." to the "..sdir..": Not connected")
	elseif Tube:is_secondary_node(peer_pos) then
		local node = minetest.get_node(peer_pos)
		print(S(pos).." to the "..sdir..": Connected with "..node.name.." at "..S(peer_pos).."/"..peer_in_dir)
	else
		print(S(pos).." to the "..sdir..": Connected with "..S(peer_pos).."/"..peer_in_dir)
		for i, pos, node in Tube:get_tube_line(pos, out_dir) do
			print("walk", S(pos), node.name)
		end
	end
end)


minetest.register_node("tubelib2:tubeS", {
	description = "Tubelib2 Test tube",
	tiles = { -- Top, base, right, left, front, back
		"tubelib2_tube.png",
		"tubelib2_tube.png",
		"tubelib2_tube.png",
		"tubelib2_tube.png",
		"tubelib2_hole.png",
		"tubelib2_hole.png",
	},
	
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		--local t = minetest.get_us_time()
		if not Tube:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		--print("place time", minetest.get_us_time() - t)
		return false
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Tube:after_dig_tube(pos, oldnode, oldmetadata)
	end,
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-2/8, -2/8, -4/8,  2/8, 2/8, 4/8},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 3, cracky = 3, snappy = 3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("tubelib2:tubeA", {
	description = "Tubelib2 Test tube",
	tiles = { -- Top, base, right, left, front, back
		"tubelib2_tube.png",
		"tubelib2_hole.png",
		"tubelib2_tube.png",
		"tubelib2_tube.png",
		"tubelib2_tube.png",
		"tubelib2_hole.png",
	},
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Tube:after_dig_tube(pos, oldnode, oldmetadata)
	end,
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-2/8, -4/8, -2/8,  2/8, 2/8,  2/8},
			{-2/8, -2/8, -4/8,  2/8, 2/8, -2/8},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 3, cracky = 3, snappy = 3, not_in_creative_inventory=1},
	sounds = default.node_sound_glass_defaults(),
	drop = "tubelib2:tubeS",
})

local sFormspec = "size[7.5,3]"..
	"field[0.5,1;7,1;channel;Enter channel string;]" ..
	"button_exit[2,2;3,1;exit;Save]"


minetest.register_node("tubelib2:source", {
	description = "Tubelib2 Item Source",
	tiles = {
		-- up, down, right, left, back, front
		'tubelib2_source.png',
		'tubelib2_source.png',
		'tubelib2_source.png',
		'tubelib2_source.png',
		'tubelib2_source.png',
		'tubelib2_conn.png',
	},

	after_place_node = function(pos, placer)
		local tube_dir = ((minetest.dir_to_facedir(placer:get_look_dir()) + 2) % 4) + 1
		M(pos):set_int("tube_dir", tube_dir)
		Tube:after_place_node(pos, {tube_dir})		
		minetest.get_node_timer(pos):start(2)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local tube_dir = tonumber(oldmetadata.fields.tube_dir or 0)
		Tube:after_dig_node(pos, {tube_dir})
	end,
	
	on_timer = function(pos, elapsed)
		local tube_dir = M(pos):get_int("tube_dir")
		local dest_pos, dest_dir = Tube:get_connected_node_pos(pos, tube_dir)
		print("on_timer: dest_pos="..S(dest_pos).."  dest_dir="..dest_dir)
		local inv = minetest.get_inventory({type="node", pos=dest_pos})
		local stack = ItemStack("default:dirt")
		if inv then
			local leftover = inv:add_item("main", stack)
			if leftover:get_count() == 0 then
				return true
			end
		end
		local node = minetest.get_node(dest_pos)
		if node.name == "air" then
			minetest.add_item(dest_pos, stack)
		else
			print("add_item error")
		end
		return true
	end,
	
	paramtype2 = "facedir", -- important!
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 3, cracky = 3, snappy = 3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("tubelib2:junction", {
	description = "Tubelib2 Junction",
	tiles = {
		'tubelib2_conn.png',
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Position "..S(pos))
		Tube:after_place_node(pos)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Tube:after_dig_node(pos)
	end,
	
	paramtype2 = "facedir", -- important!
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 3, cracky = 3, snappy = 3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("tubelib2:teleporter", {
	description = "Tubelib2 Teleporter",
	tiles = {
		-- up, down, right, left, back, front
		'tubelib2_tele.png',
		'tubelib2_tele.png',
		'tubelib2_tele.png',
		'tubelib2_tele.png',
		'tubelib2_tele.png',
		'tubelib2_conn.png',
	},

	after_place_node = function(pos, placer)
		-- the tube_dir calculation depends on the player look-dir and the hole side of the node
		local tube_dir = ((minetest.dir_to_facedir(placer:get_look_dir()) + 2) % 4) + 1
		Tube:prepare_pairing(pos, tube_dir, sFormspec)
		Tube:after_place_node(pos, {tube_dir})
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if fields.channel ~= nil then
			Tube:pairing(pos, fields.channel)
		end
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Tube:stop_pairing(pos, oldmetadata, sFormspec)
		local tube_dir = tonumber(oldmetadata.fields.tube_dir or 0)
		Tube:after_dig_node(pos, {tube_dir})
	end,
	
	paramtype2 = "facedir", -- important!
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 3, cracky = 3, snappy = 3},
	sounds = default.node_sound_glass_defaults(),
})

local function read_param2(pos, player)
	local node = minetest.get_node(pos)	
	local dir1, dir2, num_tubes = Tube:decode_param2(pos, node.param2)
	minetest.chat_send_player(player:get_player_name(), "[Tubelib2] pos="..S(pos)..", dir1="..dir1..", dir2="..dir2..", num_tubes="..num_tubes)
end

local function remove_tube(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local pos = pointed_thing.under
		if placer:get_player_control().sneak then
			read_param2(pos, placer)
		else
			Tube:tool_remove_tube(pos, "default_break_glass")
		end
	else
		local dir = (minetest.dir_to_facedir(placer:get_look_dir()) % 4) + 1
		minetest.chat_send_player(placer:get_player_name(), 
			"[Tool Help] dir="..dir.."\n"..
			"    left: remove node\n"..
			"    right: repair tube line\n")
	end
end

local function walk(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local pos = pointed_thing.under
		local dir = (minetest.dir_to_facedir(placer:get_look_dir()) % 4) + 1
		local t = minetest.get_us_time()
		local pos1, outdir1, pos2, outdir2, cnt = Tube:walk(pos, dir)
		t = minetest.get_us_time() - t
		print("time", t)
		if pos1 then
			local s = "[Tubelib2] pos1="..S(pos1)..", outdir1="..outdir1..", pos2="..S(pos2)..", outdir2="..outdir2..", cnt="..cnt
			minetest.chat_send_player(placer:get_player_name(), s)
		end
	else
		local dir = (minetest.dir_to_facedir(placer:get_look_dir()) % 4) + 1
		minetest.chat_send_player(placer:get_player_name(), 
			"[Tool Help] dir="..dir.."\n"..
			"    left: remove node\n"..
			"    right: repair tube line\n")
	end
end

local function debug(itemstack, placer, pointed_thing)
	Tube:dbg_out()
end

-- Tool for tube workers to crack a protected tube line
minetest.register_node("tubelib2:tool", {
	description = "Tubelib2 Tool",
	inventory_image = "tubelib2_tool.png",
	wield_image = "tubelib2_tool.png",
	use_texture_alpha = true,
	groups = {cracky=1, book=1},
	on_use = remove_tube,
	on_place = debug,
	node_placement_prediction = "",
	stack_max = 1,
})

