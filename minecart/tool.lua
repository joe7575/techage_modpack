--[[

	Minecart
	========

	Copyright (C) 2019-2021 Joachim Stolberg

	MIT
	See license.txt for more information
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = minecart.S
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local P2H = minetest.hash_node_position

local sDir = {[0] =	"north", "east", "south", "west"}

local function DOTS(dots) 
	if dots then
		return table.concat(dots, ", ")
	else
		return ""
	end
end

local old_pos

local function test_get_route(pos, node, player)
	local yaw = player:get_look_horizontal()
	local dir = minetest.yaw_to_dir(yaw)
	local facedir = minetest.dir_to_facedir(dir)
	local route = minecart.get_waypoint(pos, facedir, {})
	if route then
--		print(dump(route))
		minecart.set_marker(route.pos, "pos", 0.3, 10)
		if route.cart_pos then
			minecart.set_marker(route.cart_pos, "cart", 0.3, 10)
		end
		
		-- determine some kind of current y
		old_pos = old_pos or pos
		local curr_y = pos.y > old_pos.y and 1 or pos.y < old_pos.y and -1 or 0
		
		local cart_pos, extra_cycle = minecart.get_current_cart_pos_correction(pos, facedir, curr_y, route.dot)
		minecart.set_marker(cart_pos, "curr", 0.3, 10)
		old_pos = pos
		print(string.format("Route: dist = %u, dot = %u, speed = %d, extra cycle = %s", 
				vector.distance(pos, route.pos), route.dot, route.speed or 0, extra_cycle))
	end
end

local function test_get_connections(pos, node, player, ctrl)
	local wp = minecart.get_waypoints(pos)
	for i = 0,3 do
		if wp[i] then
			local dir = minecart.Dot2Dir[ wp[i].dot]
			print(sDir[i], vector.distance(pos, wp[i].pos), dir.y)
		end
	end
	print(dump(M(pos):to_table()))
end

local function click_left(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		if node.name == "carts:rail" or node.name == "carts:powerrail" then
			test_get_route(pos, node, placer)
		end
	end
end

local function click_right(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		if node.name == "carts:rail" or node.name == "carts:powerrail" then
			test_get_connections(pos, node, placer)
		elseif node.name == "minecart:buffer" then
			local route = minecart.get_route(P2S(pos))
			print(dump(route))
		end
	end
end

minetest.register_node("minecart:tool", {
	description = "Tool",
	inventory_image = "minecart_tool.png",
	wield_image = "minecart_tool.png",
	liquids_pointable = true,
	use_texture_alpha = true,
	groups = {cracky=1, book=1},
	on_use = click_left,
	on_place = click_right,
	node_placement_prediction = "",
	stack_max = 1,
})
