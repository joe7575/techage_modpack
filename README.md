# Modpack Tech Age [techage]

This modpack covers all necessary and useful mods to be able to use techage.
All mods have their own README.txt. For further information please consult these files.

This modpack contains:
- techage: The main mod
- ta4_jetpack: A Jetpack for techage with hydrogen as fuel and TA4 recipe
- ta4_paraglider: A Paraglider for techage with TA4 recipe
- ta4_addons: A Touchscreen like the TA4 display, but with additional commands and features
- autobahn: Street blocks and slopes with stripes for faster traveling (the only need of bitumen from techage)
- compost: The garden soil is needed for the TA4 LED Grow Light based flower bed
- signs_bot: For many automation tasks in TA3/TA4 like farming, mining, and item transportation
- hyperloop: Used as passenger transportation system in TA4
- techpack_stairway: Ladders, stairways, and bridges for your machines
- minecart: Techage transportation system for oil and other items
- towercrane: Simplifies the building of large techage plants
- basic_materials: Needed items for many recipes
- stamina: The "hunger" mod from "minetest-mods"
- unified_inventory: Player's inventory with crafting guide, bags, and more.
- tubelib2: Necessary library
- networks: Necessary library
- safer_lua: Necessary library
- lcdlib: Necessary library
- doclib: Necessary library


### Techage Manual

All techage manuals (EN/DE) are available ingame (craft the 'TA Construction Board')
or use the manual on [GitHub](https://github.com/joe7575/techage/wiki).


### Licenses

All mods have their own licenses. See the license files in the subfoldes.
The modpack itself has the same license as the Mod Techage.


### Further Dependencies  

Required: Minetest Game

ta4_jetpack requires the modpack 3d_armor. 3d_armor is itself a modpack and can't be integrated into the techage modpack.


### History

#### 2023-11-26

Updated Mods:

- tubelib2:
  - Improve pipe/tube placement
- doclib:
  - Add a NIL check to prevent crashes
- minecart:
  - Replace some global_exists by get_modpath
  - Fix crash when using techage (Niklp09)
- techage:
  - Fix crash with collider magnets
- basic_materials:
  - Update to current version

#### 2023-11-05

Updated Mods:

- techage v1.18:
  - see readme.md
- ta4_jetpack:
  -  Fix translation issue
- minecart:
  - Fix bug with missing techage mod 
- signs_bot:
  - Fix bug #36 (pattern/copy 5x3 is off center)
  - Adapt bot box for techage assembly tool
  - Escape equal sign in german translation (Niklp09)
- autobahn:
  - Add support for player_monoids (Niklp09)
- compost:
  - User proper player creative check (Niklp09)
  - Fix drop bug
- techpack_stairway:
  - Add stairways without handrails
- networks:
  - Add support for colored nodes by unifieddyes
  - Improve debugging tool

#### 2023-08-25

**The mod doclib is a new hard dependency !**

Updated Mods:

- techage v1.17:
  - see readme.md
- autobahn:
  - Make motor sound mono (Niklp09)
- lcdlib v1.02:
  - see readme.md
- signs_bot v1.13:
  - see readme.md
- minecart v2.05:
  - see readme.md
- mod 'doc' removed
- mod 'doclib' v1.00 added
- mod 'datastorage' removed

#### 2023-05-09

Updated Mods:

- techage v1.15:
  - see readme.md
- hyperloop:
  - Remove intlib support

#### 2023-03-05

Updated Mods:
- techage v1.11:
  - see readme.md
- signs_bot v1.12:
  - Add bot command 'set_param2'
- minecart v2.04:
  - New API functions added
  - EOL blanks removed
- hyperloop:
  - Fix some bugs
- networks v0.13:
  - New API function networks.power.get_storage_percent added
- autobahn:
  -  fix reset_player_privs bug
- basic_materials:
  - Switched back to tag "2021-01-30"

#### 2023-02-04

Updated Mods:
- techage:
  - V1.10 (see readme.md)
- signs_bot:
  - Fix fall_down on rail bug
- minecart:
- hyperloop:
  - Fix some bugs

#### 2022-12-31

Updated Mods:
- techage:
  - Add wafer recipe with 'mesecons_materials:silicon'
  - Add TA5 AI Chip II to the manual
  - Fix movecontroller wrench menu bug
  - Improve chemical reactor description
  - Improve player detector wrench menu
  - Fix 'count' command bug: default value is 0 again
  - Movecontroller: Allow moving blocks through unloaded areas
  - Player detector: Add wrench menu to configure search radius
  - Movecontroller: Place unloaded flying blocks to dest pos
  - Furnace: Don't use items filled from the top as fuel
  - Manual improvements for the move controller
  - Make a use for cotton seeds #104
  - Merge pull request #102 from Niklp09/mvps2
  - Fix broken mesecons detection
  - Fix bug with TA1 hammer used by pipeworks nodebreaker
  - Merge pull request #99 from Niklp09/mvps
  - Register mvps stopper for complex techage nodes
  - Merge pull request #98 from Niklp09/glow_gravel
  - Fix hammer bauxite bug
  - Fix mesecons_materials bug
  - Add cracking recipe for isobutane
  - Merge pull request #96 from Niklp09/ethereal
  - Grind ethereal leaves to leave powder
  - Improve manual, fix bug in electrolyzer menu description
- networks (Add API function used by the techage tool)
- safer_lua (Limit code execution time for recursive function calls (#3 by Thomas--S))
- tubelib2:
  - Merge pull request #18 from IFRFSX/cn
  - Add chinese translation
  - Merge pull request #17 from Niklp09/master
  - Fix minor translation issue
- signs_bot:
  - Fix stop command bug
  - Fix #23 (Water is moved up when a bot builds upward from under water)
  - Fix bug remove foot after move_up command
- hyperloop (Fix elevator area protection bug)

#### 2022-09-24

Updated Mods:
- techage (fix database backend bug, further bugfixes and improvements)
- lcdlib (fix MT5.5+ "deprecated" warnings)
- signs_bot (add new commands)
- networks (add 'networks.liquid.get_liquids')
- ta4_paraglider (Fix bug "Add nil player check in paraglider")
- unified_inventory (Add support for colored items (#213))

#### 2022-08-17

Updated Mods:
- techage (fix "Invalid field use_texture_alpha" errors)


#### 2022-08-06

Updated Mods:
- autobahn (fix MT5.5+ "deprecated" warnings)
- compost (fix MT5.5+ "deprecated" warnings)
- hyperloop (fix MT5.5+ "deprecated" warnings, add french translation)
- tubelib2 (fix MT5.5+ "deprecated" warnings)
- networks (Add improvement for liquid handling)
- signs_bot (fix MT5.5+ "deprecated" warnings)
- minecart (fix MT5.5+ "deprecated" warnings)
- safer_lua (fix MT5.5+ "deprecated" warnings)
- techpack_stairway (fix MT5.5+ "deprecated" warnings)
- techage (many improvements, see: https://github.com/joe7575/techage/commits/master)
- ta4_jetpack (Fix the 3d_armor _material issue)
- datastorage (fix MT5.5+ "deprecated" warnings)
- stamina (fix MT5.5+ "deprecated" warnings)


#### 2022-07-11

Updated Mods:
- techage V1.08 with improvements and bug fixes
- signs_bot
- tubelib2
- unified_inventory
- lcdlib

#### 2022-01-28

Updated Mods:
- techage (fusion reactor added)


#### 2022-01-04

Updated Mods:
- techage (bugfixes)


#### 2022-01-03

Updated Mods:
- techage (see readme)
- hyperloop (see readme)
- minecart (bugfix)
- unified_inventory (see readme)
- ta4_addons (see readme)


#### 2021-10-30

Updated Mods:
- techage (see readme)
- signs_bot (see readme)
- minecart (bugfix)
- lcdlib (improvement)


#### 2021-09-18

Updated Mods:
- techage (see readme)
- signs_bot (see readme)
- networks (see readme)
- ta4_addons (add matrix screen)


#### 2021-09-04

Updated Mods:
- minecart (bugfix)


#### 2021-09-03

Updated Mods:
- techage (bugfixes)
- minecart (see readme)
- signs_bot (see readme)


#### 2021-08-19

Changed Mods:
- techage (see readme and constuction board)

Updated Mods:
- minecart


#### 2021-08-01

Newly added mods (must be activated!):
- networks
- ta4_addons (Touchscreen)

Changed Mods:
- techage (see readme and constuction board)
- minecart (see readme "Migration to v2")

Updated Mods:
- autobahn
- signs_bot
- hyperloop
- ta4_jetpack


#### 2021-05-14

Updated Mods:
- compost
- minecart
- signs_bot
- techage
- towercrane
- unified_inventory


#### 2021-02-07

Updated Mods:
- basic_materials
- compost
- hyperloop
- minecart
- signs_bot
- ta4_paraglider
- techage
- towercrane
- tubelib2
- unified_inventory


#### 2020-12-11

Updated Mods:
- autobahn
- basic_materials
- minecart
- techage v0.25
- ta4_jetpack
- tubelib2


#### 2020-10-25

Updated Mods:
- techage v0.24
- signs_bot
- minecart
- techpack_stairway
- stamina

ta4_paraglider newly added


#### 2020-09-13

Updated Mods:

- techage v0.23
- signs_bot
- minecart


#### 2020-08-08

Updated Mods:
- autobahn
- compost
- hyperloop
- lcdlib
- minecart
- safer_lua
- signs_bot
- techage v0.21


#### 2020-07-21

Updated Mods:
- signs_bot
- techage v0.18
- towercrane
- unified_inventory
- basic_materials

#### 2020-07-02
Updates (see local readme files):
- mod 3d_armor removed again (please install separately) 
- techage v0.15 improvements and bugfixes
- autobahn v0.04 improvements

#### 2020-06-29

Updates (see local readme files):
- autobahn, towercrane, ta4_jetpack, 3d_armor, and stamina now use a common player physics lockout mechanism
- the new mod ta4_jetpack added
- mod stamina added (adapted to the player physics lockout mechanism)
- mod 3d_armor added (needed for ta4_jetpack, adapted to the player physics lockout mechanism) 
- minecart v1.07 with many improvements
- techage v0.14 with many improvements
- hyperloop v2.06 update
- autobahn update


#### 2020-06-21

Updates (see local readme files):
- signs_bot v1.03
- techage v0.13
- hyperloop v2.06


#### 2020-06-18

- techage v0.12 
  - cart commands added for both controllers
  - support for moreores added
  - Ethereal support added, manual correction
  - tin ingot recipe bugfix
  
- minecart v1.06 
  
  - API changed and chat command added
  
- signs_bot v1.02
  - some bugfixes
  
  

#### 2020-06-04

- techage v0.10
  - minor changes and bugfixes
  - stone hammer added
  - quarry 'depth' command added
  - manuals adapted
  - QSG added

#### 2020-05-31

- first commit

