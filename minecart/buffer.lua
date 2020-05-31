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

local CYCLE_TIME = 2

local StopTime = {}

local function formspec(pos)
	local name = M(pos):get_string("name")
	local time = M(pos):get_int("time")
	local s = "size[4,4.2]" ..
		"label[0,0;Configuration]" ..
		"field[0.5,1.2;3.6,1;name;"..S("Station name")..":;"..name.."]"..
		"button_exit[1,3.4;2,1;exit;Save]"
	if minecart.hopper_enabled then
		return s.."field[0.5,2.5;3.6,1;time;"..S("Stop time/sec")..":;"..time.."]"
	end
	return s
end

local function remote_station_name(pos)
	local route = minecart.get_route(P2S(pos))
	if route and route.dest_pos then
		local pos2 = S2P(route.dest_pos)
		return M(pos2):get_string("name")
	end
	return "none"
end

local function on_punch(pos, node, puncher)	
	local name = M(pos):get_string("name")
	M(pos):set_string("infotext", name..": "..S("connected to").." "..remote_station_name(pos))
	M(pos):set_string("formspec", formspec(pos))
	if minecart.hopper_enabled then
		minetest.get_node_timer(pos):start(CYCLE_TIME)
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
		minecart.del_route(minetest.pos_to_string(pos))
		M(pos):set_string("formspec", formspec(pos))
		if minecart.hopper_enabled then
			minetest.get_node_timer(pos):start(CYCLE_TIME)
		end
	end,
	on_timer = function(pos, elapsed)
		local time = M(pos):get_int("time")
		if time > 0 then
			local hash = minetest.hash_node_position(pos)
			local param2 = (minetest.get_node(pos).param2 + 2) % 4
			if minecart.check_cart_for_pushing(pos, param2) then
				if StopTime[hash] then
					if StopTime[hash] < minetest.get_gametime() then
						StopTime[hash] = nil
						local node = minetest.get_node(pos)
						local dir = minetest.facedir_to_dir(node.param2)
						minecart.punch_cart(pos, param2, 0, dir)
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
		minecart.del_route(minetest.pos_to_string(pos))
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
			M(pos):set_string("infotext", fields.name.." "..S("connected to").." "..remote_station_name(pos))			
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
