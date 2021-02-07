--[[

	Signs Bot
	=========

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Signs Bot: More commands

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("signs_bot")
local I,_ = dofile(MP.."/intllib.lua")

local lib = signs_bot.lib

local RegisteredInventories = {}
--
-- Move from/to inventories
--
-- From chest to robot
function signs_bot.robot_take(base_pos, robot_pos, param2, want_count, slot)
	local target_pos = lib.next_pos(robot_pos, param2)
	local node = tubelib2.get_node_lvm(target_pos)
	local def = RegisteredInventories[node.name]	
	local owner = M(base_pos):get_string("owner")
	
	-- Is known type of inventory node?
	if def and (not def.allow_take or def.allow_take(target_pos, nil, owner)) then
		local src_inv = minetest.get_inventory({type="node", pos=target_pos})
		-- take specified item_name from bot slot configuration OR any item from the chest
		local item_name = signs_bot.bot_inv_item_name(base_pos, slot) or lib.peek_inv(src_inv, def.take_listname)
		if item_name then
			local taken = src_inv:remove_item(def.take_listname, ItemStack(item_name.." "..want_count))
			local leftover = signs_bot.bot_inv_put_item(base_pos, slot, taken)
			src_inv:add_item(def.take_listname, leftover)
		end	
	end
end


-- From robot to chest
function signs_bot.robot_put(base_pos, robot_pos, param2, num, slot)
	local target_pos = lib.next_pos(robot_pos, param2)
	local node = tubelib2.get_node_lvm(target_pos)
	local def = RegisteredInventories[node.name]
	local owner = M(base_pos):get_string("owner")
	local taken = signs_bot.bot_inv_take_item(base_pos, slot, num)
	
	-- Is known type of inventory node?
	if taken and def and (not def.allow_put or def.allow_put(target_pos, taken, owner)) then
		local dst_inv = minetest.get_inventory({type="node", pos=target_pos})
		local leftover = dst_inv and dst_inv:add_item(def.put_listname, taken)
		if leftover and leftover:get_count() > 0 then
			signs_bot.bot_inv_put_item(base_pos, slot, leftover)
		end
	elseif taken then
		signs_bot.bot_inv_put_item(base_pos, slot, taken)
	end
end

-- From robot to furnace
function signs_bot.robot_put_fuel(base_pos, robot_pos, param2, num, slot)
	local target_pos = lib.next_pos(robot_pos, param2)
	local node = tubelib2.get_node_lvm(target_pos)
	local def = RegisteredInventories[node.name]
	local owner = M(base_pos):get_string("owner")
	local taken = signs_bot.bot_inv_take_item(base_pos, slot, num)
	
	-- Is known type of inventory node?
	if taken and def and (not def.allow_fuel or def.allow_fuel(target_pos, taken, owner)) then
		local dst_inv = minetest.get_inventory({type="node", pos=target_pos})
		local leftover = dst_inv and dst_inv:add_item(def.fuel_listname, taken)
		if leftover and leftover:get_count() > 0 then
			signs_bot.bot_inv_put_item(base_pos, slot, leftover)
		end
	end
end

signs_bot.register_botcommand("take_item", {
	mod = "item",
	params = "<num> <slot>",	
	num_param = 2,
	description = I("Take <num> items from a chest like node\nand put it into the item inventory.\n"..
		"<slot> is the inventory slot (1..8) or 0 for any one"),
	check = function(num, slot)
		num = tonumber(num) or 1
		if num < 1 or num > 99 then 
			return false 
		end
		slot = tonumber(slot) or 0
		if slot < 0 or slot > 8 then 
			return false 
		end
		return true
	end,
	cmnd = function(base_pos, mem, num, slot)
		num = tonumber(num) or 1
		slot = tonumber(slot) or 0
		signs_bot.robot_take(base_pos, mem.robot_pos, mem.robot_param2, num, slot)
		return signs_bot.DONE
	end,
})
	
signs_bot.register_botcommand("add_item", {
	mod = "item",
	params = "<num> <slot>",	
	num_param = 2,
	description = I("Add <num> items to a chest like node\ntaken from the item inventory.\n"..
		"<slot> is the inventory slot (1..8) or 0 for any one"),
	check = function(num, slot)
		num = tonumber(num) or 1
		if num < 1 or num > 99 then 
			return false 
		end
		slot = tonumber(slot) or 0
		if slot < 0 or slot > 8 then 
			return false 
		end
		return true
	end,
	cmnd = function(base_pos, mem, num, slot)
		num = tonumber(num) or 1
		slot = tonumber(slot) or 0
		signs_bot.robot_put(base_pos, mem.robot_pos, mem.robot_param2, num, slot)
		return signs_bot.DONE
	end,
})
	
signs_bot.register_botcommand("add_fuel", {
	mod = "item",
	params = "<num> <slot>",
	num_param = 2,
	description = I("Add <num> fuel to a furnace like node\ntaken from the item inventory.\n"..
		"<slot> is the inventory slot (1..8) or 0 for any one"),
	check = function(num, slot)
		num = tonumber(num) or 1
		if num < 1 or num > 99 then 
			return false 
		end
		slot = tonumber(slot) or 0
		if slot < 0 or slot > 8 then 
			return false 
		end
		return true
	end,
	cmnd = function(base_pos, mem, num, slot)
		num = tonumber(num) or 1
		slot = tonumber(slot) or 0
		signs_bot.robot_put_fuel(base_pos, mem.robot_pos, mem.robot_param2, num, slot)
		return signs_bot.DONE
	end,
})

signs_bot.register_botcommand("cond_take_item", {
	mod = "item",
	params = "<num> <slot>",
	num_param = 2,
	description = I("deprecated, use bot inventory configuration instead"),
	check = function(num, slot)
		return false 
	end,
	cmnd = function(base_pos, mem, num, slot)
		return signs_bot.DONE
	end,
})
	
signs_bot.register_botcommand("cond_add_item", {
	mod = "item",
	params = "<num> <slot>",
	num_param = 2,
	description = I("deprecated, use bot inventory configuration instead"),
	check = function(num, slot)
		return false 
	end,
	cmnd = function(base_pos, mem, num, slot)
		return signs_bot.DONE
	end,
})

signs_bot.register_botcommand("pickup_items", {
	mod = "item",
	params = "<slot>",
	num_param = 1,
	description = I("Pick up all objects\n"..
		"in a 3x3 field.\n"..
		"<slot> is the inventory slot (1..8) or 0 for any one"),
	check = function(slot)
		slot = tonumber(slot) or 0
		return slot >= 0 and slot < 9
	end,
	cmnd = function(base_pos, mem, slot)
		slot = tonumber(slot) or 0
		local pos = lib.dest_pos(mem.robot_pos, mem.robot_param2, {0,0})
		for _, object in pairs(minetest.get_objects_inside_radius(pos, 2)) do
			local lua_entity = object:get_luaentity()
			if not object:is_player() and lua_entity and lua_entity.name == "__builtin:item" then
				local item = ItemStack(lua_entity.itemstring)
				local leftover = signs_bot.bot_inv_put_item(base_pos, slot, item)
				if leftover:get_count() == 0 then
					object:remove()
				end
			end
		end
		return signs_bot.DONE
	end,
})
	
signs_bot.register_botcommand("drop_items", {
	mod = "item",
	params = "<num> <slot>",
	num_param = 2,
	description = I("Drop items in front of the bot.\n"..
		"<slot> is the inventory slot (1..8) or 0 for any one"),
	check = function(num, slot)
		num = tonumber(num) or 1
		if num < 1 or num > 99 then 
			return false 
		end
		slot = tonumber(slot) or 0
		if slot < 0 or slot > 8 then 
			return false 
		end
		return true
	end,
	cmnd = function(base_pos, mem, num, slot)
		num = tonumber(num) or 1
		slot = tonumber(slot) or 0
		local pos = lib.dest_pos(mem.robot_pos, mem.robot_param2, {0})
		local items = signs_bot.bot_inv_take_item(base_pos, slot, num)
		minetest.add_item(pos, items)
		return signs_bot.DONE
	end,
})

signs_bot.register_botcommand("punch_cart", {
	mod = "item",
	params = "",
	num_param = 0,
	description = I("Punch a rail cart to start it"),
	cmnd = function(base_pos, mem)
		local pos = lib.dest_pos(mem.robot_pos, mem.robot_param2, {0})
		for _, object in pairs(minetest.get_objects_inside_radius(pos, 2)) do
			if object:get_entity_name() == "minecart:cart" then
				object:punch(object, 1.0, {
					full_punch_interval = 1.0,
					damage_groups = {fleshy = 1},
				}, minetest.facedir_to_dir(mem.robot_param2))
				break -- start only one cart
			end
		end
		return signs_bot.DONE
	end,
})

-- def is a table with following data:
--	{
--		put = {
--			allow_inventory_put = func(pos, stack, player_name), 
--			listname = "src",
--		},
--		take = {
--			allow_inventory_take = func(pos, stack, player_name),
--			listname = "dst",
		
--		fuel = {
--			allow_inventory_put = func(pos, stack, player_name), 
--			listname = "fuel",
--		},
--	}
function signs_bot.register_inventory(node_names, def)
	for _, name in ipairs(node_names) do
		RegisteredInventories[name] = {
			allow_put = def.put and def.put.allow_inventory_put,
			put_listname = def.put and def.put.listname,
			allow_take = def.take and def.take.allow_inventory_take,
			take_listname = def.take and def.take.listname,
			allow_fuel = def.fuel and def.fuel.allow_inventory_put,
			fuel_listname = def.fuel and def.fuel.listname,
		}
	end
end
