--[[

	Hyperloop Mod
	=============

	Copyright (C) 2017-2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

]]--

-- for lazy programmers
local SP = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local S = hyperloop.S
local NS = hyperloop.NS
local I, _ = dofile( minetest.get_modpath("hyperloop").."/intllib.lua")

local Stations = hyperloop.Stations

local function enter_display(tStation, text)
    -- determine position
	if tStation ~= nil then
		local lcd_pos = hyperloop.new_pos(tStation.pos, tStation.facedir, "1F", 2)
		-- update display
		minetest.registered_nodes["hyperloop:lcd"].update(lcd_pos, text) 
	end
end

local function on_final_close_door(tStation)
	-- close the door and play sound if no player is around
	if hyperloop.is_player_around(tStation.pos) then
		-- try again later
		minetest.after(3.0, on_final_close_door, tStation)
	else
		hyperloop.close_pod_door(tStation)
		enter_display(tStation, I(" |  | << Hyperloop >> | be anywhere"))
	end
end

local function on_open_door(tArrival)
	-- open the door and play sound
	local meta = minetest.get_meta(tArrival.pos)
	meta:set_int("arrival_time", 0) -- finished
	-- open door
	hyperloop.open_pod_door(tArrival)
	-- prepare display for the next trip
	enter_display(tArrival, I("Thank you | for | travelling | with | Hyperloop."))
	minetest.after(5.0, on_final_close_door, tArrival, tArrival.facedir)
end

local function on_arrival(tDeparture, tArrival, player_name, sound)
	local player = minetest.get_player_by_name(player_name)
	-- activate display
	local text = I(" | Welcome at | | ")..string.sub(tArrival.name, 1, 13)
	enter_display(tArrival, text)
	-- stop timer
	minetest.get_node_timer(tDeparture.pos):stop()
	-- move player to the arrival station
	if player ~= nil then
		local pos = table.copy(tArrival.pos)
		pos.y = pos.y + 0.5
		player:set_pos(pos)
		-- rotate player to look in correct arrival direction
		-- calculate the look correction
		-- workaround to prevent server crashes
		local val1 = hyperloop.facedir_to_rad(tDeparture.facedir)
		local val2 = player:get_look_horizontal()
		if val1 ~= nil and val2 ~= nil then
			local offs = val1 - val2
			local yaw = hyperloop.facedir_to_rad(tArrival.facedir) - offs
			player:set_look_yaw(yaw)
		end
		-- set player name again
		if tArrival.attributes then
			player:set_nametag_attributes(tArrival.attributes)
		end
	end
	-- play arrival sound
	minetest.sound_stop(sound)
	minetest.sound_play("down2", {
			pos = tArrival.pos,
			gain = 0.5,
			max_hear_distance = 2
		})

	minetest.after(4.0, on_open_door, tArrival)
end

local function on_travel(tDeparture, tArrival, player_name, atime)
	-- play sound and switch door state
	local sound = minetest.sound_play("normal2", {
			pos = tDeparture.pos,
			gain = 0.5,
			max_hear_distance = 2,
			loop = true,
		})
	hyperloop.animate_pod_door(tDeparture)
	minetest.after(atime, on_arrival, tDeparture, tArrival, player_name, sound)
	minetest.after(atime, on_final_close_door, tDeparture)
end

local function display_timer(pos, elapsed)
	-- update display with trip data
	local tStation = hyperloop.get_base_station(pos)
	if tStation then
		local meta = M(pos)
		local atime = meta:get_int("arrival_time") - 1
		meta:set_int("arrival_time", atime)
		local text = meta:get_string("lcd_text")
		if atime > 2 then
			enter_display(tStation, text..atime.." sec")
			return true
		else
			return false
		end
	end
	return false
end

local function meter_to_km(dist)
	if dist < 1000 then
		return tostring(dist).." m"
	elseif dist < 10000 then
		return string.format("%.3f km", dist/1000)
	else
		return string.format("%.1f km", dist/1000)
	end
end

-- place the player, close the door, activate display
local function on_start_travel(pos, node, clicker)
	-- arrival data
	local meta = M(pos)
	local tDeparture, departure_pos = hyperloop.get_base_station(pos)
	local arrival_pos = hyperloop.get_arrival(departure_pos)
	if arrival_pos == nil then
		minetest.chat_send_player(clicker:get_player_name(), S("[Hyperloop] No booking entered!"))
		return
	end
	local tArrival = hyperloop.get_station(arrival_pos)
	if tDeparture == nil or tArrival == nil then
		return
	end
	
	minetest.sound_play("up2", {
			pos = pos,
			gain = 0.5,
			max_hear_distance = 2
		})
	
	-- close the door at arrival station
	hyperloop.close_pod_door(tArrival)
	-- place player on the seat
	pos.y = pos.y - 0.5
	clicker:set_pos(pos)
	-- rotate player to look in move direction
	clicker:set_look_horizontal(hyperloop.facedir_to_rad(tDeparture.facedir))
    -- hide player name
	tArrival.attributes = clicker:get_nametag_attributes()
	clicker:set_nametag_attributes({text = "     "})
	
	-- activate display
	local dist = hyperloop.distance(pos, tArrival.pos) 
	local text = I("Destination:").." | "..string.sub(tArrival.name, 1, 13).." | "..I("Distance:").." | "..
				 meter_to_km(dist).." | "..I("Arrival in:").." | "
	local atime
	if dist < 1000 then
		atime = 10 + math.floor(dist/200)		-- 10..15 sec
	elseif dist < 10000 then
		atime = 15 + math.floor(dist/600)		-- 16..32 sec
	else
		atime = 32								-- 32 sec is the maximum
	end
	enter_display(tDeparture, text..atime.." sec")

	-- block departure and arrival stations
	hyperloop.block(departure_pos, arrival_pos, atime+10)	

	-- store some data for on_timer()
	meta:set_int("arrival_time", atime)
	meta:set_string("lcd_text", text)
	minetest.get_node_timer(pos):start(1.0)
	hyperloop.close_pod_door(tDeparture)

	atime = atime - 7 -- substract start/arrival time
	minetest.after(4.9, on_travel, tDeparture, tArrival, clicker:get_player_name(), atime)
end

-- Hyperloop Seat
minetest.register_node("hyperloop:seat", {
	description = S("Hyperloop Pod Seat"),
	tiles = {
		"hyperloop_seat-top.png",
		"hyperloop_seat-side.png",
		"hyperloop_seat-side.png",
		"hyperloop_seat-side.png",
		"hyperloop_seat-side.png",
		"hyperloop_seat-side.png",
	},
	drawtype = "nodebox",
	paramtype = 'light',
	light_source = 1,	
	paramtype2 = "facedir",
	is_ground_content = false,
	walkable = false,
	drop = "",
	groups = {not_in_creative_inventory=1, crumbly=3},
	node_box = {
		type = "fixed",
		fixed = {
			{ -6/16, -8/16, -8/16,   6/16, -2/16, 5/16},
			{ -8/16, -8/16, -8/16,  -6/16,  4/16, 8/16},
			{  6/16, -8/16, -8/16,   8/16,  4/16, 8/16},
			{ -6/16, -8/16,  4/16,   6/16,  6/16, 8/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16,   8/16, -2/16, 8/16 },
	},

	on_timer = display_timer,
	on_rightclick = on_start_travel,
	on_rotate = screwdriver.disallow,	
	
	auto_place_node = function(pos, facedir, sStationPos)
		M(pos):set_string("sStationPos", sStationPos)
	end,
})
