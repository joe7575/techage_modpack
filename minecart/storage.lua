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

local storage = minetest.get_mod_storage()

local function place_carts(t)
	local Carts = {
		["minecart:cart"] = "minecart:cart",
		["techage:tank_cart_entity"] = "techage:tank_cart",
		["techage:chest_cart_entity"] = "techage:chest_cart",
	}
	for id, item in pairs(t) do
		local pos = vector.round((item.start_pos or item.last_pos))
		local name = Carts[item.entity_name] or "minecart:cart"
		--print(P2S(pos), name, item.owner, item.userID)
		if minetest.registered_nodes[name] then
			minecart.add_nodecart(pos, name, 0, {}, item.owner or "", item.userID or 0)
		end
	end
end

-------------------------------------------------------------------------------
-- Store data of running carts
-------------------------------------------------------------------------------
minecart.CartsOnRail = {}

minetest.register_on_mods_loaded(function()
	local version = storage:get_int("version")
	if version < 2 then
		local t = minetest.deserialize(storage:get_string("CartsOnRail")) or {}
		minetest.after(5, place_carts, t)
		storage:set_int("version", 2)
	else
		local t = minetest.deserialize(storage:get_string("CartsOnRail")) or {}
		for owner, carts in pairs(t) do
			minecart.CartsOnRail[owner] = minecart.CartsOnRail[owner] or {}
			for userID, cart in pairs(carts) do
				if cart.objID then
					minecart.CartsOnRail[owner][userID] = cart
					-- mark all entity carts as zombified
					if cart.objID ~= 0 then
						cart.objID = -1
					end
					minecart.push(1, cart)
				end
			end
		end
	end
end)

minetest.register_on_shutdown(function()
	storage:set_string("CartsOnRail", minetest.serialize(minecart.CartsOnRail))
	print("minecart shutdown finished!!!")
end)

function minecart.store_carts()
	storage:set_string("CartsOnRail", minetest.serialize(minecart.CartsOnRail))
end

-------------------------------------------------------------------------------
-- Store routes (in buffers)
-------------------------------------------------------------------------------
function minecart.store_route(pos, route)
	if pos and route then
		M(pos):set_string("route", minetest.serialize(route))
		return true
	end
	return false
end

function minecart.get_route(pos)
	if pos then
		local s = M(pos):get_string("route")
		if s ~= "" then
			local route = minetest.deserialize(s)
			if route.waypoints then
				M(pos):set_string("route", "")
				M(pos):set_int("time", 0)
				return
			end
			return route
		end
	end
end

function minecart.del_route(pos)
	M(pos):set_string("route", "")
end
