--[[

	TA4 Addons
	==========

	Copyright (C) 2020-2021 Joachim Stolberg
	Copyright (C) 2020-2021 Thomas S.

	AGPL v3
	See LICENSE.txt for more information

	Matrix Screen

]]--

local S = ta4_addons.S
local M = minetest.get_meta
local N = techage.get_nvm

local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local letters_to_idx = {}
for idx = 1,64 do
    letters_to_idx[letters:sub(idx, idx)] = idx
end

local function letter_to_idx(letter)
    return letters_to_idx[letter] or 1
end

local palettes = {
    "rgb6bit",-- "resurrect64", "aap64", "sweet_canyon_extended", "endesga64"
}

local palettes_to_idx = {}

for k,v in ipairs(palettes) do
    palettes_to_idx[v] = k
end

local rgb6bit_palette = {
    "000000", "000055", "0000aa", "0000ff", "550000", "550055", "5500aa", "5500ff",
    "aa0000", "aa0055", "aa00aa", "aa00ff", "ff0000", "ff0055", "ff00aa", "ff00ff",
    "005500", "005555", "0055aa", "0055ff", "555500", "555555", "5555aa", "5555ff",
    "aa5500", "aa5555", "aa55aa", "aa55ff", "ff5500", "ff5555", "ff55aa", "ff55ff",
    "00aa00", "00aa55", "00aaaa", "00aaff", "55aa00", "55aa55", "55aaaa", "55aaff",
    "aaaa00", "aaaa55", "aaaaaa", "aaaaff", "ffaa00", "ffaa55", "ffaaaa", "ffaaff",
    "00ff00", "00ff55", "00ffaa", "00ffff", "55ff00", "55ff55", "55ffaa", "55ffff",
    "aaff00", "aaff55", "aaffaa", "aaffff", "ffff00", "ffff55", "ffffaa", "ffffff",
}

-- Source: https://lospec.com/palette-list/resurrect-64
local resurrect64_palette = {
    "2e222f", "3e3546", "625565", "966c6c", "ab947a", "694f62", "7f708a", "9babb2",
    "c7dcd0", "ffffff", "6e2727", "b33831", "ea4f36", "f57d4a", "ae2334", "e83b3b",
    "fb6b1d", "f79617", "f9c22b", "7a3045", "9e4539", "cd683d", "e6904e", "fbb954",
    "4c3e24", "676633", "a2a947", "d5e04b", "fbff86", "165a4c", "239063", "1ebc73",
    "91db69", "cddf6c", "313638", "374e4a", "547e64", "92a984", "b2ba90", "0b5e65",
    "0b8a8f", "0eaf9b", "30e1b9", "8ff8e2", "323353", "484a77", "4d65b4", "4d9be6",
    "8fd3ff", "45293f", "6b3e75", "905ea9", "a884f3", "eaaded", "753c54", "a24b6f",
    "cf657f", "ed8099", "831c5d", "c32454", "f04f78", "f68181", "fca790", "fdcbb0",
}

-- Source: https://lospec.com/palette-list/aap-64
local aap64_palette = {
    "060608", "141013", "3b1725", "73172d", "b4202a", "df3e23", "fa6a0a", "f9a31b",
    "ffd541", "fffc40", "d6f264", "9cdb43", "59c135", "14a02e", "1a7a3e", "24523b",
    "122020", "143464", "285cc4", "249fde", "20d6c7", "a6fcdb", "ffffff", "fef3c0",
    "fad6b8", "f5a097", "e86a73", "bc4a9b", "793a80", "403353", "242234", "221c1a",
    "322b28", "71413b", "bb7547", "dba463", "f4d29c", "dae0ea", "b3b9d1", "8b93af",
    "6d758d", "4a5462", "333941", "422433", "5b3138", "8e5252", "ba756a", "e9b5a3",
    "e3e6ff", "b9bffb", "849be4", "588dbe", "477d85", "23674e", "328464", "5daf8d",
    "92dcba", "cdf7e2", "e4d2aa", "c7b08b", "a08662", "796755", "5a4e44", "423934",
}

-- Source: https://lospec.com/palette-list/sweet-canyon-extended-64
local sweet_canyon_extended_palette = {
    "0f0e11", "2d2c33", "40404a", "51545c", "6b7179", "7c8389", "a8b2b6", "d5d5d5",
    "eeebe0", "f1dbb1", "eec99f", "e1a17e", "cc9562", "ab7b49", "9a643a", "86482f",
    "783a29", "6a3328", "541d29", "42192c", "512240", "782349", "8b2e5d", "a93e89",
    "d062c8", "ec94ea", "f2bdfc", "eaebff", "a2fafa", "64e7e7", "54cfd8", "2fb6c3",
    "2c89af", "25739d", "2a5684", "214574", "1f2966", "101445", "3c0d3b", "66164c",
    "901f3d", "bb3030", "dc473c", "ec6a45", "fb9b41", "f0c04c", "f4d66e", "fffb76",
    "ccf17a", "97d948", "6fba3b", "229443", "1d7e45", "116548", "0c4f3f", "0a3639",
    "251746", "48246d", "69189c", "9f20c0", "e527d2", "ff51cf", "ff7ada", "ff9edb",
}

-- Source: https://lospec.com/palette-list/endesga-64
local endesga64_palette = {
    "ff0040", "131313", "1b1b1b", "272727", "3d3d3d", "5d5d5d", "858585", "b4b4b4",
    "ffffff", "c7cfdd", "92a1b9", "657392", "424c6e", "2a2f4e", "1a1932", "0e071b",
    "1c121c", "391f21", "5d2c28", "8a4836", "bf6f4a", "e69c69", "f6ca9f", "f9e6cf",
    "edab50", "e07438", "c64524", "8e251d", "ff5000", "ed7614", "ffa214", "ffc825",
    "ffeb57", "d3fc7e", "99e65f", "5ac54f", "33984b", "1e6f50", "134c4c", "0c2e44",
    "00396d", "0069aa", "0098dc", "00cdf9", "0cf1ff", "94fdff", "fdd2ed", "f389f5",
    "db3ffd", "7a09fa", "3003d9", "0c0293", "03193f", "3b1443", "622461", "93388f",
    "ca52c9", "c85086", "f68187", "f5555d", "ea323c", "c42430", "891e2b", "571c27",
}

local function rgb6bit(idx)
    return rgb6bit_palette[idx]
end

local function resurrect64(idx)
    return resurrect64_palette[idx]
end

local function aap64(idx)
    return aap64_palette[idx]
end

local function sweet_canyon_extended(idx)
    return sweet_canyon_extended_palette[idx]
end

local function endesga64(idx)
    return endesga64_palette[idx]
end

local function get_palette(palette_name)
    --if palette_name == "resurrect64" then
    --    return resurrect64
    --elseif palette_name == "aap64" then
    --    return aap64
    --elseif palette_name == "sweet_canyon_extended" then
    --    return sweet_canyon_extended
    --elseif palette_name == "endesga64" then
    --    return endesga64
    --end
    return rgb6bit
end

local function string_to_indices(input_string)
    input_string = input_string:gsub("%s", "") -- Ignore space characters
    input_string = input_string:sub(1, 256) -- Limit to 256 chars at max
    input_string = input_string..string.rep("A", 256-#input_string) -- Fill up to reach 256 chars
    local result = {}
    for i = 1,#input_string  do
        result[i] = letter_to_idx(input_string:sub(i, i))
    end
    return result
end

local function string_to_colors(input_string, palette_name)
    local palette_func = get_palette(palette_name)
    local indices = string_to_indices(input_string)
    local result = {}
    for i = 1,#indices do
        result[i] = palette_func(indices[i])
    end
    return result
end

local function generate_texture_from_color_list(colors)
    local texture = {"[combine:16x16"}
    local x, y = 0, 0
    for _,color in ipairs(colors) do
        texture[#texture+1] = ":"
        texture[#texture+1] = x
        texture[#texture+1] = ","
        texture[#texture+1] = y
        texture[#texture+1] = "=px.png\\^[colorize\\:#"
        texture[#texture+1] = color
        x = x + 1
        if x >= 16 then
            x = 0
            y = y + 1
        end
    end
    texture[#texture+1] = "^[resize:128x128^ta4_addons_matrix_screen_overlay.png"
    return table.concat(texture, "")
end

local function generate_texture_from_indices(indices)
    local texture = {"[combine:16x16:0,0=px_bg.png"}
    local x, y = 0, 0
    for _,index in ipairs(indices) do
        if index ~=1 then
            texture[#texture+1] = ":"
            texture[#texture+1] = x
            texture[#texture+1] = ","
            texture[#texture+1] = y
            texture[#texture+1] = "=px"
            texture[#texture+1] = index
            texture[#texture+1] = ".png"
        end
        x = x + 1
        if x >= 16 then
            x = 0
            y = y + 1
        end
    end
    texture[#texture+1] = "^[resize:128x128^ta4_addons_matrix_screen_overlay.png"
    return table.concat(texture, "")
end

local function string_to_table(input_string)
    local indices = string_to_indices(input_string)
    local t = {}
    local x, y = 0, 0
    for i = 1,#indices do
        t[y] = t[y] or {}
        t[y][x] = indices[i]
        x = x + 1
        if x >= 16 then
            x = 0
            y = y + 1
        end
    end
    return t
end

ta4_addons.base64_to_texture = function(color_string, palette)
    --return generate_texture_from_color_list(string_to_colors(color_string, palette))
    return generate_texture_from_indices(string_to_indices(color_string))
end

local function update_matrix_display(pos, objref)
    pos = vector.round(pos)
    local nvm = N(pos)
    objref:set_properties({
        textures = { ta4_addons.base64_to_texture(nvm.color_string or "", nvm.palette) },
    })
end

minetest.register_node("ta4_addons:matrix_screen", {
    description = S("TA4 Matrix Screen"),
    inventory_image = "ta4_addons_matrix_screen_inventory.png",
    tiles = {"ta4_addons_matrix_screen.png"},
    drawtype = "nodebox",
    paramtype = "light",
    sunlight_propagates = true,
    paramtype2 = "wallmounted",
    node_box = techage.display.lcd_box,
    selection_box = techage.display.lcd_box,
    light_source = 6,

    display_entities = {
        ["techage:display_entity"] = {
            depth = 0.42,
            on_display_update = update_matrix_display
        },
    },

    after_place_node = function(pos, placer)
        local number = techage.add_node(pos, "ta4_addons:matrix_screen")
        local meta = M(pos)
        meta:set_string("node_number", number)
        meta:set_string("infotext", S("Matrix Screen no: ")..number)
        local nvm = techage.get_nvm(pos)
        nvm.color_string = "AABBCCDDEEFFGGHHAABBCCDDEEFFGGHH"
                        .. "IIJJKKLLMMNNOOPPIIJJKKLLMMNNOOPP"
                        .. "QQRRSSTTUUVVWWXXQQRRSSTTUUVVWWXX"
                        .. "YYZZaabbccddeeffYYZZaabbccddeeff"
                        .. "gghhiijjkkllmmnngghhiijjkkllmmnn"
                        .. "ooppqqrrssttuuvvooppqqrrssttuuvv"
                        .. "wwxxyyzz00112233wwxxyyzz00112233"
                        .. "445566778899++//445566778899++//"
        lcdlib.update_entities(pos)
        minetest.get_node_timer(pos):start(2)
    end,

    after_dig_node = function(pos, oldnode, oldmetadata)
        techage.remove_node(pos, oldnode, oldmetadata)
    end,

    on_timer = techage.display.on_timer,
    on_place = lcdlib.on_place,
    on_construct = lcdlib.on_construct,
    on_destruct = lcdlib.on_destruct,
    on_rotate = lcdlib.on_rotate,
    groups = {cracky=2, crumbly=2},
    is_ground_content = false,
    sounds = default.node_sound_glass_defaults(),
})

minetest.register_craft({
    output = "ta4_addons:matrix_screen",
    recipe = {
        {"dye:red", "dye:green", "dye:blue"},
        {"default:copper_ingot", "techage:ta4_display", "default:copper_ingot"},
        {"", "default:mese_crystal_fragment", ""},
    },
})

techage.register_node({"ta4_addons:matrix_screen"}, {
    on_recv_message = function(pos, src, topic, payload)
        local mem = techage.get_mem(pos)
        mem.ticks = mem.ticks or 0

        if mem.ticks == 0 then
            mem.ticks = 1
        end

        if topic == "pixels" then
            N(pos).color_string = tostring(payload)
        elseif topic == "palette" then
            N(pos).palette = tostring(payload)
        end
    end,
})

local function generate_px_button(x, y, i, palette_func, name)
    return "image_button["..x..","..y..";.5,.5;px.png^[colorize:#"..palette_func(i)..";"..name..";"..letters:sub(i,i).."]"
end

local function get_px_val(nvm, x, y)
    return ((nvm.px or {})[y] or {})[x] or 1
end

local function generate_base64(nvm)
    local result = ""
    for y=0,15 do
        for x=0,15 do
            local i = get_px_val(nvm, x, y)
            result = result..letters:sub(i,i)
        end
        result = result.." "
    end
    return result:sub(1,-2)
end

local function update_fs(pos)
    local nvm = N(pos)
    local palette = nvm.palette or "rgb6bit"
    local palette_func = get_palette(palette)
    local current_idx = nvm.current_idx or 1
    local fs = "formspec_version[4]size[18,12]"
    fs = fs.."label[0.5,.75;Palette:]"
    fs = fs.."dropdown[2,.5;3,.5;palette;"..table.concat(palettes, ",")..";"..(palettes_to_idx[palette] or 1).."]"
    local x = .5
    local y = 1.5
    for i = 1,64 do
        fs = fs..generate_px_button(x, y, i, palette_func, "color_idx_"..i)
        x = x + .6
        if x > 2.5 then
            x = .5
            y = y + .6
        end
    end
    for y_px = 0,15 do
        for x_px = 0,15 do
            fs = fs..generate_px_button(3.5+x_px*.6, 1.5+y_px*.6, get_px_val(nvm, x_px, y_px), palette_func, "px_"..x_px.."_"..y_px)
        end
    end
    fs = fs.."label[13.5,.75;Current Color:]"
    fs = fs..generate_px_button(17, .5, current_idx, palette_func, "current_color")
    fs = fs.."style_type[textarea;font=mono]"
    fs = fs.."textarea[13.5,4.5;4,5;base64;Base64 string:;"..generate_base64(nvm).."]"
    fs = fs.."button[16.5,9.5;1,.5;read_base64;Read]"
    fs = fs.."field[13.5,10.5;3,1;target;Target Techage Number:;"..minetest.formspec_escape(nvm.target or "").."]"
    fs = fs.."button[16.5,10.5;1,1;send_cmnd;Send]"
    M(pos):set_string("formspec", fs)
end

minetest.register_node("ta4_addons:matrix_screen_programmer", {
    description = S("TA4 Matrix Screen Programmer"),
    tiles = {
        -- up, down, right, left, back, front
        "techage_filling_ta4.png^techage_frame_ta4_top.png",
        "techage_filling_ta4.png^techage_frame_ta4.png",
        "techage_filling_ta4.png^techage_frame_ta4.png",
        "techage_filling_ta4.png^techage_frame_ta4.png",
        "techage_filling_ta4.png^techage_frame_ta4.png",
        "techage_filling_ta4.png^techage_frame_ta4.png^ta4_addons_appl_matrix_screen.png",
    },
    drawtype = "normal",
    paramtype = "light",
    paramtype2 = "facedir",
    on_construct = function(pos)
        update_fs(pos)
        M(pos):set_string("infotext", S("TA4 Matrix Screen Programmer"))
    end,
    after_place_node = function(pos, placer)
        local number = techage.add_node(pos, "ta4_addons:matrix_screen_programmer")
        local meta = M(pos)
        meta:set_string("node_number", number)
        meta:set_string("infotext", S("Matrix Screen Programmer ")..number)
    end,
    after_dig_node = function(pos, oldnode, oldmetadata)
        techage.remove_node(pos, oldnode, oldmetadata)
    end,
    groups = {cracky=2, crumbly=2},
    is_ground_content = false,
    sounds = default.node_sound_metal_defaults(),
    on_receive_fields = function (pos, formname, fields, sender)
        local player_name = sender:get_player_name()
        if minetest.is_protected(pos, player_name) then
            return
        end
        local nvm = N(pos)
        for i=1,64 do
            if fields["color_idx_"..i] then
                nvm.current_idx = i
            end
        end
        for y=0,15 do
            for x=0,15 do
                if fields["px_"..x.."_"..y] then
                    nvm.px = nvm.px or {}
                    nvm.px[y] = nvm.px[y] or {}
                    nvm.px[y][x] = nvm.current_idx
                end
            end
        end
        if fields.read_base64 and fields.base64 then
            nvm.px = string_to_table(fields.base64)
        end
        if fields.send_cmnd and fields.target and techage.check_numbers(fields.target, player_name) then
            nvm.target = fields.target
            local own_number = M(pos):get_string("node_number")
            if not own_number or own_number == "" then
                own_number = "0"
            end
            techage.send_multi(own_number, fields.target, "palette", nvm.palette or "rgb6bit")
            techage.send_multi(own_number, fields.target, "pixels", generate_base64(nvm))
        end
        if fields.palette then
            nvm.palette = fields.palette
        end
        update_fs(pos)
    end
})

techage.register_node({"ta4_addons:matrix_screen_programmer"}, {
    on_recv_message = function(pos, src, topic, payload)
        local nvm = N(pos)
        if topic == "on" then
            local own_number = M(pos):get_string("node_number")
            techage.send_multi(own_number, nvm.target, "pixels", generate_base64(nvm))
            techage.send_multi(own_number, nvm.target, "palette", nvm.palette or "rgb6bit")
        end
    end,
})

minetest.register_craft({
    output = "ta4_addons:matrix_screen_programmer",
    recipe = {
        {"default:steel_ingot", "techage:ta4_ramchip", "default:steel_ingot"},
        {"", "ta4_addons:matrix_screen", ""},
        {"default:steel_ingot", "techage:ta4_wlanchip", "default:steel_ingot"},
    },
})

if techage.repair_number then
    minetest.register_lbm({
        label = "Fix lost techage numbers for matrix screens",
        name = "ta4_addons:repair_matrix_screen_numbers",
        nodenames = {"ta4_addons:matrix_screen", "ta4_addons:matrix_screen_programmer"},
        action = function(pos, node)
            techage.repair_number(pos)
        end
    })
end

minetest.register_lbm({
    label = "Fix lost timer for matrix screens",
    name = "ta4_addons:repair_matrix_screen_timer",
    nodenames = {"ta4_addons:matrix_screen"},
    action = function(pos, node)
        minetest.get_node_timer(pos):start(2)
    end
})