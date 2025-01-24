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

-------------------------------------------------------------------------------
-- Ethereal (Saplings use ABM instead of NodeTimer)
-------------------------------------------------------------------------------
if minetest.get_modpath("ethereal") then
	ts("ethereal:bamboo_sprout", "ethereal:bamboo_sprout", nil)
	ts("ethereal:banana_tree_sapling", "ethereal:banana_tree_sapling", nil)
	ts("ethereal:basandra_bush_sapling", "ethereal:basandra_bush_sapling", nil)
	ts("ethereal:big_tree_sapling", "ethereal:big_tree_sapling", nil)
	ts("ethereal:birch_sapling", "ethereal:birch_sapling", nil)
	ts("ethereal:frost_tree_sapling", "ethereal:frost_tree_sapling", nil)
	ts("ethereal:giant_redwood_sapling", "ethereal:giant_redwood_sapling", nil)
	ts("ethereal:lemon_tree_sapling", "ethereal:lemon_tree_sapling", nil)
	ts("ethereal:mushroom_brown_sapling", "ethereal:mushroom_brown_sapling", nil)
	ts("ethereal:mushroom_sapling", "ethereal:mushroom_sapling", nil)
	ts("ethereal:olive_tree_sapling", "ethereal:olive_tree_sapling", nil)
	ts("ethereal:orange_tree_sapling", "ethereal:orange_tree_sapling", nil)
	ts("ethereal:palm_sapling", "ethereal:palm_sapling", nil)
	ts("ethereal:redwood_sapling", "ethereal:redwood_sapling", nil)
	ts("ethereal:sakura_sapling", "ethereal:sakura_sapling", nil)
	ts("ethereal:willow_sapling", "ethereal:willow_sapling", nil)
	ts("ethereal:yellow_tree_sapling", "ethereal:yellow_tree_sapling", nil)
end

-------------------------------------------------------------------------------
-- Moretrees
-------------------------------------------------------------------------------
if minetest.get_modpath("moretrees") then
	ts("moretrees:apple_tree_sapling", "moretrees:apple_tree_sapling")
	ts("moretrees:beech_sapling", "moretrees:beech_sapling")
	ts("moretrees:birch_sapling", "moretrees:birch_sapling")
	ts("moretrees:cedar_sapling", "moretrees:cedar_sapling")
	ts("moretrees:date_palm_sapling", "moretrees:date_palm_sapling")
	ts("moretrees:fir_sapling", "moretrees:fir_sapling")
	ts("moretrees:oak_sapling", "moretrees:oak_sapling")
	ts("moretrees:palm_sapling", "moretrees:palm_sapling")
	ts("moretrees:poplar_sapling", "moretrees:poplar_sapling")
	ts("moretrees:poplar_small_sapling", "moretrees:poplar_small_sapling")
	ts("moretrees:rubber_tree_sapling", "moretrees:rubber_tree_sapling")
	ts("moretrees:sequoia_sapling", "moretrees:sequoia_sapling")
	ts("moretrees:spruce_sapling", "moretrees:spruce_sapling")
	ts("moretrees:willow_sapling", "moretrees:willow_sapling")
end
