# Networks [networks]

A library to build and manage networks based on tubelib2 tubes, pipes, or cables.

![networks](https://github.com/joe7575/networks/blob/main/screenshot.png)


### Power Networks

Power networks consists of following node types:

- Generators, nodes providing power
- Consumers, nodes consuming power
- Storage nodes, nodes storing power
- Cables, to build power connections
- Junctions, to connect point to point connection to networks
- Switches, to turn on/off network segments

All storage nodes in a network form a storage system. Storage systems are
required as buffers. Generators "charge" the storage system, consumers
"discharge" the storage system.

Charging the storage system follows a degressive/adaptive charging curve.
When the storage system e.g. is 80% full, the charging load is continuously reduced.
This ensures that all generators are loaded in a balanced manner.

Cables, junctions, and switches can be hidden under blocks (plastering)
and opened again with a tool.
This makes power installations in buildings more realistic.
The mod uses a whitelist for filling material. The function 
`networks.register_filling_items` is used to register node names.


### Liquid Networks

Liquid networks consists of following node types:

- Pumps, nodes pumping liquids from/to tanks
- Tanks, storuing liquids
- Junctions, to connect pipes to networks
- Valves, to turn on/off pipe segments


### Control

In addition to any network the 'control' API can be used to send commands
or request data from nodes, specified via 'node_type'.


### Test Nodes

The file `./test/test_power.lua` contains test nodes of each kind of power nodes.
It can be used to play with the features and to study the use of `networks`.

- [G] a generator, which provides 20 units of power every 2 s
- [C] a consumer, which need 5 units of power every 2 s
- [S] a storage with 500 units capacity

All three nodes can be turned on/off by right-clicking.

- cable node for power transportation
- junction node for power distribution
- a power switch to turn on/off consumers
- a tool to hide/open cables and junctions

The file `./test/test_liquid.lua` contains test nodes of each kind of liquid nodes.

- [P] a pump which pumps 2 items every 2 s
- [T] tree types of tanks (empty, milk, water)
- junction node
- a value to connect/disconnect pipes

The file `./test/test_control.lua` contains server [S] and client [C] nodes
to demonstrate simple on/off commands.

All this testing nodes can be enabled via mod settings `networks_test_enabled = true` in `minetest.conf`




### License

Copyright (C) 2021 Joachim Stolberg  
Code: Licensed under the GNU AGPL version 3 or later. See LICENSE.txt  
Textures: CC BY-SA 3.0  


### Dependencies

Required: tubelib2


### History

**2021-05-23  V0.01**
- First shot

**2021-05-24  V0.02**
- Add switch
- Add tool and hide/open feature
- bug fixes and improvements

**2021-05-25  V0.03**
- Add function `networks.get_power_data`
- bug fixes and improvements

**2021-05-29  V0.04**
- bug fixes and improvements

**2021-05-30  V0.05**
- Change power API

**2021-06-03  V0.06**
- Add 'liquid'
- bug fixes and improvements

**2021-06-04  V0.07**
- Add 'control' API

**2021-07-06  V0.08**
- Add 'transfer' functions to the 'power' API

**2021-07-23  V0.09**
- bug fixes and improvements

**2021-09-18  V0.10**
- Add support for colored cables (PR #1 by Thomas--S)

**2022-01-06  V0.11**
- Support for junction rotation added
