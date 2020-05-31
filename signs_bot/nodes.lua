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
-- seed is what has to be placed on the ground (stage 1)
function signs_bot.register_farming_seed(inv_seed, seed)
	signs_bot.FarmingSeed[inv_seed] = {seed = seed}
end

-- crop is the farming crop in the final stage
-- inv_crop is the the inventory item name of the crop result
-- inv_seed is the the inventory item name of the seed result
function signs_bot.register_farming_crop(crop, inv_crop, inv_seed)
	signs_bot.FarmingCrop[crop] = {inv_crop = inv_crop, inv_seed = inv_seed}
end

-- inv_sapling is the sapling inventory name
-- sapling is what has to be placed on the ground 
-- t1/t2 is needed for trees which require the node timer
function signs_bot.register_tree_saplings(inv_sapling, sapling, t1, t2)
	signs_bot.TreeSaplings[inv_sapling] = {sapling = sapling, t1 = t1 or 300, t2 = t2 or 1500}
end

local fs = signs_bot.register_farming_seed
local fc = signs_bot.register_farming_crop
local ts = signs_bot.register_tree_saplings


if farming.mod ~= "redo" then
	fs("farming:seed_wheat", "farming:wheat_1")
	fc("farming:wheat_8", "farming:wheat", "farming:seed_wheat")
	fs("farming:seed_cotton", "farming:cotton_1")
	fc("farming:cotton_8", "farming:cotton", "farming:seed_cotton")
end

-------------------------------------------------------------------------------
-- Farming Redo
-------------------------------------------------------------------------------
if farming.mod == "redo" then
	fs("farming:seed_wheat",  "farming:wheat_1")
	fc("farming:wheat_8",     "farming:wheat",         "farming:seed_wheat")
	fs("farming:seed_cotton", "farming:cotton_1")
	fc("farming:cotton_8",    "farming:cotton",         "farming:seed_cotton")
	fs("farming:carrot",      "farming:carrot_1")
	fc("farming:carrot_8",    "farming:carrot",         "farming:carrot")
	fs("farming:potato",      "farming:potato_1")
	fc("farming:potato_4",    "farming:potato 2",       "farming:potato")
	fs("farming:tomato",      "farming:tomato_1")
	fc("farming:tomato_8",    "farming:tomato 2",       "farming:tomato")
	fs("farming:cucumber",    "farming:cucumber_1")
	fc("farming:cucumber_4",  "farming:cucumber",       "farming:cucumber")
	fs("farming:corn",        "farming:corn_1")
	fc("farming:corn_8",      "farming:corn",           "farming:corn")
	fs("farming:coffee_beans", "farming:coffee_1")
	fc("farming:coffee_5",    "farming:coffee_beans",   "farming:coffee_beans")
	fs("farming:melon_slice", "farming:melon_1")
	fc("farming:melon_8",     "farming:melon_8",        "farming:melon_slice")
	fs("farming:pumpkin_slice", "farming:pumpkin_1")
	fc("farming:pumpkin_8",   "farming:pumpkin_8",      "farming:pumpkin_slice")
	fs("farming:raspberries", "farming:raspberry_1")
	fc("farming:raspberry_4", "farming:raspberries 2",  "farming:raspberries")
	fs("farming:blueberries", "farming:blueberry_1")
	fc("farming:blueberry_4", "farming:blueberries",    "farming:blueberries")
	fs("farming:rhubarb",     "farming:rhubarb_1")
	fc("farming:rhubarb_3",   "farming:rhubarb",        "farming:rhubarb")
	fs("farming:beans",       "farming:beanpole_1")
	fc("farming:beanpole_5",  "farming:beans 2",        "farming:beans")
	fs("farming:grapes",      "farming:grapes_1")
	fc("farming:grapes_8",    "farming:grapes 2",       "farming:grapes")
	fs("farming:seed_barley", "farming:barley_1")
	fc("farming:barley_7",    "farming:barley",         "farming:seed_barley")
	fs("farming:chili_pepper", "farming:chili_1")
	fc("farming:chili_8",     "farming:chili_pepper",   "farming:chili_pepper")
	fs("farming:seed_hemp",   "farming:hemp_1")
	fc("farming:hemp_8",      "farming:hemp_leaf",      "farming:seed_hemp")
	fs("farming:seed_oat",    "farming:oat_1")
	fc("farming:oat_8",       "farming:oat",            "farming:seed_oat")
	fs("farming:seed_rye",    "farming:rye_1")
	fc("farming:rye_8",       "farming:rye",            "farming:seed_rye")
	fs("farming:seed_rice",   "farming:rice_1")
	fc("farming:rice_8",      "farming:rice",           "farming:seed_rice")
	fs("farming:beetroot",    'farming:beetroot_1')
	fc('farming:beetroot_5',  'farming:beetroot',       'farming:beetroot')
	fs("farming:cocoa_beans", 'farming:cocoa_1')
	fc('farming:cocoa_4',     'farming:cocoa_beans',    'farming:cocoa_beans')
	fs('farming:garlic_clove', 'farming:garlic_1')
	fc('farming:garlic_5',    'farming:garlic',         'farming:garlic_clove')
	fs('farming:onion',       'farming:onion_1')
	fc('farming:onion_5',     'farming:onion',          'farming:onion')
	fs('farming:peas',        'farming:pea_1')
	fc('farming:pea_5',       'farming:pea_pod 2',      'farming:peas')
	fs('farming:peppercorn',  'farming:pepper_1')
	fc('farming:pepper_5',    'farming:pepper 2',       'farming:peppercorn')
	fs('farming:pineapple',   'farming:pineapple_1')
	fc('farming:pineapple_8', 'farming:pineapple',      'farming:pineapple')
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
