--[[

	Hyperloop Mod
	=============

	Copyright (C) 2017-2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	Station reservation/blocking and trip booking
]]--

-- for lazy programmers
local SP = function(pos) if pos then return minetest.pos_to_string(pos) end end
--local P = minetest.string_to_pos
--local M = minetest.get_meta

local S = hyperloop.S
--local NS = hyperloop.NS

local tBlockingTime = {}
local tBookings = {}  -- open bookings: tBookings[SP(departure_pos)] = arrival_pos

local Stations = hyperloop.Stations

-- Reserve departure and arrival stations for some time
function hyperloop.reserve(departure_pos, arrival_pos, player)
	if Stations:get(departure_pos) == nil then
		hyperloop.chat(player, S("Station data is corrupted. Please rebuild the station!"))
		return false
	elseif Stations:get(arrival_pos) == nil then
		hyperloop.chat(player, S("Station data is corrupted. Please rebuild the station!"))
		return false
	end

	if (tBlockingTime[SP(departure_pos)] or 0) > minetest.get_gametime() then
		hyperloop.chat(player, S("Station is still blocked. Please try again in a few seconds!"))
		return false
	elseif (tBlockingTime[SP(arrival_pos)] or 0) > minetest.get_gametime() then
		hyperloop.chat(player, S("Station is still blocked. Please try again in a few seconds!"))
		return false
	end

	-- place a reservation for 20 seconds to start the trip
	tBlockingTime[SP(departure_pos)] = minetest.get_gametime() + 20
	tBlockingTime[SP(arrival_pos)] = minetest.get_gametime() + 20
	return true
end

-- block the already reserved stations
function hyperloop.block(departure_pos, arrival_pos, seconds)
	if Stations:get(departure_pos) == nil then
		return false
	elseif Stations:get(arrival_pos) == nil then
		return false
	end

	tBlockingTime[SP(departure_pos)] = minetest.get_gametime() + seconds
	tBlockingTime[SP(arrival_pos)] = minetest.get_gametime() + seconds
	return true
end

-- check if station is blocked
function hyperloop.is_blocked(pos)
	if not pos then return false end
	if Stations:get(pos) == nil then
		return false
	end

	return (tBlockingTime[SP(pos)] or 0) > minetest.get_gametime()
end


function hyperloop.set_arrival(departure_pos, arrival_pos)
	tBookings[SP(departure_pos)] = arrival_pos
end

function hyperloop.get_arrival(departure_pos)
	-- Return and delete the arrival pos
	local arrival_pos = tBookings[SP(departure_pos)]
	tBookings[SP(departure_pos)] = nil
	return arrival_pos
end
