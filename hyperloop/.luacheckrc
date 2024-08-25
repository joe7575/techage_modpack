unused_args = false

ignore = {
    "131", -- Unused global variable
    "432", -- Shadowing an upvalue argument
}

read_globals = {
    "core",
    "minetest",
    "default",
    "worldedit",
    "tubelib2",
    "intllib",
    "DIR_DELIM",
    "techage",

    string = {fields = {"split", "trim"}},
    vector = {fields = {"add", "equals", "multiply"}},
    table =  {fields = {"copy", ""}},
}

globals = {
    "hyperloop",
    "ItemStack",
    "screwdriver",
}

