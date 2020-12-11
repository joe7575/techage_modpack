--[[

	Minecart
	========

	Copyright (C) 2019-2020 Joachim Stolberg

	MIT
	See license.txt for more information
	
]]--

-- Some notes:
-- 1) Entity IDs are volatile. For each server restart all carts get new IDs.
-- 2) Monitoring is performed for entities only. Stopped carts in form of
--    real nodes need no monitoring.
-- 3) But nodes at stations have to call 'node_at_station' to be "visible"
--    for the chat commands


-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local S = minecart.S
local MP = minetest.get_modpath("minecart")
local lib = dofile(MP.."/cart_lib3.lua")

local CartsOnRail = minecart.CartsOnRail  -- from storage.lua
local get_route = minecart.get_route  -- from storage.lua
local NodesAtStation = {}

--
-- Helper functions
--
local function get_pos_vel_pitch_yaw(item)
	if item.start_time and item.start_key then  -- cart on recorded route
		local run_time = minetest.get_gametime() - item.start_time
		local waypoints = get_route(item.start_key).waypoints
		local waypoint = waypoints[run_time]
		if waypoint then
			return S2P(waypoint[1]), S2P(waypoint[2]), 0, 0
		end
	end
	if item.last_pos then
		item.last_pos = vector.round(item.last_pos)
		if carts:is_rail(item.last_pos, minetest.raillike_group("rail")) then
			return item.last_pos, item.last_vel, item.last_pitch or 0, item.last_yaw or 0
		end
		item.last_pos.y = item.last_pos.y - 1
		if carts:is_rail(item.last_pos, minetest.raillike_group("rail")) then
			return item.last_pos, item.last_vel, item.last_pitch or 0, item.last_yaw or 0
		end
	end
	return item.start_pos, {x=0, y=0, z=0}, 0, 0
end

--
-- Monitoring of cart entities
--
function minecart.add_to_monitoring(obj, myID, owner, userID)
	local pos = vector.round(obj:get_pos())
	CartsOnRail[myID] = {
		start_key = lib.get_route_key(pos),
		start_pos = pos,
		owner = owner,  -- needed for query API
		userID = userID,  -- needed for query API
		stopped = true,
		entity_name = obj:get_entity_name()
	}
end

-- Called after cart number formspec is closed
function minecart.update_userID(myID, userID)
	if CartsOnRail[myID] then
		CartsOnRail[myID].userID = userID
	end
end

-- When cart entity is removed
function minecart.remove_from_monitoring(myID)
	if myID then
		CartsOnRail[myID] = nil
		minecart.store_carts()
	end
end	

-- For node carts at stations
function minecart.node_at_station(owner, userID, pos)
	NodesAtStation[owner] = NodesAtStation[owner] or {}
	NodesAtStation[owner][userID] = pos
end
		
function minecart.start_cart(pos, myID)
	local item = CartsOnRail[myID]
	if item and item.stopped then
		item.stopped = false
		item.start_pos = pos
		item.start_time = nil
		-- cart started from a buffer?
		local start_key = lib.get_route_key(pos)
		if start_key then
			item.start_time = minetest.get_gametime()
			item.start_key = start_key
			item.junctions = minecart.get_route(start_key).junctions
			minecart.store_carts()
			return true
		end
	end
	return false
end

function minecart.stop_cart(pos, myID)
	local item = CartsOnRail[myID]
	if item and not item.stopped then
		item.start_time = nil
		item.start_key = nil
		item.start_pos = nil
		item.junctions = nil
		item.stopped = true
		minecart.store_carts()
		return true
	end
	return false
end

local function monitoring()
	local to_be_added = {}
	for key, item in pairs(CartsOnRail) do
		local entity = minetest.luaentities[key]
		--print("Cart:", key, item.owner, item.userID, item.stopped)
		if entity then  -- cart entity running
			local pos = entity.object:get_pos()
			local vel = entity.object:get_velocity()
			local rot = entity.object:get_rotation()
			if not minetest.get_node_or_nil(pos) then  -- unloaded area
				lib.unload_cart(pos, vel, entity, item)
				item.stopped = minecart.stopped(vel)
			end
			-- store last pos from cart
			item.last_pos, item.last_vel, item.last_pitch, item.last_yaw = pos, vel, rot.x, rot.y

		else  -- no cart running
			local pos, vel, pitch, yaw = get_pos_vel_pitch_yaw(item)
			if pos and vel then
				if minetest.get_node_or_nil(pos) then  -- loaded area
					if pitch > 0 then 
						pos.y = pos.y + 0.5 
					end
					local myID = lib.load_cart(pos, vel, pitch, yaw, item)
					if myID then
						item.stopped = minecart.stopped(vel)
						to_be_added[myID] = table.copy(item)
						CartsOnRail[key] = nil  -- invalid old ID 
					end
				end
				item.last_pos, item.last_vel, item.last_pitch, item.last_yaw = pos, vel, pitch, yaw
			else
				-- should never happen
				minetest.log("error", "[minecart] Cart of owner "..(item.owner or "nil").." got lost")
				CartsOnRail[key] = nil
			end
		end
	end
	-- table maintenance
	local is_changed = false
	for key,val in pairs(to_be_added) do
		CartsOnRail[key] = val
		is_changed = true
	end
	if is_changed then
		minecart.store_carts()
	end
	minetest.after(1, monitoring)
end
-- delay the start to prevent cart disappear into nirvana
minetest.register_on_mods_loaded(function()
	minetest.after(10, monitoring)
end)


--
-- API functions
--

-- Return a list of carts with current position and speed.
function minecart.get_cart_list()
	local tbl = {}
	for id, item in pairs(CartsOnRail) do
		local pos, speed = calc_pos_and_vel(item)
		tbl[#tbl+1] = {pos = pos, speed = speed, id = id}
	end
	return tbl
end

local function get_cart_pos(query_pos, cart_pos)
	local dist = math.floor(vector.distance(cart_pos, query_pos))
	local station = lib.get_station_name(cart_pos)
	return station or dist
end

local function get_cart_state(name, userID)
	for id, item in pairs(CartsOnRail) do
		if item.owner == name and item.userID == userID then
			return item.stopped and "stopped" or "running", item.last_pos
		end
	end
	return nil, nil
end	

minetest.register_chatcommand("mycart", {
	params = "<cart-num>",
	description = "Output cart state and position, or a list of carts, if no cart number is given.",
    func = function(name, param)
		local userID = tonumber(param)
		local query_pos = minetest.get_player_by_name(name):get_pos()
		
		if userID then
			-- First check if it is a node cart at a station
			local cart_pos = NodesAtStation[name] and NodesAtStation[name][userID]
			if cart_pos then
				local pos = get_cart_pos(query_pos, cart_pos)
				return true, "Cart #"..userID.." stopped at "..pos.."  "
			end
			-- Check all running carts
			local state, cart_pos = get_cart_state(name, userID)
			if state and cart_pos then
				local pos = get_cart_pos(query_pos, cart_pos)
				if type(pos) == "string" then
					return true, "Cart #"..userID.." stopped at "..pos.."  "
				elseif state == "running" then
					return true, "Cart #"..userID.." running "..pos.." m away  "
				else
					return true, "Cart #"..userID.." stopped "..pos.." m away  "
				end
			end
			return false, "Cart #"..userID.." is unknown"
		else
			-- Output a list with all numbers
			local tbl = {}
			for userID, pos in pairs(NodesAtStation[name] or {}) do
				tbl[#tbl + 1] = userID
			end
			for id, item in pairs(CartsOnRail) do
				if item.owner == name then
					tbl[#tbl + 1] = item.userID
				end
			end
			return true, "List of carts: "..table.concat(tbl, ", ").."  "
		end
    end
})

function minecart.cmnd_cart_state(name, userID)
	-- First check if it is a node cart at a station
	local pos = NodesAtStation[name] and NodesAtStation[name][userID]
	if pos then
		return "stopped"
	end
	return get_cart_state(name, userID)
end

function minecart.cmnd_cart_location(name, userID, query_pos)
	-- First check if it is a node cart at a station
	local station = NodesAtStation[name] and NodesAtStation[name][userID]
	if station then
		return station
	end
	local state, cart_pos = get_cart_state(name, userID)
	if state then
		return get_cart_pos(query_pos, cart_pos)
	end
end

minetest.register_on_mods_loaded(function()
	if minetest.global_exists("techage") then
		techage.icta_register_condition("cart_state", {
			title = "read cart state",
			formspec = {
				{
					type = "digits",
					name = "number",
					label = "cart number",
					default = "",
				},
				{
					type = "label", 
					name = "lbl", 
					label = "Read state from one of your carts", 
				},
			},
			button = function(data, environ)  -- default button label
				local number = tonumber(data.number) or 0
				return 'cart_state('..number..')'
			end,
			code = function(data, environ)
				local condition = function(env, idx)
					local number = tonumber(data.number) or 0
					return minecart.cmnd_cart_state(environ.owner, number)
				end
				local result = function(val)
					return val ~= 0
				end
				return condition, result
			end,
		})
		techage.icta_register_condition("cart_location", {
			title = "read cart location",
			formspec = {
				{
					type = "digits",
					name = "number",
					label = "cart number",
					default = "",
				},
				{
					type = "label", 
					name = "lbl", 
					label = "Read location from one of your carts", 
				},
			},
			button = function(data, environ)  -- default button label
				local number = tonumber(data.number) or 0
				return 'cart_loc('..number..')'
			end,
			code = function(data, environ)
				local condition = function(env, idx)
					local number = tonumber(data.number) or 0
					return minecart.cmnd_cart_location(environ.owner, number, env.pos)
				end
				local result = function(val)
					return val ~= 0
				end
				return condition, result
			end,
		})
		techage.lua_ctlr.register_function("cart_state", {
			cmnd = function(self, num) 
				num = tonumber(num) or 0
				return minecart.cmnd_cart_state(self.meta.owner, num)
			end,
			help = " $cart_state(num)\n"..
				" Read state from one of your carts.\n"..
				' "num" is the cart number\n'..
				' example: sts = $cart_state(2)'
		})
		techage.lua_ctlr.register_function("cart_location", {
			cmnd = function(self, num) 
				num = tonumber(num) or 0
				return minecart.cmnd_cart_location(self.meta.owner, num, self.meta.pos)
			end,
			help = " $cart_location(num)\n"..
				" Read location from one of your carts.\n"..
				' "num" is the cart number\n'..
				' example: sts = $cart_location(2)'
		})
	end
end)

