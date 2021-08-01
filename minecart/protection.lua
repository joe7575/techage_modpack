--[[

	Minecart
	========

	Copyright (C) 2019-2021 Joachim Stolberg

	MIT
	See license.txt for more information
	
]]--

local S = minecart.S
local RANGE = 8

local IsNodeUnderObservation = {}

-- Register all nodes, which should be protected by the "minecart:landmark"
function minecart.register_protected_node(name)
		IsNodeUnderObservation[name] = true
end

local function landmark_found(pos, name, range)
	local pos1 = {x=pos.x-range, y=pos.y-range, z=pos.z-range}
	local pos2 = {x=pos.x+range, y=pos.y+range, z=pos.z+range}
	for _,npos in ipairs(minetest.find_nodes_in_area(pos1, pos2, {"minecart:landmark"})) do
		if minetest.get_meta(npos):get_string("owner") ~= name then
			return true
		end
	end
	return false
end

local function is_protected(pos, name, range)
	if minetest.check_player_privs(name, "minecart")
			or not landmark_found(pos, name, range) then
		return false
	end
	return true
end

local old_is_protected = minetest.is_protected

function minetest.is_protected(pos, name)
	if pos and name then
		local node = minetest.get_node(pos)
		if IsNodeUnderObservation[node.name] and is_protected(pos, name, RANGE) then
			return true
		end
	end
	return old_is_protected(pos, name)
end

minetest.register_node("minecart:landmark", {
	description = S("Minecart Landmark"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-3/16, -8/16, -3/16,  3/16, 4/16, 3/16},
			{-2/16,  4/16, -3/16,  2/16, 5/16, 3/16},
		},
	},
	tiles = {
		'default_mossycobble.png',
		'default_mossycobble.png',
		'default_mossycobble.png',
		'default_mossycobble.png',
		'default_mossycobble.png^minecart_protect.png',
		'default_mossycobble.png^minecart_protect.png',
	},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", placer:get_player_name())
		if is_protected(pos, placer:get_player_name(), RANGE+3) then
			minetest.remove_node(pos)
			return true
		end
	end,
	
	can_dig = function(pos, digger)
		local meta = minetest.get_meta(pos)
		if meta:get_string("owner") == digger:get_player_name() then
			return true
		end
		if minetest.check_player_privs(digger:get_player_name(), "minecart") then
			return true
		end
		minetest.chat_send_player(digger:get_player_name(), 
				S("[minecart] Area is protected!").." (owner: "..meta:get_string("owner")..")")
		return false
	end,
	
	on_punch = function(pos, node, puncher, pointed_thing)
		minecart.set_land_marker(pos, RANGE, 20)
	end,
	
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {cracky = 3, stone = 1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = "minecart:landmark 6",
	recipe = {
		{"", "default:mossycobble", ""},
		{"", "default:mossycobble", ""},
		{"", "default:mossycobble", ""},
	},
})

minetest.register_node("minecart:ballast", {
	description = "Minecart Ballast",
	tiles = {"minecart_ballast.png"},
	groups = {crumbly = 1, cracky = 3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("minecart:ballast_slope", {
	description = "Minecart Ballast Slope",
	tiles = {"minecart_ballast.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16,  8/16, -4/16, 8/16},
			{-8/16, -4/16, -4/16,  8/16,  0/16, 8/16},
			{-8/16,  0/16,  0/16,  8/16,  4/16, 8/16},
			{-8/16,  4/16,  4/16,  8/16,  8/16, 8/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, -8/16,  8/16, 8/16, 8/16},
	},
	paramtype2 = "facedir",
	groups = {crumbly = 1, cracky = 3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("minecart:ballast_ramp", {
	description = "Minecart Ballast Ramp",
	tiles = {"minecart_ballast.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16,  8/16,  8/16, 8/16},
			{-8/16, -4/16, -4/16,  8/16, 12/16, 8/16},
			{-8/16,  0/16,  0/16,  8/16, 16/16, 8/16},
			{-8/16,  4/16,  4/16,  8/16, 20/16, 8/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, -8/16,  8/16, 8/16, 8/16},
	},
	paramtype2 = "facedir",
	groups = {crumbly = 1, cracky = 3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = "minecart:ballast 6",
	recipe = {
		{"", "", ""},
		{"default:cobble", "default:stone", "default:cobble"},
		{"default:cobble", "default:stone", "default:cobble"},
	},
})

minetest.register_craft({
	output = "minecart:ballast_slope 6",
	recipe = {
		{"", "", "default:cobble"},
		{"", "default:stone", "default:cobble"},
		{"default:cobble", "default:stone", "default:cobble"},
	},
})

minetest.register_craft({
	output = "minecart:ballast_ramp 2",
	recipe = {
		{"", "", ""},
		{"minecart:ballast_slope", "", ""},
		{"minecart:ballast", "", ""},
	},
})

minetest.register_privilege("minecart", {
	description = S("Allow to dig/place rails in Minecart Landmark areas"),
	give_to_singleplayer = false,
	give_to_admin = true,
})

minecart.register_protected_node("carts:rail")
minecart.register_protected_node("carts:powerrail")
minecart.register_protected_node("carts:brakerail")
minecart.register_protected_node("minecart:buffer")
minecart.register_protected_node("minecart:ballast")
minecart.register_protected_node("minecart:ballast_slope")
minecart.register_protected_node("minecart:ballast_ramp")
minecart.register_protected_node("minecart:speed1")
minecart.register_protected_node("minecart:speed2")
minecart.register_protected_node("minecart:speed4")
minecart.register_protected_node("minecart:speed8")

