--[[

	Hyperloop Mod
	=============

	Copyright (C) 2017-2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

]]--

-- for lazy programmers
local SP = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local S = hyperloop.S
local NS = hyperloop.NS

local Tube = hyperloop.Tube
local Stations = hyperloop.Stations


-- Station Pod Assembly Plan
local AssemblyPlan = {
	-- y-offs, x/z-path, facedir-offs, name
	-- middle slice
	{ 1, "2F", 0, "hyperloop:pod_wall_ni"},
	{ 1, "",   0, "hyperloop:pod_wall_ni"},
	{ 1, "",   0, "hyperloop:pod_wall_ni"},
	{ 0, "1B", 0, "hyperloop:pod_wall_ni"},
	{ 0, "1B", 0, "hyperloop:pod_wall_ni"},
	{ 0, "1B", 0, "hyperloop:pod_wall_ni"},
	{-1, "",   0, "hyperloop:pod_wall_ni"},
	{-1, "",   0, "hyperloop:pod_wall_ni"},
	{ 0, "1F", 2, "hyperloop:seat"},
	{ 0, "1F", 0, "hyperloop:pod_floor"},
	{ 1, "",   0, "hyperloop:lcd"},
	-- right slice	
	{-1, "1F1R", 0, "hyperloop:pod_wall_ni"},
	{ 1, "",   0, "hyperloop:pod_wall_ni"},
	{ 1, "",   0, "hyperloop:pod_wall_ni"},
	{ 0, "1B", 0, "hyperloop:pod_wall_ni"},
	{ 0, "1B", 0, "hyperloop:pod_wall_ni"},
	{ 0, "1B", 0, "hyperloop:pod_wall_ni"},
	{-1, "",   0, "hyperloop:pod_wall_ni"},
	{-1, "",   0, "hyperloop:pod_wall_ni"},
	{ 0, "1F", 0, "hyperloop:pod_wall_ni"},
	{ 0, "1F", 0, "hyperloop:pod_wall_ni"},
	{ 1, "",   0, "hyperloop:pod_wall_ni"},
	{ 0, "1B", 0, "hyperloop:pod_wall_ni"},
	-- left slice	
	{-1, "2L2R", 0, "hyperloop:pod_wall_ni"},
	{ 1, "",   0, "hyperloop:pod_wall_ni"},
	{ 1, "",   0, "hyperloop:pod_wall_ni"},
	{ 0, "1B", 0, "hyperloop:pod_wall_ni"},
	{ 0, "1B", 0, "hyperloop:pod_wall_ni"},
	{ 0, "1B", 0, "hyperloop:pod_wall_ni"},
	{-1, "",   0, "hyperloop:pod_wall_ni"},
	{-1, "",   0, "hyperloop:pod_wall_ni"},
	{ 0, "1F", 0, "hyperloop:pod_wall_ni"},
	{ 1, "",   0, "hyperloop:pod_wall_ni"},
	{ 0, "1F", 1, "hyperloop:doorTopPassive"},
	{-1, "",   1, "hyperloop:doorBottom"},
}


local function store_station(pos, placer)
	local facedir = hyperloop.get_facedir(placer)
	-- do a facedir correction 
	facedir = (facedir + 3) % 4  -- face to LCD
	Stations:set(pos, "Station", {
			owner = placer:get_player_name(), 
			facedir = facedir,
			time_blocked = 0})
end

-- Calls the node related "auto_place_node()" callback.
local function call_auto_place_node(name, pos, facedir, sKey)
	local node = minetest.registered_nodes[name]
	if node.auto_place_node ~= nil then
		node.auto_place_node(pos, facedir, sKey)
	end
end

local function place_node(pos, facedir, node_name, sKey)
	if node_name == "hyperloop:lcd" then
		-- wallmounted devices need a facedir correction
		local tbl = {[0]=4, [1]=2, [2]=5, [3]=3} 
		minetest.add_node(pos, {name=node_name, paramtype2="wallmounted", param2=tbl[facedir]})
	else
		minetest.add_node(pos, {name=node_name, param2=facedir})
	end
	call_auto_place_node(node_name, pos, facedir, sKey)
end

-- timer function, called cyclically
local function construct(idx, pos, facedir, player_name, sKey)
	local item = AssemblyPlan[idx]
	if item ~= nil then
		local y, path, fd_offs, node_name = item[1], item[2], item[3], item[4]
		pos = hyperloop.new_pos(pos, facedir, path, y)
		place_node(pos, (facedir + fd_offs) % 4, node_name, sKey)
		minetest.after(0.5, construct, idx+1, pos, facedir, player_name, sKey)
	else
		hyperloop.chat(player_name, S("Station completed. Now place the Booking Machine!"))
	end
end	
	
local function check_space(pos, facedir, placer)
	for _,item in ipairs(AssemblyPlan) do
		local y, path, node_name = item[1], item[2], item[4]
		pos = hyperloop.new_pos(pos, facedir, path, y)
		if minetest.is_protected(pos, placer:get_player_name()) then
			hyperloop.chat(placer, S("Area is protected!"))
			return false
		elseif minetest.get_node_or_nil(pos).name ~= "air" then
			hyperloop.chat(placer, S("Not enough space to build the station!"))
			return false
		end
	end
	return true
end

local station_formspec =
	"size[8,9]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"label[2,0;"..S("Hyperloop Station Pod Builder").."]" ..
	"image[0.2,0.9;3,3;hyperloop_station_formspec.png]"..
	"list[context;src;3,0.9;1,4;]"..
	"label[4,1.2;30 x "..S("Hyperloop Pod Shell").."]" ..
	"item_image[3,0.9;1,1;hyperloop:pod_wall]"..
	"label[4,2.2;4 x "..S("Hypersteel Ingot").."]" ..
	"item_image[3,1.9;1,1;hyperloop:hypersteel_ingot]"..
	"label[4,3.2;2 x "..S("Blue Wool").."]" ..
	"item_image[3,2.9;1,1;wool:blue]"..
	"label[4,4.2;2 x "..S("Glass").."]" ..
	"item_image[3,3.9;1,1;default:glass]"..
	"list[current_player;main;0,5.3;8,4;]"..
    "listring[context;src]"..
    "listring[current_player;main]"


local function allow_metadata_inventory(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if M(pos):get_int("busy") == 1 then
		return 0
	end
	return stack:get_count()
end

local function check_inventory(inv, player)
	local list = inv:get_list("src")
	if list[1]:get_name() == "hyperloop:pod_wall" and list[1]:get_count() >= 30 then
		if list[2]:get_name() == "hyperloop:hypersteel_ingot" and list[2]:get_count() >= 4 then
			if list[3]:get_name() == "wool:blue" and list[3]:get_count() >= 2 then
				if list[4]:get_name() == "default:glass" and list[4]:get_count() >= 2 then
					return true
				end
			end
		end
	end
	hyperloop.chat(player, S("Not enough inventory items to build the station!"))
	return false
end
	
local function remove_inventory_items(inv, meta)
	inv:remove_item("src", ItemStack("hyperloop:pod_wall 30"))
	inv:remove_item("src", ItemStack("hyperloop:hypersteel_ingot 4"))
	inv:remove_item("src", ItemStack("wool:blue 2"))
	inv:remove_item("src", ItemStack("default:glass 2"))
	meta:set_int("busy", 0)
end

local function add_inventory_items(inv)
	inv:add_item("src", ItemStack("hyperloop:pod_wall 30"))
	inv:add_item("src", ItemStack("hyperloop:hypersteel_ingot 4"))
	inv:add_item("src", ItemStack("wool:blue 2"))
	inv:add_item("src", ItemStack("default:glass 2"))
end

local function build_station(pos, placer)
	-- check protection
	if minetest.is_protected(pos, placer:get_player_name()) then
		return
	end			
	local meta = M(pos)
	local inv = meta:get_inventory()
	local facedir = hyperloop.get_facedir(placer)
	-- do a facedir correction 
	facedir = (facedir + 3) % 4				-- face to LCD
	if check_inventory(inv, placer) then
		Stations:update(pos, {facedir = facedir})

		if check_space(table.copy(pos), facedir, placer) then
			construct(1, table.copy(pos), facedir, placer:get_player_name(), SP(pos))
			meta:set_string("formspec", station_formspec .. 
				"button_exit[0,3.9;3,1;destroy;"..S("Destroy Station").."]")
			meta:set_int("built", 1)
			meta:set_int("busy", 1)
			-- remove items aften the station is build
			minetest.after(20, remove_inventory_items, inv, meta)
		end
	end
end

local function on_destruct(pos)
	Stations:update(pos, {
			booking_pos = "nil",
			booking_info = "nil",
			name = "Station",
	})
end

local function destroy_station(pos, player_name)
	-- check protection
	if minetest.is_protected(pos, player_name) then
		return
	end		
	
	local station = Stations:get(pos)
	if station then
		-- remove nodes
		local _pos = table.copy(pos)
		for _,item in ipairs(AssemblyPlan) do
			local y, path, node_name = item[1], item[2], item[4]
			_pos = hyperloop.new_pos(_pos, station.facedir, path, y)
			minetest.remove_node(_pos)
		end
		on_destruct(pos)
		-- maintain meta
		local meta = M(pos)
		meta:set_string("formspec", station_formspec .. 
			"button_exit[0,3.9;3,1;build;"..S("Build Station").."]")
		local inv = meta:get_inventory()
		add_inventory_items(inv)
		meta:set_int("built", 0)
	else
		M(pos):set_int("built", 0)
	end
end

minetest.register_node("hyperloop:station", {
	description = S("Hyperloop Station Block"),
	drawtype = "nodebox",
	tiles = {
		"hyperloop_station.png",
		"hyperloop_station_connection.png",
		"hyperloop_station_connection.png",
	},

	on_construct = function(pos)
		local meta = M(pos)
		meta:set_string("formspec", station_formspec .. 
			"button_exit[0,3.9;3,1;build;"..S("Build Station").."]")
		local inv = meta:get_inventory()
		inv:set_size('src', 4)
	end,
	
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		hyperloop.check_network_level(pos, placer)
		M(pos):set_string("infotext", S("Station"))
		store_station(pos, placer)
		Tube:after_place_node(pos)
	end,

	allow_metadata_inventory_put = allow_metadata_inventory,
	allow_metadata_inventory_take = allow_metadata_inventory,

	on_receive_fields = function(pos, formname, fields, player)
		if fields.destroy ~= nil then
			destroy_station(pos, player:get_player_name())
		elseif fields.build ~= nil then
			build_station(pos, player)
		end
	end,
	
	on_dig = function(pos, node, puncher, pointed_thing)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if inv:is_empty("src") and meta:get_int("built") ~= 1 then
			minetest.node_dig(pos, node, puncher, pointed_thing)
		end
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Tube:after_dig_node(pos)
		Stations:delete(pos)
	end,
		
	on_rotate = screwdriver.disallow,	
	paramtype2 = "facedir",
	groups = {cracky = 1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("hyperloop:pod_wall", {
	description = S("Hyperloop Pod Shell"),
	tiles = {
		-- up, down, right, left, back, front
		"hyperloop_skin2.png",
		"hyperloop_skin2.png",
		"hyperloop_skin.png",
	},
	on_rotate = screwdriver.disallow,	
	paramtype2 = "facedir",
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("hyperloop:pod_wall_ni", {
	description = S("Hyperloop Pod Shell"),
	tiles = {
		-- up, down, right, left, back, front
		"hyperloop_skin2.png",
		"hyperloop_skin2.png",
		"hyperloop_skin.png",
	},
	on_rotate = screwdriver.disallow,	
	paramtype2 = "facedir",
	groups = {cracky=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
	drop = "",
})

minetest.register_node("hyperloop:pod_floor", {
	description = S("Hyperloop Pod Shell"),
	tiles = {
		-- up, down, right, left, back, front
		"hyperloop_skin2.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, 8/16,  -7.5/16,  8/16},
		},
	},
	on_rotate = screwdriver.disallow,	
	paramtype2 = "facedir",
	groups = {cracky=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
	drop = "",
})
