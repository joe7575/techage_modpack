--[[

	Networks
	========

	Copyright (C) 2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta
local N = tubelib2.get_node_lvm

local hidden_message = ""
local tFillingMaterial = {}

-- handle old techage names
local function legacy_names(meta)
	if meta:contains("techage_hidden_nodename") then
		meta:set_string("netw_name", meta:get_string("techage_hidden_nodename"))
		meta:set_string("techage_hidden_nodename", "")
	end
	if meta:contains("tl2_param2") then
		meta:set_int("netw_param2", meta:get_int("tl2_param2"))
		meta:set_string("tl2_param2", "")
	end
end

-------------------------------------------------------------------------------
-- API
-------------------------------------------------------------------------------
function networks.hidden_name(pos)
	local meta = M(pos)
	legacy_names(meta)
	if meta:contains("netw_name") then
		return meta:get_string("netw_name")
	end
end

function networks.get_nodename(pos)
	local meta = M(pos)
	legacy_names(meta)
	if meta:contains("netw_name") then
		return meta:get_string("netw_name")
	end
	return tubelib2.get_node_lvm(pos).name
end

function networks.get_node(pos)
	local meta = M(pos)
	legacy_names(meta)
	if meta:contains("netw_name") then
		return {name = meta:get_string("netw_name"), param2 = meta:get_int("netw_param2")}
	end
	return tubelib2.get_node_lvm(pos)
end

local get_node = networks.get_node
local get_nodename = networks.get_nodename

-- Override methods of tubelib2 to store tube/cable info as metadata,
-- used for hidden cables/tubes/junctions/switches.
function networks.use_metadata(tlib2)
	tlib2.get_primary_node_param2 = function(self, pos, dir)
		local npos = vector.add(pos, tubelib2.Dir6dToVector[dir or 0])
		if self.primary_node_names[get_nodename(npos)] then
			local meta = M(npos)
			return meta:get_int("netw_param2"), npos
		end
	end
	tlib2.is_primary_node = function(self, pos, dir)
		local npos = vector.add(pos, tubelib2.Dir6dToVector[dir or 0])
		return self.primary_node_names[get_nodename(npos)] ~= nil
	end
	tlib2.get_secondary_node = function(self, pos, dir)
		local npos = vector.add(pos, tubelib2.Dir6dToVector[dir or 0])
		local node = get_node(npos)
		if self.secondary_node_names[node.name] then
			return node, npos, true
		end
	end
	tlib2.is_secondary_node = function(self, pos, dir)
		local npos = vector.add(pos, tubelib2.Dir6dToVector[dir or 0])
		local name = get_nodename(npos)
		return self.secondary_node_names[name] ~= nil
	end
end

function networks.hide_node(pos, node, placer)
	local inv = placer:get_inventory()
	local stack = inv:get_stack("main", 1)
	local taken = stack:take_item(1)

	if taken:get_count() == 1 and tFillingMaterial[taken:get_name()] then
		local meta = M(pos)
		meta:set_string("netw_name", node.name)
		local param2 = 0
		local ndef = minetest.registered_nodes[taken:get_name()]
		if ndef.paramtype2 and ndef.paramtype2 == "facedir" then
			param2 = minetest.dir_to_facedir(placer:get_look_dir(), true)
		end
		minetest.swap_node(pos, {name = taken:get_name(), param2 = param2})
		inv:set_stack("main", 1, stack)
		return true
	end
end

function networks.open_node(pos, node, placer)
	local name = networks.hidden_name(pos)
	local param2
	if M(pos):get_int("netw_param2") ~= 0 then
		param2 = M(pos):get_int("netw_param2")
	else
		param2 = M(pos):get_int("netw_param2_copy")
	end
	minetest.swap_node(pos, {name = name, param2 = param2 % 32 + M(pos):get_int("netw_color_param2")})
	local meta = M(pos)
	meta:set_string("netw_name", "")
	local inv = placer:get_inventory()
	inv:add_item("main", ItemStack(node.name))
	return true
end

-------------------------------------------------------------------------------
-- Patch registered nodes
-------------------------------------------------------------------------------
function networks.register_hidden_message(msg)
	hidden_message = msg
end

local function get_new_can_dig(old_can_dig)
	return function(pos, player, ...)
		if networks.hidden_name(pos) then
			if player and player.get_player_name then
				minetest.chat_send_player(player:get_player_name(), hidden_message)
			end
			return false
		end
		if old_can_dig then
			return old_can_dig(pos, player, ...)
		else
			return true
		end
	end
end

-- Register item names to be used as filling material to hide tubes/cables
function networks.register_filling_items(names)
	for _, name in ipairs(names) do
		tFillingMaterial[name] = true
		-- Change can_dig for registered filling materials.
		local ndef = minetest.registered_nodes[name]
		if ndef then
			local old_can_dig = ndef.can_dig
			minetest.override_item(ndef.name, {
				can_dig = get_new_can_dig(old_can_dig)
			})
		end
	end
end

