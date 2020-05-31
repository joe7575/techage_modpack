signs_bot.doc = {}

if not minetest.get_modpath("doc") then
	return
end

-- Load support for intllib.
local MP = minetest.get_modpath("signs_bot")
local I,_ = dofile(MP.."/intllib.lua")

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

local start_doc = table.concat({
	I("After you have placed the Signs Bot Box, you can start the bot by means of the 'On' button in the box menu."),
	I("The bot then runs straight up until it reaches an obstacle (a step with two or more blocks up or down or a sign.)"),
	I("If the bot first reaches a sign it will execute the commands on the sign."),
	I("If the command(s) on the sign is e.g. 'turn_around', the bot turns and goes back."),
	I("In this case, the bot reaches his box again and turns off."),
	"",
	I("The Signs Bot Box has an inventory with 6 stacks for signs and 8 stacks for other items (to be placed/dug by the bot)."),
	I("This inventory simulates the bot internal inventory."),
	I("That means you will only have access to the inventory if the bot is turned off ('sitting' in his box)."),
}, "\n")

local control_doc = table.concat({
	I("You simply control the direction of the bot by means of the 'turn left' and 'turn right' signs (signs with the arrow)."),
	I("The bot can run over steps (one block up/down). But there are also commands to move the bot up and down."),
	"",
	I("It is not necessary to mark a way back to the box."),
	I("With the command 'turn_off' the bot will turn off and be back in his box from every position."),
	I("The same applies if you turn off the bot by the box menu."),
	I("If the bot reaches a sign from the wrong direction (from back or sides) the sign will be ignored."),
	I("The bot will walk over."),
	"",
	I("All predefined signs have a menu with a list of the bot commands."),
	I("These signs can't be changed, but you can craft and program your own signs."),
	I("For this you have to use the 'command' sign."),
	I("This sign has an edit field for your commands and a help page with all available commands."),
	I("The help page has a copy button to simplify the programming."),
	"",
	I("Also for your own signs it is important to know:"),
	I("After the execution of the last command of the sign, the bot falls back into its default behaviour and runs in its taken direction."),
	"",
	I("A standard job for the bot is to move items from one chest to another"),
	I("(chest or node with a chest like inventory)."),
	I("This can be done by means of the two signs 'take item' and 'add item'."),
	I("These signs have to be placed on top of chest nodes."),
}, "\n")

local sensor_doc = table.concat({
	I("In addition to the signs the bot can be controlled by means of sensors."),
	I("Sensors like the Bot Sensor have two states: on and off."),
	I("If the Bot Sensor detects a bot it will switch to the state 'on' and"),
	I("sends a signal to a connected block, called an actuator."),
	"",
	I("Sensors are:"),
	I("- Bot Sensor: Sends a signal when the robot passes by"),
	I("- Node Sensor: Sends a signal when it detects any node"),
	I("- Crop Sensor: Sends a signal when, for example wheat is fully grown"),
	I("- Bot Chest: Sends a signal depending on the chest state (empty, full)"),
	"",
	I("Actuators are:"),
	I("- Signs Bot Box: Can turn the bot off and on"),
	I("- Control Unit: Can be used to exchange the sign to lead the bot"),
	"",
	I("Additional sensors and actuator can be added by other mods."),
}, "\n")


local tool_doc = table.concat({
	I("To send a signal from a sensor to an actuator, the sensor has to be connected (paired) with actuator."),
	I("To connect sensor and actuator, the Sensor Connection Tool has to be used."),
	I("Simply click with the tool on both blocks and the sensor will be connected with the actuator."),
	I("A successful connection is indicated by a ping/pong noise."),
	"",
	I("Before you connect sensor with actuator, take care that the actuator is in the requested state."),
	I("For example: If you want to start the Bot with a sensor, connect the sensor with the Bot Box,"),
	I("when the Bot is in the state 'on'. Otherwise the sensor signal will stop the Bot,"),
	I("instead of starting it."),
}, "\n")


local inventory_doc = table.concat({
	I("The following applies to all commands that are used to place items in the bot inventory, like:"),
	"",
	I("- take_item <num> <slot>"),
	I("- pickup_items <slot>"),
	I("- trash_sign <slot>"),
	I("- harvest <slot>"),
	I("- dig_front <slot> <lvl>"),
	I("- dig_left <slot> <lvl>"),
	I("- dig_right <slot> <lvl>"),
	I("- dig_below <slot> <lvl>"),
	I("- dig_above <slot> <lvl>"),
	"",
	I("If no slot or slot 0 was specified with the command (case A), all 8 slots of the bot inventory "),
	I("are checked one after the other. If a slot was specified (case B), only this slot is checked."),
	I("In both cases the following applies: If the slot is preconfigured and fits the item, "),
	I("or if the slot is not configured and empty, or is only partially filled with the item type "),
	I("(which should be added), then the items are added."),
	I("If not all items can be added, the remaining slots will be tried out in case A."),
	I("Anything that could not be added to your own inventory goes back."),
	"",
	I("The following applies to all commands that are used to take items from the bot inventory, like:"),
	"",
	I("- add_item <num> <slot>"),
	"",
	I("It doesn't matter whether a slot is configured or not. The bot takes the first stack that "),
	I("it can find from its own inventory and tries to use it."),
	I("If a slot is specified, it only takes this, if no slot has been specified, it checks all of "),
	I("them one after the other, starting from slot 1 until it finds something."),
	I("If the number found is smaller than requested, he tries to take the rest out of any slot."),
}, "\n")


doc.add_category("signs_bot",
{
	name = I("Signs Bot"),
	description = I("A robot controlled by signs, used for automated work"),
	sorting = "custom",
	sorting_data = {"start", "control", "sensor_doc", "tool", 
		"box", "bot_flap", "duplicator",
		"bot_sensor", "cart_sensor", "node_sensor", "crop_sensor", "chest", "timer",
		"changer", "sensor_extender",
		"farming", "pattern", "copy3x3x3",
		"sign_cmnd", "sign_right", "sign_left", "sign_take", "sign_add", "sign_stop", "sign_blank"},
	build_formspec = formspec,
})

doc.add_entry("signs_bot", "start", {
	name = I("Start the Bot"),
	data = {text = start_doc, image = "signs_bot_doc_image.png"},
})

doc.add_entry("signs_bot", "control", {
	name = I("Control the Bot"),
	data = {text = control_doc, image = "signs_bot_doc_image.png"},
})

doc.add_entry("signs_bot", "sensor_doc", {
	name = I("Sensors and Actuators"),
	data = {text = sensor_doc, image = "signs_bot_doc_image.png"},
})

doc.add_entry("signs_bot", "tool", {
	name = I("Connecting sensors and actuator"),
	data = {text = tool_doc, image = "signs_bot_doc_image.png"},
})

doc.add_entry("signs_bot", "tool", {
	name = I("Bot inventory behavior"),
	data = {text = inventory_doc, image = "signs_bot_doc_image.png"},
})
