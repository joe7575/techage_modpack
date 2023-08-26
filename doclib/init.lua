--[[

	DocLib
	======

	Copyright (C) 2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	A library to generate ingame manuals based on markdown files.

]]--

doclib = {}

-- Version for compatibility checks, see readme.md/history
doclib.version = 1.0

-- Load support for I18n.
doclib.S = minetest.get_translator("doclib")

local MP = minetest.get_modpath("doclib")

dofile(MP.."/formspec.lua")
dofile(MP.."/api.lua")
--dofile(MP.."/node.lua") -- only for testing purposes
