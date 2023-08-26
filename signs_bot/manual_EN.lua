return {
  titles = {
    "1,Signs Bot",
    "2,Firt Steps",
    "2,Signs",
    "2,Sensors and Actuators",
    "2,Sensor Connection Tool",
    "2,Inventory",
    "2,Nodes / Blocks",
    "3,Signs Bot Box",
    "3,Bot Flap",
    "3,Signs Duplicator",
    "3,Bot Sensor",
    "3,Node Sensor",
    "3,Crop Sensor",
    "3,Signs Bot Chest",
    "3,Bot Timer",
    "3,Bot Control Unit",
    "3,Sensor Extender",
    "3,Signal AND",
    "3,Signal Delayer",
    "3,Sign 'farming'",
    "3,Sign 'pattern'",
    "3,Sign 'copy3x3x3'",
    "3,Sign 'flowers'",
    "3,Sign 'aspen'",
    "3,Sign 'command'",
    "3,Sign \"turn right\"",
    "3,Sign \"turn left\"",
    "3,Sign \"take item\"",
    "3,Sign \"add item\"",
    "3,Sign \"stop\"",
    "3,Sign \"add to cart\" (minecart)",
    "3,Sign \"take from cart\" (minecart)",
    "3,Sign 'take water' (xdecor)",
    "3,Sign 'cook soup' (xdecor)",
    "2,Bot Commands",
    "3,Techage specific commands",
    "3,Flow control commands",
    "3,Further jump commands",
    "3,Flow control Examples",
    "4,Example with a function at the beginning:",
    "4,Example with a function at the end:",
  },
  texts = {
    "A robot controlled by signs.\n"..
    "\n"..
    "On the web: https://github.com/joe7575/signs_bot/blob/master/manual_EN.md\n"..
    "\n"..
    "\n"..
    "\n",
    "After you have placed the Signs Bot Box\\, you can start the bot by means of the\n"..
    "'On' button in the box menu. If the bot returns to its box right away\\,\n"..
    "you will need to charge it with electrical energy (techage) first.\n"..
    "The bot then runs straight ahead until it reaches an obstacle\n"..
    "(a step with two or more blocks up or down or a sign.)\n"..
    "\n"..
    "The bot can only be controlled by signs that are placed in its path.\n"..
    "\n"..
    "If the bot first reaches a sign it will execute the commands on the sign.\n"..
    "If the first command on the sign is e.g. 'turn_around'\\, the bot turns and goes back.\n"..
    "In this case\\, the bot reaches his box again and turns off.\n"..
    "\n"..
    "If the bot first reaches an obstacle it will stop\\, or if available\\, execute\n"..
    "the next commands from the last sign.\n"..
    "\n"..
    "The Signs Bot Box has an inventory with 6 stacks for signs and 8 stacks for\n"..
    "other items (which are placed/mined by the bot). This inventory simulates the bot\n"..
    "internal inventory. That means you will only have access to the inventory\n"..
    "if the bot is turned off ('sitting' in his box).\n"..
    "\n"..
    "There are also the following blocks:\n"..
    "\n"..
    "  - Sensors: These can send a signal to an actuator if they are connected to the actuator.\n"..
    "  - Actuators: These perform an action when they receive a signal from a sensor.\n"..
    "\n"..
    "\n"..
    "\n",
    "You control the direction of the bot using the \"turn left\" and\n"..
    "\"turn right\" signs (signs with the arrow). The bot can run over steps\n"..
    "(one block up/down). But there are also commands to move the bot up and down.\n"..
    "\n"..
    "It is not necessary to mark a way back to the box. With the command 'turn_off'\n"..
    "the bot will turn off and be back in his box from every position. The same applies\n"..
    "if you turn off the bot by the box menu. If the bot reaches a sign from the wrong\n"..
    "direction (from back or sides) the sign will be ignored.\n"..
    "The bot will simply step over the sign.\n"..
    "\n"..
    "All predefined signs have a menu with a list of the bot commands. These signs\n"..
    "can't be changed\\, but you can craft and program your own signs. For this you\n"..
    "have to use the 'command' sign. This sign has an edit field for your commands\n"..
    "and a help page with all available commands. The help page has a copy button\n"..
    "to simplify the programming.\n"..
    "\n"..
    "Also for your own signs it is important to know: After the execution of the last\n"..
    "command of the sign\\, the bot falls back into its default behaviour and runs in\n"..
    "its taken direction.\n"..
    "\n"..
    "A standard job for the bot is to move items from one chest to another chest\n"..
    "(or node with a chest like inventory). This can be done by means of the two signs\n"..
    "'take item' and 'add item'. These signs have to be placed on top of chest nodes.\n"..
    "\n"..
    "\n"..
    "\n",
    "In addition to the signs the bot can be controlled by means of sensors. Sensors\n"..
    "like the Bot Sensor have two states: on and off. If the Bot Sensor detects a bot\n"..
    "it will switch to the state 'on' and sends a signal to a connected block\\,\n"..
    "called an actuator.\n"..
    "\n"..
    "Sensors are:\n"..
    "\n"..
    "  - Bot Sensor: Sends a signal when a robot passes by\n"..
    "  - Node Sensor: Sends a signal when it detects any (new) node\n"..
    "  - Crop Sensor: Sends a signal when\\, for example wheat is fully grown\n"..
    "  - Bot Chest: Sends a signal depending on the chest state (empty\\, full)\n"..
    "\n"..
    "Actuators are:\n"..
    "\n"..
    "  - Signs Bot Box: Can turn the bot off and on\n"..
    "  - Control Unit: Can be used to exchange the sign to lead the bot\n"..
    "\n"..
    "Sensors must be connected (paired) with actuators. This is what the\n"..
    "\"Sensor Connection Tool\" does.\n"..
    "\n"..
    "\n"..
    "\n",
    "To send a signal from a sensor to an actuator\\, the sensor has to be connected\n"..
    "(paired) with actuator. To connect sensor and actuator\\, the Sensor Connection Tool\n"..
    "has to be used. Simply click with the tool on both blocks and the sensor will be\n"..
    "connected with the actuator. A successful connection is indicated by a ping/pong noise.\n"..
    "\n"..
    "Before you connect sensor with actuator\\, take care that the actuator is in the\n"..
    "requested state. For example: If you want to start the Bot with a sensor\\, connect\n"..
    "the sensor with the Bot Box\\, when the Bot is in the state 'on'. Otherwise the sensor\n"..
    "signal will stop the Bot\\, instead of starting it.\n"..
    "\n"..
    "\n"..
    "\n",
    "The following applies to all commands that place items/items in the bot inventory\\, such as:\n"..
    "\n"..
    "  - 'take_item <num> <slot>'\n"..
    "  - 'pickup_items <slot>'\n"..
    "  - 'trash_sign <slot>'\n"..
    "  - 'harvest <slot>'\n"..
    "  - 'dig_front <slot> <lvl>'\n"..
    "\n"..
    "If no slot or slot 0 was specified with the command (case A)\\, all 8 slots of the bot\n"..
    "inventory are checked one after the other. If a slot was specified (case B)\\,\n"..
    "only this slot is checked. \n"..
    "In both cases the following applies: \n"..
    "\n"..
    "If the slot is preconfigured and matches the item\\, or if the slot is unconfigured\n"..
    "and empty\\, or only partially filled with the item type to be added\\, \n"..
    "then the item(s) will be added.\n"..
    "If not all items can be added\\, in case A the remaining slots are tried. \n"..
    "Anything that couldn't be added to your inventory will go back or be dropped.\n"..
    "\n"..
    "The following applies to all commands that are used to take items from the bot inventory\\, like:\n"..
    "\n"..
    "  - 'add_item <num> <slot>'\n"..
    "\n"..
    "It doesn't matter whether a slot is configured or not. The bot takes the first stack\n"..
    "that it can find from its own inventory and tries to use it. If a slot is specified\\,\n"..
    "it only takes this\\, if no slot has been specified\\, it checks all of them one after\n"..
    "the other\\, starting from slot 1 until it finds something. If the number found is\n"..
    "smaller than requested\\, he tries to take the rest out of any other slot.\n"..
    "\n"..
    "\n"..
    "\n",
    "",
    "The Box is the housing of the bot. Place the box and start the bot by means of the\n"..
    "'On' button. If the mod techage is installed\\, the bot needs electrical power.\n"..
    "The bot leaves the box on the right side. It will not start\\, if this position is blocked.\n"..
    "\n"..
    "To stop and remove the bot\\, press the 'Off' button.\n"..
    "The box inventory simulates the inventory of the bot.\n"..
    "You will not be able to access the inventory\\, if the bot is running.\n"..
    "The bot can carry up to 8 stacks and 6 signs with it.\n"..
    "\n"..
    "\n"..
    "\n",
    "The flap is a simple block used as door for the bot. Place the flap in any wall\\,\n"..
    "and the bot will automatically open and close the flap as it passes through it.\n"..
    "\n"..
    "\n"..
    "\n",
    "The Duplicator can be used to make copies of signs:\n"..
    "\n"..
    "  - Put one 'cmnd' sign to be used as template into the 'Template' inventory\n"..
    "  - Add one or several 'blank signs' to the 'Input' inventory.\n"..
    "  - Take the copies from the 'Output' inventory.\n"..
    "\n"..
    "Written books \\[default:book_written\\] can alternatively be used as template.\n"..
    "Already written signs can be used as input\\, too.\n"..
    "\n"..
    "\n"..
    "\n",
    "The Bot Sensor detects any bot and sends a signal\\, if a bot is nearby.\n"..
    "The sensor range is one node/meter.\" The sensor direction does not care.\n"..
    "\n"..
    "\n"..
    "\n",
    "The node sensor sends cyclical signals when it detects that nodes have appeared\n"..
    "or disappeared\\, but has to be configured accordingly. Valid nodes are all kind\n"..
    "of blocks and plants. The sensor range is 3 nodes/meters in one direction.\n"..
    "The sensor has an active side (red) that must point to the observed area.\n"..
    "\n"..
    "\n"..
    "\n",
    "The Crop Sensor sends cyclical signals when\\, for example\\, wheat is fully grown.\n"..
    "The sensor range is one node/meter. The sensor has an active side (red) that\n"..
    "must point to the crop/field.\n"..
    "\n"..
    "\n"..
    "\n",
    "The Signs Bot Chest is a special chest with sensor function. It sends a signal\n"..
    "depending on the chest state. Possible states are 'empty'\\, 'not empty'\\, 'almost full'\n"..
    "\n"..
    "A typical use case is to turn off the bot\\, when the chest is almost full or empty.\n"..
    "\n"..
    "\n"..
    "\n",
    "This is a special kind of sensor. Can be programmed with a time in seconds\\,\n"..
    "e.g. to start the bot cyclically.\n"..
    "\n"..
    "\n"..
    "\n",
    "The Bot Control Unit is used to lead the bot by means of signs. The unit can be\n"..
    "loaded with up to 4 different signs and can be programmed by means of sensors.\n"..
    "\n"..
    "To load the unit\\, place a sign on the red side of the unit and click on the unit.\n"..
    "The sign disappears / is moved to the inventory of the unit.\n"..
    "This can be repeated 3 times.\n"..
    "\n"..
    "Use the connection tool to connect up to 4 sensors with the Bot Control Unit.\n"..
    "\n"..
    "\n"..
    "\n",
    "With the Sensor Extender\\, sensor signals can be sent to more than one actuator.\n"..
    "Place one or more extender nearby the sensor and connect each extender with one\n"..
    "further actuator by means of the Connection Tool.\n"..
    "\n"..
    "\n"..
    "\n",
    "Signal is sent\\, if all input signals are received.\n"..
    "\n"..
    "\n"..
    "\n",
    "Signals are forwarded delayed. Subsequent signals are queued. \n"..
    "The delay time can be configured.\n"..
    "\n"..
    "\n"..
    "\n",
    "Used to harvest and seed a 3x3 field. Place the sign in front of the field.\n"..
    "The seed used must be in the first slot of the bot inventory.\n"..
    "When the bot is done\\, the bot will turn and walk back.\n"..
    "\n"..
    "\n"..
    "\n",
    "Used to make a copy of a 3x3x3 cube. Place the sign in front of the pattern\n"..
    "to be copied. Use the copy sign to make the copy of this pattern on a different\n"..
    "location. The bot must first reach the pattern sign\\, then the copy sign.\n"..
    "\n"..
    "Used to make a copy of a 3x3x3 cube. Place the shield in front of the blocks\n"..
    "to be copied. Use the copy sign to make the copy of these blocks in another\n"..
    "location. The bot must first process the \"pattern\" sign\\, only then can the bot\n"..
    "be directed to the copy sign.\n"..
    "\n"..
    "\n"..
    "\n",
    "Used to make a copy of a 3x3x3 cube. Place the sign in front of where you want\n"..
    "the copy to be made. See also sign \"pattern\".\n"..
    "\n"..
    "\n"..
    "\n",
    "Used to cut flowers on a 3x3 field. Place the sign in front of the field.\n"..
    "When finished\\, the bot turns.\n"..
    "\n"..
    "\n"..
    "\n",
    "Used to harvest an aspen or pine tree trunk\n"..
    "\n"..
    "  - Place the sign in front of the tree.\n"..
    "  - Place a chest to the right of the sign.\n"..
    "  - Put a dirt stack (10 items min.) into the chest.\n"..
    "  - Preconfigure slot 1 of the bot inventory with dirt\n"..
    "  - Preconfigure slot 2 of the bot inventory with saplings\n"..
    "\n"..
    "\n"..
    "\n",
    "The 'command' sign can be programmed by the player. Place the sign in front\n"..
    "of you and use the node menu to program your sequence of bot commands.\n"..
    "The menu has an edit field for your commands and a help page with all\n"..
    "available commands. The help page has a copy button to simplify the programming.\n"..
    "\n"..
    "\n"..
    "\n",
    "The Bot turns right when it detects this sign in front of it.\n"..
    "\n"..
    "\n"..
    "\n",
    "The Bot turns left when it detects this sign in front of it.\n"..
    "\n"..
    "\n"..
    "\n",
    "The Bot takes items out of a chest in front of it and then turns around.\n"..
    "This sign has to be placed on top of the chest.\n"..
    "\n"..
    "\n"..
    "\n",
    "The Bot puts items into a chest in front of it and then turns around.\n"..
    "This sign has to be placed on top of the chest.\n"..
    "\n"..
    "\n"..
    "\n",
    "The Bot will stop in front of this sign until the sign is removed or\n"..
    "the bot is turned off.\n"..
    "\n"..
    "\n"..
    "\n",
    "The Bot puts items into a minecart in front of it\\, pushes the cart and then turns\n"..
    "around. This sign has to be placed on top of the rail at the cart end position.\n"..
    "\n"..
    "\n"..
    "\n",
    "The Bot takes items out of a minecart in front of it\\, pushes the cart and then\n"..
    "turns around. This sign has to be placed on top of the rail at the cart end position.\n"..
    "\n"..
    "\n"..
    "\n",
    "Used to take water into bucket. Place the sign on a shore\\, in front of the still water pool. \n"..
    "\n"..
    "Items in slots:\n"..
    "\n"..
    "  1 - empty bucket\n"..
    "\n"..
    "The result is one bucket with water in selected inventory slot. When finished\\,\n"..
    "the bot turns around.\n"..
    "\n"..
    "\n"..
    "\n",
    "Used to cook a vegetable soup in cauldron. Cauldon should be empty and located\n"..
    "above flammable material. Place the sign in front of the cauldron with one field\n"..
    "space\\, to prevent wooden sign from catching fire.\n"..
    "\n"..
    "Items in slots:\n"..
    "\n"..
    "  1 - water bucket\"\n"..
    "  2 - vegetable #1 (i.e. tomato)\n"..
    "  3 - vegetable #2 (i.e. carrot)\n"..
    "  4 - empty bowl (from farming or xdecor mods)\n"..
    "\n"..
    "  The result is one bowl with vegetable soup in selected inventory slot.\n"..
    "When finished\\, the bot turns around.\n"..
    "\n"..
    "\n"..
    "\n",
    "The commands are also all described as help in the \"Sign command\" node.\n"..
    "All blocks or signs that are set are taken from the bot inventory.\n"..
    "Any blocks or signs removed will be added back to the Bot Inventory.\n"..
    "'<slot>' is always the bot internal inventory stack (1..8).\n"..
    "\n"..
    "    move <steps>              - go one or more steps forward\n"..
    "    cond_move                 - go to the nearest obstacle or sign\n"..
    "    turn_left                 - turn left\n"..
    "    turn_right                - turn right\n"..
    "    turn_around               - turn around\n"..
    "    backward                  - take a step back\n"..
    "    turn_off                  - turn off the robot / back to the box\n"..
    "    pause <sec>               - wait one or more seconds\n"..
    "    move_up                   - move up (maximum 2 times)\n"..
    "    move_down                 - move down\n"..
    "    fall_down                 - fall into a hole/chasm (up to 10 blocks)\n"..
    "    take_item <num> <slot>    - take one or more items from a box\n"..
    "    add_item <num> <slot>     - put one or more items in a box\n"..
    "    add_fuel <num> <slot>     - put fuel in a furnace\n"..
    "    place_front <slot> <lvl>  - place the block in front of the bot\n"..
    "    place_left <slot> <lvl>   - place the block to the left of the bot\n"..
    "    place_right <slot> <lvl>  - place the block to the right of the bot\n"..
    "    place_below <slot>        - lift the robot and put the block under the robot\n"..
    "    place_above <slot>        - set block above the robot\n"..
    "    dig_front <slot> <lvl>    - remove block in front of the robot\n"..
    "    dig_left <slot> <lvl>     - remove block on the left\n"..
    "    dig_right <slot> <lvl>    - remove block on the right\n"..
    "    dig_below <slot>          - remove block under the robot\n"..
    "    dig_above <slot>          - remove block above the robot\n"..
    "    rotate_item <lvl> <steps> - rotate a block in front of the robot\n"..
    "    set_param2 <lvl> <param2> - set param2 of the block in front of the robot\n"..
    "    place_sign <slot>         - set sign\n"..
    "    place_sign_behind <slot>  - put a sign behind the bot\n"..
    "    dig_sign <slot>           - remove the sign\n"..
    "    trash_sign <slot>         - Remove the sign\\, clear data and add to the item Inventory\n"..
    "    stop                      - Bot stops until the shield is removed\n"..
    "    pickup_items <slot>       - pickup items (in a 3x3 field)\n"..
    "    drop_items <num> <slot>   - drop items\n"..
    "    harvest                   - harvest a 3x3 field (farming)\n"..
    "    cutting                   - cut flowers in a 3x3 field\n"..
    "    sow_seed <slot>           - see/plant a 3x3 field\n"..
    "    plant_sapling <slot>      - plant a sapling in front of the robot\n"..
    "    pattern                   - save the block properties behind the sign (3x3x3 cube) as a template\n"..
    "    copy <size>               - make a 3x3x3 copy of the stored template\n"..
    "    punch_cart                - bump a mine cart\n"..
    "    add_compost <slot>        - Put 2 leaves into the compost barrel\n"..
    "    take_compost <slot>       - Take a compost item from the barrel\n"..
    "    print <text>              - Output chat message for debug purposes\n"..
    "    take_water <slot>         - Take water with empty bucket\n"..
    "    fill_cauldron <slot>      - Fill the xdecor cauldron for a soup\n"..
    "    take_soup <slot>          - Take boiling soup into empty bowl from cauldron\n"..
    "    flame_on                  - Make fire\n"..
    "    flame_off                 - Put out the fire\n"..
    "\n"..
    "\n"..
    "\n",
    "    ignite                            - Ignite the techage charcoal lighter\n"..
    "    low_batt <percent>                - Turn the bot off if the battery power is below the \n"..
    "                                        given value in percent (1..99)\n"..
    "    jump_low_batt <percent> <label>   - Jump to <label> if the battery power is below the \n"..
    "                                        given value in percent (1..99)\n"..
    "                                        (see \"Flow control commands\")\n"..
    "    send_cmnd <receiver> <command>    - Send a techage command to a given node. \n"..
    "                                        Receiver is addressed by the techage node number. \n"..
    "                                        For commands with two or more words\\, \n"..
    "                                        use the '*' character instead of spaces\\, e.g.: \n"..
    "                                        send_cmnd 3465 pull*default:dirt*2\n"..
    "\n"..
    "\n"..
    "\n",
    "    -- jump command\\, <label> is a word from the characters a-z or A-Z\n"..
    "    jump <label>\n"..
    "    \n"..
    "    -- jump label / start of a function\n"..
    "    <label>:\n"..
    "    \n"..
    "    -- return from a function\n"..
    "    return\n"..
    "    \n"..
    "    -- start of a loop block\\, <num> is a number 1..999\n"..
    "    repeat <num>\n"..
    "    \n"..
    "    -- end of a loop block\n"..
    "    end\n"..
    "    \n"..
    "    -- call of a function (with return via the command 'return')\n"..
    "    call <label>\n"..
    "\n"..
    "\n"..
    "\n",
    "    -- Check if there are <num> items in the chest like node.\n"..
    "    -- If not\\, jump to <label>.\n"..
    "    -- <slot> is the bot inventory slot (1..8) to\n"..
    "    -- specify the item\\, or 0 for any item.\n"..
    "    jump_check_item <num> <slot> <label>\n"..
    "    \n"..
    "    -- See \"Techage specific commands\"\n"..
    "    jump_low_batt <percent> <label>\n"..
    "\n"..
    "\n"..
    "\n",
    "",
    "    -- jump to the label 'main'\n"..
    "    jump main\n"..
    "    \n"..
    "    -- starting point of the function with the name 'foo'\n"..
    "    foo:\n"..
    "      cmnd ...\n"..
    "      cmnd ...\n"..
    "    -- end of 'foo'. Jump back\n"..
    "    return\n"..
    "    \n"..
    "    -- main program\n"..
    "    main:\n"..
    "      cmnd ...\n"..
    "      -- repeat all commands up to 'end' 10 times\n"..
    "      repeat 10\n"..
    "        cmnd ...\n"..
    "        -- call the subfunction 'foo'\n"..
    "        call foo\n"..
    "        cmnd ...\n"..
    "      -- end of the 'repeat' loop\n"..
    "      end\n"..
    "    -- end of the program\n"..
    "    exit\n"..
    "\n",
    "    cmnd ...\n"..
    "    -- repeat all commands up to 'end' 10 times\n"..
    "    repeat 10\n"..
    "      cmnd ...\n"..
    "      -- call the subfunction 'foo'\n"..
    "      call foo\n"..
    "      cmnd ...\n"..
    "    -- end of the 'repeat' loop\n"..
    "    end\n"..
    "    -- end of the program\n"..
    "    exit\n"..
    "    \n"..
    "    -- starting point of the function with the name 'foo'\n"..
    "    foo:\n"..
    "      cmnd ...\n"..
    "      cmnd ...\n"..
    "    -- end of 'foo'. Jump back\n"..
    "    return\n"..
    "\n",
  },
  images = {
    "signs_bot_bot_inv.png",
    "signs_bot_bot_inv.png",
    "signs_bot_sign_left.png",
    "signs_bot_sensor_crop_inv.png",
    "signs_bot_tool.png",
    "signs_bot:box",
    "",
    "signs_bot:box",
    "signs_bot:bot_flap",
    "signs_bot:duplicator",
    "signs_bot:bot_sensor",
    "signs_bot:node_sensor",
    "signs_bot:crop_sensor",
    "signs_bot:chest",
    "signs_bot:timer",
    "signs_bot:changer1",
    "signs_bot:sensor_extender",
    "signs_bot:and1",
    "signs_bot:delayer",
    "signs_bot:farming",
    "signs_bot:pattern",
    "signs_bot:copy3x3x3",
    "signs_bot:flowers",
    "signs_bot:aspen",
    "signs_bot:sign_cmnd",
    "signs_bot:sign_right",
    "signs_bot:sign_left",
    "signs_bot:sign_take",
    "signs_bot:sign_add",
    "signs_bot:sign_stop",
    "signs_bot:sign_add_cart",
    "signs_bot:sign_take_cart",
    "signs_bot:water",
    "signs_bot:soup",
    "signs_bot_bot_inv.png",
    "signs_bot_bot_inv.png",
    "signs_bot_bot_inv.png",
    "signs_bot_bot_inv.png",
    "",
    "",
    "",
  },
  plans = {
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
  }
}