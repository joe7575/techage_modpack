--[[

	Minecart
	========

	Copyright (C) 2019-2021 Joachim Stolberg

	MIT
	See license.txt for more information
	
]]--

local NUM_ITEMS = 4

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local S = minecart.S

local function scan_for_objects(pos, inv)
	for _, object in pairs(minetest.get_objects_inside_radius(pos, 1)) do
		local lua_entity = object:get_luaentity()
		if not object:is_player() and lua_entity and lua_entity.name == "__builtin:item" then
			if lua_entity.itemstring ~= "" then
				local stack = ItemStack(lua_entity.itemstring)
				if inv:room_for_item("main", stack) then
					inv:add_item("main", stack)
					object:remove()
				end
			end
		end
	end
end

local function pull_push_item(pos, param2)
	local items = minecart.take_items(pos, param2, NUM_ITEMS)
	if items then
		local leftover = minecart.put_items(pos, param2, items)
		if leftover then
			-- place item back
			minecart.untake_items(pos, param2, leftover)
			return false
		end
		return true
	else
		items = minecart.take_items({x=pos.x, y=pos.y+1, z=pos.z}, nil, NUM_ITEMS)
		if items then
			local leftover = minecart.put_items(pos, param2, items)
			if leftover then
				-- place item back
				minecart.untake_items({x=pos.x, y=pos.y+1, z=pos.z}, nil, leftover)
				return false
			end
			return true
		end
	end
	return false
end

local function push_item(pos, inv, param2)
	local taken = minecart.inv_take_items(inv, "main", NUM_ITEMS)
	if taken then
		local leftover = minecart.put_items(pos, param2, taken)
		if leftover then
			inv:add_item("main", leftover)
		end
	end
end

local formspec = "size[8,6.5]"..
	"list[context;main;3,0;2,2;]"..
	"list[current_player;main;0,2.7;8,4;]"..
	"listring[context;main]"..
	"listring[current_player;main]"

minetest.register_node("minecart:hopper", {
	description = S("Minecart Hopper"),
	tiles = {
		-- up, down, right, left, back, front
		"default_cobble.png^minecart_appl_hopper_top.png",
		"default_cobble.png^minecart_appl_hopper.png",
		"default_cobble.png^minecart_appl_hopper_right.png",
		"default_cobble.png^minecart_appl_hopper.png",
		"default_cobble.png^minecart_appl_hopper.png",
		"default_cobble.png^minecart_appl_hopper.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16,  2/16, -8/16,  8/16, 8/16, -6/16},
			{-8/16,  2/16,  6/16,  8/16, 8/16,  8/16},
			{-8/16,  2/16, -8/16, -6/16, 8/16,  8/16},
			{ 6/16,  2/16, -8/16,  8/16, 8/16,  8/16},
			{-6/16,  0/16, -6/16,  6/16, 3/16,  6/16},
			{-5/16, -4/16, -5/16,  5/16, 0/16,  5/16},
			{ 0/16, -4/16, -3/16, 11/16, 2/16,  3/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-8/16,  2/16, -8/16,  8/16, 8/16,  8/16},
			{-5/16, -4/16, -5/16,  5/16, 0/16,  5/16},
			{ 0/16, -4/16, -3/16, 11/16, 2/16,  3/16},
		},
	},

	on_construct = function(pos)
		local inv = M(pos):get_inventory()
		inv:set_size('main', 4)
	end,
	
	after_place_node = function(pos, placer)
		local meta = M(pos)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", formspec)
		minetest.get_node_timer(pos):start(2)
	end,

	on_timer = function(pos, elapsed)
		local inv = M(pos):get_inventory()
		local param2 = minetest.get_node(pos).param2
		param2 = (param2 + 1) % 4 -- output is on the right
		if not pull_push_item(pos, param2) then
			scan_for_objects({x=pos.x, y=pos.y+1, z=pos.z}, inv)
			push_item(pos, inv, param2)
		end
		return true
	end,
		
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		minetest.get_node_timer(pos):start(2)
		return stack:get_count()
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		return stack:get_count()
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		for _,stack in ipairs(oldmetadata.inventory.main) do
			minetest.add_item(pos, stack)
		end
	end,
	
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	use_texture_alpha = minecart.CLIP,
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_craft({
	output = "minecart:hopper",
	recipe = {
		{"default:stone", "", "default:stone"},
		{"default:stone", "default:gold_ingot",	"default:stone"},
		{"", "default:stone", ""},
	},
})
