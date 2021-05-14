--[[

	Minecart
	========

	Copyright (C) 2019-2021 Joachim Stolberg

	MIT
	See license.txt for more information
	
	Wrapper functions to get hopper support for other mods
	
]]--

-- for lazy programmers
local M = minetest.get_meta

local CacheForFuelNodeNames = {}

local function is_fuel(stack)
	local name = stack:get_name()
	if CacheForFuelNodeNames[name] then 
		return true
	end
	if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time ~= 0 then
		CacheForFuelNodeNames[name] = true
	end
	return CacheForFuelNodeNames[name]
end

------------------------------------------------------------------------------
-- default
------------------------------------------------------------------------------

minecart.register_inventory({"default:chest", "default:chest_open"}, {
	put = {
		listname = "main",
	},
	take = {
		listname = "main",
	},
})

minecart.register_inventory({"default:chest_locked", "default:chest_locked_open"}, {
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

minecart.register_inventory({"default:furnace", "default:furnace_active"}, {
	put = {
		-- distinguish between fuel and other items
		put_item = function(pos, stack, player_name)
			local inv = minetest.get_inventory({type="node", pos=pos})
			local listname = is_fuel(stack) and "fuel" or "src"
			local leftover = inv:add_item(listname, stack)
			minetest.get_node_timer(pos):start(1.0)
			if leftover:get_count() > 0 then
				return leftover
			end			
		end, 
	},
	take = {
		-- fuel can't be taken
		listname = "dst",
	},
})

------------------------------------------------------------------------------
-- digtron
------------------------------------------------------------------------------

minecart.register_inventory({"digtron:inventory"}, {
	put = {
		listname = "main",
	},
	take = {
		listname = "main",
	},
})

minecart.register_inventory({"digtron:fuelstore"}, {
	put = {
		listname = "fuel",
	},
	take = {
		listname = "fuel",
	},
})

minecart.register_inventory({"digtron:combined_storage"}, {
	put = {
		-- distinguish between fuel and other items
		put_item = function(pos, stack, player_name)
			local inv = minetest.get_inventory({type="node", pos=pos})
			local listname = is_fuel(stack) and "fuel" or "main"
			local leftover = inv:add_item(listname, stack)
			if leftover:get_count() > 0 then
				return leftover
			end			
		end, 
	},
	take = {
		-- fuel can't be taken
		listname = "main",
	},
})

------------------------------------------------------------------------------
-- protector
------------------------------------------------------------------------------

minecart.register_inventory({"protector:chest"}, {
	put = {
		listname = "main",
	},
	take = {
		listname = "main",
	},
})
