--[[

	Networks
	========

	Copyright (C) 2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Power API for power consuming and generating nodes

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta
local N = tubelib2.get_node_lvm
local OBS = networks.node_observer
local Flip = tubelib2.Turn180Deg

networks.power = {}
networks.registered_networks.power = {}

local DEFAULT_DATA = {
	curr_load = 0,  -- network storage value
	max_capa = 0,   -- network storage capacity
	consumed = 0,   -- consumed power by consumers
	provided = 0,   -- provided power by generators
	available = 0,  -- max. available generator power
	netw_num = 0,   -- network number
}

-- Storage parameters:
-- capa = maximum value in power units
-- load = current value in power units
-- level = ratio value (load/capa) (0..1)

local Power = {}  -- {netID = {curr_load, max_capa, consumed, provided, available}}



-- Determine load, capa and other power network data
local function get_power_data(pos, tlib2, outdir, netID)
	assert(outdir)
	local netw = networks.get_network_table(pos, tlib2, outdir) or {}
	local max_capa = 1  -- to prevent nan
	local max_perf = 0
	local curr_load = 0
	-- Generators
	for _,item in ipairs(netw.gen or {}) do
		local ndef = minetest.registered_nodes[N(item.pos).name]
		local data = ndef.get_generator_data and ndef.get_generator_data(item.pos, Flip[item.indir], tlib2)
		if data then
			OBS("get_power_data", item.pos, data)
			max_capa = max_capa + (data.capa or 0)
			max_perf = max_perf + (data.perf or 0)
			curr_load = curr_load + ((data.level or 0) * (data.capa or 0))
		end
	end
	-- Storage systems
	for _,item in ipairs(netw.sto or {}) do
		local ndef = minetest.registered_nodes[N(item.pos).name]
		local data = ndef.get_storage_data and ndef.get_storage_data(item.pos, Flip[item.indir], tlib2)
		if data then
			OBS("get_power_data", item.pos, data)
			max_capa = max_capa + (data.capa or 0)
			curr_load = curr_load + ((data.level or 0) * (data.capa or 0))
		end
	end
	Power[netID] = {
		curr_load = curr_load,    -- network storage value
		max_capa = max_capa,      -- network storage capacity
		max_perf = max_perf,      -- max. available power
		consumed = 0,             -- consumed power
		provided = 0,             -- provided power
		available = 0,            -- available power
		num_nodes = netw.num_nodes,
	}
	return Power[netID]
end

-------------------------------------------------------------------------------
-- For all types of nodes
-------------------------------------------------------------------------------
-- names: list of node names
-- tlib2: tubelib2 instance
-- node_type: one of "gen", "con", "sto", "junc"
-- valid_sides: something like {"L", "R"} or nil
function networks.power.register_nodes(names, tlib2, node_type, valid_sides)
	if node_type == "gen" then
		assert(#valid_sides <= 2)
	elseif node_type == "sto" then
		assert(#valid_sides == 1)
	elseif node_type == "con" or node_type == "junc" then
		assert(not valid_sides or type(valid_sides) == "table")
		valid_sides = valid_sides or {"B", "R", "F", "L", "D", "U"}
	elseif node_type and type(node_type) == "string" then
		valid_sides = valid_sides or {"B", "R", "F", "L", "D", "U"}
	else
		error("parameter error")
	end

	tlib2:add_secondary_node_names(names)
	networks.registered_networks.power[tlib2.tube_type] = tlib2

	for _, name in ipairs(names) do
		local ndef = minetest.registered_nodes[name]
		local tbl = ndef.networks or {}
		assert(tbl[tlib2.tube_type] == nil, "more than one call of 'networks.power.register_nodes' for " .. names[1])
		tbl[tlib2.tube_type] = {ntype = node_type}
		minetest.override_item(name, {networks = tbl})
		tlib2:set_valid_sides(name, valid_sides)
	end
end

-- To be called for each power network change via
-- tubelib2_on_update2 or register_on_tube_update2
function networks.power.update_network(pos, outdir, tlib2, node)
	local ndef = networks.net_def(pos, tlib2.tube_type)
	assert(ndef, "node " .. N(pos).name .. " has no 'networks." .. tlib2.tube_type .. "' table")
	if ndef.ntype == "junc" then
		outdir = 0
	end
	local netID = networks.get_netID(pos, outdir)
	if netID then
		Power[netID] = nil
	end
	networks.update_network(pos, outdir, tlib2, node)
end

-------------------------------------------------------------------------------
-- Consumer
-------------------------------------------------------------------------------
-- Function checks for a power grid, not for enough power
-- Param outdir is optional
function networks.power.power_available(pos, tlib2, outdir)
	for _,outdir in ipairs(networks.get_outdirs(pos, tlib2, outdir)) do
		local netID = networks.determine_netID(pos, tlib2, outdir)
		if netID then
			local pwr = Power[netID] or get_power_data(pos, tlib2, outdir, netID)
			OBS("power_available", pos, pwr)
			return pwr.curr_load > 0
		end
	end
end

-- Param outdir is optional
function networks.power.consume_power(pos, tlib2, outdir, amount)
	assert(amount)
	for _,outdir in ipairs(networks.get_outdirs(pos, tlib2, outdir)) do
		local netID = networks.determine_netID(pos, tlib2, outdir)
		if netID then
			local pwr = Power[netID] or get_power_data(pos, tlib2, outdir, netID)
			OBS("consume_power", pos, {outdir = outdir, amount = amount}, pwr)
			if pwr.curr_load >= amount then
				pwr.curr_load = pwr.curr_load - amount
				pwr.consumed = pwr.consumed + amount
				return amount
			else
				local consumed = pwr.curr_load
				pwr.curr_load = 0
				pwr.consumed = pwr.consumed + consumed
				return consumed
			end
		end
	end
	return 0
end

-------------------------------------------------------------------------------
-- Generator
-------------------------------------------------------------------------------
-- amount is the maximum power, the generator can provide.
-- cp1 and cp2 are control points for the charge regulator.
-- From cp1 the charging power is reduced more and more and reaches zero at cp2.
--
--        A
--        |
--  100 % |-------------------__
--        |                     --__
--        |                         --__
--        |                             --__
--      --+------------------+---------------+---->
--        |                 cp1             cp2
--
function networks.power.provide_power(pos, tlib2, outdir, amount, cp1, cp2)
	assert(outdir)
	assert(amount and amount > 0)
	local netID = networks.determine_netID(pos, tlib2, outdir)
	if netID then
		local pwr = Power[netID] or get_power_data(pos, tlib2, outdir, netID)
		local x = pwr.curr_load / pwr.max_capa
		OBS("provide_power", pos, {outdir = outdir, amount = amount}, pwr)

		pwr.available = pwr.available + amount
		amount = math.min(amount, pwr.max_capa - pwr.curr_load)
		cp1 = cp1 or 0.8
		cp2 = cp2 or 1.0

		if x < cp1 then  -- charge with full power
			pwr.curr_load = pwr.curr_load + amount
			pwr.provided = pwr.provided + amount
			return amount
		elseif x < cp2 then  -- charge with reduced power
			local factor = 1 - ((x - cp1) / (cp2 - cp1))
			local provided = amount * factor
			pwr.curr_load = pwr.curr_load + provided
			pwr.provided = pwr.provided + provided
			return provided
		else  -- turn off
			return 0
		end
	end
	return 0
end

-- Function for generators with storage capacity
function networks.power.get_storage_load(pos, tlib2, outdir, amount)
	local netID = networks.determine_netID(pos, tlib2, outdir)
	if netID then
		local pwr = Power[netID] or get_power_data(pos, tlib2, outdir, netID)
		OBS("get_storage_load", pos, pwr)
		if pwr.max_capa and pwr.max_capa > 0 then
			return pwr.curr_load / pwr.max_capa * amount
		else
			error("invalid pwr.max_capa", pwr.max_capa)
		end
	end
	return 0
end

-------------------------------------------------------------------------------
-- Storage
-------------------------------------------------------------------------------
-- Function returns a table with storage level as ratio (0..1) and the
-- charging state (1 = charging, -1 = uncharging, or 0)
-- Function provides nil if no network is available
function networks.power.get_storage_data(pos, tlib2, outdir)
	assert(outdir)
	local netID = networks.determine_netID(pos, tlib2, outdir)
	if netID then
		local pwr = Power[netID] or get_power_data(pos, tlib2, outdir, netID)
		OBS("get_storage_data", pos, pwr)
		local charging = (pwr.provided > pwr.consumed and 1) or (pwr.provided < pwr.consumed and -1) or 0
		return {level = pwr.curr_load / pwr.max_capa, charging = charging}
	end
end

-- To be called for each network storage change (turn on/off of storage/generator nodes)
function networks.power.start_storage_calc(pos, tlib2, outdir)
	assert(outdir)
	local netID = networks.determine_netID(pos, tlib2, outdir)
	OBS("start_storage_calc", pos)
	if netID then
		Power[netID] = nil
	end
end

-------------------------------------------------------------------------------
-- Transformer
-------------------------------------------------------------------------------
-- Charge transfer in both directions between network 1 and network 2
-- 'netw1' and 'netw2' are tubelib2 network instances.
-- Function returns a table with result values for:
-- {curr_load1, curr_load2, max_capa1, max_capa2, moved}
function networks.power.transfer_duplex(pos, netw1, outdir1, netw2, outdir2, amount)
	local netID1 = networks.determine_netID(pos, netw1, outdir1)
	local netID2 = networks.determine_netID(pos, netw2, outdir2)
	if netID1 and netID2 then
		local pwr1 = Power[netID1] or get_power_data(pos, netw1, outdir1, netID1)
		local pwr2 = Power[netID2] or get_power_data(pos, netw2, outdir2, netID2)
		local lvl = pwr1.curr_load / pwr1.max_capa - pwr2.curr_load / pwr2.max_capa
		local moved

		pwr2.available = pwr2.available + amount
		pwr1.available = pwr1.available + amount
		if lvl > 0 then
			-- transfer from netw1 to netw2
			moved = math.min(amount, lvl * math.min(pwr1.max_capa, pwr2.max_capa))
			moved = math.max(moved, 0)
			pwr1.curr_load = pwr1.curr_load - moved
			pwr2.curr_load = pwr2.curr_load + moved
			pwr1.consumed = (pwr1.consumed or 0) + moved
			pwr2.provided = (pwr2.provided or 0) + moved
		elseif lvl < 0 then
			-- transfer from netw2 to netw1
			moved = math.min(amount, lvl * math.min(pwr1.max_capa, pwr2.max_capa))
			moved = math.max(moved, 0)
			pwr2.curr_load = pwr2.curr_load - moved
			pwr1.curr_load = pwr1.curr_load + moved
			pwr2.consumed = (pwr2.consumed or 0) + moved
			pwr1.provided = (pwr1.provided or 0) + moved
		else
			moved = 0
		end
		OBS("transfer_duplex", pos, pwr1, pwr2)
		return {
			curr_load1 = pwr1.curr_load,
			curr_load2 = pwr2.curr_load,
			max_capa1 = pwr1.max_capa,
			max_capa2 = pwr2.max_capa,
			moved = moved}
	end
end

-- Charge transfer in one direction from network 1 to network 2
-- 'netw1' and 'netw2' are tubelib2 network instances.
-- Function returns a table with result values for:
-- {curr_load1, curr_load2, max_capa1, max_capa2, moved}
function networks.power.transfer_simplex(pos, netw1, outdir1, netw2, outdir2, amount)
	local netID1 = networks.determine_netID(pos, netw1, outdir1)
	local netID2 = networks.determine_netID(pos, netw2, outdir2)
	if netID1 and netID2 then
		local pwr1 = Power[netID1] or get_power_data(pos, netw1, outdir1, netID1)
		local pwr2 = Power[netID2] or get_power_data(pos, netw2, outdir2, netID2)
		local lvl = pwr1.curr_load / pwr1.max_capa - pwr2.curr_load / pwr2.max_capa
		local moved

		pwr2.available = pwr2.available + amount
		if lvl > 0 then
			-- transfer from netw1 to netw2
			moved = math.min(amount, lvl * math.min(pwr1.max_capa, pwr2.max_capa))
			moved = math.max(moved, 0)
			pwr1.curr_load = pwr1.curr_load - moved
			pwr2.curr_load = pwr2.curr_load + moved
			pwr1.consumed = (pwr1.consumed or 0) + moved
			pwr2.provided = (pwr2.provided or 0) + moved
		else
			moved = 0
		end
		OBS("transfer_simplex", pos, pwr1, pwr2)
		return {
			curr_load1 = pwr1.curr_load,
			curr_load2 = pwr2.curr_load,
			max_capa1 = pwr1.max_capa,
			max_capa2 = pwr2.max_capa,
			moved = moved}
	end
end

-------------------------------------------------------------------------------
-- Switch
-------------------------------------------------------------------------------
function networks.power.turn_switch_on(pos, tlib2, name_off, name_on)
	local node = N(pos)
	local meta = M(pos)
	local changed = false

	if node.name == name_off then
		node.name = name_on
		changed = true
	elseif meta:get_string("netw_name") == name_off then
		meta:set_string("netw_name", name_on)
	else
		return false
	end

	if meta:contains("netw_param2") then
		meta:set_int("netw_param2", meta:get_int("netw_param2_copy"))
	else
		node.param2 = meta:get_int("netw_param2_copy")
	end
	meta:set_int("netw_param2_copy", 0)

	if changed then
		minetest.swap_node(pos, node)
	end

	tlib2:after_place_tube(pos)
	return true
end

function networks.power.turn_switch_off(pos, tlib2, name_off, name_on)
	local node = N(pos)
	local meta = M(pos)
	local changed = false

	if node.name == name_on then
		node.name = name_off
		changed = true
	elseif meta:get_string("netw_name") == name_on then
		meta:set_string("netw_name", name_off)
	else
		return false
	end

	if meta:contains("netw_param2") then
		meta:set_int("netw_param2_copy", meta:get_int("netw_param2"))
		--meta:set_int("netw_param2", 0)
	else
		meta:set_int("netw_param2_copy", node.param2)
	end

	if changed then
		minetest.swap_node(pos, node)
	end

	if meta:contains("netw_param2") then
		node.param2 = meta:get_int("netw_param2")
	end
	tlib2:after_dig_tube(pos, node)
	return true
end

-------------------------------------------------------------------------------
-- Statistics
-------------------------------------------------------------------------------
function networks.power.get_network_data(pos, tlib2, outdir)
	for _,outdir in ipairs(networks.get_outdirs(pos, tlib2, outdir)) do
		local netID = networks.determine_netID(pos, tlib2, outdir)
		if netID then
			local pwr = Power[netID] or get_power_data(pos, tlib2, outdir, netID)
			local consumed, provided, available
			if pwr.available > 0 and pwr.max_perf > 0 then
				local fac = pwr.max_perf / pwr.available
				available = pwr.max_perf
				provided = pwr.provided * fac
				consumed = pwr.consumed * fac
			else
				available = pwr.max_perf
				provided = 0
				consumed = pwr.consumed
			end
			local res = {
				curr_load = pwr.curr_load,             -- network storage value
				max_capa = pwr.max_capa,               -- network storage capacity
				consumed = consumed,                   -- consumed power by consumers
				provided = provided,                   -- provided power by generators
				available = available,                 -- max. available generator power
				netw_num = networks.netw_num(netID),   -- network number
			}
			pwr.consumed = 0
			pwr.provided = 0
			pwr.available = 0
			return res
		end
	end
	return DEFAULT_DATA
end
