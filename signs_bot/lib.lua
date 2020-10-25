--[[

	Signs Bot
	=========

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Signs Bot: Library with helper functions

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

signs_bot.lib = {}

local Face2Dir = {[0]=
	{x=0,  y=0,  z=1},
	{x=1,  y=0,  z=0},
	{x=0,  y=0, z=-1},
	{x=-1, y=0,  z=0},
	{x=0,  y=-1, z=0},
	{x=0,  y=1,  z=0}
}

-- allowed for digging
local NotSoSimpleNodes = {}

function signs_bot.lib.register_node_to_be_dug(name)
	NotSoSimpleNodes[name] = true
end

-- Determine the next robot position based on the robot position, 
-- the robot param2.
function signs_bot.lib.next_pos(pos, param2)
	return vector.add(pos, Face2Dir[param2])
end

-- Determine the destination position based on the robot position, 
-- the robot param2, and a route table like : {0,0,3}
-- 0 = forward, 1 = right, 2 = backward, 3 = left
function signs_bot.lib.dest_pos(pos, param2, route)
	local p2 = param2
	for _,dir in ipairs(route) do
		p2 = (param2 + dir) % 4
		pos = vector.add(pos, Face2Dir[p2])
	end
	return pos, p2
end

function signs_bot.lib.get_node_lvm(pos)
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
	node = {
		name = minetest.get_name_from_content_id(data[idx]),
		param2 = param2_data[idx]
	}
	return node
end

local next_pos = signs_bot.lib.next_pos
local dest_pos = signs_bot.lib.dest_pos
local get_node_lvm = signs_bot.lib.get_node_lvm

local function poke_objects(pos, param2, objects)
	minetest.sound_play('signs_bot_go_away', {pos = pos})
	for _,obj in ipairs(objects) do
		local pos1 = obj:get_pos()
		pos1 = vector.add(pos1, vector.multiply(Face2Dir[param2], 0.2))
		obj:move_to(pos1)
	end
end	

-- check if nodeA on posA == air-like and nodeB == solid and no player around
function signs_bot.lib.check_pos(posA, nodeA, nodeB, param2)
	local ndefA = minetest.registered_nodes[nodeA.name]
	local ndefB = minetest.registered_nodes[nodeB.name]
	if ndefA and not ndefA.walkable and ndefB and ndefB.walkable then
		return true
	end
	return false
end

local function handle_drop(drop)
	-- To keep it simple, return only the item with the lowest rarity
	if drop.items then
		local rarity = 9999
		local name
		for idx,item in ipairs(drop.items) do
			if item.rarity and item.rarity < rarity then
				rarity = item.rarity
				name = item.items[1] -- take always the first item
			else
				return item.items[1] -- take always the first item
			end
		end
		return name
	end
	return false
end

-- Has to be checked before a node is placed
function signs_bot.lib.is_air_like(pos)
	local node = get_node_lvm(pos)
	local ndef = minetest.registered_nodes[node.name]
	if ndef and ndef.buildable_to then
		return true
	end
	return false
end

-- Has to be checked before a node is dug
function signs_bot.lib.is_simple_node(node)
	-- don't remove nodes with some intelligence or undiggable nodes
	local ndef = minetest.registered_nodes[node.name]
	if not NotSoSimpleNodes[node.name] then
		if not ndef or node.name == "air" then return false end
		if ndef.drop == "" then return false end
		if ndef.diggable == false then return false end
		if ndef.after_dig_node then return false end
	end
	if type(ndef.drop) == "table" then
		return handle_drop(ndef.drop)
	end
	return ndef.drop or node.name
end	

-- Check rights before node is dug or inventory is used
function signs_bot.lib.not_protected(base_pos, pos)
	local me = M(base_pos):get_string("owner")
	minetest.load_area(pos)
	if minetest.is_protected(pos, me) then
		return false
	end
	local you = M(pos):get_string("owner")
	if you ~= "" and me ~= you then
		return false
	end
	return true
end


--
-- Access functions for chest like nodes
-- (bot inventory releated function are in basis.lua)

-- Search for items in the inventory and return the item_name or nil.
function signs_bot.lib.peek_inv(inv, listname)
	if inv:is_empty(listname) then return nil end
	
	local inv_size =  inv:get_size(listname)

	for idx in signs_bot.random(inv_size) do
		local stack = inv:get_stack(listname, idx)
		if stack:get_count() > 0 then
			return stack:get_name()
		end
	end
end


-- In the case an inventory is full
function signs_bot.lib.drop_items(robot_pos, items)
	local pos1 = {x=robot_pos.x-1, y=robot_pos.y, z=robot_pos.z-1}
	local pos2 = {x=robot_pos.x+1, y=robot_pos.y, z=robot_pos.z+1}
	for _,pos in ipairs(minetest.find_nodes_in_area(pos1, pos2, {"air"})) do
		minetest.add_item(pos, items)
		return
	end
end


--
--  Place/dig signs
--
function signs_bot.lib.place_sign(pos, sign, param2)				
	if sign:get_name() then
		minetest.set_node(pos, {name=sign:get_name(), param2=param2})
		local ndef = minetest.registered_nodes[sign:get_name()]
		if ndef and ndef.after_place_node then
			ndef.after_place_node(pos, nil, sign)
		end
	end
end

function signs_bot.lib.dig_sign(pos, node)
	node = node or get_node_lvm(pos)
	local nmeta = minetest.get_meta(pos)
	local cmnd = nmeta:get_string("signs_bot_cmnd")
	local sign
	if cmnd ~= "" then
		if node.name == "signs_bot:sign_cmnd" then
			local err_code = nmeta:get_int("err_code")
			local err_msg = nmeta:get_string("err_msg")
			local name = nmeta:get_string("sign_name")
			sign = ItemStack("signs_bot:sign_cmnd")
			local smeta = sign:get_meta()
			smeta:set_string("cmnd", cmnd)
			smeta:set_int("err_code", err_code)
			smeta:set_string("err_msg", err_msg)
			smeta:set_string("description", name)
		else
			sign = ItemStack(node.name)
		end
		minetest.remove_node(pos)
		return sign
	end
end

function signs_bot.lib.after_dig_sign_node(pos, oldnode, oldmetadata, digger)
	local sign = ItemStack(oldnode.name)
	local smeta = sign:get_meta()
	smeta:set_string("cmnd", oldmetadata.fields.signs_bot_cmnd)
	smeta:set_string("description", oldmetadata.fields.sign_name)
	if oldmetadata.fields.err_code then
		smeta:set_int("err_code", tonumber(oldmetadata.fields.err_code))
		smeta:set_string("err_msg", oldmetadata.fields.err_msg or "")
	end
	local player_name = digger:get_player_name()
	-- See https://github.com/minetest/minetest/blob/34e3ede8eeb05e193e64ba3d055fc67959d87d86/doc/lua_api.txt#L6222
	if player_name == "" then
		minetest.add_item(pos, sign)
	else
		local inv = minetest.get_inventory({type="player", name=digger:get_player_name()})
		local left_over = inv:add_item("main", sign)
		if left_over:get_count() > 0 then
			minetest.add_item(pos, sign)
		end
	end
end

local function activate_extender_node(pos)
	local node = get_node_lvm(pos)
	if node.name == "signs_bot:sensor_extender" then
		node.name = "signs_bot:sensor_extender_on"
		minetest.swap_node(pos, node)
		minetest.registered_nodes["signs_bot:sensor_extender_on"].after_place_node(pos)
	end
end

local NestedCounter = 0
function signs_bot.lib.activate_extender_nodes(pos, is_sensor)
	if is_sensor then 
		NestedCounter = 0 
	else
		NestedCounter = NestedCounter + 1
		if NestedCounter >= 5 then
			return
		end
	end
	activate_extender_node({x=pos.x-1, y=pos.y, z=pos.z})
	activate_extender_node({x=pos.x+1, y=pos.y, z=pos.z})
	activate_extender_node({x=pos.x, y=pos.y, z=pos.z-1})
	activate_extender_node({x=pos.x, y=pos.y, z=pos.z+1})
end

--
-- Determine the field positions
--
local function start_pos(robot_pos, robot_param2, x_size, lvl_offs)
	local pos = next_pos(robot_pos, robot_param2)
	pos = {x=pos.x, y=pos.y+lvl_offs, z=pos.z}
	if x_size == 5 then
		return dest_pos(pos, robot_param2, {3,3})
	else
		return dest_pos(pos, robot_param2, {3})
	end
end	

--
-- Return a table with all positions to copy
-- 
function signs_bot.lib.gen_position_table(robot_pos, robot_param2, x_size, z_size, lvl_offs)
	local tbl = {}
	if robot_pos and robot_param2 and x_size and z_size and lvl_offs then
		local pos = start_pos(robot_pos, robot_param2, x_size, lvl_offs)
		tbl[#tbl+1] = pos
		z_size = math.min(z_size, 5)
		for z = 1,z_size do
			for x = 1,x_size-1 do
				local dir = (z % 2) == 0 and 3 or 1
				pos = dest_pos(pos, robot_param2, {dir})
				tbl[#tbl+1] = pos
			end
			if z < z_size then
				pos = dest_pos(pos, robot_param2, {0})
				tbl[#tbl+1] = pos
			end
		end
	end
	return tbl
end

function signs_bot.lib.trim_text(text)
	local tbl = {}
	for idx,line in ipairs(string.split(text, "[\r\n]+", true, -1, true)) do
		tbl[#tbl+1] = line:trim()
	end
	return table.concat(tbl, "\n")
end

function signs_bot.lib.fake_player(name)
	return {
		get_player_name = function() return name end,
		is_player = function() return false end,
	}
end

signs_bot.lib.register_node_to_be_dug("default:cactus")
signs_bot.lib.register_node_to_be_dug("default:papyrus")
