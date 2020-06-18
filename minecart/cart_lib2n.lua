--[[

	Minecart
	========

	Copyright (C) 2019-2020 Joachim Stolberg

	MIT
	See license.txt for more information
	
	Cart library functions for node based carts (level 2)
	
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
	local ndef = minetest.registered_nodes[node_name]
	local node = minetest.get_node(pos)
	local meta = M(pos)
	local rail = node.name
	minetest.add_node(pos, {name = node_name, param2 = param2})
	meta:set_string("removed_rail", rail)
	meta:set_string("owner", owner)
	meta:set_string("userID", userID)
	meta:set_string("infotext", minetest.get_color_escape_sequence("#FFFF00")..owner..": "..userID)
	if ndef.after_place_node then
		ndef.after_place_node(pos)
	end
	if cargo and ndef.set_cargo then
		ndef.set_cargo(pos, cargo)
	end
end

-- called after punch cart
local function start_cart(pos, node_name, entity_name, puncher, dir)
	-- Read node metadata
	local ndef = minetest.registered_nodes[node_name]
	if ndef then
		local meta = M(pos)
		local rail = meta:get_string("removed_rail")
		local userID = meta:get_int("userID")
		local cart_owner = meta:get_string("owner")
		local cargo = ndef.get_cargo and ndef.get_cargo(pos) or {}
		-- swap node to rail
		minetest.remove_node(pos)
		minetest.add_node(pos, {name = rail})
		-- Add entity
		local obj = minetest.add_entity(pos, entity_name)
		-- Determine ID
		local myID = api.get_object_id(obj)
		if myID then
			-- Copy metadata to cart entity
			local entity = obj:get_luaentity()
			entity.owner = cart_owner
			entity.userID = userID
			entity.cargo = cargo
			entity.myID = myID
			obj:set_nametag_attributes({color = "#ffff00", text = cart_owner..": "..userID})
			minecart.add_to_monitoring(obj, myID, cart_owner, userID)
			minecart.node_at_station(cart_owner, userID, nil)
			-- punch cart to prevent the stopped handling
			obj:punch(puncher or obj, 1, {
					full_punch_interval = 1.0,
					damage_groups = {fleshy = 1},
				}, dir)
			return myID
		else
			print("Entity has no ID")
		end
	end
end

function api.stop_cart(pos, entity, node_name, param2)
	-- rail buffer reached?
	if api.get_route_key(pos) then
		-- Read entity data
		local owner = entity.owner or ""
		local userID = entity.userID or 0
		local cargo = entity.cargo or {}
		-- Remove entity
		minecart.remove_from_monitoring(entity.myID)
		minecart.node_at_station(owner, userID, pos)
		entity.object:remove()
		-- Add cart node
		add_cart(pos, node_name, param2, owner, userID, cargo)
	end
	-- Stop sound
	if entity.sound_handle then
		minetest.sound_stop(entity.sound_handle)
		entity.sound_handle = nil
	end
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
	
	minetest.show_formspec(owner, "minecart:userID_node",
                "size[4,3]" ..
                "label[0,0;Enter cart number:]" ..
                "field[1,1;3,1;userID;;]" ..
                "button_exit[1,2;2,1;exit;Save]")	
	
	return itemstack
end

function api.node_on_punch(pos, node, puncher, pointed_thing, entity_name, dir)
	local ndef = minetest.registered_nodes[node.name]
	-- Player digs cart by sneak-punch
	if puncher and puncher:get_player_control().sneak then
		api.remove_cart(nil, pos, puncher)
		return
	end
	start_cart(pos, node.name, entity_name, puncher, dir)
end

local function add_to_player_inventory(pos, player, node_name)
	local inv = player:get_inventory()
	if not (creative and creative.is_enabled_for
			and creative.is_enabled_for(player:get_player_name()))
			or not inv:contains_item("main", node_name) then
		local leftover = inv:add_item("main", node_name)
		-- If no room in inventory add a replacement cart to the world
		if not leftover:is_empty() then
			minetest.add_item(pos, leftover)
		end
	end
end

-- Player removes the node
function api.remove_cart(self, pos, player)
	if self then  -- cart is still an entity
		add_to_player_inventory(pos, player, self.node_name or "minecart:cart")
		minecart.remove_from_monitoring(self.myID)
		self.object:remove()
	else
		local node = minetest.get_node(pos)
		local ndef = minetest.registered_nodes[node.name]
		if ndef.can_dig and ndef.can_dig(pos, player) then
			add_to_player_inventory(pos, player, node.name)
			node.name = M(pos):get_string("removed_rail")
			if node.name == "" then
				node.name = "carts:rail"
			end
			minetest.remove_node(pos)
			minetest.add_node(pos, node)
		end
	end
end

function api.load_cargo() 
	-- nothing to load
end
	
function api.unload_cargo() 
	-- nothing to unload
end

function api.add_cargo_to_player_inv()
	-- nothing to do
end

-- needed by minecart.punch_cart and node carts
minecart.node_on_punch = api.node_on_punch

return api