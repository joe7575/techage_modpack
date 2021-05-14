--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Signal function

]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local M = minetest.get_meta

-- Used by the pairing tool
function signs_bot.get_node_type(pos)
	local node = tubelib2.get_node_lvm(pos)
	local ndef = minetest.registered_nodes[node.name]
	local is_sensor = minetest.get_item_group(node.name, "sign_bot_sensor") == 1
	if ndef then
		if ndef.signs_bot_get_signal and is_sensor then
			return "repeater"
		elseif ndef.signs_bot_get_signal then
			return "actuator"
		elseif is_sensor then
			return "sensor"
		end
	end
end

-- Used by the pairing tool
function signs_bot.get_signal(actuator_pos)
	if actuator_pos then
		local node = tubelib2.get_node_lvm(actuator_pos)
		local ndef = minetest.registered_nodes[node.name]
		if ndef	and ndef.signs_bot_get_signal then
			return ndef.signs_bot_get_signal(actuator_pos, node)
		end
	end
end
	
-- Used by the pairing tool	
function signs_bot.store_signal(sensor_pos, dest_pos, signal)
	local meta = sensor_pos and M(sensor_pos)
	if meta then
		meta:set_string("signal_pos", P2S(dest_pos))
		meta:set_string("signal_data", signal)
	end
end

--
-- Send a signal from a sensor to a actuator
--
function signs_bot.send_signal(sensor_pos)
	local meta = sensor_pos and M(sensor_pos)
	if meta then
		local dest_pos = meta:get_string("signal_pos")
		local signal = meta:get_string("signal_data")
		if dest_pos ~= "" and signal ~= "" then
			local pos = S2P(dest_pos)
			local node = tubelib2.get_node_lvm(pos)
			local ndef = minetest.registered_nodes[node.name]
			if ndef	and ndef.signs_bot_on_signal then
				ndef.signs_bot_on_signal(pos, node, signal)
			end
		end
	end
end
