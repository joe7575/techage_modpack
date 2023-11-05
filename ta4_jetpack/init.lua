--[[

	TA4_Jetpack
	===========

	Copyright (C) 2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

]]--

-- Load support for I18n.
local S = minetest.get_translator("ta4_jetpack")

local liquid = networks.liquid
local LQD = function(pos) return (minetest.registered_nodes[tubelib2.get_node_lvm(pos).name] or {}).liquid end

local ta4_jetpack = {}

local Players = {}
local Jetpacks = {}
local ItemsBlocklist = {}

local MAX_HEIGHT = tonumber(minetest.settings:get("ta4_jetpack_max_height")) or 500
local MAX_VSPEED = tonumber(minetest.settings:get("ta4_jetpack_max_vertical_speed")) or 20
local MAX_HSPEED = (tonumber(minetest.settings:get("ta4_jetpack_max_horizontal_speed")) or 12) / 4
local MAX_NUM_INV_ITEMS = tonumber(minetest.settings:get("ta4_jetpack_max_num_inv_items")) or 99

-- Flight time maximum 6 min or 360 s or 3600 steps.
-- 12 units hydrogen for 3600 steps means 0.0033 units hydrogen / step.
local MAX_FUEL = 12   -- hydrogen units
local RESERVE_LVL = 2  -- fuel reserve
local FUEL_UNIT = 2   -- tank units per click
local WEAR_CYCLE = 10  -- check wear every 10 sec
local STEPS_TO_FUEL = 0.0033

local WEAR_VALUE = 180   -- roughly 10 flys, 6 min each

-- API function to register items that are forbidden in inventory during flight.
ta4_jetpack.register_forbidden_item = function(itemname)
	ItemsBlocklist[itemname] = true
end

local function store_player_physics(player)
	local meta = player:get_meta()
	-- Check access conflicts with other mods
	if meta:get_int("player_physics_locked") == 0 then 
		local physics = player:get_physics_override()
		meta:set_int("player_physics_locked", 1)
		meta:set_int("ta4_jetpack_normal_player_speed", physics.speed)
		meta:set_int("ta4_jetpack_normal_player_gravity", physics.gravity)
		return true
	end
	return false
end

local function restore_player_physics(player)
	local meta = player:get_meta()
	local physics = player:get_physics_override()
	physics.speed = meta:get_int("ta4_jetpack_normal_player_speed")
	physics.gravity = meta:get_int("ta4_jetpack_normal_player_gravity")
	meta:set_int("player_physics_locked", 0)
	player:set_physics_override(physics)
end

local function turn_jetpack_off(player)
    local name = player:get_player_name()
    restore_player_physics(player)
    if Players[name] and Players[name].snd_hdl then
        minetest.sound_stop(Players[name].snd_hdl)
    end
    if Players[name] and Players[name].alarm_snd_hdl then
        minetest.sound_stop(Players[name].alarm_snd_hdl)
    end
	--Jetpacks[name] = nil
	Players[name] = nil
end

local function get_inv_controller_index(player)
	local inv = player:get_inventory()
	for idx, item in ipairs(inv:get_list("main")) do
		if item:get_name() == "ta4_jetpack:controller_on" then
			return idx
		end
	end
end

local function turn_inv_controller_off(player)
	local idx = get_inv_controller_index(player)
	if idx then
		local inv = player:get_inventory()
		inv:set_stack("main", idx, ItemStack("ta4_jetpack:controller_off"))
	end
end

-- Fuel is stored as metadata (0..100) in the jetpack item located at the armor inventory 
local function get_fuel_value(name)
	if Jetpacks[name] and Jetpacks[name].index then
		local index = Jetpacks[name].index
		local inv = minetest.get_inventory({type = "detached", name = name.."_armor"})
		local stack = inv:get_stack("armor", index)
		local meta = stack:get_meta()
		return meta:get_float("fuel")
	end
	return 0
end

local function set_fuel_value(name, value)
	if Jetpacks[name] and Jetpacks[name].index then
		local index = Jetpacks[name].index
		local inv = minetest.get_inventory({type = "detached", name = name.."_armor"})
		local stack = inv:get_stack("armor", index)
		local meta = stack:get_meta()
		meta:set_float("fuel", value)
		inv:set_stack("armor", index, stack)
	end
end

local function subtract_fuel_value(name, value)
	if Jetpacks[name] and Jetpacks[name].index then
		local index = Jetpacks[name].index
		local inv = minetest.get_inventory({type = "detached", name = name.."_armor"})
		local stack = inv:get_stack("armor", index)
		local meta = stack:get_meta()
		local amount = meta:get_float("fuel")
		if amount >= value then
			meta:set_float("fuel", amount - value)
			inv:set_stack("armor", index, stack)
			return amount - value
		end
	end
	return 0
end

local function fuel_value_to_wearout(value)
	return math.floor(65533 - (value / MAX_FUEL * 65530))
end

local function update_controller_fuel_gauge(player, index, value)
	local inv = player:get_inventory()
	if inv and index then
		local stack = inv:get_stack("main", index)
		if stack:get_name() == "ta4_jetpack:controller_on" then
			stack:set_wear(fuel_value_to_wearout(value))
			inv:set_stack("main", index, stack)
		end
	end
end

local function check_player_load(player)
	local inv = player:get_inventory()
	local meta = player:get_meta()
	local bags_meta = meta:get_string("unified_inventory:bags")
	if bags_meta then
		if next(minetest.deserialize(bags_meta) or {}) then
			return S("You are too heavy: Please remove your bags!")
		end
	end
	for _, stack in ipairs(inv:get_list("craft") or {}) do
		if not stack:is_empty() then
			return S("You are too heavy: Check your crafting menu!")
		end
	end
	local count = 0
	for _, stack in ipairs(inv:get_list("main") or {}) do
		count = count + stack:get_count()
		if count > MAX_NUM_INV_ITEMS then 
			return S("You are too heavy: Check your inventory!")
		end
		if ItemsBlocklist[stack:get_name()] then
			return S("You may not transport @1 with a jetpack!", stack:get_description())
		end
	end
end	
	
local cycle_time = 0
minetest.register_globalstep(function(dtime)
	cycle_time = cycle_time + dtime
	if cycle_time < 0.1 then return end
	cycle_time = cycle_time - 0.1
	
	for name, def in pairs(Players) do
		local player = minetest.get_player_by_name(name)
		local fire = player:get_player_control().jump
		local ctrl = player:get_player_control_bits()
		local pos = player:getpos()
		local vel = player:get_player_velocity()
		local item = player:get_wielded_item()
		
		-- The controller as wielded item prevents the player from using other blocks
		if item:get_name() ~= "ta4_jetpack:controller_on" then
			-- You shouldn't have done that :)
			turn_jetpack_off(player)
			turn_inv_controller_off(player)
		else
			-- handle fire button
			if fire ~= def.old_fire then
				def.old_fire = fire
				if fire then
					def.gravity = -0.5
					def.speed = MAX_HSPEED
					def.correction = true
				else
					def.gravity = 0.7
					def.speed = MAX_HSPEED
					def.correction = true
				end	
			end
		
			-- handle drive sound
			if ctrl ~= def.old_ctrl then
				def.old_ctrl = ctrl
				if ctrl > 0 and ctrl ~= 256 then
					if not def.snd_hdl then
						def.snd_hdl = minetest.sound_play("ta4_jetpack", {
							max_hear_distance = 16,
							gain = 1,
							object = player,
							loop = true
						})	
					end
				else
					if def.snd_hdl then
						minetest.sound_stop(def.snd_hdl)
						def.snd_hdl = nil
					end
				end
			end
				
			-- handle smoke and use
			if ctrl > 0 then
				minetest.add_particle({
					pos = pos,
					velocity = {x = vel.x, y = vel.y - 10, z = vel.z},
					expirationtime = 1,
					size = 5,
					vertical = false,
					texture = "ta4_jetpack_smoke.png",
				})
				def.used = (def.used or 0) + 1
			end
			
			-- control max height
			if pos.y > MAX_HEIGHT then 
				pos.y = MAX_HEIGHT - MAX_HEIGHT/10
				player:setpos(pos)
			end
			
			-- control max speed
			if vel.y > MAX_VSPEED then
				player:set_physics_override({gravity = 1, speed = def.speed})
				def.correction = true
			elseif vel.y < (-2 * MAX_VSPEED) then
				player:set_physics_override({gravity = -1, speed = def.speed})
				def.correction = true
			elseif def.correction then
				player:set_physics_override({gravity = def.gravity, speed = def.speed})
				def.correction = false
			end
		end
	end
end)

local function debug_out(name)
	local index = Jetpacks[name].index
	local inv = minetest.get_inventory({type = "detached", name = name.."_armor"})
	local stack = inv:get_stack("armor", index)
	print("used = "..(def.used or 0)..", value = "..get_fuel_value(name)..", wear = "..stack:get_wear())
end

-- Called cyclic to maintain wear out and fuel gauge
local function jetpack_wearout()
	for name, def in pairs(Players) do
		local player = minetest.get_player_by_name(name)
		if player and Jetpacks[name] then
			-- debug_out(name)
			if def.used then
				local value = subtract_fuel_value(name, def.used * STEPS_TO_FUEL)
				def.used = 0
				def.controller_index = def.controller_index or get_inv_controller_index(player)
				update_controller_fuel_gauge(player, def.controller_index, value)
				if value == 0 then
					---- Fly is finished :)
					turn_jetpack_off(player)
					turn_inv_controller_off(player)
				elseif value < RESERVE_LVL then
					def.alarm_snd_hdl = minetest.sound_play("ta4_jetpack_alarm", {
							max_hear_distance = 16,
							gain = 1,
							object = player,
						})
				end
				-- Handle the jetpack wear out
				local index = Jetpacks[name] and Jetpacks[name].index or 1
				local inv = minetest.get_inventory({type = "detached", name = name.."_armor"})
				local stack = inv:get_stack("armor", index)
				armor:damage(player, index, stack, WEAR_VALUE)
				if stack:get_wear() > (65535 - WEAR_VALUE * 4) then
					def.alarm_snd_hdl = minetest.sound_play("ta4_jetpack_alarm", {
							max_hear_distance = 16,
							gain = 1,
							object = player,
						})
				end
			else
				local value = get_fuel_value(name)
				if value < 4 then
					def.alarm_snd_hdl = minetest.sound_play("ta4_jetpack_alarm", {
							max_hear_distance = 16,
							gain = 1,
							object = player,
						})
				end
			end
		end
	end
	minetest.after(WEAR_CYCLE, jetpack_wearout)
end

minetest.after(WEAR_CYCLE, jetpack_wearout)

local function round(val)
	return math.floor((val * 10) + 0.5) / 10.0
end

local function load_fuel(itemstack, user, pointed_thing)
	local pos = pointed_thing.under
	if pos then
		local name = user:get_player_name()
		local nvm = techage.get_nvm(pos)
		-- check jetpack
		if not Jetpacks[name] then 
			minetest.chat_send_player(name, S("[Jetpack] You don't have your jetpack on your back!"))
			return itemstack
		end
		if name and liquid.srv_peek(nvm) == "techage:hydrogen" then
			local value = get_fuel_value(name)
			local newvalue
			
			if user:get_player_control().sneak then  -- back to tank?
				local amount = math.max(math.min(value, FUEL_UNIT), 0)
				local rest = liquid.srv_put(nvm, "techage:hydrogen", amount, LQD(pos).capa)
				newvalue = value - (amount - rest)
			else
				local amount = math.max(math.min(FUEL_UNIT, MAX_FUEL - value), 0)
				local taken = liquid.srv_take(nvm, "techage:hydrogen", math.floor(amount))
				newvalue = value + taken
			end
			set_fuel_value(name, newvalue)
			minetest.chat_send_player(name, S("[Jetpack]") .. ": " .. round(newvalue) .. "/" .. MAX_FUEL)
		end
	end
	return itemstack
end


local function turn_controller_on_off(itemstack, user)
	local name = user:get_player_name()
	if Players[name] then -- turn off
		turn_jetpack_off(user)
		itemstack = ItemStack("ta4_jetpack:controller_off 1 0")
	else
		-- check jetpack
		if not Jetpacks[name] then 
			minetest.chat_send_player(name, S("[Jetpack] You don't have your jetpack on your back!"))
			return itemstack
		end
		-- check inventory load
		local res = check_player_load(user) 
		if res then
			minetest.chat_send_player(name, S("[Jetpack]").." "..res)
			return itemstack
		end
		-- check fuel
		local value = get_fuel_value(name)
		if value == 0 then
			minetest.chat_send_player(name, S("[Jetpack] Your tank is empty!"))
			minetest.chat_send_player(name, S("Use the controller (left click) to fill the tank with hydrogen"))
			return itemstack
		end
		-- start the jetpack
		if store_player_physics(user) then
			Players[name] = {gravity = 1, speed = 1}
			minetest.sound_play("ta4_jetpack_on", {
				max_hear_distance = 16,
				gain = 1,
				object = user,
			})	
			-- update fuel gauge
			itemstack = ItemStack("ta4_jetpack:controller_on")
			itemstack:set_wear(fuel_value_to_wearout(value))
		end
	end
	return itemstack
end

minetest.register_tool("ta4_jetpack:controller_on", {
	description = S("TA4 Jetpack Controller On"),
	inventory_image = "ta4_jetpack_controller_inv.png",
	wield_image = "ta4_jetpack_controller_inv.png",
	groups =  {cracky = 1, wieldview_transform = 1, not_in_creative_inventory = 1},
	on_use = load_fuel,
	on_secondary_use = turn_controller_on_off,
	on_place = turn_controller_on_off,
	-- Prevent dropping a running controller
	on_drop = function(itemstack) return itemstack end,
	node_placement_prediction = "",
	stack_max = 1,
})

minetest.register_tool("ta4_jetpack:controller_off", {
	description = S("TA4 Jetpack Controller Off"),
	inventory_image = "ta4_jetpack_controller_off_inv.png",
	wield_image = "ta4_jetpack_controller_off_inv.png",
	groups = {cracky = 1, wieldview_transform = 1},
	on_use = load_fuel,
	on_secondary_use = turn_controller_on_off,
	on_place = turn_controller_on_off,
	node_placement_prediction = "",
	stack_max = 1,
})

armor:register_armor("ta4_jetpack:jetpack_material", {
    description = S("TA4 Jetpack"),
    texture = "ta4_jetpack_jetpack.png",
    inventory_image = "ta4_jetpack_jetpack_inv.png",
    groups = {armor_torso=1, armor_heal=0, armor_use=100},
	on_equip = function(player, index, stack)
		local name = player:get_player_name()
		Jetpacks[name] = {index = index}
        Players[name] = nil
	end,
	on_unequip = function(player, index, stack)
        turn_jetpack_off(player)
		turn_inv_controller_off(player)
		local name = player:get_player_name()
		Jetpacks[name] = nil
	end,
	on_destroy = function(player, index, stack)
        turn_jetpack_off(player)
		turn_inv_controller_off(player)
		local name = player:get_player_name()
		Jetpacks[name] = nil
	end
})

minetest.register_alias("ta4_jetpack:jetpack", "ta4_jetpack:jetpack_material")

-- For some reason, prevent to move/put/take a running controller
minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
	if inventory_info.stack and inventory_info.stack:get_name() == "ta4_jetpack:controller_on" then
		return 0
	end
end)

local function reset_player(player)
	local name = player:get_player_name()
	
	if Players[name] then
		-- Turn Jetpack off
		Players[name] = nil
		Jetpacks[name] = nil
		turn_inv_controller_off(player)
		
		restore_player_physics(player)
		
		-- Determine the ground below the player for the next respawn
		local pos = vector.round(player:get_pos())
		local res, pos1 = minetest.line_of_sight(pos, {x = pos.x, y = pos.y - MAX_HEIGHT, z = pos.z})
		if not res then
			local meta = player:get_meta()
			meta:set_string("ta4_jetpack_startpos", 
					minetest.pos_to_string({x = pos1.x, y = pos1.y + 2, z = pos1.z}))
		end
	end
end

minetest.register_on_leaveplayer(function(player)
	reset_player(player)
end)

minetest.register_on_shutdown(function()
	for name, def in pairs(Players) do
		local player = minetest.get_player_by_name(name)
		reset_player(player)
	end
end)

minetest.register_on_joinplayer(function(player)
	-- teleport player to the ground position
	local meta = player:get_meta()
	local s = meta:get_string("ta4_jetpack_startpos")
	
	if s ~= "" then
		meta:set_string("ta4_jetpack_startpos", "")
		local pos = minetest.string_to_pos(s)
		player:set_pos(pos)
	end
	meta:set_int("player_physics_under_control", 0)
end)

minetest.register_node("ta4_jetpack:trainingmat", {
	description = S("Jetpack Training Mat"),
	tiles = {
		"ta4_jetpack_mat_top.png", 
		"ta4_jetpack_mat_top.png", 
		"ta4_jetpack_mat_side.png"
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, 8/16, -2/16,  8/16},
		},
	},
	walkable = true,
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 1, fall_damage_add_percent = -80, bouncy = 40},
})

minetest.register_craft({
	output = "ta4_jetpack:jetpack",
	recipe = {
		{"techage:ta4_carbon_fiber", "", "techage:ta4_carbon_fiber"},
		{"techage:aluminum", "techage:ta3_cylinder_large", "techage:aluminum"},
		{"basic_materials:motor", "basic_materials:steel_bar", "basic_materials:motor"}
	},
})

minetest.register_craft({
	output = "ta4_jetpack:controller_off",
	recipe = {
		{"basic_materials:plastic_sheet", "techage:basalt_glass_thin", "basic_materials:plastic_sheet"},
		{"techage:ta4_wlanchip", "techage:ta4_battery", "techage:ta4_ramchip"},
		{"", "", ""}
	},
})

minetest.register_craft({
	output = "ta4_jetpack:trainingmat",
	recipe = {
		{"dye:green", "dye:green", "dye:green"},
		{"techage:ta4_carbon_fiber", "techage:ta4_carbon_fiber", "techage:ta4_carbon_fiber"},
		{"basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet"}
	},
})

dofile(minetest.get_modpath("ta4_jetpack") .. "/manual_DE.lua")
dofile(minetest.get_modpath("ta4_jetpack") .. "/manual_EN.lua")

techage.add_manual_items({
		ta4_jetpack = "ta4_jetpack.png",
		ta4_jetpack_controller = 'ta4_jetpack_controller_inv.png'})

ta4_jetpack.register_forbidden_item("techage:cylinder_large_hydrogen")
ta4_jetpack.register_forbidden_item("techage:cylinder_small_hydrogen")
ta4_jetpack.register_forbidden_item("techage:hydrogen")
ta4_jetpack.register_forbidden_item("digtron:loaded_crate")
ta4_jetpack.register_forbidden_item("digtron:loaded_locked_crate")
