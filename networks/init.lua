--[[

	Networks
	========

	Copyright (C) 2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

]]--

networks = {}

-- Version for compatibility checks, see readme.md/history
networks.version = 0.11

if not minetest.global_exists("tubelib2") or tubelib2.version < 2.2 then
	minetest.log("error", "[networks] Networks requires tubelib2 version 2.2 or newer!")
	return
end

local MP = minetest.get_modpath("networks")

dofile(MP .. "/hidden.lua")
dofile(MP .. "/networks.lua")
dofile(MP .. "/junction.lua")
dofile(MP .. "/observer.lua")
dofile(MP .. "/power.lua")
dofile(MP .. "/liquid.lua")
dofile(MP .. "/control.lua")

if minetest.settings:get_bool("networks_test_enabled") == true then
	-- Only for testing/demo purposes
	dofile(MP .. "/test/test_liquid.lua")
	local Cable = dofile(MP .. "/test/test_power.lua")
	assert(loadfile(MP .. "/test/test_control.lua"))(Cable)
	dofile(MP .. "/test/test_tool.lua")
end
