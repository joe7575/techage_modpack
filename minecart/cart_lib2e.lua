--[[

	Minecart
	========

	Copyright (C) 2019-2020 Joachim Stolberg

	MIT
	See license.txt for more information
	
	Cart library functions for entity based carts (level 2)
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = minecart.S
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local MP = minetest.get_modpath("minecart")

local api = dofile(MP.."/cart_lib3.lua")

-- Add node, set metadata, and load carge
local function add_cart(pos, node_name, param2, owner, userID, cargo)
	local obj = minetest.add_entity(pos, node_name)
	local myID = api.get_object_id(obj)
	if myID then
		-- Copy item data to cart entity
		local entity = obj:get_luaentity()
		entity.owner = owner
		entity.userID = userID
		entity.cargo = cargo
		entity.myID = myID
		obj:set_nametag_attributes({color = "#FFFF00", text = owner..": "..userID})
		minecart.add_to_monitoring(obj, myID, owner, userID)
		return myID
	else
		print("Entity has no ID")
	end
end

function api.stop_cart(pos, entity, node_name, param2)
	-- Stop sound
	if entity.sound_handle then
		minetest.sound_stop(entity.sound_handle)
		entity.sound_handle = nil
	end
	minecart.stop_cart(pos, entity.myID)
end


-- Player adds the node
function api.add_cart(itemstack, placer, pointed_thing, node_name)
	local owner = placer:get_player_name()
	local meta = placer:get_meta()
	local param2 = minetest.dir_to_facedir(placer:get_look_dir())
	local userID = 0
	local cargo = {}
	
	-- Add node
	if carts:is_rail(pointed_thing.under) then
		add_cart(pointed_thing.under, node_name, param2, owner, userID, cargo)
		meta:set_string("cart_pos", P2S(pointed_thing.under))
	elseif carts:is_rail(pointed_thing.above) then
		add_cart(pointed_thing.above, node_name, param2, owner, userID, cargo)
		meta:set_string("cart_pos", P2S(pointed_thing.above))
	else
		return
	end

	minetest.sound_play({name = "default_place_node_metal", gain = 0.5},
		{pos = pointed_thing.above})

	if not (creative and creative.is_enabled_for
			and creative.is_enabled_for(placer:get_player_name())) then
		itemstack:take_item()
	end
	
	minetest.show_formspec(owner, "minecart:userID_entity",
                "size[4,3]" ..
                "label[0,0;Enter cart number:]" ..
                "field[1,1;3,1;userID;;]" ..
                "button_exit[1,2;2,1;exit;Save]")	
	
	return itemstack
end

-- Player removes the node
function api.remove_cart(self, pos, player)
	-- Add cart to player inventory
	local inv = player:get_inventory()
	if not (creative and creative.is_enabled_for
			and creative.is_enabled_for(player:get_player_name()))
			or not inv:contains_item("main", "minecart:cart") then
		local leftover = inv:add_item("main", "minecart:cart")
		-- If no room in inventory add a replacement cart to the world
		if not leftover:is_empty() then
			minetest.add_item(pos, leftover)
		end
	end
	minecart.remove_from_monitoring(self.myID)
	self.object:remove()
	-- Stop sound
	if self.sound_handle then
		minetest.sound_stop(self.sound_handle)
		self.sound_handle = nil
	end
	return true
end

function api.load_cargo(self, pos) 
	self.cargo = self.cargo or {}
	for _, obj_ in pairs(minetest.get_objects_inside_radius(pos, 1)) do
		local entity = obj_:get_luaentity()
		if not obj_:is_player() and entity and entity.name == "__builtin:item" then
			obj_:remove()
			self.cargo[#self.cargo + 1] = entity.itemstring
		end
	end
end
	
function api.unload_cargo(self, pos) 
	-- Spawn loaded items again
	for _,item in ipairs(self.cargo or {}) do
		minetest.add_item(pos, ItemStack(item))
	end
	self.cargo = {}
end

-- in the case the owner punches the cart
function api.add_cargo_to_player_inv(self, pos, puncher)
	local added = false
	local inv = puncher:get_inventory()
	for _, obj in pairs(minetest.get_objects_inside_radius(pos, 1)) do
		local entity = obj:get_luaentity()
		if not obj:is_player() and entity and entity.name == "__builtin:item" then
			obj:remove()
			local item = ItemStack(entity.itemstring)
			local leftover = inv:add_item("main", item)
			if leftover:get_count() > 0 then
				minetest.add_item(pos, leftover)
			end
			added = true  -- don't dig the cart
		end
	end
	return added
end

return api
