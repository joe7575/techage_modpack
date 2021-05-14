--[[

	Minecart
	========

	Copyright (C) 2019-2021 Joachim Stolberg

	MIT
	See license.txt for more information
	
]]--

local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P2H = minetest.hash_node_position
local H2P = minetest.get_position_from_hash
local MAX_SPEED = minecart.MAX_SPEED
local dot2dir = minecart.dot2dir
local get_waypoint = minecart.get_waypoint
local recording_waypoints = minecart.recording_waypoints
local recording_junctions = minecart.recording_junctions
local set_junctions = minecart.set_junctions
local player_ctrl = minecart.player_ctrl
local tEntityNames = minecart.tEntityNames

local function stop_cart(self, cart_pos)
	self.is_running = false
	self.arrival_time = 0
	
	if self.driver then
		local player = minetest.get_player_by_name(self.driver)
		if player then
			minecart.stop_recording(self, cart_pos)	
			minecart.manage_attachment(player, self, false)
		end
	end
	if not minecart.get_buffer_pos(cart_pos, self.owner) then
		-- Probably somewhere in the pampas 
		minecart.delete_cart_waypoint(cart_pos)
	end
	minecart.entity_to_node(cart_pos, self)
end

local function get_ctrl(self, pos)
	-- Use player ctrl or junction data from recorded routes
	return (self.driver and self.ctrl) or (self.junctions and self.junctions[P2H(pos)]) or {}
end

local function new_speed(self, new_dir)
	self.cart_speed = self.cart_speed or 0
	local rail_speed = (self.waypoint.speed or 0) / 10
	
	if rail_speed <= 0 then
		rail_speed = math.max(self.cart_speed + rail_speed, 0)
	elseif rail_speed <= self.cart_speed then
		rail_speed = math.max((self.cart_speed + rail_speed) / 2, 0)
	end
	
	-- Speed corrections
	if new_dir.y == 1 then
		if rail_speed < 1 then rail_speed = 0 end
	else
		if rail_speed < 0.4 then rail_speed = 0 end
	end
	
	self.cart_speed = rail_speed -- store for next cycle
	return rail_speed
end

local function running(self)
	local rot = self.object:get_rotation()
	local dir = minetest.yaw_to_dir(rot.y)
	dir.y = math.floor((rot.x / (math.pi/4)) + 0.5)
	dir = vector.round(dir)
	local facedir = minetest.dir_to_facedir(dir)
	local cart_pos, wayp_pos, is_junction
	
	if self.reenter then -- through monitoring
		cart_pos = H2P(self.reenter[1])
		wayp_pos = cart_pos
		is_junction = false
		self.waypoint = {pos = H2P(self.reenter[2]), power = 0, dot = self.reenter[4]}
		self.cart_speed = self.reenter[3]
		self.speed_limit = MAX_SPEED
		self.reenter = nil
	elseif not self.waypoint then
		-- get waypoint
		cart_pos = vector.round(self.object:get_pos())
		wayp_pos = cart_pos
		is_junction = false
		self.waypoint = get_waypoint(cart_pos, facedir, get_ctrl(self, cart_pos), true)
		if self.no_normal_start then
			-- Probably somewhere in the pampas
			minecart.delete_waypoint(cart_pos)
			self.no_normal_start = nil
		end
		self.cart_speed = 2  -- push speed
		self.speed_limit = MAX_SPEED
	else
		-- next waypoint
		cart_pos = vector.new(self.waypoint.cart_pos or self.waypoint.pos)
		wayp_pos = self.waypoint.pos
		local vel = self.object:get_velocity()
		self.waypoint, is_junction = get_waypoint(wayp_pos, facedir, get_ctrl(self, wayp_pos), self.cart_speed < 0.1)
	end

	if not self.waypoint then
		stop_cart(self, wayp_pos)
		return
	end
	
	if is_junction then
		if self.is_recording then
			set_junctions(self, wayp_pos)
		end
		self.ctrl = nil
	end
	
	--print("dist", P2S(cart_pos), P2S(self.waypoint.pos), P2S(self.waypoint.cart_pos), self.waypoint.dot)
	local dist = vector.distance(cart_pos, self.waypoint.cart_pos or self.waypoint.pos)
	local new_dir = dot2dir(self.waypoint.dot)
	local new_speed = new_speed(self, new_dir)
	local straight_ahead = vector.equals(new_dir, dir)
	-- If straight_ahead, then it's probably a speed limit sign
	if straight_ahead then
		self.speed_limit = minecart.get_speedlimit(wayp_pos, facedir) or self.speed_limit
	end
	new_speed = math.min(new_speed, self.speed_limit)
	
	local new_cart_pos, extra_cycle = minecart.get_current_cart_pos_correction(
			wayp_pos, facedir, dir.y, self.waypoint.dot)  -- TODO: Why has self.waypoint no dot?
	if extra_cycle and not vector.equals(cart_pos, new_cart_pos) then
		self.waypoint = {pos = wayp_pos, cart_pos = new_cart_pos}
		new_dir = vector.direction(cart_pos, new_cart_pos)
		dist = vector.distance(cart_pos, new_cart_pos)
		--print("extra_cycle", P2S(cart_pos), P2S(wayp_pos), P2S(new_cart_pos), new_speed)
	end
	
	-- Slope corrections
	--print("Slope corrections", P2S(new_dir), P2S(cart_pos))
	if new_dir.y ~= 0 then
		cart_pos.y = cart_pos.y + 0.2
	end	
	
	-- Calc velocity, rotation and arrival_time
	local yaw = minetest.dir_to_yaw(new_dir)
	local pitch = new_dir.y * math.pi/4
	--print("new_speed", new_speed / (new_dir.y ~= 0 and 1.41 or 1))
	local vel = vector.multiply(new_dir, new_speed / ((new_dir.y ~= 0) and 1.41 or 1))
	self.arrival_time = self.timebase + (dist / new_speed)
	-- needed for recording
	self.curr_speed = new_speed  
	self.num_sections = (self.num_sections or 0) + 1
	
	-- Got stuck somewhere
	if new_speed < 0.1 or dist < 0 then
		print("Got stuck somewhere", new_speed, dist)
		stop_cart(self, wayp_pos)
		return
	end
	
	self.object:set_pos(cart_pos)
	self.object:set_rotation({x = pitch, y = yaw, z = 0})
	self.object:set_velocity(vel)
	return
end

local function play_sound(self)
	if self.sound_handle then
		local handle = self.sound_handle
		self.sound_handle = nil
		minetest.after(0.2, minetest.sound_stop, handle)
	end
	if self.object then
		self.sound_handle = minetest.sound_play(
			"carts_cart_moving", {
			object = self.object,
			gain = self.curr_speed / MAX_SPEED,
		})
	end
end

local function on_step(self, dtime)
	self.timebase = (self.timebase or 0) + dtime
	
	if self.is_running then
		if self.arrival_time <= self.timebase then
			running(self)
		end
		
		if (self.sound_ttl or 0) <= self.timebase then
			play_sound(self)
			self.sound_ttl = self.timebase + 1.0
		end
	else
		if self.sound_handle then
			minetest.sound_stop(self.sound_handle)
			self.sound_handle = nil
		end		
	end

	if self.driver then
		if self.is_recording then
			if self.rec_time <= self.timebase then
				recording_waypoints(self)
				self.rec_time = self.rec_time + 2.0
			end
			recording_junctions(self)
		else
			player_ctrl(self)
		end
	end
end

local function on_entitycard_activate(self, staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
end

-- Start the entity cart (or dig by shift+leftclick)
local function on_entitycard_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
	if minecart.is_owner(puncher, self.owner) then
		if puncher:get_player_control().sneak then
			if not self.only_dig_if_empty or not next(self.cargo) then
				-- drop items
				local pos = vector.round(self.object:get_pos())
				for _,item in ipairs(self.cargo or {}) do
					minetest.add_item(pos, ItemStack(item))
				end
				-- Dig cart
				if self.driver then
					-- remove cart as driver
					minecart.stop_recording(self, pos)	
					minecart.monitoring_remove_cart(self.owner, self.userID)
					minecart.remove_entity(self, pos, puncher)
					minecart.manage_attachment(puncher, self, false)
				else
					-- remove cart from outside
					minecart.monitoring_remove_cart(self.owner, self.userID)				
					minecart.remove_entity(self, pos, puncher)
				end
			end
		elseif not self.is_running then
			-- start the cart
			local pos = vector.round(self.object:get_pos())
			if puncher then
				local yaw = puncher:get_look_horizontal()
				self.object:set_rotation({x = 0, y = yaw, z = 0})
			end
			minecart.start_entitycart(self, pos)
			minecart.start_recording(self, pos) 
		end
	end
end
	
-- Player get on / off
local function on_entitycard_rightclick(self, clicker)
	if clicker and clicker:is_player() and self.driver_allowed then
		-- Get on / off
		if self.driver then
			-- get off
			local pos = vector.round(self.object:get_pos())
			minecart.manage_attachment(clicker, self, false)
			minecart.entity_to_node(pos, self)
		else
			-- get on
			local pos = vector.round(self.object:get_pos())
			minecart.stop_recording(self, pos)	
			minecart.manage_attachment(clicker, self, true)
		end
	end
end

local function on_entitycard_detach_child(self, child)
	if child and child:get_player_name() == self.driver then
		self.driver = nil
	end
end

function minecart.get_entitycart_nearby(pos, param2, radius)
	local pos2 = param2 and vector.add(pos, minecart.param2_to_dir(param2)) or pos
	for _, object in pairs(minetest.get_objects_inside_radius(pos2, radius or 0.5)) do
		local entity = object:get_luaentity()
		if entity and entity.name and tEntityNames[entity.name] then
			local vel = object:get_velocity()
			if vector.equals(vel, {x=0, y=0, z=0}) then  -- still standing?
				return entity
			end
		end
	end	
end

function minecart.push_entitycart(self, punch_dir)
	--print("push_entitycart")
	local vel = self.object:get_velocity()
	punch_dir.y = 0
	local yaw = minetest.dir_to_yaw(punch_dir)
	self.object:set_rotation({x = 0, y = yaw, z = 0})
	self.is_running = true
	self.arrival_time = 0
end

function minecart.register_cart_entity(entity_name, node_name, cart_type, entity_def)
	entity_def.entity_name = entity_name
	entity_def.node_name = node_name
	entity_def.on_activate = on_entitycard_activate
	entity_def.on_punch = on_entitycard_punch
	entity_def.on_step = on_step
	entity_def.on_rightclick = on_entitycard_rightclick
	entity_def.on_detach_child = on_entitycard_detach_child
	
	entity_def.owner = nil
	entity_def.driver = nil
	entity_def.cargo = {}
	
	minetest.register_entity(entity_name, entity_def)
	-- register node for punching
	minecart.register_cart_names(node_name, entity_name, cart_type)
end

