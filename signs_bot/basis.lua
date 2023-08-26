--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Signs Bot: Robot basis block

]]--

-- for lazy programmers
local M = minetest.get_meta

-- Load support for I18n.
local S = signs_bot.S

local lib = signs_bot.lib

signs_bot.MAX_CAPA = 600

local CYCLE_TIME = 1
local CYCLE_TIME2 = 2  -- for charging phase

local function in_range(val, min, max)
	if val < min then return min end
	if val > max then return max end
	return val
end

-- determine item name from the given Bot inventory slot
function signs_bot.bot_inv_item_name(pos, slot)
	if slot == 0 then return nil end -- invalid num
	local inv = M(pos):get_inventory()
	local name = inv:get_stack("filter", slot):get_name()
	if name ~= "" then return name end
end

-- put items into the bot inventory and return leftover
function signs_bot.bot_inv_put_item(pos, slot, items)
	if not items then return end
	local inv = M(pos):get_inventory()
	if slot and slot > 0 then
		local name = inv:get_stack("filter", slot):get_name()
		if name == "" or name == items:get_name() then
			local stack = inv:get_stack("main", slot)
			items = stack:add_item(items)
			inv:set_stack("main", slot, stack)
		end
	else
		for idx = 1,8 do
			local name = inv:get_stack("filter", idx):get_name()
			if name == "" or name == items:get_name() then
				local stack = inv:get_stack("main", idx)
				items = stack:add_item(items)
				inv:set_stack("main", idx, stack)
				if items:get_count() == 0 then return items end
			end
		end
	end
	return items
end

local function take_items(inv, slot, num)
	local stack = inv:get_stack("main", slot)
	if stack:get_count() >= num then
		local taken = stack:take_item(num)
		inv:set_stack("main", slot, stack)
		return taken
	else
		inv:set_stack("main", slot, nil)
		local rest = num - stack:get_count()
		local taken = inv:remove_item("main", ItemStack(stack:get_name().." "..rest))
		stack:set_count(stack:get_count() + taken:get_count())
		return stack
	end
end

-- take items from the bot inventory
function signs_bot.bot_inv_take_item(pos, slot, num)
	local inv = M(pos):get_inventory()
	if slot and slot > 0 then
		return take_items(inv, slot, num)
	else
		for idx = 1,8 do
			if not inv:get_stack("main", idx):is_empty() then
				return take_items(inv, idx, num)
			end
		end
	end
end

local bot_inv_item_name = signs_bot.bot_inv_item_name

local function preassigned_slots(pos)
	local inv = M(pos):get_inventory()
	local tbl = {}
	for idx = 1,8 do
		local item_name = inv:get_stack("filter", idx):get_name()
		if item_name ~= "" then
			local x = ((idx - 1) % 4) + 5
			local y = idx < 5 and 1 or 2
			tbl[#tbl+1] = "item_image["..x..","..y..";1,1;"..item_name.."]"
		end
	end
	return table.concat(tbl, "")
end

local function status(mem)
	if mem.error then
		if type(mem.error) == "string" then
			return mem.error
		else
			return dump(mem.error)
		end
	end
	if mem.running then
		return S("running")
	end
	if mem.charging then
		return S("charging")
	end
	return S("stopped")
end

local function formspec(pos, mem)
	mem.running = mem.running or false
	local cmnd = mem.running and "stop;"..S("Off") or "start;"..S("On")
	local bot = not mem.running and "image[0.6,0;1,1;signs_bot_bot_inv.png]" or ""
	local current_capa = mem.capa or (signs_bot.MAX_CAPA * 0.9)
	return "size[9,8.2]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"label[2.1,0;"..S("Signs").."]label[5.3,0;"..S("Other items").."]"..
	"image[0.6,0;1,1;signs_bot_form_mask.png]"..
	bot..
	preassigned_slots(pos)..
	signs_bot.formspec_battery_capa(signs_bot.MAX_CAPA, current_capa)..
	"label[2.1,0.5;1]label[3.1,0.5;2]label[4.1,0.5;3]"..
	"list[context;sign;1.8,1;3,2;]"..
	"label[2.1,3;4]label[3.1,3;5]label[4.1,3;6]"..
	"label[5.3,0.5;1]label[6.3,0.5;2]label[7.3,0.5;3]label[8.3,0.5;4]"..
	"list[context;main;5,1;4,2;]"..
	"label[5.3,3;5]label[6.3,3;6]label[7.3,3;7]label[8.3,3;8]"..
	"button[0.2,1;1.5,1;config;"..S("Config").."]"..
	"button[0.2,2;1.5,1;"..cmnd.."]"..
	"label[1,3.6;"..status(mem).."]"..
	"list[current_player;main;0.5,4.4;8,4;]"..
	"listring[context;main]"..
	"listring[current_player;main]"
end

local function formspec_cfg()
	return "size[9,8.2]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"label[5.3,0;"..S("Preassign slots items").."]"..
	"label[5.3,0.5;1]label[6.3,0.5;2]label[7.3,0.5;3]label[8.3,0.5;4]"..
	"list[context;filter;5,1;4,2;]"..
	"label[5.3,3;5]label[6.3,3;6]label[7.3,3;7]label[8.3,3;8]"..
	"button[0.2,1;1.5,1;back;"..S("Back").."]"..
	"list[current_player;main;0.5,4.4;8,4;]"..
	"listring[context;filter]"..
	"listring[current_player;main]"
end

local function get_capa(itemstack)
	local meta = itemstack:get_meta()
	if meta then
		return in_range(meta:get_int("capa") * (signs_bot.MAX_CAPA/100), 0, 3000)
	end
	return 0
end

local function set_capa(pos, oldnode, digger, capa)
	local node = ItemStack(oldnode.name)
	local meta = node:get_meta()
	capa = techage.power.percent(signs_bot.MAX_CAPA, capa)
	capa = (math.floor((capa or 0) / 5)) * 5
	meta:set_int("capa", capa)
	local text = S("Robot Box").." ("..capa.." %)"
	meta:set_string("description", text)
	local inv = minetest.get_inventory({type="player", name=digger:get_player_name()})
	if inv then
		local left_over = inv:add_item("main", node)
		if left_over:get_count() > 0 then
			minetest.add_item(pos, node)
		end
	end
end

function signs_bot.infotext(pos, state)
	local meta = M(pos)
	local number = meta:get_string("number")
	state = state or "<unknown>"
	meta:set_string("infotext", S("Robot Box").." "..number..": "..state)
end

local function free_start_pos(pos, mem)
	local param2 = (minetest.get_node(pos).param2 + 1) % 4
	local robot_pos = lib.next_pos(pos, param2, 1)
	return signs_bot.lib.is_air_like(robot_pos)
end

local function reset_robot(pos, mem)
	mem.robot_param2 = (minetest.get_node(pos).param2 + 1) % 4
	mem.robot_pos = lib.next_pos(pos, mem.robot_param2, 1)
	local pos_below = {x=mem.robot_pos.x, y=mem.robot_pos.y-1, z=mem.robot_pos.z}
	signs_bot.place_robot(mem.robot_pos, pos_below, mem.robot_param2)
end

function signs_bot.start_robot(base_pos)
	local mem = tubelib2.get_mem(base_pos)
	if free_start_pos(base_pos, mem) then
		mem.steps = nil
		mem.script = "cond_move"
		local meta = M(base_pos)
		signs_bot.reset(base_pos, mem)
		mem.running = true
		mem.charging = false
		mem.error = false
		mem.stored_node = nil
		if minetest.global_exists("techage") then
			mem.capa = mem.capa or 0 -- enable power consumption
		else
			mem.capa = nil
		end
		meta:set_string("formspec", formspec(base_pos, mem))
		signs_bot.infotext(base_pos, S("running"))
		reset_robot(base_pos, mem)
		minetest.get_node_timer(base_pos):start(CYCLE_TIME)
		return true
	end
end

function signs_bot.stop_robot(base_pos, mem)
	local meta = M(base_pos)
	if mem.signal_request ~= true then
		mem.running = false
		if minetest.global_exists("techage") then
			minetest.get_node_timer(base_pos):start(CYCLE_TIME2)
			mem.charging = true
			mem.power_available = false
		else
			minetest.get_node_timer(base_pos):stop()
			mem.charging = false
		end
		if mem.charging then
			signs_bot.infotext(base_pos, S("charging"))
		else
			signs_bot.infotext(base_pos, S("stopped"))
		end
		meta:set_string("formspec", formspec(base_pos, mem))
		signs_bot.remove_robot(mem)
	else
		mem.signal_request = false
		signs_bot.start_robot(base_pos)
	end
end

-- Used by the pairing tool
local function signs_bot_get_signal(pos, node)
	local mem = tubelib2.get_mem(pos)
	if mem.running then
		return "on"
	else
		return "off"
	end
end

-- To be called from sensors
local function signs_bot_on_signal(pos, node, signal)
	local mem = tubelib2.get_mem(pos)
	if signal == "on" and not mem.running then
		signs_bot.start_robot(pos)
	elseif signal == "off" and mem.running then
		signs_bot.stop_robot(pos, mem)
--	else
--		mem.signal_request = (signal == "on")
	end
end


local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	if mem.charging and signs_bot.while_charging then
		return signs_bot.while_charging(pos, mem)
	else
		local res = false
		--local t = minetest.get_us_time()
		if mem.running then
			res = signs_bot.run_next_command(pos, mem)
		end
		--t = minetest.get_us_time() - t
		--print("node_timer", t)
		return res and mem.running
	end
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local mem = tubelib2.get_mem(pos)
	local meta = minetest.get_meta(pos)

	if fields.update then
		meta:set_string("formspec", formspec(pos, mem))
	elseif fields.config then
		meta:set_string("formspec", formspec_cfg())
	elseif fields.back then
		meta:set_string("formspec", formspec(pos, mem))
	elseif fields.start then
		signs_bot.start_robot(pos)
	elseif fields.stop then
		signs_bot.stop_robot(pos, mem)
	end
end

local function on_rightclick(pos)
	local mem = tubelib2.get_mem(pos)
	M(pos):set_string("formspec", formspec(pos, mem))
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local mem = tubelib2.get_mem(pos)
	if mem.running then
		return 0
	end
	local name = stack:get_name()
	if listname == "sign" and minetest.get_item_group(name, "sign_bot_sign") ~= 1 then
		return 0
	end
	if listname == "main" and bot_inv_item_name(pos, index) and
				name ~= bot_inv_item_name(pos, index) then
		return 0
	end
	if listname == "filter" then
		local inv = M(pos):get_inventory()
		local list = inv:get_list(listname)
		if list[index]:get_count() == 0 or stack:get_name() ~= list[index]:get_name() then
			return 1
		end
		return 0
	end
	return stack:get_count()
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local mem = tubelib2.get_mem(pos)
	if mem.running then
		return 0
	end
	return stack:get_count()
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local mem = tubelib2.get_mem(pos)
	if mem.running then
		return 0
	end
	if from_list ~= to_list then
		return 0
	end
	local inv = M(pos):get_inventory()
	local name = inv:get_stack(from_list, from_index):get_name()
	if to_list == "main" and bot_inv_item_name(pos, to_index) and
				name ~= bot_inv_item_name(pos, to_index) then
		return 0
	end
	if to_list == "filter" then
		local list = inv:get_list(to_list)
		if list[to_index]:get_count() == 0 or name ~= list[to_index]:get_name() then
			return 1
		end
		return 0
	end
	return count
end

local drop = "signs_bot:box"
if minetest.global_exists("techage") then
	drop = ""
end

minetest.register_node("signs_bot:box", {
	description = S("Signs Bot Box"),
	stack_max = 1,
	tiles = {
		-- up, down, right, left, back, front
		'signs_bot_base_top.png',
		'signs_bot_base_top.png',
		'signs_bot_base_right.png',
		'signs_bot_base_left.png',
		'signs_bot_base_front.png',
		'signs_bot_base_front.png',
	},

	on_construct = function(pos)
		local meta = M(pos)
		local inv = meta:get_inventory()
		inv:set_size('main', 8)
		inv:set_size('sign', 6)
		inv:set_size('filter', 8)
	end,

	after_place_node = function(pos, placer, itemstack)
		if not placer or not placer:is_player() then
			minetest.remove_node(pos)
			minetest.add_item(pos, itemstack)
			return
		end
		local mem = tubelib2.init_mem(pos)
		mem.running = false
		mem.error = false
		local meta = M(pos)
		local number = ""
		if minetest.global_exists("techage") then
			number = techage.add_node(pos, "signs_bot:box")
		end
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("number", number)
		meta:set_string("formspec", formspec(pos, mem))
		meta:set_string("signs_bot_cmnd", "turn_off")
		meta:set_int("err_code", 0)
		signs_bot.infotext(pos, S("stopped"))
		if minetest.global_exists("techage") then
			techage.ElectricCable:after_place_node(pos)
			mem.capa = get_capa(itemstack)
		end
	end,

	signs_bot_get_signal = signs_bot_get_signal,
	signs_bot_on_signal = signs_bot_on_signal,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	allow_metadata_inventory_move = allow_metadata_inventory_move,

	can_dig = function(pos, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end
		local mem = tubelib2.get_mem(pos)
		if mem.running then
			return
		end
		local inv = M(pos):get_inventory()
		return inv:is_empty("main") and inv:is_empty("sign")
	end,

	on_dig = function(pos, node, puncher, pointed_thing)
		minetest.node_dig(pos, node, puncher, pointed_thing)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		if minetest.global_exists("techage") then
			techage.ElectricCable:after_dig_node(pos)
			local mem = tubelib2.get_mem(pos)
			set_capa(pos, oldnode, digger, mem.capa)
		end
		tubelib2.del_mem(pos)
	end,

	on_timer = node_timer,
	on_rotate = screwdriver.disallow,

	drop = drop,
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {cracky = 1},
	sounds = default.node_sound_metal_defaults(),
})


if minetest.global_exists("techage") then
	minetest.register_craft({
		output = "signs_bot:box",
		recipe = {
			{"default:steel_ingot", "group:wood", "default:steel_ingot"},
			{"basic_materials:motor", "techage:ta4_wlanchip", "basic_materials:gear_steel"},
			{"default:tin_ingot", "", "default:tin_ingot"}
		}
	})
else
	minetest.register_craft({
		output = "signs_bot:box",
		recipe = {
			{"default:steel_ingot", "group:wood", "default:steel_ingot"},
			{"basic_materials:motor", "default:mese_crystal", "basic_materials:gear_steel"},
			{"default:tin_ingot", "", "default:tin_ingot"}
		}
	})
end


if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "box", {
		name = S("Signs Bot Box"),
		data = {
			item = "signs_bot:box",
			text = table.concat({
				S("The Box is the housing of the bot."),
				S("Place the box and start the bot by means of the 'On' button."),
				S("If the mod techage is installed, the bot needs electrical power."),
				"",
				S("The bot leaves the box on the right side."),
				S("It will not start, if this position is blocked."),
				"",
				S("To stop and remove the bot, press the 'Off' button."),
				"",
				S("The box inventory simulates the inventory of the bot."),
				S("You will not be able to access the inventory, if the bot is running."),
				S("The bot can carry up to 8 stacks and 6 signs with it."),
			}, "\n")
		},
	})
end
