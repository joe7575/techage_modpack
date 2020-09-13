--[[

	Signs Bot
	=========

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Bot flower cutting command
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("signs_bot")
local I,_ = dofile(MP.."/intllib.lua")

local lib = signs_bot.lib

local bot_inv_put_item = signs_bot.bot_inv_put_item
local bot_inv_take_item = signs_bot.bot_inv_take_item

local Flowers = {}

function signs_bot.register_flower(name)
	Flowers[name] = true
end

minetest.after(1, function()
	for _,def in pairs(minetest.registered_decorations) do
		local name = def.decoration
		if name and type(name) == "string" then
			local mod = string.split(name, ":")[1]
			if mod == "flowers" or mod == "bakedclay" then -- Bakedclay also registers flowers as decoration.
				signs_bot.register_flower(name)
			end
		end
	end
end)

local function soil_availabe(pos)
	local node = minetest.get_node_or_nil(pos)
	if node.name == "air" then
		node = minetest.get_node_or_nil({x=pos.x, y=pos.y-1, z=pos.z})
		if node and minetest.get_item_group(node.name, "soil") >= 1 then
			return true
		end
	end
	return false
end

local function harvesting(base_pos, mem)
	local pos = mem.pos_tbl and mem.pos_tbl[mem.steps]
	mem.steps = (mem.steps or 1) + 1
	
	if pos and lib.not_protected(base_pos, pos) then
		local node = minetest.get_node_or_nil(pos)
		if Flowers[node.name] then
			minetest.remove_node(pos)
			bot_inv_put_item(base_pos, 0,  ItemStack(node.name))
		end
	end
end

signs_bot.register_botcommand("cutting", {
	mod = "farming",
	params = "",
	num_param = 0,
	description = I("Cutting flowers\nin front of the robot\non a 3x3 field."),
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

local CMD = [[dig_sign 1
move
cutting
backward
place_sign 1
turn_around]]

signs_bot.register_sign({
	name = "flowers", 
	description = I('Sign "flowers"'), 
	commands = CMD, 
	image = "signs_bot_sign_flowers.png",
})

minetest.register_craft({
	output = "signs_bot:flowers 2",
	recipe = {
		{"group:wood", "default:stick", "group:wood"},
		{"dye:black", "default:stick", "dye:yellow"},
		{"dye:red", "", ""}
	}
})

if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "flowers", {
		name = I("Sign 'flowers'"),
		data = {
			item = "signs_bot:flowers",
			text = table.concat({
				I("Used to cut flowers on a 3x3 field."),
				I("Place the sign in front of the field."), 
				I("When finished, the bot turns."),
			}, "\n")		
		},
	})
end
