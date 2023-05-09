--[[

	Tower Crane Mod
	===============

	Copyright (C) 2017-2020 Joachim Stolberg
	LGPLv2.1+
	See LICENSE.txt for more information


	   Nodes      Meta data
	+--------+
	|        |  - last_known_pos as "(x,y,z)"
	| switch |  - last_used
	|        |  - running
	+--------+
	+--------+
	|        |  - owner
	|  base  |  - width
	|        |  - height
	+--------+  - dir as "(0,0,1)"
]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos

-- crane minimum size
local MIN_SIZE = 8

towercrane = {}

towercrane.S = minetest.get_translator("towercrane")
local S = towercrane.S
local MP = minetest.get_modpath("towercrane")
dofile(MP.."/config.lua")
dofile(MP.."/control.lua")

-------------------------------------------------------------------------------
-- Helper functions
-------------------------------------------------------------------------------
local function chat(owner, text)
	if owner ~= nil then
		minetest.chat_send_player(owner, "[Tower Crane] "..text)
	end
end

local function formspec(height, width)
	local text = ""
	if height and width then
		text = height..","..width
	end
	return "size[5,4]"..
		"label[0,0;"..S("Construction area size").."]" ..
		"field[1,1.5;3,1;size;height,width;"..text.."]" ..
		"button_exit[1,2;2,1;exit;"..S("Build").."]"
end

local function get_node_lvm(pos)
	local node = minetest.get_node_or_nil(pos)
	if node then
		return node
	end
	local vm = minetest.get_voxel_manip()
	local MinEdge, MaxEdge = vm:read_from_map(pos, pos)
	local data = vm:get_data()
	local param2_data = vm:get_param2_data()
	local area = VoxelArea:new({MinEdge = MinEdge, MaxEdge = MaxEdge})
	local idx = area:indexp(pos)
	if data[idx] and param2_data[idx] then
		return {
			name = minetest.get_name_from_content_id(data[idx]),
			param2 = param2_data[idx]
		}
	end
	return {name="ignore", param2=0}
end

local function turnright(dir)
	local facedir = minetest.dir_to_facedir(dir)
	return minetest.facedir_to_dir((facedir + 1) % 4)
end

local function turnleft(dir)
	local facedir = minetest.dir_to_facedir(dir)
	return minetest.facedir_to_dir((facedir + 3) % 4)
end

-- pos is the base position
local function is_crane_running(pos)
	local switch_pos = {x=pos.x, y=pos.y+1, z=pos.z}
	return towercrane.is_crane_running(switch_pos)
end

local function get_crane_data(pos)
	local meta = minetest.get_meta(pos)
	local dir = S2P(meta:get_string("dir"))
	local owner = meta:get_string("owner")
	local height = meta:get_int("height")
	local width = meta:get_int("width")
	if dir and height > 0 and width > 0 and owner ~= "" then
		return {dir = dir, height = height, width = width, owner = owner}
	end
end

-- generic function for contruction and removement
local function crane_body_plan(pos, dir, height, width, clbk, tArg)
	pos.y = pos.y + 1
	clbk(pos, "towercrane:mast_ctrl_off", tArg)

	for _ = 1,height+1 do
		pos.y = pos.y + 1
		clbk(pos, "towercrane:mast", tArg)
	end

	pos.y = pos.y - 2
	pos.x = pos.x - dir.x
	pos.z = pos.z - dir.z
	clbk(pos, "towercrane:arm2", tArg)
	pos.x = pos.x - dir.x
	pos.z = pos.z - dir.z
	clbk(pos, "towercrane:arm", tArg)
	pos.x = pos.x - dir.x
	pos.z = pos.z - dir.z
	clbk(pos, "towercrane:balance", tArg)
	pos.x = pos.x + 3 * dir.x
	pos.z = pos.z + 3 * dir.z

	for i = 1,width do
		pos.x = pos.x + dir.x
		pos.z = pos.z + dir.z
		if i % 2 == 0 then
			clbk(pos, "towercrane:arm2", tArg)
		else
			clbk(pos, "towercrane:arm", tArg)
		end
	end
end

-- Check space and protection for the crane
local function check_space(pos, dir, height, width, owner)
	local check = function(pos, node_name, tArg)
		if minetest.get_node(pos).name ~= "air" then
			tArg.res = false
		elseif minetest.is_protected(pos, tArg.owner) then
			tArg.res = false
		end
	end
	local tArg = {res = true, owner = owner}
	crane_body_plan(table.copy(pos), dir, height, width, check, tArg)
	return tArg.res
end

local function construct_crane(pos, dir, height, width)
	local add = function(pos, node_name, tArg)
		minetest.add_node(pos, {
				name = node_name,
				param2 = minetest.dir_to_facedir(tArg.dir)})
	end
	local tArg = {dir = dir}
	crane_body_plan(table.copy(pos), dir, height, width, add, tArg)
end

local function remove_crane(pos, dir, height, width)
	local remove = function(pos, node_name, tArg)
		local node = get_node_lvm(pos)
		if node.name == node_name or node.name == "towercrane:mast_ctrl_on" then
			minetest.remove_node(pos)
		end
	end
	crane_body_plan(table.copy(pos), dir, height, width, remove, {})
end

-- pos is the base position
local function is_my_crane(pos, player)
	if minetest.check_player_privs(player, "server") then
		return true
	end
	-- check protection
	local player_name = player and player:get_player_name() or ""
	if minetest.is_protected(pos, player_name) then
		return false
	end
	-- check owner
    local meta = minetest.get_meta(pos)
	if not meta or player_name ~= meta:get_string("owner") then
		return false
	end
	return true
end

-- Check user input (height, width)
local function check_input(fields)
	local size = string.split(fields.size, ",")
	if #size == 2  then
		local height = tonumber(size[1])
		local width = tonumber(size[2])
		if height ~= nil and width ~= nil then
			height = math.max(height, MIN_SIZE)
			height = math.min(height, towercrane.max_height)
			width = math.max(width, MIN_SIZE)
			width = math.min(width, towercrane.max_width)
			return height, width
		end
	end
	return 0, 0
end

-- pos is the base position
function towercrane.get_crane_down(pos)
	local data = get_crane_data(pos)
	if data then
		remove_crane(pos, data.dir, data.height, data.width)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", formspec(data.height, data.width))
	end
end

local function build_crane_up(pos, owner, height, width)
	if height > 0 and width > 0 then
		local meta = minetest.get_meta(pos)
		local dir = S2P(meta:get_string("dir"))
		if dir then
			if check_space(pos, dir, height, width, owner) then
				construct_crane(pos, dir, height, width)
				meta:set_int("height", height)
				meta:set_int("width", width)
				meta:set_string("infotext", S("Owner")..": "..owner..
					", "..S("Crane size")..": "..height..","..width)
				meta:set_string("formspec", formspec(height, width))
			else
				chat(owner, S("Area is protected or not enough space for the crane!"))
			end
		end
	else
		chat(owner, S("Invalid input!"))
	end
end

-------------------------------------------------------------------------------
-- Nodes
-------------------------------------------------------------------------------
minetest.register_node("towercrane:base", {
	description = S("Tower Crane Base"),
	inventory_image = "[inventorycube{towercrane_mast.png{towercrane_mast.png{towercrane_mast.png",
	tiles = {
		"towercrane_base.png^towercrane_arrow.png",
		"towercrane_base.png^towercrane_screws.png",
		"towercrane_base.png^towercrane_screws.png",
		"towercrane_base.png^towercrane_screws.png",
		"towercrane_base.png^towercrane_screws.png",
		"towercrane_base.png^towercrane_screws.png",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	sounds = default.node_sound_metal_defaults(),
	is_ground_content = false,
	groups = {cracky=2},

	-- set meta data (form for crane height and width, dir of the arm)
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local owner = placer:get_player_name()
		meta:set_string("owner", owner)
		meta:set_string("formspec", formspec())

		local fdir = minetest.dir_to_facedir(placer:get_look_dir(), false)
		local dir = minetest.facedir_to_dir(fdir)
		meta:set_string("dir", P2S(dir))
	end,

	on_rotate = function(pos, node, player, mode, new_facedir)
		-- check whether crane is built up
		local pos_above = {x=pos.x, y=pos.y+1, z=pos.z}
		local node_above = minetest.get_node(pos_above)

		if node_above.name == "towercrane:mast_ctrl_on"
				or node_above.name == "towercrane:mast_ctrl_off" then
			return false
		end

		-- only allow rotation around y-axis
		new_facedir = new_facedir % 4

		local dir = minetest.facedir_to_dir(new_facedir)
		local meta = minetest.get_meta(pos)
		meta:set_string("dir", P2S(dir))

		node.param2 = new_facedir
		minetest.swap_node(pos, node)
		return true
	end,

	-- evaluate user input (height, width),
	-- destroy old crane and build a new one with
	-- the given size
	on_receive_fields = function(pos, formname, fields, player)
		if fields.size == nil then
			return
		end
		if is_crane_running(pos) then
			return
		end
		if not is_my_crane(pos, player) then
			return
		end
		-- destroy old crane
		towercrane.get_crane_down(pos)
		-- evaluate user input and build new
		local height, width = check_input(fields)
		build_crane_up(pos, player:get_player_name(), height, width)
	end,

	can_dig = function(pos, player)
		if minetest.check_player_privs(player, "server") then
			return true
		end
		if is_crane_running(pos) then
			return false
		end
		if not is_my_crane(pos, player) then
			return false
		end
		return true
	end,

	on_destruct = function(pos)
		towercrane.get_crane_down(pos)
	end,
})

minetest.register_node("towercrane:balance", {
	description = S("Tower Crane Balance"),
	tiles = {
		"towercrane_base.png^towercrane_screws.png^morelights_extras_blocklight.png",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 12,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly=0, not_in_creative_inventory=1},
	drop = "",
})

minetest.register_node("towercrane:mast", {
	description = S("Tower Crane Mast"),
	drawtype = "glasslike_framed",
	tiles = {
		"towercrane_mast.png",
		{
			name = "towercrane_mast.png",
			backface_culling = false,
		},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly=0, not_in_creative_inventory=1},
	drop = "",
})

minetest.register_node("towercrane:arm", {
	description = S("Tower Crane Arm"),
	drawtype = "glasslike_framed",
	tiles = {
		"towercrane_arm.png",
		{
			name = "towercrane_arm.png",
			backface_culling = false,
		},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly=0, not_in_creative_inventory=1},
	drop = "",
})

minetest.register_node("towercrane:arm2", {
	description = S("Tower Crane Arm2"),
	drawtype = "glasslike_framed",
	tiles = {
		"towercrane_arm2.png",
		{
			name = "towercrane_arm2.png",
			backface_culling = false,
		},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly=0, not_in_creative_inventory=1},
	drop = "",
})

if towercrane.recipe then
	minetest.register_craft({
		output = "towercrane:base",
		recipe = {
			{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
			{"default:steel_ingot", "", ""},
			{"default:steel_ingot", "dye:yellow", ""}
		}
	})
end

-------------------------------------------------------------------------------
-- export
-------------------------------------------------------------------------------
towercrane.turnright = turnright
towercrane.turnleft = turnleft
towercrane.is_my_crane = is_my_crane
towercrane.get_crane_data = get_crane_data
