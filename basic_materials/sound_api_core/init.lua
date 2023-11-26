local sound_api = {}

--convert some games for api usage

--ks_sounds conversion
--currently loggy and bedrock are ignored
local ks = {}

function ks.node_sound_defaults(table)
	table = table or {}
	table.footstep = table.footstep or ks_sounds.generalnode_sounds.footstep
	table.dug = table.dug or ks_sounds.generalnode_sounds.dug
    table.dig = table.dig or ks_sounds.generalnode_sounds.dig
	table.place = table.place or ks_sounds.generalnode_sounds.place
	return table
end

function ks.node_sound_wood_defaults(table)
	table = table or {}
	table.footstep = table.footstep or ks_sounds.woodennode_sounds.footstep
	table.dug = table.dug or ks_sounds.woodennode_sounds.dug
    table.dig = table.dig or ks_sounds.woodennode_sounds.dig
	table.place = table.place or ks_sounds.woodennode_sounds.place
	ks.node_sound_defaults(table)
	return table
end

function ks.node_sound_leaves_defaults(table)
	table = table or {}
	table.footstep = table.footstep or ks_sounds.leafynode_sounds.footstep
	table.dug = table.dug or ks_sounds.leafynode_sounds.dug
    table.dig = table.dig or ks_sounds.leafynode_sounds.dig
	table.place = table.place or ks_sounds.leafynode_sounds.place
	ks.node_sound_defaults(table)
	return table
end

function ks.node_sound_snow_defaults(table)
	table = table or {}
	table.footstep = table.footstep or ks_sounds.snowynode_sounds.footstep
	table.dug = table.dug or ks_sounds.snowynode_sounds.dug
    table.dig = table.dig or ks_sounds.snowynode_sounds.dig
	table.place = table.place or ks_sounds.snowynode_sounds.place
	ks.node_sound_defaults(table)
	return table
end


--api
function sound_api.node_sound_default(table)
    if minetest.get_modpath("default") then
        return default.node_sound_defaults(table)
    elseif minetest.get_modpath("mcl_sounds") then
        return mcl_sounds.node_sound_defaults(table)
    elseif minetest.get_modpath("ks_sounds") then
        return ks.node_sound_default(table)
    elseif minetest.get_modpath("nodes_nature") then
        return nodes_nature.node_sound_default(table)
    elseif minetest.get_modpath("hades_sounds") then
        return hades_sounds.node_sound_defaults(table)
    else
        return table
    end
end

function sound_api.node_sound_stone_defaults(table)
    if minetest.get_modpath("default") then
        return default.node_sound_stone_defaults(table)
    elseif minetest.get_modpath("mcl_sounds") then
        return mcl_sounds.node_sound_stone_defaults(table)
    elseif minetest.get_modpath("nodes_nature") then
        return nodes_nature.node_sound_stone_defaults(table)
    elseif minetest.get_modpath("fl_stone") then
        return fl_stone.sounds.stone(table)
    elseif minetest.get_modpath("hades_sounds") then
        return hades_sounds.node_sound_stone_defaults(table)
    else
        return table
    end
end

function sound_api.node_sound_dirt_defaults(table)
    if minetest.get_modpath("default") then
        return default.node_sound_dirt_defaults(table)
    elseif minetest.get_modpath("mcl_sounds") then
        return mcl_sounds.node_sound_dirt_defaults(table)
    elseif minetest.get_modpath("nodes_nature") then
        return nodes_nature.node_sound_dirt_defaults(table)
    --s/dirt/grass
    elseif minetest.get_modpath("fl_topsoil") then
        return fl_topsoil.sounds.grass(table)
    elseif minetest.get_modpath("hades_sounds") then
        return hades_sounds.node_sound_dirt_defaults(table)
    else
        return table
    end
end

--return dirt as some games use dirt vs grass
function sound_api.node_sound_grass_defaults(table)
    if minetest.get_modpath("hades_sounds") then
        return hades_sounds.node_sound_grass_defaults(table)
    else
        return sound_api.node_sound_dirt_defaults(table)
    end
end

function sound_api.node_sound_sand_defaults(table)
    if minetest.get_modpath("default") then
        return default.node_sound_sand_defaults(table)
    elseif minetest.get_modpath("mcl_sounds") then
        return mcl_sounds.node_sound_sand_defaults(table)
    elseif minetest.get_modpath("nodes_nature") then
        return nodes_nature.node_sound_sand_defaults(table)
    elseif minetest.get_modpath("fl_stone") then
        return fl_stone.sounds.sand(table)
    elseif minetest.get_modpath("hades_sounds") then
        return hades_sounds.node_sound_sand_defaults(table)
    else
        return table
    end
end

function sound_api.node_sound_gravel_defaults(table)
    if minetest.get_modpath("default") then
        return default.node_sound_gravel_defaults(table)
    --s/gravel/sand
    elseif minetest.get_modpath("mcl_sounds") then
        return mcl_sounds.node_sound_sand_defaults(table)
    elseif minetest.get_modpath("nodes_nature") then
        return nodes_nature.node_sound_gravel_defaults(table)
    elseif minetest.get_modpath("fl_topsoil") then
        return fl_topsoil.sounds.gravel(table)
    elseif minetest.get_modpath("hades_sounds") then
        return hades_sounds.node_sound_gravel_defaults(table)
    else
        return table
    end
end

function sound_api.node_sound_wood_defaults(table)
    if minetest.get_modpath("default") then
        return default.node_sound_wood_defaults(table)
    elseif minetest.get_modpath("mcl_sounds") then
        return mcl_sounds.node_sound_wood_defaults(table)
    elseif minetest.get_modpath("ks_sounds") then
        return ks.node_sound_wood_default(table)
    elseif minetest.get_modpath("nodes_nature") then
        return nodes_nature.node_sound_wood_defaults(table)
    elseif minetest.get_modpath("fl_trees") then
        return fl_trees.sounds.wood(table)
    elseif minetest.get_modpath("hades_sounds") then
        return hades_sounds.node_sound_wood_defaults(table)
    else
        return table
    end
end

function sound_api.node_sound_leaves_defaults(table)
    if minetest.get_modpath("default") then
        return default.node_sound_leaves_defaults(table)
    elseif minetest.get_modpath("mcl_sounds") then
        return mcl_sounds.node_sound_leaves_defaults(table)
    elseif minetest.get_modpath("ks_sounds") then
        return ks.node_sound_leaves_default(table)
    elseif minetest.get_modpath("nodes_nature") then
        return nodes_nature.node_sound_leaves_defaults(table)
    elseif minetest.get_modpath("hades_sounds") then
        return hades_sounds.node_sound_leaves_defaults(table)
    else
        return table
    end
end

function sound_api.node_sound_glass_defaults(table)
    if minetest.get_modpath("default") then
        return default.node_sound_glass_defaults(table)
    elseif minetest.get_modpath("mcl_sounds") then
        return mcl_sounds.node_sound_glass_defaults(table)
    elseif minetest.get_modpath("nodes_nature") then
        return nodes_nature.node_sound_glass_defaults(table)
    elseif minetest.get_modpath("hades_sounds") then
        return hades_sounds.node_sound_glass_defaults(table)
    else
        return table
    end
end


function sound_api.node_sound_ice_defaults(table)
    if minetest.get_modpath("default") then
        return default.node_sound_ice_defaults(table)
    --s/ice/glass
    elseif minetest.get_modpath("mcl_sounds") then
        return mcl_sounds.node_sound_glass_defaults(table)
    --s/ice/glass
    elseif minetest.get_modpath("nodes_nature") then
        return nodes_nature.node_sound_glass_defaults(table)
    --s/ice/glass
    elseif minetest.get_modpath("hades_sounds") then
        return hades_sounds.node_sound_glass_defaults(table)
    else
        return table
    end
end

function sound_api.node_sound_metal_defaults(table)
    if minetest.get_modpath("default") then
        return default.node_sound_metal_defaults(table)
    elseif minetest.get_modpath("mcl_sounds") then
        return mcl_sounds.node_sound_metal_defaults(table)
    elseif minetest.get_modpath("hades_sounds") then
        return hades_sounds.node_sound_metal_defaults(table)
    else
        return table
    end
end

function sound_api.node_sound_water_defaults(table)
    if minetest.get_modpath("default") then
        return default.node_sound_water_defaults(table)
    elseif minetest.get_modpath("mcl_sounds") then
        return mcl_sounds.node_sound_water_defaults(table)
    elseif minetest.get_modpath("nodes_nature") then
        return nodes_nature.node_sound_water_defaults(table)
    elseif minetest.get_modpath("hades_sounds") then
        return hades_sounds.node_sound_water_defaults(table)
    else
        return table
    end
end

function sound_api.node_sound_lava_defaults(table)
    --s/lava/water
    if minetest.get_modpath("default") then
        return default.node_sound_water_defaults(table)
    elseif minetest.get_modpath("mcl_sounds") then
        return mcl_sounds.node_sound_lava_defaults(table)
    --s/lava/water
    elseif minetest.get_modpath("nodes_nature") then
        return nodes_nature.node_sound_water_defaults(table)
    elseif minetest.get_modpath("hades_sounds") then
        return hades_sounds.node_sound_lava_defaults(table)
    else
        return table
    end
end

function sound_api.node_sound_snow_defaults(table)
    if minetest.get_modpath("default") then
        return default.node_sound_snow_defaults(table)
    elseif minetest.get_modpath("mcl_sounds") then
        return mcl_sounds.node_sound_snow_defaults(table)
    elseif minetest.get_modpath("ks_sounds") then
        return ks.node_sound_snow_default(table)
    elseif minetest.get_modpath("nodes_nature") then
        return nodes_nature.node_sound_snow_defaults(table)
    elseif minetest.get_modpath("fl_topsoil") then
        return fl_topsoil.sounds.snow(table)
    else
        return table
    end
end

function sound_api.node_sound_wool_defaults(table)
    --s/wool/default
    if minetest.get_modpath("default") then
        return default.node_sound_defaults(table)
    elseif minetest.get_modpath("mcl_sounds") then
        return mcl_sounds.node_sound_wool_defaults(table)
    else
        return table
    end
end

return sound_api