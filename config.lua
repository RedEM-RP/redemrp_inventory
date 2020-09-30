Config = {}

Config.MaxWeight = 24.0

Config.MultiServer = true ---- If you have more than one server with synced DB

Config.Crafting = {


["bread"] = {

items = {
		"empty","empty","empty",
		"wheat","wheat","wheat",
		"empty","empty","empty"
		},
requireJob = "empty",
type = "cooking",
amount = 1,


},

}

Config.Items = {

    ["water"] =
    {
        label = "Water",
        description = "?????????",
        weight = 0.3,
        canBeDropped = true,
        canBeUsed = true,
        requireLvl = 0,
        limit = 32,
        imgsrc = "items/water.png",
        type = "item_standard",

    },

    ["bread"] =
    {
        label = "Bread",
        description = "?????????",
        weight = 0.1,
        canBeDropped = true,
        canBeUsed = true,
        requireLvl = 0,
        limit = 20,
        imgsrc = "items/bread.png",
        type = "item_standard",


    },
	
	["wheat"] =
    {
        label = "Wheat",
        description = "?????????",
        weight = 0.05,
        canBeDropped = true,
        canBeUsed = false,
        requireLvl = 0,
        limit = 64,
        imgsrc = "items/wheat.png",
        type = "item_standard",

    },
	
	["apple"] =
    {
        label = "Apple",
        description = "?????????",
        weight = 0.02,
        canBeDropped = true,
        canBeUsed = true,
        requireLvl = 0,
        limit = 32,
        imgsrc = "items/apple.png",
        type = "item_standard",


    },
	 ["p_baitBread01x"] =
    {
        label = "Przynęta z chleba",
        description = "Przydaje się podczas łowienia mniejszych ryb",
        weight = 0.01,
        canBeDropped = true,
        canBeUsed = true,
        requireLvl = 0,
        limit = 32,
        imgsrc = "items/bread_bait.png",
        type = "item_standard",


    },



    ["p_baitCheese01x"] =
    {
        label = "Przynęta z sera",
        description = "Przydaje się podczas łowienia wielu gatunków ryb",
        weight = 0.01,
        canBeDropped = true,
        canBeUsed = true,
        requireLvl = 0,
        limit = 48,
        imgsrc = "items/cheese_bait.png",
        type = "item_standard",


    },

    ["p_baitCorn01x"] =
    {
        label = "Przynęta z chleba",
        description = "Przydaje się podczas łowienia wielu gatunków ryb",
        weight = 0.01,
        canBeDropped = true,
        canBeUsed = true,
        requireLvl = 0,
        limit = 48,
        imgsrc = "items/corn_bait.png",
        type = "item_standard",


    },
    ["p_baitCricket01x"] =
    {
        label = "Przynęta z krykieta",
        description = "Przydaje się podczas łowienia mniejszych ryb",
        weight = 0.01,
        canBeDropped = true,
        canBeUsed = true,
        requireLvl = 0,
        limit = 32,
        imgsrc = "items/cricket_bait.png",
        type = "item_standard",


    },



    ["p_finishedragonfly01x"] =
    {
        label = "Przynęta na rzeke",
        description = "Przydaje się podczas łowienia ryb na rzece",
        weight = 0.05,
        canBeDropped = true,
        canBeUsed = true,
        requireLvl = 0,
        limit = 5,
        imgsrc = "items/river_bait.png",
        type = "item_standard",


    },


    ["p_FinisdFishlure01x"] =
    {
        label = "Przynęta na jezioro",
        description = "Przydaje się podczas łowienia mniejszych ryb",
        weight = 0.05,
        canBeDropped = true,
        canBeUsed = true,
        requireLvl = 0,
        limit = 5,
        imgsrc = "items/lake_bait.png",
        type = "item_standard",


    },

    ["p_finishdcrawd01x"] =
    {
        label = "Przynęta na bagno",
        description = "Przydaje się podczas łowienia na bagnie",
        weight = 0.05,
        canBeDropped = true,
        canBeUsed = true,
        requireLvl = 0,
        limit = 5,
        imgsrc = "items/swamp_bait.png",
        type = "item_standard",


    },


["WEAPON_FISHINGROD"] =
	{
		label = "Fishingrod",
		description = "?????????",
		weight = 0.9,
		canBeDropped = true,
		requireLvl = 1,
		weaponHash = GetHashKey("WEAPON_FISHINGROD"),
		  imgsrc = "items/WEAPON_FISHINGROD.png",
		type = "item_weapon"
	},
	
	

}
