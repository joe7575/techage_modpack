--[[

	Tube Library 2
	==============

	Copyright (C) 2017-2021 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	tube_api.lua

]]--

-- Version for compatibility checks, see readme.md/history
tubelib2.version = 2.1

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("tubelib2")
local I,_ = dofile(MP.."/intllib.lua")

-- Cardinal directions, regardless of orientation
local Dir2Str = {"north", "east", "south", "west", "down", "up"}

function tubelib2.dir_to_string(dir)
	return Dir2Str[dir]
end

-- Relative directions, dependant on orientation (param2)
local DirToSide = {"B", "R", "F", "L", "D", "U"}

function tubelib2.dir_to_side(dir, param2)
	if dir < 5 then
		dir = (((dir - 1) - (param2 % 4)) % 4) + 1
	end
	return DirToSide[dir]
end

local SideToDir = {B=1, R=2, F=3, L=4, D=5, U=6}

function tubelib2.side_to_dir(side, param2)
	local dir = SideToDir[side]
	if dir < 5 then
		dir = (((dir - 1) + (param2 % 4)) % 4) + 1
	end
	return dir
end


local function Tbl(list)
	local tbl = {}
	for _,item in ipairs(list) do
		tbl[item] = true
	end
	return tbl
end

-- Tubelib2 Class
local Tube = tubelib2.Tube
local Turn180Deg = tubelib2.Turn180Deg
local Dir6dToVector = tubelib2.Dir6dToVector


local function get_pos(pos, dir)
	return vector.add(pos, Dir6dToVector[dir or 0])
end
tubelib2.get_pos = get_pos

function tubelib2.get_node_lvm(pos)
	local node = minetest.get_node_or_nil(pos)
	if node then
		return node
	end
	local vm = minetest.get_voxel_manip()
	local MinEdge, MaxEdge = vm:read_from_map(pos, pos)
	local data = vm:get_data()
	local param2_data = vm:get_param2_data()
	local area = VoxelArea:new({MinEdge = MinEdge, MaxEdge = MaxEdge})
	local idx = area:indexp(pos)
	node = {
		name = minetest.get_name_from_content_id(data[idx]),
		param2 = param2_data[idx]
	}
	return node
end

local function update1(self, pos, dir)
	local fpos,fdir = self:walk_tube_line(pos, dir)
	self:infotext(get_pos(pos, dir), fpos)
	self:infotext(fpos, get_pos(pos, dir))
	-- Translate pos/dir pointing to the secondary node into 
	-- spos/sdir of the secondary node pointing to the tube.
	if fpos and fdir then
		local spos, sdir = get_pos(fpos,fdir), Turn180Deg[fdir]
		self:del_from_cache(spos, sdir)
		self:add_to_cache(pos, dir, spos, sdir)
		self:add_to_cache(spos, sdir, pos, dir)
		self:update_secondary_node(pos, dir, spos, sdir)
		self:update_secondary_node(spos, sdir, pos, dir)
	end
end

local function update2(self, pos1, dir1, pos2, dir2)
	local fpos1,fdir1,cnt1 = self:walk_tube_line(pos1, dir1)
	local fpos2,fdir2,cnt2 = self:walk_tube_line(pos2, dir2)
	if cnt1 + cnt2 >= self.max_tube_length then -- line to long?
		-- reset next tube(s) to head tube(s) again
		local param2 = self:encode_param2(dir1, dir2, 2)
		self:update_after_dig_tube(pos1, param2)
		M(get_pos(pos1, dir1)):set_string("infotext", I("Maximum length reached!"))
		M(get_pos(pos1, dir2)):set_string("infotext", I("Maximum length reached!"))
		return false 
	end
	self:infotext(fpos1, fpos2)
	self:infotext(fpos2, fpos1)
	-- Translate fpos/fdir pointing to the secondary node into 
	-- spos/sdir of the secondary node pointing to the tube.
	local spos1, sdir1 = get_pos(fpos1,fdir1), Turn180Deg[fdir1]
	local spos2, sdir2 = get_pos(fpos2,fdir2), Turn180Deg[fdir2]
	self:del_from_cache(spos1, sdir1)
	self:del_from_cache(spos2, sdir2)
	self:add_to_cache(spos1, sdir1, spos2, sdir2)
	self:add_to_cache(spos2, sdir2, spos1, sdir1)
	self:update_secondary_node(spos1, sdir1, spos2, sdir2)
	self:update_secondary_node(spos2, sdir2, spos1, sdir1)
	return true
end

local function update3(self, pos, dir1, dir2)
	if pos and dir1 and dir2 then
		local fpos1,fdir1,cnt1 = self:walk_tube_line(pos, dir1)
		local fpos2,fdir2,cnt2 = self:walk_tube_line(pos, dir2)
		self:infotext(fpos1, fpos2)
		self:infotext(fpos2, fpos1)
		-- Translate fpos/fdir pointing to the secondary node into 
		-- spos/sdir of the secondary node pointing to the tube.
		if fpos1 and fpos2 and fdir1 and fdir2 then
			local spos1, sdir1 = get_pos(fpos1,fdir1), Turn180Deg[fdir1]
			local spos2, sdir2 = get_pos(fpos2,fdir2), Turn180Deg[fdir2]
			self:del_from_cache(spos1, sdir1)
			self:del_from_cache(spos2, sdir2)
			self:add_to_cache(spos1, sdir1, spos2, sdir2)
			self:add_to_cache(spos2, sdir2, spos1, sdir1)
			self:update_secondary_node(spos1, sdir1, spos2, sdir2)
			self:update_secondary_node(spos2, sdir2, spos1, sdir1)
			return dir1, dir2, fpos1, fpos2, fdir1, fdir2, cnt1 or 0, cnt2 or 0
		end
		return dir1, dir2, pos, pos, dir1, dir2, cnt1 or 0, cnt2 or 0
	end
end

local function update_secondary_nodes_after_node_placed(self, pos, dirs)
	dirs = dirs or self.dirs_to_check
	-- check surrounding for secondary nodes
	for _,dir in ipairs(dirs) do
		local tmp, npos
		if self.force_to_use_tubes then
			tmp, npos = self:get_special_node(pos, dir)
		else
			tmp, npos = self:get_secondary_node(pos, dir) 
		end
		if npos then
			self:update_secondary_node(npos, Turn180Deg[dir], pos, dir)
			self:update_secondary_node(pos, dir, npos, Turn180Deg[dir])
		end
	end
end

local function update_secondary_nodes_after_node_dug(self, pos, dirs)
	dirs = dirs or self.dirs_to_check
	-- check surrounding for secondary nodes
	for _,dir in ipairs(dirs) do
		local tmp, npos
		if self.force_to_use_tubes then
			tmp, npos = self:get_special_node(pos, dir)
		else
			tmp, npos = self:get_secondary_node(pos, dir) 
		end
		if npos then
			self:del_from_cache(npos, Turn180Deg[dir])
			self:del_from_cache(pos, dir)
			self:update_secondary_node(npos, Turn180Deg[dir])
			self:update_secondary_node(pos, dir)
		end
	end
end

--
-- API Functions
--

function Tube:new(attr)
	local o = {
		dirs_to_check = attr.dirs_to_check or {1,2,3,4,5,6},
		max_tube_length = attr.max_tube_length or 1000, 
		primary_node_names = Tbl(attr.primary_node_names or {}), 
		secondary_node_names = Tbl(attr.secondary_node_names or {}),
		valid_node_contact_sides = {},
		show_infotext = attr.show_infotext or false,
		force_to_use_tubes = attr.force_to_use_tubes or false, 
		clbk_after_place_tube = attr.after_place_tube,
		tube_type = attr.tube_type or "unknown",
		pairingList = {}, -- teleporting nodes
		connCache = {}, -- connection cache {pos1 = {dir1 = {pos2 = pos2, dir2 = dir2},...}
		special_node_names = {}, -- use add_special_node_names() to register nodes
		debug_info = attr.debug_info,  -- debug_info(pos, text) 
	}
	o.valid_dirs = Tbl(o.dirs_to_check)
	setmetatable(o, self)
	self.__index = self
	if attr.valid_node_contact_sides then
		o:set_valid_sides_multiple(attr.valid_node_contact_sides)
	end
	return o
end

-- Register (foreign) tubelib compatible nodes.
function Tube:add_secondary_node_names(names)
	for _,name in ipairs(names) do
		self.secondary_node_names[name] = true
	end
end


-- Defaults for valid sides configuration
local function invert_booleans(tab)
	local inversion = {}
	for key, value in pairs(tab) do
		inversion[key] = not value
	end
	return inversion
end
local valid_sides_default_true = Tbl(DirToSide)
local valid_sides_default_false = invert_booleans(valid_sides_default_true)
local function complete_valid_sides(valid_sides, existing_defaults)
	local valid_sides_complete = {}
	for side, default_value in pairs(existing_defaults) do
		local new_value = valid_sides[side]
		if new_value == nil then
			valid_sides_complete[side] = default_value
		else
			valid_sides_complete[side] = new_value
		end
	end
	return valid_sides_complete
end

-- Set sides which are valid
-- with a table of name = valid_sides pairs
function Tube:set_valid_sides_multiple(names)
	for name, valid_sides in pairs(names) do
		self:set_valid_sides(name, valid_sides)
	end
end

-- Set sides which are invalid
-- with a table of name = valid_sides pairs
function Tube:set_invalid_sides_multiple(names)
	for name, invalid_sides in pairs(names) do
		self:set_invalid_sides(name, invalid_sides)
	end
end

-- Set sides which are valid
-- will assume all sides not given are invalid
-- Only sets new sides, existing sides will remain
function Tube:set_valid_sides(name, valid_sides)
	local existing_defaults = self.valid_node_contact_sides[name] or valid_sides_default_false
	self.valid_node_contact_sides[name] = complete_valid_sides(Tbl(valid_sides), existing_defaults)
end

-- Set sides which are invalid
-- will assume all sides not given are valid
-- Only sets new sides, existing sides will remain
function Tube:set_invalid_sides(name, invalid_sides)
	local existing_defaults = self.valid_node_contact_sides[name] or valid_sides_default_true
	self.valid_node_contact_sides[name] = complete_valid_sides(invert_booleans(Tbl(invalid_sides)), existing_defaults)
end

-- Checks the list of valid node connection sides to
-- see if a given side can be connected to
function Tube:is_valid_side(name, side)
	local valid_sides = self.valid_node_contact_sides[name]
	if valid_sides then
		return valid_sides[side] or false
	end
end

-- Checks if a particular node can be connected to
-- from a particular direction, taking into account orientation
function Tube:is_valid_dir(node, dir)
	if node and dir ~= nil and self.valid_node_contact_sides[node.name] then
		local side = tubelib2.dir_to_side(dir, node.param2)
		return self:is_valid_side(node.name, side)
	end
end

-- Checks if a node at a particular position can be connected to
-- from a particular direction, taking into account orientation
function Tube:is_valid_dir_pos(pos, dir)
	local node = self:get_node_lvm(pos)
	return self:is_valid_dir(node, dir)
end

-- Register further nodes, which should be updated after
-- a node/tube is placed/dug
function Tube:add_special_node_names(names)
	for _,name in ipairs(names) do
		self.special_node_names[name] = true
	end
end

-- Called for each connected node when the tube connection has been changed.
-- func(node, pos, out_dir, peer_pos, peer_in_dir)
function Tube:register_on_tube_update(update_secondary_node)
		self.clbk_update_secondary_node = update_secondary_node
end

-- Called for each connected node when the tube connection has been changed.
-- func(pos1, out_dir, self, node)
function Tube:register_on_tube_update2(update_secondary_node2)
		self.clbk_update_secondary_node2 = update_secondary_node2
end

function Tube:get_pos(pos, dir)
	return vector.add(pos, Dir6dToVector[dir or 0])
end

-- To be called after a secondary node is placed.
-- dirs is a list with valid dirs, like: {1,2,3,4}
function Tube:after_place_node(pos, dirs)
	-- [s][f]----[n] x
	-- s..secondary, f..far, n..near, x..node to be placed
	for _,dir in ipairs(self:update_after_place_node(pos, dirs)) do
		if pos and dir then
			update1(self, pos, dir)
		end
	end
	update_secondary_nodes_after_node_placed(self, pos, dirs)
end

-- To be called after a tube/primary node is placed.
-- Returns false, if placing is not allowed
function Tube:after_place_tube(pos, placer, pointed_thing)
	-- [s1][f1]----[n1] x [n2]-----[f2][s2]
	-- s..secondary, f..far, n..near, x..node to be placed
	local res,dir1,dir2 = self:update_after_place_tube(pos, placer, pointed_thing)
	if res then  -- node placed?
		return update2(self, pos, dir1, pos, dir2)
	end
	return res
end

function Tube:after_dig_node(pos, dirs)
	-- [s][f]----[n] x
	-- s..secondary, f..far, n..near, x..node to be removed
	for _,dir in ipairs(self:update_after_dig_node(pos, dirs)) do
		update1(self, pos, dir)
	end
	update_secondary_nodes_after_node_dug(self, pos, dirs)
end

-- To be called after a tube/primary node is removed.
function Tube:after_dig_tube(pos, oldnode)
	-- [s1][f1]----[n1] x [n2]-----[f2][s2]
	-- s..secondary, f..far, n..near, x..node to be removed
	
	-- update tubes
	if oldnode and oldnode.param2 then
		local dir1, dir2 = self:update_after_dig_tube(pos, oldnode.param2)
		if dir1 then update1(self, pos, dir1) end
		if dir2 then update1(self, pos, dir2) end
		
		-- Update secondary nodes, if right beside
		dir1, dir2 = self:decode_param2(pos, oldnode.param2)
		local npos1,ndir1 = get_pos(pos, dir1),Turn180Deg[dir1]
		local npos2,ndir2 = get_pos(pos, dir2),Turn180Deg[dir2]
		self:del_from_cache(npos1,ndir1)
		self:update_secondary_node(npos1,ndir1)
		self:update_secondary_node(npos2,ndir2)
	end
end


-- From source node to destination node via tubes.
-- pos is the source node position, dir the output dir
-- The returned pos is the destination position, dir
-- is the direction into the destination node.
function Tube:get_connected_node_pos(pos, dir)
	local key = S(pos)
	if self.connCache[key] and self.connCache[key][dir] then
		local item = self.connCache[key][dir]
		return item.pos2, Turn180Deg[item.dir2]
	end	
	local fpos,fdir = self:walk_tube_line(pos, dir)
	local spos = get_pos(fpos,fdir)
	self:add_to_cache(pos, dir, spos, Turn180Deg[fdir])
	self:add_to_cache(spos, Turn180Deg[fdir], pos, dir)
	return spos, fdir
end

-- Check if node at given position is a tubelib2 compatible node,
-- able to receive and/or deliver items.
-- If dir == nil then node_pos = pos 
-- Function returns the result (true/false), new pos, and the node
function Tube:compatible_node(pos, dir)
	local npos = vector.add(pos, Dir6dToVector[dir or 0])
	local node = self:get_node_lvm(npos)
	return self.secondary_node_names[node.name], npos, node
end


-- To be called from a repair tool in the case of a "WorldEdit" or with
-- legacy nodes corrupted tube line.
function Tube:tool_repair_tube(pos)
	local param2  = self:get_primary_node_param2(pos)
	if param2 then
		local dir1, dir2 = self:decode_param2(pos, param2)
		return update3(self, pos, dir1, dir2)
	end
end

-- To be called from a repair tool in the case, tube nodes are "unbreakable".
function Tube:tool_remove_tube(pos, sound)
	if self:is_primary_node(pos) then
		local _,node = self:get_node(pos)
		minetest.sound_play({name=sound},{
				pos=pos,
				gain=1,
				max_hear_distance=5,
				loop=false})
		minetest.remove_node(pos)
		self:after_dig_tube(pos, node)
		return true
	end
	return false
end


function Tube:prepare_pairing(pos, tube_dir, sFormspec)
	local meta = M(pos)
	if meta:get_int("tube_dir") ~= 0 then -- already prepared?
		-- update tube_dir only
		meta:set_int("tube_dir", tube_dir)
	elseif tube_dir then
		meta:set_int("tube_dir", tube_dir)
		meta:set_string("channel", nil)
		meta:set_string("infotext", I("Pairing is missing"))
		meta:set_string("formspec", sFormspec)
	else
		meta:set_string("infotext", I("Connection to a tube is missing!"))
	end
end

function Tube:pairing(pos, channel)
	if self.pairingList[channel] and not vector.equals(pos, self.pairingList[channel]) then
		-- store peer position on both nodes
		local peer_pos = self.pairingList[channel]
		local tube_dir1 = self:store_teleport_data(pos, peer_pos)
		local tube_dir2 = self:store_teleport_data(peer_pos, pos)
		update2(self, pos, tube_dir1, peer_pos, tube_dir2)
		self.pairingList[channel] = nil
		return true
	else
		self.pairingList[channel] = pos
		local meta = M(pos)
		meta:set_string("channel", channel)
		meta:set_string("infotext", I("Pairing is missing").." ("..channel..")")
		return false
	end
end

function Tube:stop_pairing(pos, oldmetadata, sFormspec)
	-- unpair peer node
	if oldmetadata and oldmetadata.fields then
		if oldmetadata.fields.tele_pos then
			local tele_pos = minetest.string_to_pos(oldmetadata.fields.tele_pos)
			local peer_meta = M(tele_pos)
			if peer_meta then
				self:after_dig_node(tele_pos, {peer_meta:get_int("tube_dir")})
				peer_meta:set_string("channel", nil)
				peer_meta:set_string("tele_pos", nil)
				peer_meta:set_string("formspec", sFormspec)
				peer_meta:set_string("infotext", I("Pairing is missing"))
			end
		elseif oldmetadata.fields.channel then
			self.pairingList[oldmetadata.fields.channel] = nil
		end
	end
end


-- Used by chat commands, when tubes are placed e.g. via WorldEdit
function Tube:replace_tube_line(pos1, pos2)
	if pos1 and pos2 and not vector.equals(pos1, pos2) then
		local check = (((pos1.x == pos2.x) and 1) or 0) + 
				(((pos1.y == pos2.y) and 1) or 0) + 
				(((pos1.z == pos2.z) and 1) or 0)
		if check == 2 then
			local v = vector.direction(pos1, pos2)
			local dir1 = self:vector_to_dir(v)
			local dir2 = Turn180Deg[dir1]
		
			self:replace_nodes(pos1, pos2, dir1, dir2)
			update3(self, pos1, dir1, dir2)
		end
	end
end

-- Used to change the tube nodes texture (e.g. on/off state)
function Tube:switch_tube_line(pos, dir, state)
	self:switch_nodes(pos, dir, state)
end

-- Generator function to iterate over a tube line
-- Returns for each tube: i , pos, node
function Tube:get_tube_line(pos, dir)
	if pos and dir then
		self.ref = {pos = pos, dir = dir}
		return function(self, i)
			if i < self.max_tube_length then
				local new_pos, new_dir, num = self:get_next_tube(self.ref.pos, self.ref.dir)
				if new_pos then
					self.ref.pos, self.ref.dir = new_pos, new_dir
					i = i + 1
					return i, self.ref.pos, self.node
				end
			end
		end, self, 0
	end
end	
