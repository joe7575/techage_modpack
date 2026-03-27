--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Signal AND.
	Signal is sent, if all input signals are received.
]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for I18n.
local S = signs_bot.S

local lib = signs_bot.lib

local function inputs(tbl)
	local out = {}
	for _,v in ipairs(tbl) do
		if v then
			out[#out + 1] = "1"
		else
			out[#out + 1] = "0"
		end
	end
	return table.concat(out, " ")
end

local function update_infotext(pos, dest_pos, cmnd)
	local mem = tubelib2.get_mem(pos)
	local text = table.concat({
		S("Signal AND with"),
		#mem.inputs or 0,
		S("inputs"),
		":",
		S("Connected with"),
		P2S(dest_pos),
		"/",
		cmnd,
		":",
		inputs(mem.inputs or {})
	}, " ")
	M(pos):set_string("infotext", text)
end

local function all_inputs(mem)
	mem.inputs = mem.inputs or {}
	for _,v in ipairs(mem.inputs) do
		if not v then return false end
	end
	return true
end

local function zero_inputs(mem)
	mem.inputs = mem.inputs or {}
	for _,v in ipairs(mem.inputs) do
		if v then return true end
	end
	return false
end

local function clear_inputs(mem)
	mem.inputs = mem.inputs or {}
	for i,_ in ipairs(mem.inputs) do
		mem.inputs[i] = false
	end
end

local function infotext(pos)
	local meta = M(pos)
	local dest_pos = meta:get_string("signal_pos")
	local signal = meta:get_string("signal_data")
	if dest_pos ~= "" and signal ~= "" then
		update_infotext(pos, S2P(dest_pos), signal)
	end
end

-- Used by the pairing tool
local function signs_bot_get_signal(pos, node)
	local mem = tubelib2.get_mem(pos)
	mem.known_sensors = mem.known_sensors or {}
	if not mem.known_sensors[node.hash] then
		mem.known_sensors[node.hash] = true
		mem.inputs = mem.inputs or {}
		mem.inputs[#mem.inputs + 1] = false
		clear_inputs(mem)
		infotext(pos)
	end
	return #mem.inputs
end

-- switch to normal texture
local function turn_off(pos)
	local node = minetest.get_node(pos)
	if node.name == "signs_bot:and2" or node.name == "signs_bot:and3" then
		node.name = "signs_bot:and1"
		minetest.swap_node(pos, node)
	end
end

-- switch to not zero texture
local function not_zero(pos)
	local node = minetest.get_node(pos)
	if node.name == "signs_bot:and1" or node.name == "signs_bot:and3" then
		node.name = "signs_bot:and2"
		minetest.swap_node(pos, node)
	end
	infotext(pos)
end

local function send_signal(pos)
	local meta = M(pos)
	local mem = tubelib2.get_mem(pos)
	local node = minetest.get_node(pos)
	if node.name == "signs_bot:and1" or node.name == "signs_bot:and2" then
		node.name = "signs_bot:and3"
		minetest.swap_node(pos, node)
		minetest.after(2, turn_off, pos)
	end
	signs_bot.send_signal(pos)
	signs_bot.lib.activate_extender_nodes(pos, true)
	clear_inputs(mem)
	infotext(pos)
end

local function valid_state(pos)
	local signal = M(pos):get_string("signal_data")
	local state = signs_bot.get_state(pos)
	-- Signs box must be in the opposite state
	return state == nil or (signal == "on" and state == false) or (signal == "off" and state == true)
end

-- To be called from sensors
local function signs_bot_on_signal(pos, node, signal)
	local mem = tubelib2.get_mem(pos)
	signal = tonumber(signal) or 1
	if valid_state(pos) then
		mem.inputs = mem.inputs or {}
		mem.inputs[signal] = true

		if all_inputs(mem) then
			send_signal(pos)
		else
			not_zero(pos)
		end
	end
end

minetest.register_node("signs_bot:and1", {
	description = S("Signal AND"),
	inventory_image = "signs_bot_and_inv.png",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -11/32, -1/2, -11/32, 11/32, -5/16, 11/32},
		},
	},
	tiles = {
		-- up, down, right, left, back, front
		"signs_bot_sensor2.png^signs_bot_and1.png",
		"signs_bot_sensor2.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local mem = tubelib2.init_mem(pos)
		mem.inputs = {}
		infotext(pos)
	end,

	signs_bot_get_signal = signs_bot_get_signal,
	signs_bot_on_signal = signs_bot_on_signal,
	update_infotext = update_infotext,
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	use_texture_alpha = signs_bot.CLIP,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {sign_bot_sensor = 1, cracky = 1},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("signs_bot:and2", {
	description = S("Signal AND"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -11/32, -1/2, -11/32, 11/32, -5/16, 11/32},
		},
	},
	tiles = {
		-- up, down, right, left, back, front
		"signs_bot_sensor2.png^signs_bot_and2.png",
		"signs_bot_sensor2.png",
	},

	on_punch = function(pos, node, puncher, pointed_thing)
		local mem = tubelib2.get_mem(pos)
		clear_inputs(mem)
		turn_off(pos)
		infotext(pos)
	end,
	signs_bot_get_signal = signs_bot_get_signal,
	signs_bot_on_signal = signs_bot_on_signal,
	update_infotext = update_infotext,
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	use_texture_alpha = signs_bot.CLIP,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	is_ground_content = false,
	drop = "signs_bot:and1",
	groups = {sign_bot_sensor = 1, cracky = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("signs_bot:and3", {
	description = S("Signal AND"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -11/32, -1/2, -11/32, 11/32, -5/16, 11/32},
		},
	},
	tiles = {
		-- up, down, right, left, back, front
		"signs_bot_sensor2.png^signs_bot_and3.png",
		"signs_bot_sensor2.png",
	},

	update_infotext = update_infotext,
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	use_texture_alpha = signs_bot.CLIP,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	is_ground_content = false,
	diggable = false,
	groups = {sign_bot_sensor = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_craft({
	output = "signs_bot:and1",
	recipe = {
		{"group:wood", "dye:yellow", ""},
		{"", "", ""},
		{"default:steel_ingot", "", "default:mese_crystal_fragment"},
	}
})

if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "and", {
		name = S("Signal AND"),
		data = {
			item = "signs_bot:and1",
			text = table.concat({
				S("Signal is sent, if all input signals are received."),
			}, "\n")
		},
	})
end

