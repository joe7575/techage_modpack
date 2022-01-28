--[[

	Minecart
	========

	Copyright (C) 2019-2021 Joachim Stolberg

	MIT
	See license.txt for more information
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local P2H = minetest.hash_node_position
local H2P = minetest.get_position_from_hash
local S = minecart.S

local function dashboard_destroy(self)
	if self.driver and self.hud_id then
		local player = minetest.get_player_by_name(self.driver)
		if player then
			player:hud_remove(self.hud_id)
			self.hud_id = nil
		end
	end
end

local function dashboard_create(self)
	if self.driver then	
		local player = minetest.get_player_by_name(self.driver)
		if player then
			dashboard_destroy(self)
			self.hud_id = player:hud_add({
				name = "minecart",
				hud_elem_type = "text",
				position = {x = 0.4, y = 0.25},
				scale = {x=100, y=100},
				text = "Recording:",
				number = 0xFFFFFF,
				size = {x = 1},
			})
		end
	end
end

local function dashboard_update(self)
	if self.driver and self.hud_id then
		local player = minetest.get_player_by_name(self.driver)
		if player then
			local time = self.runtime or 0
			local dir = (self.ctrl and self.ctrl.left and S("left")) or 
					(self.ctrl and self.ctrl.right and S("right")) or S("straight")
			local speed = math.floor((self.curr_speed or 0) + 0.5)
			local s = string.format(S("Recording") .. 
					" | " .. S("speed") .. 
					": %.1f | " .. S("next junction") .. 
					": %-8s | " .. S("Travel time") .. ": %.1f s", 
					speed, dir, time)
			player:hud_change(self.hud_id, "text", s)
		end
	end
end

local function check_waypoint(self, pos)
	-- If next waypoint already reached but not handled
	-- determine next waypoint
	if vector.equals(pos, self.waypoint.pos) then
		local rot = self.object:get_rotation()
		local dir = minetest.yaw_to_dir(rot.y)
		dir.y = math.floor((rot.x / (math.pi/4)) + 0.5)
		local facedir = minetest.dir_to_facedir(dir)
		local waypoint = minecart.get_waypoint(pos, facedir, self.ctrl or {}, false)
		if waypoint then
			return waypoint.pos
		end
	end
	return self.waypoint.pos
end

--
-- Route recording
--
function minecart.start_recording(self, pos)	
	--print("start_recording")
	if self.driver then
		self.start_pos = minecart.get_buffer_pos(pos, self.driver)
		if self.start_pos then
			self.checkpoints = {} -- {cart_pos, next_waypoint_pos, speed, dot}
			self.junctions = {}
			self.is_recording = true
			self.rec_time = self.timebase
			self.hud_time = self.timebase
			self.runtime = 0
			self.num_sections = 0
			self.sum_speed = 0
			self.ctrl = {}
			dashboard_create(self)
			dashboard_update(self, 0)
		end
	end
end

function minecart.stop_recording(self, pos, force_exit)	
	--print("stop_recording")
	if self.driver and self.is_recording then
		local dest_pos = minecart.get_buffer_pos(pos, self.driver)
		local player = minetest.get_player_by_name(self.driver)
		if force_exit then
			minetest.chat_send_player(self.driver, S("[minecart] Recording canceled!"))
		elseif dest_pos and player and #self.checkpoints > 3 then
			-- Remove last checkpoint, because it is potentially too close to the dest_pos
			table.remove(self.checkpoints) 
			if self.start_pos then
				local route = {
					dest_pos = dest_pos,
					checkpoints = self.checkpoints,
					junctions = self.junctions,
				}
				minecart.store_route(self.start_pos, route)
				minetest.chat_send_player(self.driver, S("[minecart] Route stored!"))
				local speed = self.sum_speed / #self.checkpoints
				local length = speed * self.runtime
				local fmt = S("[minecart] Speed = %u m/s, Time = %u s, Route length = %u m")
				minetest.chat_send_player(self.driver, string.format(fmt, speed, self.runtime, length))
				minecart.update_buffer_infotext(self.start_pos)
			end
		elseif #self.checkpoints <= 3 then
			minetest.chat_send_player(self.driver, S("[minecart] Your route is too short to record!"))
		end
		dashboard_destroy(self)
	end
	self.is_recording = false
	self.checkpoints = nil
	self.waypoints = nil
	self.junctions = nil
end

function minecart.recording_waypoints(self)	
	local pos = vector.round(self.object:get_pos())
	-- pos correction on slopes
	if not minecart.is_rail(pos) then
		pos.y = pos.y - 1
	end
	-- hier müsste überprüfung dest_pos rein
	self.sum_speed = self.sum_speed + self.curr_speed 
	local wp_pos = check_waypoint(self, pos)
	self.checkpoints[#self.checkpoints+1] = {
		-- cart_pos, next_waypoint_pos, speed, dot
		P2H(pos), 
		P2H(wp_pos), 
		math.floor(self.curr_speed + 0.5),
		self.waypoint.dot
	}
end

function minecart.recording_junctions(self)
	local player = minetest.get_player_by_name(self.driver)
	if player then
		local ctrl = player:get_player_control()
		if ctrl.left then
			self.ctrl = {left = true}
		elseif ctrl.right then
			self.ctrl = {right = true}
		elseif ctrl.up or ctrl.down then
			self.ctrl = nil
		elseif ctrl.jump then
			return true
		end
	end
	if self.hud_time <= self.timebase then
		dashboard_update(self)
		self.hud_time = self.timebase + 0.5
		self.runtime = self.runtime + 0.5
	end
end

function minecart.set_junctions(self, wayp_pos)
	if self.ctrl then
		self.junctions[P2H(wayp_pos)] = self.ctrl
	end
end

function minecart.player_ctrl(self)
	local player = minetest.get_player_by_name(self.driver)
	if player then
		local ctrl = player:get_player_control()
		if ctrl.left then
			self.ctrl = {left = true}
		elseif ctrl.right then
			self.ctrl = {right = true}
		elseif ctrl.jump then
			return true
		end
	end
end
