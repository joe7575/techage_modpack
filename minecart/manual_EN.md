# Minecart

The mod Minecart has its own carts (called Minecart) in addition to the standard carts.
Minecarts are used for automated item transport on private and public rail networks.
The main features are:

- Item transport from station to station
- Carts can run through unloaded areas (only both stations have to be loaded)
- Automated loading/unloading of Minecarts by means of the Minecart Hopper
- The rails can be protected by means of landmarks

If the mod Techage is available, then:

- Two additional carts for item and liquid transportation are available
- Carts can be loaded/unloaded by means of Techage pusher and pumps

You can:

- Enter the cart with a right-click
- Leave the cart with a jump or a right-click
- Push/start the cart with a left-click

But carts have their owner and you can't start, stop, or remove foreign carts.
Carts can only be started at the buffer. If a cart stops on the way,
remove it and place it at the buffer position.

[minecart_manual_image.png|image]


## Quick start guide

1. Place your rails and build a route with two endpoints.
   Junctions are allowed as long as each route has its own start and endpoint.
2. Place a Railway Buffer at both endpoints (buffers are always needed,
   they store the route and timing information).
3. Give both Railway Buffers unique station names, like Oxford and Cambridge.
4. Place a Minecart at a buffer and give it a cart number (1..999)
5. Drive from buffer to buffer in both directions using the Minecart(!) to
   record the routes (use 'right-left' keys to control the Minecart).
6. Punch the buffers to check the connection data
   (e.g. 'Oxford: connected to Cambridge').
7. Optional: Configure the Minecart waiting time in both buffers.
   The Minecart will then start automatically after the configured time.
9. Place a Minecart in front of the buffer and check whether it starts
   after the configured time.
10. Drop items into the Minecart and punch the cart to start it.
11. Dig the cart with 'sneak+click' (as usual). The items will be drop down.

[minecart_manual_image.png|image]


## Minecart Blocks

[minecart:cart|image]


### Cart

Primary used to transport items. You can drop items into the Minecart and punch the cart to get started. 
Sneak+click the cart to get cart and items back.

[minecart:cart|image]


### Buffer

Used as buffer on both rail ends. Needed to be able to record the cart routes.

[minecart:buffer|image]


### Landmark

Protect your rails with the Landmarks (one Landmark at least every 16 blocks near the rail.

[minecart:landmark|image]


### Hopper

Used to load/unload Minecarts. The Hopper can push/pull items to/from chests
and drop/pickup items to/from Minecarts. To unload a Minecart place the hopper 
below the rail. To load the Minecart, place the hopper right next to the Minecart.

[minecart:hopper|image]


### Cart pusher

If several carts are running on one route, it can happen that a buffer position
is already occupied and one cart therefore stops earlier.
In this case, the cart pusher is used to push the cart towards the buffer again.
This block must be placed under the rail at a distance of 2 m in front of the buffer.

[minecart:cart_pusher|image]


### Speed limit signs

Limit the cart speed with speed limit signs.

[minecart:speed2|image]


## Chat commands

- Command `/mycart <num>` to output cart state and location
- Command `/stopcart <num>` to retrieve lost carts


## Online manual

A comprehensive manual is available online.
See: https://github.com/joe7575/minecart/wiki