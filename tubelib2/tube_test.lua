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
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local M = minetest.get_meta


-- Marker entities for debugging purposes
local function debug_info(pos, text)
	local marker = minetest.add_entity(pos, "tubelib2:marker_cube")
	if marker ~= nil then
		if text == "add" then
			marker:set_nametag_attributes({color = "#FF0000", text = "add__________"})
		elseif text == "del" then
			marker:set_nametag_attributes({color = "#00FF00", text = "_____del_____"})
		elseif text == "noc" then
			marker:set_nametag_attributes({color = "#0000FF", text = "__________noc"})
		end
		minetest.after(6, marker.remove, marker)
	end
end

minetest.register_entity(":tubelib2:marker_cube", {
	initial_properties = {
		visual = "cube",
		textures = {
			"tubelib2_marker_cube.png",
			"tubelib2_marker_cube.png",
			"tubelib2_marker_cube.png",
			"tubelib2_marker_cube.png",
			"tubelib2_marker_cube.png",
			"tubelib2_marker_cube.png",
		},
		physical = false,
		visual_size = {x = 1.1, y = 1.1},
		collisionbox = {-0.55,-0.55,-0.55, 0.55,0.55,0.55},
		glow = 8,
	},
	on_punch = function(self)
		self.object:remove()
	end,
})

-- Test tubes
local Tube = tubelib2.Tube:new({
	                -- North, East, South, West, Down, Up
	-- dirs_to_check = {1,2,3,4}, -- horizontal only
	-- dirs_to_check = {5,6},  -- vertical only
	dirs_to_check = {1,2,3,4,5,6},
	max_tube_length = 10, 
	show_infotext = true,
	primary_node_names = {"tubelib2:tubeS", "tubelib2:tubeA"}, 
	secondary_node_names = {"default:chest", "default:chest_open", 
			"tubelib2:source", "tubelib2:junction", "tubelib2:teleporter"},
	after_place_tube = function(pos, param2, tube_type, num_tubes, tbl)
		minetest.swap_node(pos, {name = "tubelib2:tube"..tube_type, param2 = param2})
	end,
	--debug_info = debug_info,
})

Tube:set_valid_sides("tubelib2:source", {"F"})
Tube:set_valid_sides("tubelib2:teleporter", {"F"})

Tube:register_on_tube_update(function(node, pos, out_dir, peer_pos, peer_in_dir)
	local sdir = tubelib2.dir_to_string(out_dir)
	if not peer_pos then
		print(P2S(pos).." to the "..sdir..": Not connected")
	elseif Tube:is_secondary_node(peer_pos) then
		local node = minetest.get_node(peer_pos)
		print(P2S(pos).." to the "..sdir..": Connected with "..node.name.." at "..P2S(peer_pos).."/"..peer_in_dir)
	else
		print(P2S(pos).." to the "..sdir..": Connected with "..P2S(peer_pos).."/"..peer_in_dir)
		for i, pos, node in Tube:get_tube_line(pos, out_dir) do
			print("walk", P2S(pos), node.name)
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

local function push_item(pos)
	local tube_dir = M(pos):get_int("tube_dir")
	local dest_pos, dest_dir = Tube:get_connected_node_pos(pos, tube_dir)
	local dest_node = minetest.get_node(dest_pos)
	local on_push_item = minetest.registered_nodes[dest_node.name].on_push_item
	--print("on_timer: dest_pos="..S(dest_pos).."  dest_dir="..dest_dir)
	local inv = minetest.get_inventory({type="node", pos=dest_pos})
	local stack = ItemStack("default:dirt")
	
	if on_push_item then
		return on_push_item(dest_pos, dest_dir, stack)
	elseif inv then
		local leftover = inv:add_item("main", stack)
		if leftover:get_count() == 0 then
			return true
		end
	elseif dest_node.name == "air" then
		minetest.add_item(dest_pos, stack)
		return true
	end
	return false
end

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
		if not push_item(pos) then
			print("push_item error")
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

-- Can't be used for item transport (hyperloop test node)
minetest.register_node("tubelib2:junction", {
	description = "Tubelib2 Junction",
	tiles = {
		'tubelib2_conn.png',
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Position "..P2S(pos))
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

-------------------------------------------------------------------------------
-- Teleporter
-------------------------------------------------------------------------------
local pairingList = {}

local sFormspec = "size[7.5,3]"..
	"field[0.5,1;7,1;channel;Enter channel string;]" ..
	"button_exit[2,2;3,1;exit;Save]"

local function store_connection(pos, peer_pos)		
	local meta = M(pos)
	meta:set_string("peer_pos", P2S(peer_pos))
	meta:set_string("channel", "")
	meta:set_string("formspec", "")
	meta:set_string("infotext", "Connected with "..P2S(peer_pos))
end

local function prepare_pairing(pos)
	local meta = M(pos)
	meta:set_string("peer_pos", "")
	meta:set_string("channel", "")
	meta:set_string("formspec", sFormspec)
	meta:set_string("infotext", "Pairing is missing")
end

local function pairing(pos, channel)
	if pairingList[channel] and not vector.equals(pos, pairingList[channel]) then
		-- store peer position on both nodes
		local peer_pos = pairingList[channel]
		store_connection(pos, peer_pos)
		store_connection(peer_pos, pos)
		pairingList[channel] = nil
		return true
	else
		pairingList[channel] = pos
		prepare_pairing(pos)
		return false
	end
end

local function stop_pairing(pos, oldmetadata)
	-- unpair peer node
	if oldmetadata and oldmetadata.fields then
		if oldmetadata.fields.peer_pos then
			local peer_pos = S2P(oldmetadata.fields.peer_pos)
			prepare_pairing(peer_pos)
		elseif oldmetadata.fields.channel then
			pairingList[oldmetadata.fields.channel] = nil
		end
	end
end

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
		M(pos):set_int("tube_dir", tube_dir)
		Tube:after_place_node(pos, {tube_dir})
		prepare_pairing(pos)
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if fields.channel ~= nil then
			pairing(pos, fields.channel)
		end
	end,
	
	on_push_item = function(pos, dir, item)
		local tube_dir = M(pos):get_int("tube_dir")
		if dir == tubelib2.Turn180Deg[tube_dir] then
			local s = M(pos):get_string("peer_pos")
			if s and s ~= "" then
				push_item(S2P(s))
				return true
			end
		end
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		stop_pairing(pos, oldmetadata)
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

-------------------------------------------------------------------------------
-- Tool
-------------------------------------------------------------------------------
local function read_param2(pos, player)
	local node = minetest.get_node(pos)	
	local dir1, dir2, num_tubes = Tube:decode_param2(pos, node.param2)
	minetest.chat_send_player(player:get_player_name(), "[Tubelib2] pos="..P2S(pos)..", dir1="..dir1..", dir2="..dir2..", num_tubes="..num_tubes)
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

--local function walk(itemstack, placer, pointed_thing)
--	if pointed_thing.type == "node" then
--		local pos = pointed_thing.under
--		local dir = (minetest.dir_to_facedir(placer:get_look_dir()) % 4) + 1
--		local t = minetest.get_us_time()
--		local pos1, outdir1, pos2, outdir2, cnt = Tube:walk(pos, dir)
--		t = minetest.get_us_time() - t
--		print("time", t)
--		if pos1 then
--			local s = "[Tubelib2] pos1="..P2S(pos1)..", outdir1="..outdir1..", pos2="..P2S(pos2)..", outdir2="..outdir2..", cnt="..cnt
--			minetest.chat_send_player(placer:get_player_name(), s)
--		end
--	else
--		local dir = (minetest.dir_to_facedir(placer:get_look_dir()) % 4) + 1
--		minetest.chat_send_player(placer:get_player_name(), 
--			"[Tool Help] dir="..dir.."\n"..
--			"    left: remove node\n"..
--			"    right: repair tube line\n")
--	end
--end

local function repair_tube(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local pos = pointed_thing.under
		local _, _, fpos1, fpos2, _, _, cnt1, cnt2 = Tube:tool_repair_tube(pos)
		local length = cnt1 + cnt2
		
		local s = "Tube from " .. P2S(fpos1) .. " to " .. P2S(fpos2) .. ". Lenght = " .. length
		minetest.chat_send_player(placer:get_player_name(), s)
		
		if length > Tube.max_tube_length then
			local s = string.char(0x1b) .. "(c@#ff0000)" .. "Tube length error!"
			minetest.chat_send_player(placer:get_player_name(), s)
		end
		
		minetest.sound_play("carts_cart_new", {
				pos = pos, 
				gain = 1,
				max_hear_distance = 5})
	else
		local dir = (minetest.dir_to_facedir(placer:get_look_dir()) % 4) + 1
		minetest.chat_send_player(placer:get_player_name(), 
			"[Tool Help] dir="..dir.."\n"..
			"    left: remove node\n"..
			"    right: repair tube line\n")
	end
end

-- Tool for tube workers to crack a protected tube line
minetest.register_node("tubelib2:tool", {
	description = "Tubelib2 Tool",
	inventory_image = "tubelib2_tool.png",
	wield_image = "tubelib2_tool.png",
	use_texture_alpha = true,
	groups = {cracky=1, book=1},
	on_use = remove_tube,
	on_place = repair_tube,
	node_placement_prediction = "",
	stack_max = 1,
})

