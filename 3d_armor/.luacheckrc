
unused_args = false

globals = {
	"wieldview",
	"armor",
	"armor_i18n",
	"inventory_plus"
}

read_globals = {
	-- Stdlib
	string = {fields = {"split"}},
	table = {fields = {"copy", "getn"}},

	-- Minetest
	"vector", "ItemStack",
	"dump", "VoxelArea",

	-- deps
	"default",
	"minetest",
	"unified_inventory",
	"intllib",
	"wardrobe",
	"player_monoids",
	"armor_monoid",
	"sfinv",
	"ARMOR_MATERIALS",
	"ARMOR_FIRE_NODES",
	"pova",
	"skins",
	"u_skins"
}
