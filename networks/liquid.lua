--[[

	Networks
	========

	Copyright (C) 2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Liquid API for liquid pumping and storing nodes

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta
local N = tubelib2.get_node_lvm
local LQD = function(pos) return (minetest.registered_nodes[N(pos).name] or {}).liquid end

networks.liquid = {}
networks.registered_networks.liquid = {}

-- return list of nodes {pos = ..., indir = ...} of given node_type
local function get_network_table(pos, tlib2, outdir, node_type)
	local netw = networks.get_network_table(pos, tlib2, outdir)
	if netw then
		return netw[node_type] or {}
	end
	return {}
end

-------------------------------------------------------------------------------
-- For all types of nodes
-------------------------------------------------------------------------------
-- names: list of node names
-- tlib2: tubelib2 instance
-- node_type: one of "pump", "tank", "junc"
-- valid_sides: something like {"L", "R"} or nil
-- liquid_callbacks = {
--	capa = CAPACITY,
--	peek = function(pos, indir), -- returns: liquid name
--	put = function(pos, indir, name, amount),  -- returns: liquid leftover or 0
--	take = function(pos, indir, name, amount), -- returns: taken, name
--	untake = function(pos, indir, name, amount), -- returns: leftover
-- }
function networks.liquid.register_nodes(names, tlib2, node_type, valid_sides, liquid_callbacks)
	if node_type == "pump" then
		assert(not valid_sides or type(valid_sides) == "table")
		valid_sides = valid_sides or {"B", "R", "F", "L", "D", "U"}
	elseif node_type == "tank" or node_type == "junc" then
		assert(not valid_sides or type(valid_sides) == "table")
		valid_sides = valid_sides or {"B", "R", "F", "L", "D", "U"}
	elseif node_type and type(node_type) == "string" then
		valid_sides = valid_sides or {"B", "R", "F", "L", "D", "U"}
	else
		error("parameter error")
	end

	if node_type == "tank" then
		assert(type(liquid_callbacks) == "table")
	end

	tlib2:add_secondary_node_names(names)
	networks.registered_networks.liquid[tlib2.tube_type] = tlib2

	for _, name in ipairs(names) do
		local ndef = minetest.registered_nodes[name]
		local tbl = ndef.networks or {}
		tbl[tlib2.tube_type] = {ntype = node_type}
		minetest.override_item(name, {networks = tbl})
		minetest.override_item(name, {liquid = liquid_callbacks})
		tlib2:set_valid_sides(name, valid_sides)
	end
end

-- To be called for each liquid network change via
-- tubelib2_on_update2 or register_on_tube_update2
function networks.liquid.update_network(pos, outdir, tlib2, node)
	local ndef = networks.net_def(pos, tlib2.tube_type)
	if ndef.ntype == "junc" then
		outdir = 0
	end
	networks.update_network(pos, outdir, tlib2, node)
end

-------------------------------------------------------------------------------
-- Client/pump functions
-------------------------------------------------------------------------------
-- Determine and return liquid 'name' from the
-- remote inventory.
function networks.liquid.peek(pos, tlib2, outdir)
	assert(outdir)
	for _,item in ipairs(get_network_table(pos, tlib2, outdir, "tank")) do
		local liq = LQD(item.pos)
		if liq and liq.peek then
			return liq.peek(item.pos, item.indir)
		end
	end
end

-- Add given amount of liquid to the remote inventory.
-- return leftover amount
function networks.liquid.put(pos, tlib2, outdir, name, amount, show_debug_cube)
	assert(outdir)
	assert(name)
	assert(amount and amount > 0)
	for _,item in ipairs(get_network_table(pos, tlib2, outdir, "tank")) do
		local liq = LQD(item.pos)
		if liq and liq.put and liq.peek then
			-- wrong items?
			local peek = liq.peek(item.pos, item.indir)
			if peek and peek ~= name then return amount or 0 end
			if show_debug_cube then
				networks.set_marker(item.pos, "put", 1.1, 1)
			end
			amount = liq.put(item.pos, item.indir, name, amount)
			if not amount or amount == 0 then break end
		end
	end
	return amount or 0
end

-- Take given amount of liquid from the remote inventory.
-- return taken amount and item name
function networks.liquid.take(pos, tlib2, outdir, name, amount, show_debug_cube)
	assert(outdir)
	assert(amount and amount > 0)
	local taken = 0
	for _,item in ipairs(get_network_table(pos, tlib2, outdir, "tank")) do
		local liq = LQD(item.pos)
		if liq and liq.take then
			if show_debug_cube then
				networks.set_marker(item.pos, "take", 1.1, 1)
			end
			taken, name = liq.take(item.pos, item.indir, name, amount)
			if taken and name and taken > 0 then
				break
			end
		end
	end
	return taken, name
end

function networks.liquid.untake(pos, tlib2, outdir, name, amount)
	assert(outdir)
	assert(name)
	assert(amount)
	for _,item in ipairs(get_network_table(pos, tlib2, outdir, "tank")) do
		local liq = LQD(item.pos)
		if liq and liq.untake then
			amount = liq.untake(item.pos, item.indir, name, amount)
			if not amount or amount == 0 then break end
		end
	end
	return amount or 0
end

-------------------------------------------------------------------------------
-- Server/tank local functions
-------------------------------------------------------------------------------
function networks.liquid.is_empty(nvm)
	return not nvm.liquid or (nvm.liquid.amount or 0) <= 0
end

function networks.liquid.get_amount(nvm)
	if nvm.liquid and nvm.liquid.amount then
		return nvm.liquid.amount
	end
	return 0
end

function networks.liquid.get_item(nvm)
	local itemname = "<empty>"
	if nvm.liquid and nvm.liquid.amount and nvm.liquid.amount > 0 and nvm.liquid.name then
		itemname = nvm.liquid.name.." "..nvm.liquid.amount
	end
	return itemname
end

function networks.liquid.srv_peek(nvm)
	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = math.floor((nvm.liquid.amount or 0) + 0.5)
	return nvm.liquid.amount > 0 and nvm.liquid.name
end

function networks.liquid.srv_put(nvm, name, amount, capa)
	assert(name)
	assert(capa and capa > 0)
	amount = math.floor((amount or 0) + 0.5)
	nvm.liquid = nvm.liquid or {}
	
	if not nvm.liquid.name then
		nvm.liquid.name = name
		nvm.liquid.amount = amount
		return 0
	elseif nvm.liquid.name == name then
		nvm.liquid.amount = nvm.liquid.amount or 0
		if nvm.liquid.amount + amount <= capa then
			nvm.liquid.amount = nvm.liquid.amount + amount
			return 0
		else
			local rest = nvm.liquid.amount + amount - capa
			nvm.liquid.amount = capa
			return rest
		end
	end
	return amount
end

function networks.liquid.srv_take(nvm, name, amount)
	amount = math.floor((amount or 0) + 0.5)
	nvm.liquid = nvm.liquid or {}
	
	if not name or nvm.liquid.name == name then
		name = nvm.liquid.name
		nvm.liquid.amount = nvm.liquid.amount or 0
		if nvm.liquid.amount > amount then
			nvm.liquid.amount = nvm.liquid.amount - amount
			return amount, name
		else
			local rest = nvm.liquid.amount
			local name = nvm.liquid.name
			nvm.liquid.amount = 0
			nvm.liquid.name = nil
			return rest, name
		end
	end
	return 0
end

-------------------------------------------------------------------------------
-- Valve
-------------------------------------------------------------------------------
function networks.liquid.turn_valve_on(pos, tlib2, name_off, name_on)
	local node = N(pos)
	local meta = M(pos)
	if node.name == name_off then
		node.name = name_on
		minetest.swap_node(pos, node)
		tlib2:after_place_tube(pos)
		meta:set_int("networks_param2", node.param2)
		return true
	elseif meta:contains("networks_param2_copy") then
		meta:set_int("networks_param2", meta:get_int("networks_param2_copy"))
		tlib2:after_place_tube(pos)
		return true
	end
end

function networks.liquid.turn_valve_off(pos, tlib2, name_off, name_on)
	local node = N(pos)
	local meta = M(pos)
	if node.name == name_on then
		node.name = name_off
		minetest.swap_node(pos, node)
		meta:set_int("networks_param2", 0)
		tlib2:after_dig_tube(pos, node)
		return true
	elseif meta:contains("networks_param2") then
		meta:set_int("networks_param2_copy", meta:get_int("networks_param2"))
		meta:set_int("networks_param2", 0)
		tlib2:after_dig_tube(pos, node)
		return true
	end
end
