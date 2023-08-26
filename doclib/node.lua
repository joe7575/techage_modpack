--[[

	DocLib
	======

	Copyright (C) 2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	A library to generate ingame manuals based on markdown files.

]]--

-- for lazy programmers
local S = doclib.S
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local M = minetest.get_meta
local MP = minetest.get_modpath("doclib")

local settings = {
	symbol_item = "doclib_book_inv.png", -- can be a PGN file or a item, like: "mod:name"
}

doclib.create_manual("doclib", "EN", settings)
local content = dofile(MP.."/manual_EN.lua") 
doclib.add_to_manual("doclib", "EN", content)

minetest.register_node("doclib:manual", {
	description = "DocLib Manual (EN)",
	inventory_image = "doclib_book_inv.png",
	tiles = {
		-- up, down, right, left, back, front
		"doclib_book.png",
		"doclib_book.png",
		"doclib_book.png^[transformR270",
		"doclib_book.png^[transformR90",
		"doclib_book.png^[transformR180",
		"doclib_book.png"
		},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/32, -16/32, -12/32, 8/32, -12/32, 12/32},
		},
	},

	after_place_node = function(pos, placer, itemstack)
		M(pos):set_string("infotext", "DocLib Manual (EN)")
		M(pos):set_string("formspec", doclib.formspec(pos, "doclib", "EN"))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		local player_name = player:get_player_name()
		if minetest.is_protected(pos, player_name) then
			return
		end
		M(pos):set_string("formspec", doclib.formspec(pos, "doclib", "EN", fields))
	end,

	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	use_texture_alpha = "clip",
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
})
 

--
-- Demo plan 1
--
local ITEM1 = {"item", "doclib_demo_img1.png"}
local ITEM2 = {"item", "doclib_demo_img2.png", "Tooltip 1"}
local ITEM3 = {"item", "doclib_demo_img3.png", "Tooltip 2"}
local ITEM4 = {"item", "doclib_demo_img4.png", "Tooltip 3"}
local ITEM5 = {"item", "doclib_book_inv.png",  "doclib:manual"}
local ITEM6 = {"item", "doclib:manual",  "doclib:manual"}
local IMG_1 = {"img", "doclib_book_inv.png", "2,2"}
local TEXT1 = {"text", "Top view"}
local TEXT2 = {"text", "Pointless Demo"}
local TEXT3 = {"text", "End"}

-- The maximum plan size is 12 fields wide and 10 fields high
local plan1 = {
	{TEXT2, false, false, false, false, false, false, false, false, false, false, ITEM4},
	{false, false, false, TEXT1, false, false, false, false, IMG_1, false, false, false},
	{false, false, false, false, false, false, false, false, false, false, false, false},
	{false, false, false, false, ITEM1, false, false, false, false, false, false, false},
	{false, false, false, ITEM4, ITEM5, ITEM2, false, false, false, false, false, false},
	{false, false, false, false, ITEM3, false, false, false, false, false, false, false},
	{false, false, false, false, ITEM6, false, false, false, false, false, false, false},
	{false, false, false, false, false, false, false, false, false, false, false, false},
	{false, false, false, false, false, false, false, false, false, false, false, false},
	{TEXT3, false, false, false, false, false, false, false, false, false, false, ITEM4},
}

doclib.add_manual_plan("doclib", "EN", "demo1", plan1)
