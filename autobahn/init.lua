--[[

	Autobahn

	Copyright (C) 2017-2021 Joachim Stolberg
	GPL v3
	See LICENSE.txt for more information

	History:
	2017-11-11  v0.01  first version
	2019-09-13  v0.02  adapted to 5.0.0
	2020-03-19  v0.03  recipe added for techage bitumen
	2020-07-02  v0.04  further slope nodes added

]]--
local S = minetest.get_translator("autobahn")

autobahn = {}

-- Test for MT 5.4 new string mode
autobahn.CLIP = minetest.features.use_texture_alpha_string_modes and "clip" or true

local Facedir2Dir = {[0] = 
	{x=0,  y=0,  z=1},
	{x=1,  y=0,  z=0},
	{x=0,  y=0,  z=-1},
	{x=-1, y=0,  z=0},
}

-- To prevent race condition crashes
local Currently_left_the_game = {}

local function is_active(player)
    local pl_meta = player:get_meta()
	if not pl_meta or pl_meta:get_int("autobahn_isactive") ~= 1 then
		return false
	end
	return true
end

local function set_player_privs(player)
	local physics = player:get_physics_override()
	local meta = player:get_meta()
	-- Check access conflicts with other mods
	if meta:get_int("player_physics_locked") == 0 then
		meta:set_int("player_physics_locked", 1)
		if meta and physics then
			-- store the player privs default values
			meta:set_int("autobahn_speed", physics.speed)
			-- set operator privs
			meta:set_int("autobahn_isactive", 1)
			physics.speed = 3.5
			minetest.sound_play("autobahn_motor", {
					pos = player:get_pos(),
					gain = 0.5,
					max_hear_distance = 5,
				})
			-- write back
			player:set_physics_override(physics)
		end
	end
end

local function reset_player_privs(player)
	local physics = player:get_physics_override()
	local meta = player:get_meta()
	if meta and physics then
		-- restore the player privs default values
		meta:set_int("autobahn_isactive", 0)
		physics.speed = meta:get_int("autobahn_speed")
		if physics.speed == 0 then physics.speed = 1 end
		-- delete stored default values
		meta:set_string("autobahn_speed", "")
		-- write back
		player:set_physics_override(physics)
		meta:set_int("player_physics_locked", 0)
	end
end

minetest.register_on_joinplayer(function(player)
	if is_active(player) then
		reset_player_privs(player)
	end
end)

minetest.register_on_leaveplayer(function(player)
	if is_active(player) then
		Currently_left_the_game[player:get_player_name()] = true
	end
end)

minetest.register_on_respawnplayer(function(player)
	if is_active(player) then
		reset_player_privs(player)
	end
end)

local function control_player(player_name)
	if Currently_left_the_game[player_name] then
		Currently_left_the_game[player_name] = nil
		return
	end
	local player = minetest.get_player_by_name(player_name)
	if player then
		local pos = player:get_pos()
		if pos then
			pos.y = math.floor(pos.y)
			local node = minetest.get_node(pos)
			if string.sub(node.name,1,13) == "autobahn:node" then
				minetest.after(0.5, control_player, player_name)
			else
				pos.y = pos.y - 1
				node = minetest.get_node(pos)
				if string.sub(node.name,1,13) == "autobahn:node" then
					minetest.after(0.5, control_player, player_name)
				else
					pos.y = pos.y + 2
					node = minetest.get_node(pos)
					if string.sub(node.name,1,13) == "autobahn:node" then
						minetest.after(0.5, control_player, player_name)
					else
						reset_player_privs(player)
					end
				end
			end
		end
	end
end	


local NodeTbl1 = {
	["autobahn:node1"] = true,
	["autobahn:node2"] = true,
	["autobahn:node3"] = true,
	["autobahn:node4"] = true,
	["autobahn:node5"] = true,
	["autobahn:node6"] = true,
	["autobahn:node12"] = true,
	["autobahn:node22"] = true,
	["autobahn:node32"] = true,
	["autobahn:node42"] = true,
	["autobahn:node52"] = true,
	["autobahn:node62"] = true,
}
local NodeTbl2 = {
	["autobahn:node11"] = true,
	["autobahn:node21"] = true,
	["autobahn:node31"] = true,
	["autobahn:node41"] = true,
	["autobahn:node51"] = true,
	["autobahn:node61"] = true,
}
local NodeTbl3 = {
	["autobahn:node1"] = true,
	["autobahn:node2"] = true,
	["autobahn:node3"] = true,
	["autobahn:node4"] = true,
	["autobahn:node5"] = true,
	["autobahn:node6"] = true,
}

--  1)   _o_
--       /\  [?]        ==> 1
--     [T][T][S][S][S]      T..tar
--     [S][S][S][S][S]      S..sand
--
--
--  2)   _o_
--       /\  [1][?]     ==> 2
--     [T][T][S][S][S]
--     [S][S][S][S][S]
--
--
--  3)   _o_
--       /\  [?]        ==> 1
--     [S][S][S][T][T]
--     [S][S][S][S][S]
--
--
--  4)   _o_
--       /\  [?][1]     ==> 2
--     [S][S][S][T][T]
--     [S][S][S][S][S]

local function update_node(pos)
	local node = minetest.get_node(pos)
	local nnode
	local npos
	-- check case 1
	local facedir = (2 + node.param2) % 4
	npos = vector.add(pos, Facedir2Dir[facedir])
	npos.y = npos.y - 1
	nnode = minetest.get_node(npos)
	if NodeTbl1[nnode.name] and NodeTbl3[node.name] then
		node.name = node.name .. "1"
		if minetest.registered_nodes[node.name] then
			minetest.swap_node(pos, node)
		end
		return
	end
	-- check case 2
	npos.y = npos.y + 1
	nnode = minetest.get_node(npos)
	if NodeTbl2[nnode.name] then
		node.name = string.sub(node.name,1,-1) .. "2"
		if minetest.registered_nodes[node.name] then
			minetest.swap_node(pos, node)
		end
		return
	end
	-- check case 3
	facedir = (0 + node.param2) % 4
	npos = vector.add(pos, Facedir2Dir[facedir])
	npos.y = npos.y - 1
	nnode = minetest.get_node(npos)
	if NodeTbl1[nnode.name] and NodeTbl3[node.name] then
		node.name = node.name .. "1"
		node.param2 = 3
		if minetest.registered_nodes[node.name] then
			minetest.swap_node(pos, node)
		end
		return
	end
	-- check case 4
	npos.y = npos.y + 1
	nnode = minetest.get_node(npos)
	if NodeTbl2[nnode.name] then
		node.name = string.sub(node.name,1,-1) .. "2"
		node.param2 = 3
		if minetest.registered_nodes[node.name] then
			minetest.swap_node(pos, node)
		end
		return
	end
end		


local function register_node(name, tiles, drawtype, mesh, box, drop)
	minetest.register_node("autobahn:"..name, {
		description = S("Autobahn"),
		tiles = tiles,
		drawtype = drawtype,
		mesh = mesh,
		selection_box = box,
		collision_box = box,
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		use_texture_alpha = autobahn.CLIP,
		sounds = default.node_sound_stone_defaults(),
		is_ground_content = false,
		groups = {cracky=2, crumbly=2, 
			fall_damage_add_percent = -80,
			not_in_creative_inventory=(mesh==nil) and 0 or 1},
		drop = "autobahn:"..drop,

		after_place_node = function(pos, placer, itemstack, pointed_thing)
			update_node(pos)
		end,
		
		on_rightclick = function(pos, node, clicker)
			if is_active(clicker) then
				reset_player_privs(clicker)
			else
				set_player_privs(clicker)
				local player_name = clicker:get_player_name()
				minetest.after(0.5, control_player, player_name)
			end
		end,
	})
end

local sb1 = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5,   -0.5,  0.5, -0.375, 0.5},
		{-0.5, -0.375, -0.25, 0.5, -0.25,  0.5},
		{-0.5, -0.25,  0,    0.5, -0.125, 0.5},
		{-0.5, -0.125, 0.25, 0.5,  0,     0.5},
	}
}
local sb2 = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5,   -0.5,  0.5, 0.125, 0.5},
		{-0.5, 0.125, -0.25, 0.5, 0.25,  0.5},
		{-0.5, 0.25,  0,    0.5, 0.375, 0.5},
		{-0.5, 0.375, 0.25, 0.5,  0.5,     0.5},
	}
}

local Nodes = {
	{name="node1", tiles={"autobahn1.png"}, drawtype="normal", mesh=nil, box=nil, drop="node1"},
	{name="node2", tiles={"autobahn2.png","autobahn1.png"}, drawtype="normal", mesh=nil, box=nil, drop="node2"},
	{name="node3", tiles={"autobahn3.png","autobahn1.png"}, drawtype="normal", mesh=nil, box=nil, drop="node3"},
	{name="node4", tiles={"autobahn2.png^[transformR180]","autobahn1.png"}, drawtype="normal", mesh=nil, box=nil, drop="node4"},
	{name="node5", tiles={"autobahn4.png^[transformR90]","autobahn1.png"}, drawtype="normal", mesh=nil, box=nil, drop="node5"},
	{name="node6", tiles={"autobahn5.png^[transformR90]","autobahn1.png"}, drawtype="normal", mesh=nil, box=nil, drop="node6"},
	
	{name="node11", tiles={"autobahn1.png"}, drawtype="mesh", mesh="autobahn_ramp1.obj", box=sb1, drop="node1"},
	{name="node21", tiles={"autobahn2.png","autobahn1.png"}, drawtype="mesh", mesh="autobahn_ramp1.obj", box=sb1, drop="node2"},
	{name="node31", tiles={"autobahn3.png","autobahn1.png"}, drawtype="mesh", mesh="autobahn_ramp1.obj", box=sb1, drop="node3"},
	{name="node41", tiles={"autobahn2.png^[transformR180]","autobahn1.png"}, drawtype="mesh", mesh="autobahn_ramp1.obj", box=sb1, drop="node4"},
	{name="node51", tiles={"autobahn4.png^[transformR90]","autobahn1.png"}, drawtype="mesh", mesh="autobahn_ramp1.obj", box=sb1, drop="node5"},
	{name="node61", tiles={"autobahn5.png^[transformR90]","autobahn1.png"}, drawtype="mesh", mesh="autobahn_ramp1.obj", box=sb1, drop="node6"},
	
	{name="node12", tiles={"autobahn1.png"}, drawtype="mesh", mesh="autobahn_ramp2.obj", box=sb2, drop="node1"},
	{name="node22", tiles={"autobahn2.png","autobahn1.png"}, drawtype="mesh", mesh="autobahn_ramp2.obj", box=sb2, drop="node2"},
	{name="node32", tiles={"autobahn3.png","autobahn1.png"}, drawtype="mesh", mesh="autobahn_ramp2.obj", box=sb2, drop="node3"},
	{name="node42", tiles={"autobahn2.png^[transformR180]","autobahn1.png"}, drawtype="mesh", mesh="autobahn_ramp2.obj", box=sb2, drop="node4"},
	{name="node52", tiles={"autobahn4.png^[transformR90]","autobahn1.png"}, drawtype="mesh", mesh="autobahn_ramp2.obj", box=sb2, drop="node5"},
	{name="node62", tiles={"autobahn5.png^[transformR90]","autobahn1.png"}, drawtype="mesh", mesh="autobahn_ramp2.obj", box=sb2, drop="node6"},
}

for _,item in ipairs(Nodes) do
	register_node(item.name, item.tiles, item.drawtype, item.mesh, item.box, item.drop)
end


minetest.register_craftitem("autobahn:stripes", {
	description = S("Autobahn Stripe"),
	inventory_image = 'autobahn_stripes.png',
})


if minetest.global_exists("techage") then	
	minetest.register_craft({
		output = "autobahn:node1 12",
		recipe = {
			{"techage:sieved_basalt_gravel", "techage:sieved_basalt_gravel", "techage:sieved_basalt_gravel"},
			{"techage:sieved_basalt_gravel", "techage:ta3_barrel_bitumen", "techage:sieved_basalt_gravel"},
			{"techage:sieved_basalt_gravel", "techage:sieved_basalt_gravel", "techage:sieved_basalt_gravel"},
		},
		replacements = {{"techage:ta3_barrel_bitumen", "techage:ta3_barrel_empty"}},
	})
	minetest.register_craft({
		output = "autobahn:node1 12",
		recipe = {
			{"techage:sieved_gravel", "techage:sieved_gravel", "techage:sieved_gravel"},
			{"techage:sieved_gravel", "techage:ta3_barrel_bitumen", "techage:sieved_gravel"},
			{"techage:sieved_gravel", "techage:sieved_gravel", "techage:sieved_gravel"},
		},
		replacements = {{"techage:ta3_barrel_bitumen", "techage:ta3_barrel_empty"}},
	})
elseif minetest.global_exists("moreblocks") then
	minetest.register_craft({
		output = "autobahn:node1 4",
		recipe = {
			{"moreblocks:tar", "moreblocks:tar"},
			{"default:cobble", "default:cobble"},
		},
	})
else
	minetest.register_craft({
		output = "autobahn:node1 4",
		recipe = {
			{"autobahn:tar", "autobahn:tar"},
			{"default:cobble", "default:cobble"},
		},
	})
	minetest.register_craft({
		type = "cooking", 
		output = "autobahn:tar",
		recipe = "default:pine_tree",
	})
	minetest.register_node("autobahn:tar", {
		description = S("Tar"),
		tiles = {"autobahn1.png^[colorize:#000000:80"},
		is_ground_content = false,
		groups = {cracky = 2},
		sounds = default.node_sound_stone_defaults(),
	})
end

minetest.register_craft({
	output = "autobahn:stripes 8",
	recipe = {
		{"dye:white"},
	}
})


minetest.register_craft({
	output = "autobahn:node2",
	recipe = {
		{"", "", "autobahn:stripes"},
		{"", "autobahn:node1", ""},
	}
})

minetest.register_craft({
	output = "autobahn:node3",
	recipe = {
		{"", "autobahn:stripes", ""},
		{"", "autobahn:node1", ""},
	}
})

minetest.register_craft({
	output = "autobahn:node4",
	recipe = {
		{"autobahn:stripes", "", ""},
		{"", "autobahn:node1", ""},
	}
})

minetest.register_craft({
	output = "autobahn:node5",
	recipe = {
		{"", "", ""},
		{"autobahn:stripes", "autobahn:node1", ""},
	}
})

minetest.register_craft({
	output = "autobahn:node6",
	recipe = {
		{"", "autobahn:stripes", ""},
		{"autobahn:stripes", "autobahn:node1", ""},
	}
})

if minetest.global_exists("minecart") then
	minecart.register_protected_node("autobahn:node1")
	minecart.register_protected_node("autobahn:node2")	
	minecart.register_protected_node("autobahn:node3")	
	minecart.register_protected_node("autobahn:node4")	
	minecart.register_protected_node("autobahn:node5")	
	minecart.register_protected_node("autobahn:node6")	
	minecart.register_protected_node("autobahn:node11")	
	minecart.register_protected_node("autobahn:node21")	
	minecart.register_protected_node("autobahn:node31")	
	minecart.register_protected_node("autobahn:node41")	
	minecart.register_protected_node("autobahn:node51")	
	minecart.register_protected_node("autobahn:node61")	
	minecart.register_protected_node("autobahn:node12")	
	minecart.register_protected_node("autobahn:node22")	
	minecart.register_protected_node("autobahn:node32")	
	minecart.register_protected_node("autobahn:node42")	
	minecart.register_protected_node("autobahn:node52")	
	minecart.register_protected_node("autobahn:node62")	
end	


-------------------------------------------------------------------------------
-- External API functions
-------------------------------------------------------------------------------

-- Returns true if player is "driving" on the autobahn
--   func autobahn.is_driving(player)
autobahn.is_driving = is_active