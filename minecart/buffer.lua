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
local S2P = minetest.string_to_pos
local S = minecart.S

local CYCLE_TIME = 2

local StopTime = {}

local function formspec(pos)
	local name = M(pos):get_string("name")
	local time = M(pos):get_int("time")
	return "size[4,4.2]" ..
		"label[0,0;Configuration]" ..
		"field[0.5,1.2;3.6,1;name;"..S("Station name")..":;"..name.."]"..
		"button_exit[1,3.4;2,1;exit;Save]"..
		"field[0.5,2.5;3.6,1;time;"..S("Waiting time/sec")..":;"..time.."]"
end

local function remote_station_name(pos)
	local route = minecart.get_route(pos)
	if route and route.dest_pos then
		return M(route.dest_pos):get_string("name")
	end
end

local function on_punch(pos, node, puncher)
	local name = M(pos):get_string("name")
	local dest = remote_station_name(pos)
	if dest then
		M(pos):set_string("infotext", name .. ": " .. S("connected to") .. " " .. dest)
	else
		M(pos):set_string("infotext", name .. ": " .. S("Not connected!"))
	end
	M(pos):set_string("formspec", formspec(pos))
	minetest.get_node_timer(pos):start(CYCLE_TIME)

	-- Optional Teleport function
	if not minecart.teleport_enabled then return end
	local route = minecart.get_route(pos)
	if route and route.dest_pos and puncher and puncher:is_player() then

		-- only teleport if the user is not pressing shift
		if not puncher:get_player_control()['sneak'] then
			local playername = puncher:get_player_name()

			local teleport = function()
				-- Make sure the player object still exists
				local player = minetest.get_player_by_name(playername)
				if player then player:set_pos(route.dest_pos) end
			end
			minetest.after(0.25, teleport)
		end
	end
end

minetest.register_node("minecart:buffer", {
	description = S("Minecart Railway Buffer"),
	tiles = {
		'default_junglewood.png',
		'default_junglewood.png',
		'default_junglewood.png',
		'default_junglewood.png',
		'default_junglewood.png',
		'default_junglewood.png^minecart_buffer.png',
		},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16,  8/16,  -4/16,  8/16},
			{-8/16, -4/16, -8/16,  8/16,   0/16,  4/16},
			{-8/16,  0/16, -8/16,  8/16,   4/16,  0/16},
			{-8/16,  4/16, -8/16,  8/16,   8/16, -4/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, -8/16,  8/16, 8/16, 8/16},
	},
	after_place_node = function(pos, placer)
		M(pos):set_string("owner", placer:get_player_name())
		minecart.del_route(pos)
		M(pos):set_string("formspec", formspec(pos))
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
	on_timer = function(pos, elapsed)
		local time = M(pos):get_int("time")
		if time > 0 then
			local hash = minetest.hash_node_position(pos)
			local param2 = (minetest.get_node(pos).param2 + 2) % 4
			if minecart.is_cart_available(pos, param2, 0.5) then
				if StopTime[hash] then
					if StopTime[hash] < minetest.get_gametime() then
						StopTime[hash] = nil
						local dir = minetest.facedir_to_dir(param2)
						minecart.punch_cart(pos, param2, 0.5, dir)
					end
				else
					StopTime[hash] = minetest.get_gametime() + time
				end
			else
				StopTime[hash] = nil
			end
		end
		return true
	end,
	after_dig_node = function(pos)
		minecart.del_route(pos)
		local hash = minetest.hash_node_position(pos)
		StopTime[hash] = nil
	end,
	on_receive_fields = function(pos, formname, fields, player)
		if M(pos):get_string("owner") ~= player:get_player_name() then
			return
		end
		if (fields.key_enter == "true" or fields.exit == "Save") and fields.name ~= "" then
			M(pos):set_string("name", fields.name)
			M(pos):set_int("time", tonumber(fields.time) or 0)
			M(pos):set_string("formspec", formspec(pos))
			local dest = remote_station_name(pos)
			if dest then
				M(pos):set_string("infotext", fields.name .. ": " .. S("connected to") .. " " .. dest)
			else
				M(pos):set_string("infotext", fields.name .. ": " .. S("Not connected!"))
			end
			minetest.get_node_timer(pos):start(CYCLE_TIME)
		end
	end,
	on_punch = on_punch,
	paramtype = "light",
	sunlight_propagates = true,
	on_rotate = screwdriver.disallow,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "minecart:buffer",
	recipe = {
		{"dye:red", "", "dye:white"},
		{"default:steel_ingot", "default:junglewood", "default:steel_ingot"},
	},
})

minetest.register_lbm({
	label = "Delete metadata",
	name = "minecart:metadata",
	nodenames = {"minecart:buffer"},
	run_at_every_load = true,
	action = function(pos, node)
		-- delete old metadata around the buffer (bugfix)
		local pos1 = {x = pos.x - 2, y = pos.y - 2, z = pos.z - 2}
		local pos2 = {x = pos.x + 2, y = pos.y + 2, z = pos.z + 2}
		for _, pos in ipairs(minetest.find_nodes_with_meta(pos1, pos2)) do
			minecart.del_metadata(pos)
		end
	end,
})
