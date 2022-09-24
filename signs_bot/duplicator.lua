--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Signs duplicator

]]--

-- for lazy programmers
local M = minetest.get_meta

-- Load support for I18n.
local S = signs_bot.S

local lib = signs_bot.lib

local formspec = "size[8,7.3]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"label[0.1,0.2;"..S("Template:").."]"..
	"list[context;temp;2,0;1,1;]"..
	"label[0.1,1.2;"..S("Input:").."]"..
	"list[context;inp;2,1;1,1;]"..
	"label[0.1,2.2;"..S("Output:").."]"..
	"list[context;outp;2,2;1,1;]"..
	"label[3,0.2;"..S("1. Place one 'cmnd' sign").."]"..
	"label[3,1.2;"..S("2. Add 'blank signs'").."]"..
	"label[3,2.2;"..S("3. Take the copies").."]"..
	"list[current_player;main;0,3.5;8,4;]"..
	"listring[context;inp]"..
	"listring[current_player;main]"..
	"listring[current_player;main]"..
	"listring[context;outp]"

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if listname == "outp" then
		return 0
	end
	if minetest.get_item_group(stack:get_name(), "sign_bot_sign") ~= 1
			and stack:get_name() ~= "default:book_written" then
		return 0
	end
	if listname == "temp" then
		return 1
	end
	return stack:get_count()
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

local function get_template_data(stack)
	local name = stack:get_name()
	local data = stack:get_meta():to_table().fields

	if name == "default:sign_user" or name == "signs_bot:sign_cmnd" then
		return data.description, data.cmnd
	end
	if name == "default:book_written" then
		return data.title, data.text
	end
end

local function get_dest_item(stack)
	local name = stack:get_name()
	if name == "signs_bot:sign_blank" or name == "signs_bot:sign_user" then
		return ItemStack("signs_bot:sign_user")
	end
	if name == "signs_bot:sign_cmnd" then
		return ItemStack("signs_bot:sign_cmnd")
	end
end

local function move_to_output(pos)
	local inv = M(pos):get_inventory()
	local inp_stack = inv:get_stack("inp", 1)
	local temp_stack = inv:get_stack("temp", 1)
	local outp_stack = inv:get_stack("outp", 1)
	local dest_item = get_dest_item(inp_stack)
	local descr, cmnd = get_template_data(temp_stack)

	if dest_item and descr then
		dest_item:set_count(inp_stack:get_count())
		local meta = dest_item:get_meta()
		meta:set_string("description", descr)
		meta:set_string("cmnd", cmnd)
		inp_stack:clear()
		inv:set_stack("inp", 1, inp_stack)
		inv:set_stack("outp", 1, dest_item)
	end
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
	if listname == "inp" then
		minetest.after(0.5, move_to_output, pos)
	end
end

minetest.register_node("signs_bot:duplicator", {
	description = S("Signs Duplicator"),
	stack_max = 1,
	tiles = {
		-- up, down, right, left, back, front
		'signs_bot_base_top.png',
		'signs_bot_base_top.png',
		'signs_bot_duplicator.png',
		'signs_bot_duplicator.png',
		'signs_bot_duplicator.png',
		'signs_bot_duplicator.png',
	},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('inp', 1)
		inv:set_size('temp', 1)
		inv:set_size('outp', 1)
		meta:set_string("formspec", formspec)
	end,

	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_metadata_inventory_put = on_metadata_inventory_put,

	can_dig = function(pos, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return false
		end
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("inp") and inv:is_empty("temp") and inv:is_empty("outp")
	end,

	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {cracky = 1},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_craft({
	output = "signs_bot:duplicator",
	recipe = {
		{"default:steel_ingot", "group:wood", "default:steel_ingot"},
		{"", "basic_materials:gear_steel", ""},
		{"default:tin_ingot", "", "default:tin_ingot"}
	}
})

local function formspec_user(cmnd)
	cmnd = minetest.formspec_escape(cmnd)
	return "size[6,5]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"label[0.2,0;"..cmnd.."]"
end

minetest.register_node("signs_bot:sign_user", {
	description = S('Sign "user"'),
	drawtype = "nodebox",
	inventory_image = "signs_bot_sign_user.png",
	node_box = {
		type = "fixed",
		fixed = {
			{ -1/16, -8/16, -1/16,   1/16, 4/16, 1/16},
			{ -6/16, -5/16, -2/16,   6/16, 3/16, -1/16},
		},
	},
	paramtype2 = "facedir",
	tiles = {
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png^signs_bot_sign_user.png",
	},
	after_place_node = function(pos, placer, itemstack)
		local imeta = itemstack:get_meta()
		local nmeta = minetest.get_meta(pos)
		if imeta:get_string("description") ~= ""  then
			nmeta:set_string("signs_bot_cmnd", imeta:get_string("cmnd"))
			nmeta:set_string("sign_name", imeta:get_string("description"))
		end
		nmeta:set_string("infotext", nmeta:get_string("sign_name"))
		local text = nmeta:get_string("sign_name").."\n"..imeta:get_string("cmnd")
		nmeta:set_string("formspec", formspec_user(text))
	end,

	after_dig_node = lib.after_dig_sign_node,
	drop = "",
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, sign_bot_sign = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_wood_defaults(),
})

signs_bot.register_sign({
	name = "sign_blank",
	description = S('Sign "blank"'),
	commands = "",
	image = "signs_bot_sign_blank.png",
})

minetest.register_craft({
	output = "signs_bot:sign_blank 6",
	recipe = {
		{"group:wood", "default:stick", "group:wood"},
		{"dye:yellow", "default:stick", "dye:yellow"},
		{"", "", ""}
	}
})

if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "duplicator", {
		name = S("Signs Duplicator"),
		data = {
			item = "signs_bot:duplicator",
			text = table.concat({
				S("The Duplicator can be used to make copies of signs."),
				S("1. Put one 'cmnd' sign to be used as template into the 'Template' inventory"),
				S("2. Add one or several 'blank signs' to the 'Input' inventory."),
				S("3. Take the copies from the 'Output' inventory."),
				"",
				S("Written books [default:book_written] can alternatively be used as template"),
				S("Already written signs can be used as input, too."),
			}, "\n")
		},
	})
end

if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "sign_blank", {
		name = S('Sign "blank"'),
		data = {
			item = "signs_bot:sign_blank",
			text = S("Needed as input for the Duplicator.")
		},
	})
end
