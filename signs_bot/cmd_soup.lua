--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg
	Copyright (C) 2021 Michal 'Micu' Cieslakiewicz

	GPL v3
	See LICENSE.txt for more information
	
	Bot soup cooking commands

	Allows bot to use pot (xdecor:cauldron) to cook a vegetable soup

]]--

if not minetest.global_exists("bucket") or not minetest.global_exists("fire")
   or not minetest.global_exists("xdecor") then return end

local M = minetest.get_meta

-- Load support for I18n.
local S = signs_bot.S

local lib = signs_bot.lib

local bucket_empty, bucket_water = ItemStack("bucket:bucket_empty 1"), ItemStack("bucket:bucket_water 1")
local bowl_empty_farming, bowl_empty_xdecor = ItemStack("farming:bowl 1"), ItemStack("xdecor:bowl 1")
local bowl_soup = ItemStack("xdecor:bowl_soup 1")

local function find_item_slot(base_pos, item)
	local inv = M(base_pos):get_inventory()
	local s = nil
	for i = 1, 8 do
		local t = inv:get_stack("main", i)
		if t and t:get_name() == item:get_name() then
			s = i
			break
		end
	end
	return s
end

signs_bot.register_botcommand("take_water", {
	mod = "soup",
	params = "<slot>",
	num_param = 1,
	description = S("Take water into empty bucket when standing on a shore\n(use specified slot number or 0 for auto selection)"),
	check = function(slot)
		slot = tonumber(slot)
		return slot and slot >= 0 and slot <= 8
	end,
	cmnd = function(base_pos, mem, slot)
		slot = tonumber(slot)
		local pos = lib.dest_pos(mem.robot_pos, mem.robot_param2, { 0 })
		pos.y = pos.y - 1
		if not lib.not_protected(base_pos, pos) then
			return signs_bot.ERROR, S("Error: Position protected")
		end
		local node = minetest.get_node_or_nil(pos)
		if not node or node.name ~= "default:water_source" then
			return signs_bot.ERROR, S("Error: No still water around")
		end
		local itemslot = slot
		if slot == 0 then
			itemslot = find_item_slot(base_pos, bucket_empty)
			if not itemslot then
				return signs_bot.ERROR, S("Error: No empty bucket in inventory")
			end
		end
		local item = signs_bot.bot_inv_take_item(base_pos, itemslot, 1)
		if not item or item:is_empty() or item:get_name() ~= bucket_empty:get_name() then
			return signs_bot.ERROR, S("Error: No empty bucket in inventory slot " .. itemslot)
		end
		item = signs_bot.bot_inv_put_item(base_pos, slot, bucket_water)
		if item:is_empty() then
			minetest.remove_node(pos)
		else
			signs_bot.bot_inv_put_item(base_pos, itemslot, bucket_empty)
			return signs_bot.ERROR, S("Error: No inventory space for full bucket")
		end
	        return signs_bot.DONE
	end,
})

signs_bot.register_botcommand("fill_cauldron", {
	mod = "soup",
	params = "<slot>",
	num_param = 1,
	description = S("Pour water from bucket to empty cauldron in front of a robot\n(use specified slot number or 0 for auto selection)"),
	check = function(slot)
		slot = tonumber(slot)
		return slot and slot >= 0 and slot <= 8
	end,
	cmnd = function(base_pos, mem, slot)
		slot = tonumber(slot)
		local pos = lib.dest_pos(mem.robot_pos, mem.robot_param2, { 0 })
		if not lib.not_protected(base_pos, pos) then
			return signs_bot.ERROR, S("Error: Position protected")
		end
		local node = minetest.get_node_or_nil(pos)
		if not node or node.name ~= "xdecor:cauldron_empty" then
			return signs_bot.ERROR, S("Error: No empty cauldron in front of a robot")
		end
		local itemslot = slot
		if slot == 0 then
			itemslot = find_item_slot(base_pos, bucket_water)
			if not itemslot then
				return signs_bot.ERROR, S("Error: No full bucket in inventory")
			end
		end
		local item = signs_bot.bot_inv_take_item(base_pos, itemslot, 1)
		if not item or item:is_empty() or item:get_name() ~= bucket_water:get_name() then
			return signs_bot.ERROR, S("Error: No full bucket in inventory slot " .. itemslot)
		end
		item = signs_bot.bot_inv_put_item(base_pos, slot, bucket_empty)
		if item:is_empty() then
			minetest.set_node(pos, { name = "xdecor:cauldron_idle", param2 = node.param2 })
		else
			signs_bot.bot_inv_put_item(base_pos, itemslot, bucket_water)
			return signs_bot.ERROR, S("Error: No inventory space for empty bucket")
		end
	        return signs_bot.DONE
	end,
})

signs_bot.register_botcommand("flame_on", {
	mod = "soup",
	params = "",
	num_param = 0,
	description = S("Set fire under cauldron (requires flammable material)\n(command is ignored when fire is already burning)"),
	cmnd = function(base_pos, mem)
		local pos = lib.dest_pos(mem.robot_pos, mem.robot_param2, { 0 })
		local fire_pos = { x = pos.x, y = pos.y - 1, z = pos.z }
		local fuel_pos = { x = pos.x, y = pos.y - 2, z = pos.z }
		if not (lib.not_protected(base_pos, pos) and lib.not_protected(base_pos, fire_pos)
		   and lib.not_protected(base_pos, fuel_pos)) then
			return signs_bot.ERROR, S("Error: Position protected")
		end
		local node = minetest.get_node_or_nil(pos)
		if not node or not node.name:find("xdecor:cauldron") then
			return signs_bot.ERROR, S("Error: No cauldron in front of a robot")
		end
		local fire_node = minetest.get_node_or_nil(fire_pos)
		if fire_node and fire_node.name:match("fire:[%w_]*flame") then
			return signs_bot.DONE
		elseif not fire_node or fire_node.name ~= "air" then
			return signs_bot.ERROR, S("Error: No space for fire under cauldron")
		end
		local fuel_node = minetest.get_node_or_nil(fuel_pos)
		if fuel_node and minetest.registered_nodes[fuel_node.name].on_ignite then
			minetest.registered_nodes[fuel_node.name].on_ignite(fuel_pos)
		elseif fuel_node and minetest.get_item_group(fuel_node.name, "flammable") >= 1 then
			minetest.set_node(fire_pos, { name = "fire:basic_flame" })
		else
			return signs_bot.ERROR, S("Error: No flammable material under cauldron")
		end
	        return signs_bot.DONE
	end,
})

signs_bot.register_botcommand("flame_off", {
	mod = "soup",
	params = "",
	num_param = 0,
	description = S("Put out (extinguish) fire under cauldron\n(command is ignored when there is no fire)"),
	cmnd = function(base_pos, mem)
		local pos = lib.dest_pos(mem.robot_pos, mem.robot_param2, { 0 })
		local fire_pos = { x = pos.x, y = pos.y - 1, z = pos.z }
		if not (lib.not_protected(base_pos, pos) and lib.not_protected(base_pos, fire_pos)) then
			return signs_bot.ERROR, S("Error: Position protected")
		end
		local node = minetest.get_node_or_nil(pos)
		if not node or not node.name:find("xdecor:cauldron") then
			return signs_bot.ERROR, S("Error: No cauldron in front of a robot")
		end
		local node = minetest.get_node_or_nil(fire_pos)
		if node and node.name:match("fire:[%w_]*flame") then
			minetest.remove_node(fire_pos)
		end
	        return signs_bot.DONE
	end,
})

signs_bot.register_botcommand("take_soup", {
	mod = "soup",
	params = "<slot>",
	num_param = 1,
	description = S("Take boiling soup into empty bowl from cauldron\nin front of a robot\n(use specified slot number or 0 for auto selection)"),
	check = function(slot)
		slot = tonumber(slot)
		return slot and slot >= 0 and slot <= 8
	end,
	cmnd = function(base_pos, mem, slot)
		slot = tonumber(slot)
		local pos = lib.dest_pos(mem.robot_pos, mem.robot_param2, { 0 })
		if not lib.not_protected(base_pos, pos) then
			return signs_bot.ERROR, S("Error: Position protected")
		end
		local node = minetest.get_node_or_nil(pos)
		if not node or node.name ~= "xdecor:cauldron_soup" then
			return signs_bot.ERROR, S("Error: No cauldron with a soup in front of a robot")
		end
		local itemslot = slot
		if slot == 0 then
			itemslot = find_item_slot(base_pos, bowl_empty_xdecor) or find_item_slot(base_pos, bowl_empty_farming)
			if not itemslot then
				return signs_bot.ERROR, S("Error: No empty bowl in inventory")
			end
		end
		local item = signs_bot.bot_inv_take_item(base_pos, itemslot, 1)
		if not item or item:is_empty() or (item:get_name() ~= bowl_empty_farming:get_name()
		   and item:get_name() ~= bowl_empty_xdecor:get_name()) then
			return signs_bot.ERROR, S("Error: No empty bowl in inventory slot " .. itemslot)
		end
		local item_full = signs_bot.bot_inv_put_item(base_pos, slot, bowl_soup)
		if item_full:is_empty() then
			minetest.set_node(pos, { name = "xdecor:cauldron_empty", param2 = node.param2 })
		else
			signs_bot.bot_inv_put_item(base_pos, itemslot, item)
			return signs_bot.ERROR, S("Error: No inventory space for full bowl")
		end
		return signs_bot.DONE
	end,
})

local CMD_WATER = [[
dig_sign 1
move
take_water 1
backward
place_sign 1
turn_around
]]

local CMD_SOUP = [[
dig_sign 1
move 2
fill_cauldron 1
flame_on
pause 11
move_up
drop_items 1 2
drop_items 1 3
move_down
pause 6
take_soup 4
flame_off
backward
backward
place_sign 1
turn_around
]]

signs_bot.register_sign({
	name = "water",
	description = S('Sign "take water"'),
	commands = CMD_WATER,
	image = "signs_bot_sign_water.png",
})


signs_bot.register_sign({
	name = "soup",
	description = S('Sign "cook soup"'),
	commands = CMD_SOUP,
	image = "signs_bot_sign_soup.png",
})

minetest.register_craft({
	output = "signs_bot:water",
	recipe = {
		{"group:wood", "bucket:bucket_empty", "group:wood"},
		{"dye:black", "default:stick", "dye:yellow"},
		{"dye:blue", "", ""}
	}
})

minetest.register_craft({
	output = "signs_bot:soup",
	recipe = {
		{"group:wood", "xdecor:bowl", "group:wood"},
		{"dye:black", "default:stick", "dye:yellow"},
		{"dye:orange", "", ""}
	}
})

if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "water", {
		name = S("Sign 'take water'"),
		data = {
			item = "signs_bot:water",
			text = table.concat({
				S("Used to take water into bucket."),
				S("Place the sign on a shore, in front of the still water pool."),
				S("Items in slots:"),
				S("  1 - empty bucket"),
				S("The result is one bucket with water in selected inventory slot."),
				S("When finished, the bot turns around."),
			}, "\n")
		},
	})
	doc.add_entry("signs_bot", "soup", {
		name = S("Sign 'cook soup'"),
		data = {
			item = "signs_bot:soup",
			text = table.concat({
				S("Used to cook a vegetable soup in cauldron."),
				S("Cauldon should be empty and located above flammable material."),
				S("Place the sign in front of the cauldron with one field space,"),
				S("to prevent wooden sign from catching fire."),
				S("Items in slots:"),
				S("  1 - water bucket"),
				S("  2 - vegetable #1 (i.e. tomato)"),
				S("  3 - vegetable #2 (i.e. carrot)"),
				S("  4 - empty bowl (from farming or xdecor mods)"),
				S("The result is one bowl with vegetable soup in selected inventory slot."),
				S("When finished, the bot turns around."),
			}, "\n")
		},
	})
end
