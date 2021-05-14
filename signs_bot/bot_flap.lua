--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPLv3
	See LICENSE.txt for more information
	
	Signs Bot: Bot Flap

]]--

-- Load support for I18n.
local S = signs_bot.S

local function formspec(cmnd)
	cmnd = minetest.formspec_escape(cmnd)
	return "size[6,5]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"label[0.3,0.3;"..cmnd.."]"..
	"button_exit[2.5,5.5;2,1;exit;"..S("Exit").."]"
end

local commands = [[dig_sign 6
move 2
place_sign_behind 6
]]

minetest.register_node("signs_bot:bot_flap", {
	description = S("Bot Flap"),
	paramtype2 = "facedir",
	tiles = {
		"signs_bot_bot_flap_top.png",
		"signs_bot_bot_flap_top.png",
		"signs_bot_bot_flap_top.png",
		"signs_bot_bot_flap_top.png",
		"signs_bot_bot_flap.png",
		"signs_bot_bot_flap.png",
	},
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("signs_bot_cmnd", commands)
		meta:set_string("formspec", formspec(commands))
	end,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1, sign_bot_sign = 1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "signs_bot:bot_flap",
	recipe = {
		{"signs_bot:sign_cmnd", "group:wood", "default:steel_ingot"},
		{"", "", ""},
		{"", "", ""}
	}
})

if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "bot_flap", {
		name = S("Bot Flap"),
		data = {
			item = "signs_bot:bot_flap",
			text = table.concat({
				S("The flap is a simple block used as door for the bot."),
				S("Place the flap in any wall, and the bot will automatically open"),
				S("and close the flap as it passes through it."),
			}, "\n")		
		},
	})
end
