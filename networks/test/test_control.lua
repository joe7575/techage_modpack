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

local Cable = ...
local power = networks.power
local control = networks.control

-------------------------------------------------------------------------------
-- Client (sender)
-------------------------------------------------------------------------------
minetest.register_node("networks:client", {
	description = "Client",
	tiles = {
		-- up, down, right, left, back, front
		'networks_con.png^[colorize:#F05100:60',
		'networks_con.png^[colorize:#F05100:60',
		'networks_con.png^[colorize:#F05100:60',
		'networks_con.png^[colorize:#F05100:60',
		'networks_con.png^[colorize:#F05100:60',
		'networks_conn.png^[colorize:#F05100:60',
	},
	after_place_node = function(pos)
		local outdir = networks.side_to_outdir(pos, "F")
		M(pos):set_int("outdir", outdir)
		M(pos):set_string("infotext", "off")
		Cable:after_place_node(pos, {outdir})
		tubelib2.init_mem(pos)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata)
		local outdir = tonumber(oldmetadata.fields.outdir or 0)
		Cable:after_dig_node(pos, {outdir})
		tubelib2.del_mem(pos)
	end,
	on_rightclick = function(pos, node, clicker)
		local mem = tubelib2.get_mem(pos)
		local outdir = M(pos):get_int("outdir")
		local cnt
		if mem.on then
			cnt = control.send(pos, Cable, outdir, "server", "off")
			M(pos):set_string("infotext", "off")
			mem.on = false
		else
			cnt = control.send(pos, Cable, outdir, "server", "on")
			M(pos):set_string("infotext", "on")
			mem.on = true
		end
		print("Command sent to " .. cnt .. " nodes.")
	end,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	sounds = default.node_sound_defaults(),
})

power.register_nodes({"networks:client"}, Cable, "client")
control.register_nodes({"networks:client"}, {}) -- no callbacks

-------------------------------------------------------------------------------
-- Server (receiver)
-------------------------------------------------------------------------------
local function swap_node(pos, name)
	local node = tubelib2.get_node_lvm(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

minetest.register_node("networks:server_off", {
	description = "Server",
	tiles = {
		-- up, down, right, left, back, front
		"networks_sto.png^[colorize:#F05100:60",
	},
	after_place_node = function(pos)
		Cable:after_place_node(pos)
	end,
	after_dig_node = function(pos)
		Cable:after_dig_node(pos)
	end,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("networks:server_on", {
	description = "Server",
	tiles = {
		-- up, down, right, left, back, front
		"networks_sto.png^[colorize:#F05100:60",
	},
	after_place_node = function(pos)
		Cable:after_place_node(pos)
	end,
	after_dig_node = function(pos)
		Cable:after_dig_node(pos)
	end,
	paramtype = "light",
	light_source = 8,
	paramtype2 = "facedir",
	drop = "networks:server_off",
	groups = {crumbly = 2, cracky = 2, snappy = 2, not_in_creative_inventory = 1},
	is_ground_content = false,
	sounds = default.node_sound_defaults(),
})

power.register_nodes({"networks:server_off", "networks:server_on"}, Cable, "server")
control.register_nodes({"networks:server_off", "networks:server_on"}, {
		on_receive = function(pos, tlib2, topic, payload)
			if topic == "on" then
				swap_node(pos, "networks:server_on")
			elseif topic == "off" then
				swap_node(pos, "networks:server_off")
			end
		end,
		on_request = function(pos, tlib2, topic)
			return false
		end,
	}
)

