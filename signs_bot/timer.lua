--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Bot Timer

]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for I18n.
local S = signs_bot.S

local CYCLE_TIME = 4

local function update_infotext(pos, dest_pos, cmnd)
	local meta = M(pos)
	local mem = tubelib2.get_mem(pos)
	local rest = math.floor((mem.time or 0) / 60)
	local cycle_time = meta:get_int("cycle_time")
	local text
	if cycle_time > 0 then
		text = S("Bot Timer").." ("..rest.."/"..cycle_time.." min): "..S("Connected with")
	else
		text = S("Bot Timer").." (-- min): "..S("Connected with")
	end
	meta:set_string("infotext", text.." "..P2S(dest_pos).." / "..(cmnd or "none").."    ")
end

local function update_infotext_local(pos)
	local meta = M(pos)
	local mem = tubelib2.get_mem(pos)
	local rest = math.floor((mem.time or 0) / 60)
	local cycle_time = meta:get_int("cycle_time")
	local dest_pos = meta:get_string("signal_pos")
	local signal = meta:get_string("signal_data")
	local text1 = " (-- min): "
	local text2 = "Not connected"

	if dest_pos ~= "" and signal ~= "" then
		text2 = S("Connected with").." "..dest_pos.." / "..signal
	end
	if cycle_time > 0 then
		text1 = " ("..rest.."/"..cycle_time.." min): "
	end
	if dest_pos ~= "" and signal ~= "" and cycle_time > 0 then
		mem.running = true
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end
	meta:set_string("infotext", S("Bot Timer")..text1..text2.."    ")
end


local function formspec(meta)
	local label = minetest.formspec_escape(S("Cycle time [min]:"))
	local value = minetest.formspec_escape(meta:get_int("cycle_time"))
	return "size[4,3]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"field[0.3,1;4,1;time;"..label..";"..value.."]"..
	"button_exit[1,2.2;2,1;start;"..S("Start").."]"
end

-- switch to normal texture
local function turn_off(pos)
	local node = minetest.get_node(pos)
	node.name = "signs_bot:timer"
	minetest.swap_node(pos, node)
end

local function node_timer(pos)
	local mem = tubelib2.get_mem(pos)
	mem.time = mem.time or 0
	if mem.time > CYCLE_TIME then
		mem.time = mem.time - CYCLE_TIME
		if ((mem.time or 0) % 60) == 0 then
			local meta = M(pos)
			local dest_pos = meta:get_string("signal_pos")
			local signal = meta:get_string("signal_data")
			if dest_pos ~= "" and signal ~= "" then
				update_infotext(pos, S2P(dest_pos), signal)
			end
		end
	else
		local node = minetest.get_node(pos)
		node.name = "signs_bot:timer_on"
		minetest.swap_node(pos, node)
		signs_bot.send_signal(pos)
		signs_bot.lib.activate_extender_nodes(pos, true)
		minetest.after(2, turn_off, pos)
		local meta = M(pos)
		mem.time = meta:get_int("cycle_time") * 60
		local dest_pos = meta:get_string("signal_pos")
		local signal = meta:get_string("signal_data")
		if dest_pos ~= "" and signal ~= "" then
			update_infotext(pos, S2P(dest_pos), signal)
		end
	end
	return mem.time > 0
end

local function on_receive_fields(pos, formname, fields, player)
	local mem = tubelib2.get_mem(pos)
	local meta = M(pos)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	if fields.key_enter_field == "time" or fields.start then
		local cycle_time = tonumber(fields.time)
		if cycle_time and cycle_time > 0 and cycle_time < 9999 then
			meta:set_int("cycle_time", cycle_time)
			mem.time = cycle_time * 60
		elseif cycle_time == 0 then
			minetest.get_node_timer(pos):stop()
			mem.time = 0
			meta:set_int("cycle_time", 0)
		end
	end
	meta:set_string("formspec", formspec(meta))
	update_infotext_local(pos)
end

minetest.register_node("signs_bot:timer", {
	description = S("Bot Timer"),
	inventory_image = "signs_bot_timer_inv.png",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -11/32, -1/2, -11/32, 11/32, -5/16, 11/32},
		},
	},
	tiles = {
		-- up, down, right, left, back, front
		"signs_bot_sensor2.png^signs_bot_timer.png",
		"signs_bot_sensor2.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		meta:set_string("infotext", S("Bot Timer: Not connected"))
		meta:set_string("formspec", formspec(meta))
	end,

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

minetest.register_node("signs_bot:timer_on", {
	description = S("Bot Timer"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -11/32, -1/2, -11/32, 11/32, -5/16, 11/32},
		},
	},
	tiles = {
		-- up, down, right, left, back, front
		"signs_bot_sensor2.png^signs_bot_timer_on.png",
		"signs_bot_sensor2.png",
	},

	on_timer = node_timer,
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
	output = "signs_bot:timer",
	recipe = {
		{"", "", ""},
		{"dye:yellow", "group:stone", "dye:black"},
		{"default:steel_ingot", "default:mese_crystal_fragment", "default:steel_ingot"}
	}
})

minetest.register_lbm({
	label = "[signs_bot] Restart timer",
	name = "signs_bot:timer_restart",
	nodenames = {"signs_bot:timer", "signs_bot:timer_on"},
	run_at_every_load = true,
	action = function(pos, node)
		local mem = tubelib2.get_mem(pos)
		if mem.running then
			minetest.get_node_timer(pos):start(CYCLE_TIME)
		end
	end
})

if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "timer", {
		name = S("Bot Timer"),
		data = {
			item = "signs_bot:timer",
			text = table.concat({
				S("Special kind of sensor."),
				S("Can be programmed with a time in seconds, e.g. to start the bot cyclically."),
			}, "\n")
		},
	})
end
