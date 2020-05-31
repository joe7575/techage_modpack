--[[

	Hyperloop Mod
	=============

	v2.04 by JoSt

	Copyright (C) 2017-2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	History:
	2017-06-18  v0.01  First version
	2017-07-06  v0.02  Version on GitHub
	2017-07-07  v0.03  Recipes added, settingstypes added
	2017-07-08  v0.04  Door removal issue fixed
	2017-07-16  v0.05  Doors can be opened manually
	2017-07-24  v0.06  Tubes with limited slope, elevator and deco blocks added
	2017-07-28  v0.07  Slope removed, Station auto-builder added
	2017-07-30  v0.08  Signs added, tube robot added, crowbar added
	2017-07-31  v0.09  Some bug fixes on the Bocking Machine
	2017-08-01  v0.10  Elevator now with sound and travel animation plus minor bug fixes
	2017-08-06  v0.11  Crowbar now allows repairing of illegally detroyed tubes
	2018-03-27  v0.12  Some minor improvements with player position, arrival time,
	                   Wifi node improvements, Podshell cheating bugfix,
	                   forceload_block removed.
	2018-04-13  v0.13  Potential "Never Store ObjectRefs" bug fixed
	2018-10-27  v1.00  Release
	2018-10-27  v2.00  Switched to lubelib2 for shafts and tubes
	2018-12-16  v2.01  Adapted to lubelib2 v0.5
	2018-12-20  v2.02  Intllib support added, bugs fixed
	2019-03-23  v2.03  Elevator duplication bugfix
	2020-01-03  v2.04  Elevator door bugfix (MT 5+)
	2020-03-12  v2.05  minetest translator added (thanks to acmgit/Clyde)

]]--

hyperloop = {}

-- Version for compatibility checks, see history
hyperloop.version = 2.05

if minetest.global_exists("techage") and techage.version < 0.06 then
	minetest.log("error", "[hyperloop] Hyperloop requires techage version 0.06 or newer!")
	return
end


if minetest.get_translator ~= nil then
    hyperloop.S = minetest.get_translator(minetest.get_current_modname())
    
else
    -- Load support for intllib.
    local MP = minetest.get_modpath("hyperloop")
    hyperloop.S, hyperloop.NS = dofile(MP.."/intllib.lua")    
        
end

if tubelib2.version < 1.7 then
	minetest.log("error", "Hyperloop requires tubelib2 version 1.7 or newer!!!")
else
	-- Configuration settings
	hyperloop.wifi_enabled = minetest.settings:get_bool("hyperloop_wifi_enabled")
	hyperloop.wifi_crafting_enabled = minetest.settings:get_bool("hyperloop_wifi_crafting_enabled")
	hyperloop.free_tube_placement_enabled = minetest.settings:get_bool("hyperloop_free_tube_placement_enabled")
	
	dofile(minetest.get_modpath("hyperloop") .. "/network.lua")
	dofile(minetest.get_modpath("hyperloop") .. "/data_base.lua")
	dofile(minetest.get_modpath("hyperloop") .. "/booking.lua")
	dofile(minetest.get_modpath("hyperloop") .. "/utils.lua")
	dofile(minetest.get_modpath("hyperloop") .. "/elevator.lua")
	dofile(minetest.get_modpath("hyperloop") .. "/tube.lua")
	dofile(minetest.get_modpath("hyperloop") .. "/tubecrowbar.lua")
	dofile(minetest.get_modpath("hyperloop") .. "/junction.lua")
	dofile(minetest.get_modpath("hyperloop") .. "/station.lua")
	dofile(minetest.get_modpath("hyperloop") .. "/booking_node.lua")
	if hyperloop.wifi_enabled then
		dofile(minetest.get_modpath("hyperloop") .. "/wifi.lua")
	end
	dofile(minetest.get_modpath("hyperloop") .. "/map.lua")
	dofile(minetest.get_modpath("hyperloop") .. "/door.lua")
	dofile(minetest.get_modpath("hyperloop") .. "/seat.lua")
	dofile(minetest.get_modpath("hyperloop") .. "/lcd.lua")
	dofile(minetest.get_modpath("hyperloop") .. "/waypoint.lua")
	dofile(minetest.get_modpath("hyperloop") .. "/deco.lua")
	dofile(minetest.get_modpath("hyperloop") .. "/recipes.lua")
	---- Migration from v1 to v2
	dofile(minetest.get_modpath("hyperloop") .. "/migrate.lua")

	print ("[MOD] Hyperloop loaded")
end
