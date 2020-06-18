--[[

	Minecart
	========

	Copyright (C) 2019-2020 Joachim Stolberg

	MIT
	See license.txt for more information
	
	Cart library functions (level 1)
	
]]--

-- Notes:
-- 1) Only the owner can punch der cart
-- 2) Only the owner can start the recording
-- 3) But any player can act as cargo, cart punched by owner or buffer


-- for lazy programmers
local M = minetest.get_meta
local S = minecart.S
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local MP = minetest.get_modpath("minecart")

local api = {}

function api:init(is_node_cart)
	local lib
	
	if is_node_cart then
		lib = dofile(MP.."/cart_lib2n.lua")
	else
		lib = dofile(MP.."/cart_lib2e.lua")
	end
		
	-- add lib to local api
	for k,v in pairs(lib) do
		api[k] = v
	end
end

-- Player get on / off
function api:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	local player_name = clicker:get_player_name()
	if self.driver and player_name == self.driver then
		self.driver = nil
		carts:manage_attachment(clicker, nil)
	elseif not self.driver then
		self.driver = player_name
		carts:manage_attachment(clicker, self.object)

		-- player_api does not update the animation
		-- when the player is attached, reset to default animation
		player_api.set_animation(clicker, "stand")
	end
end

function api:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
end

function api:on_detach_child(child)
	if child and child:get_player_name() == self.driver then
		self.driver = nil
	end
end

function api:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	local pos = self.object:get_pos()
	local vel = self.object:get_velocity()
	local stopped = vector.equals(vel, {x=0, y=0, z=0})
	local is_minecart = self.node_name == nil
	local node_name = self.node_name or "minecart:cart"
	local puncher_name = puncher and puncher:is_player() and puncher:get_player_name()
	local puncher_is_owner = puncher_name and (not self.owner or self.owner == "" or
			puncher_name == self.owner or
			minetest.check_player_privs(puncher_name, "minecart"))
	local puncher_is_driver = self.driver and self.driver == puncher_name
	local sneak_punch = puncher_name and puncher:get_player_control().sneak
	local no_cargo = next(self.cargo or {}) == nil
	
	-- driver wants to leave/remove the empty Minecart by sneak-punch
	if is_minecart and sneak_punch and puncher_is_driver and no_cargo then
		if puncher_is_owner then
			api.remove_cart(self, pos, puncher)
		end
		carts:manage_attachment(puncher, nil)
		return
	end
	
	-- running carts can't be punched or removed from external
	if not stopped then
		return
	end
	
	-- Punched by non-authorized player
	if puncher_name and not puncher_is_owner then
		minetest.chat_send_player(puncher_name, S("[minecart] Cart is protected by ")..(self.owner or ""))
		return
	end
	
	if not self.railtype then
		local node = minetest.get_node(pos).name
		self.railtype = minetest.get_item_group(node, "connect_to_raillike")
	end
	
	-- Punched by non-player
	if not puncher_name then
		local cart_dir = carts:get_rail_direction(pos, direction, nil, nil, self.railtype)
		if vector.equals(cart_dir, {x=0, y=0, z=0}) then
			return
		end
		self.velocity = vector.multiply(cart_dir, 2)
		self.punched = true
		api.load_cargo(self, pos)
		minecart.start_cart(pos, self.myID)
		return
	end
	
	-- Sneak-punched by owner
	if sneak_punch then
		-- Unload the cargo
		if api.add_cargo_to_player_inv(self, pos, puncher) then
			return
		end
		-- detach driver
		if self.driver then
			carts:manage_attachment(puncher_name, nil)
		end
		-- Pick up cart
		api.remove_cart(self, pos, puncher)
		return
	end
	
	-- Cart with driver punched to start recording
	if puncher_is_driver then
		minecart.start_recording(self, pos, vel, puncher)
	else
		minecart.start_cart(pos, self.myID)
	end

	api.load_cargo(self, pos)
	
    -- Normal punch by owner to start the cart
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

local function rail_on_step_event(handler, obj, dtime)
	if handler then
		handler(obj, dtime)
	end
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
	if not self.stopped then
		local vel = self.object:get_velocity() or {x=0, y=0, z=0}
		local speed = vector.length(vel)
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

local v3_len = vector.length
local function rail_on_step(self, dtime)
	local vel = self.object:get_velocity()
	local pos = self.object:get_pos()
	local rot = self.object:get_rotation()
	local stopped = minecart.stopped(vel) and rot.x == 0
	local is_minecart = self.node_name == nil
	local recording = is_minecart and self.driver == self.owner
	
	-- cart position correction on slopes
	if rot.x ~= 0 then
		pos.y = pos.y - 0.5
	end
	
	if self.punched then
		vel = vector.add(vel, self.velocity)
		self.object:set_velocity(vel)
		self.old_dir.y = 0
		self.stopped = false
	elseif stopped and not self.stopped then
		local param2 = minetest.dir_to_facedir(self.old_dir)
		api.stop_cart(pos, self, self.node_name or "minecart:cart", param2)
		if recording then
			minecart.stop_recording(self, pos, vel, self.driver)
		end
		api.unload_cargo(self, pos) 
		self.stopped = true
		self.object:set_velocity({x=0, y=0, z=0})
		self.object:set_acceleration({x=0, y=0, z=0})
		return
	elseif stopped then
		return
	end
	
	if recording then
		minecart.store_next_waypoint(self, pos, vel)
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

	-- Get player controls
	if recording then
		player = minetest.get_player_by_name(self.driver)
		if player then
			ctrl = player:get_player_control()
		end
	end
	
	local railparams

	-- dir:         New moving direction of the cart
	-- switch_keys: Currently pressed L/R key, used to ignore the key on the next rail node
	local dir, switch_keys = carts:get_rail_direction(
		pos, cart_dir, ctrl, self.old_switch, self.railtype
	)
	
	-- handle junctions
	if switch_keys then  -- recording
		minecart.set_junction(self, pos, dir, switch_keys)
	else  -- normal run
		dir, switch_keys = minecart.get_junction(self, pos, dir)
	end
	
	local dir_changed = not vector.equals(dir, self.old_dir)

	local new_acc = {x=0, y=0, z=0}
	if vector.equals(dir, {x=0, y=0, z=0}) then
		vel = {x = 0, y = 0, z = 0}
		local pos_r = vector.round(pos)
		if not carts:is_rail(pos_r, self.railtype)
				and self.old_pos then
			pos = self.old_pos
		else
			pos = pos_r
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
		local acc = dir.y * -2.0

		-- Get rail for corrected position
		railparams = get_railparams(pos)

		-- no need to check for railparams == nil since we always make it exist.
		local speed_mod = railparams.acceleration
		if speed_mod and speed_mod ~= 0 then
			-- Try to make it similar to the original carts mod
			acc = acc + speed_mod
		else
			acc = acc - 0.4
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
	if not vector.equals(dir, {x=0, y=0, z=0}) then
		self.old_dir = vector.new(dir)
	end
	self.old_switch = switch_keys

	if self.punched then
		self.punched = false
		update.vel = true
	end

	railparams = railparams or get_railparams(pos)

	if not (update.vel or update.pos) then
		rail_on_step_event(railparams.on_step, self, dtime)
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
		vel = vector.divide(vel, 2)
		update.vel = true
	elseif self.old_pitch ~= 0 then
		vel = vector.multiply(vel, 2)
		update.vel = true
	end
	self.old_pitch = pitch
	
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

	-- call event handler
	rail_on_step_event(railparams.on_step, self, dtime)
end

function api:on_step(dtime)
	rail_on_step(self, dtime)
	rail_sound(self, dtime)
end

return api
