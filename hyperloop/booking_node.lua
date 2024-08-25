--[[

	Hyperloop Mod
	=============

	Copyright (C) 2017-2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	Booking/ticket machine
]]--

-- for lazy programmers
local SP = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local S = hyperloop.S

-- Used to store the Station list for each booking machine:
--    tStationList[SP(pos)] = {pos1, pos2, ...}
local tStationList = {}

local Stations = hyperloop.Stations


-- Form spec for the station list
local function generate_string(sortedList)
	local tRes = {"size[12,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"item_image[0,0;1,1;hyperloop:booking]"..
	"label[4,0; "..S("Select your destination").."]"}
	tRes[2] = "tablecolumns[text,width=20;text,width=6,align=right;text]"

	local stations = {}
	for idx,tDest in ipairs(sortedList) do
		local name = tDest.name or S("<unknown>")
		local distance = tDest.distance or 0
		local info = tDest.booking_info or ""

		stations[#stations+1] = minetest.formspec_escape(string.sub(name, 1, 28))
		stations[#stations+1] = distance.."m"
		stations[#stations+1] = minetest.formspec_escape(info)
	end

	if #stations>0 then
		tRes[#tRes+1] = "table[0,1;11.8,7.2;button;"..table.concat(stations, ",").."]"
	else
		tRes[#tRes+1] = "button_exit[4,4;3,1;button;Update]"
	end

	return table.concat(tRes)
end

local function store_station_list(pos, sortedList)
	local tbl = {}
	for idx,item in ipairs(sortedList) do
		tbl[#tbl+1] = item.pos
	end
	tStationList[SP(pos)] = tbl
end

local function remove_junctions(sortedList)
	local tbl = {}
	for idx,item in ipairs(sortedList) do
		if not item.junction and item.booking_pos then
			tbl[#tbl+1] = item
		end
	end
	return tbl
end

local function filter_subnet(sortedList, subnet)
	if hyperloop.subnet_enabled then
		if subnet == "" then
			subnet = nil
		end

		local tbl = {}
		for idx,item in ipairs(sortedList) do
			if item.subnet == subnet then
				tbl[#tbl+1] = item
			end
		end
		return tbl
	end
	return sortedList
end

-- Used to update the station list for booking machine
-- and teleport list.
local function station_list_as_string(pos, subnet)
	-- Generate a name sorted list of all connected stations
	local sortedList = Stations:station_list(pos, pos, "name")
	-- remove all junctions from the list
	sortedList = remove_junctions(sortedList)
	-- use subnet pattern to reduce the list
	sortedList = filter_subnet(sortedList, subnet)
	-- store the list for later use
	store_station_list(pos, sortedList)
	-- Generate the formspec string
	return generate_string(sortedList)
end

local naming_formspec

if hyperloop.subnet_enabled then
	naming_formspec = function(pos)
		local meta = M(pos)
		local formspec = "size[7,5.4]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"label[0,0;"..S("Please enter the station name to\nwhich this booking machine belongs.").."]" ..
		"field[0.2,1.5;7.1,1;name;"..S("Station name")..";MyTown]" ..
		"field[0.2,2.7;7.1,1;info;"..S("Additional station information")..";]" ..
		"field[0.2,3.9;7.1,1;subnet;"..S("Subnet name (optional)")..";]" ..
		"button_exit[2.5,4.7;2,1;exit;Save]"
		meta:set_string("formspec", formspec)
		meta:set_int("change_counter", 0)
	end
else
	naming_formspec = function(pos)
		local meta = M(pos)
		local formspec = "size[7,4.4]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"label[0,0;"..S("Please enter the station name to\nwhich this booking machine belongs.").."]" ..
		"field[0.2,1.5;7.1,1;name;"..S("Station name")..";MyTown]" ..
		"field[0.2,2.7;7.1,1;info;"..S("Additional station information")..";]" ..
		"button_exit[2.5,3.7;2,1;exit;Save]"
		meta:set_string("formspec", formspec)
		meta:set_int("change_counter", 0)
	end
end

local function booking_machine_update(pos)
	local meta = M(pos)
	local sStationPos = meta:get_string("sStationPos")
	if sStationPos ~= "" then
		local station_pos = P(sStationPos)
		local counter = meta:get_int("change_counter") or 0
		local changed, newcounter = Stations:changed(counter)
		if changed or not tStationList[sStationPos] then
			local subnet = meta:get_string("subnet")
			meta:set_string("formspec", station_list_as_string(station_pos, subnet))
			meta:set_int("change_counter", newcounter)
		end
	end
end

local function on_rightclick(pos)
	booking_machine_update(pos)
end

local function on_receive_fields(pos, formname, fields, player)
	-- station name entered?
	if fields.name ~= nil then
		local station_name = string.trim(fields.name)
		if station_name == "" then
			return
		end
		local stationPos = Stations:get_next_station(pos)
		if stationPos then
			if Stations:get(stationPos).booking_pos then
				hyperloop.chat(player, S("Station has already a booking machine!"))
				return
			end
			-- add subnet name if available
			local subnet = string.trim(fields.subnet or "")
			if subnet == "" then
				subnet = nil
			end
			-- store meta and generate station formspec
			Stations:update(stationPos, {
					name = station_name,
					booking_pos = pos,
					booking_info = string.trim(fields.info),
					subnet = subnet,
			})

			local meta = M(pos)
			meta:set_string("sStationPos", SP(stationPos))
			meta:set_string("infotext", "Station: "..station_name)
			meta:set_string("subnet", string.trim(fields.subnet or ""))
			meta:set_int("change_counter", 0) -- force update
			booking_machine_update(pos)
		else
			hyperloop.chat(player, S("Invalid station name!"))
		end
	elseif fields.button ~= nil then -- destination selected?
		local te = minetest.explode_table_event(fields.button)
		local idx = tonumber(te.row)
		if idx and te.type=="CHG" then
			local tStation, src_pos = hyperloop.get_base_station(pos)
			local dest_pos = tStationList[SP(src_pos)] and tStationList[SP(src_pos)][idx]
			if dest_pos and tStation then
				-- place booking if not already blocked
				if hyperloop.reserve(src_pos, dest_pos, player) then
					hyperloop.set_arrival(src_pos, dest_pos)
					-- open the pod door
					hyperloop.open_pod_door(tStation)
				end
			else
				-- data is corrupt, try an update
				M(pos):set_int("change_counter", 0)
			end

			minetest.close_formspec(player:get_player_name(), formname)
		end
	end
end

local function on_destruct(pos)
	local sStationPos = M(pos):get_string("sStationPos")
	if sStationPos ~= "" then
		Stations:update(P(sStationPos), {
			booking_pos = "nil",
			booking_info = "nil",
			name = "Station",
		})
	end
end

-- wap from wall to ground
local function swap_node(pos, placer)
	pos.y = pos.y - 1
	if minetest.get_node_or_nil(pos).name ~= "air" then
		local node = minetest.get_node(pos)
		node.name = "hyperloop:booking_ground"
		node.param2 = hyperloop.get_facedir(placer)
		pos.y = pos.y + 1
		minetest.swap_node(pos, node)
	else
		pos.y = pos.y + 1
	end
end

-- wall mounted booking machine
minetest.register_node("hyperloop:booking", {
	description = S("Hyperloop Booking Machine"),
	tiles = {
		-- up, down, right, left, back, front
		"hyperloop_booking.png",
		"hyperloop_booking.png",
		"hyperloop_booking.png",
		"hyperloop_booking.png",
		"hyperloop_booking.png",
		"hyperloop_booking_front.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, 2/16,  8/16,  8/16, 8/16},
		},
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		naming_formspec(pos)
		swap_node(pos, placer)
	end,

	on_rotate = screwdriver.disallow,
	on_receive_fields = on_receive_fields,
	on_destruct = on_destruct,
	on_rightclick = on_rightclick,

	paramtype = 'light',
	light_source = 2,
	paramtype2 = "facedir",
	groups = {cracky=2},
	is_ground_content = false,
})

-- ground mounted booking machine
minetest.register_node("hyperloop:booking_ground", {
	description = S("Hyperloop Booking Machine"),
	tiles = {
		-- up, down, right, left, back, front
		"hyperloop_booking.png",
		"hyperloop_booking.png",
		"hyperloop_booking.png",
		"hyperloop_booking.png",
		"hyperloop_booking.png",
		"hyperloop_booking_front.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, -3/16,  8/16,  8/16, 3/16},
		},
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		naming_formspec(pos)
	end,

	on_receive_fields = on_receive_fields,
	on_destruct = on_destruct,
	on_rightclick = on_rightclick,

	on_rotate = screwdriver.disallow,
	drop = "hyperloop:booking",
	light_source = 2,
	paramtype = 'light',
	paramtype2 = "facedir",
	groups = {cracky=2, not_in_creative_inventory=1},
	is_ground_content = false,
})



