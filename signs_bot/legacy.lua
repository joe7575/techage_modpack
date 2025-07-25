--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Registation of standard chests and furnace

]]--

-- for lazy programmers
local M = minetest.get_meta

signs_bot.register_inventory({"default:chest", "default:chest_open"}, {
	put = {
		listname = "main",
	},
	take = {
		listname = "main",
	},
})

signs_bot.register_inventory({"default:chest_locked", "default:chest_locked_open"}, {
	put = {
		allow_inventory_put = function(pos, stack, player_name)
			local owner = M(pos):get_string("owner")
			return owner == player_name
		end,
		listname = "main",
	},
	take = {
		allow_inventory_take = function(pos, stack, player_name)
			local owner = M(pos):get_string("owner")
			return owner == player_name
		end,
		listname = "main",
	},
})

signs_bot.register_inventory({"default:furnace", "default:furnace_active"}, {
	put = {
		allow_inventory_put = function(pos, stack, player_name)
			minetest.get_node_timer(pos):start(1.0)
			return true
		end,
		listname = "src",
	},
	take = {
		listname = "dst",
	},
	fuel = {
		allow_inventory_put = function(pos, stack, player_name)
			minetest.get_node_timer(pos):start(1.0)
			return true
		end,
		listname = "fuel",
	},
})

signs_bot.register_inventory({"mobs:beehive"}, {
	put = {
		listname = "beehive",
	},
	take = {
		listname = "beehive",
	},
})

signs_bot.register_inventory({"xdecor:hive"}, {
	put = {
		listname = "honey",
	},
	take = {
		listname = "honey",
	},
})

signs_bot.register_inventory({"shop:shop"}, {
	put = {
		allow_inventory_put = function(pos, stack, player_name)
			local owner = M(pos):get_string("owner")
			return owner == player_name
		end,
		listname = "stock",
	},
	take = {
		allow_inventory_take = function(pos, stack, player_name)
			local owner = M(pos):get_string("owner")
			return owner == player_name
		end,
		listname = "register",
	},
})

