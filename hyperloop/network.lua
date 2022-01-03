--[[

	Hyperloop Mod
	=============

	Copyright (C) 2017-2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	Station and elevator network management
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Convert to list and add pos based on key string
local function table_to_list(table)
	local lRes = {}
	for key,item in pairs(table) do 
		item.pos = P(key)
		lRes[#lRes+1] = item 
	end
	return lRes
end

local function distance(pos1, pos2)
	return math.floor(math.abs(pos1.x - pos2.x) + 
			math.abs(pos1.y - pos2.y) + math.abs(pos1.z - pos2.z))
end

-- Add the distance to pos to each list item
local function add_distance_to_list(lStations, pos)
	for _,item in ipairs(lStations) do 
		item.distance = distance(item.pos, pos)
	end
	return lStations
end

-- Add the index to each list item
local function add_index_to_list(lStations)
	-- walk through the list of floors for the next connection
	local get_next = function(key, idx)
		for _,floor in ipairs(lStations) do
			if floor.conn[6] == key then  -- upward match?
				floor.idx = idx
				return S(floor.pos) -- return floor key
			end
		end
	end
	
	local key = nil
	for idx = 1,#lStations do
		key = get_next(key, idx)
	end
	return lStations
end

-- Return a table with all stations, the given station (as 'sKey') is connected with
-- tRes is used for the resulting table (recursive call)
local function get_stations(tStations, sKey, tRes)
	if not tStations[sKey] or not tStations[sKey].conn then 
		return {} 
	end
	for dir,dest in pairs(tStations[sKey].conn) do
		-- Not already visited?
		if not tRes[dest] then
			-- Known station?
			if tStations[dest] then
				tStations[dest].name = tStations[dest].name or ""
				tRes[dest] = tStations[dest]
				get_stations(tStations, dest, tRes)
			end
		end
	end
	return tRes
end

-- Return a list with sorted elevators, beginning with the top car
-- with no shaft upwards
local function sort_based_on_level(tStations)
	local lStations = table_to_list(table.copy(tStations))
	-- to be able to sort the list, an index has to be added
	lStations = add_index_to_list(lStations)
	table.sort(lStations, function(a,b) return (a.idx or 9999) < (b.idx or 9999) end)
	return lStations
end
	
-- Return a list with sorted stations
local function sort_based_on_distance(tStations, pos)
	local lStations = table_to_list(table.copy(tStations))
	-- to be able to sort the list, the distance to pos has to be added
	lStations = add_distance_to_list(lStations, pos)
	table.sort(lStations, function(a,b) return a.distance < b.distance end)
	return lStations
end

-- Return a list with sorted stations
local function sort_based_on_name(tStations, pos)
	local lStations = table_to_list(table.copy(tStations))
	-- Add distance 
	lStations = add_distance_to_list(lStations, pos)
	table.sort(lStations, function(a,b) return a.name < b.name end)
	return lStations
end


--
-- Class Network
--

--[[
	tStations["(x,y,z)"] = {
		["conn"] = {
			dir = "(200,0,20)",
		},
	}
	change_counter = n,
]]--


local Network = {}
hyperloop.Network = Network

function Network:new()
	local o = {
		tStations = {},
		change_counter = 0,
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Set an elevator or station entry.
-- tAttr is a table with additional attributes to be stored.
function Network:set(pos, name, tAttr)
	if pos then
		local sKey = S(pos)
		if not self.tStations[sKey] then
			self.tStations[sKey] = {
				conn = {},
			}
		end
		self.tStations[sKey].name = name or ""
		for k,v in pairs(tAttr) do
			self.tStations[sKey][k] = v
		end
		self.change_counter = self.change_counter + 1
	end
end

-- Update an elevator or station entry.
-- tAttr is a table with additional attributes to be stored.
function Network:update(pos, tAttr)
	if pos then
		local sKey = S(pos)
		if self.tStations[sKey] then
			for k,v in pairs(tAttr) do
				if v == "nil" then
					self.tStations[sKey][k] = nil
				else
					self.tStations[sKey][k] = v
				end
			end
			self.change_counter = self.change_counter + 1
		end
	end
end

function Network:get(pos)
	return pos and self.tStations[S(pos)]
end

-- Delete an elevator or station entry.
function Network:delete(pos)
	if pos then
		self.tStations[S(pos)] = nil
		self.change_counter = self.change_counter + 1
	end
end

function Network:changed(counter)
	return self.change_counter > counter, self.change_counter
end
	
-- Update the connection data base. The output dir information is needed
-- to be able to delete a connection, if necessary.
-- Returns true, if data base is changed.
function Network:update_connections(pos, out_dir, conn_pos)
	local sKey = S(pos)
	local res = false
	if not self.tStations[sKey] then
		self.tStations[sKey] = {}
		res = true
	end
	if not self.tStations[sKey].conn then
		self.tStations[sKey].conn = {}
		res = true
	end
	conn_pos = S(conn_pos)
	if self.tStations[sKey].conn[out_dir] ~= conn_pos then
		self.tStations[sKey].conn[out_dir] = conn_pos
		res = true
	end
	if res then
		self.change_counter = self.change_counter + 1
	end
	return res
end

-- Return the nearest station position
function Network:get_next_station(pos)
	local min_dist = 999999
	local min_key = nil
	local dist
	for key,item in pairs(self.tStations) do
		if not item.junction then
			dist = distance(pos, P(key))
			if dist < min_dist then
				min_dist = dist
				min_key = key
			end
		end
	end
	return P(min_key)
end

-- Return a sorted list of stations
-- Param pos: player pos
-- Param station_pos: next station pos or nil.
--                    Used to generate list with connected stations only
-- Param sorted: either "dist" or "level"
function Network:station_list(pos, station_pos, sorted)
	local tStations, lStations
	if station_pos then
		local tRes = {}
		tStations = get_stations(self.tStations, S(station_pos), tRes) -- reduced
	else
		tStations = self.tStations  -- all stations
	end
	if sorted == "dist" then
		lStations = sort_based_on_distance(tStations, pos)
	elseif sorted == "level" then
		lStations = sort_based_on_level(tStations)
	else
		-- delete own station from list
		tStations[S(station_pos)] = nil
		lStations = sort_based_on_name(tStations, pos)
	end
	return lStations
end

-- Check the complete table by means of the provided callback bool = func(pos)
function Network:filter(callback)
	local lKeys = {}
	for key,_ in pairs(self.tStations) do
		lKeys[#lKeys+1] = key
	end
	for _,key in ipairs(lKeys) do
		if not callback(P(key)) then
			self.tStations[key] = nil
		end
	end
end

function Network:deserialize(data)
	if data ~= "" then
		data = minetest.deserialize(data)
		self.tStations = data.tStations
		self.change_counter = data.change_counter
	end
end
	
function Network:serialize()
	return minetest.serialize(self)
end
	
-- Return a pos/item table with all network nodes, the node at pos is connected with
function Network:get_node_table(pos)
	local tRes = {}
	local key = S(pos)
	get_stations(self.tStations, key, tRes)	
	tRes[key] = nil
	return tRes
end
