--[[

	LCD
	===

	Derived from the work of kaeza, sofar and others (digilines)

	LGPLv2.1+
	See LICENSE.txt for more information

]]--

-- Load support for intllib.
local S = hyperloop.S

-- load characters map
local chars_file = io.open(minetest.get_modpath("hyperloop").."/characters.data", "r")
local charmap = {}
local max_chars = 16
if not chars_file then
	print("[Hyperloop] E: LCD: character map file not found")
else
	while true do
		local char = chars_file:read("*l")
		if char == nil then
			break
		end
		local img = chars_file:read("*l")
		chars_file:read("*l")
		charmap[char] = img
	end
end

-- CONSTANTS
local LCD_WITH = 112

local LINE_LENGTH = 17
local NUMBER_OF_LINES = 6

local LINE_HEIGHT = 14
local CHAR_WIDTH = 5

local create_lines = function(text)
	local line = ""
	local line_num = 1
	local tab = {}
	for word in string.gmatch(text, "%S+") do
		if string.len(line)+string.len(word) < LINE_LENGTH and word ~= "|" then
			if line ~= "" then
				line = line.." "..word
			else
				line = word
			end
		else
			table.insert(tab, line)
			if word ~= "|" then
				line = word
			else
				line = ""
			end
			line_num = line_num+1
			if line_num > NUMBER_OF_LINES then
				return tab
			end
		end
	end
	table.insert(tab, line)
	return tab
end

local generate_line = function(s, ypos)
	local i = 1
	local parsed = {}
	local width = 0
	local chars = 0
	while chars < max_chars and i <= #s do
		local file = nil
		if charmap[s:sub(i, i)] ~= nil then
			file = charmap[s:sub(i, i)]
			i = i + 1
		elseif i < #s and charmap[s:sub(i, i + 1)] ~= nil then
			file = charmap[s:sub(i, i + 1)]
			i = i + 2
		else
			i = i + 1
		end
		if file ~= nil then
			width = width + CHAR_WIDTH
			table.insert(parsed, file)
			chars = chars + 1
		end
	end
	width = width - 1

	local texture = ""
	local xpos = math.floor((LCD_WITH - width) / 2) - CHAR_WIDTH
	--xpos = 5
	for ii = 1, #parsed do
		texture = texture..":"..xpos..","..ypos.."="..parsed[ii]..".png"
		xpos = xpos + CHAR_WIDTH + 1
	end
	return texture
end

local generate_texture = function(lines)
	local texture = "[combine:"..LCD_WITH.."x"..LCD_WITH
	local ypos = 8
	for i = 1, #lines do
		texture = texture..generate_line(lines[i], ypos)
		ypos = ypos + LINE_HEIGHT
	end
	return texture
end

local lcds = {
	[2] = {delta = {x =  0.425, y = 0, z = 0}, yaw = math.pi / -2},
	[3] = {delta = {x = -0.425, y = 0, z = 0}, yaw = math.pi /  2},
	[4] = {delta = {x = 0, y = 0, z =  0.425}, yaw = 0},
	[5] = {delta = {x = 0, y = 0, z = -0.425}, yaw = math.pi},
}

local clearscreen = function(pos)
	local objects = minetest.get_objects_inside_radius(pos, 0.5)
	for _, o in ipairs(objects) do
		local o_entity = o:get_luaentity()
		if o_entity and o_entity.name == "hyperloop_lcd:text" then
			o:remove()
		end
	end
end

local prepare_writing = function(pos)
	local lcd_info = lcds[minetest.get_node(pos).param2]
	if lcd_info == nil then return end
	local text = minetest.add_entity(
		{x = pos.x + lcd_info.delta.x,
		 y = pos.y + lcd_info.delta.y,
		 z = pos.z + lcd_info.delta.z}, "hyperloop_lcd:text")
	text:set_yaw(lcd_info.yaw or 0)
	--* text:setpitch(lcd_info.yaw or 0)
	return text
end

local lcd_update = function(pos, text)
	local meta = minetest.get_meta(pos)
	meta:set_string("text", text)
	clearscreen(pos)
	prepare_writing(pos)
end

local lcd_box = {
	type = "wallmounted",
	wall_top = {-8/16, 15/32, -8/16, 8/16, 8/16, 8/16}
}


minetest.register_node("hyperloop:lcd", {
	drawtype = "nodebox",
	description = S("Hyperloop Display"),
	tiles = {"hyperloop_lcd.png"},

	on_rotate = screwdriver.disallow,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	node_box = lcd_box,
	selection_box = lcd_box,
	drop = "",
	groups = {cracky=1, not_in_creative_inventory=1},

	auto_place_node = function(pos, placer, facedir)
		local param2 = minetest.get_node(pos).param2
		if param2 == 0 or param2 == 1 then
			minetest.add_node(pos, {name = "hyperloop:lcd", param2 = 3})
		end
		lcd_update(pos, " |  | << Hyperloop >> | be anywhere")
	end,

	on_destruct = function(pos)
		clearscreen(pos)
	end,

	update = function(pos, text)
		lcd_update(pos, text)
	end,

	light_source = 6,
})

minetest.register_entity(":hyperloop_lcd:text", {
	collisionbox = { 0, 0, 0, 0, 0, 0 },
	visual = "upright_sprite",
	textures = {},

	on_activate = function(self)
		local meta = minetest.get_meta(self.object:get_pos())
		local text = meta:get_string("text")
		self.object:set_properties({textures={generate_texture(create_lines(text))}})
	end
})

