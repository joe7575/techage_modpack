--[[

	Networks
	========

	Copyright (C) 2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

]]--

local SideToDir = {B=1, R=2, F=3, L=4, D=5, U=6}
local tubelib2_dir_to_side = tubelib2.dir_to_side

local function bit(p)
  return 2 ^ (p - 1)  -- 1-based indexing
end

-- Typical call:  if hasbit(x, bit(3)) then ...
local function hasbit(x, p)
  return x % (p + p) >= p
end

local function setbit(x, p)
  return hasbit(x, p) and x or x + p
end

local function get_node_box(val, size, boxes)
	local fixed = {{-size, -size, -size, size, size, size}}
	for i = 1,6 do
		if hasbit(val, bit(i)) then
			for _,box in ipairs(boxes[i]) do
				table.insert(fixed, box)
			end
		end
	end
	return {
		type = "fixed",
		fixed = fixed,
	}
end

-- 'size' is the size of the junction cube without any connection, e.g. 1/8
-- 'boxes' is a table with 6 table elements for the 6 possible connection arms
-- 'tlib2' is the tubelib2 instance
-- 'node' is the node definition with tiles, callback functions, and so on
-- 'index' number for the inventory node (default 0)
function networks.register_junction(name, size, boxes, tlib2, node, index)
	local names = {}
	for idx = 0,63 do
		local ndef = table.copy(node)
		if idx == (index or 0) then
			ndef.groups.not_in_creative_inventory = 0
		else
			ndef.groups.not_in_creative_inventory = 1
		end
		ndef.drawtype = "nodebox"
		ndef.paramtype = "light"
		ndef.sunlight_propagates = true
		ndef.node_box = get_node_box(idx, size, boxes)
		ndef.paramtype2 = "facedir"
		ndef.on_rotate = screwdriver.disallow
		ndef.drop = name..(index or "0")
		minetest.register_node(name..idx, ndef)
		names[#names + 1] = name..idx
	end
	return names
end

function networks.junction_type(pos, network, default_side, param2)
	local connected = function(self, pos, dir)
		if network:is_primary_node(pos, dir) then
			local param2, npos = self:get_primary_node_param2(pos, dir)
			if param2 then
				local d1, d2, _ = self:decode_param2(npos, param2)
				dir = networks.Flip[dir]
				return d1 == dir or dir == d2
		    end
		end
	end

	local val = 0
	if default_side then
		val = setbit(val, bit(SideToDir[default_side]))
	end
	for dir = 1,6 do
		local dir2 = SideToDir[tubelib2_dir_to_side(dir, param2 or 0)]
		if network.force_to_use_tubes then
			if connected(network, pos, dir) then
				val = setbit(val, bit(dir2))
			elseif network:is_special_node(pos, dir) then
				val = setbit(val, bit(dir2))
			end
		else
			if connected(network, pos, dir) then
				val = setbit(val, bit(dir2))
			elseif network:is_secondary_node(pos, dir) then
				local node = network:get_secondary_node(pos, dir)
				if network:is_valid_dir(node, networks.Flip[dir]) then
					val = setbit(val, bit(dir2))
				end
			end
		end
	end
	return val
end

