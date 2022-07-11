--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Bot farming commands
]]--

-- Load support for I18n.
local S = signs_bot.S

local lib = signs_bot.lib

local bot_inv_put_item = signs_bot.bot_inv_put_item
local bot_inv_take_item = signs_bot.bot_inv_take_item

local function soil_availabe(pos, trellis)
	local node = minetest.get_node_or_nil(pos)
	if node.name == (trellis or "air") then
		node = minetest.get_node_or_nil({x=pos.x, y=pos.y-1, z=pos.z})
		if node and minetest.get_item_group(node.name, "soil") >= 1 then
			return true
		end
	end
	return false
end

local function planting(base_pos, mem, slot)
	local pos = mem.pos_tbl and mem.pos_tbl[mem.steps]
	mem.steps = (mem.steps or 1) + 1
	if pos and lib.not_protected(base_pos, pos) then
		local stack = bot_inv_take_item(base_pos, slot, 1)
		if stack and stack ~= "" then
			local plant = stack:get_name()
			if plant then
				local item = signs_bot.FarmingSeed[plant]
				if item and soil_availabe(pos, signs_bot.FarmingNeedTrellis[item]) then
					if minetest.registered_nodes[item] then
						local p2 = minetest.registered_nodes[item].place_param2 or 1
						minetest.set_node(pos, {name = item, param2 = p2})
					else
						minetest.set_node(pos, {name = item})
					end
					minetest.sound_play("default_place_node", {pos = pos, gain = 1.0})
				else
					bot_inv_put_item(base_pos, 0,  ItemStack(plant))
				end
			end
		end
	end
end	

signs_bot.register_botcommand("sow_seed", {
	mod = "farming",
	params = "<slot>",
	num_param = 1,
	description = S("Sow farming seeds\nin front of the robot"),
	check = function(slot)
		slot = tonumber(slot)
		return slot and slot > 0 and slot < 9
	end,
	cmnd = function(base_pos, mem, slot)
		slot = tonumber(slot)
		if not mem.steps then
			mem.pos_tbl = signs_bot.lib.gen_position_table(mem.robot_pos, mem.robot_param2, 3, 3, 0)
			mem.steps = 1
		end
		mem.pos_tbl = mem.pos_tbl or {}
		planting(base_pos, mem, slot)
		if mem.steps > #mem.pos_tbl then
			mem.steps = nil
			return signs_bot.DONE
		end
		return signs_bot.BUSY
	end,
})

local function harvesting(base_pos, mem)
	local pos = mem.pos_tbl and mem.pos_tbl[mem.steps]
	mem.steps = (mem.steps or 1) + 1
	
	if pos and lib.not_protected(base_pos, pos) then
		local node = minetest.get_node_or_nil(pos)
		if signs_bot.FarmingCrop[node.name] then
			local trellis = signs_bot.FarmingKeepTrellis[node.name]
			if trellis then
				minetest.set_node(pos, {name = trellis})
			elseif not trellis then
				minetest.remove_node(pos)
			end
			-- Do not cache the result of get_node_drops; it is a probabilistic function!
			local drops = minetest.get_node_drops(node.name)
			for _,itemstring in ipairs(drops) do
				if not trellis or trellis ~= itemstring then
					local leftover = bot_inv_put_item(base_pos, 0,  ItemStack(itemstring))
					if leftover and leftover:get_count() > 0 then
						signs_bot.lib.drop_items(mem.robot_pos, leftover)
					end
				end
			end
		end
	end
end

signs_bot.register_botcommand("harvest", {
	mod = "farming",
	params = "",
	num_param = 0,
	description = S("Harvest farming products\nin front of the robot\non a 3x3 field."),
	cmnd = function(base_pos, mem)
		if not mem.steps then
			mem.pos_tbl = signs_bot.lib.gen_position_table(mem.robot_pos, mem.robot_param2, 3, 3, 0)
			mem.steps = 1
		end
		mem.pos_tbl = mem.pos_tbl or {}
		harvesting(base_pos, mem)
		if mem.steps > #mem.pos_tbl then
			mem.steps = nil
			return signs_bot.DONE
		end
		return signs_bot.BUSY
	end,
})


local function plant_sapling(base_pos, mem, slot)
	local pos = lib.dest_pos(mem.robot_pos, mem.robot_param2, {0})
	if lib.not_protected(base_pos, pos) and soil_availabe(pos) then
		local stack = bot_inv_take_item(base_pos, slot, 1)
		local item = stack and signs_bot.TreeSaplings[stack:get_name()]
		if item and item.sapling then
			minetest.set_node(pos, {name = item.sapling, paramtype2 = "wallmounted", param2 = 1})
			if item.t1 ~= nil then 
				-- We have to simulate "on_place" and start the timer by hand
				-- because the after_place_node function checks player rights and can't therefore
				-- be used.
				minetest.get_node_timer(pos):start(math.random(item.t1, item.t2))
			end			
		end
	end
end	

signs_bot.register_botcommand("plant_sapling", {
	mod = "farming",
	params = "<slot>",
	num_param = 1,
	description = S("Plant a sapling\nin front of the robot"),
	check = function(slot)
		slot = tonumber(slot)
		return slot and slot > 0 and slot < 9
	end,
	cmnd = function(base_pos, mem, slot)
		slot = tonumber(slot)
		plant_sapling(base_pos, mem, slot)
		return signs_bot.DONE
	end,
})


local CMD = [[dig_sign 1
move
harvest
sow_seed 1
backward
place_sign 1
turn_around]]

signs_bot.register_sign({
	name = "farming", 
	description = S('Sign "farming"'), 
	commands = CMD, 
	image = "signs_bot_sign_farming.png",
})

minetest.register_craft({
	output = "signs_bot:farming 2",
	recipe = {
		{"group:wood", "default:stick", "group:wood"},
		{"dye:black", "default:stick", "dye:yellow"},
		{"dye:grey", "", ""}
	}
})

if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "farming", {
		name = S("Sign 'farming'"),
		data = {
			item = "signs_bot:farming",
			text = table.concat({
				S("Used to harvest and seed a 3x3 field."),
				S("Place the sign in front of the field."), 
				S("The seed to be placed has to be in the first inventory slot of the bot."),
				S("When finished, the bot turns."),
			}, "\n")		
		},
	})
end
