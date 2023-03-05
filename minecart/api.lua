--[[

	Minecart
	========

	Copyright (C) 2019-2021 Joachim Stolberg

	MIT
	See license.txt for more information

]]--

--
-- API functions
--

-- 'pos' is the position of the puncher/sensor, the cart
-- position will be determined by means of 'param2' and 'radius'

-- Function returns true for all standing carts (entities and nodes)
function minecart.is_cart_available(pos, param2, radius)
	return minecart.get_nodecart_nearby(pos, param2, radius) ~= nil or
		minecart.get_entitycart_nearby(pos, param2, radius) ~= nil
end

-- Function returns true if a standing cart as node is avaliable
function minecart.is_nodecart_available(pos, param2, radius)
	return minecart.get_nodecart_nearby(pos, param2, radius) ~= nil
end

-- Function returns true if a standing cart as entity is avaliable
function minecart.is_entitycart_available(pos, param2, radius)
	return minecart.get_entitycart_nearby(pos, param2, radius) ~= nil
end

function minecart.punch_cart(pos, param2, radius, punch_dir)
	local pos2, node = minecart.get_nodecart_nearby(pos, param2, radius)
	if pos2 then
		minecart.start_nodecart(pos2, node.name, nil, punch_dir)
		return true
	end
	-- The entity check is needed for a cart with driver
	local entity = minecart.get_entitycart_nearby(pos, param2, radius)
	if entity and entity.driver then
		minecart.push_entitycart(entity, punch_dir)
		return true
	end
end

--------------------------------------------------------------------------------------------
-- API functions for other mods to add/remove carts
--------------------------------------------------------------------------------------------
function minecart.is_cart(name)
	return minecart.tNodeNames[name] ~= nil
end

-- Remove a cart, available as node
function minecart.remove_cart(pos)
	local node = minecart.get_node_lvm(pos)
	local cargo, owner, userID = minecart.remove_nodecart(pos, node)
	minecart.monitoring_remove_cart(owner, userID)
	local cartdef = {cargo = cargo, owner = owner, userID = userID}
	return cartdef
end

-- Place and start the cart
function minecart.place_and_start_cart(pos, node, cartdef, player)
	local name = minecart.get_node_lvm(pos).name
	if minecart.is_rail(pos, name) or minecart.is_cart(name) then
		local vel = {x = 0, y = 0, z = 0}
		local entity_name = minecart.tNodeNames[node.name]
		local obj = minecart.add_entitycart(pos, node.name, entity_name, vel,
			cartdef.cargo, cartdef.owner, cartdef.userID)
		local entity = obj:get_luaentity()
		minecart.monitoring_add_cart(cartdef.owner, cartdef.userID, pos, node.name, entity_name)
		if player then
			minecart.manage_attachment(player, entity, true)
		end
		minecart.start_entitycart(entity, pos, 0)
	else
		minecart.add_nodecart(pos, node.name, node.param2, cartdef.cargo, cartdef.owner, cartdef.userID, true)
	end
end
