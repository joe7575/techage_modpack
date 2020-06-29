--[[

	Minecart
	========

	Copyright (C) 2019-2020 Joachim Stolberg

	MIT
	See license.txt for more information
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local S = minecart.S

local storage = minetest.get_mod_storage()

-------------------------------------------------------------------------------
-- Store data of running carts
-------------------------------------------------------------------------------
minecart.CartsOnRail = {}

minetest.register_on_mods_loaded(function()
	for key,val in pairs(minetest.deserialize(storage:get_string("CartsOnRail")) or {}) do
		-- use invalid keys to force the cart spawning
		minecart.CartsOnRail[-key] = val
	end
end)

minetest.register_on_shutdown(function()
	storage:set_string("CartsOnRail", minetest.serialize(minecart.CartsOnRail))
end)

function minecart.store_carts()
	storage:set_string("CartsOnRail", minetest.serialize(minecart.CartsOnRail))
end

-------------------------------------------------------------------------------
-- Store routes
-------------------------------------------------------------------------------
-- All positions as "pos_to_string" string
--Routes = {
--	  start_pos = {
--        waypoints = {{spos, svel}, {spos, svel}, ...}, 
--        dest_pos = spos,
--        junctions = {
--            {spos = num}, 
--            {spos = num},
--        },
--    },
--	  start_pos = {...},
--}
local Routes = {}
local NEW_ROUTE = {waypoints = {}, junctions = {}}

function minecart.store_route(key, route)
	if key and route then
		Routes[key] = route
		local meta = M(S2P(key))
		if meta then
			meta:set_string("route", minetest.serialize(route))
			return true
		end
	end
	return false
end

function minecart.get_route(key)
	if not Routes[key] then
		local s = M(S2P(key)):get_string("route")
		if s ~= "" then
			Routes[key] = minetest.deserialize(s) or NEW_ROUTE
		else
			Routes[key] = NEW_ROUTE
		end
	end
	return Routes[key]
end

function minecart.del_route(key)
	Routes[key] = nil  -- remove from memory
	M(S2P(key)):set_string("route", "") -- and as metadata
end

-------------------------------------------------------------------------------
-- Convert data to v2
-------------------------------------------------------------------------------
minetest.after(5, function()
	local tbl = storage:to_table()
	for key,s in pairs(tbl.fields) do
		if key ~= "CartsOnRail" then
			local route = minetest.deserialize(s)
			if route.waypoints and route.junctions then
				if minecart.store_route(key, route) then
					storage:set_string(key, "")
				end
			else
				storage:set_string(key, "")
			end
		end
	end
end)


