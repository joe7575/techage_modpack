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
local P2H = minetest.hash_node_position

local get_node_lvm = minecart.get_node_lvm

local MAX_SPEED = 8
local SLOWDOWN = 0.3
local MAX_NODES = 100

--waypoint = {
--	dot = travel direction,
--	pos = destination pos,
--	speed = 10 times the section speed (as int),
--	limit = 10 times the speed limit (as int),
--}
--
-- waypoints = {facedir = waypoint,...}

local tWaypoints = {} -- {pos_hash = waypoints, ...}

local tRailsPower = {
	["carts:rail"] = 0,
	["carts:powerrail"] = 1,
	["minecart:rail"] = 0,
	["minecart:powerrail"] = 1,
	["carts:brakerail"] = 0,
}
-- Real rails from the mod carts
local tRails = {
	["carts:rail"] = true,
	["carts:powerrail"] = true,
	["carts:brakerail"] = true,
	["minecart:rail"] = true,
	["minecart:powerrail"] = true,
}
-- Rails plus node carts. Used to find waypoints. Added via add_raillike_nodes
local tRailsExt = {
	["carts:rail"] = true,
	["carts:powerrail"] = true,
	["carts:brakerail"] = true,
	["minecart:rail"] = true,
	["minecart:powerrail"] = true,
}

local tSigns = {
	["minecart:speed1"] = 1,
	["minecart:speed2"] = 2,
	["minecart:speed4"] = 4,
	["minecart:speed8"] = 8,
}

-- Real rails from the mod carts
local lRails = {"carts:rail", "carts:powerrail", "carts:brakerail", "minecart:rail", "minecart:powerrail"}
-- Rails plus node carts used to find waypoints, , added via add_raillike_nodes
local lRailsExt = {"carts:rail", "carts:powerrail", "carts:brakerail", "minecart:rail", "minecart:powerrail"}

minecart.MAX_SPEED = MAX_SPEED
minecart.lRails = lRails
minecart.tRails = tRails
minecart.tRailsExt = tRailsExt
minecart.lRailsExt = lRailsExt

local Dot2Dir = {}
local Dir2Dot = {}
local Facedir2Dir = {[0] =
	{x= 0, y=0,  z= 1},
	{x= 1, y=0,  z= 0},
	{x= 0, y=0,  z=-1},
	{x=-1, y=0,  z= 0},
	{x= 0, y=-1, z= 0},
	{x= 0, y=1,  z= 0},
}

local flip = {
	[0] = 2,
	[1] = 3,
	[2] = 0,
	[3] = 1,
	[4] = 5,
	[5] = 4,
}

-- facedir = math.floor(dot / 4)
-- y       = (dot % 4) - 1

-- Create helper tables
for facedir = 0,3 do
	for y = -1,1 do
		local dot = 1 + facedir * 4 + y
		local dir = vector.new(Facedir2Dir[facedir])
		dir.y = y
		Dot2Dir[dot] = dir
		Dir2Dot[P2H(dir)] = dot
	end
end

local function dot2dir(dot)    return vector.new(Dot2Dir[dot]) end
local function facedir2dir(fd) return vector.new(Facedir2Dir[fd]) end

minecart.dot2dir = dot2dir
minecart.facedir2dir = facedir2dir

-------------------------------------------------------------------------------
-- waypoint metadata
-------------------------------------------------------------------------------
local function has_metadata(pos)
	return M(pos):contains("waypoints")
end

local function get_metadata(pos)
	local hash = P2H(pos)
	if tWaypoints[hash] then
		return tWaypoints[hash]
	end
    local s = M(pos):get_string("waypoints")
    if s ~= "" then
        tWaypoints[hash] = minetest.deserialize(s)
		return tWaypoints[hash]
    end
end

local function get_oldmetadata(meta)
    local s = meta:get_string("waypoints")
    if s ~= "" then
        return minetest.deserialize(s)
    end
end

local function set_metadata(pos, t)
	local hash = P2H(pos)
	tWaypoints[hash] = t
	local s = minetest.serialize(t)
	M(pos):set_string("waypoints", s)
	-- visualization
	local name = get_node_lvm(pos).name
	if name == "carts:rail" then
		minetest.swap_node(pos, {name = "minecart:rail"})
	elseif name == "carts:powerrail" then
		minetest.swap_node(pos, {name = "minecart:powerrail"})
	end
end

local function del_metadata(pos)
	local hash = P2H(pos)
	tWaypoints[hash] = nil
	local meta = M(pos)
    if meta:contains("waypoints") then
        meta:set_string("waypoints", "")
		-- visualization
		local name = get_node_lvm(pos).name
		if name == "minecart:rail" then
			minetest.swap_node(pos, {name = "carts:rail"})
		elseif name == "minecart:powerrail" then
			minetest.swap_node(pos, {name = "carts:powerrail"})
		end
    end
end

-------------------------------------------------------------------------------
-- find_next_waypoint
-------------------------------------------------------------------------------
local function check_right(pos, facedir)
    local fdr = (facedir + 1) % 4  -- right
	local new_pos = vector.add(pos, facedir2dir(fdr))

	local name = get_node_lvm(new_pos).name
    if tRailsExt[name] or tSigns[name] then
		return true
    end
    new_pos.y = new_pos.y - 1
    if tRailsExt[get_node_lvm(new_pos).name] then
        return true
    end
end

local function check_left(pos, facedir)
    local fdl = (facedir + 3) % 4  -- left
	local new_pos = vector.add(pos, facedir2dir(fdl))

	local name = get_node_lvm(new_pos).name
    if tRailsExt[name] or tSigns[name] then
		return true
    end
    new_pos.y = new_pos.y - 1
    if tRailsExt[get_node_lvm(new_pos).name] then
        return true
    end
end

local function get_next_pos(pos, facedir, y)
	local new_pos = vector.add(pos, facedir2dir(facedir))
    new_pos.y = new_pos.y + y
	local name = get_node_lvm(new_pos).name
    return tRailsExt[name] ~= nil, new_pos, tRailsPower[name] or 0
end

local function is_ramp(pos)
    return tRailsExt[get_node_lvm({x = pos.x, y = pos.y + 1, z = pos.z}).name]  ~= nil
end

-- Check also the next position to detect a ramp
local function slope_detection(pos, facedir)
	local is_rail, new_pos = get_next_pos(pos, facedir, 0)
	if not is_rail then
		return is_ramp(new_pos)
	end
end

local function find_next_waypoint(pos, facedir, y)
	local cnt = 0
	local name = get_node_lvm(pos).name
	local speed = tRailsPower[name] or 0
	local is_rail, new_pos, _speed

	while cnt < MAX_NODES do
		is_rail, new_pos, _speed = get_next_pos(pos, facedir, y)
		speed = speed + _speed
		if not is_rail then
			return pos, y == 0 and is_ramp(new_pos), speed
		end
		if y == 0 then  -- no slope
			if check_right(new_pos, facedir) then
				return new_pos, slope_detection(new_pos, facedir), speed
			elseif check_left(new_pos, facedir) then
				return new_pos, slope_detection(new_pos, facedir), speed
			end
		end
		pos = new_pos
		cnt = cnt + 1
	end
	return new_pos, false, speed
end

-------------------------------------------------------------------------------
-- find_all_next_waypoints
-------------------------------------------------------------------------------
local function check_front_up_down(pos, facedir)
	local new_pos = vector.add(pos, facedir2dir(facedir))

    if tRailsExt[get_node_lvm(new_pos).name] then
		return 0
    end
    new_pos.y = new_pos.y - 1
    if tRailsExt[get_node_lvm(new_pos).name] then
        return -1
    end
    new_pos.y = new_pos.y + 2
    if tRailsExt[get_node_lvm(new_pos).name] then
        return 1
    end
end

-- Search for rails in all 4 directions
local function find_all_rails_nearby(pos)
	--print("find_all_rails_nearby")
    local tbl = {}
    for fd = 0, 3 do
		tbl[#tbl + 1] = check_front_up_down(pos, fd, true)
    end
	return tbl
end

-- Recalc the value based on waypoint length and slope
local function recalc_speed(num_pow_rails, pos1, pos2, y)
	local num_norm_rails = vector.distance(pos1, pos2) - num_pow_rails
	local ratio, speed

	if y ~= 0 then
		num_norm_rails = math.floor(num_norm_rails / 1.41 + 0.5)
	end

	if y ~= -1 then
		if num_pow_rails == 0 then
			return num_norm_rails * -SLOWDOWN
		else
			ratio = math.floor(num_norm_rails / num_pow_rails)
			ratio = minecart.range(ratio, 0, 11)
		end
	else
		ratio = 3 + num_norm_rails * SLOWDOWN + num_pow_rails
	end

	if y == 1 then
		speed = 7 - ratio
	elseif y == -1 then
		speed = 15 - ratio
	else
		speed = 11 - ratio
	end

	return minecart.range(speed, 0, 8)
end

local function find_all_next_waypoints(pos)
    local wp = {}
	local dots = {}

	for facedir = 0,3 do
		local y = check_front_up_down(pos, facedir)
		if y then
			local new_pos, is_ramp, speed = find_next_waypoint(pos, facedir, y)
			--print("find_all_next_waypoints", P2S(new_pos), is_ramp, speed)
			local dot = 1 + facedir * 4 + y
			speed = recalc_speed(speed, pos, new_pos, y) * 10
			wp[facedir] = {dot = dot, pos = new_pos, speed = speed, is_ramp = is_ramp}
		end
	end

	return wp
end

-------------------------------------------------------------------------------
-- get_waypoint
-------------------------------------------------------------------------------
-- If ramp, stop 0.5 nodes earlier or later
local function ramp_correction(pos, wp, facedir)
	if wp.is_ramp or pos.y < wp.pos.y then  -- ramp detection
		local dir = facedir2dir(facedir)
		local pos = wp.pos

		wp.cart_pos = {
			x = pos.x - dir.x / 2,
			y = pos.y,
			z = pos.z - dir.z / 2}
	elseif pos.y > wp.pos.y then
		local dir = facedir2dir(facedir)
		local pos = wp.pos

		wp.cart_pos = {
			x = pos.x + dir.x / 2,
			y = pos.y,
			z = pos.z + dir.z / 2}
	end
	return wp
end

-- Returns waypoint and is_junction
function minecart.get_waypoint(pos, facedir, ctrl, uturn)
	local t = get_metadata(pos)
	if not t then
		t = find_all_next_waypoints(pos)
		set_metadata(pos, t)
	end

	local left  = (facedir + 3) % 4
	local right = (facedir + 1) % 4
	local back  = (facedir + 2) % 4

	if ctrl.right and t[right] then return t[right], t[facedir] ~= nil or t[left] ~= nil end
	if ctrl.left  and t[left]  then return t[left] , t[facedir] ~= nil or t[right] ~= nil end

	if t[facedir] then return ramp_correction(pos, t[facedir], facedir), false end
	if t[right]   then return ramp_correction(pos, t[right], right),     false end
	if t[left]    then return ramp_correction(pos, t[left], left),       false end

	if uturn and t[back] then return t[back], false end
end

-------------------------------------------------------------------------------
-- delete waypoints
-------------------------------------------------------------------------------
local function delete_counterpart_metadata(pos, wp)
	for facedir = 0,3 do
		if wp[facedir] then
			del_metadata(wp[facedir].pos)
		end
	end
	del_metadata(pos)
end

local function delete_next_metadata(pos, facedir, y)
	local cnt = 0
	while cnt <= MAX_NODES do
		local is_rail, new_pos = get_next_pos(pos, facedir, y)
		if not is_rail then
			return
		end

		if has_metadata(new_pos) then
			del_metadata(new_pos)
		end

		pos = new_pos
		cnt = cnt + 1
	end
	if has_metadata(pos) then
		del_metadata(pos)
	end
end

function minecart.delete_waypoint(pos)
	if has_metadata(pos) then
		local wp = get_metadata(pos)
		delete_counterpart_metadata(pos, wp)
		return
	end

	for facedir = 0,3 do
		local y = check_front_up_down(pos, facedir)
		if y then
			local new_pos = vector.add(pos, facedir2dir(facedir))
			new_pos.y = new_pos.y + y
			if has_metadata(new_pos) then
				local wp = get_metadata(new_pos)
				delete_counterpart_metadata(new_pos, wp)
			else
				delete_next_metadata(pos, facedir, y)
			end
		end
	end
end

-------------------------------------------------------------------------------
-- find next buffer (needed as starting position)
-------------------------------------------------------------------------------
local function get_next_waypoints(pos)
	local t = get_metadata(pos)
	if not t then
		t = find_all_next_waypoints(pos)
	end
	return t
end

local function get_next_pos_and_facedir(waypoints, facedir)
	local cnt = 0
	local newpos, newfacedir
	facedir = (facedir + 2) % 4  -- opposite dir

	for i = 0, 3 do
		if waypoints[i] then
			cnt = cnt + 1
			if i ~= facedir then -- not the same way back
				newpos = vector.new(waypoints[i].pos)
				newfacedir = i
			end
		end
	end

	-- no junction and valid facedir
	if cnt < 3 and newfacedir then
		return newpos, newfacedir
	end
end

local function get_next_buffer(pos, facedir)
	facedir = (facedir + 2) % 4  -- opposite dir
	for i = 1,5 do  -- limit search depth
		local waypoints = get_next_waypoints(pos) or {}
		local pos1, facedir1 = get_next_pos_and_facedir(waypoints, facedir)
		if pos1 then
			pos, facedir = pos1, facedir1
		else
			return minecart.find_node_near_lvm(pos, 1, {"minecart:buffer"})
		end
	end
end


carts:register_rail("minecart:rail", {
	description = "Rail",
	tiles = {
		"carts_rail_straight.png^minecart_waypoint.png", "carts_rail_curved.png^minecart_waypoint.png",
		"carts_rail_t_junction.png^minecart_waypoint.png", "carts_rail_crossing.png^minecart_waypoint.png"
	},
	inventory_image = "carts_rail_straight.png",
	wield_image = "carts_rail_straight.png",
	groups = carts:get_rail_groups({not_in_creative_inventory = 1}),
	drop = "carts:rail",
}, {})

carts:register_rail("minecart:powerrail", {
	description = "Powered Rail",
	tiles = {
		"carts_rail_straight_pwr.png^minecart_waypoint.png", "carts_rail_curved_pwr.png^minecart_waypoint.png",
		"carts_rail_t_junction_pwr.png^minecart_waypoint.png", "carts_rail_crossing_pwr.png^minecart_waypoint.png"
	},
	inventory_image = "carts_rail_straight.png",
	wield_image = "carts_rail_straight.png",
	groups = carts:get_rail_groups({not_in_creative_inventory = 1}),
	drop = "carts:powerrail",
}, {})

for name,_ in pairs(tRails) do
	minetest.override_item(name, {
		after_destruct = minecart.delete_waypoint,
		after_place_node = minecart.delete_waypoint,
	})
end

-------------------------------------------------------------------------------
-- API functions
-------------------------------------------------------------------------------
-- Return new cart pos and if an extra move cycle is needed
function minecart.get_current_cart_pos_correction(curr_pos, curr_fd, curr_y, new_dot)
	if new_dot then
		local new_y = (new_dot % 4) - 1
		local new_fd = math.floor(new_dot / 4)

		if curr_y == -1 or new_y == -1 then
			local new_fd = math.floor(new_dot / 4)
			local dir = facedir2dir(new_fd)
			return {
				x = curr_pos.x + dir.x / 2,
				y = curr_pos.y,
				z = curr_pos.z + dir.z / 2}, new_y == -1
		elseif curr_y == 1 and curr_fd ~= new_fd then
			local dir = facedir2dir(new_fd)
			return {
				x = curr_pos.x + dir.x / 2,
				y = curr_pos.y,
				z = curr_pos.z + dir.z / 2}, true
		elseif curr_y == 1 or new_y == 1 then
			local dir = facedir2dir(curr_fd)
			return {
				x = curr_pos.x - dir.x / 2,
				y = curr_pos.y,
				z = curr_pos.z - dir.z / 2}, false
		end
	end
	return curr_pos, false
end

-- Called by carts, returns the speed value or nil
function minecart.get_speedlimit(pos, facedir)
    local fd = (facedir + 1) % 4  -- right
	local new_pos = vector.add(pos, facedir2dir(fd))
	local node = get_node_lvm(new_pos)
	if tSigns[node.name] and node.param2 == facedir then
		return tSigns[node.name]
    end

    fd = (facedir + 3) % 4  -- left
	new_pos = vector.add(pos, facedir2dir(fd))
	node = get_node_lvm(new_pos)
	if tSigns[node.name] and node.param2 == facedir then
		return tSigns[node.name]
    end
end

-- Called by carts, to delete temporarily created waypoints
function minecart.delete_cart_waypoint(pos)
	del_metadata(pos)
end

-- Called by signs, to delete the rail waypoints nearby
function minecart.delete_signs_waypoint(pos)
	local node = minetest.get_node(pos)
    local facedir = (node.param2 + 1) % 4  -- right
	local new_pos = vector.add(pos, facedir2dir(facedir))
	if tRailsExt[get_node_lvm(new_pos).name] then
		minecart.delete_waypoint(new_pos)
	end

    facedir = (node.param2 + 3) % 4  -- left
	new_pos = vector.add(pos, facedir2dir(facedir))
	if tRailsExt[get_node_lvm(new_pos).name] then
		minecart.delete_waypoint(new_pos)
	end
end

function minecart.is_rail(pos, name)
	return tRails[name or get_node_lvm(pos).name] ~= nil
end

-- To register node cart names
function minecart.add_raillike_nodes(name)
	tRailsExt[name] = true
	lRailsExt[#lRailsExt + 1] = name
end

-- minecart.get_next_buffer(pos, facedir)
minecart.get_next_buffer = get_next_buffer

-- minecart.del_metadata(pos)
minecart.del_metadata = del_metadata

--minetest.register_lbm({
--	label = "Delete waypoints",
--	name = "minecart:del_meta",
--	nodenames = {"minecart:rail", "minecart:powerrail"},
--	run_at_every_load = true,
--	action = function(pos, node)
--		del_metadata(pos)
--	end,
--})


