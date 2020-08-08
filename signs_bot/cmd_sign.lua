--[[

	Signs Bot
	=========

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Bot sign commands and nodes

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("signs_bot")
local I,_ = dofile(MP.."/intllib.lua")

local lib = signs_bot.lib

local sCmnds = ""
local lCmnds = {}
local tCmndIdx = {}

minetest.after(2, function() 
	for idx,cmnd in ipairs(signs_bot.get_commands()) do
		cmnd = minetest.formspec_escape(cmnd)
		lCmnds[#lCmnds+1] = cmnd
		tCmndIdx[cmnd] = idx
	end
	sCmnds = table.concat(lCmnds, ",")
end)


local function formspec1(meta)
	local cmnd = meta:get_string("signs_bot_cmnd")
	local name = meta:get_string("sign_name")
	local err_msg = meta:get_string("err_msg")
	cmnd = minetest.formspec_escape(cmnd)
	name = minetest.formspec_escape(name)
	return "size[9,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"style_type[textarea,table;font=mono]"..
	"tabheader[0,0;tab;"..I("Commands,Help")..";1;;true]"..
	"field[0.3,0.5;9,1;name;"..I("Sign name:")..";"..name.."]"..
	"textarea[0.3,1.2;9,7.2;cmnd;;"..cmnd.."]"..
	"label[0.3,7.5;"..err_msg.."]"..
	"button_exit[5,7.5;2,1;cancel;"..I("Cancel").."]"..
	"button[7,7.5;2,1;check;"..I("Check").."]"
end

local function formspec2(pos, text)
	return "size[9,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"style_type[textarea,table;font=mono]"..
	"tabheader[0,0;tab;"..I("Commands,Help")..";2;;true]"..
	"table[0.1,0;8.6,4;command;"..sCmnds..";"..pos.."]"..
	"textarea[0.3,4.5;9,3.5;help;Help:;"..text.."]"..
	"button[3,7.5;3,1;copy;"..I("Copy Cmnd").."]"
end

local function add_arrow(text, line_num)
	local tbl = {}
	for idx,line in ipairs(string.split(text, "\n", true)) do
		if idx == line_num and not string.find(line, '--<<== error') then
			tbl[#tbl+1] = line.."  --<<== error"
		else
			tbl[#tbl+1] = line
		end
	end
	return table.concat(tbl, "\n")
end	

local function check_syntax(pos, meta, text)
	local res,err_msg, line_num = signs_bot.check_commands(pos, text)
	meta:set_int("err_code", res and 0 or 1) -- zero means OK
	meta:set_string("err_msg", err_msg)
	if line_num > 0 then
		meta:set_string("signs_bot_cmnd", add_arrow(text, line_num))
	end
end

local function append_line(pos, meta, line)
	line = line and line:trim() or ""
	local text = meta:get_string("signs_bot_cmnd").."\n"..line
	meta:set_string("signs_bot_cmnd", text)
	meta:set_int("err_code", 1) -- zero means OK
	meta:set_string("err_msg", "please check the added line(s)")
end	
	
local function check_and_store(pos, meta, fields)	
	meta:set_string("sign_name", fields.name)
	meta:set_string("signs_bot_cmnd", fields.cmnd)
	check_syntax(pos, meta, fields.cmnd)
	meta:set_string("formspec", formspec1(meta))
	meta:set_string("infotext", meta:get_string("sign_name"))
end

minetest.register_node("signs_bot:sign_cmnd", {
	description = I('Sign "command"'),
	drawtype = "nodebox",
	inventory_image = "signs_bot_sign_cmnd.png",
	node_box = {
		type = "fixed",
		fixed = {
			{ -1/16, -8/16, -1/16,   1/16, 4/16, 1/16},
			{ -6/16, -5/16, -2/16,   6/16, 3/16, -1/16},
		},
	},
	paramtype2 = "facedir",
	tiles = {
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png^signs_bot_sign_cmnd.png",
	},
	after_place_node = function(pos, placer, itemstack)
		local imeta = itemstack:get_meta()
		local nmeta = minetest.get_meta(pos)
		if imeta:get_string("description") ~= ""  then
			nmeta:set_string("signs_bot_cmnd", imeta:get_string("cmnd"))
			nmeta:set_string("sign_name", imeta:get_string("description"))
			nmeta:set_string("err_msg", imeta:get_string("err_msg"))
			nmeta:set_int("err_code", imeta:get_int("err_code"))
		else
			nmeta:set_string("sign_name", I('Sign "command"'))
			nmeta:set_string("signs_bot_cmnd", I("-- enter or copy commands from help page"))
			nmeta:set_int("err_code", 0)
		end
		nmeta:set_string("infotext", nmeta:get_string("sign_name"))
		nmeta:set_string("formspec", formspec1(nmeta))
	end,
	
	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end
		local meta = minetest.get_meta(pos)
		if fields.check then
			check_and_store(pos, meta, fields)
		elseif fields.key_enter_field then
			check_and_store(pos, meta, fields)
		elseif fields.copy then
			append_line(pos, meta, lCmnds[meta:get_int("help_pos")])
		elseif fields.tab == "1" then
			meta:set_string("formspec", formspec1(meta))
		elseif fields.tab == "2" then
			check_and_store(pos, meta, fields)
			local pos = meta:get_int("help_pos")
			local cmnd = lCmnds[pos] or ""
			meta:set_string("formspec", formspec2(pos, signs_bot.get_help_text(cmnd)))
		elseif fields.command then
			local evt = minetest.explode_table_event(fields.command)
			if evt.type == "DCL" then
				append_line(pos, meta, lCmnds[tonumber(evt.row)])
			elseif evt.type == "CHG" then
				local pos = tonumber(evt.row)
				meta:set_int("help_pos", pos)
				local cmnd = lCmnds[pos] or ""
				meta:set_string("formspec", formspec2(pos, signs_bot.get_help_text(cmnd)))
			end
		end
	end,
	
	after_dig_node = lib.after_dig_sign_node,
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	drop = "",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, sign_bot_sign = 1},
	sounds = default.node_sound_wood_defaults(),
})


-- Get one sign from the robot signs inventory
local function get_inv_sign(base_pos, slot)
	local inv = minetest.get_inventory({type="node", pos=base_pos})
	local stack = inv:get_stack("sign", slot)
	local taken = stack:take_item(1)
	if taken:get_count() == 1 then
		inv:set_stack("sign", slot, stack)
		return taken
	end
end
			
-- Put one sign into the robot signs inventory
local function put_inv_sign(base_pos, slot, item)
	local inv = minetest.get_inventory({type="node", pos=base_pos})
	local stack = inv:get_stack("sign", slot)
	local leftovers = stack:add_item(item)
	if leftovers:get_count() == 0 then
		inv:set_stack("sign", slot, stack)
		return true
	end
	return false
end

local function place_sign(base_pos, robot_pos, param2, slot)
	local pos1 = lib.dest_pos(robot_pos, param2, {0})
	if lib.not_protected(base_pos, pos1) then
		if lib.is_air_like(pos1) then
			local sign = get_inv_sign(base_pos, slot)
			if sign then
				lib.place_sign(pos1, sign, param2)
				return signs_bot.DONE
			else
				return signs_bot.ERROR, I("Error: Signs inventory empty")
			end
		end
	end
	return signs_bot.ERROR, I("Error: Position protected or occupied")
end

signs_bot.register_botcommand("place_sign", {
	mod = "sign",
	params = "<slot>",
	num_param = 1,
	description = I("Place a sign in front of the robot\ntaken from the signs inventory\n"..
		"<slot> is the inventory slot (1..6)"),
	check = function(slot)
		slot = tonumber(slot) or 1
		return slot and slot > 0 and slot < 7
	end,
	cmnd = function(base_pos, mem, slot)
		slot = tonumber(slot) or 1
		return place_sign(base_pos, mem.robot_pos, mem.robot_param2, slot)
	end,
})

local function place_sign_behind(base_pos, robot_pos, param2, slot)
	local pos1 = lib.dest_pos(robot_pos, param2, {2})
	if lib.not_protected(base_pos, pos1) then
		if lib.is_air_like(pos1) then
			local sign = get_inv_sign(base_pos, slot)
			if sign then
				lib.place_sign(pos1, sign, param2)
				return signs_bot.DONE
			else
				return signs_bot.ERROR, I("Error: Signs inventory empty")
			end
		end
	end
	return signs_bot.ERROR, I("Error: Position protected or occupied")
end

signs_bot.register_botcommand("place_sign_behind", {
	mod = "sign",
	params = "<slot>",
	num_param = 1,
	description = I("Place a sign behind the robot\ntaken from the signs inventory\n"..
		"<slot> is the inventory slot (1..6)"),
	check = function(slot)
		slot = tonumber(slot) or 1
		return slot and slot > 0 and slot < 7
	end,
	cmnd = function(base_pos, mem, slot)
		slot = tonumber(slot) or 1
		return place_sign_behind(base_pos, mem.robot_pos, mem.robot_param2, slot)
	end,
})

local function dig_sign(base_pos, robot_pos, param2, slot)
	local pos1 = lib.dest_pos(robot_pos, param2, {0})
	local meta =  M(pos1)
	local cmnd = meta:get_string("signs_bot_cmnd")
	local err_code = meta:get_int("err_code")
	local name = meta:get_string("sign_name")
	if cmnd == "" then
		return signs_bot.ERROR, I("Error: No sign available")
	end
	if lib.not_protected(base_pos, pos1) then
		local node = lib.get_node_lvm(pos1)
		local sign = ItemStack(node.name)
		local meta = sign:get_meta()
		meta:set_string("description", name)
		meta:set_string("cmnd", cmnd)
		meta:set_int("err_code", err_code)
		minetest.remove_node(pos1)
		if not put_inv_sign(base_pos, slot, sign) then	
			signs_bot.lib.drop_items(robot_pos, sign)
			return signs_bot.ERROR, I("Error: Signs inventory slot is occupied")
		end
		return signs_bot.DONE
	end
	return signs_bot.ERROR, I("Error: Position is protected")
end

signs_bot.register_botcommand("dig_sign", {
	mod = "sign",
	params = "<slot>",
	num_param = 1,
	description = I("Dig the sign in front of the robot\n"..
		"and add it to the signs inventory.\n"..
		"<slot> is the inventory slot (1..6)"),
	check = function(slot)
		slot = tonumber(slot) or 1
		return slot and slot > 0 and slot < 7
	end,
	cmnd = function(base_pos, mem, slot)
		slot = tonumber(slot) or 1
		return dig_sign(base_pos, mem.robot_pos, mem.robot_param2, slot)
	end,
})

local function trash_sign(base_pos, robot_pos, param2, slot)
	local pos1 = lib.dest_pos(robot_pos, param2, {0})
	local cmnd = M(pos1):get_string("signs_bot_cmnd")
	if cmnd == "" then
		return signs_bot.ERROR, I("Error: No sign available")
	end
	if lib.not_protected(base_pos, pos1) then
		local node = lib.get_node_lvm(pos1)
		local sign = ItemStack("signs_bot:sign_cmnd")
		minetest.remove_node(pos1)
		signs_bot.bot_inv_put_item(base_pos, slot, sign)
		return signs_bot.DONE
	end
	return signs_bot.ERROR, I("Error: Position is protected")
end

signs_bot.register_botcommand("trash_sign", {
	mod = "sign",
	params = "<slot>",	
	num_param = 1,
	description = I("Dig the sign in front of the robot\n"..
		"and add the cleared sign to\nthe item iventory.\n"..
		"<slot> is the inventory slot (1..8)"),
	check = function(slot)
		slot = tonumber(slot) or 1
		return slot and slot > 0 and slot < 9
	end,
	cmnd = function(base_pos, mem, slot)
		slot = tonumber(slot) or 1
		return trash_sign(base_pos, mem.robot_pos, mem.robot_param2, slot)
	end,
})
	

minetest.register_craft({
	output = "signs_bot:sign_cmnd 4",
	recipe = {
		{"group:wood", "default:stick", "group:wood"},
		{"dye:yellow", "default:stick", "dye:yellow"},
		{"", "dye:black", ""}
	}
})

if minetest.get_modpath("doc") then
	doc.add_entry("signs_bot", "sign_cmnd", {
		name = I("Sign 'command'"),
		data = {
			item = "signs_bot:sign_cmnd",
			text = table.concat({
				I("The 'command' sign can be programmed by the player."),
				I("Place the sign in front of you and use the node menu to program your sequence of bot commands."), 
				I("The menu has an edit field for your commands and a help page with all available commands."),
				I("The help page has a copy button to simplify the programming."),
			}, "\n")		
		},
	})
end

