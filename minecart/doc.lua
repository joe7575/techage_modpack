--[[

	Minecart
	========

	Copyright (C) 2019-2020 Joachim Stolberg

	MIT
	See license.txt for more information
	
]]--


minecart.doc = {}

if not minetest.get_modpath("doc") then
	return
end

local S = minecart.S

local summary_doc = table.concat({
	S("Summary"),
	"------------",
	"",
	S("1. Place your rails and build a route with two endpoints. Junctions are allowed as long as each route has its own start and endpoint."),
	S("2. Place a Railway Buffer at both endpoints (buffers are always needed, they store the route and timing information)."),
	S("3. Give both Railway Buffers unique station names, like Oxford and Cambridge."),
	S("4. Place a Minecart at a buffer and give it a cart number (1..999)"),
	S("5. Drive from buffer to buffer in both directions using the Minecart(!) to record the routes (use 'right-left' keys to control the Minecart)."),
	S("6. Punch the buffers to check the connection data (e.g. 'Oxford: connected to Cambridge')."),
	S("7. Optional: Configure the Minecart stop time in one or both buffers. The Minecart will then start automatically after the configured time."),
	S("8. Optional: Protect your rail network with the Protection Landmarks (one Landmark at least every 16 nodes/meters)."),
	S("9. Place a Minecart in front of the buffer and check whether it starts after the configured time."),
	S("10. Check the cart state via the chat command: /mycart <num>\n   '<num>' is the cart number"),
	S("11. Drop items into the Minecart and punch the cart to start it, or 'sneak+click' the Minecart to get the items back."),
	S("12. Dig the empty cart with a second 'sneak+click' (as usual)."),
}, "\n")

local cart_doc = S("Primary used to transport items. You can drop items into the Minecart and punch the cart to get started. Sneak+click the cart to get the items back")

local buffer_doc = S("Used as buffer on both rail ends. Needed to be able to record the cart routes")

local landmark_doc = S("Protect your rails with the Landmarks (one Landmark at least every 16 blocks near the rail)")

local hopper_doc = S("Used to load/unload Minecart. The Hopper can push/pull items to/from chests and drop/pickup items to/from Minecarts. To unload a Minecart place the hopper below the rail. To load the Minecart, place the hopper right next to the Minecart.")


local function formspec(data)
	if data.image then
		local image = "image["..(doc.FORMSPEC.ENTRY_WIDTH - 3)..",0;3,2;"..data.image.."]"
		local formstring = doc.widgets.text(data.text, doc.FORMSPEC.ENTRY_START_X, doc.FORMSPEC.ENTRY_START_Y+1.6, doc.FORMSPEC.ENTRY_WIDTH, doc.FORMSPEC.ENTRY_HEIGHT - 1.6)
		return image..formstring
	elseif data.item then
		local box = "box["..(doc.FORMSPEC.ENTRY_WIDTH - 1.6)..",0;1,1.1;#BBBBBB]"
		local image = "item_image["..(doc.FORMSPEC.ENTRY_WIDTH - 1.5)..",0.1;1,1;"..data.item.."]"
		local formstring = doc.widgets.text(data.text, doc.FORMSPEC.ENTRY_START_X, doc.FORMSPEC.ENTRY_START_Y+0.8, doc.FORMSPEC.ENTRY_WIDTH, doc.FORMSPEC.ENTRY_HEIGHT - 0.8)
		return box..image..formstring
	else
		return doc.entry_builders.text(data.text)
	end
end

doc.add_category("minecart",
{
	name = S("Minecart"),
	description = S("Minecart, the lean railway transportation automation system"),
	sorting = "custom",
	sorting_data = {"summary", "cart"},
	build_formspec = formspec,
})

doc.add_entry("minecart", "summary", {
	name = S("Summary"),
	data = {text=summary_doc, image="minecart_doc_image.png"},
})

doc.add_entry("minecart", "cart", {
	name = S("Minecart Cart"),
	data = {text=cart_doc, item="minecart:cart"},
})

doc.add_entry("minecart", "buffer", {
	name = S("Minecart Railway Buffer"),
	data = {text=buffer_doc, item="minecart:buffer"},
})

doc.add_entry("minecart", "landmark", {
	name = S("Minecart Landmark"),
	data = {text = landmark_doc, item="minecart:landmark"},
})

if minecart.hopper_enabled then
	doc.add_entry("minecart", "hopper", {
		name = S("Minecart Hopper"),
		data = {text=hopper_doc, item="minecart:hopper"},
	})
end
