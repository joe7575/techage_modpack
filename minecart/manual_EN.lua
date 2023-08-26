return {
  titles = {
    "1,Minecart",
    "2,Quick start guide",
    "2,Minecart Blocks",
    "3,Cart",
    "3,Buffer",
    "3,Landmark",
    "3,Hopper",
    "3,Cart pusher",
    "3,Speed limit signs",
    "2,Chat commands",
    "2,Online manual",
  },
  texts = {
    "The mod Minecart has its own carts (called Minecart) in addition to the standard carts.\n"..
    "Minecarts are used for automated item transport on private and public rail networks.\n"..
    "The main features are:\n"..
    "\n"..
    "  - Item transport from station to station\n"..
    "  - Carts can run through unloaded areas (only both stations have to be loaded)\n"..
    "  - Automated loading/unloading of Minecarts by means of the Minecart Hopper\n"..
    "  - The rails can be protected by means of landmarks\n"..
    "\n"..
    "If the mod Techage is available\\, then:\n"..
    "\n"..
    "  - Two additional carts for item and liquid transportation are available\n"..
    "  - Carts can be loaded/unloaded by means of Techage pusher and pumps\n"..
    "\n"..
    "You can:\n"..
    "\n"..
    "  - Enter the cart with a right-click\n"..
    "  - Leave the cart with a jump or a right-click\n"..
    "  - Push/start the cart with a left-click\n"..
    "\n"..
    "But carts have their owner and you can't start\\, stop\\, or remove foreign carts.\n"..
    "Carts can only be started at the buffer. If a cart stops on the way\\,\n"..
    "remove it and place it at the buffer position.\n"..
    "\n"..
    "\n"..
    "\n",
    "  - Place your rails and build a route with two endpoints.\nJunctions are allowed as long as each route has its own start and endpoint.\n"..
    "  - Place a Railway Buffer at both endpoints (buffers are always needed\\,\nthey store the route and timing information).\n"..
    "  - Give both Railway Buffers unique station names\\, like Oxford and Cambridge.\n"..
    "  - Place a Minecart at a buffer and give it a cart number (1..999)\n"..
    "  - Drive from buffer to buffer in both directions using the Minecart(!) to\nrecord the routes (use 'right-left' keys to control the Minecart).\n"..
    "  - Punch the buffers to check the connection data\n(e.g. 'Oxford: connected to Cambridge').\n"..
    "  - Optional: Configure the Minecart waiting time in both buffers.\nThe Minecart will then start automatically after the configured time.\n"..
    "  - Place a Minecart in front of the buffer and check whether it starts\nafter the configured time.\n"..
    "  - Drop items into the Minecart and punch the cart to start it.\n"..
    "  - Dig the cart with 'sneak+click' (as usual). The items will be drop down.\n"..
    "\n"..
    "\n"..
    "\n",
    "\n"..
    "\n",
    "Primary used to transport items. You can drop items into the Minecart and punch the cart to get started. \n"..
    "Sneak+click the cart to get cart and items back.\n"..
    "\n"..
    "\n"..
    "\n",
    "Used as buffer on both rail ends. Needed to be able to record the cart routes.\n"..
    "\n"..
    "\n"..
    "\n",
    "Protect your rails with the Landmarks (one Landmark at least every 16 blocks near the rail.\n"..
    "\n"..
    "\n"..
    "\n",
    "Used to load/unload Minecarts. The Hopper can push/pull items to/from chests\n"..
    "and drop/pickup items to/from Minecarts. To unload a Minecart place the hopper \n"..
    "below the rail. To load the Minecart\\, place the hopper right next to the Minecart.\n"..
    "\n"..
    "\n"..
    "\n",
    "If several carts are running on one route\\, it can happen that a buffer position\n"..
    "is already occupied and one cart therefore stops earlier.\n"..
    "In this case\\, the cart pusher is used to push the cart towards the buffer again.\n"..
    "This block must be placed under the rail at a distance of 2 m in front of the buffer.\n"..
    "\n"..
    "\n"..
    "\n",
    "Limit the cart speed with speed limit signs.\n"..
    "\n"..
    "\n"..
    "\n",
    "  - Command '/mycart <num>' to output cart state and location\n"..
    "  - Command '/stopcart <num>' to retrieve lost carts\n"..
    "\n",
    "A comprehensive manual is available online.\n"..
    "See: https://github.com/joe7575/minecart/wiki\n"..
    "\n",
  },
  images = {
    "minecart_manual_image.png",
    "minecart_manual_image.png",
    "minecart:cart",
    "minecart:cart",
    "minecart:buffer",
    "minecart:landmark",
    "minecart:hopper",
    "minecart:cart_pusher",
    "minecart:speed2",
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
  }
}