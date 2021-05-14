--[[

	Tower Crane Mod
	===============

	Copyright (C) 2017-2020 Joachim Stolberg
	LGPLv2.1+
	See LICENSE.txt for more information

]]--


-- Maximum crane height in blocks (8..n)
towercrane.max_height = tonumber(minetest.settings:get("towercrane_max_height")) or 32

-- Maximum crane width in blocks (8..n)
towercrane.max_width = tonumber(minetest.settings:get("towercrane_max_width")) or 32

-- Crane rope lenght in block (max_height .. max_height+x)
towercrane.rope_length = tonumber(minetest.settings:get("towercrane_rope_length")) or 40

-- Recipe available (true/false)
towercrane.recipe = tonumber(minetest.settings:get("towercrane_recipe")) or true
