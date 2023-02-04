--[[

	Minecart
	========

	Copyright (C) 2019-2023 Joachim Stolberg

	MIT
	See license.txt for more information
	
]]--

local minecart_lib = [[
// Minecart library for reading status and distance
// from running carts. To do this, a cart terminal
// must be connected to an I/O Module.

import "lib/techage.c"

var payload[1];
var resp[1];


// Read cart state.
// Parameters:
//  - ip_port: IOM port to the Cart Terminal
//  - card_id: Cart number
// Function returns:
//  - 0 for unknown/missing
//  - 1 for stopped
//  - 2 for running
func mc_get_state(io_port, cart_id) {
  var sts;

  payload[0] = cart_id;
  request_data(io_port, 129, payload, resp);
  if(sts == 0) {
    return resp[0];
  }
  return 0;
}

// Read cart distance.
// Parameters:
//  - ip_port: IOM port to the Cart Terminal
//  - card_id: Cart number
// Function returns the distance between
// Cart Terminal and cart in meter.
func mc_get_distance(io_port, cart_id) {
  var sts;

  payload[0] = cart_id;
  request_data(io_port, 130, payload, resp);
  if(sts == 0) {
    return resp[0];
  }
  return 0;
}
]]

local minecart_demo = [[
import "sys/stdio.asm"
import "sys/os.c"
import "lib/minecart.c"

func init() {
  setstdout(1);  // use terminal window for stdout
  putstr("### Minecart Demo ###\n");
}

func cart_state(io_port, cart_id) {
  putstr("Cart #");
  putnum(cart_id);
  putstr(": state = ");
  putnum(mc_get_state(io_port, cart_id));
  putstr(", distance = ");
  putnum(mc_get_distance(io_port, cart_id));
  putstr("\n");
}

func loop() {
  // Adapt IO port and cart ID to your needs
  cart_state(0, 1);
  sleep(20);
}
]]

minetest.register_on_mods_loaded(function()
	if minetest.global_exists("vm16") and minetest.global_exists("beduino") then
		vm16.register_ro_file("beduino", "lib/minecart.c", minecart_lib)
		vm16.register_ro_file("beduino", "demo/minecart.c", minecart_demo)
	end
end)