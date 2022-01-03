# ta4_addons

An extension mod for Minetest's [techage](https://github.com/joe7575/techage) mod to provide more TA4 devices.

Currently, the following devices are implemented:

- Touchscreen

## License

Copyright (C) 2020-2021 Joachim Stolberg  
Copyright (C) 2020-2021 Thomas-S

### Code
Licensed under the GNU AGPL version 3 or later. See `LICENSE.txt`.

The only exception is the file `markdown2lua.py` (by Joachim Stolberg), which is licensed under the GNU GPL version 3 or later.
See `LICENSE_GPL.txt`.
It is taken from the [ta4_jetpack](https://github.com/joe7575/ta4_jetpack) mod.

### Textures

`ta4_addons_touchscreen.png`:
Based on [techage_display.png](https://github.com/joe7575/techage/blob/master/textures/techage_display.png) by Joachim Stolberg, published under the CC BY-SA 3.0 license.
Modifications were made by Thomas-S.

`ta4_addons_touchscreen_inventory.png`, `ta4_addons_matrix_screen_inventory.png`, `ta4_addons_appl_matrix_screen.png`:
Based on [techage_display_inventory.png](https://github.com/joe7575/techage/blob/master/textures/techage_display_inventory.png) by Joachim Stolberg, published  under the CC BY-SA 3.0 license.
Modifications were made by Thomas-S.

Everything else:
CC BY-SA 3.0 by Thomas-S


## Example Program for the Lua Controller

**Init:**

```lua
$events(true)
$loopcycle(0)

TOUCHSCREEN_NUM = 338

counter = 1

$send_cmnd(TOUCHSCREEN_NUM, "remove_content")

res = $send_cmnd(TOUCHSCREEN_NUM, "add_content", Store("type", "button", "w", 5, "label", counter))
res2 = $send_cmnd(TOUCHSCREEN_NUM, "add_content", Store("type", "button", "w", 5, "y", 2, "label", counter))

$print("ID: "..res)
```

**Loop:**

```lua
local num,msg = $get_msg(true)

if num == tostring(TOUCHSCREEN_NUM) and msg.next then
    for k,v in msg.next() do
        if k == "button" then
            counter = counter + 1
            $print(res)
            $send_cmnd(TOUCHSCREEN_NUM, "update_content", Store("type", "button", "w", "5", "label", counter, "id", res))
            if counter > 10 then
                $send_cmnd(TOUCHSCREEN_NUM, "remove_content", Store("id", res2))
            else
                $send_cmnd(TOUCHSCREEN_NUM, "update_content", Store("type", "button", "w", "5", "y", 2, "label", counter, "id", res2))
            end
        end
        $print(k..": "..v)
        $display(TOUCHSCREEN_NUM, 0, k)
        $display(TOUCHSCREEN_NUM, 0, v)
    end
end
```

