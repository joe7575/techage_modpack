Minecart
========

**Minecart, the lean railway transportation automation system**


Browse on: [GitHub](https://github.com/joe7575/minecart)

Download: [GitHub](https://github.com/joe7575/minecart/archive/master.zip)

![minecart](https://github.com/joe7575/minecart/blob/master/screenshot.png)


Minecart is based on carts, which is
based almost entirely on the mod boost_cart [1], which
itself is based on (and fully compatible with) the carts mod [2].

The model was originally designed by stujones11 [3] (CC-0).

Cart textures are based on original work from PixelBOX by Gambit (permissive
license).


1. https://github.com/SmallJoker/boost_cart/
2. https://github.com/PilzAdam/carts/
3. https://github.com/stujones11/railcart/


Minecart Features
-----------------

The mod Minecart has its own cart (called Minecart) in addition to the standard cart.
Minecarts are used for automated item transport on private and public rail networks.
The mod features are:
- a fast cart for your railway or roller coaster (up to 8 m/s!)
- boost rails and speed limit signs
- rail junction switching with the 'right-left' walking keys
- configurable timetables and routes for Minecarts
- automated loading/unloading of Minecarts by means of a Minecart Hopper
- rail network protection based on protection blocks called Land Marks
- protection of minecarts and cargo
- Minecarts run through unloaded areas (only the stations/hopper have to be loaded)
- Extra Minecart privs for rail workers
- Ingame documentation (German and English), based on the mod "doc"
- API to register carts from other mods
- chat command `/mycart <num>` to output cart state and location
- Command interface for Techage (Lua and ICTA) and for Beduino Controllers


Technical Background
--------------------

The Minecart can "run" through unloaded areas. This is done by means of recorded 
and stored routes. If the area is unloaded the cart will simply follow the 
predefined route until an area is loaded again. In this case the cart will be 
spawned and run as usual.


Introduction
------------

1. Place your rails and build a route with two endpoints. Junctions are allowed 
   as long as each route has its own start and endpoint.
2. Place a Railway Buffer at both endpoints. (buffers are always needed, 
   they store the route and timing information)
3. Give both Railway Buffers unique station names, like Oxford and Cambridge
4. Place a Minecart at a buffer and give it a cart number (1..999)
5. Drive from buffer to buffer in both directions using the Minecart(!) to record the 
   routes (use 'right-left' keys to control the Minecart)
6. Punch the buffers to check the connection data (e.g. "Oxford: connected to Cambridge")
7. Optional: Configure the Minecart waiting time in both buffers. The Minecart
   will then start automatically after the configured time
8. Optional: Protect your rail network with the Protection Landmarks (one Landmark 
   at least every 16 nodes/meters)
9. Place a Minecart in front of the buffer and check whether it starts after the 
   configured time
10. Check the cart state via the chat command: `/mycart <num>`
    `<num>` is the cart number, or get a list of carts with `/mycart`
11. Drop items into the Minecart and punch the cart to start it, or "sneak+click" the 
    Minecart to get cart and items back
12. Dig the cart with 'sneak+click' (as usual). The items will be drop down.
13. To retrieve lost carts, use the chat command: /stopcart <num>



## Manual

see [Wiki](https://github.com/joe7575/minecart/wiki)



## Command Interface

### Techage ICTA Controller

The ICTA Controller support the conditions:

- "read cart state" (function returns "stopped" or "running")
- "read cart location" (function returns the distance or the station/buffer name)

See help page of the ICTA controller block.

### Techage Lua Controller

The Lua controller support the functions:

- `$cart_state(num)`  (function returns "stopped" or "running")
- `$cart_location(num)`  (function returns the distance or the station/buffer name)

See help page of the Lua controller block.

### Cart Terminal

The Cart Terminal has a Techage command interface with the commands:

| Command    | Data       | Description                                             |
| ---------- | ---------- | ------------------------------------------------------- |
| `state`    | \<cart-ID> | Returns `unknown`, `stopped`, or `running`              |
| `distance` | \<cart-ID> | Returns the distance from the cart to the Cart Terminal |

### Beduino Controller

The Cart Terminal has a Beduino command interface with the commands:

| Command  | Topic | Data      | Response   | Description                                             |
| -------- | ----- | --------- | ---------- | ------------------------------------------------------- |
| State    | 129   | [cart-id] | [state]    | Returns 0 = UNKNOWN, 1 = STOPPED, 2 = RUNNING           |
| Distance | 130   | [cart-id] | [distance] | Returns the distance from the cart to the Cart Terminal |




History
-------

2019-04-19  v0.01  first commit  
2019-04-21  v0.02  functional, with junctions support  
2019-04-23  v0.03  bug fixes and improvements  
2019-04-25  v0.04  Landmarks and Minecart protection added  
2019-05-04  v0.05  Route recording protection added  
2019-05-22  v0.06  Pick up items from a cart improved  
2019-06-23  v0.07  'doc' mod support and German translation added  
2020-01-04  v1.00  Hopper added, buffer improved  
2020-02-09  v1.01  cart loading bugfix  
2020-02-24  v1.02  Hopper improved  
2020-03-05  v1.03  Hopper again improved  
2020-03-28  v1.04  cart unloading bugfix  
2020-05-14  v1.05  API changed to be able to register carts  
2020-06-14  v1.06  API changed and chat command added  
2020-06-27  v1.07  Route storage and cart command bugfixes  
2020-07-24  V1.08  Adapted to new techage ICTA style  
2020-08-14  V1.09  Hopper support for digtron, protector:chest and default:furnace added    
2020-11-12  V1.10  Make carts more robust against server lag  
2021-04-10  V2.00  Complete revision to make carts robust against server load/lag,  
                   Speed limit signs and cart terminal added  
2021-09-02  V2.01  Chat command /stopcart added  
2021-10-18  V2.02  Cart reproduction bug fixed  
2023-01-04  V2.03  Techage and Beduino command interface added
2023-02-05  V2.04  New API functions added, EOL blanks removed