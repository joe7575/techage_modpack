# Tube Library 2 [tubelib2]

A library for mods which need connecting tubes / pipes / cables or similar.

![tubelib2](https://github.com/joe7575/tubelib2/blob/master/screenshot.png)


This mod is not useful for its own. It does not even have any nodes.
It only comes with a few test nodes to play around with the tubing algorithm.

Browse on: [GitHub](https://github.com/joe7575/tubelib2)

Download: [GitHub](https://github.com/joe7575/tubelib2/archive/master.zip)


## Description

Tubelib2 distinguished two kinds of nodes:
- primary nodes are tube like nodes (pipes, cables, ...)
- secondary nodes are all kind of nodes, which can be connected by means of primary nodes

Tubelib2 specific 6D directions (1 = North, 2 = East, 3 = South, 4 = West, 5 = Down, 6 = Up)

All 6D dirs are the view from the node to the outer side
Tubes are based on two node types, "angled" and "straight" tubes.


            +-------+
           /       /|              +-------+
          /       / |             /       /|
         /       /  +            /       / |
        /       /  /            +-------+  |
       +-------+  /             |       |  |
       |       | /              |       |/ |
       |       |/               +-------+| +
       +-------+                  |      |/
                                  +------+


All other nodes are build by means of axis/rotation variants based on param2
 (paramtype2 == "facedir").

The 3 free MSB bits of param2 of tube nodes are used to store the number of connections (0..2).

The data of the peer head tube are stored in memory 'self.connCache'

Tubelib2 provides an update mechanism for connected "secondary" nodes. A callback function
func(node, pos, out_dir, peer_pos, peer_in_dir) will be called for every change on the connected tubes.



## Dependencies
optional: default


## License
Copyright (C) 2017-2022 Joachim Stolberg
Code: Licensed under the GNU LGPL version 2.1 or later.
      See LICENSE.txt and http://www.gnu.org/licenses/lgpl-2.1.txt  
Textures: CC0


## Credits

### Contributors
- oversword (PR #5, PR #7, PR #8)


## History
- 2018-10-20  v0.1  * Tested against hyperloop elevator.
- 2018-10-27  v0.2  * Tested against and enhanced for the hyperloop mod.
- 2018-10-27  v0.3  * Further improvements.
- 2018-11-09  v0.4  * on_update function for secondary nodes introduced
- 2018-12-16  v0.5  * meta data removed, memory cache added instead of
- 2018-12-20  v0.6  * intllib support added, max tube length bugfix
- 2019-01-06  v0.7  * API function replace_tube_line added, bug fixed
- 2019-01-11  v0.8  * dir_to_facedir bugfix
- 2019-02-09  v0.9  * storage.lua added, code partly restructured
- 2019-02-17  v1.0  * released 
- 2019-03-02  v1.1  * API function 'switch_tube_line' added, secondary node placement bugfix 
- 2019-04-18  v1.2  * 'force_to_use_tubes' added
- 2019-05-01  v1.3  * API function 'compatible_node' added
- 2019-05-09  v1.4  * Attribute 'tube_type' added
- 2019-07-12  v1.5  * internal handling of secondary nodes changed
- 2019-10-25  v1.6  * callback 'tubelib2_on_update2' added
- 2020-01-03  v1.7  * max_tube_length bugfix
- 2020-02-02  v1.8  * 'special nodes' as alternative to 'secondary nodes' introduced
- 2020-05-31  v1.9  * Generator function 'get_tube_line' added, storage improvements
- 2021-01-23  v2.0  * Add functions for easy & fast 'valid side' checking (PR #8)
- 2021-05-24  v2.1  * Add API functions 'register_on_tube_update2'
- 2022-01-05  v2.2  * Extend the 'node.param2' support for all 24 possible values
- 2022-03-11  v2.2.1 * Changed to minetest 5.0 translation (#12)


