--[[

	Tube Library 2
	==============

	Copyright (C) 2018-2020 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	internal1.lua
	
	First level functions behind the API

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("tubelib2")
local I,_ = dofile(MP.."/intllib.lua")

local Tube = tubelib2.Tube
local Turn180Deg = tubelib2.Turn180Deg
local Dir6dToVector = tubelib2.Dir6dToVector
local tValidNum = {[0] = true, true, true}  -- 0..2 are valid

local function get_pos(pos, dir)
	return vector.add(pos, Dir6dToVector[dir or 0])
end

local function fdir(self, player)
	local pitch = player:get_look_vertical()
	if pitch > 1.0 and self.valid_dirs[6] then -- up?
		return 6
	elseif pitch < -1.0 and self.valid_dirs[5] then -- down?
		return 5
	elseif not self.valid_dirs[1] then
		return 6
	else
		return minetest.dir_to_facedir(player:get_look_dir()) + 1
	end
end

local function get_player_data(self, placer, pointed_thing)
	if placer and pointed_thing and pointed_thing.type == "node" then
		if placer:get_player_control().sneak then
			return pointed_thing.under, fdir(self, placer)
		else
			return nil, fdir(self, placer)
		end
	end
end


-- Used to determine the node side to the tube connection.
-- Function returns the first found dir value
-- to a primary node.
-- Only used by convert.set_pairing()
function Tube:get_primary_dir(pos)
	-- Check all valid positions
	for dir = 1,6 do
		if self:is_primary_node(pos, dir) then
			return dir
		end
	end
end

-- pos/dir are the pos of the stable secondary node pointing to the head tube node.
function Tube:del_from_cache(pos, dir)
	local key = S(pos)
	if self.connCache[key] and self.connCache[key][dir] then
		local pos2 = self.connCache[key][dir].pos2
		local dir2 = self.connCache[key][dir].dir2
		local key2 = S(pos2)
		if self.connCache[key2] and self.connCache[key2][dir2] then
			self.connCache[key2][dir2] = nil
			if self.debug_info then self.debug_info(pos2, "del") end
		end
		self.connCache[key][dir] = nil
		if self.debug_info then self.debug_info(pos, "del") end
	else
		if self.debug_info then self.debug_info(pos, "noc") end
	end
end

-- pos/dir are the pos of the secondary nodes pointing to the head tube nodes.
function Tube:add_to_cache(pos1, dir1, pos2, dir2)
	local key = S(pos1)
	if not self.connCache[key] then
		self.connCache[key] = {}
	end
	self.connCache[key][dir1] = {pos2 = pos2, dir2 = dir2}
	if self.debug_info then self.debug_info(pos1, "add") end
end

-- pos/dir are the pos of the secondary nodes pointing to the head tube nodes.
function Tube:update_secondary_node(pos1, dir1, pos2, dir2)
	local node,_ = self:get_secondary_node(pos1)
	if node then
		local ndef = minetest.registered_nodes[node.name] or {}
		-- New functions
		if ndef.tubelib2_on_update2 then
			ndef.tubelib2_on_update2(pos1, dir1, self, node)
		elseif self.clbk_update_secondary_node2 then
			self.clbk_update_secondary_node2(pos1, dir1, self, node)
		-- Legacy functions
		elseif ndef.tubelib2_on_update then
			ndef.tubelib2_on_update(node, pos1, dir1, pos2, Turn180Deg[dir2])
		elseif self.clbk_update_secondary_node then
			self.clbk_update_secondary_node(node, pos1, dir1, pos2, Turn180Deg[dir2])
		end
	end
end

function Tube:infotext(pos1, pos2)
	if self.show_infotext then
		if pos1 and pos2 then
			if vector.equals(pos1, pos2) then
				M(pos1):set_string("infotext", I("Not connected!"))
			else
				M(pos1):set_string("infotext", I("Connected with ")..S(pos2))
			end
		end
	end
end

--------------------------------------------------------------------------------------
-- pairing functions
--------------------------------------------------------------------------------------

-- Pairing helper function
function Tube:store_teleport_data(pos, peer_pos)		
	local meta = M(pos)
	meta:set_string("tele_pos", S(peer_pos))
	meta:set_string("channel", nil)
	meta:set_string("formspec", nil)
	meta:set_string("infotext", I("Paired with ")..S(peer_pos))
	return meta:get_int("tube_dir")
end

-------------------------------------------------------------------------------
-- update-after/get-dir functions
-------------------------------------------------------------------------------

function Tube:update_after_place_node(pos, dirs)
	-- Check all valid positions
	local lRes= {}
	dirs = dirs or self.dirs_to_check
	for _,dir in ipairs(dirs) do
		local npos, d1, d2, num = self:add_tube_dir(pos, dir)
		if npos and self.valid_dirs[d1] and self.valid_dirs[d2] and num < 2 then
			self.clbk_after_place_tube(self:get_tube_data(npos, d1, d2, num+1))
			lRes[#lRes+1] = dir
		end
	end
	return lRes
end

function Tube:update_after_dig_node(pos, dirs)
	-- Check all valid positions
	local lRes= {}
	dirs = dirs or self.dirs_to_check
	for _,dir in ipairs(dirs) do
		local npos, d1, d2, num = self:del_tube_dir(pos, dir)
		if npos and self.valid_dirs[d1] and self.valid_dirs[d2] and tValidNum[num] then
			self.clbk_after_place_tube(self:get_tube_data(npos, d1, d2, num))
			lRes[#lRes+1] = dir
		end
	end
	return lRes
end

function Tube:update_after_place_tube(pos, placer, pointed_thing)
	local preferred_pos, fdir = get_player_data(self, placer, pointed_thing)
	local dir1, dir2, num_tubes = self:determine_tube_dirs(pos, preferred_pos, fdir)
	if dir1 == nil then
		return false
	end
	if self.valid_dirs[dir1] and self.valid_dirs[dir2] and tValidNum[num_tubes] then
		self.clbk_after_place_tube(self:get_tube_data(pos, dir1, dir2, num_tubes))
	end
	
	if num_tubes >= 1 then
		local npos, d1, d2, num = self:add_tube_dir(pos, dir1)
		if npos and self.valid_dirs[d1] and self.valid_dirs[d2] and num < 2 then
			self.clbk_after_place_tube(self:get_tube_data(npos, d1, d2, num+1))
		end
	end
	
	if num_tubes >= 2 then
		local npos, d1, d2, num = self:add_tube_dir(pos, dir2)
		if npos and self.valid_dirs[d1] and self.valid_dirs[d2] and num < 2 then
			self.clbk_after_place_tube(self:get_tube_data(npos, d1, d2, num+1))
		end
	end
	return true, dir1, dir2, num_tubes
end	
	
function Tube:update_after_dig_tube(pos, param2)
	local dir1, dir2 = self:decode_param2(pos, param2)
	
	local npos, d1, d2, num = self:del_tube_dir(pos, dir1)
	if npos and self.valid_dirs[d1] and self.valid_dirs[d2] and tValidNum[num] then
		self.clbk_after_place_tube(self:get_tube_data(npos, d1, d2, num))
	else
		dir1 = nil
	end
	
	npos, d1, d2, num = self:del_tube_dir(pos, dir2)
	if npos and self.valid_dirs[d1] and self.valid_dirs[d2] and tValidNum[num] then
		self.clbk_after_place_tube(self:get_tube_data(npos, d1, d2, num))
	else
		dir2 = nil
	end
	
	return dir1, dir2
end

-- Used by chat commands, when tubes are placed e.g. via WorldEdit
function Tube:replace_nodes(pos1, pos2, dir1, dir2)
	self.clbk_after_place_tube(self:get_tube_data(pos1, dir1, dir2, 1))
	local pos = get_pos(pos1, dir1)
	while not vector.equals(pos, pos2) do
		self.clbk_after_place_tube(self:get_tube_data(pos, dir1, dir2, 2))
		pos = get_pos(pos, dir1)
	end
	self.clbk_after_place_tube(self:get_tube_data(pos2, dir1, dir2, 1))
end	

function Tube:switch_nodes(pos, dir, state)
	pos = get_pos(pos, dir)
	local old_dir = dir
	while pos do
		local param2 = self:get_primary_node_param2(pos)
		if param2 then
			local dir1, dir2, num_conn = self:decode_param2(pos, param2)
			self.clbk_after_place_tube(self:get_tube_data(pos, dir1, dir2, num_conn, state))
			if dir1 == Turn180Deg[old_dir] then
				pos = get_pos(pos, dir2)
				old_dir = dir2
			else
				pos = get_pos(pos, dir1)
				old_dir = dir1
			end
		else
			break
		end
	end
end
