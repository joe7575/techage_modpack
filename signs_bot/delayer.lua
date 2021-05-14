--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Signal Delayer.
	Signals are forwarded delayed. Subsequent signals are queued.
]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for I18n.
local S = signs_bot.S

local CYCLE_TIME = 2

local function update_infotext(pos, dest_pos, cmnd)
	M(pos):set_string("infotext", S("Signal Delayer: Connected with").." "..P2S(dest_pos).." / "..cmnd)
end	

local function infotext(pos)
	local meta = M(pos)
	local dest_pos = meta:get_string("signal_pos")
	local signal = meta:get_string("signal_data")
	if dest_pos ~= "" and signal ~= "" then
		update_infotext(pos, S2P(dest_pos), signal)
	end
end

local function formspec(meta)
	local label = minetest.formspec_escape(S("Delay time [sec]:"))
	local value = minetest.formspec_escape(meta:get_int("time"))
	return "size[4,3]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"field[0.3,1;4,1;time;"..label..";"..value.."]"..
	"button_exit[1,2.2;2,1;start;"..S("Start").."]"
end

-- Used by the pairing tool
local function signs_bot_get_signal(pos, node)
	return "do"
end

-- switch to normal or loaded texture
local function turn_off(pos)	
	local mem = tubelib2.get_mem(pos)
	local node = minetest.get_node(pos)
	if mem.queue > 0 then
		node.name = "signs_bot:delayer_loaded"
	else
		node.name = "signs_bot:delayer"
	end
	minetest.swap_node(pos, node)
end

-- switch to loaded texture
local function loaded(pos)	
	local node = minetest.get_node(pos)
	if node.name == "signs_bot:delayer" or node.name == "signs_bot:delayer_on" then
		node.name = "signs_bot:delayer_loaded"
		minetest.swap_node(pos, node)
	end
end

local function send_signal(pos)
	local meta = M(pos)
	local mem = tubelib2.get_mem(pos)
	local node = minetest.get_node(pos)
	if node.name == "signs_bot:delayer" or node.name == "signs_bot:delayer_loaded" then
		node.name = "signs_bot:delayer_on"
		minetest.swap_node(pos, node)
		minetest.after(2, turn_off, pos)
	end
	signs_bot.send_signal(pos)
	signs_bot.lib.activate_extender_nodes(pos, true)
	mem.queue = (mem.queue or 1) - 1
	if mem.queue > 0 then
		mem.time = meta:get_int("time")
	end
end

local function node_timer(pos)
	local meta = M(pos)
	local mem = tubelib2.get_mem(pos)
	mem.time = (mem.time or 0) - CYCLE_TIME
	--print("node_timer time="..mem.time..", queue="..mem.queue)
	if mem.time <= 0 and mem.queue > 0 then
		send_signal(pos)
	end
	return mem.queue > 0
end

-- To be called from sensors
local function signs_bot_on_signal(pos, node, signal)
	local meta = M(pos)
	local mem = tubelib2.get_mem(pos)
	mem.queue = mem.queue or 0
	
	--print("signs_bot_on_signal", signal, meta:get_int("time"))
	if signal ~= "do" or  meta:get_int("time") == 0 then return end
		
	if mem.queue <= 0 then
		mem.queue = 1
		mem.time = meta:get_int("time")
		loaded(pos)
	else
		mem.queue = mem.queue + 1
	end
	minetest.get_node_timer(pos):start(CYCLE_TIME)
end

local function on_receive_fields(pos, formname, fields, player)
	local mem = tubelib2.get_mem(pos)
	local meta = M(pos)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	if fields.key_enter_field == "time" or fields.start then
		local time = tonumber(fields.time)
		if time and time >= 0 and time < 999999 then
			meta:set_int("time", time)
			mem.time = 0
			mem.queue = 0
		end
	end
	meta:set_string("formspec", formspec(meta))
	turn_off(pos)
end

minetest.register_node("signs_bot:delayer", {
	description = S("Signal Delayer"),
	inventory_image = "signs_bot_delayer_inv.png",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -11/32, -1/2, -11/32, 11/32, -5/16, 11/32},
		},
	},
	tiles = {
		-- up, down, right, left, back, front
		"signs_bot_sensor2.png^signs_bot_delayer.png",
		"signs_bot_sensor2.png",
	},
	
	after_place_node = function(pos, placer)
		local meta = M(pos)
		local mem = tubelib2.init_mem(pos)
		mem.time = 0
		mem.queue = 0
		infotext(pos)
		meta:set_string("formspec", formspec(meta))
	end,
	
	signs_bot_get_signal = signs_bot_get_signal,
	signs_bot_on_signal = signs_bot_on_signal,
	on_receive_fields = on_receive_fields,
	on_timer = node_timer,
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

minetest.register_node("signs_bot:delayer_loaded", {
	description = S("Signal Delayer"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -11/32, -1/2, -11/32, 11/32, -5/16, 11/32},
		},
	},
	tiles = {
		-- up, down, right, left, back, front
		"signs_bot_sensor2.png^signs_bot_delayer_loaded.png",
		"signs_bot_sensor2.png",
	},

	signs_bot_get_signal = signs_bot_get_signal,
	signs_bot_on_signal = signs_bot_on_signal,
	on_receive_fields = on_receive_fields,
	on_timer = node_timer,
	update_infotext = update_infotext,
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	use_texture_alpha = signs_bot.CLIP,
	is_ground_content = false,
	diggable = false,
	groups = {sign_bot_sensor = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("signs_bot:delayer_on", {
	description = S("Signal Delayer"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -11/32, -1/2, -11/32, 11/32, -5/16, 11/32},
		},
	},
	tiles = {
		-- up, down, right, left, back, front
		"signs_bot_sensor2.png^signs_bot_delayer_on.png",
		"signs_bot_sensor2.png",
	},

	on_timer = node_timer,
	update_infotext = update_infotext,
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	use_texture_alpha = signs_bot.CLIP,
	is_ground_content = false,
	diggable = false,
	groups = {sign_bot_sensor = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_craft({
	output = "signs_bot:delayer",
	recipe = {
		{"group:wood", "dye:yellow", ""},
		{"default:mese_crystal_fragment", "", ""},
		{"default:steel_ingot", "", ""},
	}
})

minetest.register_lbm({
	label = "[signs_bot] Restart delayer",
	name = "signs_bot:delayer_restart",
	nodenames = {"signs_bot:delayer", "signs_bot:delayer_loaded", "signs_bot:delayer_on"},
	run_at_every_load = true,
	action = function(pos, node)
		turn_off(pos)
		local mem = tubelib2.get_mem(pos)
		if mem.time and mem.time > 0 then
			minetest.get_node_timer(pos):start(CYCLE_TIME)
		end
	end
})

if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "delayer", {
		name = S("Signal Delayer"),
		data = {
			item = "signs_bot:delayer",
			text = table.concat({
				S("Signals are forwarded delayed. Subsequent signals are queued."), 
				S("The delay time can be configured."),
			}, "\n")		
		},
	})
end

