# Tower Crane Mod
In order to simplify the construction of buildings, the crane forms a construction area in which the player gets fly privs.

Browse on: ![GitHub](https://github.com/minetest-mods/towercrane)

Download: ![GitHub](https://github.com/minetest-mods/towercrane/archive/master.zip)

The crane can be completely assembled by setting only the base block.
The size of the crane (which is the construction area) and the rope length can be configured.

![Tower Crane](https://github.com/minetest-mods/towercrane/blob/master/towercrane640.png)


## Introduction
* Place the crane base block.
  The crane arm will later be build in the same direction you are currently looking 

* Right-click the crane base block and set the crane dimensions in height and width (between 8 and 32 by default).
  The crane will be build according to this settings.
  If there is not enough free space for the crane mast/arm or the potential construction area of the 
  crane intersects a protected area from another player, the crane will not be build.

* Right-click the crane switch block to start the crane (get fly privs). The player will be placed in front of the crane.

* To remove the crane, destroy the base block.  

**Minetest v5.0+ is required!**

## Dependencies
default  


# License
Copyright (C) 2017-2020 Joachim Stolberg  
Code: Licensed under the GNU LGPL version 2.1 or later. See LICENSE.txt and http://www.gnu.org/licenses/lgpl-2.1.txt  
Textures: Mostly CC0 (by Ammoth)

 * `morelights_extras_blocklight.png`: CC BY-SA 4.0 (by random-geek)

# History:
* 2017-06-04  v0.01  first version
* 2017-06-06  v0.02  Hook bugfix
* 2017-06-07  v0.03  fixed 2 bugs, added config.lua and sound
* 2017-06-08  v0.04  recipe and rope length now configurable
* 2017-06-10  v0.05  resizing bugfix, area protection added
* 2017-07-11  v0.06  fixed the space check bug, settingtypes added
* 2017-07-16  v0.07  crane remove bug fix
* 2017-07-16  v0.08  player times out bugfix
* 2017-08-19  v0.09  crane protection area to prevent crane clusters
* 2017-08-27  v0.10  hook instance and sound switch off bug fixes
* 2017-09-09  v0.11  further player bugfixes
* 2017-09-24  v0.12  Switched from entity hook model to real fly privs
* 2017-10-17  v0.13  Area protection bugfix
* 2017-11-01  v0.14  Crane handing over bugfix
* 2017-11-07  v0.15  Working zone is now restricted to areas with necessary rights
* 2018-02-27  v0.16  "fly privs" bug fixed (issue #2)
* 2018-04-12  v0.17  "area owner changed" bug fixed (issue #3)
* 2018-05-28  v1.0 Mod released
* 2019-09-08  v2.0 Completely restructured, protection areas removed
* 2019-12-03  v2.1 Bugfix issue #2 (Some players still have "fly" after detaching)
* 2020-01-03  V2.2 dying player bugfix (when fly mode is disabled)
* 2020-03-16  V2.3 switched to 16 bit textures (by tuedel/Ammoth) and crane upright time increased to 5 real days
