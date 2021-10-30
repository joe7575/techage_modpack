--[[

	Signs Bot
	=========

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Bot flower cutting command
]]--

-- Load support for I18n.
local S = signs_bot.S

local lib = signs_bot.lib

local bot_inv_put_item = signs_bot.bot_inv_put_item
local bot_inv_take_item = signs_bot.bot_inv_take_item

local Flowers = {}


-- Special drop handling is necessary because of waterlily.
function signs_bot.register_flower(name)
	local drop = signs_bot.lib.is_simple_node({name = name})
	if drop then
		Flowers[name] = drop
	end
end

signs_bot.register_flower("default:bush_stem")
signs_bot.register_flower("default:acacia_bush_stem")
signs_bot.register_flower("default:pine_bush_stem")

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

local function is_tree(node)
	if minetest.get_item_group(node.name, "tree") == 1 then
		return signs_bot.handle_drop_like_a_player(node)
	end
	if minetest.get_item_group(node.name, "leaves") == 1 then
		return signs_bot.handle_drop_like_a_player(node)
	end
end

local function harvesting(base_pos, mem)
	local pos = mem.pos_tbl and mem.pos_tbl[mem.steps]
	mem.steps = (mem.steps or 1) + 1
	
	if pos and lib.not_protected(base_pos, pos) then
		local node = minetest.get_node_or_nil(pos)
		if node.name ~= "default:papyrus" then
			local drop = Flowers[node.name] or is_tree(node)
			if drop then
				minetest.remove_node(pos)
				local leftover = bot_inv_put_item(base_pos, 0,  ItemStack(drop))
				if leftover and leftover:get_count() > 0 then
					signs_bot.lib.drop_items(mem.robot_pos, leftover)
				end
			end
		else
			-- papyrus is a special plant that is collected upwards when cut
			local count = 0
			while node.name == "default:papyrus" and lib.not_protected(base_pos, pos) do
				minetest.remove_node(pos)
				pos = { x = pos.x, y = pos.y + 1, z = pos.z }
				count = count + 1
				node = minetest.get_node(pos)
			end
			if count > 0 then
				local leftover = bot_inv_put_item(base_pos, 0,  ItemStack("default:papyrus " .. count))
				if leftover and leftover:get_count() > 0 then
					signs_bot.lib.drop_items(mem.robot_pos, leftover)
				end
			end
		end
	end
end

signs_bot.register_botcommand("cutting", {
	mod = "farming",
	params = "",
	num_param = 0,
	description = S("Cutting flowers, papyrus,\nleaves and tree blocks\nin front of the robot\non a 3x3 field."),
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
	description = S('Sign "flowers"'), 
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
		name = S("Sign 'flowers'"),
		data = {
			item = "signs_bot:flowers",
			text = table.concat({
				S("Used to cut flowers on a 3x3 field."),
				S("Place the sign in front of the field."), 
				S("When finished, the bot turns."),
			}, "\n")		
		},
	})
end
