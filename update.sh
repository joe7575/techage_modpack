#!/usr/bin/env bash

declare -A mods

mods[autobahn]=https://github.com/joe7575/autobahn.git
mods[basic_materials]=https://gitlab.com/VanessaE/basic_materials.git
mods[compost]=https://github.com/joe7575/compost.git
mods[hyperloop]=https://github.com/joe7575/Minetest-Hyperloop.git
mods[tubelib2]=https://github.com/joe7575/tubelib2.git
mods[signs_bot]=https://github.com/joe7575/signs_bot.git
mods[minecart]=https://github.com/joe7575/minecart.git
mods[safer_lua]=https://github.com/joe7575/safer_lua.git
mods[techpack_stairway]=https://github.com/joe7575/techpack_stairway.git
mods[lcdlib]=https://github.com/joe7575/lcdlib.git
mods[techage]=https://github.com/joe7575/techage.git
mods[towercrane]=https://github.com/minetest-mods/towercrane.git
mods[unified_inventory]=https://github.com/minetest-mods/unified_inventory.git
mods[datastorage]=https://github.com/minetest-technic/datastorage.git

for mod in "${!mods[@]}"; do
    rm -rf ./$mod
    git clone --single-branch --depth=1 "${mods[$mod]}" $mod
    rm -rf ./$mod/.git
done

git add *
git commit -a -m "built on $(date '+%d/%m/%Y %H:%M:%S')"
