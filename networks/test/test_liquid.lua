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
local AMOUNT = 2

local liquid = networks.liquid

-------------------------------------------------------------------------------
-- Pipe
-------------------------------------------------------------------------------
local Pipe = tubelib2.Tube:new({
	dirs_to_check = {1,2,3,4,5,6},
	max_tube_length = 100,
	tube_type = "liq",
	primary_node_names = {"networks:pipeS", "networks:pipeA", "networks:valve_on"},
	secondary_node_names = {},  -- Names will be added via 'liquids.register_nodes'
	after_place_tube = function(pos, param2, tube_type, num_tubes, tbl)
		local name = minetest.get_node(pos).name
		if name == "networks:valve_on" then
			minetest.swap_node(pos, {name = "networks:valve_on", param2 = param2})
		elseif name == "networks:valve_off" then
			minetest.swap_node(pos, {name = "networks:valve_off", param2 = param2})
		else
			minetest.swap_node(pos, {name = "networks:pipe"..tube_type, param2 = param2})
		end
	end,
})

-- Use global callback instead of node related functions
Pipe:register_on_tube_update2(function(pos, outdir, tlib2, node)
	liquid.update_network(pos, outdir, tlib2, node)
end)

minetest.register_node("networks:pipeS", {
	description = "Pipe",
	tiles = { -- Top, base, right, left, front, back
		"networks_cable.png^[colorize:#007577:60",
		"networks_cable.png^[colorize:#007577:60",
		"networks_cable.png^[colorize:#007577:60",
		"networks_cable.png^[colorize:#007577:60",
		"networks_hole.png",
		"networks_hole.png",
	},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Pipe:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_tube(pos, oldnode, oldmetadata)
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
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("networks:pipeA", {
	description = "Pipe",
	tiles = { -- Top, base, right, left, front, back
		"networks_cable.png^[colorize:#007577:60",
		"networks_hole.png^[colorize:#007577:60",
		"networks_cable.png^[colorize:#007577:60",
		"networks_cable.png^[colorize:#007577:60",
		"networks_cable.png^[colorize:#007577:60",
		"networks_hole.png^[colorize:#007577:60",
	},
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_tube(pos, oldnode, oldmetadata)
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
	drop = "networks:pipeS",
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

local names = networks.register_junction("networks:junction", size, Boxes, Pipe, {
	description = "Junction",
	tiles = {"networks_junction.png^[colorize:#007577:60"},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local name = "networks:junction" .. networks.junction_type(pos, Pipe)
		minetest.swap_node(pos, {name = name, param2 = 0})
		Pipe:after_place_node(pos)
	end,
	-- junction needs own 'tubelib2_on_update2' to be able to call networks.junction_type
	tubelib2_on_update2 = function(pos, outdir, tlib2, node)
		local name = "networks:junction" .. networks.junction_type(pos, Pipe)
		minetest.swap_node(pos, {name = name, param2 = 0})
		liquid.update_network(pos, 0, tlib2, node)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
	end,
	use_texture_alpha = "clip",
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	sounds = default.node_sound_defaults(),
}, 63)

liquid.register_nodes(names, Pipe, "junc")

-------------------------------------------------------------------------------
-- Pump
-------------------------------------------------------------------------------
local function swap_node(pos, name)
	local node = tubelib2.get_node_lvm(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function turn_on(pos, mem)
	swap_node(pos, "networks:pump_on")
	M(pos):set_string("infotext", "pumping")
	mem.running = true
	-- enable marker cube
	mem.dbg_cycles = 5
	minetest.get_node_timer(pos):start(CYCLE_TIME)
end

local function turn_off(pos, mem)
	swap_node(pos, "networks:pump_off")
	M(pos):set_string("infotext", "off")
	mem.running = false
	minetest.get_node_timer(pos):stop()
end

local function on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	if not mem.running then
		turn_on(pos, mem)
	else
		turn_off(pos, mem)
	end
end

local function pumping(pos)
	local mem = tubelib2.get_mem(pos)
	local outdir = M(pos):get_int("outdir")
	local taken, name = liquid.take(pos, Pipe, networks.Flip[outdir], nil, AMOUNT, mem.dbg_cycles > 0)
	if taken > 0 then
		print("pumping " .. name .. " " .. taken)
		local leftover = liquid.put(pos, Pipe, outdir, name, taken, mem.dbg_cycles > 0)
		if leftover and leftover > 0 then
			liquid.untake(pos, Pipe, networks.Flip[outdir], name, leftover)
			if leftover == taken then
				turn_off(pos, mem)
				return false
			end
		end
	else
		print("pumping -")
	end
	mem.dbg_cycles = mem.dbg_cycles - 1
	return true
end

local function after_place_node(pos)
	local outdir = networks.side_to_outdir(pos, "B")
	M(pos):set_int("outdir", outdir)
	Pipe:after_place_node(pos, {outdir})
	M(pos):set_string("infotext", "off")
	tubelib2.init_mem(pos)
end

local function after_dig_node(pos, oldnode, oldmetadata)
	local outdir = tonumber(oldmetadata.fields.outdir or 0)
	Pipe:after_dig_node(pos, {outdir})
	tubelib2.del_mem(pos)
end

minetest.register_node("networks:pump_off", {
	description = "Pump",
	tiles = {
		-- up, down, right, left, back, front
		'networks_arrow.png^[colorize:#007577:60',
		'networks_pump.png^[colorize:#007577:60',
		'networks_pump.png^[colorize:#007577:60',
		'networks_pump.png^[colorize:#007577:60',
		'networks_conn.png^[colorize:#007577:60',
		'networks_conn.png^[colorize:#007577:60',
	},
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	on_timer = pumping,
	on_rightclick = on_rightclick,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("networks:pump_on", {
	description = "Pump",
	tiles = {
		-- up, down, right, left, back, front
		'networks_arrow.png^[colorize:#007577:60',
		'networks_pump.png^[colorize:#007577:60',
		'networks_pump.png^[colorize:#007577:60',
		'networks_pump.png^[colorize:#007577:60',
		'networks_conn.png^[colorize:#007577:60',
		'networks_conn.png^[colorize:#007577:60',
	},
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	on_timer = pumping,
	on_rightclick = on_rightclick,
	paramtype = "light",
	light_source = 8,
	paramtype2 = "facedir",
	diggable = false,
	drop = "",
	groups = {not_in_creative_inventory = 1},
	is_ground_content = false,
	sounds = default.node_sound_defaults(),
})

-- Pumps have to provide one output and one input side
liquid.register_nodes({"networks:pump_off", "networks:pump_on"}, Pipe, "pump", {"F", "B"}, {})

-------------------------------------------------------------------------------
-- Tank
-------------------------------------------------------------------------------
local function register_tank(name, description, liquid_name, liquid_amount)
	minetest.register_node(name, {
		description = description,
		tiles = {
			-- up, down, right, left, back, front
			"networks_tank.png^[colorize:#007577:60",
			"networks_tank.png^[colorize:#007577:60",
			"networks_tank.png^[colorize:#007577:60",
			"networks_tank.png^[colorize:#007577:60",
			"networks_tank.png^[colorize:#007577:60",
			'networks_tank.png^[colorize:#007577:60',
		},
		after_place_node = function(pos)
			Pipe:after_place_node(pos)
			local mem = tubelib2.init_mem(pos)
			mem.liquid = {}
			mem.liquid.name = liquid_name
			mem.liquid.amount = liquid_amount
			M(pos):set_string("infotext", networks.liquid.get_item(mem))
			minetest.get_node_timer(pos):start(CYCLE_TIME)
		end,
		after_dig_node = function(pos, oldnode, oldmetadata)
			Pipe:after_dig_node(pos)
			tubelib2.del_mem(pos)
		end,
		on_timer = function(pos, elapsed)
			local mem = tubelib2.get_mem(pos)
			M(pos):set_string("infotext", networks.liquid.get_item(mem))
			return true
		end,
		paramtype2 = "facedir",
		on_rotate = screwdriver.disallow,
		is_ground_content = false,
		groups = {crumbly = 2, cracky = 2, snappy = 2},
		sounds = default.node_sound_defaults(),
	})
end

-- 3 types of test tanks
register_tank("networks:tank1", "Water Tank", "water", STORAGE_CAPA)
register_tank("networks:tank2", "Milk Tank", "milk", STORAGE_CAPA)
register_tank("networks:tank3", "Empty Tank", nil, 0)

liquid.register_nodes({"networks:tank1", "networks:tank2", "networks:tank3"},
	Pipe, "tank", nil, {
		capa = STORAGE_CAPA,
		peek = function(pos, indir)
			local mem = tubelib2.get_mem(pos)
			return liquid.srv_peek(mem)
		end,
		put = function(pos, indir, name, amount)
			local mem = tubelib2.get_mem(pos)
			return liquid.srv_put(mem, name, amount, STORAGE_CAPA)
		end,
		take = function(pos, indir, name, amount)
			local mem = tubelib2.get_mem(pos)
			return liquid.srv_take(mem, name, amount)
		end,
		untake = function(pos, indir, name, amount)
			local mem = tubelib2.get_mem(pos)
			return liquid.srv_put(mem, name, amount, STORAGE_CAPA)
		end,
	}
)

-------------------------------------------------------------------------------
-- Valve
-------------------------------------------------------------------------------
local node_box = {
	type = "fixed",
	fixed = {
		{-5/16, -5/16, -4/8,  5/16, 5/16, 4/8},
	},
}

-- The on-valve is a "primary node" like pipes
minetest.register_node("networks:valve_on", {
	description = "Valve",
	paramtype = "light",
	drawtype = "nodebox",
	node_box = node_box,
	tiles = {
		"networks_switch_on.png^[transformR90^[colorize:#007577:60",
		"networks_switch_on.png^[transformR90^[colorize:#007577:60",
		"networks_switch_on.png^[colorize:#007577:60",
		"networks_switch_on.png^[colorize:#007577:60",
		"networks_switch_hole.png^[colorize:#007577:60",
		"networks_switch_hole.png^[colorize:#007577:60",
	},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Pipe:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,
	on_rightclick = function(pos, node, clicker)
		if liquid.turn_valve_off(pos, Pipe, "networks:valve_off", "networks:valve_on") then
			minetest.sound_play("doors_glass_door_open", {
				pos = pos,
				gain = 1,
				max_hear_distance = 5})
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_tube(pos, oldnode, oldmetadata)
	end,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	sounds = default.node_sound_defaults(),
})

-- The off-valve is a "secondary node" without connection sides
minetest.register_node("networks:valve_off", {
	description = "Valve",
	paramtype = "light",
	drawtype = "nodebox",
	node_box = node_box,
	tiles = {
		"networks_switch_off.png^[transformR90^[colorize:#007577:60",
		"networks_switch_off.png^[transformR90^[colorize:#007577:60",
		"networks_switch_off.png^[colorize:#007577:60",
		"networks_switch_off.png^[colorize:#007577:60",
		"networks_switch_hole.png^[colorize:#007577:60",
		"networks_switch_hole.png^[colorize:#007577:60",
	},
	on_rightclick = function(pos, node, clicker)
		if liquid.turn_valve_on(pos, Pipe, "networks:valve_off", "networks:valve_on") then
			minetest.sound_play("doors_glass_door_open", {
				pos = pos,
				gain = 1,
				max_hear_distance = 5})
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
	end,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	is_ground_content = false,
	drop = "networks:valve_on",
	groups = {crumbly = 2, cracky = 2, snappy = 2, test_trowel = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_defaults(),
})

liquid.register_nodes({"networks:valve_off"}, Pipe, "tank", {}, {})
