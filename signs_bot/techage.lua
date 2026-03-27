--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPLv3
	See LICENSE.txt for more information

	Signs Bot: interface for techage

]]--

-- Load support for I18n.
local S = signs_bot.S

local MAX_CAPA = signs_bot.MAX_CAPA
local PWR_NEEDED = 8

if minetest.global_exists("techage") then

	local function on_power(pos)
		local mem = tubelib2.get_mem(pos)
		mem.power_available = true
		mem.charging = true
		signs_bot.infotext(pos, S("charging"))
	end

	local function on_nopower(pos)
		local mem = tubelib2.get_mem(pos)
		mem.power_available = false
		signs_bot.infotext(pos, S("no power"))
	end

	local Cable = techage.ElectricCable
	local power = networks.power

	signs_bot.register_inventory({"techage:chest_ta2", "techage:chest_ta3", "techage:chest_ta4",
			"techage:ta3_silo", "techage:ta4_silo", "techage:ta4_sensor_chest",
			"techage:ta4_reactor"}, {
		allow_inventory_put = function(pos, stack, player_name)
			return not minetest.is_protected(pos, player_name)
		end,
		allow_inventory_take = function(pos, stack, player_name)
			return not minetest.is_protected(pos, player_name)
		end,
		put = {
			listname = "main",
		},
		take = {
			listname = "main",
		},
	})
	signs_bot.register_inventory({"techage:meltingpot", "techage:meltingpot_active"}, {
		allow_inventory_put = function(pos, stack, player_name)
			return not minetest.is_protected(pos, player_name)
		end,
		allow_inventory_take = function(pos, stack, player_name)
			return not minetest.is_protected(pos, player_name)
		end,
		put = {
			listname = "src",
		},
		take = {
			listname = "dst",
		},
	})
	signs_bot.register_inventory({
			"techage:ta2_autocrafter_pas", "techage:ta2_autocrafter_act",
			"techage:ta3_autocrafter_pas", "techage:ta3_autocrafter_act"}, {
		allow_inventory_put = function(pos, stack, player_name)
			return not minetest.is_protected(pos, player_name)
		end,
		allow_inventory_take = function(pos, stack, player_name)
			return not minetest.is_protected(pos, player_name)
		end,
		put = {
			listname = "src",
		},
		take = {
			listname = "dst",
		},
	})
	signs_bot.register_inventory({
			"techage:ta2_distributor_pas", "techage:ta2_distributor_act",
			"techage:ta3_distributor_pas", "techage:ta3_distributor_act",
			"techage:ta4_distributor_pas", "techage:ta4_distributor_act",
			"techage:ta4_high_performance_distributor_pas", "techage:ta4_high_performance_distributor_act"}, {
		allow_inventory_put = function(pos, stack, player_name)
			return not minetest.is_protected(pos, player_name)
		end,
		allow_inventory_take = function(pos, stack, player_name)
			return not minetest.is_protected(pos, player_name)
		end,
		put = {
			listname = "src",
		},
		take = {
			listname = "src",
		},
	})

	local function percent_value(max_val, curr_val)
		return math.min(math.ceil(((curr_val or 0) * 100.0) / (max_val or 1.0)), 100)
	end
	signs_bot.percent_value = percent_value

	function signs_bot.formspec_battery_capa(max_capa, current_capa)
		local percent = percent_value(max_capa, current_capa)
		return "image[0.1,0;0.5,1;signs_bot_form_level_bg.png^[lowpart:"..
				percent..":signs_bot_form_level_fg.png]"
	end

	signs_bot.register_botcommand("ignite", {
		mod = "techage",
		params = "",
		num_param = 0,
		description = S("Ignite the techage charcoal lighter"),
		cmnd = function(base_pos, mem)
			local pos = signs_bot.lib.dest_pos(mem.robot_pos, mem.robot_param2, {0})
			local node = tubelib2.get_node_lvm(pos)
			if minetest.registered_nodes[node.name]
			and minetest.registered_nodes[node.name].on_ignite then
				minetest.registered_nodes[node.name].on_ignite(pos)
			end
			return signs_bot.DONE
		end,
	})

	signs_bot.register_botcommand("low_batt", {
		mod = "techage",
		params = "<percent>",
		num_param = 1,
		description = S("Turns the bot off if the\nbattery power is below the\ngiven value in percent (1..99)"),
		check = function(val)
			val = tonumber(val) or 5
			return val and val > 0 and val < 100
		end,
		cmnd = function(base_pos, mem, val)
			val = tonumber(val) or 5
			local pwr = percent_value(signs_bot.MAX_CAPA, mem.capa)
			if pwr < val then
				signs_bot.stop_robot(base_pos, mem)
				return signs_bot.TURN_OFF
			end
			return signs_bot.DONE
		end,
	})

	signs_bot.register_botcommand("jump_low_batt", {
		mod = "techage",
		params = "<percent> <label>",
		num_param = 2,
		description = S("Jump to <label> if the\nbattery power is below the\ngiven value in percent (1..99)"),
		check = function(val, lbl)
			val = tonumber(val) or 5
			return val and val > 0 and val < 100 and signs_bot.check_label(lbl)
		end,
		cmnd = function(base_pos, mem, val, addr)
			val = tonumber(val) or 5
			local pwr = percent_value(signs_bot.MAX_CAPA, mem.capa)
			if pwr < val then
				mem.pc = addr - 3
				return signs_bot.DONE
			end
			return signs_bot.DONE
		end,
	})

	signs_bot.register_botcommand("send_cmnd", {
		mod = "techage",
		params = "<receiver> <command>",
		num_param = 2,
		description = S([[Sends a techage command
to a given node.
Receiver is addressed by
the techage node number.
For commands with two or more
words, use the '*' character
instead of spaces, e.g.:
send_cmnd 3465 pull*default:dirt*2]]),
		check = function(address, command)
			address = tonumber(address)
			return address ~= nil and command ~= nil and command ~= ""
		end,
		cmnd = function(base_pos, mem, address, command)
			command = tostring(command)
			command = command:gsub("*", " ")
			address = tostring(tonumber(address))
			local meta = minetest.get_meta(base_pos)
			local number = tostring(meta:get_int("number") or 0)
			local topic, payload = unpack(string.split(command, " ", false, 1))
			techage.send_single(number, address, topic, payload)
			return signs_bot.DONE
		end,
	})


    -- Bot in the box
	function signs_bot.while_charging(pos, mem)
		mem.capa = mem.capa or 0

		if mem.capa < signs_bot.MAX_CAPA then
			local consumed = power.consume_power(pos, Cable, nil, PWR_NEEDED)
			mem.capa = mem.capa + consumed
		else
			minetest.get_node_timer(pos):stop()
			mem.charging = false
			if not mem.running then
				signs_bot.infotext(pos, S("fully charged"))
			end
			return false
		end
		return true
	end

	power.register_nodes({"signs_bot:box"}, Cable, "con")

	techage.register_node({"signs_bot:box"}, {
		on_inv_request = function(pos, in_dir, access_type)
			local meta = minetest.get_meta(pos)
			return meta:get_inventory(), "main"
		end,
		on_pull_item = function(pos, in_dir, num, item_name)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if item_name then
				local taken = inv:remove_item("main", {name = item_name, count = num})
				if taken:get_count() > 0 then
					return taken
				end
			else -- no item given
				return techage.get_items(pos, inv, "main", num)
			end
		end,
		on_push_item = function(pos, in_dir, stack, idx)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return techage.put_items(inv, "main", stack, idx)
		end,
		on_unpull_item = function(pos, in_dir, stack)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return techage.put_items(inv, "main", stack)
		end,

		on_recv_message = function(pos, src, topic, payload)
			local mem = tubelib2.get_mem(pos)
			if topic == "state" then
				if mem.error then
					return "fault"
				elseif mem.running then
					if mem.curr_cmnd == "stop" then
						return "standby"
					elseif mem.blocked then
						return "blocked"
					else
						return "running"
					end
				elseif mem.capa then
					if mem.capa <= 0 then
						return "nopower"
					elseif mem.capa >= signs_bot.MAX_CAPA then
						return "stopped"
					else
						return "charging"
					end
				else
					return "stopped"
				end
			elseif topic == "load" then
				return signs_bot.percent_value(signs_bot.MAX_CAPA, mem.capa)
			elseif topic == "on" then
				if not mem.running then
					signs_bot.start_robot(pos)
				end
			elseif topic == "off" then
				if mem.running then
					signs_bot.stop_robot(pos, mem)
				end
			else
				return "unsupported"
			end
		end,
		on_beduino_receive_cmnd = function(pos, src, topic, payload)
			local mem = tubelib2.get_mem(pos)
			if topic == 1 then
				if payload[1] == 1 then -- on
					if not mem.running then
						signs_bot.start_robot(pos)
						return 0, {1}
					end
				else
					if mem.running then
						signs_bot.stop_robot(pos, mem)
						return 0, {1}
					end
				end
			else
				return 2, ""  -- topic is unknown or invalid
			end
		end,
		on_beduino_request_data = function(pos, src, topic, payload)
			local mem = tubelib2.get_mem(pos)
			if topic == 129 then -- state
				if mem.error then
					return 0, {5}
				elseif mem.running then
					if mem.curr_cmnd == "stop" then
						return 0, {3}
					elseif mem.blocked then
						return 0, {2} 
					else
						return 0, {1}  -- running
					end
				elseif mem.capa then
					if mem.capa <= 0 then
						return 0, {4}  -- nopower
					elseif mem.capa >= signs_bot.MAX_CAPA then
						return 0, {6}  -- stopped
					else
						return 0, {7}  -- charging
					end
				else
					return 0, {6}  -- stopped
				end
			else
				return 2, ""  -- topic is unknown or invalid
			end
		end,
	})
	techage.register_node({"signs_bot:chest"}, {
		on_inv_request = function(pos, in_dir, access_type)
			local meta = minetest.get_meta(pos)
			return meta:get_inventory(), "main"
		end,
		on_pull_item = function(pos, in_dir, num, item_name)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if item_name then
				local taken = inv:remove_item("main", {name = item_name, count = num})
				if taken:get_count() > 0 then
					return taken
				end
			else -- no item given
				return techage.get_items(pos, inv, "main", num)
			end
		end,
		on_push_item = function(pos, in_dir, stack, idx)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return techage.put_items(inv, "main", stack, idx)
		end,
		on_unpull_item = function(pos, in_dir, stack)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return techage.put_items(inv, "main", stack)
		end,
	})

	techage.register_node_for_v1_transition({"signs_bot:box"}, function(pos, node)
		power.update_network(pos, nil, Cable)
	end)

	techage.disable_block_for_assembly_tool("signs_bot:box")
else
	function signs_bot.formspec_battery_capa(max_capa, current_capa)
		return ""
	end
end

