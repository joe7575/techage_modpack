local materials = {
	dirt = "default:dirt",
	sand = "default:sand",
	gravel = "default:gravel",
	copper_ingot = "default:copper_ingot",
	steel_ingot = "default:steel_ingot",
	gold_ingot = "default:gold_ingot",
	tin_ingot = "default:tin_ingot",
	mese_crystal_fragment = "default:mese_crystal_fragment",
	torch = "default:torch",
	diamond = "default:diamond",
	clay_lump = "default:clay_lump",
	water_bucket = "bucket:bucket_water",
	empty_bucket = "bucket:bucket_empty",
	dye_dark_grey = "dye:dark_grey",
	silicon = "mesecons_materials:silicon",
}

if minetest.get_modpath("moreores") then
	materials.silver_ingot = "moreores:silver_ingot"
end

if minetest.get_modpath("technic") then
	materials.lead_ingot = "technic:lead_ingot"
	materials.carbon_steel_ingot = "technic:carbon_steel_ingot"
	materials.stainless_steel_ingot = "technic:stainless_steel_ingot"
end

if minetest.get_modpath("aloz") then
	materials["aluminum_ingot"] = "aloz:aluminum_ingot"
end

if minetest.get_modpath("mcl_core") then
	materials = {
		dirt = "mcl_core:dirt",
		sand = "mcl_core:sand",
		gravel = "mcl_core:gravel",
		steel_ingot = "mcl_core:iron_ingot",
		gold_ingot = "mcl_core:gold_ingot",
		mese_crystal_fragment = "mesecons:redstone",
		torch = "mcl_torches:torch",
		diamond = "mcl_core:diamond",
		clay_lump = "mcl_core:clay_lump",
		water_bucket = "mcl_buckets:bucket_water",
		empty_bucket = "mcl_buckets:bucket_empty",
		dye_dark_grey = "mcl_dye:dark_grey",
		-- Use iron where no equivalent
		copper_ingot = "mcl_core:iron_ingot",
		tin_ingot = "mcl_core:iron_ingot",
		silver_ingot = "mcl_core:iron_ingot",
		silicon = "mesecons_materials:silicon",
	}
elseif minetest.get_modpath("fl_ores") and minetest.get_modpath("fl_stone") then
	materials = {
		dirt = "fl_topsoil:dirt",
		sand = "fl_stone:sand",
		gravel = "fl_topsoil:gravel",
		steel_ingot = "fl_ores:iron_ingot",
		gold_ingot = "fl_ores:gold_ingot",
		mese_crystal_fragment = "fl_ores:iron_ingot",
		torch = "fl_light_sources:torch",
		diamond = "fl_ores:diamond",
		clay_lump = "fl_bricks:clay_lump",
		water_bucket = "fl_bucket:bucket_water",
		empty_bucket = "fl_bucket:bucket",
		dye_dark_grey = "fl_dyes:dark_grey_dye",
		copper_ingot = "fl_ores:copper_ingot",
		tin_ingot = "fl_ores:tin_ingot",
		silver_ingot = "fl_ores:iron_ingot",
		silicon = "mesecons_materials:silicon",
	}
elseif minetest.get_modpath("rp_default") then
	materials = {
		dirt = "rp_default:dirt",
		sand = "rp_default:sand",
		gravel = "rp_default:gravel",
		steel_ingot = "rp_default:ingot_steel",
		gold_ingot = "rp_default:ingot_gold",
		mese_crystal_fragment = "rp_default:ingot_steel",
		torch = "rp_default:torch",
		diamond = "rp_default:pearl",
		clay_lump = "rp_default:ingot_steel",
		water_bucket = "rp_default:swamp_dirt",
		empty_bucket = "rp_default:dirt",
		dye_dark_grey = "rp_default:ingot_steel",
		copper_ingot = "rp_default:ingot_copper",
		tin_ingot = "rp_default:ingot_tin",
		silver_ingot = "rp_default:ingot_steel",
		silicon = "rp_default:ingot_steel",
	}
elseif minetest.get_modpath("hades_core") then
	materials = {
		dirt = "hades_core:dirt",
		sand = "hades_core:fertile_sand",
		gravel = "hades_core:gravel",
		steel_ingot = "hades_core:steel_ingot",
		gold_ingot = "hades_core:gold_ingot",
		mese_crystal_fragment = "hades_core:mese_crystal_fragment",
		torch = "hades_torches:torch",
		diamond = "hades_core:diamond",
		clay_lump = "hades_core:clay_lump",
		dye_dark_grey = "hades_dye:dark_grey",
		copper_ingot = "hades_core:copper_ingot",
		tin_ingot = "hades_core:tin_ingot",
		--[[
			Since hades doesnt have buckets or water for the user,
			using dirt from near water to pull the water out
		]]
		water_bucket = "hades_core:dirt",
		empty_bucket = "hades_core:fertile_sand",
		-- Set this to steel unless hadesextraores is present
		silver_ingot = "hades_core:steel_ingot",
		silicon = "hades_materials:silicon",
	}

	if minetest.get_modpath("hades_bucket") then
		materials["water_bucket"] = "hades_bucket:bucket_water"
		materials["empty_bucket"] = "hades_bucket:bucket_empty"
	end
	if minetest.get_modpath("hades_extraores") then
		materials["silver_ingot"] = "hades_extraores:silver_ingot"
		materials["aluminum_ingot"] = "hades_extraores:aluminum_ingot"
	end
	if minetest.get_modpath("hades_technic") then
		materials.lead_ingot = "hades_technic:lead_ingot"
		materials.carbon_steel_ingot = "hades_technic:carbon_steel_ingot"
		materials.stainless_steel_ingot = "hades_technic:stainless_steel_ingot"
	end
end

local have_hades_materials = minetest.get_modpath("hades_materials")

local function compress_craft(input)
	local buffer = {}
	for _, item in pairs(input) do
		if type(item)=="table" then
			for _, inneritem in pairs(item) do
				buffer[inneritem] = (buffer[inneritem] or 0) + 1
			end
		elseif item ~= "" then
			buffer[item] = (buffer[item] or 0) + 1
		end
	end

	local output = {}
	for item, count in pairs(buffer) do
		output[#output + 1] = item .. " " .. count
	end
	return output
end

local function register_craft(input)
	if minetest.get_modpath("rp_crafting") then
		local rp_craft = compress_craft(input.recipe)
		if #rp_craft > crafting.MAX_INPUTS then
			minetest.log("error", "[basic_materials] unable to register craft for " .. input.output)
			return
		end

		crafting.register_craft({
			output = input.output,
			items = rp_craft
		})
	else
		minetest.register_craft(input)
	end
end

-- Craft recipes
register_craft({
	output = "basic_materials:chainlink_brass 12",
	recipe = {
		{"", "basic_materials:brass_ingot", "basic_materials:brass_ingot"},
		{"basic_materials:brass_ingot", "", "basic_materials:brass_ingot"},
		{"basic_materials:brass_ingot", "basic_materials:brass_ingot", ""},
	},
})

register_craft({
	output = "basic_materials:chain_steel 2",
	recipe = {
		{"basic_materials:chainlink_steel"},
		{"basic_materials:chainlink_steel"},
		{"basic_materials:chainlink_steel"}
	}
})

register_craft({
	output = "basic_materials:chain_brass 2",
	recipe = {
		{"basic_materials:chainlink_brass"},
		{"basic_materials:chainlink_brass"},
		{"basic_materials:chainlink_brass"}
	}
})

register_craft( {
	type = "shapeless",
	output = "basic_materials:brass_ingot 9",
	recipe = {"basic_materials:brass_block"},
})

register_craft( {
	output = "basic_materials:brass_block",
	recipe = {
		{"basic_materials:brass_ingot", "basic_materials:brass_ingot", "basic_materials:brass_ingot"},
		{"basic_materials:brass_ingot", "basic_materials:brass_ingot", "basic_materials:brass_ingot"},
		{"basic_materials:brass_ingot", "basic_materials:brass_ingot", "basic_materials:brass_ingot"},
	},
})

register_craft( {
	output = "basic_materials:plastic_strip 9",
	recipe = {
		{"basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet"}
	},
})

register_craft( {
	output = "basic_materials:empty_spool 3",
	recipe = {
		{"basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet"},
		{"", "basic_materials:plastic_sheet", ""},
		{"basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet"}
	},
})

if have_hades_materials then
	minetest.clear_craft({
		type = "shapeless",
		recipe = {"group:leaves", "group:leaves", "group:leaves", "group:leaves", "group:leaves", "group:leaves"}
	})
end

register_craft({
	type = "shapeless",
	output = "basic_materials:oil_extract 2",
	recipe = {"group:leaves", "group:leaves", "group:leaves", "group:leaves", "group:leaves", "group:leaves"}
})

-- Cooking recipes
if not have_hades_materials then
	minetest.register_craft({
		type = "cooking",
		output = "basic_materials:plastic_sheet",
		recipe = "basic_materials:paraffin",
	})
end

minetest.register_craft({
	type = "cooking",
	output = "basic_materials:paraffin",
	recipe = "basic_materials:oil_extract",
})

minetest.register_craft({
	type = "cooking",
	output = "basic_materials:cement_block",
	recipe = "basic_materials:wet_cement",
	cooktime = 8
})

-- Fuel recipes
minetest.register_craft({
	type = "fuel",
	recipe = "basic_materials:plastic_sheet",
	burntime = 30,
})

minetest.register_craft({
	type = "fuel",
	recipe = "basic_materials:oil_extract",
	burntime = 30,
})

minetest.register_craft({
	type = "fuel",
	recipe = "basic_materials:paraffin",
	burntime = 30,
})

register_craft({
	output = "basic_materials:concrete_block 6",
	recipe = {
		{"group:sand", "basic_materials:wet_cement", materials.gravel},
		{"basic_materials:steel_bar", "basic_materials:wet_cement", "basic_materials:steel_bar"},
		{materials.gravel, "basic_materials:wet_cement", "group:sand"},
	}
})

register_craft( {
	output = "basic_materials:motor 2",
	recipe = {
		{materials.mese_crystal_fragment, "basic_materials:copper_wire", "basic_materials:plastic_sheet"},
		{materials.copper_ingot, materials.steel_ingot, materials.steel_ingot},
		{materials.mese_crystal_fragment, "basic_materials:copper_wire", "basic_materials:plastic_sheet"}
	},
	replacements = {
		{"basic_materials:copper_wire", "basic_materials:empty_spool"},
		{"basic_materials:copper_wire", "basic_materials:empty_spool"},
	}
})

register_craft( {
	output = "basic_materials:heating_element 2",
	recipe = {
		{materials.copper_ingot, materials.mese_crystal_fragment, materials.copper_ingot}
	},
})

register_craft({
	--type = "shapeless",
	output = "basic_materials:energy_crystal_simple 2",
	recipe = {
		{materials.mese_crystal_fragment, materials.torch, materials.mese_crystal_fragment},
		{materials.diamond, materials.gold_ingot, materials.diamond}
	},
})

register_craft( {
	output = "basic_materials:copper_wire 2",
	type = "shapeless",
	recipe = {
		materials.copper_ingot,
		"basic_materials:empty_spool",
		"basic_materials:empty_spool",
	},
})

register_craft( {
	output = "basic_materials:gold_wire 2",
	type = "shapeless",
	recipe = {
		materials.gold_ingot,
		"basic_materials:empty_spool",
		"basic_materials:empty_spool",
	},
})

register_craft( {
	output = "basic_materials:steel_wire 2",
	type = "shapeless",
	recipe = {
		materials.steel_ingot,
		"basic_materials:empty_spool",
		"basic_materials:empty_spool",
	},
})

if materials.stainless_steel_ingot then
	register_craft( {
		output = "basic_materials:stainless_steel_wire 2",
		type = "shapeless",
		recipe = {
			materials.stainless_steel_ingot,
			"basic_materials:empty_spool",
			"basic_materials:empty_spool",
		},
	})
end

if materials.aluminum_ingot then
	register_craft( {
		output = "basic_materials:aluminum_wire 2",
		type = "shapeless",
		recipe = {
			materials.aluminum_ingot,
			"basic_materials:empty_spool",
			"basic_materials:empty_spool",
		},
	})
end

register_craft( {
	output = "basic_materials:steel_strip 12",
	recipe = {
		{"", materials.steel_ingot, ""},
		{materials.steel_ingot, "", ""},
	},
})

register_craft( {
	output = "basic_materials:copper_strip 12",
	recipe = {
		{"", materials.copper_ingot, ""},
		{materials.copper_ingot, "", ""},
	},
})

register_craft( {
	output = "basic_materials:gold_strip 12",
	recipe = {
		{"", materials.gold_ingot, ""},
		{materials.gold_ingot, "", ""},
	},
})

if materials.lead_ingot then
	register_craft( {
		output = "basic_materials:lead_strip 12",
		recipe = {
			{"", materials.lead_ingot, ""},
			{materials.lead_ingot, "", ""},
		},
	})
end

if materials.stainless_steel_ingot then
	register_craft( {
		output = "basic_materials:stainless_steel_strip 12",
		recipe = {
			{"", materials.stainless_steel_ingot, ""},
			{materials.stainless_steel_ingot, "", ""},
		},
	})
end

if materials.aluminum_ingot then
	register_craft( {
		output = "basic_materials:aluminum_strip 12",
		recipe = {
			{"", materials.aluminum_ingot, ""},
			{materials.aluminum_ingot, "", ""},
		},
	})
end

register_craft( {
	output = "basic_materials:steel_bar 6",
	recipe = {
		{"", "", materials.steel_ingot},
		{"", materials.steel_ingot, ""},
		{materials.steel_ingot, "", ""},
	},
})

if materials.carbon_steel_ingot then
	register_craft( {
		output = "basic_materials:carbon_steel_bar 6",
		recipe = {
			{"", "", materials.carbon_steel_ingot},
			{"", materials.carbon_steel_ingot, ""},
			{materials.carbon_steel_ingot, "", ""},
		},
	})
end

if materials.stainless_steel_ingot then
	register_craft( {
		output = "basic_materials:stainless_steel_bar 6",
		recipe = {
			{"", "", materials.stainless_steel_ingot},
			{"", materials.stainless_steel_ingot, ""},
			{materials.stainless_steel_ingot, "", ""},
		},
	})
end

if materials.aluminum_ingot then
	register_craft( {
		output = "basic_materials:aluminum_bar 6",
		recipe = {
			{"", "", materials.aluminum_ingot},
			{"", materials.aluminum_ingot, ""},
			{materials.aluminum_ingot, "", ""},
		},
	})
end

register_craft( {
	output = "basic_materials:padlock 2",
	recipe = {
		{"basic_materials:steel_bar"},
		{materials.steel_ingot},
		{materials.steel_ingot},
	},
})

register_craft({
	output = "basic_materials:chainlink_steel 12",
	recipe = {
		{"", materials.steel_ingot, materials.steel_ingot},
		{materials.steel_ingot, "", materials.steel_ingot},
		{materials.steel_ingot, materials.steel_ingot, ""},
	},
})

register_craft( {
	output = "basic_materials:gear_steel 6",
	recipe = {
		{"", materials.steel_ingot, ""},
		{materials.steel_ingot,"basic_materials:chainlink_steel", materials.steel_ingot},
		{"", materials.steel_ingot, ""}
	},
})

register_craft( {
	type = "shapeless",
	output = "basic_materials:terracotta_base 8",
	recipe = {
		materials.water_bucket,
		materials.clay_lump,
		materials.gravel,
	},
	replacements = {{materials.water_bucket, materials.empty_bucket}},
})

register_craft({
	type = "shapeless",
	output = "basic_materials:wet_cement 3",
	recipe = {
		materials.dirt,
		materials.dye_dark_grey,
		materials.dye_dark_grey,
		materials.dye_dark_grey,
		materials.water_bucket
	},
	replacements = {{materials.water_bucket, materials.empty_bucket}},
})

if not have_hades_materials then
	register_craft( {
		output = materials.silicon.." 4",
		recipe = {
			{materials.sand, materials.sand},
			{materials.sand, materials.steel_ingot},
		},
	})
end

register_craft( {
	output = "basic_materials:ic 4",
	recipe = {
		{materials.silicon, materials.silicon},
		{materials.silicon, materials.copper_ingot},
	},
})

-- Without moreores, there still should be a way to create brass.
register_craft( {
	output = "basic_materials:brass_ingot 9",
	recipe = {
		{materials.copper_ingot, materials.tin_ingot, materials.copper_ingot},
		{materials.gold_ingot, materials.copper_ingot, materials.tin_ingot},
		{materials.copper_ingot, materials.tin_ingot, materials.copper_ingot},
	},
})

if materials.silver_ingot then
	register_craft( {
		output = "basic_materials:silver_wire 2",
		type = "shapeless",
		recipe = {
			materials.silver_ingot,
			"basic_materials:empty_spool",
			"basic_materials:empty_spool",
		},
	})

	register_craft( {
		type = "shapeless",
		output = "basic_materials:brass_ingot 3",
		recipe = {
			materials.copper_ingot,
			materials.copper_ingot,
			materials.silver_ingot,
		},
	})
end
