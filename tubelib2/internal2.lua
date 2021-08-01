--[[

	Tube Library 2
	==============

	Copyright (C) 2018-2021 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	internal.lua

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("tubelib2")
local I,IS = dofile(MP.."/intllib.lua")


local Tube = {}

local Turn180Deg = {[0]=0,3,4,1,2,6,5}

-- To calculate param2 based on dir6d information
local DirToParam2 = {
 -- dir1 / dir2 ==> param2 / type (Angled/Straight)
	[12] = {11, "A"},
	[13] = {12, "S"},
	[14] = {14, "A"},
	[15] = { 8, "A"},
	[16] = {10, "A"},
	[23] = { 7, "A"},
	[24] = {21, "S"},
	[25] = { 3, "A"},
	[26] = {19, "A"},
	[34] = { 5, "A"},
	[35] = { 0, "A"},
	[36] = {20, "A"},
	[45] = {15, "A"},
	[46] = {13, "A"},
	[56] = { 4, "S"},
}

-- To retrieve dir6d values from the nodes param2
local Param2ToDir = {}
for k,item in pairs(DirToParam2) do
	Param2ToDir[item[1]] = k
end

-- For neighbour position calculation
local Dir6dToVector = {[0] =
	{x=0,  y=0,  z=0},
	{x=0,  y=0,  z=1},
	{x=1,  y=0,  z=0},
	{x=0,  y=0, z=-1},
	{x=-1, y=0,  z=0},
	{x=0,  y=-1, z=0},
	{x=0,  y=1,  z=0},
}

tubelib2.Tube = Tube
tubelib2.Turn180Deg = Turn180Deg
tubelib2.DirToParam2 = DirToParam2
tubelib2.Param2ToDir = Param2ToDir
tubelib2.Dir6dToVector = Dir6dToVector


--
-- Tubelib2 Methods
--

function Tube:get_node_lvm(pos)
	local node = minetest.get_node_or_nil(pos)
	if node then
		return node
	end
	local vm = minetest.get_voxel_manip()
	local MinEdge, MaxEdge = vm:read_from_map(pos, pos)
	local data = vm:get_data()
	local param2_data = vm:get_param2_data()
	local area = VoxelArea:new({MinEdge = MinEdge, MaxEdge = MaxEdge})
	local idx = area:index(pos.x, pos.y, pos.z)
	node = {
		name = minetest.get_name_from_content_id(data[idx]),
		param2 = param2_data[idx]
	}
	return node
end

-- Read param2 from a primary node at the given position.
-- If dir == nil then node_pos = pos 
-- Function returns param2, new_pos or nil
function Tube:get_primary_node_param2(pos, dir)
	local npos = vector.add(pos, Dir6dToVector[dir or 0])
	self.node = self:get_node_lvm(npos)
	if self.primary_node_names[self.node.name] then
		return self.node.param2, npos
	end
end

-- Check if node at given position is a tube node
-- If dir == nil then node_pos = pos 
-- Function returns true/false
function Tube:is_primary_node(pos, dir)
	local npos = vector.add(pos, Dir6dToVector[dir or 0])
	local node = self:get_node_lvm(npos)
	return self.primary_node_names[node.name]
end

-- Get secondary node at given position
-- If dir == nil then node_pos = pos 
-- Function returns node and new_pos or nil
function Tube:get_secondary_node(pos, dir)
	local npos = vector.add(pos, Dir6dToVector[dir or 0])
	local node = self:get_node_lvm(npos)
	if self.secondary_node_names[node.name] then
		return node, npos
	end
end

-- Get special registered nodes at given position
-- If dir == nil then node_pos = pos 
-- Function returns node and new_pos or nil
function Tube:get_special_node(pos, dir)
	local npos = vector.add(pos, Dir6dToVector[dir or 0])
	local node = self:get_node_lvm(npos)
	if self.special_node_names[node.name] then
		return node, npos
	end
end

-- Check if node at given position is a secondary node
-- If dir == nil then node_pos = pos 
-- Function returns true/false
function Tube:is_secondary_node(pos, dir)
	local npos = vector.add(pos, Dir6dToVector[dir or 0])
	local node = self:get_node_lvm(npos)
	return self.secondary_node_names[node.name]
end

-- Check if node at given position is a special node
-- If dir == nil then node_pos = pos 
-- Function returns true/false
function Tube:is_special_node(pos, dir)
	local npos = vector.add(pos, Dir6dToVector[dir or 0])
	local node = self:get_node_lvm(npos)
	return self.special_node_names[node.name]
end

-- Check if node has a connection on the given dir
function Tube:connected(pos, dir)
	return self:is_primary_node(pos, dir) or self:is_secondary_node(pos, dir)
end

function Tube:get_next_tube(pos, dir)
	local param2, npos = self:get_primary_node_param2(pos, dir)
	if param2 then
		local val = Param2ToDir[param2 % 32] or 0
		local dir1, dir2 = math.floor(val / 10), val % 10
		local num_conn = math.floor(param2 / 32) or 0
		local odir = Turn180Deg[dir]
		if odir == dir1 then
			return npos, dir2, num_conn
		elseif odir == dir2 then
			return npos, dir1, num_conn
		end
		return
	end
	return self:get_next_teleport_node(pos, dir)
end

-- Return param2 and tube type ("A"/"S")
function Tube:encode_param2(dir1, dir2, num_conn)
	if dir1 and dir2 and num_conn then
		if dir1 > dir2 then
			dir1, dir2 = dir2, dir1
		end
		local param2, _type = unpack(DirToParam2[dir1 * 10 + dir2] or {0, "S"})
		return (num_conn * 32) + param2, _type
	end
	return 0, "S"
end


-- Return dir1, dir2, num_conn
function Tube:decode_param2(pos, param2)
	local val = Param2ToDir[param2 % 32]
	if val then
		local dir1, dir2 = math.floor(val / 10), val % 10
		local num_conn = math.floor(param2 / 32)
		return dir1, dir2, num_conn
	end
end

function Tube:repair_tube(pos, dir)
	local param2, npos = self:get_primary_node_param2(pos, dir)
	if param2 then
		local dir1, dir2 = self:decode_param2(npos, param2)
		local param2, tube_type = self:encode_param2(dir1, dir2, 2)
		self.clbk_after_place_tube(npos, param2, tube_type, 2)
	end
end

-- Return node next to pos in direction 'dir'
function Tube:get_node(pos, dir)
	local npos = vector.add(pos, Dir6dToVector[dir or 0])
	return npos, self:get_node_lvm(npos)
end

-- format and return given data as table
function Tube:get_tube_data(pos, dir1, dir2, num_tubes, state)
	local param2, tube_type = self:encode_param2(dir1, dir2, num_tubes)
	return pos, param2, tube_type, num_tubes, state
end	

-- Return pos for a primary_node and true if num_conn < 2, else false
function Tube:friendly_primary_node(pos, dir)
	local param2, npos = self:get_primary_node_param2(pos, dir)
	if param2 then
		local _,_,num_conn = self:decode_param2(npos, param2)
		-- tube node with max one connection?
		return npos, (num_conn or 2) < 2
	end
end

function Tube:vector_to_dir(v)
	if v.y > 0 then
		return 6
	elseif v.y < 0 then
		return 5
	else
		return minetest.dir_to_facedir(v) + 1
	end
end

-- Check all 6 possible positions for known nodes considering preferred_pos 
-- and the players fdir and return dir1, dir2 and the number of tubes to connect to (0..2).
function Tube:determine_tube_dirs(pos, preferred_pos, fdir)
	local tbl = {}
	local allowed = table.copy(self.valid_dirs)
	
	-- If the node at players "prefered position" is a tube,
	-- then the other side of the new tube shall point to the player.
	if preferred_pos then
		local _, friendly = self:friendly_primary_node(preferred_pos)
		if friendly then
			local v = vector.direction(pos, preferred_pos)
			local dir1 = self:vector_to_dir(v)
			local dir2 = Turn180Deg[fdir]
			return dir1, dir2, 1
		end
	end
	-- Check for primary nodes (tubes)
	for dir = 1,6 do
		if allowed[dir] then
			local npos, friendly = self:friendly_primary_node(pos, dir)
			if npos then
				if not friendly then
					allowed[dir] = false
				else
					if preferred_pos and vector.equals(npos, preferred_pos) then
						preferred_pos = nil
						table.insert(tbl, 1, dir)
					else
						table.insert(tbl, dir)
					end
				end
			end
		end
	end

	-- If no tube around the pointed pos and player prefers a position,
	-- then the new tube shall point to the player.
	if #tbl == 0 and preferred_pos and fdir and allowed[Turn180Deg[fdir]] then
		tbl[1] = Turn180Deg[fdir]
	-- Already 2 dirs found?
	elseif #tbl >= 2 then
		return tbl[1], tbl[2], 2
	end
	
	-- Check for secondary nodes (chests and so on)
	for dir = 1,6 do
		if allowed[dir] then
			local node,npos = self:get_secondary_node(pos, dir)
			if npos then
				if self:is_valid_dir(node, Turn180Deg[dir]) == false then
					allowed[dir] = false
				else
					if preferred_pos and vector.equals(npos, preferred_pos) then
						preferred_pos = nil
						table.insert(tbl, 2, dir)
					else
						table.insert(tbl, dir)
					end
				end
			end
		end
	end
	
	-- player pointed to an unknown node to force the tube orientation? 
	if preferred_pos and fdir then
		if tbl[1] == Turn180Deg[fdir] and allowed[fdir] then
			tbl[2] = fdir
		elseif allowed[Turn180Deg[fdir]] then
			tbl[2] = Turn180Deg[fdir]
		end
	end
	
	-- dir1, dir2 still unknown?
	if fdir then
		if #tbl == 0 and allowed[Turn180Deg[fdir]] then
			tbl[1] = Turn180Deg[fdir]
		end
		if #tbl == 1 and allowed[Turn180Deg[tbl[1]]] then
			tbl[2] = Turn180Deg[tbl[1]]
		elseif #tbl == 1 and tbl[1] ~= Turn180Deg[fdir] and allowed[Turn180Deg[fdir]] then
			tbl[2] = Turn180Deg[fdir]
		end
	end

	if #tbl >= 2 and tbl[1] ~= tbl[2] then
		local num_tubes = (self:connected(pos, tbl[1]) and 1 or 0) + 
				(self:connected(pos, tbl[2]) and 1 or 0)
		return tbl[1], tbl[2], math.min(2, num_tubes)
	end
end

-- Determine a tube side without connection, increment the number of connections
-- and return the new data to be able to update the node: 
-- new_pos, dir1, dir2, num_connections (1, 2)
function Tube:add_tube_dir(pos, dir)
	local param2, npos = self:get_primary_node_param2(pos, dir)
	if param2 then
		local d1, d2, num = self:decode_param2(npos, param2)
		if not num then return end
		-- if invalid face, do nothing
		if self:is_valid_dir_pos(pos, dir) == false then return end
		-- not already connected to the new tube?
		dir = Turn180Deg[dir]
		if d1 ~= dir and dir ~= d2 then
			if num == 0 then
				d1 = dir
			elseif num == 1 then
				-- determine, which of d1, d2 has already a connection
				if self:connected(npos, d1) then
					d2 = dir
				else
					d1 = dir
				end
			end
		end
		return npos, d1, d2, num
	end
end

-- Decrement the number of tube connections
-- and return the new data to be able to update the node: 
-- new_pos, dir1, dir2, num_connections (0, 1)
function Tube:del_tube_dir(pos, dir)
	local param2, npos = self:get_primary_node_param2(pos, dir)
	if param2 then
		local d1, d2, num = self:decode_param2(npos, param2)
		-- check if node is connected to the given pos
		dir = Turn180Deg[dir]
		if d1 == dir or dir == d2 then
			return npos, d1, d2, math.max((num or 1) - 1, 0)
		end
	end
end
	
-- Pairing helper function
function Tube:store_teleport_data(pos, peer_pos)		
	local meta = M(pos)
	meta:set_string("tele_pos", S(peer_pos))
	meta:set_string("channel", nil)
	meta:set_string("formspec", nil)
	meta:set_string("infotext", I("Connected with ")..S(peer_pos))
	return meta:get_int("tube_dir")
end

-- Jump over the teleport nodes to the next tube node
function Tube:get_next_teleport_node(pos, dir)
	if pos then
		local npos = vector.add(pos, Dir6dToVector[dir or 0])
		if self:is_valid_dir_pos(npos, Turn180Deg[dir]) == false then
			return
		end
		local meta = M(npos)
		local s = meta:get_string("tele_pos")
		if s ~= "" then
			local tele_pos = P(s)
			local tube_dir = M(tele_pos):get_int("tube_dir")
			if tube_dir ~= 0 then
				return tele_pos, tube_dir
			end
		end
	end
end

function Tube:dbg_out()
	for pos1,item1 in pairs(self.connCache) do
		for dir1,item2 in pairs(item1) do
			print("pos1="..pos1..", dir1="..dir1..", pos2="..S(item2.pos2)..", dir2="..item2.dir2)
		end
	end
end
	
-- Walk to the end of the tube line and return pos and outdir of both head tube nodes.
-- If no tube is available, return nil
function Tube:walk_tube_line(pos, dir)
	local cnt = 0
	if dir then
		while cnt <= self.max_tube_length do
			local new_pos, new_dir, num = self:get_next_tube(pos, dir)
			if not new_pos then	break end
			if cnt > 0 and num ~= 2 and self:is_primary_node(new_pos, new_dir) then
				self:repair_tube(new_pos, new_dir)
			end
			pos, dir = new_pos, new_dir
			cnt = cnt + 1
		end
		if cnt > 0 then
			return pos, dir, cnt
		end
	end
	return table.copy(pos), dir, 0
end	
