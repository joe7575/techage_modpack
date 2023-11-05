--[[

	Minecart
	========

	Copyright (C) 2019-2023 Joachim Stolberg

	MIT
	See license.txt for more information

	InGame Documentation for techage or doclib

]]--

local MP = minetest.get_modpath("minecart")

if not minetest.global_exists("techage") and
       minetest.global_exists("doclib") then

	minetest.register_node("minecart:manual", {
		description = "Minecart Manual (EN)",
		inventory_image = "minecart_book_inv.png",
		tiles = {
			-- up, down, right, left, back, front
			"minecart_book.png",
			"minecart_book.png",
			"minecart_book.png^[transformR270",
			"minecart_book.png^[transformR90",
			"minecart_book.png^[transformR180",
			"minecart_book.png"
			},
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{ -8/32, -16/32, -12/32, 8/32, -12/32, 12/32},
			},
		},

		after_place_node = function(pos, placer, itemstack)
			minetest.get_meta(pos):set_string("infotext", "Minecart Manual (EN)")
			minetest.get_meta(pos):set_string("formspec", doclib.formspec(pos, "minecart", "EN"))
		end,

		on_receive_fields = function(pos, formname, fields, player)
			local player_name = player:get_player_name()
			if minetest.is_protected(pos, player_name) then
				return
			end
			minetest.get_meta(pos):set_string("formspec", doclib.formspec(pos, "minecart", "EN", fields))
		end,

		paramtype = "light",
		sunlight_propagates = true,
		paramtype2 = "facedir",
		use_texture_alpha = "clip",
		is_ground_content = false,
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	})

	minetest.register_node("minecart:handbuch", {
		description = "Minecart Handbuch (DE)",
		inventory_image = "minecart_book_inv.png",
		tiles = {
			-- up, down, right, left, back, front
			"minecart_book.png",
			"minecart_book.png",
			"minecart_book.png^[transformR270",
			"minecart_book.png^[transformR90",
			"minecart_book.png^[transformR180",
			"minecart_book.png"
			},
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{ -8/32, -16/32, -12/32, 8/32, -12/32, 12/32},
			},
		},

		after_place_node = function(pos, placer, itemstack)
			minetest.get_meta(pos):set_string("infotext", "Minecart Handbuch (DE)")
			minetest.get_meta(pos):set_string("formspec", doclib.formspec(pos, "minecart", "DE"))
		end,

		on_receive_fields = function(pos, formname, fields, player)
			local player_name = player:get_player_name()
			if minetest.is_protected(pos, player_name) then
				return
			end
			minetest.get_meta(pos):set_string("formspec", doclib.formspec(pos, "minecart", "DE", fields))
		end,

		paramtype = "light",
		sunlight_propagates = true,
		paramtype2 = "facedir",
		use_texture_alpha = "clip",
		is_ground_content = false,
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	})

	minetest.register_craft({
		output = "minecart:manual",
		recipe = {
			{"dye:red", "default:paper", "default:paper"},
			{"dye:black", "default:paper", "default:paper"},
			{"dye:red", "default:paper", "default:paper"},
		},
	})

	minetest.register_craft({
		type = "shapeless",
		output = "minecart:handbuch",
		recipe = {"minecart:manual"},
	})

	minetest.register_craft({
		type = "shapeless",
		output = "minecart:manual",
		recipe = {"minecart:handbuch"},
	})
end

minetest.register_on_mods_loaded(function()
	if minetest.global_exists("techage") then

		-- Use the Techage Construction Board
		local content = dofile(MP.."/manual_EN.lua")
		doclib.add_to_manual("techage", "EN", content)
		local content = dofile(MP.."/manual_DE.lua")
		doclib.add_to_manual("techage", "DE", content)

	elseif minetest.global_exists("doclib") then

		-- Create own manual book
		local settings = {
			symbol_item = "minecart_manual_image.png",
		}

		doclib.create_manual("minecart", "EN", settings)
		local content = dofile(MP.."/manual_EN.lua")
		doclib.add_to_manual("minecart", "EN", content)

		doclib.create_manual("minecart", "DE", settings)
		local content = dofile(MP.."/manual_DE.lua")
		doclib.add_to_manual("minecart", "DE", content)

	end
end)