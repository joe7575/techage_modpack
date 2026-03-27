--[[
    lcdlib based on:
	 
    font_lib mod for Minetest - Library to add font display capability 
    to display_lib mod. 
    (c) Pierre-Yves Rollo

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

-- Character texture size
local WIDTH = 7
local HEIGHT = 14

-- Builds texture for a multiline colored text
-- @param tText Text as table of lines
-- @param maxchar Maximum number of characters per line (16,18,...40)
-- @param maxlines Maximum number of lines (8,9,...20)
-- @param color Color of the text
-- @return Texture string
function lcdlib.make_mono_texture(tText, maxchar, maxlines, color)
	local tbl = {}
    local x, y
    for row = 1, maxlines do
        local line = tText[row] or ""
        for pos = 1, maxchar do
            local num = string.byte(line, pos) or 32
            x = (pos - 1) * WIDTH
            y = (row - 1) * HEIGHT
            if num > 32 and num <= 126 then
                table.insert(tbl, string.format(":%d,%d=lcdm%02X.png", x, y, num))
            end
		end	
	end
    local s = string.format("[combine:%dx%d", maxchar * WIDTH, maxlines * HEIGHT) ..
        table.concat(tbl)..(color and "^[colorize:"..color or "")
    return s
end

function lcdlib.on_mono_display_update(pos, objref, tText)
	local entity = objref:get_luaentity()
    local meta = minetest.get_meta(pos)
    local color = meta:get_string("color") or "#CCCCCC"
    local rows = meta:get_int("resolution") or 8
    local chars = rows * 2
	local ndef = minetest.registered_nodes[minetest.get_node(pos).name]

	if entity then
        local def = ndef.display_entities[entity.name]
        if def then
            objref:set_properties({ 
                textures={lcdlib.make_mono_texture(tText, chars, rows, color)}, 
                visual_size = def.size
            })
        end
	end
end
