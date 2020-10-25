--[[

	Signs Bot
	=========

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Node information tables for the Bot

]]--

signs_bot.FarmingSeed = {}
signs_bot.FarmingCrop = {}
signs_bot.TreeSaplings = {}

-- inv_seed is the seed inventory name
-- plantlet is what has to be placed on the ground (stage 1)
-- crop is the farming crop in the final stage
function signs_bot.register_farming_plant(inv_seed, plantlet, crop)
	signs_bot.FarmingCrop[crop] = true
	signs_bot.FarmingSeed[inv_seed] = plantlet
end

-- inv_sapling is the sapling inventory name
-- sapling is what has to be placed on the ground 
-- t1/t2 is needed for trees which require the node timer
function signs_bot.register_tree_saplings(inv_sapling, sapling, t1, t2)
	signs_bot.TreeSaplings[inv_sapling] = {sapling = sapling, t1 = t1 or 300, t2 = t2 or 1500}
end

local fp = signs_bot.register_farming_plant
local ts = signs_bot.register_tree_saplings


if farming.mod ~= "redo" then
	fp("farming:seed_wheat", "farming:wheat_1", "farming:wheat_8")
	fp("farming:seed_cotton", "farming:cotton_1", "farming:cotton_8")
end

-------------------------------------------------------------------------------
-- Farming Redo
-------------------------------------------------------------------------------
if farming.mod == "redo" then
	fp("farming:seed_wheat", "farming:wheat_1", "farming:wheat_8")
	fp("farming:seed_cotton", "farming:cotton_1", "farming:cotton_8")
	fp("farming:carrot", "farming:carrot_1", "farming:carrot_8")
	fp("farming:potato", "farming:potato_1", "farming:potato_4")
	fp("farming:tomato", "farming:tomato_1", "farming:tomato_8")
	fp("farming:cucumber", "farming:cucumber_1", "farming:cucumber_4")
	fp("farming:corn", "farming:corn_1", "farming:corn_8")
	fp("farming:coffee_beans", "farming:coffee_1", "farming:coffee_5")
	fp("farming:melon_slice", "farming:melon_1", "farming:melon_8")
	fp("farming:pumpkin_slice", "farming:pumpkin_1", "farming:pumpkin_8")
	fp("farming:raspberries", "farming:raspberry_1", "farming:raspberry_4")
	fp("farming:blueberries", "farming:blueberry_1", "farming:blueberry_4")
	fp("farming:rhubarb", "farming:rhubarb_1", "farming:rhubarb_3")
	fp("farming:beans", "farming:beanpole_1", "farming:beanpole_5")
	fp("farming:grapes", "farming:grapes_1", "farming:grapes_8")
	fp("farming:seed_barley", "farming:barley_1", "farming:barley_7")
	fp("farming:chili_pepper", "farming:chili_1", "farming:chili_8")
	fp("farming:seed_hemp", "farming:hemp_1", "farming:hemp_8")
	fp("farming:seed_oat", "farming:oat_1", "farming:oat_8")
	fp("farming:seed_rye", "farming:rye_1", "farming:rye_8")
	fp("farming:seed_rice", "farming:rice_1", "farming:rice_8")
	fp("farming:beetroot", "farming:beetroot_1", "farming:beetroot_5")
	fp("farming:cocoa_beans", "farming:cocoa_1", "farming:cocoa_4")
	fp("farming:garlic_clove", "farming:garlic_1", "farming:garlic_5")
	fp("farming:onion", "farming:onion_1", "farming:onion_5")
	fp("farming:peas", "farming:pea_1", "farming:pea_5")
	fp("farming:peppercorn", "farming:pepper_1", "farming:pepper_5")
	fp("farming:pineapple_top", "farming:pineapple_1", "farming:pineapple_8")
end

-------------------------------------------------------------------------------
-- Ethereal Farming
-------------------------------------------------------------------------------
--fn("ethereal:strawberry_8",   "ethereal:strawberry 2",	     "ethereal:strawberry 1")
--fn("ethereal:onion_5",		  "ethereal:wild_onion_plant 2", "ethereal:onion_1")


--fn("ethereal:willow_trunk",   "ethereal:willow_trunk", "ethereal:willow_sapling")
--fn("ethereal:redwood_trunk",  "ethereal:redwood_trunk",  "ethereal:redwood_sapling")
--fn("ethereal:frost_tree",     "ethereal:frost_tree",  "ethereal:frost_tree_sapling")
--fn("ethereal:yellow_trunk",   "ethereal:yellow_trunk",  "ethereal:yellow_tree_sapling")
--fn("ethereal:palm_trunk",     "ethereal:palm_trunk",  "ethereal:palm_sapling")
--fn("ethereal:banana_trunk",   "ethereal:banana_trunk",  "ethereal:banana_tree_sapling")
--fn("ethereal:mushroom_trunk", "ethereal:mushroom_trunk",  "ethereal:mushroom_sapling")
--fn("ethereal:birch_trunk",    "ethereal:birch_trunk",  "ethereal:birch_sapling")
--fn("ethereal:bamboo",         "ethereal:bamboo",       "ethereal:bamboo_sprout")

--fn("ethereal:willow_twig")
--fn("ethereal:redwood_leaves")
--fn("ethereal:orange_leaves")
--fn("ethereal:bananaleaves")
--fn("ethereal:yellowleaves")
--fn("ethereal:palmleaves")
--fn("ethereal:birch_leaves")
--fn("ethereal:frost_leaves")
--fn("ethereal:bamboo_leaves")
--fn("ethereal:mushroom")
--fn("ethereal:mushroom_pore")
--fn("ethereal:bamboo_leaves")
--fn("ethereal:bamboo_leaves")
--fn("ethereal:banana")
--fn("ethereal:orange")
--fn("ethereal:coconut")

-------------------------------------------------------------------------------
-- Default Trees
-------------------------------------------------------------------------------
ts("default:acacia_bush_sapling", "default:acacia_bush_sapling")
ts("default:acacia_sapling", "default:acacia_sapling")
ts("default:aspen_sapling", "default:aspen_sapling")
ts("default:blueberry_bush_sapling", "default:blueberry_bush_sapling")
ts("default:bush_sapling", "default:bush_sapling")
ts("default:emergent_jungle_sapling", "default:emergent_jungle_sapling")
ts("default:junglesapling", "default:junglesapling")
ts("default:pine_bush_sapling", "default:pine_bush_sapling")
ts("default:pine_sapling", "default:pine_sapling")
ts("default:sapling", "default:sapling")
