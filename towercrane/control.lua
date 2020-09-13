--[[

	Tower Crane Mod
	===============

	Copyright (C) 2017-2020 Joachim Stolberg
	LGPLv2.1+
	See LICENSE.txt for more information

]]--

local DAYS_WITHOUT_USE = 72 * 5

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos

local S = towercrane.S

-- To prevent race condition crashes
local Currently_left_the_game = {}

-- pos is the switch position
local function is_my_crane(pos, clicker)
	local base_pos = {x=pos.x, y=pos.y-1, z=pos.z}
	return towercrane.is_my_crane(base_pos, clicker)
end

-- pos is the switch position
local function get_crane_data(pos)
	local base_pos = {x=pos.x, y=pos.y-1, z=pos.z}
	return towercrane.get_crane_data(base_pos)
end

local function get_my_crane_pos(player)
	-- check operator state
    local pl_meta = player:get_meta()
	if not pl_meta or pl_meta:get_int("towercrane_isoperator") ~= 1 then
		return 
	end
	-- check owner
	local pos = S2P(pl_meta:get_string("towercrane_pos"))
	local player_name = (player and player:get_player_name()) or ""
    local data = get_crane_data(pos)
	if not data or player_name ~= data.owner then
		return 
	end
	-- check protection
	if minetest.is_protected(pos, player_name) then
		return 
	end
	
	return pos  -- switch pos
end

-- pos is the switch position
local function is_crane_running(pos)
	local meta = minetest.get_meta(pos)
	return meta:get_int("running") == 1
end
	
local function is_operator(player)
    local pl_meta = player:get_meta()
	if not pl_meta or pl_meta:get_int("towercrane_isoperator") ~= 1 then
		return false
	end
	return true
end

local function set_operator_privs(player, pos)
	local privs = minetest.get_player_privs(player:get_player_name())
	local physics = player:get_physics_override()
	local meta = player:get_meta()
	-- Check access conflicts with other mods
	if meta:get_int("player_physics_locked") == 0 then 
		if pos and meta and privs and physics then
			meta:set_string("towercrane_pos", P2S(pos))
			-- store the player privs default values
			meta:set_string("towercrane_fast", privs["fast"] and "true" or "false")
			meta:set_string("towercrane_fly", privs["fly"] and "true" or "false")
			meta:set_int("towercrane_speed", physics.speed)
			-- set operator privs
			meta:set_int("towercrane_isoperator", 1)
			meta:set_int("player_physics_locked", 1)
			privs["fly"] = true
			privs["fast"] = nil
			physics.speed = 0.7
			-- write back
			player:set_physics_override(physics)
			minetest.set_player_privs(player:get_player_name(), privs)
			return true
		end
	end
	return false
end

local function reset_operator_privs(player)
	local privs = minetest.get_player_privs(player:get_player_name())
	local physics = player:get_physics_override()
	local meta = player:get_meta()
	if meta and privs and physics then
		meta:set_string("towercrane_pos", "")
		-- restore the player privs default values
		meta:set_int("towercrane_isoperator", 0)
		meta:set_int("player_physics_locked", 0)
		privs["fast"] = meta:get_string("towercrane_fast") == "true" or nil
		privs["fly"] = meta:get_string("towercrane_fly") == "true" or nil
		physics.speed = meta:get_int("towercrane_speed")
		if physics.speed == 0 then physics.speed = 1 end
		-- delete stored default values
		meta:set_string("towercrane_fast", "")
		meta:set_string("towercrane_fly", "")
		meta:set_string("towercrane_speed", "")
		-- write back
		player:set_physics_override(physics)
		minetest.set_player_privs(player:get_player_name(), privs)
	end
end

local function place_player(pos, player)
	if pos and player then
		local data = get_crane_data(pos)
		if data then
			local new_pos = vector.add(pos, data.dir)
			new_pos.y = new_pos.y - 1
			player:set_pos(new_pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("last_known_pos", P2S(new_pos))
		end
	end
end

-- state must be "on" or "off"
local function swap_node(pos, state)
	-- check node
    local node = minetest.get_node(pos)
	if node.name ~= "towercrane:mast_ctrl_"..(state == "on" and "off" or "on") then
		return
	end
	-- switch node
	node.name = "towercrane:mast_ctrl_"..state
	minetest.swap_node(pos, node)
end

-- pos is the switch position
local function store_last_used(pos)
	local meta = minetest.get_meta(pos)
	meta:set_int("last_used", minetest.get_day_count() + DAYS_WITHOUT_USE)
end

local function stop_crane(pos, player)
	swap_node(pos, "off")
	local meta = minetest.get_meta(pos)
	meta:set_int("running", 0)
	store_last_used(pos)
	place_player(pos, player)
end

local function start_crane(pos, player)
	swap_node(pos, "on")
	local meta = minetest.get_meta(pos)
	meta:set_int("running", 1)
	store_last_used(pos)
	place_player(pos, player)
end

local function calc_construction_area(pos)
	local data = get_crane_data(pos)
	if data then
		-- pos1 = close/right/below
		local dir = towercrane.turnright(data.dir)
		local pos1 = vector.add(pos, vector.multiply(dir, data.width/2))
		dir = towercrane.turnleft(dir)
		pos1 = vector.add(pos1, vector.multiply(dir, 1))
		pos1.y = pos.y - 2 + data.height - towercrane.rope_length
		-- pos2 = far/left/above
		local pos2 = vector.add(pos1, vector.multiply(dir, data.width-1))
		dir = towercrane.turnleft(dir)
		pos2 = vector.add(pos2, vector.multiply(dir, data.width))
		pos2.y = pos.y - 3 + data.height

		-- normalize x/z so that pos2 > pos1
		if pos2.x < pos1.x then
			pos2.x, pos1.x = pos1.x, pos2.x
		end
		if pos2.z < pos1.z then
			pos2.z, pos1.z = pos1.z, pos2.z
		end
		return pos1, pos2
	end
end

local function control_player(pos, pos1, pos2, player_name)
	if Currently_left_the_game[player_name] then
		Currently_left_the_game[player_name] = nil
		return
	end
	local player = player_name and minetest.get_player_by_name(player_name)
	if player then
		if is_crane_running(pos) then
			-- check if outside of the construction area
			local correction = false
			local pl_pos = player:get_pos()
			if pl_pos then
				if pl_pos.x < pos1.x then pl_pos.x = pos1.x; correction = true end
				if pl_pos.x > pos2.x then pl_pos.x = pos2.x; correction = true end
				if pl_pos.y < pos1.y then pl_pos.y = pos1.y; correction = true end
				if pl_pos.y > pos2.y then pl_pos.y = pos2.y; correction = true end
				if pl_pos.z < pos1.z then pl_pos.z = pos1.z; correction = true end
				if pl_pos.z > pos2.z then pl_pos.z = pos2.z; correction = true end
				-- check if a protected area is violated
				if correction == false and minetest.is_protected(pl_pos, player_name) then
					minetest.chat_send_player(player_name, "[Tower Crane] "..S("Area is protected."))
					correction = true
				end
				local meta = minetest.get_meta(pos)
				if correction == true then
					local last_pos = S2P(meta:get_string("last_known_pos"))
					if last_pos then
						player:set_pos(last_pos)	
					end
				else  -- store last known correct position
					meta:set_string("last_known_pos", P2S(pl_pos))
				end
				minetest.after(1, control_player, pos, pos1, pos2, player_name)
			end
		else
			store_last_used(pos)
			place_player(pos, player)
			reset_operator_privs(player)
		end
	else
		local meta = minetest.get_meta(pos)
		meta:set_int("running", 0)
	end
end	

minetest.register_node("towercrane:mast_ctrl_on", {
	description = S("Tower Crane Mast Ctrl On"),
	drawtype = "node",
	tiles = {
		"towercrane_base.png",
		"towercrane_base.png",
		"towercrane_base.png",
		"towercrane_base.png",
		"towercrane_base.png^towercrane_button_on.png",
		"towercrane_base.png^towercrane_button_on.png",
	},
	-- switch the crane OFF
	on_rightclick = function (pos, node, clicker)
		local pos2 = get_my_crane_pos(clicker)
		if pos2 and vector.equals(pos, pos2) or minetest.check_player_privs(clicker, "server") then
			stop_crane(pos, clicker)
		end
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Switch crane on/off"))
	end,

	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 3,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly=0, not_in_creative_inventory=1},
})

minetest.register_node("towercrane:mast_ctrl_off", {
	description = S("Tower Crane Mast Ctrl Off"),
	drawtype = "node",
	tiles = {
		"towercrane_base.png",
		"towercrane_base.png",
		"towercrane_base.png",
		"towercrane_base.png",
		"towercrane_base.png^towercrane_button_off.png",
		"towercrane_base.png^towercrane_button_off.png",
	},
	-- switch the crane ON
	on_rightclick = function (pos, node, clicker)
		if is_my_crane(pos, clicker) and not is_operator(clicker) then
			if set_operator_privs(clicker, pos) then
				start_crane(pos, clicker)
				local pos1, pos2 = calc_construction_area(pos)
				-- control player every second
				minetest.after(1, control_player, pos, pos1, pos2, clicker:get_player_name())
			end
		end
	end,

	on_construct = function(pos)
		-- add infotext
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Switch crane on/off"))
	end,

	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly=0, not_in_creative_inventory=1},
})

minetest.register_on_joinplayer(function(player)
	local pos = get_my_crane_pos(player)
	if pos then
		reset_operator_privs(player)
		stop_crane(pos, player)
	end
end)

minetest.register_on_leaveplayer(function(player)
	if is_operator(player) then
		Currently_left_the_game[player:get_player_name()] = true
	end
end)

minetest.register_on_dieplayer(function(player, reason)
	if is_operator(player) then
		local pos = get_my_crane_pos(player)
		if pos then
			reset_operator_privs(player)
			stop_crane(pos, player)
		end
	end
end)

minetest.register_lbm({
	label = "[towercrane] break down",
	name = "towercrane:break_down",
	nodenames = {"towercrane:mast_ctrl_off", "towercrane:mast_ctrl_on"},
	run_at_every_load = true,
	action = function(pos, node)
		local t = minetest.get_day_count()
		local meta = minetest.get_meta(pos)
		local last_used = meta:get_int("last_used") or 0
		if last_used == 0 then
			meta:set_int("last_used", t + DAYS_WITHOUT_USE)
		elseif t > last_used then
			local base_pos = {x=pos.x, y=pos.y-1, z=pos.z}
			towercrane.get_crane_down(base_pos)
		end
	end
})

-------------------------------------------------------------------------------
-- export
-------------------------------------------------------------------------------
towercrane.is_crane_running = is_crane_running
