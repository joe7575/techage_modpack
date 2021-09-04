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

local tCartsOnRail = minecart.CartsOnRail
local Queue = {}
local first = 0
local last = -1

local function push(cycle, item)
	last = last + 1
	item.cycle = cycle
	Queue[last] = item
end

local function pop(cycle)
	if first > last then return end
	local item = Queue[first]
	if item.cycle < cycle then
		Queue[first] = nil -- to allow garbage collection
		first = first + 1
		return item
	end
end

local function is_player_nearby(pos)
	for _, object in pairs(minetest.get_objects_inside_radius(pos, 64)) do
		if object:is_player() then
			return true
		end
	end
end

local function zombie_to_entity(pos, cart, checkpoint)
	local vel = {x = 0, y = 0, z = 0}
	local obj = minecart.add_entitycart(pos, cart.node_name, cart.entity_name, 
				vel, cart.cargo, cart.owner, cart.userID)
	if obj then
		local entity = obj:get_luaentity()
		entity.reenter = checkpoint
		entity.junctions = cart.junctions
		entity.is_running = true
		entity.arrival_time = 0
		cart.objID = entity.objID
	end
end

local function get_checkpoint(cart)
	local cp = cart.checkpoints[cart.idx]
	if not cp then
		cart.idx = #cart.checkpoints
		cp = cart.checkpoints[cart.idx]
	end
	local pos = H2P(cp[1])
--	if M(pos):contains("waypoints") then
--		print("get_checkpoint", P2S(H2P(cp[1])), P2S(H2P(cp[2])))
--	end
	return cp, cart.idx == #cart.checkpoints
end

-- Function returns the cart state ("running" / "stopped") and
-- the station name or position string, or if cart is running, 
-- the distance to the query_pos.
local function get_cart_state_and_loc(name, userID, query_pos)
	if tCartsOnRail[name] and tCartsOnRail[name][userID] then
		local cart = tCartsOnRail[name][userID]
		local pos = cart.last_pos or cart.pos
		local loc = minecart.get_buffer_name(cart.pos) or
				math.floor(vector.distance(pos, query_pos))
		if cart.objID == 0 then
			return "stopped",  minecart.get_buffer_name(cart.pos) or
					math.floor(vector.distance(pos, query_pos)), cart.node_name
		else
			return "running", math.floor(vector.distance(pos, query_pos)), cart.node_name
		end
	end
	return "unknown", 0, "unknown"
end	

local function get_cart_info(owner, userID, query_pos)
	local state, loc, name = get_cart_state_and_loc(owner, userID, query_pos)
	local cart_type = minecart.tCartTypes[name] or "unknown"
	if type(loc) == "number" then
		return "Cart #" .. userID .. " (" .. cart_type .. ") " .. state .. " " .. loc .. " m away  "
	else
		return "Cart #" .. userID .. " (" .. cart_type .. ") " .. state .. " at ".. loc .. "  "
	end
end

local function monitoring(cycle)
    local cart = pop(cycle)
	
    while cart do
		-- All running cars
		if cart.objID and cart.objID ~= 0 then
			cart.idx = cart.idx + 1
			local entity = minetest.luaentities[cart.objID]
			if entity then  -- cart entity running
				local pos = entity.object:get_pos()
				if pos then
					cart.last_pos = vector.round(pos)
					--print("entity card " .. cart.userID .. " at " .. P2S(cart.last_pos))
				else
					minetest.log("warning", "[Minecart] entity card without pos!")
				end
				push(cycle, cart)
			elseif cart.checkpoints then
				local cp, last_cp = get_checkpoint(cart)
				if cp then
					cart.last_pos = H2P(cp[1])
					--print("zombie " .. cart.userID .. " at " .. P2S(cart.last_pos))
					if is_player_nearby(cart.last_pos) or last_cp then
						zombie_to_entity(cart.last_pos, cart, cp)
					end
					push(cycle, cart)
				else
					minetest.log("warning", "[Minecart] zombie got lost")
				end
			else
				local pos = cart.last_pos or cart.pos
				pos = minecart.add_nodecart(pos, cart.node_name, 0, cart.cargo, cart.owner, cart.userID)
				cart.objID = 0
				cart.pos = pos
				--print("cart to node", cycle, cart.userID, P2S(pos))
			end
		elseif cart and not cart.objID and tCartsOnRail[cart.owner] then
			-- Delete carts marked as "to be deleted"
			tCartsOnRail[cart.owner][cart.userID] = nil
		end
		cart = pop(cycle)
	end
	minetest.after(2, monitoring, cycle + 1)
end

minetest.after(5, monitoring, 2)


function minecart.monitoring_add_cart(owner, userID, pos, node_name, entity_name)
	--print("monitoring_add_cart", owner, userID)
	tCartsOnRail[owner] = tCartsOnRail[owner] or {}
	tCartsOnRail[owner][userID] = {
		owner = owner,
		userID = userID,
		objID = 0,
		pos = pos,
		idx = 0,
		node_name = node_name,
		entity_name = entity_name,
	}
	minecart.store_carts()
end
	
function minecart.start_monitoring(owner, userID, pos, objID, checkpoints, junctions, cargo)
	--print("start_monitoring", owner, userID)
	if tCartsOnRail[owner] and tCartsOnRail[owner][userID] then
		tCartsOnRail[owner][userID].pos = pos
		tCartsOnRail[owner][userID].objID = objID
		tCartsOnRail[owner][userID].checkpoints = checkpoints
		tCartsOnRail[owner][userID].junctions = junctions
		tCartsOnRail[owner][userID].cargo = cargo
		tCartsOnRail[owner][userID].idx = 0
		push(0, tCartsOnRail[owner][userID])
		minecart.store_carts()
	end
end

function minecart.stop_monitoring(owner, userID, pos)
	--print("stop_monitoring", owner, userID)
	if tCartsOnRail[owner] and tCartsOnRail[owner][userID] then
		tCartsOnRail[owner][userID].pos = pos
		tCartsOnRail[owner][userID].objID = 0
		minecart.store_carts()
	end
end

function minecart.monitoring_remove_cart(owner, userID)
	--print("monitoring_remove_cart", owner, userID)
	if tCartsOnRail[owner] and tCartsOnRail[owner][userID] then
		tCartsOnRail[owner][userID].objID = nil
		tCartsOnRail[owner][userID] = nil
		minecart.store_carts()
	end
end

function minecart.monitoring_valid_cart(owner, userID, pos, node_name)
	if tCartsOnRail[owner] and tCartsOnRail[owner][userID] then
		return vector.equals(tCartsOnRail[owner][userID].pos, pos) and 
				tCartsOnRail[owner][userID].node_name == node_name
	end
end

function minecart.userID_available(owner, userID)
	return not tCartsOnRail[owner] or tCartsOnRail[owner][userID] == nil
end

function minecart.get_cart_monitoring_data(owner, userID)
	if tCartsOnRail[owner] then
		return tCartsOnRail[owner][userID]
	end
end


--
-- API functions
--

-- Needed by storage to re-construct the queue after server start
minecart.push = push

minetest.register_chatcommand("mycart", {
	params = "<cart-num>",
	description = S("Output cart state and position, or a list of carts, if no cart number is given."),
    func = function(owner, param)
		local userID = tonumber(param)
		local query_pos = minetest.get_player_by_name(owner):get_pos()
		
		if userID then
			return true, get_cart_info(owner, userID, query_pos)
		elseif tCartsOnRail[owner] then
			-- Output a list with all numbers
			local tbl = {}
			for userID, cart in pairs(tCartsOnRail[owner]) do
				tbl[#tbl + 1] = userID
			end
			return true, S("List of carts") .. ": "..table.concat(tbl, ", ").."  "
		end
    end
})

minetest.register_chatcommand("stopcart", {
	params = "<cart-num>",
	description = S("Stop amd return a missing/running cart."),
    func = function(owner, param)
		local userID = tonumber(param)
		local player_pos = minetest.get_player_by_name(owner):get_pos()
		if userID then
			local data = minecart.get_cart_monitoring_data(owner, userID)
			if data then
				if data.objID and data.objID ~= 0 then
					local entity = minetest.luaentities[data.objID]
					if entity then  -- cart entity running
						minecart.entity_to_node(player_pos, entity)
						minecart.monitoring_remove_cart(owner, userID)
					end
				else
					local pos = data.last_pos or data.pos
					local cargo, _, _ = minecart.remove_nodecart(pos)
					minecart.add_nodecart(player_pos, data.node_name, 0, cargo, owner, userID)
					minecart.monitoring_remove_cart(owner, userID)
				end
				return true, S("Cart") .. " " .. userID .. " " .. S("stopped")
			else
				return false, S("Cart") .. " " .. userID .. " " .. S("is not existing!")
			end
		end
    end
})

function minecart.cmnd_cart_state(name, userID)
	local state, loc = get_cart_state_and_loc(name, userID, {x=0, y=0, z=0})
	return state
end

function minecart.cmnd_cart_location(name, userID, query_pos)
	local state, loc = get_cart_state_and_loc(name, userID, query_pos)
	return loc
end

function minecart.get_cart_list(pos, name)
	local userIDs = {}
	local carts = {}
	
	for userID, cart in pairs(tCartsOnRail[name] or {}) do
		userIDs[#userIDs + 1] = userID
	end
	
	table.sort(userIDs, function(a,b) return a < b end)
	
	for _, userID in ipairs(userIDs) do
		carts[#carts + 1] = get_cart_info(name, userID, pos)
	end
	
	return table.concat(carts, "\n")
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
