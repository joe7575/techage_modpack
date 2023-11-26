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

local function get_text(text, x_offs, y_offs)
	if text == "top_view" then
		return "label[" .. x_offs .. "," .. y_offs .. ";" .. S("Top view") .. "]"
	elseif text == "side_view" then
		return "label[" .. x_offs .. "," .. y_offs .. ";" .. S("Side view") .. "]"
	elseif text == "sectional_view" then
		return "label[" .. x_offs .. "," .. y_offs .. ";" .. S("Sectional view") .. "]"
	end
	return "label[" .. x_offs .. "," .. y_offs .. ";" .. minetest.formspec_escape(text) .. "]"
end

local function get_image(image, size, x_offs, y_offs)
	size = size or "2.2,2.2"
	return "image[" .. x_offs .. "," .. y_offs .. ";" .. size .. ";" .. image .. "]"
end

local function get_item(item, tooltip, x_offs, y_offs)
	local ndef = minetest.registered_nodes[tooltip]
	if ndef and ndef.description then
		tooltip = minetest.formspec_escape(ndef.description)
	else
		tooltip = minetest.formspec_escape(tooltip) or ""
	end
	tooltip = "tooltip[" .. x_offs .. "," .. y_offs .. ";1,1;" .. tooltip .. ";#0C3D32;#FFFFFF]"

	if string.find(item, ":") then
		return "item_image[" .. x_offs .. "," .. y_offs .. ";1,1;" .. item .. "]", tooltip
	else
		return "image[" .. x_offs .. "," .. y_offs .. ";1,1;" .. item .. "]", tooltip
	end
end

local function get_item_data(tbl, x_offs, y_offs)
	if type(tbl) == "table" then
		local ttype = tbl[1]
		if ttype == "item" then
			return get_item(tbl[2], tbl[3], x_offs, y_offs)
		elseif ttype == "img" then
			return get_image(tbl[2], tbl[3], x_offs, y_offs), ""
		elseif ttype == "text" then
			return get_text(tbl[2], x_offs, y_offs), ""
		else
			return "", ""
		end
	end
end

-- formspec images
local function plan(images)
	local tbl = {}
	if images == "none" then return "label[1,3;"..S("No plan available") .."]" end
	for y=1,#images do
		for x=1,#images[1] do
			local item = images[y][x] or false
			if item ~= false then
				local x_offs, y_offs = (x-1) * 0.9, (y-1) * 0.9 + 0.8
				local image, tooltip = get_item_data(item, x_offs, y_offs)
				tbl[#tbl+1] = image
				if tooltip then
					tbl[#tbl+1] = tooltip
				end
			end
		end
	end
	return table.concat(tbl)
end

local function formspec_help(meta, manual)
	local idx = meta:get_int("doclib_index")
	local box = "box[9.4,1.5;1.15,1.25;#BBBBBB]"
	local bttn, symbol

	if manual.content.aPlans[idx] ~= "" then
		bttn = "button[9.6,1;1,1;plan;" .. S("Plan") .. "]"
	elseif manual.content.aImages[idx] ~= "" then
		local name = manual.content.aImages[idx] or ""
		local item = manual.content.kvImages[name] or name
		if string.find(item, ":") then
			bttn = box .. "item_image[9.45,1.55;1.3,1.3;" .. item .. "]"
		else
			bttn = "image[9.4,1.5;1.4,1.4;" .. item .. "]"
		end
	else
		bttn = box
	end
	
	if string.find(manual.settings.symbol_item, ":") then
		symbol = "item_image[9.6,0;1,1;" .. manual.settings.symbol_item .. "]"
	else
		symbol = "image[9.6,0;1,1;" .. manual.settings.symbol_item .. "]"
	end
	
	return "size[11,10]" ..
		symbol ..
		"tablecolumns[tree,width=1;text,width=10,align=inline]" ..
		"tableoptions[opendepth=1]" ..
		"table[0.1,0;9,5;page;" .. table.concat(manual.content.aTitles, ",") .. ";" .. idx .. "]" ..
		bttn ..
		"box[0,5.75;10.775,4.45;#000000]" ..
		"style_type[textarea;textcolor=#FFFFFF]" ..
		"textarea[0.3,5.7;11,5.3;;;" .. (manual.content.aTexts[idx] or "") .. "]"
end

local function formspec_plan(meta, manual)
	local idx = meta:get_int("doclib_index")
	local name = manual.content.aPlans[idx] or "none"
	local tbl = manual.content.kvPlans[name] or {}
	local titel = string.sub(manual.content.aTitles[idx] or "", 3) or "unknown"

	return "size[11,10]" ..
		"label[0,0;"..titel..":]" ..
		"button[10,0;1,0.8;back;<<]" ..
		plan(tbl)
end

function doclib.formspec(pos, mod, language, fields)
	if doclib.manual and doclib.manual[mod] and doclib.manual[mod][language] then
		local manual = doclib.manual[mod][language]
		local meta = M(pos)

		if not fields then
			meta:set_int("doclib_index", 1)
			return formspec_help(meta, manual)
		elseif fields.plan then
			return formspec_plan(meta, manual)
		elseif fields.back then
			return formspec_help(meta, manual)
		elseif fields.page then
			local evt = minetest.explode_table_event(fields.page)
			if evt.type == "CHG" then
				local idx = tonumber(evt.row)
				meta:set_int("doclib_index", idx)
			end
		end
		return formspec_help(meta, manual)
	end
end
