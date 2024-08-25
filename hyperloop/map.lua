--[[

	Hyperloop Mod
	=============

	Copyright (C) 2017-2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

]]--

-- for lazy programmers
local SP = function(pos) if pos then return minetest.pos_to_string(pos) end end
--local P = minetest.string_to_pos
--local M = minetest.get_meta

-- Load support for intllib.
local S = hyperloop.S

local Stations = hyperloop.Stations

-- Return a text block with all given station names and their attributes
local function generate_string(sortedList)
	-- Generate a list with lStationPositions[pos] = idx
	-- used to generate the "connected with" list.
	local lStationPositions = {}
	for idx,item in ipairs(sortedList) do
		local sKey = SP(item.pos)
		lStationPositions[sKey] = idx
	end

	local tRes = {
		"label[0,0;ID]"..
		"label[0.7,0;"..S("Dist.").."]"..
		"label[1.8,0;"..S("Station/Junction").."]"..
		"label[5.4,0;"..S("Position").."]"..
		"label[7.9,0;"..S("Owner").."]"..
		"label[10,0;"..S("Conn. to").."]"}
	for idx,dataSet in ipairs(sortedList) do
		if idx == 23 then
			break
		end
		local ypos = 0.2 + idx * 0.4
		local owner = dataSet.owner or "<unknown>"
		local name = dataSet.name or "<unknown>"
		local distance = dataSet.distance or 0

		tRes[#tRes+1] = "label[0,"..ypos..";"..idx.."]"
		tRes[#tRes+1] = "label[0.7,"..ypos..";"..distance.." m]"
		tRes[#tRes+1] = "label[1.8,"..ypos..";"..string.sub(name,1,24).."]"
		tRes[#tRes+1] = "label[5.4,"..ypos..";"..SP(dataSet.pos).."]"
		tRes[#tRes+1] = "label[7.9,"..ypos..";"..string.sub(owner,1,14).."]"
		tRes[#tRes+1] = "label[10,"..ypos..";"
		for dir,conn in pairs(dataSet.conn) do
			if conn and lStationPositions[conn] then
				tRes[#tRes + 1] = lStationPositions[conn]
				tRes[#tRes + 1] = ", "
			else
				tRes[#tRes + 1] = conn
				tRes[#tRes + 1] = ", "
			end
		end
		tRes[#tRes] = "]"
	end
	return table.concat(tRes)
end

local function station_list_as_string(pos)
	-- Generate a distance sorted list of all stations
	local sortedList = Stations:station_list(pos, nil, "dist")
	-- Generate the formspec string
	return generate_string(sortedList)
end

local function network_list_as_string(pos)
	-- Determine next station position
	local next_pos = Stations:get_next_station(pos)
	-- Generate a distance sorted list of all connected stations
	local sortedList = Stations:station_list(pos, next_pos, "dist")
	-- Generate the formspec string
	return generate_string(sortedList)
end

local function map_on_use(itemstack, user)
	local player_name = user:get_player_name()
	local pos = user:get_pos()
	local sStationList = station_list_as_string(pos)
	local formspec = "size[12,10]" ..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	sStationList ..
	"button_exit[5,9.5;2,1;close;"..S("Close").."]"

	minetest.show_formspec(player_name, "hyperloop:station_map", formspec)
	return itemstack
end

local function map_on_secondary_use(itemstack, user)
	local player_name = user:get_player_name()
	local pos = user:get_pos()
	local sStationList = network_list_as_string(pos)
	local formspec = "size[12,10]" ..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	sStationList ..
	"button_exit[5,9.5;2,1;close;"..S("Close").."]"

	minetest.show_formspec(player_name, "hyperloop:station_map", formspec)
	return itemstack
end

-- Tool for tube workers to find the next station
minetest.register_node("hyperloop:station_map", {
	description = S("Hyperloop Station Book"),
	inventory_image = "hyperloop_stations_book.png",
	wield_image = "hyperloop_stations_book.png",
	groups = {cracky=1, book=1},
	on_use = map_on_use,
	on_place = map_on_secondary_use,
	on_secondary_use = map_on_secondary_use,
	stack_max = 1,
})

