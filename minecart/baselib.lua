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
local P2H = minetest.hash_node_position
local H2P = minetest.get_position_from_hash

local param2_to_dir = {[0]=
	{x=0,  y=0,  z=1},
	{x=1,  y=0,  z=0},
	{x=0,  y=0, z=-1},
	{x=-1, y=0,  z=0},
	{x=0,  y=-1, z=0},
	{x=0,  y=1,  z=0}
}

-- Registered carts
minecart.tNodeNames = {} -- [<cart_node_name>] =  <cart_entity_name>
minecart.tEntityNames = {} -- [<cart_entity_name>] =  true
minecart.lCartNodeNames = {} -- {<cart_node_name>, <cart_node_name>, ...}
minecart.tCartTypes = {}

function minecart.param2_to_dir(param2)
	return param2_to_dir[param2 % 6]
end

function minecart.get_node_lvm(pos)
	local node = minetest.get_node_or_nil(pos)
	if node then
		return node
	end
	local vm = minetest.get_voxel_manip()
	local MinEdge, MaxEdge = vm:read_from_map(pos, pos)
	local data = vm:get_data()
	local param2_data = vm:get_param2_data()
	local area = VoxelArea:new({MinEdge = MinEdge, MaxEdge = MaxEdge})
	local idx = area:indexp(pos)
	if data[idx] and param2_data[idx] then
		return {
			name = minetest.get_name_from_content_id(data[idx]),
			param2 = param2_data[idx]
		}
	end
	return {name="ignore", param2=0}
end

function minecart.find_node_near_lvm(pos, radius, items)
	local npos = minetest.find_node_near(pos, radius, items)
	if npos then
		return npos
	end
	local tItems = {}
	for _,v in ipairs(items) do
		tItems[v] = true
	end
	local pos1 = {x = pos.x - radius, y = pos.y - radius, z = pos.z - radius}
	local pos2 = {x = pos.x + radius, y = pos.y + radius, z = pos.z + radius}
	local vm = minetest.get_voxel_manip()
	local MinEdge, MaxEdge = vm:read_from_map(pos1, pos2)
	local data = vm:get_data()
	local area = VoxelArea:new({MinEdge = MinEdge, MaxEdge = MaxEdge})
	for x = pos1.x, pos2.x do
		for y = pos1.y, pos2.y do
			for z = pos1.z, pos2.z do
				local idx = area:indexp({x = x, y = y, z = z})
				if minetest.get_name_from_content_id(data[idx]) then
					return {x = x, y = y, z = z}
				end
			end
		end
	end
end

-- Marker entities for debugging purposes
function minecart.set_marker(pos, text, size, ttl)
	local marker = minetest.add_entity(pos, "minecart:marker_cube")
	if marker ~= nil then
		marker:set_nametag_attributes({color = "#FFFFFF", text = text})
		size = size or 1
		marker:set_properties({visual_size = {x = size, y = size}})
		if ttl then
			minetest.after(ttl, marker.remove, marker)
		end
	end
end

minetest.register_entity(":minecart:marker_cube", {
	initial_properties = {
		visual = "cube",
		textures = {
			"minecart_marker_cube.png",
			"minecart_marker_cube.png",
			"minecart_marker_cube.png",
			"minecart_marker_cube.png",
			"minecart_marker_cube.png",
			"minecart_marker_cube.png",
		},
		physical = false,
		visual_size = {x = 1, y = 1},
		collisionbox = {-0.25,-0.25,-0.25, 0.25,0.25,0.25},
		glow = 8,
		static_save = false,
	},
	on_punch = function(self)
		self.object:remove()
	end,
})

function minecart.is_air_like(name)
	local ndef = minetest.registered_nodes[name]
	if ndef and ndef.buildable_to then
		return true
	end
	return false
end

function minecart.range(val, min, max)
	val = tonumber(val)
	if val < min then return min end
	if val > max then return max end
	return val
end

function minecart.get_next_node(pos, param2)
	local pos2 = param2 and vector.add(pos, param2_to_dir[param2]) or pos
	local node = minetest.get_node(pos2)
	return pos2, node
end

function minecart.get_object_id(object)
	for id, entity in pairs(minetest.luaentities) do
		if entity.object == object then
			return id
		end
	end
end

function minecart.is_owner(player, owner)
	if not player or not player:is_player() or not owner or owner == "" then
		return true
	end

	local name = player:get_player_name()
	if minetest.check_player_privs(name, "minecart") then
		return true
	end
	return name == owner
end

function minecart.get_buffer_pos(pos, player_name)
	local pos1 = minecart.find_node_near_lvm(pos, 1, {"minecart:buffer"})
	if pos1 then
		local meta = minetest.get_meta(pos1)
		if player_name == nil or player_name == meta:get_string("owner") then
			return pos1
		end
	end
end

function minecart.get_buffer_name(pos)
	local pos1 = minecart.find_node_near_lvm(pos, 1, {"minecart:buffer"})
	if pos1 then
		local name = M(pos1):get_string("name")
		if name ~= "" then
			return name
		end
		return P2S(pos1)
	end
end

function minecart.manage_attachment(player, entity, get_on)
	if not player then
		return
	end
	local player_name = player:get_player_name()
	if player_api.player_attached[player_name] == get_on then
		return
	end
	player_api.player_attached[player_name] = get_on
	
	local obj = entity.object
	if get_on then
		player:set_attach(obj, "", {x=0, y=-4.5, z=-4}, {x=0, y=0, z=0})
		player:set_eye_offset({x=0, y=-6, z=0},{x=0, y=-6, z=0})
		player:set_properties({visual_size = {x = 2.5, y = 2.5}})
		player_api.set_animation(player, "sit")
		entity.driver = player:get_player_name()
	else
		player:set_detach()
		player:set_eye_offset({x=0, y=0, z=0},{x=0, y=0, z=0})
		player:set_properties({visual_size = {x = 1, y = 1}})
		player_api.set_animation(player, "stand")
		entity.driver = nil
	end
end

function minecart.register_cart_names(node_name, entity_name, cart_type)
	minecart.tNodeNames[node_name] = entity_name
	minecart.tEntityNames[entity_name] = true
	minecart.lCartNodeNames[#minecart.lCartNodeNames+1] = node_name
	minecart.add_raillike_nodes(node_name)
	minecart.tCartTypes[node_name] = cart_type
end

function minecart.add_nodecart(pos, node_name, param2, cargo, owner, userID)
	if pos and node_name and param2 and cargo and owner and userID then
		local pos2
		if not minecart.is_rail(pos) then
			pos2 = minetest.find_node_near(pos, 1, minecart.lRails)
			if not pos2 or not minecart.is_rail(pos2) then
				pos2 = minetest.find_node_near(pos, 2, minecart.lRails)
				if not pos2 or not minecart.is_rail(pos2) then
					pos2 = minetest.find_node_near(pos, 2, {"air"})
				end
			end
		else
			pos2 = vector.new(pos)
		end
		if pos2 then
			local node = minetest.get_node(pos2)
			local ndef = minetest.registered_nodes[node_name]
			local rail = node.name
			minetest.swap_node(pos2, {name = node_name, param2 = param2})
			local meta = M(pos2)
			meta:set_string("removed_rail", rail)
			meta:set_string("owner", owner)
			meta:set_int("userID", userID)
			meta:set_string("infotext", owner .. ": " .. userID)
			
			if cargo and ndef.set_cargo then
				ndef.set_cargo(pos2, cargo)
			end
			if ndef.after_place_node then
				ndef.after_place_node(pos2)
			end
			return pos2
		else
			minetest.add_item(pos, ItemStack({name = node_name}))
		end
	end
end

function minecart.add_entitycart(pos, node_name, entity_name, vel, cargo, owner, userID)
	local obj = minetest.add_entity(pos, entity_name)
	local objID = minecart.get_object_id(obj)
	
	if objID then
		local entity = obj:get_luaentity()
		entity.start_pos = pos
		entity.owner = owner
		entity.node_name = node_name
		entity.userID = userID
		entity.objID = objID
		entity.cargo = cargo
		obj:set_nametag_attributes({color = "#ffff00", text = owner..": "..userID})
		obj:set_velocity(vel)
		return obj
	end
end

function minecart.start_entitycart(self, pos)
	local route = {}
	
	self.is_running = true
	self.arrival_time = 0
	self.start_pos = minecart.get_buffer_pos(pos, self.owner)
	if self.start_pos then
		-- Read buffer route for the junction info
		route = minecart.get_route(self.start_pos) or {}
		self.junctions = route and route.junctions
	end
	-- If set the start waypoint will be deleted
	self.no_normal_start = self.start_pos == nil
	if self.driver == nil then
		minecart.start_monitoring(self.owner, self.userID, pos, self.objID, 
				route.checkpoints, route.junctions, self.cargo or {})
	end
end

function minecart.remove_nodecart(pos)
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	local meta = M(pos)
	local rail = meta:get_string("removed_rail")
	if rail == "" then rail = "air" end
	local userID = meta:get_int("userID")
	local owner = meta:get_string("owner")
	meta:set_string("infotext", "")
	meta:set_string("formspec", "")
	local cargo = ndef.get_cargo and ndef.get_cargo(pos) or {}
	minetest.swap_node(pos, {name = rail})
	return cargo, owner, userID
end	
	
function minecart.node_to_entity(pos, node_name, entity_name)
	-- Remove node
	local cargo, owner, userID = minecart.remove_nodecart(pos)
	local obj = minecart.add_entitycart(pos, node_name, entity_name,
			{x = 0, y = 0, z = 0}, cargo, owner, userID)
	if obj then
		return obj
	else
		print("Entity has no ID")
	end
end

function minecart.entity_to_node(pos, entity)
	-- Stop sound
	if entity.sound_handle then
		minetest.sound_stop(entity.sound_handle)
		entity.sound_handle = nil
	end
	
	local rot = entity.object:get_rotation()
	local dir = minetest.yaw_to_dir(rot.y)
	local facedir = minetest.dir_to_facedir(dir)
	minecart.stop_recording(entity, pos)
	entity.object:remove()
	local pos2 = minecart.add_nodecart(pos, entity.node_name, facedir, entity.cargo, entity.owner, entity.userID)
	minecart.stop_monitoring(entity.owner, entity.userID, pos2)
end

function minecart.add_node_to_player_inventory(pos, player, node_name)
	local inv = player:get_inventory()
	if not (creative and creative.is_enabled_for
			and creative.is_enabled_for(player:get_player_name()))
			or not inv:contains_item("main", node_name) then
		local leftover = inv:add_item("main", node_name)
		-- If no room in inventory, drop the cart
		if not leftover:is_empty() then
			minetest.add_item(pos, leftover)
		end
	end
end

-- Player removes the node
function minecart.remove_entity(self, pos, player)
	-- Stop sound
	if self.sound_handle then
		minetest.sound_stop(self.sound_handle)
		self.sound_handle = nil
	end
	minecart.add_node_to_player_inventory(pos, player, self.node_name or "minecart:cart")
	minecart.stop_monitoring(self.owner, self.userID, pos)
	minecart.stop_recording(self, pos)	
	minecart.monitoring_remove_cart(self.owner, self.userID)
	self.object:remove()
end
