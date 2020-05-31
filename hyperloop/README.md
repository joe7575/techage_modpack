# Hyperloop v2

**A new evolution in the voxel word:**

## Minetest goes Hyperloop!

Hyperloop is passenger transportation system for travelling through evacuated tubes my means of passenger pods.
It is the fast and modern way of travelling.
* Hyperloop allows travelling from point to point in seconds (900 km/h) :-)
* The tubes system with all stations and pods have to be build by players
* It can be used even on small servers without lagging
* No configuration or programming of the tube network is necessary (only the station names have to be entered)


**![See Wiki Page for more info](https://github.com/joe7575/Minetest-Hyperloop/wiki)**

![screenshot](https://github.com/joe7575/Minetest-Hyperloop/blob/master/screenshot.png)


The mod includes many different kind of blocks:
- Hyperloop Stations Block to automatically build the pod/car
- Hyperloop Booking Machine for the station to select the destination
- Hyperloop Tube to connect two stations
- Hyperloop Junction Block to connect up to 6 tubes for complex network structures
- Hyperloop Stations Signs
- Hyperloop Promo Poster for station advertisement
- Hyperloop Elevator to reach other levels
- Hyperloop Elevator Shaft to connect two elevator cars 
- Hyperloop Station Book with all available stations (for builders/engineers)
- Hyperloop Tube Crowbar to crack/repair tube lines (for admins)
- Hyperloop WiFi Tubes for very large distances (optional)
- chat command to repair WorldEdit placed tubes
..and more.


Browse on: ![GitHub](https://github.com/joe7575/Minetest-Hyperloop)

Download: ![GitHub](https://github.com/joe7575/Minetest-Hyperloop/archive/master.zip)


## Migration from v1 to v2
The logic behind the tubes/shafts has changed. Hyperloop now uses tubelib2 as tube library.
That means, available worlds have to be migrated for the new tubes. This is done automatically but
has some risks. Therefore:

**I recommend to backup your world or test the migration from v1 to v2 on a copy of your world!!!**


## What is new in v2
- some textures changed
- the Elevator Shafts can now be used as ladder/climbing shafts
- the Crowbar is public available, but cracking a tube line need 'hyperloop' privs
- the Station Book is improved and simplified to find stations, junctions, and open tube ends
- a Waypoint plate is added to mark and easier find the tube destination
- Elevator shafts can be build in all directions (optional)
- WiFi Tubes can be crafted and placed by players (optional)
- intllib support added (German translation available)


## Introduction

**![See Wiki Page for more info](https://github.com/joe7575/Minetest-Hyperloop/wiki)**


## Configuration
The following can be changed in the minetest menu (Settings -> Advanced Settings -> Mods -> hyperloop) or directly in 'minetest.conf'
* "WiFi block enabled" - To enable the usage of WiFi blocks
* "WiFi block crafting enabled" - To enable the crafting of WiFi blocks
* "free tube placement enabled" - If enabled Hyperloop Tubes and Elevator Shafts can be build in all directions.  
  When this option is disabled, Hyperloop tubes can only be built in the horizontal direction and elevator shafts in the vertical direction.

Example for 'minetest.conf':
```LUA
hyperloop_wifi_enabled = true
hyperloop_wifi_crafting_enabled = false
hyperloop_free_tube_placement_enabled = true
```

## Dependencies
tubelib2 (![GitHub](https://github.com/joe7575/tubelib2))  
default  
intllib  
optional: worldedit, techage


# License
Copyright (C) 2017,2020 Joachim Stolberg  
Code: Licensed under the GNU LGPL version 2.1 or later. See LICENSE.txt and http://www.gnu.org/licenses/lgpl-2.1.txt  
Textures: CC0  
Display: Derived from the work of kaeza, sofar and others (digilines) LGPLv2.1+
