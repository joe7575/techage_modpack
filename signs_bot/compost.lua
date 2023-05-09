--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Signs Bot: Commands for the compost mod

]]--

-- Load support for I18n.
local S = signs_bot.S

local NUM_LEAVES = 2

-- we reuse the minecart hopper API here
local function additem(mem, stack)
	local pos = signs_bot.lib.next_pos(mem.robot_pos, mem.robot_param2)
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	if ndef.minecart_hopper_additem then
		return ndef.minecart_hopper_additem(pos, stack)
	end

	pos = {x = pos.x, y = pos.y - 1, z = pos.z}
	node = minetest.get_node(pos)
	ndef = minetest.registered_nodes[node.name]
	if ndef and ndef.minecart_hopper_additem then
		return ndef.minecart_hopper_additem(pos, stack)
	end

	return stack
end

local function takeitem(mem)
	local pos = signs_bot.lib.next_pos(mem.robot_pos, mem.robot_param2)
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	if ndef.minecart_hopper_takeitem then
		return ndef.minecart_hopper_takeitem(pos, 1)
	end

	pos = {x = pos.x, y = pos.y - 1, z = pos.z}
	node = minetest.get_node(pos)
	ndef = minetest.registered_nodes[node.name]
	if ndef and ndef.minecart_hopper_takeitem then
		return ndef.minecart_hopper_takeitem(pos, 1)
	end
end


if  minetest.global_exists("compost") then

	signs_bot.register_botcommand("add_compost", {
		mod = "compost",
		params = "<slot>",
		num_param = 1,
		description = S("Put 2 leaves into the compost barrel\n"..
			"<slot> is the bot inventory slot (1..8)\n"..
			"with the leaves."),
		check = function(slot)
			slot = tonumber(slot) or 0
			return slot > 0 and slot < 9
		end,
		cmnd = function(base_pos, mem, slot)
			slot = tonumber(slot) or 0
			local taken = signs_bot.bot_inv_take_item(base_pos, slot, NUM_LEAVES)
			local leftover = additem(mem, taken)
			if leftover and leftover:get_count() > 0 then
				signs_bot.bot_inv_put_item(base_pos, slot, leftover)
			end
			return signs_bot.DONE
		end,
	})

	signs_bot.register_botcommand("take_compost", {
		mod = "compost",
		params = "<slot>",
		num_param = 1,
		description = S("Take a compost item from the barrel.\n"..
			"<slot> (1..8 or 0 for the first free slot) is the bot\n"..
			"slot for the compost item."),
		check = function(num, slot)
			slot = tonumber(slot) or 0
			return slot >= 0 and slot < 9
		end,
		cmnd = function(base_pos, mem, slot)
			slot = tonumber(slot) or 0
			local taken = takeitem(mem)
			local leftover = signs_bot.bot_inv_put_item(base_pos, slot, taken)
			if leftover and leftover:get_count() > 0 then
				signs_bot.lib.drop_items(mem.robot_pos, leftover)
			end
			return signs_bot.DONE
		end,
	})
end
