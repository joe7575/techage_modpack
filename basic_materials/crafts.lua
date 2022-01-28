--craft recipes
minetest.register_craft({
	output = "basic_materials:chainlink_brass 12",
	recipe = {
		{"", "basic_materials:brass_ingot", "basic_materials:brass_ingot"},
		{ "basic_materials:brass_ingot", "", "basic_materials:brass_ingot" },
		{ "basic_materials:brass_ingot", "basic_materials:brass_ingot", "" },
	},
})

minetest.register_craft({
	output = 'basic_materials:chain_steel 2',
	recipe = {
		{"basic_materials:chainlink_steel"},
		{"basic_materials:chainlink_steel"},
		{"basic_materials:chainlink_steel"}
	}
})

minetest.register_craft({
	output = 'basic_materials:chain_brass 2',
	recipe = {
		{"basic_materials:chainlink_brass"},
		{"basic_materials:chainlink_brass"},
		{"basic_materials:chainlink_brass"}
	}
})

minetest.register_craft( {
	type = "shapeless",
	output = "basic_materials:brass_ingot 9",
	recipe = { "basic_materials:brass_block" },
})

minetest.register_craft( {
	output = "basic_materials:brass_block",
	recipe = {
		{ "basic_materials:brass_ingot", "basic_materials:brass_ingot", "basic_materials:brass_ingot" },
		{ "basic_materials:brass_ingot", "basic_materials:brass_ingot", "basic_materials:brass_ingot" },
		{ "basic_materials:brass_ingot", "basic_materials:brass_ingot", "basic_materials:brass_ingot" },
	},
})

minetest.register_craft( {
    output = "basic_materials:plastic_strip 9",
    recipe = {
		{ "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" }
    },
})

minetest.register_craft( {
	output = "basic_materials:empty_spool 3",
	recipe = {
		{ "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" },
		{ "", "basic_materials:plastic_sheet", "" },
		{ "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" }
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "basic_materials:oil_extract 2",
	recipe = {"group:leaves", "group:leaves", "group:leaves", "group:leaves", "group:leaves", "group:leaves"}
})

--cooking recipes
minetest.register_craft({
	type = "cooking",
	output = "basic_materials:plastic_sheet",
	recipe = "basic_materials:paraffin",
})

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

--fuel recipes
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

if minetest.get_modpath("default") then
    minetest.register_craft({
        output = 'basic_materials:concrete_block 6',
        recipe = {
            {'group:sand',                'basic_materials:wet_cement', 'default:gravel'},
            {'basic_materials:steel_bar', 'basic_materials:wet_cement', 'basic_materials:steel_bar'},
            {'default:gravel',            'basic_materials:wet_cement', 'group:sand'},
        }
    })

    minetest.register_craft( {
        output = "basic_materials:motor 2",
        recipe = {
            { "default:mese_crystal_fragment", "basic_materials:copper_wire", "basic_materials:plastic_sheet" },
            { "default:copper_ingot",          "default:steel_ingot",         "default:steel_ingot" },
            { "default:mese_crystal_fragment", "basic_materials:copper_wire", "basic_materials:plastic_sheet" }
        },
        replacements = {
            { "basic_materials:copper_wire", "basic_materials:empty_spool" },
            { "basic_materials:copper_wire", "basic_materials:empty_spool" },
        }
    })

    minetest.register_craft( {
        output = "basic_materials:heating_element 2",
        recipe = {
            { "default:copper_ingot", "default:mese_crystal_fragment", "default:copper_ingot" }
        },
    })

    minetest.register_craft({
        --type = "shapeless",
        output = "basic_materials:energy_crystal_simple 2",
        recipe = {
            { "default:mese_crystal_fragment", "default:torch", "default:mese_crystal_fragment" },
            { "default:diamond", "default:gold_ingot", "default:diamond" }
        },
    })

    minetest.register_craft( {
        output = "basic_materials:copper_wire 2",
        type = "shapeless",
        recipe = {
            "default:copper_ingot",
            "basic_materials:empty_spool",
            "basic_materials:empty_spool",
        },
    })

    minetest.register_craft( {
        output = "basic_materials:gold_wire 2",
        type = "shapeless",
        recipe = {
            "default:gold_ingot",
            "basic_materials:empty_spool",
            "basic_materials:empty_spool",
        },
    })

    minetest.register_craft( {
        output = "basic_materials:steel_wire 2",
        type = "shapeless",
        recipe = {
            "default:steel_ingot",
            "basic_materials:empty_spool",
            "basic_materials:empty_spool",
        },
    })

    minetest.register_craft( {
        output = "basic_materials:steel_strip 12",
        recipe = {
            { "", "default:steel_ingot", "" },
            { "default:steel_ingot", "", "" },
        },
    })

    minetest.register_craft( {
        output = "basic_materials:copper_strip 12",
        recipe = {
            { "", "default:copper_ingot", "" },
            { "default:copper_ingot", "", "" },
        },
    })

    minetest.register_craft( {
        output = "basic_materials:steel_bar 6",
        recipe = {
            { "", "", "default:steel_ingot" },
            { "", "default:steel_ingot", "" },
            { "default:steel_ingot", "", "" },
        },
    })

    minetest.register_craft( {
        output = "basic_materials:padlock 2",
        recipe = {
            { "basic_materials:steel_bar" },
            { "default:steel_ingot" },
            { "default:steel_ingot" },
        },
    })

    minetest.register_craft({
        output = "basic_materials:chainlink_steel 12",
        recipe = {
            {"", "default:steel_ingot", "default:steel_ingot"},
            { "default:steel_ingot", "", "default:steel_ingot" },
            { "default:steel_ingot", "default:steel_ingot", "" },
        },
    })

    minetest.register_craft( {
        output = "basic_materials:gear_steel 6",
        recipe = {
            { "", "default:steel_ingot", "" },
            { "default:steel_ingot","basic_materials:chainlink_steel", "default:steel_ingot" },
            { "", "default:steel_ingot", "" }
        },
    })

    if minetest.get_modpath("bucket") then
        minetest.register_craft( {
            type = "shapeless",
            output = "basic_materials:terracotta_base 8",
            recipe = {
                "bucket:bucket_water",
                "default:clay_lump",
                "default:gravel",
            },
            replacements = { {"bucket:bucket_water", "bucket:bucket_empty"}, },
        })

        if minetest.get_modpath("dye") then
            minetest.register_craft({
                type = "shapeless",
                output = "basic_materials:wet_cement 3",
                recipe = {
                    "default:dirt",
                    "dye:dark_grey",
                    "dye:dark_grey",
                    "dye:dark_grey",
                    "bucket:bucket_water"
                },
                replacements = {{'bucket:bucket_water', 'bucket:bucket_empty'},},
            })
        end
    end

    if minetest.get_modpath("mesecons_materials") then
        minetest.register_craft( {
            output = "mesecons_materials:silicon 4",
            recipe = {
                { "default:sand", "default:sand" },
                { "default:sand", "default:steel_ingot" },
            },
        })

        minetest.register_craft( {
            output = "basic_materials:ic 4",
            recipe = {
                { "mesecons_materials:silicon", "mesecons_materials:silicon" },
                { "mesecons_materials:silicon", "default:copper_ingot" },
            },
        })
    end

    if not minetest.get_modpath("moreores") then
        -- Without moreores, there still should be a way to create brass.
        minetest.register_craft( {
            output = "basic_materials:brass_ingot 9",
            recipe = {
            {"default:copper_ingot", "default:tin_ingot", "default:copper_ingot"},
            {"default:gold_ingot", "default:copper_ingot", "default:gold_ingot"},
            {"default:copper_ingot", "default:tin_ingot", "default:copper_ingot"},
            },
        })
    elseif minetest.get_modpath("moreores") then
        minetest.register_craft( {
            output = "basic_materials:silver_wire 2",
            type = "shapeless",
            recipe = {
                "moreores:silver_ingot",
                "basic_materials:empty_spool",
                "basic_materials:empty_spool",
            },
        })

        minetest.register_craft( {
            type = "shapeless",
            output = "basic_materials:brass_ingot 3",
            recipe = {
                "default:copper_ingot",
                "default:copper_ingot",
                "moreores:silver_ingot",
            },
        })
    end
end