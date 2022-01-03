--[[

	Hyperloop Mod
	=============

	Copyright (C) 2017-2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	mod storage and data integrity
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

hyperloop.Stations = hyperloop.Network:new()
hyperloop.Elevators = hyperloop.Network:new()


-- Check all nodes on the map and delete useless data base entries
local function check_data_base()
	-- used for VM get_node
	local tube = tubelib2.Tube:new({})
	
	hyperloop.Stations:filter(function(pos) 
		local _,node = tube:get_node(pos)
		return node.name == "hyperloop:station" or node.name == "hyperloop:junction"	
	end)

	hyperloop.Elevators:filter(function(pos) 
		local _,node = tube:get_node(pos)
		return node.name == "hyperloop:elevator_bottom"	
	end)
end	

local storage = minetest.get_mod_storage()
hyperloop.Stations:deserialize(storage:get_string("Stations"))
hyperloop.Elevators:deserialize(storage:get_string("Elevators"))

local function update_mod_storage()
	minetest.log("action", "[Hyperloop] Store data...")
	storage:set_string("Stations", hyperloop.Stations:serialize())
	storage:set_string("Elevators", hyperloop.Elevators:serialize())
	-- store data each hour
	minetest.after(60*60, update_mod_storage)
	minetest.log("action", "[Hyperloop] Data stored")
end

minetest.register_on_shutdown(function()
	update_mod_storage()
end)

-- delete data base entries without corresponding nodes
--minetest.after(5, check_data_base)

-- store data after one hour
minetest.after(60*60, update_mod_storage)
