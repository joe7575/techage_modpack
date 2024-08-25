--[[

	Hyperloop Mod
	=============

	Copyright (C) 2017-2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	mod storage and data integrity
]]--

-- for lazy programmers
--local P = minetest.string_to_pos
--local M = minetest.get_meta

hyperloop.Stations = hyperloop.Network:new()
hyperloop.Elevators = hyperloop.Network:new()

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
