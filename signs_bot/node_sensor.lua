--[[

	Signs Bot
	=========

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Node Sensor

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("signs_bot")
local I,_ = dofile(MP.."/intllib.lua")

local lib = signs_bot.lib

local CYCLE_TIME = 2

local function update_infotext(pos, dest_pos, cmnd)
	M(pos):set_string("infotext", I("Node Sensor: Connected with ")..S(dest_pos).." / "..cmnd)
end	

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return false
	end
	if string.sub(node.name, 1,21) == "signs_bot:node_sensor" then
		node.name = name
		minetest.swap_node(pos, node)
		return true
	end
	return false
end
	
	
local DropdownValues = {
	[I("added")] = 1,
	[I("removed")] = 2,
	[I("added or removed")] = 3,
}

local function formspec(mem)
	local label = I("added")..","..I("removed")..","..I("added or removed")
	return "size[6,3]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"label[0.2,0.4;"..I("Send signal if nodes have been:").."]"..
	"dropdown[0.2,1;6,1;mode;"..label..";"..(mem.mode or 3).."]"..
	"button_exit[1.5,2.2;3,1;accept;"..I("accept").."]"
end

local function any_node_changed(pos)
	local mem = tubelib2.get_mem(pos)
	if not mem.pos1 or not mem.pos2 or not mem.num then
		local node = minetest.get_node(pos)
		local param2 = (node.param2 + 2) % 4
		mem.pos1 = lib.dest_pos(pos, param2, {0})
		mem.pos2 = lib.dest_pos(pos, param2, {0,0,0})
		mem.num = #minetest.find_nodes_in_area(mem.pos1, mem.pos2, {"air"})
		return false
	end
	local num = #minetest.find_nodes_in_area(mem.pos1, mem.pos2, {"air"})
	
	if mem.num ~= num then
		if mem.mode == 1 and num < mem.num then 
			mem.num = num
			return true
		elseif mem.mode == 2 and num > mem.num then 
			mem.num = num
			return true
		elseif mem.mode == 3 then
			mem.num = num
			return true
		end
		mem.num = num
	end
	return false
end

local function on_receive_fields(pos, formname, fields, player)
	local mem = tubelib2.get_mem(pos)
	local meta = M(pos)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	if fields.accept then
		mem.mode = DropdownValues[fields.mode] or 3
		mem.num = nil
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		swap_node(pos, "signs_bot:node_sensor")
	end
	meta:set_string("formspec", formspec(mem))
end

local function node_timer(pos)
	if any_node_changed(pos)then
		if swap_node(pos, "signs_bot:node_sensor_on") then
			signs_bot.send_signal(pos)
			signs_bot.lib.activate_extender_nodes(pos, true)
			minetest.after(1, swap_node, pos, "signs_bot:node_sensor")
		end
	end
	return true
end

minetest.register_node("signs_bot:node_sensor", {
	description = I("Node Sensor"),
	inventory_image = "signs_bot_sensor_node_inv.png",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -11/32, -1/2, -11/32, 11/32, -5/16, 11/32},
		},
	},
	tiles = {
		-- up, down, right, left, back, front
		"signs_bot_sensor1.png^signs_bot_sensor_node.png",
		"signs_bot_sensor1.png",
		"signs_bot_sensor1.png^[transformFXR90",
		"signs_bot_sensor1.png^[transformFXR90",
		"signs_bot_sensor1.png^[transformFXR90",
		"signs_bot_sensor1.png^[transformFXR180",
	},
	
	after_place_node = function(pos, placer)
		local meta = M(pos)
		local mem = tubelib2.init_mem(pos)
		meta:set_string("infotext", "Node Sensor: Not connected")
		mem.mode = 3 -- default legacy mode
		meta:set_string("formspec", formspec(mem))
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		any_node_changed(pos)
	end,
	
	on_timer = node_timer,
	update_infotext = update_infotext,
	on_receive_fields = on_receive_fields,
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {sign_bot_sensor = 1, cracky = 1},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("signs_bot:node_sensor_on", {
	description = I("Node Sensor"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -11/32, -1/2, -11/32, 11/32, -5/16, 11/32},
		},
	},
	tiles = {
		-- up, down, right, left, back, front
		"signs_bot_sensor1.png^signs_bot_sensor_node_on.png",
		"signs_bot_sensor1.png",
		"signs_bot_sensor1.png^[transformFXR90",
		"signs_bot_sensor1.png^[transformFXR90",
		"signs_bot_sensor1.png^[transformFXR90",
		"signs_bot_sensor1.png^[transformFXR180",
	},
			
	on_timer = node_timer,
	update_infotext = update_infotext,
	on_receive_fields = on_receive_fields,
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	is_ground_content = false,
	drop = "signs_bot:node_sensor",
	groups = {sign_bot_sensor = 1, cracky = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_craft({
	output = "signs_bot:node_sensor",
	recipe = {
		{"", "", ""},
		{"dye:black", "group:stone", "dye:grey"},
		{"default:steel_ingot", "default:mese_crystal_fragment", "default:steel_ingot"}
	}
})

minetest.register_lbm({
	label = "[signs_bot] Restart timer",
	name = "signs_bot:node_sensor_restart",
	nodenames = {"signs_bot:node_sensor", "signs_bot:node_sensor_on"},
	run_at_every_load = true,
	action = function(pos, node)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		if node.name == "signs_bot:node_sensor_on" then
			signs_bot.send_signal(pos)
			signs_bot.lib.activate_extender_nodes(pos, true)
		end
	end
})

if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "node_sensor", {
		name = I("Node Sensor"),
		data = {
			item = "signs_bot:node_sensor",
			text = table.concat({
				I("The node sensor sends cyclical signals when it detects that nodes have appeared or disappeared,"),
				I("but has to be configured accordingly."),
				I("Valid nodes are all kind of blocks and plants."),
				I("The sensor range is 3 nodes/meters in one direction."), 
				I("The sensor has an active side (red) that must point to the observed area."),
			}, "\n")		
		},
	})
end
