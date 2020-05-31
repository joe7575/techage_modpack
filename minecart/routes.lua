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

local CartsOnRail = minecart.CartsOnRail

--
-- Helper functions
--
local function get_object_id(object)
	for id, entity in pairs(minetest.luaentities) do
		if entity.object == object then
			return id
		end
	end
end

local function get_route_key(pos, player_name)
	local pos1 = minetest.find_node_near(pos, 1, {"minecart:buffer"})
	if pos1 then
		local meta = minetest.get_meta(pos1)
		if player_name == nil or player_name == meta:get_string("owner") then
			return P2S(pos1)
		end
	end
end

--
-- Recording
--
function minecart.add_cart_to_monitoring(obj, owner, cargo)
	--print("add_cart_to_monitoring", dump(cargo))
	local self = obj:get_luaentity()
	self.myID = get_object_id(obj)
	self.owner = owner
	local pos = self.object:get_pos()
	CartsOnRail[self.myID] = {
		start_key = get_route_key(pos),
		start_pos = pos,
		stopped = true,
		owner = owner,
		entity_name = self.name,
		cargo = cargo,
	}
	return self.myID
end

function minecart.start_recording(self, pos, vel, puncher)	
	-- Player punches cart to start the trip
	if puncher:get_player_name() == self.driver and vector.equals(vel, {x=0, y=0, z=0}) then
		self.start_key = get_route_key(pos, self.driver)
		if self.start_key then
			self.waypoints = {}
			self.junctions = {}
			self.recording = true
			self.next_time = minetest.get_us_time() + 1000000
			minetest.chat_send_player(self.driver, S("[minecart] Start route recording!"))
		end
	end
end

function minecart.store_next_waypoint(self, pos, vel)	
	if self.start_key and self.recording and self.driver and 
			self.next_time < minetest.get_us_time() then
		self.next_time = minetest.get_us_time() + 1000000
		self.waypoints[#self.waypoints+1] = {P2S(vector.round(pos)), P2S(vector.round(vel))}
		
		local dest_pos = get_route_key(pos, self.driver)
		if vector.equals(vel, {x=0, y=0, z=0}) and dest_pos then
			if self.start_key ~= dest_pos then
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
			self.recording = false
			self.waypoints = nil
			self.junctions = nil
		end
	elseif self.recording and not self.driver then
		self.recording = false
		self.waypoints = nil
		self.junctions = nil
	end
end

function minecart.set_junction(self, pos, dir, switch_keys)
	local junctions = CartsOnRail[self.myID] and CartsOnRail[self.myID].junctions
	if junctions then
		if self.junctions then
			self.junctions[minetest.pos_to_string(vector.round(pos))] = {dir, switch_keys}
		end
	end
end

function minecart.get_junction(self, pos, dir)
	local junctions = CartsOnRail[self.myID] and CartsOnRail[self.myID].junctions
	if junctions then
		local data = junctions[minetest.pos_to_string(vector.round(pos))]
		if data then
			return data[1], data[2]
		end
	end
	return dir
end

--
-- Normal operation
--
function minecart.start_run(self, pos, vel, driver)
	if vector.equals(vel, {x=0, y=0, z=0}) then
		local start_key = get_route_key(pos)
		if not start_key then
			if driver then -- Punched from inside the cart
				-- Don't start the cart
				self.velocity = {x=0, y=0, z=0}
				minetest.chat_send_player(driver, S("[minecart] Please start at a Railway Buffer!"))
				return
			end
			-- Add also carts without route to be able to restore last pos/vel
			minetest.log("info", "[minecart] Cart "..self.myID.." started.")
			--print("start_run", dump(CartsOnRail[self.myID]))
			CartsOnRail[self.myID].stopped = false
		else -- Add cart to monitoring
			minetest.log("info", "[minecart] Cart "..self.myID.." started.")
			--print("start_run", dump(CartsOnRail[self.myID]))
			local item = CartsOnRail[self.myID]
			item.start_time = minetest.get_gametime()
			item.start_key = start_key
			item.stopped = false
			item.junctions = minecart.get_route(start_key).junctions
		end
	end
end

function minecart.attach_cargo(self, pos)
	local data = CartsOnRail[self.myID]
	if data then
		data.attached_items = {}
		for _, obj_ in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			local entity = obj_:get_luaentity()
			if not obj_:is_player() and entity and entity.name == "__builtin:item" then
				obj_:remove()
				data.attached_items[#data.attached_items + 1] = entity.itemstring
			end
		end
	end
end

function minecart.detach_cargo(self, pos, data)
	-- Spawn loaded items again
	if data.attached_items then
		for _,item in ipairs(data.attached_items) do
			minetest.add_item(pos, ItemStack(item))
		end
	end
end

function minecart.stopped(self, pos)
	local data = CartsOnRail[self.myID]
	if data and not data.stopped then
		minecart.detach_cargo(self, pos, data)
		data.stopped = true
		data.start_key = get_route_key(pos)
		data.start_pos = pos
		data.start_time = nil
		minetest.log("info", "[minecart] Cart "..self.myID.." stopped.")
		if self.sound_handle then
			minetest.sound_stop(self.sound_handle)
		end
		return data.cargo or {} -- for node based carts
	end
end

function minecart.on_dig(self)
	if self and self.myID then
		CartsOnRail[self.myID] = nil
	end
end

--
-- Monitoring
--
local function spawn_cart(pos, vel, item)
--	local node = minetest.get_node(pos)
--	if not minetest.tValidCarts[node.name] then
	local pos2 = vector.round(pos)
	if carts:is_rail(pos2) or carts:is_rail({x = pos2.x, y = pos2.y-1, z = pos2.z}) then
		local obj = minetest.add_entity(pos, item.entity_name or "minecart:cart", nil)
		obj:set_velocity(vel)
		local id = minecart.add_cart_to_monitoring(obj, item.owner)
		minetest.log("info", "[minecart] Cart "..id.." spawned again.")
		return id
	end
end

local function calc_pos_and_vel(item)
	if item.start_time and item.start_key then
		local run_time = minetest.get_gametime() - item.start_time
		local waypoints = minecart.get_route(item.start_key).waypoints
		local waypoint = waypoints[run_time]
		if waypoint then
			return minetest.string_to_pos(waypoint[1]), minetest.string_to_pos(waypoint[2])
		end
	end
	if item.last_pos then
		return item.last_pos, item.last_vel
	end
	return item.start_pos, {x=0, y=0, z=0}
end

local function monitoring()
	local to_be_added = {}
	for key, item in pairs(CartsOnRail) do
		--print("Cart:", key, P2S(item.start_pos), item.owner)
		if not item.recording then
			local entity = minetest.luaentities[key]
			if entity then  -- cart in loaded area
				local pos = entity.object:get_pos()
				local vel = entity.object:get_velocity()
				if not minetest.get_node_or_nil(pos) then  -- in unloaded area
					minetest.log("info", "[minecart] Cart "..key.." virtualized.")
					if entity.sound_handle then
						minetest.sound_stop(entity.sound_handle)
					end
					if vector.equals(vel, {x=0, y=0, z=0}) then
						minecart.attach_cargo(entity, pos)
					end
					entity.object:remove()
				end
				-- store last pos from cart without route
				item.last_pos, item.last_vel = pos, vel
			else  -- cart in unloaded area
				local pos, vel = calc_pos_and_vel(item)
				if pos and vel then
					if minetest.get_node_or_nil(pos) then  -- in loaded area
						local id = spawn_cart(pos, vel, item)
						if id then
							to_be_added[id] = table.copy(item)
							CartsOnRail[key] = nil
						end
					end
				else
					CartsOnRail[key] = nil
				end
			end
		end
	end
	-- table maintenance
	for key,val in pairs(to_be_added) do
		CartsOnRail[key] = val
	end
	minetest.after(1, monitoring)
end
minetest.after(1, monitoring)

minecart.calc_pos_and_vel = calc_pos_and_vel

--
-- API function to get a list of cart data with current position and speed.
--
function minecart.get_cart_list()
	local tbl = {}
	for id, item in pairs(CartsOnRail) do
		local pos, speed = calc_pos_and_vel(item)
		tbl[#tbl+1] = {pos = pos, speed = speed, id = id}
	end
	return tbl
end

-- minecart.get_route_key(pos, player_name)
minecart.get_route_key = get_route_key
