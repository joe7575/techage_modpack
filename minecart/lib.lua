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

local RegisteredInventories = {}

local param2_to_dir = {[0]=
	{x=0,  y=0,  z=1},
	{x=1,  y=0,  z=0},
	{x=0,  y=0, z=-1},
	{x=-1, y=0,  z=0},
	{x=0,  y=-1, z=0},
	{x=0,  y=1,  z=0}
}

-- Registered carts
local tValidCarts = {} -- [<cart_name_stopped>] =  <cart_name_running>
local lValidCartNodes = {}
local tValidCartEntities = {}

minetest.tValidCarts = tValidCarts

function minecart.register_cart_names(cart_name_stopped, cart_name_running)
	tValidCarts[cart_name_stopped] = cart_name_running
	
	if minetest.registered_nodes[cart_name_stopped] then
		lValidCartNodes[#lValidCartNodes+1] = cart_name_stopped
	end
	if minetest.registered_nodes[cart_name_running] then
		lValidCartNodes[#lValidCartNodes+1] = cart_name_running
	end
	if minetest.registered_entities[cart_name_stopped] then
		tValidCartEntities[cart_name_stopped] = true
	end
	if minetest.registered_entities[cart_name_running] then
		tValidCartEntities[cart_name_running] = true
	end
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

function minecart.stopped(vel, tolerance)
	tolerance = tolerance or 0.05
	return math.abs(vel.x) < tolerance and math.abs(vel.z) < tolerance
end

local function is_air_like(name)
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

local function get_cart_object(pos, radius)
	for _, object in pairs(minetest.get_objects_inside_radius(pos, radius or 0.5)) do
		if tValidCartEntities[object:get_entity_name()] then
			local vel = object:get_velocity()
			if vector.equals(vel, {x=0, y=0, z=0}) then  -- still standing?
				return object
			end
		end
	end
end

-- check if cart can be pushed
function minecart.check_cart_for_pushing(pos, param2, radius)	
	local pos2 = param2 and vector.add(pos, param2_to_dir[param2]) or pos
	
	if minetest.find_node_near(pos2, radius or 0.5, lValidCartNodes, true) then
		return true
	end
	
	return get_cart_object(pos2, radius) ~= nil
end

-- check if cargo can be loaded
function minecart.check_cart_for_loading(pos, param2, radius)	
	local pos2 = param2 and vector.add(pos, param2_to_dir[param2]) or pos
	
	if minetest.find_node_near(pos2, radius or 0.5, lValidCartNodes, true) then
		return true
	end
	
	for _, object in pairs(minetest.get_objects_inside_radius(pos2, radius or 0.5)) do
		if object:get_entity_name() == "minecart:cart" then
			local vel = object:get_velocity()
			if vector.equals(vel, {x=0, y=0, z=0}) then  -- still standing?
				return true
			end
		end
	end
	
	return false
end

local get_next_node = minecart.get_next_node
local check_cart_for_loading = minecart.check_cart_for_loading
local check_cart_for_pushing = minecart.check_cart_for_pushing

-- Take the given number of items from the inv.
-- Returns nil if ItemList is empty.
function minecart.inv_take_items(inv, listname, num)
	if inv:is_empty(listname) then
		return nil
	end
	local size = inv:get_size(listname)
	for idx = 1, size do
		local items = inv:get_stack(listname, idx)
		if items:get_count() > 0 then
			local taken = items:take_item(num)
			inv:set_stack(listname, idx, items)
			return taken
		end
	end
	return nil
end

function minecart.take_items(pos, param2, num)
	local npos, node
	if param2 then
		npos, node = get_next_node(pos, (param2 + 2) % 4)
	else
		npos, node = pos, minetest.get_node(pos)
	end
	local def = RegisteredInventories[node.name]
	local owner = M(pos):get_string("owner")
	local inv = minetest.get_inventory({type="node", pos=npos})
	
	if def and inv and def.take_listname and (not def.allow_take or def.allow_take(npos, nil, owner)) then
		return minecart.inv_take_items(inv, def.take_listname, num)
	elseif def and def.take_item then
		return def.take_item(npos, num, owner)
	else
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.minecart_hopper_takeitem then
			return ndef.minecart_hopper_takeitem(npos, num)
		end
	end
end

function minecart.put_items(pos, param2, stack)
	local npos, node = get_next_node(pos, param2)
	local def = RegisteredInventories[node.name]
	local owner = M(pos):get_string("owner")
	local inv = minetest.get_inventory({type="node", pos=npos})
	
	if def and inv and def.put_listname and (not def.allow_put or def.allow_put(npos, stack, owner)) then
		local leftover = inv:add_item(def.put_listname, stack)
		if leftover:get_count() > 0 then
			return leftover
		end
	elseif def and def.put_item then
		return def.put_item(npos, stack, owner)
	elseif is_air_like(node.name) or check_cart_for_loading(npos) then
		minetest.add_item(npos, stack)
	else
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.minecart_hopper_additem then
			local leftover = ndef.minecart_hopper_additem(npos, stack)
			if leftover:get_count() > 0 then
				return leftover
			end
		else
			return stack
		end
	end
end

function minecart.untake_items(pos, param2, stack)
	local npos, node
	if param2 then
		npos, node = get_next_node(pos, (param2 + 2) % 4)
	else
		npos, node = pos, minetest.get_node(pos)
	end
	local def = RegisteredInventories[node.name]
	local inv = minetest.get_inventory({type="node", pos=npos})
	
	if def and inv and def.put_listname then
		return inv:add_item(def.put_listname, stack)
	elseif def and def.untake_item then
		return def.untake_item(npos, stack)
	else
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.minecart_hopper_untakeitem then
			return ndef.minecart_hopper_untakeitem(npos, stack)
		end
	end
end

function minecart.punch_cart(pos, param2, radius, dir)
	local pos2 = param2 and vector.add(pos, param2_to_dir[param2]) or pos
	
	local pos3 = minetest.find_node_near(pos2, radius or 0.5, lValidCartNodes, true)
	if pos3 then
		local node = minetest.get_node(pos3)
		--print(node.name)
		minecart.node_on_punch(pos3, node, nil, nil, tValidCarts[node.name], dir)
		return true
	end
	
	local obj = get_cart_object(pos2, radius)
	if obj then
		obj:punch(obj, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 1},
		}, dir)
	end
end	

-- Register inventory node for hopper access
-- (for examples, see below)
function minecart.register_inventory(node_names, def)
	for _, name in ipairs(node_names) do
		RegisteredInventories[name] = {
			allow_put = def.put and def.put.allow_inventory_put,
			put_listname = def.put and def.put.listname,
			allow_take = def.take and def.take.allow_inventory_take,
			take_listname = def.take and def.take.listname,
			put_item = def.put and def.put.put_item,
			take_item = def.take and def.take.take_item,
			untake_item = def.take and def.take.untake_item,
		}
	end
end

function minecart.register_cart_entity(entity_name, node_name, entity_def)
	entity_def.velocity = {x=0, y=0, z=0} -- only used on punch
	entity_def.old_dir = {x=1, y=0, z=0} -- random value to start the cart on punch
	entity_def.old_pos = nil
	entity_def.old_switch = 0
	entity_def.node_name = node_name
	minetest.register_entity(entity_name, entity_def)
	-- register node for punching
	minecart.register_cart_names(node_name, entity_name)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "minecart:userID_node" then
		if fields.exit == "Save" or fields.key_enter == "true" then
			local cart_pos = S2P(player:get_meta():get_string("cart_pos"))
			local userID = tonumber(fields.userID) or 0
			M(cart_pos):set_int("userID", userID)
			M(cart_pos):set_string("infotext", minetest.get_color_escape_sequence("#FFFF00")..player:get_player_name()..": "..userID)
			minecart.node_at_station(player:get_player_name(), userID, cart_pos)
		end
		return true
	end
    if formname == "minecart:userID_entity" then
		if fields.exit == "Save" or fields.key_enter == "true" then
			local cart_pos = S2P(player:get_meta():get_string("cart_pos"))
			local obj = get_cart_object(cart_pos)
			if obj then
				local entity = obj:get_luaentity()
				entity.userID = tonumber(fields.userID) or 0
				obj:set_nametag_attributes({color = "#ffff00", text = entity.owner..": "..entity.userID})
				minecart.update_userID(entity.myID, entity.userID)
			end
		end
		return true
	end
    return false
end)

minecart.register_inventory({"minecart:hopper"}, {
	put = {
		allow_inventory_put = function(pos, stack, player_name)
			local owner = M(pos):get_string("owner")
			return owner == player_name
		end, 
		listname = "main",
	},
	take = {
		allow_inventory_take = function(pos, stack, player_name)
			local owner = M(pos):get_string("owner")
			return owner == player_name
		end, 
		listname = "main",
	},
})
