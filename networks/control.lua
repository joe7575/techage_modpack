--[[

	Networks
	========

	Copyright (C) 2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Control API to control other network nodes which have a control interface

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta
local N = tubelib2.get_node_lvm
local CTL = function(pos) return (minetest.registered_nodes[N(pos).name] or {}).control end

networks.control = {}

-- return list of nodes {pos = ..., indir = ...} of given node_type
local function get_network_table(pos, tlib2, outdir, node_type)
	local netw = networks.get_network_table(pos, tlib2, outdir)
	if netw then
		return netw[node_type] or {}
	end
	return {}
end

-------------------------------------------------------------------------------
-- For all types of nodes
-------------------------------------------------------------------------------
-- names: list of node names
-- control_callbacks = {
--	on_receive = function(pos, tlib2, topic, payload),
--	on_request = function(pos, tlib2, topic),  -- returns: response
-- }
function networks.control.register_nodes(names, control_callbacks)
	assert(type(control_callbacks) == "table")

	for _, name in ipairs(names) do
		minetest.override_item(name, {control = control_callbacks})
	end
end

-- Send a message with 'topic' string and any 'payload 'to all 'tlib2' network
-- nodes of type 'node_type'.
-- Function returns the number of nodes the message was sent to.
function networks.control.send(pos, tlib2, outdir, node_type, topic, payload)
	assert(outdir and node_type and topic)
	assert(type(topic) == "string")
	local cnt = 0
	for _,item in ipairs(get_network_table(pos, tlib2, outdir, node_type)) do
		local ctl = CTL(item.pos)
		if ctl and ctl.on_receive then
			ctl.on_receive(item.pos, tlib2, topic, payload)
			cnt = cnt + 1
		end
	end
	return cnt
end

-- Send a request with 'topic' string to all 'tlib2' network
-- nodes of type 'node_type'.
-- Function returns a list with all responses.
function networks.control.request(pos, tlib2, outdir, node_type, topic)
	assert(outdir and node_type and topic)
	assert(type(topic) == "string")
	local t = {}
	for _,item in ipairs(get_network_table(pos, tlib2, outdir, node_type)) do
		local ctl = CTL(item.pos)
		if ctl and ctl.on_request then
			t[#t + 1] = ctl.on_request(item.pos, tlib2, topic)
		end
	end
	return t
end
