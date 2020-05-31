--[[

	Minecart
	========

	Copyright (C) 2019-2020 Joachim Stolberg

	MIT
	See license.txt for more information
	
	Cart API for external cart definitions on a node based model
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = minecart.S
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos

-- register cart here, because entity is already registered
minecart.register_cart_names("minecart:cart", "minecart:cart")

function minecart.register_cart_entity(entity_name, node_name, entity_def)
	entity_def.velocity = {x=0, y=0, z=0} -- only used on punch
	entity_def.old_dir = {x=1, y=0, z=0} -- random value to start the cart on punch
	entity_def.old_pos = nil
	entity_def.old_switch = 0
	entity_def.node_name = node_name
	minetest.register_entity(entity_name, entity_def)
	-- register node for punching
	minecart.register_cart_names(node_name, entity_name)
end

local function switch_to_node(pos, node_name, owner, param2, cargo)
	local node = minetest.get_node(pos)
	local rail = node.name
	local ndef = minetest.registered_nodes[node_name]
	if ndef then
		node.name = node_name
		node.param2 = param2
		minetest.add_node(pos, node)
		M(pos):set_string("removed_rail", rail)
		M(pos):set_string("owner", owner)
		if ndef.after_place_node then
			ndef.after_place_node(pos)
		end
		if cargo and ndef.set_cargo then
			ndef.set_cargo(pos, cargo)
		end
	end
	
end

function minecart.node_on_place(itemstack, placer, pointed_thing, node_name)
	local under = pointed_thing.under
	local node = minetest.get_node(under)
	local udef = minetest.registered_nodes[node.name]
	if udef and udef.on_rightclick and
			not (placer and placer:is_player() and
			placer:get_player_control().sneak) then
		return udef.on_rightclick(under, node, placer, itemstack,
			pointed_thing) or itemstack
	end

	if not pointed_thing.type == "node" then
		return
	end
	local owner = placer:get_player_name()
	local param2 = minetest.dir_to_facedir(placer:get_look_dir())
	if carts:is_rail(pointed_thing.under) then
		switch_to_node(pointed_thing.under, node_name, owner, param2)
	elseif carts:is_rail(pointed_thing.above) then
		switch_to_node(pointed_thing.above, node_name, owner, param2)
	else
		return
	end

	minetest.sound_play({name = "default_place_node_metal", gain = 0.5},
		{pos = pointed_thing.above})

	if not (creative and creative.is_enabled_for
			and creative.is_enabled_for(placer:get_player_name())) then
		itemstack:take_item()
	end
	return itemstack
end

function minecart.node_on_punch(pos, node, puncher, pointed_thing, entity_name, dir)
	local ndef = minetest.registered_nodes[node.name]
	local cargo = {}
	-- Player digs cart by sneak-punch
	if puncher and puncher:get_player_control().sneak then
		-- Pick up cart
		if ndef.can_dig and ndef.can_dig(pos, puncher) then
			local inv = puncher:get_inventory()
			if not (creative and creative.is_enabled_for
					and creative.is_enabled_for(puncher:get_player_name()))
					or not inv:contains_item("main", node.name) then
				local leftover = inv:add_item("main", node.name)
				-- If no room in inventory add a replacement cart to the world
				if not leftover:is_empty() then
					minetest.add_item(pos, leftover)
				end
			end
			node.name = M(pos):get_string("removed_rail")
			if node.name == "" then
				node.name = "carts:rail"
			end
			minetest.remove_node(pos)
			minetest.add_node(pos, node)
		end
		return
	end
	-- start cart
	node.name = M(pos):get_string("removed_rail")
	if node.name ~= "" then
		if ndef.get_cargo then
			cargo = ndef.get_cargo(pos)
		end
		minetest.add_node(pos, node)
		local obj = minetest.add_entity(pos, entity_name)
		local owner = puncher and puncher:get_player_name()
		minecart.add_cart_to_monitoring(obj, owner, cargo)		
		obj:punch(puncher or obj, 1, {
				full_punch_interval = 1.0,
				damage_groups = {fleshy = 1},
			}, dir)
	end
end

function minecart:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
end


function minecart:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	--print("on_punch", direction)
	local pos = self.object:get_pos()
	local vel = self.object:get_velocity()
	local stopped = vector.equals(vel, {x=0, y=0, z=0})
	
	-- running carts can't be punched
	if not stopped then
		return
	end
	
	if not self.railtype then
		local node = minetest.get_node(pos).name
		self.railtype = minetest.get_item_group(node, "connect_to_raillike")
	end
	
	-- Punched by non-authorized player
	if puncher and self.owner and self.owner ~= puncher:get_player_name() 
			and not minetest.check_player_privs(puncher:get_player_name(), "minecart") then
		return
	end
	
	-- Punched by non-player
	if not puncher or not puncher:is_player() then
		local cart_dir = carts:get_rail_direction(pos, direction, nil, nil, self.railtype)
		if vector.equals(cart_dir, {x=0, y=0, z=0}) then
			return
		end
		self.velocity = vector.multiply(cart_dir, 2)
		self.punched = true
		return
	end
	
	-- Player digs cart by sneak-punch
	if puncher:get_player_control().sneak then
		if self.sound_handle then
			minetest.sound_stop(self.sound_handle)
		end
		
		-- Pick up cart
		local node_name = self.node_name or "minecart:cart"
		local inv = puncher:get_inventory()
		if not (creative and creative.is_enabled_for
				and creative.is_enabled_for(puncher:get_player_name()))
				or not inv:contains_item("main", node_name) then
			local leftover = inv:add_item("main", node_name)
			-- If no room in inventory add a replacement cart to the world
			if not leftover:is_empty() then
				minetest.add_item(self.object:get_pos(), leftover)
			end
		end
		minecart.on_dig(self)
		self.object:remove()
		return
	end

	local punch_dir = carts:velocity_to_dir(puncher:get_look_dir())
	punch_dir.y = 0
	local cart_dir = carts:get_rail_direction(pos, punch_dir, nil, nil, self.railtype)
	if vector.equals(cart_dir, {x=0, y=0, z=0}) then
		return
	end
	
	self.velocity = vector.multiply(cart_dir, 2)
	self.old_dir = cart_dir
	self.punched = true
end

-- sound refresh interval = 1.0sec
local function rail_sound(self, dtime)
	if not self.sound_ttl then
		self.sound_ttl = 1.0
		return
	elseif self.sound_ttl > 0 then
		self.sound_ttl = self.sound_ttl - dtime
		return
	end
	self.sound_ttl = 1.0
	if self.sound_handle then
		local handle = self.sound_handle
		self.sound_handle = nil
		minetest.after(0.2, minetest.sound_stop, handle)
	end
	local vel = self.object:get_velocity() or {x=0, y=0, z=0}
	local speed = vector.length(vel)
	if speed > 0 then
		self.sound_handle = minetest.sound_play(
			"carts_cart_moving", {
			object = self.object,
			gain = (speed / carts.speed_max) / 2,
			loop = true,
		})
	end
end

local function get_railparams(pos)
	local node = minetest.get_node(pos)
	return carts.railparams[node.name] or {}
end

local function rail_on_step(self, dtime)
	local vel = self.object:get_velocity()
	local pos = self.object:get_pos()
	
	if self.punched then
		minecart.start_run(self, pos, vel, self.driver)
		vel = vector.add(vel, self.velocity)
		self.object:set_velocity(vel)
		self.old_dir.y = 0
	elseif vector.equals(vel, {x=0, y=0, z=0}) then
		if minecart.get_route_key(pos) then
			local cargo = minecart.stopped(self, pos)
			local param2 = minetest.dir_to_facedir(self.old_dir)
			switch_to_node(vector.round(pos), self.node_name, self.owner, param2, cargo)
			minecart.on_dig(self)
			self.object:remove()
		end
		return
	end

	-- cart position correction on slopes
	local rot = self.object:get_rotation()
	if rot.x ~= 0 then
		pos.y = pos.y - 0.5
	end
	
	local cart_dir = carts:velocity_to_dir(vel)
	local same_dir = vector.equals(cart_dir, self.old_dir)
	local update = {}

	if self.old_pos and not self.punched and same_dir then
		local flo_pos = vector.round(pos)
		local flo_old = vector.round(self.old_pos)
		if vector.equals(flo_pos, flo_old) then
			-- Do not check one node multiple times
			return
		end
	end

	local ctrl, player


	local stop_wiggle = false
	if self.old_pos and same_dir then
		-- Detection for "skipping" nodes (perhaps use average dtime?)
		-- It's sophisticated enough to take the acceleration in account
		local acc = self.object:get_acceleration()
		local distance = dtime * (vector.length(vel) + 0.5 * dtime * vector.length(acc))

		local new_pos, new_dir = carts:pathfinder(
			pos, self.old_pos, self.old_dir, distance, ctrl,
			self.old_switch, self.railtype
		)

		if new_pos then
			-- No rail found: set to the expected position
			pos = new_pos
			update.pos = true
			cart_dir = new_dir
		end
	elseif self.old_pos and self.old_dir.y ~= 1 and not self.punched then
		-- Stop wiggle
		stop_wiggle = true
	end

	local railparams

	-- dir:         New moving direction of the cart
	-- switch_keys: Currently pressed L/R key, used to ignore the key on the next rail node
	local dir, switch_keys = carts:get_rail_direction(
		pos, cart_dir, ctrl, self.old_switch, self.railtype
	)
	------------------------------- changed
	if switch_keys then
		minecart.set_junction(self, pos, dir, switch_keys)
	else
		dir, switch_keys = minecart.get_junction(self, pos, dir)
	end
	------------------------------- changed
	local dir_changed = not vector.equals(dir, self.old_dir)

	local new_acc = {x=0, y=0, z=0}
	if stop_wiggle or vector.equals(dir, {x=0, y=0, z=0}) then
		vel = {x = 0, y = 0, z = 0}
		local pos_r = vector.round(pos)
		if not carts:is_rail(pos_r, self.railtype)
				and self.old_pos then
			pos = self.old_pos
		elseif not stop_wiggle then
			pos = pos_r
		else
			pos.y = math.floor(pos.y + 0.5)
		end
		update.pos = true
		update.vel = true
	else
		-- Direction change detected
		if dir_changed then
			vel = vector.multiply(dir, math.abs(vel.x + vel.z))
			update.vel = true
			if dir.y ~= self.old_dir.y then
				pos = vector.round(pos)
				update.pos = true
			end
		end
		-- Center on the rail
		if dir.z ~= 0 and math.floor(pos.x + 0.5) ~= pos.x then
			pos.x = math.floor(pos.x + 0.5)
			update.pos = true
		end
		if dir.x ~= 0 and math.floor(pos.z + 0.5) ~= pos.z then
			pos.z = math.floor(pos.z + 0.5)
			update.pos = true
		end

		-- Slow down or speed up..
		local acc = dir.y * -4.0

		-- Get rail for corrected position
		railparams = get_railparams(pos)

		-- no need to check for railparams == nil since we always make it exist.
		local speed_mod = railparams.acceleration
		if speed_mod and speed_mod ~= 0 then
			-- Try to make it similar to the original carts mod
			acc = acc + speed_mod
		else
			-- Handbrake or coast
			if ctrl and ctrl.down then
				acc = acc - 3
			else
				acc = acc - 0.4
			end
		end

		new_acc = vector.multiply(dir, acc)
	end

	-- Limits
	local max_vel = carts.speed_max
	for _, v in pairs({"x","y","z"}) do
		if math.abs(vel[v]) > max_vel then
			vel[v] = carts:get_sign(vel[v]) * max_vel
			new_acc[v] = 0
			update.vel = true
		end
	end

	self.object:set_acceleration(new_acc)
	self.old_pos = vector.round(pos)
	if not vector.equals(dir, {x=0, y=0, z=0}) and not stop_wiggle then
		self.old_dir = vector.new(dir)
	end
	self.old_switch = switch_keys

	if self.punched then
		self.punched = false
		update.vel = true
	end

	railparams = railparams or get_railparams(pos)

	if not (update.vel or update.pos) then
		return
	end

	local yaw = 0
	if self.old_dir.x < 0 then
		yaw = math.pi/2*3
	elseif self.old_dir.x > 0 then
		yaw = math.pi/2
	elseif self.old_dir.z < 0 then
		yaw = math.pi
	end
	--self.object:set_yaw(yaw * math.pi)

	local pitch = 0
	if self.old_dir.z ~= 0 then
		if dir.y == -1 then
			pitch = -math.pi/4
		elseif dir.y == 1 then
			pitch = math.pi/4
		end
	else
		if dir.y == -1 then
			pitch = math.pi/4
		elseif dir.y == 1 then
			pitch = -math.pi/4
		end
	end
	self.object:set_rotation({x = pitch, y = yaw, z = 0})
	
	-- cart position correction on slopes
	if pitch ~= 0 then
		pos.y = pos.y + 0.5
		update.pos = true
	end
	
	if update.vel then
		self.object:set_velocity(vel)
	end
	if update.pos then
		if dir_changed then
			self.object:set_pos(pos)
		else
			self.object:move_to(pos)
		end
	end
end

function minecart:on_step(dtime)
	rail_on_step(self, dtime)
	rail_sound(self, dtime)
end
