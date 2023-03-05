Signs Bot [signs_bot]
=====================

**A robot controlled by signs.**

Browse on: [GitHub](https://github.com/joe7575/signs_bot)

Download: [GitHub](https://github.com/joe7575/signs_bot/archive/master.zip)

![Signs Bot](https://github.com/joe7575/signs_bot/blob/master/screenshot.png)


The bot can only be controlled by signs that are placed in its path.
The bot starts running after starting until it encounters a sign. There, the commands are then processed on the sign.
The bot can also put himself signs in the way, which he then works off.
There is also a sign that can be programmed by the player, which then are processed by the bot.

There are also the following blocks:
- Sensors: These can send a signal to an actuator if they are connected to the actuator.
- Actuators: These perform an action when they receive a signal from a sensor.

Sensors must be connected (paired) with actuators. This is what the Connection Tool does. Click on both blocks one after the other.
A successful pairing is indicated by a ping / pong noise.
When pairing, the state of the actuator is important. In the case of the bot box, for example, the states "on" and "off", in the case of the control unit 1,2,3,4, etc.
The state of the actuator is saved with the pairing and restored by the signal. For example, the robot can be switched on via a node sensor.

An actuator can receive signals from many sensors. A sensor can only be connected to an actuator. However, if several actuators are to be controlled by one sensor, a signal extender block must be used. This connects to a sensor when it is placed next to the sensor. This extender can then be paired with another actuator.

Sensors are:
- Bot Sensor: Sends a signal when the robot passes by
- Node Sensor: Sends a signal when it detects a change (tree, cactus, flower, etc.) in front of the sensor (over 3 positions)
- Crop Sensor: Sends a signal when, for example, the wheat is fully grown
- Bot Chest: Sends a signal depending on the chest state. Possible states are "empty", "not empty", "almost full". The state to be sent is defined while pairing.

Actuators are:
- Control Unit: Can place up to 4 signs and steer the bot e.g. in different directions.
- Signs Bot Box: Can be turned off and on

In addition, there are currently the following blocks:
- The duplicator is used to copy Command Signs, i.e. the signs with their own commands.
- Bot Flap: The "cat flap" is a door for the bot, which he opens automatically and closes behind him.
- Sensor Extender for controlling additional actuators from one sensor signal
- A Timer can be used to start the Bot cyclically
- A Delayer can be used to delay and queue signals

More information:
- Using the signs "take" and "add", the bot can pick items from Chests and put them in. The signs must be placed on the box. So far, only a few blocks are supported with Inventory.
- The Control Unit can be charged with up to 4 labels. To do this, place a label next to the Control Unit and click on the Control Unit. The sign is only stored under this number.
- The inventory of the Signs Bot Box is intended to represent the inventory of the Robot. As long as the robot is on the road, of course you have no access.

The copy function can be used to clone node cubes up to 5x3x3 nodes. There is the pattern shield for the template position and the copy shield for the "3x3x3" copy. Since the bot also copies air blocks, the function can also be used for mining or tunnels. The items to be placed must be in the inventory. Items that the bot degrades are in Inventory afterwards. If there are missing items in the inventory during copying, he will set "missing items" blocks, which dissolve into air when degrading.

In-game help:
The mod has an in-game help to all blocks and signs. Therefore, it is highly recommended that you have installed the mods 'doc' and 'unified_inventory'.

### Commands:
The commands are also all described as help in the "Sign command" node.
All blocks or signs that are set are taken from the bot inventory.
Any blocks or signs removed will be added back to the Bot Inventory.
`<slot>` is always the bot internal inventory stack (1..8).
For all Inventory commands applies: If the bot inventory stack specified by `<slot>` is full, so that nothing more can be done, or just empty, so that nothing more can be removed, the next slot will automatically be used.

    move <steps>              - to follow one or more steps forward without signs
    cond_move                 - walk to the next sign and work it off
    turn_left                 - turn left
    turn_right                - turn right
    turn_around               - turn around
    backward                  - one step backward
    turn_off                  - turn off the robot / back to the box
    pause <sec>               - wait one or more seconds
    move_up                   - move up (maximum 2 times)
    move_down                 - move down
    fall_down                 - fall into a hole/chasm (up to 10 blocks)
    take_item <num> <slot>    - take one or more items from a box
    add_item <num> <slot>     - put one or more items in a box
    add_fuel <num> <slot>     - for furnaces or similar
    place_front <slot> <lvl>  - Set block in front of the robot
    place_left <slot> <lvl>   - Set block to the left
    place_right <slot> <lvl>  - set block to the right
    place_below <slot>        - set block under the robot
    place_above <slot>        - set block above the robot
    dig_front <slot> <lvl>    - remove block in front of the robot
    dig_left <slot> <lvl>     - remove block on the left
    dig_right <slot> <lvl>    - remove block on the right
    dig_below <slot>          - dig block under the robot
    dig_above <slot>          - dig block above the robot
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
    cutting                   - cut a 3x3 flower field
    sow_seed <slot>           - a 3x3 field sowing / planting
    plant_sapling <slot>      - plant a sapling in front of the robot
    pattern                   - save the blocks behind the shield (up to 5x3x3) as template
    copy <size>               - make a copy of "pattern". Size is e.g. 3x3 (see ingame help)
    punch_cart                - Punch a rail cart to start it
    add_compost <slot>        - Put 2 leaves into the compost barrel
    take_compost <slot>       - Take a compost item from the barrel
    print <text>              - Output chat message for debug purposes
    take_water <slot>         - Take water with empty bucket
    fill_cauldron <slot>      - Fill the xdecor cauldron for a soup
    take_soup <slot>          - Take boiling soup into empty bowl from cauldron
    flame_on                  - Make fire
    flame_off                 - Put out the fire

#### Techage specific commands

    ignite                            - Ignite the techage charcoal lighter
    low_batt <percent>                - Turn the bot off if the battery power is below the 
                                        given value in percent (1..99)
    jump_low_batt <percent> <label>   - Jump to <label> if the battery power is below the 
                                        given value in percent (1..99)
                                        (see "Flow control commands")
    send_cmnd <receiver> <command>    - Send a techage command to a given node. 
                                        Receiver is addressed by the techage node number. 
                                        For commands with two or more words, use the '*' character
                                        instead of spaces, e.g.: send_cmnd 3465 pull*default:dirt*2 


#### Flow control commands

    jump <label>    -- jump command, <label> is a word from the characters a-z or A-Z
    <label>:        -- jump label / start of a function
    return          -- return from a function
    repeat <num>    -- start of a loop block, <num> is a number 1..999
    end             -- end of a loop block
    call <label>    -- call of a function (with return via the command 'return')

#### Further jump commands

    jump_check_item <num> <slot> <label>  - Check if there are <num> items in the chest like node.
    		                                If not, jump to <label>.
                                            <slot> is the bot inventory slot (1..8) to specify the item,
    		                                or 0 for any item.
    jump_low_batt <percent> <label>       - See "Techage specific commands"



Example with a function at the beginning:

    jump main       -- jump to the label 'main'
    
    foo:            -- starting point of the function with the name 'foo'
      cmnd ...
      cmnd ...
    return          -- end of 'foo'. Jump back
    
    main:           -- main program
      cmnd ...
      repeat 10     -- repeat all commands up to 'end' 10 times
        cmnd ...
        call foo    -- call the subfunction 'foo'
        cmnd ...
      end           -- end of the 'repeat' loop
    exit            -- end of the program

Or alternatively with the function at the end:

    cmnd ...
    repeat 10       -- repeat all commands up to 'end' 10 times
      cmnd ...
      call foo      -- call the subfunction 'foo'
      cmnd ...
    end             -- end of the 'repeat' loop
    exit            -- end of the program
    
    foo:            -- starting point of the function with the name 'foo'
      cmnd ...
      cmnd ...
    return          -- end of 'foo'. Jump back

### License
Copyright (C) 2019-2022 Joachim Stolberg
Copyright (C) 2021 Michal 'Micu' Cieslakiewicz (soup commands)
Code: Licensed under the GNU GPL version 3 or later. See LICENSE.txt  


### Dependencies 
default, farming, basic_materials, tubelib2  
optional: farming redo, node_io, doc, techage, minecart, xdecor, compost


### History
- 2019-03-23  v0.01  * first draft
- 2019-04-06  v0.02  * completely reworked
- 2019-04-08  v0.03  * 'plant_sapling', 'place_below', 'dig_below' added, many bugs fixed
- 2019-04-11  v0.04  * support for 'node_io' added, chest added, further commands added
- 2019-04-14  v0.05  * timer added, user signs added, bug fixes
- 2019-04-15  v0.06  * nodes remove bugfix, punch_cart command added, cart sensor added
- 2019-04-18  v0.07  * node_io is now optional, support for MTG chests and furnace added
- 2019-05-22  v0.08  * recipe bug fixes and prepared for techage
- 2019-05-25  v0.09  * in-game help added for the mod 'doc'
- 2019-07-05  v0.10  * Timer, sensor and cart handling improvements
- 2019-07-08  v0.11  * Delayer added
- 2019-08-09  v0.12  * bug fixes
- 2019-08-14  v0.13  * Signs Bot Chest recipe added, Minecart signs added
- 2020-01-02  v1.00  * bot inventory filter added, documentation enhanced
- 2020-03-27  v1.01  * flower command and sign added
- 2020-03-30  v1.02  * Program flow control commands added
- 2020-06-21  v1.03  * Interpreter bugfixes, node and crop sensors changed
- 2020-10-01  v1.04  * Many improvements and bugfixes (Thanks to Thomas-S)
- 2021-01-30  v1.05  * Many improvements and bugfixes
- 2021-03-14  v1.06  * Switch translation from intllib to minetest.translator
- 2021-04-24  v1.07  * Adapted to minecart v2.0
- 2021-05-04  v1.08  * Add print command, improve error msg
- 2021-08-22  v1.09  * Add soup commands and signs, add aspen sign
- 2021-09-18  v1.10  * Add techage command 'set <num>' to the Bot Control Unit
- 2022-03-19  V1.11  * Extend farming (and add ethereal) support (Thanks to nixnoxus)
- 2022-09-11  V1.12  * Add commands `jump_low_batt` , `jump_check_item`, and `fall_down`


