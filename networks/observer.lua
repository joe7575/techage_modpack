--[[

	Networks
	========

	Copyright (C) 2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Node observer for debugging/testing purposes

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta
local N = tubelib2.get_node_lvm

local ObservePos = nil

function networks.register_observe_pos(pos)
	ObservePos = pos
end

function networks.node_observer(tag, pos, tbl1, tbl2)
	if ObservePos and pos and vector.equals(pos, ObservePos) then
		print("##### Node_observer (" .. (minetest.get_gametime() % 100) .. "): '" .. N(pos).name .. "' - " .. tag)
		print("tbl1", dump(tbl1), "\ntbl2", dump(tbl2))
	end
end
