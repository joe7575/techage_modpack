--[[

	Networks
	========

	Copyright (C) 2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta
local N = tubelib2.get_node_lvm

local Networks = {} -- cache for networks: {netw_type = {netID = <network>, ...}, ...}
local NetIDs = {}   -- cache for netw IDs: {pos_hash = {outdir = netID, ...}, ...}

local MAX_NUM_NODES = 1000  -- per network including junctions
local TTL = 5 * 60  -- 5 minutes
local Route = {} -- Used to determine the already passed nodes while walking
local NumNodes = 0  -- Used to determine the number of network nodes

local Flip = tubelib2.Turn180Deg
local get_nodename = networks.get_nodename
local get_node = networks.get_node
local tubelib2_get_pos = tubelib2.get_pos
local tubelib2_side_to_dir = tubelib2.side_to_dir

-------------------------------------------------------------------------------
-- Debugging
-------------------------------------------------------------------------------
-- Table for all registered tubelib2 instances
networks.registered_networks = {}  -- {api_type = {instance,...}}

-- Maintain simple numbers for the bulky netID hashes
local DbgNetIDs = {}
local DbgCounter = 1

local function netw_num(netID)
	if not netID or netID < 1 then
		return netID or 0
	end
	if not DbgNetIDs[netID] then
		DbgNetIDs[netID] = DbgCounter
		DbgCounter = DbgCounter + 1
	end
	return DbgNetIDs[netID]
end

local function network_nodes(netID, network)
	local tbl = {}
	for node_type,table in pairs(network or {}) do
		if type(table) == "table" then
			tbl[#tbl+1] = "#" .. node_type .. " = " .. #table
		end
	end
	tbl[#tbl+1] = "num_nodes = " .. (network.num_nodes or 0)
	return "Network " .. netw_num(netID) .. ": " .. table.concat(tbl, ", ")
end

-- Marker entities for debugging purposes
function networks.set_marker(pos, text, size, ttl)
	local marker = minetest.add_entity(pos, "networks:marker_cube")
	if marker ~= nil then
		marker:set_nametag_attributes({color = "#FFFFFF", text = text})
		size = size or 1
		marker:set_properties({visual_size = {x = size, y = size}})
		if ttl then
			minetest.after(ttl, marker.remove, marker)
		end
	end
end

minetest.register_entity("networks:marker_cube", {
	initial_properties = {
		visual = "cube",
		textures = {
			"networks_marker.png",
			"networks_marker.png",
			"networks_marker.png",
			"networks_marker.png",
			"networks_marker.png",
			"networks_marker.png",
		},
		physical = false,
		visual_size = {x = 1.1, y = 1.1},
		collisionbox = {-0.55,-0.55,-0.55, 0.55,0.55,0.55},
		glow = 8,
		static_save = false,
	},
	on_punch = function(self)
		self.object:remove()
	end,
})

-------------------------------------------------------------------------------
-- Helper
-------------------------------------------------------------------------------
-- return the networks table from the node definition
local function net_def(pos, netw_type)
	local ndef = minetest.registered_nodes[get_nodename(pos)]
	if ndef and ndef.networks then
		return ndef.networks[netw_type]
	end
	error("Node " ..  get_nodename(pos) .. " at ".. P2S(pos) .. " has no 'ndef.networks'")
end

local function net_def2(pos, node_name, netw_type)
	local ndef = minetest.registered_nodes[node_name]
	if ndef and ndef.networks then
		return ndef.networks[netw_type]
	end
	return net_def(pos, netw_type)
end

-- Don't allow direct connections between to nodes of the same type
local function valid_secondary_node_connection(tlib2, pos, dir)
	local node1 = tlib2:get_secondary_node(pos, dir)
	if node1 then
		local node2 = N(pos)
		local ndef1 = minetest.registered_nodes[node1.name]
		local ndef2 = minetest.registered_nodes[node2.name]
		local ntype1 = ((ndef1.networks or {})[tlib2.tube_type] or {}).ntype
		local ntype2 = ((ndef2.networks or {})[tlib2.tube_type] or {}).ntype
		return ntype1 == "junc" or ntype1 ~= ntype2
	end
end

-- Returns true if node is connected with another network node
local function connected(tlib2, pos, dir)
	local param2, npos = tlib2:get_primary_node_param2(pos, dir)
	if param2 then
		local d1, d2, num = tlib2:decode_param2(npos, param2)
		if not num then return end
		return Flip[dir] == d1 or Flip[dir] == d2
	end
	-- secondary nodes allowed?
	if tlib2.force_to_use_tubes then
		return tlib2:is_special_node(pos, dir)
	else
		return valid_secondary_node_connection(tlib2, pos, dir)
	end
end

local function side_to_outdir(pos, side)
	return tubelib2.side_to_dir(side, N(pos).param2)
end

-- determine outdir based on node type
local function get_outdir(node_type, indir)
	if node_type == "junc" then
		return 0 -- same network on all sides
	else
		return Flip[indir]
	end
end

-------------------------------------------------------------------------------
-- Node Connections
-------------------------------------------------------------------------------

-- Get tlib2 connection dirs as table
-- used e.g. for the connection walk
local function get_node_connection_dirs(pos, netw_type)
	local val = M(pos):get_int(netw_type.."_conn")
    local tbl = {}
    if val % 0x40 >= 0x20 then tbl[#tbl+1] = 1 end
    if val % 0x20 >= 0x10 then tbl[#tbl+1] = 2 end
    if val % 0x10 >= 0x08 then tbl[#tbl+1] = 3 end
    if val % 0x08 >= 0x04 then tbl[#tbl+1] = 4 end
    if val % 0x04 >= 0x02 then tbl[#tbl+1] = 5 end
    if val % 0x02 >= 0x01 then tbl[#tbl+1] = 6 end
    return tbl
end

local function get_node_connection_dirs_table(pos, netw_type)
	local val = M(pos):get_int(netw_type.."_conn")
    local tbl = {}
    if val % 0x40 >= 0x20 then tbl[1] = true end
    if val % 0x20 >= 0x10 then tbl[2] = true end
    if val % 0x10 >= 0x08 then tbl[3] = true end
    if val % 0x08 >= 0x04 then tbl[4] = true end
    if val % 0x04 >= 0x02 then tbl[5] = true end
    if val % 0x02 >= 0x01 then tbl[6] = true end
    return tbl
end

-- store all node sides with tube connections as nodemeta
local function store_node_connection_sides(pos, tlib2)
	local node = get_node(pos)
	local val = 0
	for dir = 1,6 do
		val = val * 2
		if tlib2:is_valid_dir(node, dir) and connected(tlib2, pos, dir) then
			val = val + 1
		end
	end
	M(pos):set_int(tlib2.tube_type.."_conn", val)
end

-- If outdir is given, return outdir, otherwise return all valid node dirs with tube connections
local function get_outdirs(pos, tlib2, outdir)
	if outdir then
		return {outdir}
	end
	return get_node_connection_dirs(pos, tlib2.tube_type)
end

-------------------------------------------------------------------------------
-- Connection Walk
-------------------------------------------------------------------------------
local function pos_already_reached(pos)
	local key = minetest.hash_node_position(pos)
	if not Route[key] and NumNodes < MAX_NUM_NODES then
		Route[key] = true
		NumNodes = NumNodes + 1
		return false
	end
	return true
end

-- check if the given tube dir into the node is valid
local function valid_indir(pos, indir, node, tlib2)
	local outdir = Flip[indir]
	return tlib2:is_valid_dir(node, outdir)
end

local function is_junction(pos, name, tlib2)
	local ndef = net_def2(pos, name,  tlib2.tube_type)
	if ndef then
		return ndef.ntype == "junc"
	end
end

-- Do the walk through the tubelib2 network.
-- `indir` is the direction which should not be covered by the walk
-- (coming from there).
-- if outdir is given, only this dir is used
local function connection_walk(pos, outdir, indir, node, tlib2, clbk)
	if clbk then clbk(pos, indir, node) end
	if outdir or is_junction(pos, node.name, tlib2) then
		for _,outdir in ipairs(get_outdirs(pos, tlib2, outdir)) do
			local pos2, indir2 = tlib2:get_connected_node_pos(pos, outdir)
			local node = get_node(pos2)
			if valid_indir(pos2, indir2, node, tlib2) and not pos_already_reached(pos2) then
				connection_walk(pos2, nil, indir2, node, tlib2, clbk)
			end
		end
	end
end

local function collect_network_nodes(pos, tlib2, outdir)
	local t = minetest.get_us_time()
	Route = {}
	NumNodes = 0
	pos_already_reached(pos)
	local netw = {}
	local node = N(pos)
	local netw_type = tlib2.tube_type
	local tbl = get_node_connection_dirs_table(pos, netw_type)
	if tbl[outdir] then -- valid conncetion
		-- outdir corresponds to the indir coming from
		connection_walk(pos, outdir, Flip[outdir], node, tlib2, function(pos, indir, node)
			local ndef = net_def2(pos, node.name, netw_type)
			if ndef then
				local ntype = ndef.ntype
				if not netw[ntype] then netw[ntype] = {} end
				netw[ntype][#netw[ntype] + 1] = {pos = pos, indir = indir}
			end
		end)
	end
	netw.ttl = minetest.get_gametime() + TTL
	netw.num_nodes = NumNodes
	t = minetest.get_us_time() - t
	--print("collect_network_nodes in " .. t .. " us", NumNodes, P2S(pos), N(pos).name)
	return netw
end

-------------------------------------------------------------------------------
-- Maintain Network
-------------------------------------------------------------------------------
local function set_network(netw_type, netID, network)
	assert(netID)
	if netID > 0 then
		Networks[netw_type] = Networks[netw_type] or {}
		Networks[netw_type][netID] = network
		Networks[netw_type][netID].ttl = minetest.get_gametime() + TTL
	end
end

-- Return network if available, or dummy network.
-- The function updates the network TTL, thus keeping the network alive.
local function get_network(netw_type, netID)
	assert(netID)
	if netID > 0 then
		local netw = Networks[netw_type] and Networks[netw_type][netID]
		if netw then
			netw.ttl = minetest.get_gametime() + TTL
			return netw
		end
	end
	return {num_nodes = 0}
end

local function delete_network(netw_type, netID)
	assert(netID)
	if netID > 0 then
		if Networks[netw_type] and Networks[netw_type][netID] then
			Networks[netw_type][netID] = nil
		end
	end
end

-- Keep data in memory small
local function remove_outdated_networks()
	local to_be_deleted = {}
	local t = minetest.get_gametime()
	for net_name,tbl in pairs(Networks) do
		for netID,network in pairs(tbl) do
			local valid = (network.ttl or 0) - t
			if valid < 0 then
				to_be_deleted[#to_be_deleted+1] = {net_name, netID}
			end
		end
	end
	for _,item in ipairs(to_be_deleted) do
		local net_name, netID = unpack(item)
		Networks[net_name][netID] = nil
		--print("Network " .. netw_num(netID) .. " timed out")
	end
	minetest.after(60, remove_outdated_networks)
end
minetest.after(60, remove_outdated_networks)

-------------------------------------------------------------------------------
-- Maintain netID
-------------------------------------------------------------------------------
local function set_netID(pos, outdir, netID)
	local hash = minetest.hash_node_position(pos)
	NetIDs[hash] = NetIDs[hash] or {}
	NetIDs[hash][outdir] = netID
end

local function get_netID(pos, outdir)
	local hash = minetest.hash_node_position(pos)
	NetIDs[hash] = NetIDs[hash] or {}
	return NetIDs[hash][outdir]
end

-- determine network ID (largest hash number of all nodes with given type)
local function determine_netID(netw)
	local netID = 0
	for node_type, table in pairs(netw) do
		if type(table) == "table" then
			for _, item in ipairs(netw[node_type] or {}) do
				local outdir = Flip[item.indir]
				local new = minetest.hash_node_position(item.pos) * 8 + outdir
				if netID <= new then
					netID = new
				end
			end
		end
	end
	return netID
end

-- store network ID for each network node
local function store_netID(tlib2, netw, netID)
	for node_type, table in pairs(netw) do
		if type(table) == "table" then
			for _, item in ipairs(table) do
				local outdir = get_outdir(node_type, item.indir)
				set_netID(item.pos, outdir, netID)
			end
		end
	end
	set_network(tlib2.tube_type, netID, netw)
end

-- delete network and netID for all nodes in the network
-- `outdir` shall be 0 for junctions
local function delete_netID(pos, tlib2, outdir)
	local netID = get_netID(pos, outdir)
	if netID then
		local netw = get_network(tlib2.tube_type, netID)
		for node_type, table in pairs(netw) do
			if type(table) == "table" then
				for _, item in ipairs(table) do
					local outdir = get_outdir(node_type, item.indir)
					set_netID(item.pos, outdir, nil)
				end
			end
		end
		set_netID(pos, outdir, nil)
		delete_network(tlib2.tube_type, netID)
	end
end

-------------------------------------------------------------------------------
-- API Functions
-------------------------------------------------------------------------------

networks.MAX_NUM_NODES = MAX_NUM_NODES

-- Table for a 180 degree turn: indir => outdir and vice versa
networks.Flip = tubelib2.Turn180Deg

-- networks.net_def(pos, netw_type)
networks.net_def = net_def

--	sides:                               outdir:
--              U
--              |    B
--              |   /                              6  (N)
--           +--|-----+                            |  1
--          /   o    /|                            | /
--         +--------+ |                            |/
--  L <----|        |o----> R        (W) 4 <-------+-------> 2 (O)
--         |    o   | |                           /|
--         |   /    | +                          / |
--         |  /     |/                          3  |
--         +-/------+                        (S)   5
--          /   |
--         F    |
--              D
--

-- Determine the pos relative to the given 'pos', 'param2'
-- and the path based on 'sides' like "FUL"
function networks.get_relpos(pos, sides, param2)
	local pos1 = {x = pos.x, y = pos.y, z = pos.z}
	for side in sides:gmatch(".") do
		pos1 = tubelib2_get_pos(pos1, tubelib2_side_to_dir(side, param2))
	end
	return pos1
end

-- networks.side_to_outdir(pos, side)
networks.side_to_outdir = side_to_outdir

-- networks.is_junction(pos, name, tlib2)
networks.is_junction = is_junction

-- Return a simple number instead of the netID
-- Useful for debuging purposes
-- networks.netw_num(netID)
networks.netw_num = netw_num

-- For debugging purposes
-- networks.network_nodes(netID, network)
networks.network_nodes = network_nodes

-- networks.get_network(netw_type, netID)
networks.get_network = get_network

-- return the networks table from the node definition
-- networks.net_def(pos, netw_type)
networks.net_def = net_def

-- Function returns {outdir} or all node dirs with connections
-- networks.get_outdirs(pos, tlib2, outdir)
networks.get_outdirs = get_outdirs

-- Provide own netID
-- networks.get_netID(pos, outdir)
networks.get_netID = get_netID

-- networks.get_node_connection_dirs(pos, netw_type)
networks.get_node_connection_dirs = get_node_connection_dirs

-- To be called from each node via 'tubelib2_on_update2'
-- 'output' is optional and only needed for nodes with dedicated
-- pipe sides. Junctions have to provide 0 (= same network on all sides).
function networks.update_network(pos, outdir, tlib2, node)
	store_node_connection_sides(pos, tlib2) -- update node internal data
	delete_netID(pos, tlib2, outdir) -- delete node netIDs and network
end

-- Provide or determine netID
function networks.determine_netID(pos, tlib2, outdir)
	assert(outdir)
	local netID = get_netID(pos, outdir)
	if netID and Networks[tlib2.tube_type] and Networks[tlib2.tube_type][netID] then
		return netID
	elseif netID == 0 then
		return -- no network available
	end

	local netw = collect_network_nodes(pos, tlib2, outdir)
	if netw.num_nodes > 1 then
		netID = determine_netID(netw)
		store_netID(tlib2, netw, netID)
		return netID
	end
	-- mark as "no network"
	set_netID(pos, outdir, 0)
end

-- Provide network with all node tables
function networks.get_network_table(pos, tlib2, outdir)
	assert(outdir)
	local netID = networks.determine_netID(pos, tlib2, outdir)
	if netID and netID > 0 then
		return get_network(tlib2.tube_type, netID)
	end
end
