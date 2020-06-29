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
local MP = minetest.get_modpath("minecart")
local lib = dofile(MP.."/cart_lib3.lua")

local CartsOnRail = minecart.CartsOnRail  -- from storage.lua
local get_route = minecart.get_route  -- from storage.lua

--
-- Route recording
--
function minecart.start_recording(self, pos)	
	self.start_key = lib.get_route_key(pos, self.driver)
	if self.start_key then
		self.waypoints = {}
		self.junctions = {}
		self.recording = true
		self.next_time = minetest.get_us_time() + 1000000
		minetest.chat_send_player(self.driver, S("[minecart] Start route recording!"))
	end
end

function minecart.store_next_waypoint(self, pos, vel)	
	if self.start_key and self.recording and self.driver and 
			self.next_time < minetest.get_us_time() then
		self.next_time = minetest.get_us_time() + 1000000
		self.waypoints[#self.waypoints+1] = {P2S(vector.round(pos)), P2S(vector.round(vel))}
	elseif self.recording and not self.driver then
		self.recording = false
		self.waypoints = nil
		self.junctions = nil
	end
end

-- destination reached(speed == 0)
function minecart.stop_recording(self, pos, vel, puncher)	
	local dest_pos = lib.get_route_key(pos, self.driver)
	if dest_pos then
		if self.start_key and self.start_key ~= dest_pos then
			local route = {
				waypoints = self.waypoints,
				dest_pos = dest_pos,
				junctions = self.junctions,
			}
			minecart.store_route(self.start_key, route)
			minetest.chat_send_player(self.driver, S("[minecart] Route stored!"))
		else
			minetest.chat_send_player(self.driver, S("[minecart] Recording canceled!"))
		end
	else
		minetest.chat_send_player(self.driver, S("[minecart] Recording canceled!"))
	end
	self.recording = false
	self.waypoints = nil
	self.junctions = nil
end

function minecart.set_junction(self, pos, dir, switch_keys)
	if self.junctions then
		self.junctions[P2S(vector.round(pos))] = {dir, switch_keys}
	end
end

function minecart.get_junction(self, pos, dir)
	local junctions = CartsOnRail[self.myID] and CartsOnRail[self.myID].junctions
	if junctions then
		local data = junctions[P2S(vector.round(pos))]
		if data then
			return data[1], data[2]
		end
	end
	return dir
end

