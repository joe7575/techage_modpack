--[[

	Minecart
	========

	Copyright (C) 2019-2020 Joachim Stolberg

	MIT
	See license.txt for more information
	
	Cart library base functions (level 3)
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = minecart.S
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos

local api = {}

function api.get_object_id(object)
	for id, entity in pairs(minetest.luaentities) do
		if entity.object == object then
			return id
		end
	end
end

function api.get_route_key(pos, player_name)
	local pos1 = minetest.find_node_near(pos, 1, {"minecart:buffer"})
	if pos1 then
		local meta = minetest.get_meta(pos1)
		if player_name == nil or player_name == meta:get_string("owner") then
			return P2S(pos1)
		end
	end
end

function api.get_station_name(pos)
	local pos1 = minetest.find_node_near(pos, 1, {"minecart:buffer"})
	if pos1 then
		local name = M(pos1):get_string("name")
		if name ~= "" then
			return name
		end
		return "-"
	end
end

function api.load_cart(pos, vel, item)
	-- Add cart to map
	local obj = minetest.add_entity(pos, item.entity_name or "minecart:cart", nil)
	-- Determine ID
	local myID = api.get_object_id(obj)
	if myID then
		-- Copy item data to cart entity
		local entity = obj:get_luaentity()
		entity.owner = item.owner or ""
		entity.userID = item.userID or 0
		entity.cargo = item.cargo or {}
		entity.myID = myID
		obj:set_nametag_attributes({color = "#FFFF00", text = entity.owner..": "..entity.userID})
		-- Update item data
		item.owner = entity.owner
		item.cargo = nil
		-- Start cart
		obj:set_velocity(vel)
		return myID
	else
		print("Entity has no ID")
	end
end

function api.unload_cart(pos, vel, entity, item)
	-- Copy entity data to item
	item.cargo = entity.cargo
	item.entity_name = entity.object:get_entity_name()
	-- Remove entity from map
	entity.object:remove()
	-- Stop sound
	if entity.sound_handle then
		minetest.sound_stop(entity.sound_handle)
		entity.sound_handle = nil
	end
end

return api
