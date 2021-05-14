local S = minetest.get_translator("compost")

compost = {}

local CYCLE_TIME = 30
local NUM_LEAVES = 2

-- Version for compatibility checks
compost.version = 1.0

if minetest.global_exists("techage") and techage.version < 0.06 then
	minetest.log("error", "[compost] Compost requires techage version 0.06 or newer!")
	return
end

compost.items = {}
compost.groups = {}

function compost.register_item(name)
	compost.items[name] = true
end

function compost.register_group(name)
	compost.groups[name] = true
end

function compost.can_compost(name)
	if compost.items[name] then
		return true
	else
		for k, i in pairs(minetest.registered_items[name].groups) do
			if i > 0 then
				if compost.groups[tostring(k)] then
					return true
				end
			end
		end

		return false
	end
end

-- grass
compost.register_item("default:grass_1")
compost.register_item("default:junglegrass")

-- leaves
compost.register_group("leaves")

-- dirt
compost.register_item("default:dirt")
compost.register_item("default:dirt_with_grass")

-- stick
compost.register_item("default:stick")

-- food
compost.register_item("farming:bread")
compost.register_item("farming:wheat")

-- groups
compost.register_group("plant")
compost.register_group("flower")

-- flowers
minetest.after(1, function()
	for name,_ in pairs(minetest.registered_decorations) do
		if type(name) == "string" then
			local mod = string.split(name, ":")[1]
			if mod == "flowers" then
				compost.register_item(name)
			end
		end
	end
end)


local function next_state(pos, elapsed)
	local node = minetest.get_node(pos)
	
	if node.name == "compost:wood_barrel_1" then
		minetest.swap_node(pos, {name = "compost:wood_barrel_2"})
	elseif node.name == "compost:wood_barrel_2" then
		minetest.swap_node(pos, {name = "compost:wood_barrel_3"})
	elseif node.name == "compost:wood_barrel_3" then
		return false
	end
	return true
end

local function start_composter(pos)
	local meta = minetest.get_meta(pos)
	local num = meta:get_int("num") or 0
	if num >= NUM_LEAVES then
		-- NUM_LEAVES leaves for one compost node
		meta:set_int("num", num - NUM_LEAVES)
		minetest.swap_node(pos, {name = "compost:wood_barrel_1"})
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end
end

local function add_item(pos, stack)
	local meta = minetest.get_meta(pos)
	local num = meta:get_int("num") or 0
	
	if num < NUM_LEAVES then
		-- add futher leaves
		meta:set_int("num", num + stack:get_count())
		stack:set_count(0)
	end
	
	start_composter(pos)
	return stack
end

local function minecart_hopper_additem(pos, stack)
	if compost.can_compost(stack:get_name()) then
		return add_item(pos, stack)
	end
	return stack
end

local function minecart_hopper_takeitem(pos, num)
	local node = minetest.get_node(pos)
	minetest.swap_node(pos, {name = "compost:wood_barrel"})
	start_composter(pos)
	return ItemStack("compost:compost")
end

local function minecart_hopper_untakeitem(pos, in_dir, stack)
	minetest.swap_node(pos, {name = "compost:wood_barrel_2"})
end

minetest.register_node("compost:wood_barrel", {
	description = S("Wood Barrel"),
	tiles = {"default_wood.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{-1/2, -1/2, -1/2, 1/2, -3/8, 1/2},
			{-1/2, -1/2, -1/2, -3/8, 1/2, 1/2},
			{3/8, -1/2, -1/2, 1/2, 1/2, 1/2},
			{-1/2, -1/2, -1/2, 1/2, 1/2, -3/8},
			{-1/2, -1/2, 3/8, 1/2, 1/2, 1/2}},
	},
	paramtype = "light",
	is_ground_content = false,
	groups = {choppy = 3},
	sounds =  default.node_sound_wood_defaults(),
	on_punch = function(pos, node, puncher, pointed_thing)
		local wielded_item = puncher:get_wielded_item():get_name()
		if compost.can_compost(wielded_item) then
			minetest.swap_node(pos, {name = "compost:wood_barrel_1"})
			local w = puncher:get_wielded_item()
			if not(minetest.setting_getbool("creative_mode")) then
				w:take_item(1)
				puncher:set_wielded_item(w)
			end
			minetest.get_node_timer(pos):start(CYCLE_TIME)
		end
	end,
	on_timer = next_state,
	minecart_hopper_additem = minecart_hopper_additem,
	minecart_hopper_untakeitem = minecart_hopper_untakeitem,
})

minetest.register_node("compost:wood_barrel_1", {
	description = S("Wood Barrel with compost"),
	tiles = {"default_wood.png^compost_compost_1.png", "default_wood.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{-1/2, -1/2, -1/2, 1/2, -3/8, 1/2},
			{-1/2, -1/2, -1/2, -3/8, 1/2, 1/2},
			{3/8, -1/2, -1/2, 1/2, 1/2, 1/2},
			{-1/2, -1/2, -1/2, 1/2, 1/2, -3/8},
			{-1/2, -1/2, 3/8, 1/2, 1/2, 1/2},
			{-3/8, -1/2, -3/8, 3/8, 3/8, 3/8}},
	},
	paramtype = "light",
	is_ground_content = false,
	groups = {choppy = 3, not_in_creative_inventory=1},
	sounds =  default.node_sound_wood_defaults(),
	on_timer = next_state,
	minecart_hopper_untakeitem = minecart_hopper_untakeitem,
})

minetest.register_node("compost:wood_barrel_2", {
	description = S("Wood Barrel with compost"),
	tiles = {"default_wood.png^compost_compost_2.png", "default_wood.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{-1/2, -1/2, -1/2, 1/2, -3/8, 1/2},
			{-1/2, -1/2, -1/2, -3/8, 1/2, 1/2},
			{3/8, -1/2, -1/2, 1/2, 1/2, 1/2},
			{-1/2, -1/2, -1/2, 1/2, 1/2, -3/8},
			{-1/2, -1/2, 3/8, 1/2, 1/2, 1/2},
			{-3/8, -1/2, -3/8, 3/8, 3/8, 3/8}},
	},
	paramtype = "light",
	is_ground_content = false,
	groups = {choppy = 3, not_in_creative_inventory=1},
	sounds =  default.node_sound_wood_defaults(),
	on_timer = next_state,
	minecart_hopper_untakeitem = minecart_hopper_untakeitem,
})

minetest.register_node("compost:wood_barrel_3", {
	description = S("Wood Barrel"),
	tiles = {"default_wood.png^compost_compost_3.png", "default_wood.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{-1/2, -1/2, -1/2, 1/2, -3/8, 1/2},
			{-1/2, -1/2, -1/2, -3/8, 1/2, 1/2},
			{3/8, -1/2, -1/2, 1/2, 1/2, 1/2},
			{-1/2, -1/2, -1/2, 1/2, 1/2, -3/8},
			{-1/2, -1/2, 3/8, 1/2, 1/2, 1/2},
			{-3/8, -1/2, -3/8, 3/8, 3/8, 3/8}},
	},
	paramtype = "light",
	is_ground_content = false,
	groups = {choppy = 3, not_in_creative_inventory=1},
	sounds =  default.node_sound_wood_defaults(),
	on_punch = function(pos, node, player, pointed_thing)
		local p = {x = pos.x + math.random(0, 5)/5 - 0.5, y = pos.y+1, z = pos.z + math.random(0, 5)/5 - 0.5}
		minetest.add_item(p, {name = "compost:compost"})
		minetest.swap_node(pos, {name = "compost:wood_barrel"})
	end,
	on_timer = next_state,
	minecart_hopper_takeitem = minecart_hopper_takeitem,
	minecart_hopper_untakeitem = minecart_hopper_untakeitem,
})

minetest.register_craft({
	output = "compost:wood_barrel",
	recipe = {
		{"default:wood", "", "default:wood"},
		{"default:wood", "", "default:wood"},
		{"default:wood", "stairs:slab_wood", "default:wood"}
	}
})

minetest.register_node("compost:compost", {
	description = S("Compost"),
	tiles = {"compost_compost.png"},
	groups = {crumbly = 3},
	sounds =  default.node_sound_dirt_defaults(),
})

minetest.register_node("compost:garden_soil", {
	description = S("Garden Soil"),
	tiles = {"compost_garden_soil.png"},
	groups = {crumbly = 3, soil=3, grassland = 1, wet = 1},
	sounds =  default.node_sound_dirt_defaults(),
})

minetest.register_craft({
	output = "compost:garden_soil",
	recipe = {
		{"compost:compost", "compost:compost"},
	}
})

minetest.register_craft({
	output = "default:dirt",
	recipe = {
		{"compost:garden_soil"},
	}
})

if  minetest.global_exists("techage") then
	techage.register_node(
		{
			"compost:wood_barrel", 
			"compost:wood_barrel_1",
			"compost:wood_barrel_2",
			"compost:wood_barrel_3",
		},
		{
		on_pull_item = function(pos, in_dir, num)
			local node = minetest.get_node(pos)
			if node.name == "compost:wood_barrel_3" then
				minetest.swap_node(pos, {name = "compost:wood_barrel"})
				start_composter(pos)
				return ItemStack("compost:compost")
			end
			return nil
		end,
		on_push_item = function(pos, in_dir, stack)
			local node = minetest.get_node(pos)
			if node.name == "compost:wood_barrel" and compost.can_compost(stack:get_name()) then
				stack = add_item(pos, stack)
				return stack:get_count() == 0
			end
			return false
		end,
		on_unpull_item = function(pos, in_dir, stack)
			minetest.swap_node(pos, {name = "compost:wood_barrel_2"})
			return true
		end,
	})	
end

