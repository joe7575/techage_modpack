--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Bot tree cutting signs
]]--

-- Load support for I18n.
local S = signs_bot.S

local CMNDS = [[-- Harvest pine/aspen trunks v1.0

-- Take dirt and saplings from chest
dig_sign 1
move 1
turn_right
take_item 99 0
take_item 99 0

-- Goto trunk
turn_left
dig_front 0 0
move 1

-- Climb up
repeat 10
    dig_above 0
    move_up
    place_below 1
end

-- Climb down
repeat 10
    dig_below 1
    move_down
end

-- Pickup saplings
repeat 4
    pickup_items 2
    turn_left
end

-- Return dirt and saplings to chest
backward
plant_sapling 2
turn_right
add_item 99 1
add_item 99 2

-- Finish
turn_left
backward
place_sign 1
turn_around]]

local HELP = table.concat({
	S("Used to harvest an aspen or pine tree trunk"),
	S("- Place the sign in front of the tree."), 
	S("- Place a chest to the right of the sign."),
	S("- Put a dirt stack (10 items min.) into the chest."),
        S("- Preconfigure slot 1 of the bot inventory with dirt"),
        S("- Preconfigure slot 2 of the bot inventory with saplings"),
}, "\n")


signs_bot.register_signXL({
	name = "aspen",
	description = S('Sign "aspen"'),
	help_text = HELP,
	commands = CMNDS,
	image = "signs_bot_sign_aspen.png",
})

minetest.register_craft({
	output = "signs_bot:aspen 2",
	recipe = {
		{"group:wood", "default:stick", "group:wood"},
		{"dye:black", "default:stick", "dye:yellow"},
		{"dye:grey", "default:aspen_sapling", ""}
	}
})

if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "aspen", {
		name = S("Sign 'aspen'"),
		data = {
			item = "signs_bot:aspen",
			text = HELP .. "\n",
		},
	})
end
