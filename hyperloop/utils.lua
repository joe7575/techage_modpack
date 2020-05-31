--[[

	Hyperloop Mod
	=============

	Copyright (C) 2017-2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	Some common used helper functions
]]--

local PI = 3.1415926

-- for lazy programmers
local SP = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

local Stations = hyperloop.Stations

function hyperloop.chat(player, text)
	if type(player) == "string" then
		minetest.chat_send_player(player, "[Hyperloop] "..text)
	elseif player ~= nil then
		minetest.chat_send_player(player:get_player_name(), "[Hyperloop] "..text)
	end
end

function hyperloop.get_facedir(placer)
	local lookdir = placer:get_look_dir()
	return core.dir_to_facedir(lookdir)
end

function hyperloop.facedir_to_rad(facedir)
	local tbl = {[0]=0, [1]=3, [2]=2, [3]=1}
	return tbl[facedir] / 2 * PI
end

-- Distance between two points in (tube) blocks
function hyperloop.distance(pos1, pos2)
	return math.floor(math.abs(pos1.x - pos2.x) + 
			math.abs(pos1.y - pos2.y) + math.abs(pos1.z - pos2.z))
end

-- calculate the new pos based on the given pos, the players facedir, the y-offset
-- and the given walk path like "3F2L" (F-orward, L-eft, R-ight, B-ack).
function hyperloop.new_pos(pos, facedir, path, y_offs)
	if facedir == nil or pos == nil or path == nil or y_offs == nil then
		return pos
	end
	local _pos = table.copy(pos)
	_pos.y = _pos.y + y_offs
	while path:len() > 0 do
		local num = tonumber(path:sub(1,1))
		local dir = path:sub(2,2)
		path = path:sub(3)
		if dir == "B" then
			facedir = (facedir + 2) % 4
		elseif dir == "L" then
			facedir = (facedir + 3) % 4
		elseif dir == "R" then
			facedir = (facedir + 1) % 4
		end
		dir = core.facedir_to_dir(facedir)
		_pos = vector.add(_pos, vector.multiply(dir, num))
	end
	return _pos
end	

function hyperloop.is_player_around(pos)
	for _,obj in ipairs(minetest.get_objects_inside_radius(pos, 2)) do
		if obj:is_player() then
			return true
		end
	end
	return false
end

function hyperloop.get_connection_string(pos)
	local item = Stations:get(pos)
	if item then
		local tbl = {}
		for k,v in pairs(item.conn) do
			tbl[#tbl+1] = v
		end
		return table.concat(tbl, " ")
	end
	return ""
end

function hyperloop.get_station(station_pos)
	local data = Stations:get(station_pos)
	if data then
		local tStation = table.copy(data)
		tStation.pos = station_pos
		return tStation
	end
end
-- Return a copy of the station table including the station pos information
-- based on the given seat/booking/lcd position (the station position
-- is determined via meta "sStationPos").
function hyperloop.get_base_station(pos)
	local meta = M(pos)
	local sStationPos = meta:get_string("sStationPos")
	if sStationPos ~= "" then
		local station_pos = P(sStationPos)
		return hyperloop.get_station(station_pos), station_pos
	end
end
