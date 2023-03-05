--[[

	Minecart
	========

	Copyright (C) 2019-2020 Joachim Stolberg

	MIT
	See license.txt for more information

]]--

-- for lazy programmers
local M = minetest.get_meta

local RegisteredInventories = {}

-- Take the given number of items from the inv.
-- Returns nil if ItemList is empty.
function minecart.inv_take_items(inv, listname, num)
	if inv:is_empty(listname) then
		return nil
	end
	local size = inv:get_size(listname)
	for idx = 1, size do
		local items = inv:get_stack(listname, idx)
		if items:get_count() > 0 then
			local taken = items:take_item(num)
			inv:set_stack(listname, idx, items)
			return taken
		end
	end
	return nil
end

function minecart.take_items(pos, param2, num)
	local npos, node
	if param2 then
		npos, node = minecart.get_next_node(pos, (param2 + 2) % 4)
	else
		npos, node = pos, minetest.get_node(pos)
	end
	local def = RegisteredInventories[node.name]
	local owner = M(pos):get_string("owner")
	local inv = minetest.get_inventory({type="node", pos=npos})

	if def and inv and def.take_listname and (not def.allow_take or def.allow_take(npos, nil, owner)) then
		return minecart.inv_take_items(inv, def.take_listname, num)
	elseif def and def.take_item then
		return def.take_item(npos, num, owner)
	else
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.minecart_hopper_takeitem then
			return ndef.minecart_hopper_takeitem(npos, num)
		end
	end
end

function minecart.put_items(pos, param2, stack)
	local npos, node = minecart.get_next_node(pos, param2)
	local def = RegisteredInventories[node.name]
	local owner = M(pos):get_string("owner")
	local inv = minetest.get_inventory({type="node", pos=npos})

	if def and inv and def.put_listname and (not def.allow_put or def.allow_put(npos, stack, owner)) then
		local leftover = inv:add_item(def.put_listname, stack)
		if leftover:get_count() > 0 then
			return leftover
		end
	elseif def and def.put_item then
		return def.put_item(npos, stack, owner)
	elseif minecart.is_air_like(node.name) or minecart.is_nodecart_available(npos) then
		minetest.add_item(npos, stack)
	else
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.minecart_hopper_additem then
			local leftover = ndef.minecart_hopper_additem(npos, stack)
			if leftover:get_count() > 0 then
				return leftover
			end
		else
			return stack
		end
	end
end

function minecart.untake_items(pos, param2, stack)
	local npos, node
	if param2 then
		npos, node = minecart.get_next_node(pos, (param2 + 2) % 4)
	else
		npos, node = pos, minetest.get_node(pos)
	end
	local def = RegisteredInventories[node.name]
	local inv = minetest.get_inventory({type="node", pos=npos})

	if def and inv and def.take_listname then
		return inv:add_item(def.take_listname, stack)
	elseif def and def.untake_item then
		return def.untake_item(npos, stack)
	else
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.minecart_hopper_untakeitem then
			return ndef.minecart_hopper_untakeitem(npos, stack)
		end
	end
end

-- Register inventory node for hopper access
-- (for example, see below)
function minecart.register_inventory(node_names, def)
	for _, name in ipairs(node_names) do
		RegisteredInventories[name] = {
			allow_put = def.put and def.put.allow_inventory_put,
			put_listname = def.put and def.put.listname,
			allow_take = def.take and def.take.allow_inventory_take,
			take_listname = def.take and def.take.listname,
			put_item = def.put and def.put.put_item,
			take_item = def.take and def.take.take_item,
			untake_item = def.take and def.take.untake_item,
		}
	end
end

-- Allow the hopper the access to itself
minecart.register_inventory({"minecart:hopper"}, {
	put = {
		allow_inventory_put = function(pos, stack, player_name)
			local owner = M(pos):get_string("owner")
			return owner == player_name
		end,
		listname = "main",
	},
	take = {
		allow_inventory_take = function(pos, stack, player_name)
			local owner = M(pos):get_string("owner")
			return owner == player_name
		end,
		listname = "main",
	},
})
