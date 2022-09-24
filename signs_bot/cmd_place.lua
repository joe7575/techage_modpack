--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Bot place/remove commands

]]--

-- Load support for I18n.
local S = signs_bot.S

local lib = signs_bot.lib
local bot_inv_take_item = signs_bot.bot_inv_take_item

local function bot_inv_put_item(pos, slot, items)
	local leftover = signs_bot.bot_inv_put_item(pos, slot, items)
	return leftover:get_count() == 0
end

local tValidLevels = {[-1] = -1, [0] = 0, [1] = 1}

-- for items with paramtype2 = "facedir"
local tRotations = {}

local Rotations = {
	{0,8,22,4},
	{1,17,21,13},
	{2,6,20,10},
	{3,15,23,19},
}

for _,v in ipairs(Rotations) do
	local t = table.copy(v)
	for i = 1,4 do
		table.insert(t, 1, table.remove(t))
		tRotations[t[1]] = {t[2], t[3], t[4]}
	end
end

--
-- Place/dig items
--
local function place_item(base_pos, robot_pos, param2, slot, route, level)
	local pos1, p2 = lib.dest_pos(robot_pos, param2, route)
	pos1.y = pos1.y + level
	if not lib.not_protected(base_pos, pos1) then
		return signs_bot.ERROR, S("Error: Position protected")
	end
	if lib.is_air_like(pos1) then
		local taken = signs_bot.bot_inv_take_item(base_pos, slot, 1)
		if taken then
			local name = taken:get_name()
			if name == "default:torch" then
				name = "signs_bot:torch"
			end
			local def = minetest.registered_nodes[name]
			if not def then return end
			if def.paramtype2 == "wallmounted" then
				local dir = minetest.facedir_to_dir(p2)
				local wdir = minetest.dir_to_wallmounted(dir)
				minetest.set_node(pos1, {name=name, param2=wdir})
			else
				minetest.set_node(pos1, {name=name, param2=p2})
				--minetest.check_single_for_falling(pos1)
			end
		end
	end
	return signs_bot.DONE
end

signs_bot.register_botcommand("place_front", {
	mod = "place",
	params = "<slot> <lvl>",
	num_param = 2,
	description = S("Place a block in front of the robot\n"..
		"<slot> is the inventory slot (1..8)\n"..
		"<lvl> is one of: -1   0   +1"),
	check = function(slot, lvl)
		slot = tonumber(slot) or 0
		if not slot or slot < 0 or slot > 8 then
			return false
		end
		return tValidLevels[lvl] ~= nil
	end,
	cmnd = function(base_pos, mem, slot, lvl)
		slot = tonumber(slot) or 0
		local level = tValidLevels[lvl]
		return place_item(base_pos, mem.robot_pos, mem.robot_param2, slot, {0}, level)
	end,
})

signs_bot.register_botcommand("place_left", {
	mod = "place",
	params = "<slot> <lvl>",
	num_param = 2,
	description = S("Place a block on the left side\n"..
		"<slot> is the inventory slot (1..8)\n"..
		"<lvl> is one of: -1   0   +1"),
	check = function(slot, lvl)
		slot = tonumber(slot) or 0
		if not slot or slot < 0 or slot > 8 then
			return false
		end
		return tValidLevels[lvl] ~= nil
	end,
	cmnd = function(base_pos, mem, slot, lvl)
		slot = tonumber(slot) or 0
		local level = tValidLevels[lvl]
		return place_item(base_pos, mem.robot_pos, mem.robot_param2, slot, {3,0}, level)
	end,
})

signs_bot.register_botcommand("place_right", {
	mod = "place",
	params = "<slot> <lvl>",
	num_param = 2,
	description = S("Place a block on the right side\n"..
		"<slot> is the inventory slot (1..8)\n"..
		"<lvl> is one of: -1   0   +1"),
	check = function(slot, lvl)
		slot = tonumber(slot) or 0
		if not slot or slot < 0 or slot > 8 then
			return false
		end
		return tValidLevels[lvl] ~= nil
	end,
	cmnd = function(base_pos, mem, slot, lvl)
		slot = tonumber(slot) or 0
		local level = tValidLevels[lvl]
		return place_item(base_pos, mem.robot_pos, mem.robot_param2, slot, {1,0}, level)
	end,
})

local function place_item_below(base_pos, robot_pos, param2, slot)
	local pos1 = {x=robot_pos.x,y=robot_pos.y-1,z=robot_pos.z}
	if not lib.not_protected(base_pos, pos1) then
		return signs_bot.ERROR, S("Error: Position protected")
	end
	local node = tubelib2.get_node_lvm(pos1)
	if node.name == "signs_bot:robot_foot" then
		local taken = bot_inv_take_item(base_pos, slot, 1)
		if taken then
			local name = taken:get_name()
			local def = minetest.registered_nodes[name]
			if not def then return end
			minetest.set_node(pos1, {name=name, param2=param2})
		end
	end
	return signs_bot.DONE
end

signs_bot.register_botcommand("place_below", {
	mod = "place",
	params = "<slot>",
	num_param = 1,
	description = S("Place a block under the robot.\n"..
		"Hint: use 'move_up' first.\n"..
		"<slot> is the inventory slot (1..8)"),
	check = function(slot)
		slot = tonumber(slot) or 0
		return slot and slot >= 0 and slot < 9
	end,
	cmnd = function(base_pos, mem, slot)
		slot = tonumber(slot) or 0
		return place_item_below(base_pos, mem.robot_pos, mem.robot_param2, slot)
	end,
})

local function place_item_above(base_pos, robot_pos, param2, slot)
	local pos1 = {x=robot_pos.x,y=robot_pos.y+1,z=robot_pos.z}
	if not lib.not_protected(base_pos, pos1) then
		return signs_bot.ERROR, S("Error: Position protected")
	end
	if lib.is_air_like(pos1) then
		local taken = bot_inv_take_item(base_pos, slot, 1)
		if taken then
			local name = taken:get_name()
			local def = minetest.registered_nodes[name]
			if not def then return end
			minetest.set_node(pos1, {name=name, param2=param2})
		end
	end
	return signs_bot.DONE
end

signs_bot.register_botcommand("place_above", {
	mod = "place",
	params = "<slot>",
	num_param = 1,
	description = S("Place a block above the robot.\n"..
		"<slot> is the inventory slot (1..8)"),
	check = function(slot)
		slot = tonumber(slot) or 0
		return slot and slot >= 0 and slot < 9
	end,
	cmnd = function(base_pos, mem, slot)
		slot = tonumber(slot) or 0
		return place_item_above(base_pos, mem.robot_pos, mem.robot_param2, slot)
	end,
})

local function dig_item(base_pos, robot_pos, param2, slot, route, level)
	local pos1 = lib.dest_pos(robot_pos, param2, route)
	pos1.y = pos1.y + (level or 0)
	local node = tubelib2.get_node_lvm(pos1)
	local dug_name = lib.is_simple_node(node)
	if not lib.not_protected(base_pos, pos1) then
		return signs_bot.ERROR, S("Error: Position protected")
	end
	if dug_name then
		if bot_inv_put_item(base_pos, slot, ItemStack(dug_name)) then
			minetest.remove_node(pos1)
		else
			return signs_bot.ERROR, S("Error: No free inventory space")
		end
	end
	return signs_bot.DONE
end

signs_bot.register_botcommand("dig_front", {
	mod = "place",
	params = "<slot> <lvl>",
	num_param = 2,
	description = S("Dig the block in front of the robot\n"..
		"<slot> is the inventory slot (1..8)\n"..
		"<lvl> is one of: -1   0   +1"),
	check = function(slot, lvl)
		slot = tonumber(slot) or 0
		if not slot or slot < 0 or slot > 8 then
			return false
		end
		return tValidLevels[lvl] ~= nil
	end,
	cmnd = function(base_pos, mem, slot, lvl)
		slot = tonumber(slot) or 0
		local level = tValidLevels[lvl]
		return dig_item(base_pos, mem.robot_pos, mem.robot_param2, slot, {0}, level)
	end,
	expensive = true,
})

signs_bot.register_botcommand("dig_left", {
	mod = "place",
	params = "<slot> <lvl>",
	num_param = 2,
	description = S("Dig the block on the left side\n"..
		"<slot> is the inventory slot (1..8)\n"..
		"<lvl> is one of: -1   0   +1"),
	check = function(slot, lvl)
		slot = tonumber(slot) or 0
		if not slot or slot < 0 or slot > 8 then
			return false
		end
		return tValidLevels[lvl] ~= nil
	end,
	cmnd = function(base_pos, mem, slot, lvl)
		slot = tonumber(slot) or 0
		local level = tValidLevels[lvl]
		return dig_item(base_pos, mem.robot_pos, mem.robot_param2, slot, {0,3}, level)
	end,
	expensive = true,
})

signs_bot.register_botcommand("dig_right", {
	mod = "place",
	params = "<slot> <lvl>",
	num_param = 2,
	description = S("Dig the block on the right side\n"..
		"<slot> is the inventory slot (1..8)\n"..
		"<lvl> is one of: -1   0   +1"),
	check = function(slot, lvl)
		slot = tonumber(slot) or 0
		if not slot or slot < 0 or slot > 8 then
			return false
		end
		return tValidLevels[lvl] ~= nil
	end,
	cmnd = function(base_pos, mem, slot, lvl)
		slot = tonumber(slot) or 0
		local level = tValidLevels[lvl]
		return dig_item(base_pos, mem.robot_pos, mem.robot_param2, slot, {0,1}, level)
	end,
	expensive = true,
})

local function dig_item_below(base_pos, robot_pos, param2, slot)
	local pos1 = {x=robot_pos.x,y=robot_pos.y-1,z=robot_pos.z}
	local node = tubelib2.get_node_lvm(pos1)
	local dug_name = lib.is_simple_node(node)
	if not lib.not_protected(base_pos, pos1) then
		return signs_bot.ERROR, S("Error: Position protected")
	end
	if dug_name then
		if bot_inv_put_item(base_pos, slot, ItemStack(dug_name)) then
			minetest.set_node(pos1, {name="signs_bot:robot_foot"})
		else
			return signs_bot.ERROR, S("Error: No free inventory space")
		end
	end
	return signs_bot.DONE
end

signs_bot.register_botcommand("dig_below", {
	mod = "place",
	params = "<slot>",
	num_param = 1,
	description = S("Dig the block under the robot.\n"..
		"<slot> is the inventory slot (1..8)"),
	check = function(slot)
		slot = tonumber(slot) or 0
		return slot and slot >= 0 and slot < 9
	end,
	cmnd = function(base_pos, mem, slot)
		slot = tonumber(slot) or 0
		return dig_item_below(base_pos, mem.robot_pos, mem.robot_param2, slot)
	end,
	expensive = true,
})

local function dig_item_above(base_pos, robot_pos, param2, slot)
	local pos1 = {x=robot_pos.x,y=robot_pos.y+1,z=robot_pos.z}
	local node = tubelib2.get_node_lvm(pos1)
	local dug_name = lib.is_simple_node(node)
	if not lib.not_protected(base_pos, pos1) then
		return signs_bot.ERROR, S("Error: Position protected")
	end
	if dug_name then
		if bot_inv_put_item(base_pos, slot, ItemStack(dug_name)) then
			minetest.remove_node(pos1)
		else
			return signs_bot.ERROR, S("Error: No free inventory space")
		end
	end
	return signs_bot.DONE
end

signs_bot.register_botcommand("dig_above", {
	mod = "place",
	params = "<slot>",
	num_param = 1,
	description = S("Dig the block above the robot.\n"..
		"<slot> is the inventory slot (1..8)"),
	check = function(slot)
		slot = tonumber(slot) or 0
		return slot and slot >= 0 and slot < 9
	end,
	cmnd = function(base_pos, mem, slot)
		slot = tonumber(slot) or 0
		return dig_item_above(base_pos, mem.robot_pos, mem.robot_param2, slot, 1)
	end,
	expensive = true,
})

local function rotate_item(base_pos, robot_pos, param2, route, level, steps)
	local pos1 = lib.dest_pos(robot_pos, param2, route)
	pos1.y = pos1.y + level
	local node = tubelib2.get_node_lvm(pos1)
	if not lib.not_protected(base_pos, pos1) then
		return signs_bot.ERROR, S("Error: Position protected")
	end
	if lib.is_simple_node(node) then
		local p2 = tRotations[node.param2] and tRotations[node.param2][steps]
		if p2 then
			minetest.swap_node(pos1, {name=node.name, param2=p2})
		end
	end
	return signs_bot.DONE
end

signs_bot.register_botcommand("rotate_item", {
	mod = "place",
	params = "<lvl> <steps>",
	num_param = 2,
	description = S("Rotate the block in front of the robot\n"..
		"<lvl> is one of:  -1   0   +1\n"..
		"<steps> is one of:  1   2   3"),
	check = function(lvl, steps)
		steps = tonumber(steps) or 1
		if not steps or steps < 1 or steps > 4 then
			return false
		end
		return tValidLevels[lvl] ~= nil
	end,
	cmnd = function(base_pos, mem, lvl, steps)
		local level = tValidLevels[lvl]
		steps = tonumber(steps) or 1
		return rotate_item(base_pos, mem.robot_pos, mem.robot_param2, {0}, level, steps)
	end,
})

-- Simplified torch which can be placed w/o a fake player
minetest.register_node("signs_bot:torch", {
	description = S("Bot torch"),
	inventory_image = "default_torch_on_floor.png",
	wield_image = "default_torch_on_floor.png",
	drawtype = "nodebox",
	node_box = {
		type = "connected",
		fixed = {
			{-1/16, -3/16, -1/16, 1/16, 7/16, 1/16},
			--{-2/16,  4/16, -2/16, 2/16, 8/16, 2/16},
		},
		connect_bottom = {{-1/16, -8/16, -1/16, 1/16, 1/16, 1/16}},
		connect_front = {{-1/16, -1/16, -8/16, 1/16, 1/16, 1/16}},
		connect_left = {{-8/16, -1/16, -1/16, 1/16, 1/16, 1/16}},
		connect_back = {{-1/16, -1/16, -1/16, 1/16, 1/16, 8/16}},
		connect_right = {{-1/16, -1/16, -1/16, 8/16, 1/16, 1/16}},
	},
	tiles = {
		-- up, down, right, left, back, front
		"signs_bot_torch_top.png",
		"signs_bot_torch_bottom.png",
		{
			image = "signs_bot_torch_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 4.0,
			},
		},

	},
	connects_to = {
		"group:pane", "group:stone", "group:glass", "group:wood", "group:tree",
		"group:bakedclay", "group:soil"},
	paramtype = "light",
	paramtype2 = "facedir",
	use_texture_alpha = signs_bot.CLIP,
	sunlight_propagates = true,
	walkable = false,
	liquids_pointable = false,
	light_source = 12,
	groups = {choppy=2, dig_immediate=3, flammable=1, attached_node=1, torch=1, not_in_creative_inventory=1},
	drop = "default:torch",
	sounds = default.node_sound_wood_defaults(),
})


