--[[

	SaferLua [safer_lua]
	====================

	Copyright (C) 2018-2025 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	environ.lua:

]]--

safer_lua = {}

-- Version for compatibility checks, see readme.md/history
safer_lua.version = 1.04

dofile(minetest.get_modpath("safer_lua") .. "/data_struct.lua")
dofile(minetest.get_modpath("safer_lua") .. "/scanner.lua")
dofile(minetest.get_modpath("safer_lua") .. "/environ.lua")
-- only for demo purposes
--dofile(minetest.get_modpath("safer_lua") .. "/demo.lua")