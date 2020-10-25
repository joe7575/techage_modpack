# Player Physics Access Control

To be able to control the access to player physics (like speed, gravity) and privs (like fast, fly)
a common design pattern is used for the following mod-pack mods:

- autobahn (fast, speed)
- towercrane (fly, speed)
- ta4_jetpack (gravity, speed)
- ta4_paraglider
- stamina (resets the gravity/speed cyclically)
- 3d_armor (changes physics based on APi calls)

All of these mods try to change the player physics, which is a common resource and should only be changed by one mod.

This access control design pattern takes care that only one mod at a time is able to change physics or privs.

```lua
local function change_player_physics(player)
	local physics = player:get_physics_override()
	local meta = player:get_meta()
	
	-- Check access conflicts with other mods
	if meta:get_int("player_physics_locked") == 0 then
		meta:set_int("player_physics_locked", 1)

        -- store old values, here speed and gravity
		meta:set_int("mymod_normal_player_speed", physics.speed)
		meta:set_int("mymod_normal_player_gravity", physics.gravity)

		-- do whatever is needed
        
        player:set_physics_override(physics)
        meta:set_int("mymod_is_active", 1)
	end
end

local function restore_player_physics(player)
	local physics = player:get_physics_override()
	local meta = player:get_meta()
	
    if meta:get_int("mymod_is_active") == 1 then
        meta:set_int("mymod_is_active", 0)

        -- restore old values (speed and gravity)
        physics.speed = meta:get_int("mymod_normal_player_speed")
        physics.gravity = meta:get_int("mymod_normal_player_gravity")
		player:set_physics_override(physics)
    end
	meta:set_int("player_physics_locked", 0)
end



minetest.register_on_joinplayer(function(player)
	restore_player_physics(player)
end)

minetest.register_on_respawnplayer(function(player)
	restore_player_physics(player)
end)

-- optional
minetest.register_on_leaveplayer(function(player)
	restore_player_physics(player)
end)

-- optional
minetest.register_on_dieplayer(function(player)
	restore_player_physics(player)
end)
```

