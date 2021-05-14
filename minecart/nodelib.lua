--[[

	Minecart
	========

	Copyright (C) 2019-2021 Joachim Stolberg

	MIT
	See license.txt for more information
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = minecart.S
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos

function minecart.get_nodecart_nearby(pos, param2, radius)	
	local pos2 = param2 and vector.add(pos, minecart.param2_to_dir(param2)) or pos
	local pos3 = minetest.find_node_near(pos2, radius or 0.5, minecart.lCartNodeNames, true)
	if pos3 then
		return pos3, minetest.get_node(pos3)
	end
end

-- Convert node to entity and start cart
function minecart.start_nodecart(pos, node_name, puncher, punch_dir)
	local owner = M(pos):get_string("owner")
	local userID = M(pos):get_int("userID")
	-- check if valid cart
	if not minecart.monitoring_valid_cart(owner, userID, pos, node_name) then
		--print("invalid cart", owner, userID, P2S(pos), node_name)
		M(pos):set_string("infotext", 
				minetest.get_color_escape_sequence("#FFFF00") .. owner .. ": 0")
		return
	end
	-- Only the owner or a noplayer can start the cart, but owner has to be online
	if minecart.is_owner(puncher, owner) and minetest.get_player_by_name(owner) and
			userID ~= 0 then
		local entity_name = minecart.tNodeNames[node_name]
		local obj = minecart.node_to_entity(pos, node_name, entity_name)
		if obj then
			local entity = obj:get_luaentity()
			if puncher then
				local yaw = puncher:get_look_horizontal()
				entity.object:set_rotation({x = 0, y = yaw, z = 0})
			elseif punch_dir then
				local yaw = minetest.dir_to_yaw(punch_dir)
				entity.object:set_rotation({x = 0, y = yaw, z = 0})
			end
			 minecart.start_entitycart(entity, pos)
		end
	end
end

function minecart.show_formspec(pos, clicker)
	local owner = M(pos):get_string("owner")
	if minecart.is_owner(clicker, owner) then
		clicker:get_meta():set_string("cart_pos", P2S(pos))
		minetest.show_formspec(owner, "minecart:userID_node",
			"size[4,3]" ..
			"label[0,0;" .. S("Enter cart number") .. ":]" ..
			"field[1,1;3,1;userID;;]" ..
			"button_exit[1,2;2,1;exit;" .. S("Save") .. "]")	
	end
end

-- Player places the node
function minecart.on_nodecart_place(itemstack, placer, pointed_thing)
	local node_name = itemstack:get_name()
	local param2 = minetest.dir_to_facedir(placer:get_look_dir())
	local owner = placer:get_player_name()
	
	-- Add node
	if minecart.is_rail(pointed_thing.under) then
		minecart.add_nodecart(pointed_thing.under, node_name, param2, {}, owner, 0)
		placer:get_meta():set_string("cart_pos", P2S(pointed_thing.under))
		minecart.show_formspec(pointed_thing.under, placer)
	elseif minecart.is_rail(pointed_thing.above) then
		minecart.add_nodecart(pointed_thing.above, node_name, param2, {}, owner, 0)
		placer:get_meta():set_string("cart_pos", P2S(pointed_thing.above))
		minecart.show_formspec(pointed_thing.above, placer)
	else
		return itemstack
	end

	minetest.sound_play({name = "default_place_node_metal", gain = 0.5},
		{pos = pointed_thing.above})

	if not (creative and creative.is_enabled_for
			and creative.is_enabled_for(placer:get_player_name())) then
		itemstack:take_item()
	end
	
	return itemstack
end

-- Start the node cart (or dig by shift+leftclick)
function minecart.on_nodecart_punch(pos, node, puncher, pointed_thing)
	--print("on_nodecart_punch")
	local owner = M(pos):get_string("owner")
	local userID = M(pos):get_int("userID")
	if minecart.is_owner(puncher, owner) then
		if puncher:get_player_control().sneak then
			local ndef = minetest.registered_nodes[node.name]
			if not ndef.has_cargo or not ndef.has_cargo(pos) then
				minecart.remove_nodecart(pos)
				minecart.add_node_to_player_inventory(pos, puncher, node.name)
				minecart.monitoring_remove_cart(owner, userID)
			end
		else
			minecart.start_nodecart(pos, node.name, puncher)
		end
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "minecart:userID_node" then
		if fields.exit or fields.key_enter == "true" then
			local cart_pos = S2P(player:get_meta():get_string("cart_pos"))
			local owner = M(cart_pos):get_string("owner")
			if minecart.is_owner(player, owner) then
				local userID = tonumber(fields.userID) or 0
				if minecart.userID_available(owner, userID) then
					M(cart_pos):set_int("userID", userID)
					M(cart_pos):set_string("infotext", 
							minetest.get_color_escape_sequence("#FFFF00") ..
							player:get_player_name() .. ": " .. userID)
					local node = minetest.get_node(cart_pos)
					local entity_name = minecart.tNodeNames[node.name]
					minecart.monitoring_add_cart(owner, userID, cart_pos, node.name, entity_name)
				end
			end
		end
		return true
	end
    return false
end)
