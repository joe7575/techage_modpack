# Signs Bot

A robot controlled by signs.

On the web: https://github.com/joe7575/signs_bot/blob/master/manual_EN.md

[signs_bot_bot_inv.png|image]

## Firt Steps

After you have placed the Signs Bot Box, you can start the bot by means of the
'On' button in the box menu. If the bot returns to its box right away,
you will need to charge it with electrical energy (techage) first.
The bot then runs straight ahead until it reaches an obstacle
(a step with two or more blocks up or down or a sign.)

The bot can only be controlled by signs that are placed in its path.

If the bot first reaches a sign it will execute the commands on the sign.
If the first command on the sign is e.g. 'turn_around', the bot turns and goes back.
In this case, the bot reaches his box again and turns off.

If the bot first reaches an obstacle it will stop, or if available, execute
the next commands from the last sign.

The Signs Bot Box has an inventory with 6 stacks for signs and 8 stacks for
other items (which are placed/mined by the bot). This inventory simulates the bot
internal inventory. That means you will only have access to the inventory
if the bot is turned off ('sitting' in his box).

There are also the following blocks:
- Sensors: These can send a signal to an actuator if they are connected to the actuator.
- Actuators: These perform an action when they receive a signal from a sensor.

[signs_bot_bot_inv.png|image]

## Signs

You control the direction of the bot using the "turn left" and
"turn right" signs (signs with the arrow). The bot can run over steps
(one block up/down). But there are also commands to move the bot up and down.

It is not necessary to mark a way back to the box. With the command 'turn_off'
the bot will turn off and be back in his box from every position. The same applies
if you turn off the bot by the box menu. If the bot reaches a sign from the wrong
direction (from back or sides) the sign will be ignored.
The bot will simply step over the sign.

All predefined signs have a menu with a list of the bot commands. These signs
can't be changed, but you can craft and program your own signs. For this you
have to use the 'command' sign. This sign has an edit field for your commands
and a help page with all available commands. The help page has a copy button
to simplify the programming.

Also for your own signs it is important to know: After the execution of the last
command of the sign, the bot falls back into its default behaviour and runs in
its taken direction.

A standard job for the bot is to move items from one chest to another chest
(or node with a chest like inventory). This can be done by means of the two signs
'take item' and 'add item'. These signs have to be placed on top of chest nodes.

[signs_bot_sign_left.png|image]

## Sensors and Actuators

In addition to the signs the bot can be controlled by means of sensors. Sensors
like the Bot Sensor have two states: on and off. If the Bot Sensor detects a bot
it will switch to the state 'on' and sends a signal to a connected block,
called an actuator.

Sensors are:

- Bot Sensor: Sends a signal when a robot passes by
- Node Sensor: Sends a signal when it detects any (new) node
- Crop Sensor: Sends a signal when, for example wheat is fully grown
- Bot Chest: Sends a signal depending on the chest state (empty, full)

Actuators are:

- Signs Bot Box: Can turn the bot off and on
- Control Unit: Can be used to exchange the sign to lead the bot

Sensors must be connected (paired) with actuators. This is what the
"Sensor Connection Tool" does.

[signs_bot_sensor_crop_inv.png|image]


## Sensor Connection Tool

To send a signal from a sensor to an actuator, the sensor has to be connected
(paired) with actuator. To connect sensor and actuator, the Sensor Connection Tool
has to be used. Simply click with the tool on both blocks and the sensor will be
connected with the actuator. A successful connection is indicated by a ping/pong noise.

Before you connect sensor with actuator, take care that the actuator is in the
requested state. For example: If you want to start the Bot with a sensor, connect
the sensor with the Bot Box, when the Bot is in the state 'on'. Otherwise the sensor
signal will stop the Bot, instead of starting it.

[signs_bot_tool.png|image]


## Inventory

The following applies to all commands that place items/items in the bot inventory, such as:


- `take_item <num> <slot>`
- `pickup_items <slot>`
- `trash_sign <slot>`
- `harvest <slot>`
- `dig_front <slot> <lvl>`

If no slot or slot 0 was specified with the command (case A), all 8 slots of the bot
inventory are checked one after the other. If a slot was specified (case B),
only this slot is checked. 
In both cases the following applies: 

If the slot is preconfigured and matches the item, or if the slot is unconfigured
and empty, or only partially filled with the item type to be added, 
then the item(s) will be added.
If not all items can be added, in case A the remaining slots are tried. 
Anything that couldn't be added to your inventory will go back or be dropped.

The following applies to all commands that are used to take items from the bot inventory, like:

- `add_item <num> <slot>`

It doesn't matter whether a slot is configured or not. The bot takes the first stack
that it can find from its own inventory and tries to use it. If a slot is specified,
it only takes this, if no slot has been specified, it checks all of them one after
the other, starting from slot 1 until it finds something. If the number found is
smaller than requested, he tries to take the rest out of any other slot.

[signs_bot:box|image]

## Nodes / Blocks

### Signs Bot Box

The Box is the housing of the bot. Place the box and start the bot by means of the
'On' button. If the mod techage is installed, the bot needs electrical power.
The bot leaves the box on the right side. It will not start, if this position is blocked.

To stop and remove the bot, press the 'Off' button.
The box inventory simulates the inventory of the bot.
You will not be able to access the inventory, if the bot is running.
The bot can carry up to 8 stacks and 6 signs with it.

[signs_bot:box|image]

### Bot Flap

The flap is a simple block used as door for the bot. Place the flap in any wall,
and the bot will automatically open and close the flap as it passes through it.

[signs_bot:bot_flap|image]

### Signs Duplicator

The Duplicator can be used to make copies of signs:

1. Put one 'cmnd' sign to be used as template into the 'Template' inventory
2. Add one or several 'blank signs' to the 'Input' inventory.
3. Take the copies from the 'Output' inventory.

Written books [default:book_written] can alternatively be used as template.
Already written signs can be used as input, too.

[signs_bot:duplicator|image]

### Bot Sensor

The Bot Sensor detects any bot and sends a signal, if a bot is nearby.
The sensor range is one node/meter." The sensor direction does not care.

[signs_bot:bot_sensor|image]

### Node Sensor

The node sensor sends cyclical signals when it detects that nodes have appeared
or disappeared, but has to be configured accordingly. Valid nodes are all kind
of blocks and plants. The sensor range is 3 nodes/meters in one direction.
The sensor has an active side (red) that must point to the observed area.

[signs_bot:node_sensor|image]

### Crop Sensor

The Crop Sensor sends cyclical signals when, for example, wheat is fully grown.
The sensor range is one node/meter. The sensor has an active side (red) that
must point to the crop/field.

[signs_bot:crop_sensor|image]

### Signs Bot Chest

The Signs Bot Chest is a special chest with sensor function. It sends a signal
depending on the chest state. Possible states are 'empty', 'not empty', 'almost full'

A typical use case is to turn off the bot, when the chest is almost full or empty.

[signs_bot:chest|image]

### Bot Timer

This is a special kind of sensor. Can be programmed with a time in seconds,
e.g. to start the bot cyclically.

[signs_bot:timer|image]

### Bot Control Unit

The Bot Control Unit is used to lead the bot by means of signs. The unit can be
loaded with up to 4 different signs and can be programmed by means of sensors.

To load the unit, place a sign on the red side of the unit and click on the unit.
The sign disappears / is moved to the inventory of the unit.
This can be repeated 3 times.

Use the connection tool to connect up to 4 sensors with the Bot Control Unit.

[signs_bot:changer1|image]

### Sensor Extender

With the Sensor Extender, sensor signals can be sent to more than one actuator.
Place one or more extender nearby the sensor and connect each extender with one
further actuator by means of the Connection Tool.

[signs_bot:sensor_extender|image]

### Signal AND

Signal is sent, if all input signals are received.

[signs_bot:and1|image]

### Signal Delayer

Signals are forwarded delayed. Subsequent signals are queued. 
The delay time can be configured.

[signs_bot:delayer|image]

### Sign 'farming'

Used to harvest and seed a 3x3 field. Place the sign in front of the field.
The seed used must be in the first slot of the bot inventory.
When the bot is done, the bot will turn and walk back.

[signs_bot:farming|image]

### Sign 'pattern'

Used to make a copy of a 3x3x3 cube. Place the sign in front of the pattern
to be copied. Use the copy sign to make the copy of this pattern on a different
location. The bot must first reach the pattern sign, then the copy sign.

Used to make a copy of a 3x3x3 cube. Place the shield in front of the blocks
to be copied. Use the copy sign to make the copy of these blocks in another
location. The bot must first process the "pattern" sign, only then can the bot
be directed to the copy sign.

[signs_bot:pattern|image]

### Sign 'copy3x3x3'

Used to make a copy of a 3x3x3 cube. Place the sign in front of where you want
the copy to be made. See also sign "pattern".

[signs_bot:copy3x3x3|image]

### Sign 'flowers'

Used to cut flowers on a 3x3 field. Place the sign in front of the field.
When finished, the bot turns.

[signs_bot:flowers|image]

### Sign 'aspen'

Used to harvest an aspen or pine tree trunk

- Place the sign in front of the tree.
- Place a chest to the right of the sign.
- Put a dirt stack (10 items min.) into the chest.
- Preconfigure slot 1 of the bot inventory with dirt
- Preconfigure slot 2 of the bot inventory with saplings

[signs_bot:aspen|image]

### Sign 'command'

The 'command' sign can be programmed by the player. Place the sign in front
of you and use the node menu to program your sequence of bot commands.
The menu has an edit field for your commands and a help page with all
available commands. The help page has a copy button to simplify the programming.

[signs_bot:sign_cmnd|image]

### Sign "turn right"

The Bot turns right when it detects this sign in front of it.

[signs_bot:sign_right|image]

### Sign "turn left"

The Bot turns left when it detects this sign in front of it.

[signs_bot:sign_left|image]

### Sign "take item"

The Bot takes items out of a chest in front of it and then turns around.
This sign has to be placed on top of the chest.

[signs_bot:sign_take|image]

### Sign "add item"

The Bot puts items into a chest in front of it and then turns around.
This sign has to be placed on top of the chest.

[signs_bot:sign_add|image]

### Sign "stop"

The Bot will stop in front of this sign until the sign is removed or
the bot is turned off.

[signs_bot:sign_stop|image]

### Sign "add to cart" (minecart)

The Bot puts items into a minecart in front of it, pushes the cart and then turns
around. This sign has to be placed on top of the rail at the cart end position.

[signs_bot:sign_add_cart|image]

### Sign "take from cart" (minecart)

The Bot takes items out of a minecart in front of it, pushes the cart and then
turns around. This sign has to be placed on top of the rail at the cart end position.

[signs_bot:sign_take_cart|image]

### Sign 'take water' (xdecor)

Used to take water into bucket. Place the sign on a shore, in front of the still water pool. 

Items in slots:

  1 - empty bucket

The result is one bucket with water in selected inventory slot. When finished,
the bot turns around.

[signs_bot:water|image]

### Sign 'cook soup' (xdecor)

Used to cook a vegetable soup in cauldron. Cauldon should be empty and located
above flammable material. Place the sign in front of the cauldron with one field
space, to prevent wooden sign from catching fire.

Items in slots:

  1 - water bucket"
  2 - vegetable #1 (i.e. tomato)
  3 - vegetable #2 (i.e. carrot)
  4 - empty bowl (from farming or xdecor mods)

  The result is one bowl with vegetable soup in selected inventory slot.
When finished, the bot turns around.

[signs_bot:soup|image]


## Bot Commands

The commands are also all described as help in the "Sign command" node.
All blocks or signs that are set are taken from the bot inventory.
Any blocks or signs removed will be added back to the Bot Inventory.
`<slot>` is always the bot internal inventory stack (1..8).

    move <steps>              - go one or more steps forward
    cond_move                 - go to the nearest obstacle or sign
    turn_left                 - turn left
    turn_right                - turn right
    turn_around               - turn around
    backward                  - take a step back
    turn_off                  - turn off the robot / back to the box
    pause <sec>               - wait one or more seconds
    move_up                   - move up (maximum 2 times)
    move_down                 - move down
    fall_down                 - fall into a hole/chasm (up to 10 blocks)
    take_item <num> <slot>    - take one or more items from a box
    add_item <num> <slot>     - put one or more items in a box
    add_fuel <num> <slot>     - put fuel in a furnace
    place_front <slot> <lvl>  - place the block in front of the bot
    place_left <slot> <lvl>   - place the block to the left of the bot
    place_right <slot> <lvl>  - place the block to the right of the bot
    place_below <slot>        - lift the robot and put the block under the robot
    place_above <slot>        - set block above the robot
    dig_front <slot> <lvl>    - remove block in front of the robot
    dig_left <slot> <lvl>     - remove block on the left
    dig_right <slot> <lvl>    - remove block on the right
    dig_below <slot>          - remove block under the robot
    dig_above <slot>          - remove block above the robot
    rotate_item <lvl> <steps> - rotate a block in front of the robot
    set_param2 <lvl> <param2> - set param2 of the block in front of the robot
    place_sign <slot>         - set sign
    place_sign_behind <slot>  - put a sign behind the bot
    dig_sign <slot>           - remove the sign
    trash_sign <slot>         - Remove the sign, clear data and add to the item Inventory
    stop                      - Bot stops until the shield is removed
    pickup_items <slot>       - pickup items (in a 3x3 field)
    drop_items <num> <slot>   - drop items
    harvest                   - harvest a 3x3 field (farming)
    cutting                   - cut flowers in a 3x3 field
    sow_seed <slot>           - see/plant a 3x3 field
    plant_sapling <slot>      - plant a sapling in front of the robot
    pattern                   - save the block properties behind the sign (3x3x3 cube) as a template
    copy <size>               - make a 3x3x3 copy of the stored template
    punch_cart                - bump a mine cart
    add_compost <slot>        - Put 2 leaves into the compost barrel
    take_compost <slot>       - Take a compost item from the barrel
    print <text>              - Output chat message for debug purposes
    take_water <slot>         - Take water with empty bucket
    fill_cauldron <slot>      - Fill the xdecor cauldron for a soup
    take_soup <slot>          - Take boiling soup into empty bowl from cauldron
    flame_on                  - Make fire
    flame_off                 - Put out the fire

[signs_bot_bot_inv.png|image]

### Techage specific commands

    ignite                            - Ignite the techage charcoal lighter
    low_batt <percent>                - Turn the bot off if the battery power is below the 
                                        given value in percent (1..99)
    jump_low_batt <percent> <label>   - Jump to <label> if the battery power is below the 
                                        given value in percent (1..99)
                                        (see "Flow control commands")
    send_cmnd <receiver> <command>    - Send a techage command to a given node. 
                                        Receiver is addressed by the techage node number. 
                                        For commands with two or more words, 
                                        use the '*' character instead of spaces, e.g.: 
                                        send_cmnd 3465 pull*default:dirt*2 

[signs_bot_bot_inv.png|image]

### Flow control commands

    -- jump command, <label> is a word from the characters a-z or A-Z
    jump <label>

    -- jump label / start of a function
    <label>:

    -- return from a function
    return

    -- start of a loop block, <num> is a number 1..999
    repeat <num>

    -- end of a loop block
    end

    -- call of a function (with return via the command 'return')
    call <label>


[signs_bot_bot_inv.png|image]

### Further jump commands

    -- Check if there are <num> items in the chest like node.
    -- If not, jump to <label>.
    -- <slot> is the bot inventory slot (1..8) to
    -- specify the item, or 0 for any item.
    jump_check_item <num> <slot> <label>

    -- See "Techage specific commands"
    jump_low_batt <percent> <label>


[signs_bot_bot_inv.png|image]

### Flow control Examples

#### Example with a function at the beginning:

    -- jump to the label 'main'
    jump main
    
    -- starting point of the function with the name 'foo'
    foo:
      cmnd ...
      cmnd ...
    -- end of 'foo'. Jump back
    return
    
    -- main program
    main:
      cmnd ...
      -- repeat all commands up to 'end' 10 times
      repeat 10
        cmnd ...
        -- call the subfunction 'foo'
        call foo
        cmnd ...
      -- end of the 'repeat' loop
      end
    -- end of the program
    exit


#### Example with a function at the end:
    
    cmnd ...
    -- repeat all commands up to 'end' 10 times
    repeat 10
      cmnd ...
      -- call the subfunction 'foo'
      call foo
      cmnd ...
    -- end of the 'repeat' loop
    end
    -- end of the program
    exit
    
    -- starting point of the function with the name 'foo'
    foo:
      cmnd ...
      cmnd ...
    -- end of 'foo'. Jump back
    return
