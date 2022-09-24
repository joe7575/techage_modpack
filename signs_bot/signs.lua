--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Signs Bot: Signs

]]--

-- Load support for I18n.
local S = signs_bot.S

local function formspec(cmnd)
	cmnd = minetest.formspec_escape(cmnd)
	return "size[4,7]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"label[0.2,0;"..cmnd.."]"
end

local function formspecXL(help_text, bot_cmnds)
	help_text = help_text or "no help"
	bot_cmnds = minetest.formspec_escape(bot_cmnds)
	return "size[9,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"label[0,0;" .. S("Instructions:") .. "]" ..
	"label[0.2,0.6;" .. help_text .. "]" ..
	"textarea[0.3,4.0;9,4.9;code;" .. S("Code") .. ":;" .. bot_cmnds .. "]"
end

local function register_sign(def)
	minetest.register_node("signs_bot:"..def.name, {
		description = def.description,
		inventory_image = def.image,
		drawtype = "nodebox",
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
			"default_wood.png^"..def.image,
		},
		after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos)
			meta:set_string("signs_bot_cmnd", def.commands)
			meta:set_string("formspec", formspec(def.commands))
			meta:set_string("infotext", def.description)
		end,
		on_rotate = screwdriver.disallow,
		paramtype = "light",
		use_texture_alpha = signs_bot.CLIP,
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, sign_bot_sign = 1},
		sounds = default.node_sound_wood_defaults(),
	})
end

local function register_signXL(def)
	minetest.register_node("signs_bot:"..def.name, {
		description = def.description,
		inventory_image = def.image,
		drawtype = "nodebox",
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
			"default_wood.png^"..def.image,
		},
		after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos)
			meta:set_string("signs_bot_cmnd", def.commands)
			meta:set_string("formspec", formspecXL(def.help_text, def.commands))
			meta:set_string("infotext", def.description)
		end,
		on_rotate = screwdriver.disallow,
		paramtype = "light",
		use_texture_alpha = signs_bot.CLIP,
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, sign_bot_sign = 1},
		sounds = default.node_sound_wood_defaults(),
	})
end

signs_bot.register_sign = register_sign
signs_bot.register_signXL = register_signXL



register_sign({
	name = "sign_right",
	description = S('Sign "turn right"'),
	commands = "turn_right",
	image = "signs_bot_sign_right.png",
})

minetest.register_craft({
	output = "signs_bot:sign_right 6",
	recipe = {
		{"group:wood", "default:stick", "group:wood"},
		{"dye:yellow", "default:stick", "dye:black"},
		{"", "", ""}
	}
})

register_sign({
	name = "sign_left",
	description = S('Sign "turn left"'),
	commands = "turn_left",
	image = "signs_bot_sign_left.png",
})

minetest.register_craft({
	output = "signs_bot:sign_left 6",
	recipe = {
		{"group:wood", "default:stick", "group:wood"},
		{"dye:yellow", "default:stick", ""},
		{"dye:black", "", ""}
	}
})

register_sign({
	name = "sign_take",
	description = S('Sign "take item"'),
	commands = "take_item 99\nturn_around",
	image = "signs_bot_sign_take.png",
})

minetest.register_craft({
	output = "signs_bot:sign_take 6",
	recipe = {
		{"group:wood", "default:stick", "group:wood"},
		{"dye:yellow", "default:stick", ""},
		{"", "dye:black", ""}
	}
})

register_sign({
	name = "sign_add",
	description = S('Sign "add item"'),
	commands = "add_item 99\nturn_around",
	image = "signs_bot_sign_add.png",
})

minetest.register_craft({
	output = "signs_bot:sign_add 6",
	recipe = {
		{"group:wood", "default:stick", "group:wood"},
		{"dye:yellow", "default:stick", ""},
		{"", "", "dye:black"}
	}
})

register_sign({
	name = "sign_stop",
	description = S('Sign "stop"'),
	commands = "stop",
	image = "signs_bot_sign_stop.png",
})

minetest.register_craft({
	output = "signs_bot:sign_stop 6",
	recipe = {
		{"group:wood", "default:stick", "group:wood"},
		{"dye:black", "default:stick", "dye:yellow"},
		{"", "", ""}
	}
})

if minetest.global_exists("minecart") then
	register_sign({
		name = "sign_add_cart",
		description = S('Sign "add to cart"'),
		commands = "drop_items 99 1\npunch_cart\nturn_around",
		image = "signs_bot_sign_add_cart.png",
	})

	minetest.register_craft({
		output = "signs_bot:sign_add_cart 4",
		recipe = {
			{"group:wood", "default:stick", "group:wood"},
			{"dye:black", "default:stick", "dye:yellow"},
			{"dye:black", "", ""}
		}
	})

	register_sign({
		name = "sign_take_cart",
		description = S('Sign "take from cart"'),
		commands = "pickup_items 1\npunch_cart\nturn_around",
		image = "signs_bot_sign_take_cart.png",
	})

	minetest.register_craft({
		output = "signs_bot:sign_take_cart 4",
		recipe = {
			{"group:wood", "default:stick", "group:wood"},
			{"dye:black", "default:stick", "dye:yellow"},
			{"", "dye:black", ""}
		}
	})
end

if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "sign_right", {
		name = S('Sign "turn right"'),
		data = {
			item = "signs_bot:sign_right",
			text = S("The Bot turns right when it detects this sign in front of it.")
		},
	})
	doc.add_entry("signs_bot", "sign_left", {
		name = S('Sign "turn left"'),
		data = {
			item = "signs_bot:sign_left",
			text = S("The Bot turns left when it detects this sign in front of it.")
		},
	})
	doc.add_entry("signs_bot", "sign_take", {
		name = S('Sign "take item"'),
		data = {
			item = "signs_bot:sign_take",
			text = table.concat({
				S("The Bot takes items out of a chest in front of it and then turns around."),
				S("This sign has to be placed on top of the chest."),
			}, "\n")
		},
	})
	doc.add_entry("signs_bot", "sign_add", {
		name = S('Sign "add item"'),
		data = {
			item = "signs_bot:sign_add",
			text = table.concat({
				S("The Bot puts items into a chest in front of it and then turns around."),
				S("This sign has to be placed on top of the chest."),
			}, "\n")
		},
	})
	doc.add_entry("signs_bot", "sign_stop", {
		name = S('Sign "stop"'),
		data = {
			item = "signs_bot:sign_stop",
			text = S("The Bot will stop in front of this sign until the sign is removed or the bot is turned off.")
		},
	})
end

if minetest.get_modpath("doc") and minetest.global_exists("minecart") then
	doc.add_entry("signs_bot", "sign_add_cart", {
		name = S('Sign "add to cart"'),
		data = {
			item = "signs_bot:sign_add_cart",
			text = table.concat({
				S("The Bot puts items into a minecart in front of it, pushes the cart and then turns around."),
				S("This sign has to be placed on top of the rail at the cart end position."),
			}, "\n")
		},
	})
	doc.add_entry("signs_bot", "sign_take_cart", {
		name = S('Sign "take from cart"'),
		data = {
			item = "signs_bot:sign_take_cart",
			text = table.concat({
				S("The Bot takes items out of a minecart in front of it, pushes the cart and then turns around."),
				S("This sign has to be placed on top of the rail at the cart end position."),
			}, "\n")
		},
	})
end
