--[[

	Networks
	========

	Copyright (C) 2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local M = minetest.get_meta

local CYCLE_TIME = 2
local STORAGE_CAPA = 500
local GEN_MAX = 20
local CON_MAX = 5
local HIDDEN = true   -- enable/disable hidden nodes

local function round(val)
	if val > 100 then
		return math.floor(val + 0.5)
	elseif val > 10 then
		return math.floor((val * 10) + 0.5) / 10
	else
		return math.floor((val * 100) + 0.5) / 100
	end
end

local power = networks.power

-------------------------------------------------------------------------------
-- Cable
-------------------------------------------------------------------------------
local Cable = tubelib2.Tube:new({
	dirs_to_check = {1,2,3,4,5,6},
	max_tube_length = 100,
	tube_type = "pwr",
	primary_node_names = {"networks:cableS", "networks:cableA", "networks:switch_on"},
	secondary_node_names = {},  -- Names will be added via 'power.register_nodes'
	after_place_tube = function(pos, param2, tube_type, num_tubes, tbl)
		local name = minetest.get_node(pos).name
		if name == "networks:switch_on" or name == "networks:switch_off" then
			minetest.swap_node(pos, {name = name, param2 = param2 % 32})
		elseif not networks.hidden_name(pos) then
			minetest.swap_node(pos, {name = "networks:cable"..tube_type, param2 = param2 % 32})
		end
		M(pos):set_int("netw_param2", param2)
	end,
})

if HIDDEN then
	-- Enable hidden cables
	networks.use_metadata(Cable)
	networks.register_hidden_message("Use the tool to remove the node.")
	networks.register_filling_items({
		"default:stone",
		"default:stonebrick",
		"default:stone_block",
		"default:clay",
		"default:snowblock",
		"default:ice",
		"default:glass",
		"default:obsidian_glass",
		"default:brick",
		"default:tree",
		"default:wood",
		"default:jungletree",
		"default:junglewood",
		"default:pine_tree",
		"default:pine_wood",
		"default:acacia_tree",
		"default:acacia_wood",
		"default:aspen_tree",
		"default:aspen_wood",
		"default:steelblock",
		"default:copperblock",
		"default:tinblock",
		"default:bronzeblock",
		"default:goldblock",
		"default:mese",
		"default:diamondblock",
	})
end

-- Use global callback instead of node related functions
Cable:register_on_tube_update2(function(pos, outdir, tlib2, node)
	power.update_network(pos, outdir, tlib2, node)
end)

minetest.register_node("networks:cableS", {
	description = "Cable",
	tiles = { -- Top, base, right, left, front, back
		"networks_cable.png",
		"networks_cable.png",
		"networks_cable.png",
		"networks_cable.png",
		"networks_hole.png",
		"networks_hole.png",
	},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Cable:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Cable:after_dig_tube(pos, oldnode, oldmetadata)
	end,
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-3/16, -3/16, -4/8,  3/16, 3/16, 4/8},
		},
	},
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2, test_trowel = 1},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("networks:cableA", {
	description = "Cable",
	tiles = { -- Top, base, right, left, front, back
		"networks_cable.png",
		"networks_hole.png",
		"networks_cable.png",
		"networks_cable.png",
		"networks_cable.png",
		"networks_hole.png",
	},
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Cable:after_dig_tube(pos, oldnode, oldmetadata)
	end,
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-3/16, -4/8, -3/16,  3/16, 3/16,  3/16},
			{-3/16, -3/16, -4/8,  3/16, 3/16, -3/16},
		},
	},
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2, test_trowel = 1, not_in_creative_inventory=1},
	sounds = default.node_sound_defaults(),
	drop = "networks:cableS",
})

local size = 3/16
local Boxes = {
	{{-size, -size,  size, size,  size, 0.5 }}, -- z+
	{{-size, -size, -size, 0.5,   size, size}}, -- x+
	{{-size, -size, -0.5,  size,  size, size}}, -- z-
	{{-0.5,  -size, -size, size,  size, size}}, -- x-
	{{-size, -0.5,  -size, size,  size, size}}, -- y-
	{{-size, -size, -size, size,  0.5,  size}}, -- y+
}

local names = networks.register_junction("networks:junction", size, Boxes, Cable, {
	description = "Junction",
	tiles = {"networks_junction.png"},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local name = "networks:junction"..networks.junction_type(pos, Cable)
		minetest.swap_node(pos, {name = name, param2 = 0})
		Cable:after_place_node(pos)
	end,
	-- junction needs own 'tubelib2_on_update2' to be able to call networks.junction_type
	tubelib2_on_update2 = function(pos, outdir, tlib2, node)
		if not networks.hidden_name(pos) then
			local name = "networks:junction" .. networks.junction_type(pos, Cable)
			minetest.swap_node(pos, {name = name, param2 = 0})
		end
		power.update_network(pos, 0, tlib2, node)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Cable:after_dig_node(pos)
	end,
	use_texture_alpha = "clip",
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2, test_trowel = 1},
	sounds = default.node_sound_defaults(),
}, 63)

power.register_nodes(names, Cable, "junc")

-------------------------------------------------------------------------------
-- Generator
-------------------------------------------------------------------------------
minetest.register_node("networks:generator", {
	description = "Generator",
	tiles = {
		-- up, down, right, left, back, front
		'networks_gen.png',
		'networks_gen.png',
		'networks_gen.png',
		'networks_gen.png',
		'networks_gen.png',
		'networks_conn.png',
	},
	after_place_node = function(pos)
		local outdir = networks.side_to_outdir(pos, "F")
		M(pos):set_int("outdir", outdir)
		Cable:after_place_node(pos, {outdir})
		M(pos):set_string("infotext", "off")
		tubelib2.init_mem(pos)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata)
		local outdir = tonumber(oldmetadata.fields.outdir or 0)
		Cable:after_dig_node(pos, {outdir})
		tubelib2.del_mem(pos)
	end,
	on_timer = function(pos, elapsed)
		local outdir = M(pos):get_int("outdir")
		local mem = tubelib2.get_mem(pos)
		mem.provided = power.provide_power(pos, Cable, outdir, GEN_MAX)
		mem.load = power.get_storage_load(pos, Cable, outdir, GEN_MAX)
		M(pos):set_string("infotext", "providing "..round(mem.provided))
		return true
	end,
	on_rightclick = function(pos, node, clicker)
		local mem = tubelib2.get_mem(pos)
		if mem.running then
			mem.running = false
			M(pos):set_string("infotext", "off")
			minetest.get_node_timer(pos):stop()
		else
			mem.provided = mem.provided or 0
			mem.running = true
			M(pos):set_string("infotext", "providing "..round(mem.provided))
			minetest.get_node_timer(pos):start(CYCLE_TIME)
		end
		local outdir = M(pos):get_int("outdir")
		power.start_storage_calc(pos, Cable, outdir)
	end,
	get_generator_data = function(pos, outdir, tlib2)
		local mem = tubelib2.get_mem(pos)
		if mem.running then
			-- generator storage capa = 2 * performance
			return {level = (mem.load or 0) / GEN_MAX, perf = GEN_MAX, capa = GEN_MAX * 2}
		end
	end,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	sounds = default.node_sound_defaults(),
})

-- Generators have to provide one output side
power.register_nodes({"networks:generator"}, Cable, "gen", {"F"})

-------------------------------------------------------------------------------
-- Storage
-------------------------------------------------------------------------------
minetest.register_node("networks:storage", {
	description = "Storage",
	tiles = {
		-- up, down, right, left, back, front
		"networks_sto.png",
		"networks_sto.png",
		"networks_sto.png",
		"networks_sto.png",
		"networks_sto.png",
		'networks_conn.png',
	},
	after_place_node = function(pos)
		local outdir = networks.side_to_outdir(pos, "F")
		M(pos):set_int("outdir", outdir)
		Cable:after_place_node(pos, {outdir})
		tubelib2.init_mem(pos)
		M(pos):set_string("infotext", "off")
	end,
	after_dig_node = function(pos, oldnode, oldmetadata)
		local outdir = tonumber(oldmetadata.fields.outdir or 0)
		Cable:after_dig_node(pos, {outdir})
		tubelib2.del_mem(pos)
	end,
	on_timer = function(pos, elapsed)
		local mem = tubelib2.get_mem(pos)
		local outdir = M(pos):get_int("outdir")
		local data = power.get_storage_data(pos, Cable, outdir)
		if data then
			mem.load = data.level * STORAGE_CAPA
			local percent = data.level * 100
			M(pos):set_string("infotext", "level = "..round(percent)..", charging = "..data.charging)
		end
		return true
	end,
	on_rightclick = function(pos, node, clicker)
		local mem = tubelib2.get_mem(pos)
		if mem.running then
			mem.running = false
			M(pos):set_string("infotext", "off")
			minetest.get_node_timer(pos):stop()
		else
			mem.provided = mem.provided or 0
			mem.running = true
			local percent = (mem.load or 0) / STORAGE_CAPA * 100
			M(pos):set_string("infotext", "level = "..round(percent))
			minetest.get_node_timer(pos):start(CYCLE_TIME)
		end
		local outdir = M(pos):get_int("outdir")
		power.start_storage_calc(pos, Cable, outdir)
	end,
	get_storage_data = function(pos, outdir, tlib2)
		local mem = tubelib2.get_mem(pos)
		if mem.running then
			return {level = (mem.load or 0) / STORAGE_CAPA, capa = STORAGE_CAPA}
		end
	end,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	sounds = default.node_sound_defaults(),
})

-- Storage nodes have to provide one input/output side
power.register_nodes({"networks:storage"}, Cable, "sto", {"F"})

-------------------------------------------------------------------------------
-- Consumer
-------------------------------------------------------------------------------
local function swap_node(pos, name)
	local node = tubelib2.get_node_lvm(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function turn_on(pos)
	swap_node(pos, "networks:consumer_on")
	M(pos):set_string("infotext", "on")
	local mem = tubelib2.get_mem(pos)
	mem.running = true
	minetest.get_node_timer(pos):start(CYCLE_TIME)
end

local function turn_off(pos)
	swap_node(pos, "networks:consumer")
	M(pos):set_string("infotext", "off")
	local mem = tubelib2.get_mem(pos)
	mem.running = false
	minetest.get_node_timer(pos):stop()
end

local function on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	if not mem.running and power.power_available(pos, Cable) then
		turn_on(pos)
	else
		turn_off(pos)
	end
end

local function after_place_node(pos)
	M(pos):set_string("infotext", "off")
	Cable:after_place_node(pos)
	tubelib2.init_mem(pos)
end

local function after_dig_node(pos, oldnode)
	Cable:after_dig_node(pos)
	tubelib2.del_mem(pos)
end

minetest.register_node("networks:consumer", {
	description = "Consumer",
	tiles = {'networks_con.png^[colorize:#000000:50'},

	on_timer = function(pos, elapsed)
		local consumed = power.consume_power(pos, Cable, nil, CON_MAX)
		if consumed == CON_MAX then
			swap_node(pos, "networks:consumer_on")
			M(pos):set_string("infotext", "on")
		end
		return true
	end,
	on_rightclick = on_rightclick,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	paramtype2 = "facedir",
	groups = {choppy = 2, cracky = 2, crumbly = 2},
	is_ground_content = false,
	sounds = default.node_sound_defaults(),
})

minetest.register_node("networks:consumer_on", {
	description = "Consumer",
	tiles = {'networks_con.png'},

	on_timer = function(pos, elapsed)
		local consumed = power.consume_power(pos, Cable, nil, CON_MAX)
		if consumed < CON_MAX then
			swap_node(pos, "networks:consumer")
			M(pos):set_string("infotext", "no power")
		end
		return true
	end,
	on_rightclick = on_rightclick,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	paramtype2 = "facedir",
	diggable = false,
	drop = "",
	groups = {not_in_creative_inventory = 1},
	is_ground_content = false,
	sounds = default.node_sound_defaults(),
})

-- Consumer can provide dedicated input sides, otherwise all sides are used
power.register_nodes({"networks:consumer", "networks:consumer_on"}, Cable, "con")

-------------------------------------------------------------------------------
-- Switch/valve
-------------------------------------------------------------------------------
local node_box = {
	type = "fixed",
	fixed = {
		{-5/16, -5/16, -4/8,  5/16, 5/16, 4/8},
	},
}

-- The on-switch is a "primary node" like cables
minetest.register_node("networks:switch_on", {
	description = "Switch",
	paramtype = "light",
	drawtype = "nodebox",
	node_box = node_box,
	tiles = {
		"networks_switch_on.png^[transformR90",
		"networks_switch_on.png^[transformR90",
		"networks_switch_on.png",
		"networks_switch_on.png",
		"networks_switch_hole.png",
		"networks_switch_hole.png",
	},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Cable:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,
	on_rightclick = function(pos, node, clicker)
		if power.turn_switch_off(pos, Cable, "networks:switch_off", "networks:switch_on") then
			minetest.sound_play("doors_glass_door_open", {
				pos = pos,
				gain = 1,
				max_hear_distance = 5})
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Cable:after_dig_tube(pos, oldnode, oldmetadata)
	end,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2, test_trowel = 1},
	sounds = default.node_sound_defaults(),
})

-- The off-switch is a "secondary node" without connection sides
minetest.register_node("networks:switch_off", {
	description = "Switch",
	paramtype = "light",
	drawtype = "nodebox",
	node_box = node_box,
	tiles = {
		"networks_switch_off.png^[transformR90",
		"networks_switch_off.png^[transformR90",
		"networks_switch_off.png",
		"networks_switch_off.png",
		"networks_switch_hole.png",
		"networks_switch_hole.png",
	},
	on_rightclick = function(pos, node, clicker)
		if power.turn_switch_on(pos, Cable, "networks:switch_off", "networks:switch_on") then
			minetest.sound_play("doors_glass_door_open", {
				pos = pos,
				gain = 1,
				max_hear_distance = 5})
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Cable:after_dig_node(pos)
	end,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	is_ground_content = false,
	drop = "networks:switch_on",
	groups = {crumbly = 2, cracky = 2, snappy = 2, test_trowel = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_defaults(),
})

power.register_nodes({"networks:switch_off"}, Cable, "con", {})

-------------------------------------------------------------------------------
-- Hide/open tool
-------------------------------------------------------------------------------
-- Hide or open a node
local function replace_node(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local pos = pointed_thing.under
		local name = placer:get_player_name()
		if minetest.is_protected(pos, name) then
			return
		end
		local node = minetest.get_node(pos)
		local res = false
		if minetest.get_item_group(node.name, "test_trowel") == 1 then
			res = networks.hide_node(pos, node, placer)
		elseif networks.hidden_name(pos) then
			res = networks.open_node(pos, node, placer)
		end
		if res then
			minetest.sound_play("default_dig_snappy", {
				pos = pos,
				gain = 1,
				max_hear_distance = 5})
		elseif placer and placer.get_player_name then
			minetest.chat_send_player(placer:get_player_name(), "Invalid fill material in inventory slot 1!")
		end
	end
end

minetest.register_tool("networks:tool", {
	description = "Hide Tool\n(Fill material to the right of the tool)",
	inventory_image = "networks_tool.png",
	wield_image = "networks_tool.png",
	use_texture_alpha = "clip",
	groups = {cracky=1},
	on_use = replace_node,
	on_place = replace_node,
	node_placement_prediction = "",
	stack_max = 1,
})

-------------------------------------------------------------------------------
-- Test Commands
-------------------------------------------------------------------------------
minetest.register_chatcommand("power_data", {
    func = function(name)
		local player = minetest.get_player_by_name(name)
		local pos = player:get_pos()
		pos.y = pos.y - 0.5
		pos = vector.round(pos)
		local data = power.get_network_data(pos, Cable)
		if data then
			local s = string.format("Netw %u: generated = %u/%u, consumed = %u, storage load = %u/%u",
				data.netw_num, round(data.provided),
				data.available, round(data.consumed),
				round(data.curr_load), round(data.max_capa))
			return true, s
		end
		return false, "No valid node position!"

    end
})

return Cable

