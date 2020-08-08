-- Load support for intllib.
local MP = minetest.get_modpath("signs_bot")
local S, NS = dofile(MP.."/intllib.lua")

local CYCLE_TIME = 4

if minetest.get_modpath("techage") then
	
	local Cable = techage.ElectricCable
	local power = techage.power
	
	signs_bot.register_inventory({"techage:chest_ta2", "techage:chest_ta3", "techage:chest_ta4"}, {
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
			local node = signs_bot.lib.get_node_lvm(pos)
			if minetest.registered_nodes[node.name]
			and minetest.registered_nodes[node.name].on_ignite then
				minetest.registered_nodes[node.name].on_ignite(pos)
			end
			return true
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
	

    -- Bot in the box
	function signs_bot.while_charging(pos, mem)
		mem.capa = mem.capa or 0
		if mem.power_available then
			if mem.capa < signs_bot.MAX_CAPA then
				local taken = power.consumer_alive(pos, Cable, CYCLE_TIME)
				mem.capa = mem.capa + taken
			else
				power.consumer_stop(pos, Cable)
				minetest.get_node_timer(pos):stop()
				mem.charging = false
				if not mem.running then
					signs_bot.infotext(pos, S("fully charged"))
				end
				return false
			end
		else
			power.consumer_start(pos, Cable, CYCLE_TIME)
		end
		return true
	end
	
	Cable:add_secondary_node_names({"signs_bot:box"})

	techage.register_node({"signs_bot:box"}, {
		on_pull_item = function(pos, in_dir, num)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return techage.get_items(pos, inv, "main", num)
		end,
		on_push_item = function(pos, in_dir, stack)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return techage.put_items(inv, "main", stack)
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
						return "loading"
					end
				else
					return "stopped"
				end
			elseif topic == "load" then
				return signs_bot.percent_value(signs_bot.MAX_CAPA, mem.capa)
			else
				return "unsupported"
			end
		end,
	})	
	techage.register_node({"signs_bot:chest"}, {
		on_pull_item = function(pos, in_dir, num)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return techage.get_items(pos, inv, "main", num)
		end,
		on_push_item = function(pos, in_dir, stack)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return techage.put_items(inv, "main", stack)
		end,
		on_unpull_item = function(pos, in_dir, stack)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return techage.put_items(inv, "main", stack)
		end,
	})	
	
else
	function signs_bot.formspec_battery_capa(max_capa, current_capa)
		return ""
	end
end