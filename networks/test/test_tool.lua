--[[

	Networks
	========

	Copyright (C) 2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local M = minetest.get_meta

local power = networks.power
local liquid = networks.liquid

local function round(val)
	return math.floor(val + 0.5)
end

local function get_list(tbl, sep)
	local keys = {}
	for k,v in pairs(tbl) do
		if v then
			keys[#keys + 1] = k
		end
	end
	return table.concat(keys, sep)
end

local NetwTypes = false

local function collect_netw_types()
	NetwTypes = {}
	for k,v in pairs(networks.registered_networks.power) do
		NetwTypes[k] = "power"
	end
	for k,v in  pairs(networks.registered_networks.liquid) do
		NetwTypes[k] = "liquid"
	end
end

local function print_sides(pos, api, netw_type)
	local t = {}
	for _, dir in ipairs(networks.get_node_connection_dirs(pos, netw_type)) do
		t[#t + 1]= tubelib2.dir_to_string(dir)
	end
	print("# " .. api .. " - " .. netw_type .. " dirs: " .. table.concat(t, ", "))
end

local function print_power_network_data(pos, api, netw_type, outdir)
	local tlib2 = networks.registered_networks[api][netw_type]
	local data = power.get_network_data(pos, tlib2, outdir)
	local netw = networks.get_network_table(pos, tlib2, outdir)
	if netw then
		print("  - Number of network nodes: " .. (netw.num_nodes or 0))
		print("  - Number of generators: " .. #(netw.gen or {}))
		print("  - Number of consumers: " .. #(netw.con or {}))
		print("  - Number of storage systems: " .. #(netw.sto or {}))
	end
	if data then
		local s = string.format("  - Netw %u: generated = %u/%u, consumed = %u, storage load = %u/%u",
			data.netw_num, round(data.provided),
			data.available, round(data.consumed),
			round(data.curr_load), round(data.max_capa))
		print(s)
	end
end

local function print_liquid_network_data(pos, api, netw_type, outdir)
	local tlib2 = networks.registered_networks[api][netw_type]
	local netw = networks.get_network_table(pos, tlib2, outdir)
	if netw then
		print("  - Number of network nodes: " .. (netw.num_nodes or 0))
		print("  - Number of pumps: " .. #(netw.pump or {}))
		print("  - Number of tanks: " .. #(netw.tank or {}))
	end
end

local function print_netID(pos, api, netw_type)
	local tlib2 = networks.registered_networks[api][netw_type]
	for _,outdir in ipairs(networks.get_outdirs(pos, tlib2)) do
		local netID = networks.get_netID(pos, outdir)
		local s = tubelib2.dir_to_string(outdir)
		if netID then
			print("- " .. s .. ": netwNum for '" .. netw_type .. "': " .. networks.netw_num(netID))
			if api == "liquid" then
				print_liquid_network_data(pos, api, netw_type, outdir)
			elseif api == "power" then
				print_power_network_data(pos, api, netw_type, outdir)
			end
		else
			print("- " .. s .. ": Node has no '" .. netw_type .. "' netID!!!")
		end
	end
end

local function print_secondary_node(pos, api, netw_type)
	local tlib2 = networks.registered_networks[api][netw_type]
	if tlib2:is_secondary_node(pos) then
		print("- Secondary node: true")
	else
		print("- Is no secondary node!!!")
	end
end

local function print_valid_sides(name, api, netw_type)
	local tlib2 = networks.registered_networks[api][netw_type]
	local sides = tlib2.valid_node_contact_sides[name]
	if sides then
		print("- Valid node contact sides: " .. get_list(sides, ", "))
	else
		print("- Has no valid node contact sides!!!")
	end
end

local function print_connected_nodes(pos, api, netw_type)
	local tlib2 = networks.registered_networks[api][netw_type]
	for outdir = 1,6 do
		local destpos, indir = tlib2:get_connected_node_pos(pos, outdir)
		if destpos and tlib2:connected(destpos) then
			local s1 = tubelib2.dir_to_string(outdir)
			local s2 = tubelib2.dir_to_string(indir)
			local node = minetest.get_node(destpos)
			print("- " .. s1 .. ": Node connected to " .. node.name .. " at " .. P2S(destpos) .. " from " .. s2)
		end
	end
end

-- debug print of node related data
local function debug_print(pos)
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]

	if not NetwTypes then
		collect_netw_types()
	end

	if not ndef.networks then
		print("No networks node!!!")
		return
	end

	print("########## " .. node.name .. " ###########")

	for netw_type,api in pairs(NetwTypes) do
		if ndef.networks[netw_type] then
			print_sides(pos, api, netw_type)
			print_netID(pos, api, netw_type)
			print_secondary_node(pos, api, netw_type)
			print_valid_sides(node.name, api, netw_type)
			print_connected_nodes(pos, api, netw_type)
		end
	end

	print("#####################")
end

local function action(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local pos = pointed_thing.under
		networks.register_observe_pos(pos)
		if placer:get_player_control().sneak then
			debug_print(pos)
		else
			debug_print(pos)
		end
	else
		networks.register_observe_pos(nil)
	end
end

minetest.register_tool("networks:tool2", {
	description = "Debugging Tool",
	inventory_image = "networks_tool.png",
	wield_image = "networks_tool.png",
	use_texture_alpha = "clip",
	groups = {cracky=1},
	on_use = action,
	on_place = action,
	node_placement_prediction = "",
	stack_max = 1,
})
