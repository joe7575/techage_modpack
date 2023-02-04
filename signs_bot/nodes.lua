--[[

	Signs Bot
	=========

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Node information tables for the Bot

]]--

signs_bot.FarmingSeed = {}
signs_bot.FarmingCrop = {}
signs_bot.FarmingNeedTrellis = {}
signs_bot.FarmingKeepTrellis = {}
signs_bot.TreeSaplings = {}

-- inv_seed is the seed inventory name
-- plantlet is what has to be placed on the ground (stage 1)
-- crop is the farming crop in the final stage
function signs_bot.register_farming_plant(inv_seed, plantlet, crop, trellis)
	signs_bot.FarmingCrop[crop] = true
	signs_bot.FarmingSeed[inv_seed] = plantlet
	if trellis then
		signs_bot.FarmingNeedTrellis[plantlet] = trellis
		signs_bot.FarmingKeepTrellis[crop] = trellis
	end
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
	local fp_grows = function(def, step)
		local crop = def.crop .. "_" .. step
		local node = minetest.registered_nodes[crop]
		if node then
			fp(def.seed, def.crop .. "_1", crop, def.trellis)
			return node.groups and node.groups.growing
		end
	end

	for name, def in pairs(farming.registered_plants) do
		-- everything except cocoa (these can only be placed on jungletree)
		if name ~= "farming:cocoa_beans" then
			local step = def.steps
			if step then
				while fp_grows(def, step) do step = step + 1 end
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Ethereal Farming
-------------------------------------------------------------------------------

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
