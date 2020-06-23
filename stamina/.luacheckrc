unused_args = false
allow_defined_top = true

read_globals = {
	"DIR_DELIM",
	"minetest",
	"dump",
	"vector", "nodeupdate",
	"VoxelManip", "VoxelArea",
	"PseudoRandom", "ItemStack",
	"intllib",
	"default",
	"armor",
	"player_monoids",
}

globals = {
	minetest = { fields = { "do_item_eat" }},
}

