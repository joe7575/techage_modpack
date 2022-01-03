--[[

	TA4 Addons
	==========

	Copyright (C) 2020-2021 Joachim Stolberg
	Copyright (C) 2020-2021 Thomas S.

	GPL v3
	See LICENSE.txt for more information

]]--

ta4_addons = {}

-- Version for compatibility checks
ta4_addons.version = 0.1

-- Load support for I18n.
ta4_addons.S = minetest.get_translator("ta4_addons")

local MP = minetest.get_modpath("ta4_addons")

dofile(MP.."/touchscreen/main.lua") -- Touchscreen
dofile(MP.."/matrix_screen/main.lua") -- Matrix Screen

dofile(MP.."/manual_DE.lua") -- Techage Manual DE
dofile(MP.."/manual_EN.lua") -- Techage Manual EN


techage.add_manual_items({ta4_addons_touchscreen = "ta4_addons_touchscreen_inventory.png"})
techage.add_manual_items({ta4_addons_matrix_screen = "ta4_addons_matrix_screen_inventory.png"})
