--[[

	Signs Bot
	=========

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Bot cloning/pattern commands, signs, and nodes

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("signs_bot")
local I,_ = dofile(MP.."/intllib.lua")

local lib = signs_bot.lib

local ValidSizes = {
	["3x1"] = true,
	["3x2"] = true,
	["3x3"] = true,
	["5x1"] = true,
	["5x2"] = true,
	["5x3"] = true,
}

--
-- Helper function to rotate nodes by the Y-axis
--
local Param2Matrix = {
	{0,1,2,3},  -- y+
	{6,15,8,17},  -- z+
	{4,13,10,19},  -- z-
	{5,14,11,16},  -- x+
	{7,12,9,18},  -- x-
	{22,21,20,23},  -- y-
}
local tWallmountedRot = {[0]=3,5,4,2}
local tFacedirRot = {}

for _,row in ipairs(Param2Matrix) do
	for idx,elem in ipairs(row) do
		local tbl = {}
		for i = 0,3 do
			tbl[i] = row[((i+idx-1) % 4) + 1]
		end
		tFacedirRot[elem] = tbl
	end
end

local function param2_conversion(node, offs) 
	local ndef = minetest.registered_nodes[node.name]
	if not ndef or not ndef.paramtype2 then	return end
	if ndef.paramtype2 == "facedir" then
		node.param2 = tFacedirRot[node.param2][offs]
	elseif ndef.paramtype2 == "wallmounted" and node.param2 > 1 then
		node.param2 = tWallmountedRot[(node.param2 + offs - 2) % 4]
	end
end
	
--
-- Inventory functions
--
local function inv_get_item(pos, name)
	-- air can be copied for free
	if name == "air" then
		return "air"
	end
	-- try to get the item
	local inv = minetest.get_inventory({type="node", pos=pos})
	if not inv then return "signs_bot:missing" end
	local taken = inv:remove_item("main", ItemStack(name))
	if taken:get_count() == 0 then
		return "signs_bot:missing"
	end
	return name
end

local function inv_put_item(pos, mem, name)
	if name == "air" then
		return
	end
	local inv = minetest.get_inventory({type="node", pos=pos})
	if not inv then return end
	local leftover = inv:add_item("main", ItemStack(name))
	if leftover:get_count() > 0 then
		lib.drop_items(mem.robot_pos, leftover)
	end
end

local function pattern_copy(base_pos, mem)
	local src_pos = mem.src_pos_tbl[mem.steps]
	local dst_pos = mem.dst_pos_tbl[mem.steps]
	mem.steps = mem.steps + 1
	
	if lib.not_protected(base_pos, dst_pos) then
		local src_node = tubelib2.get_node_lvm(src_pos)
		src_node.name = inv_get_item(base_pos, src_node.name)
	
		local dst_node = tubelib2.get_node_lvm(dst_pos)
		inv_put_item(base_pos, mem, dst_node.name)
		param2_conversion(src_node, mem.dir_offs)
		minetest.set_node(dst_pos, src_node)
	end
end

			
signs_bot.register_botcommand("pattern", {
	mod = "copy",
	params = "",
	num_param = 0,
	description = I("Store pattern to be cloned."),
	cmnd = function(base_pos, mem)
		mem.pttrn_pos = lib.next_pos(mem.robot_pos, mem.robot_param2)
		mem.pttrn_param2 = mem.robot_param2
		return signs_bot.DONE
	end,
})

signs_bot.register_botcommand("copy", {
	mod = "copy",
	params = "<size> <lvl>",
	num_param = 2,
	description = I("Copy the nodes from\n"..
		"the stored pattern position\n"..
		"<size> is: 3x1, 3x2, 3x3,\n"..
		"5x1, 5x2, 5x3 (wide x deep)\n"..
		"<lvl> pattern level offset (0..4)"),
	check = function(size, lvl)
		lvl = tonumber(lvl) or 0
		if not lvl or lvl < 0 or lvl > 4 then
			return false
		end
		return ValidSizes[size]
	end,
	cmnd = function(base_pos, mem, size, lvl)
		if not mem.pttrn_pos then return true end
		if not mem.steps then
			local x,z = size:match('(%d)x(%d)')
			lvl = tonumber(lvl) or 0
			mem.x_size = tonumber(x)
			mem.z_size = tonumber(z)
			mem.src_pos_tbl = signs_bot.lib.gen_position_table(mem.pttrn_pos, mem.pttrn_param2, x, z, lvl)
			mem.dst_pos_tbl = signs_bot.lib.gen_position_table(mem.robot_pos, mem.robot_param2, x, z, 0)
			mem.dir_offs = mem.robot_param2 - mem.pttrn_param2
			mem.steps = 1
		end
		pattern_copy(base_pos, mem)
		if mem.steps > #mem.src_pos_tbl then
			mem.steps = nil
			return signs_bot.DONE
		end
		return signs_bot.BUSY
	end,
})


minetest.register_node("signs_bot:missing", {
	description = "Missing Node",
	tiles = {"signs_bot_missing_node.png"},
	drawtype = "glasslike",
	paramtype = "light",
	sunlight_propagates = true,
	use_texture_alpha = true,
	is_ground_content = false,
	groups = {snappy=3,cracky=3,oddly_breakable_by_hand=3, not_in_creative_inventory = 1},
	drop = "",
	sounds = default.node_sound_glass_defaults(),
})

signs_bot.register_sign({
	name = "pattern", 
	description = I('Sign "pattern"'), 
	commands = "pattern\nturn_around", 
	image = "signs_bot_sign_pattern.png",
})

minetest.register_craft({
	output = "signs_bot:pattern 2",
	recipe = {
		{"group:wood", "default:stick", "group:wood"},
		{"dye:red", "default:stick", "dye:black"},
		{"", "", ""}
	}
})

local CMND = [[dig_sign 1
move
copy 3x3
move_up
copy 3x3 1
move_up
copy 3x3 2
move_down
move_down
backward
place_sign 1
turn_around]]

signs_bot.register_sign({
	name = "copy3x3x3", 
	description = I('Sign "copy 3x3x3"'), 
	commands = CMND, 
	image = "signs_bot_sign_copy3x3x3.png",
})

minetest.register_craft({
	output = "signs_bot:copy3x3x3 2",
	recipe = {
		{"group:wood", "default:stick", "group:wood"},
		{"dye:black", "default:stick", "dye:red"},
		{"", "", ""}
	}
})

if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "pattern", {
		name = I("Sign 'pattern'"),
		data = {
			item = "signs_bot:pattern",
			text = table.concat({
				I("Used to make a copy of a 3x3x3 cube."),
				I("Place the sign in front of the pattern to be copied."), 
				I("Use the copy sign to make the copy of this pattern on a different location."),
				I("The bot must first reach the pattern sign, then the copy sign."),
			}, "\n")		
		},
	})
end

if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "copy3x3x3", {
		name = I("Sign 'copy3x3x3'"),
		data = {
			item = "signs_bot:copy3x3x3",
			text = table.concat({
				I("Used to make a copy of a 3x3x3 cube."),
				I("Place the sign in front of the location, where the copy should be made."), 
				I("Use the pattern sign to mark the pattern."),
			}, "\n")		
		},
	})
end

