--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	A robot controlled by signs

]]--

signs_bot = {}

-- Version for compatibility checks, see readme.md/history
signs_bot.version = 1.09

-- Test for MT 5.4 new string mode
signs_bot.CLIP = minetest.features.use_texture_alpha_string_modes and "clip" or true

if minetest.global_exists("techage") and techage.version < 1.0 then
	error("[signs_bot] Signs Bot requires techage version 1.0 or newer!")
end

if tubelib2.version < 1.9 then
	error("[signs_bot] Signs Bot requires tubelib2 version 1.9 or newer!")
end

if minetest.global_exists("minecart") and minecart.version < 2.0 then
	error("[signs_bot] Signs Bot requires minecart version 2.0 or newer!")
end

-- Load support for I18n.
signs_bot.S = minetest.get_translator("signs_bot")

local MP = minetest.get_modpath("signs_bot")

dofile(MP.."/doc.lua")
dofile(MP.."/random.lua")
dofile(MP.."/lib.lua")
dofile(MP.."/basis.lua")
dofile(MP.."/robot.lua")
dofile(MP.."/signs.lua")

dofile(MP.."/commands.lua")
dofile(MP.."/cmd_move.lua")
dofile(MP.."/cmd_item.lua")
dofile(MP.."/cmd_place.lua")
dofile(MP.."/cmd_sign.lua")
dofile(MP.."/cmd_pattern.lua")
dofile(MP.."/cmd_farming.lua")
dofile(MP.."/cmd_flowers.lua")
dofile(MP.."/cmd_soup.lua")
dofile(MP.."/cmd_trees.lua")

dofile(MP.."/signal.lua")
dofile(MP.."/extender.lua")
dofile(MP.."/changer.lua")
dofile(MP.."/bot_flap.lua")

dofile(MP.."/duplicator.lua")
dofile(MP.."/nodes.lua")
dofile(MP.."/bot_sensor.lua")
dofile(MP.."/node_sensor.lua")
dofile(MP.."/crop_sensor.lua")
dofile(MP.."/cart_sensor.lua")
dofile(MP.."/chest.lua")
dofile(MP.."/legacy.lua")
dofile(MP.."/techage.lua")
dofile(MP.."/timer.lua")
dofile(MP.."/delayer.lua")
dofile(MP.."/logic_and.lua")
dofile(MP.."/compost.lua")

dofile(MP.."/tool.lua")
