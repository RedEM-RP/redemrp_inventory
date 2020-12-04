Config = {}

Config.MaxWeight = 24.0


Config.Crafting = {


["bread"] = {

items = {
		"empty","empty","empty",
		"wheat","wheat, 2","wheat",
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
        label = "Bread Bait",
        description = "?????????",
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
        label = "Cheese Bait",
        description = "?????????",
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
        label = "Corn Bait",
        description = "?????????",
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
        label = "Cricket Bait",
        description = "?????????",
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
        label = "River Bait",
        description = "?????????",
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
        label = "Lake Bait",
        description = "?????????",
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
        label = "Swamp Bait",
        description = "?????????",
        weight = 0.05,
        canBeDropped = true,
        canBeUsed = true,
        requireLvl = 0,
        limit = 5,
        imgsrc = "items/swamp_bait.png",
        type = "item_standard",


    },
	
	["smallfish"] =
    {
        label = "Small Fish",
        description = "?????????",
        weight = 0.3,
        canBeDropped = true,
        canBeUsed = false,
        requireLvl = 0,
        limit = 20,
        imgsrc = "items/smallfish.png",
        type = "item_standard",


    },


    ["mediumfish"] =
    {
        label = "Medium Fish", 
        description = "?????????",
        weight = 2.3,
        canBeDropped = true,
        canBeUsed = false,
        requireLvl = 0,
        limit = 15,
        imgsrc = "items/mediumfish.png",
        type = "item_standard",


    },

    ["largefish"] =
    {
        label = "Large Fish",
        description = "?????????",
        weight = 4.5,
        canBeDropped = true,
        canBeUsed = false,
        requireLvl = 0,
        limit = 10,
        imgsrc = "items/largefish.png",
        type = "item_standard",

    },

    ["blueberry"] =
    {
        label = "Blueberry",
        description = "?????????",
        weight = 0.1,
        canBeDropped = true,
        canBeUsed = true,
        requireLvl = 0,
        limit = 20,
        imgsrc = "items/blueberry.png",
        type = "item_standard",


    },
    ["stick"] =
    {
        label = "Stick",
        description = "?????????",
        weight = 0.02,
        canBeDropped = true,
        canBeUsed = false,
        requireLvl = 0,
        limit = 64,
        imgsrc = "items/stick.png",
        type = "item_standard",


    },

	["WEAPON_MELEE_LANTERN_ELECTRIC"] =
	{
		label = "Electric Lamp",
		description = "A source of light, fire & fun",
		weight = 0.5,
		canBeDropped = true,
		requireLvl = 12,
		weaponHash = GetHashKey("weapon_melee_davy_lantern"),
		  imgsrc = "items/weapon_melee_electric_lantern.png",
		type = "item_weapon",
	},
	
	

["WEAPON_MELEE_TORCH"] =
	{
		label = "Torch",
		description = "Great for travelers scared of the dark",
		weight = 0.4,
		canBeDropped = true,
		requireLvl = 2,
		weaponHash = GetHashKey("WEAPON_MELEE_TORCH"),
		 imgsrc = "items/WEAPON_MELEE_TORCH.png",
		type = "item_weapon",
	},
	


["WEAPON_FISHINGROD"] =
	{
		label = "Rod",
		description = "A mans second best friend",
		weight = 0.9,
		canBeDropped = true,
		requireLvl = 1,
		weaponHash = GetHashKey("WEAPON_FISHINGROD"),
		  imgsrc = "items/WEAPON_FISHINGROD.png",
		type = "item_weapon"
	},
	
	
["WEAPON_MELEE_HATCHET"] =
	{
		label = "Hatchet",
		description = "Uses include: Trees, Building, Fireplaces & Humans",
		weight = 1.0,
		canBeDropped = true,
		requireLvl = 15,
		weaponHash = GetHashKey("WEAPON_MELEE_HATCHET"),
		  imgsrc = "items/WEAPON_MELEE_HATCHET.png",
		type = "item_weapon"
	},


["WEAPON_MELEE_CLEAVER"] =
	{
		label = "Cleaver",
		description = "Keep out of reach of kids",
		weight = 1.0,
		canBeDropped = true,
		requireLvl = 15,
		weaponHash = GetHashKey("WEAPON_MELEE_CLEAVER"),
		  imgsrc = "items/WEAPON_MELEE_CLEAVER.png",
		type = "item_weapon"
	},
	
	
["WEAPON_MELEE_KNIFE"] =
	{
		label = "Knife",
		description = "Thats not a knife, this is a knife.",
		weight = 0.5,
		canBeDropped = true,
		requireLvl = 2,
		weaponHash = GetHashKey("WEAPON_MELEE_KNIFE"),
		  imgsrc = "items/WEAPON_MELEE_KNIFE.png",
		type = "item_weapon"
	},
	
	
	
["WEAPON_THROWN_THROWING_KNIVES"] =
	{
		label = "Throwing Knives",
		description = "Throw me, ill hurt.",
		weight = 0.2,
		canBeDropped = true,
		requireLvl = 2,
		weaponHash = GetHashKey("WEAPON_THROWN_THROWING_KNIVES"),
		  imgsrc = "items/WEAPON_THROWN_THROWING_KNIVES.png",
		type = "item_weapon"
	},
	
	
	
["WEAPON_MELEE_KNIFE_MINER"] =
	{
		label = "Mining Knife",
		description = "An old mining knife, quite large and heavy",
		weight = 0.7,
		canBeDropped = true,
		requireLvl = 5,
		weaponHash = GetHashKey("WEAPON_MELEE_KNIFE_MINER"),
		  imgsrc = "items/WEAPON_MELEE_KNIFE_MINER.png",
		type = "item_weapon"
	},


["WEAPON_MELEE_KNIFE_VAMPIRE"] =
	{
		label = "Decorated Dagger",
		description = "A symbol of designer tastes",
		weight = 1.0,
		canBeDropped = true,
		requireLvl = 20,
		weaponHash = GetHashKey("WEAPON_MELEE_KNIFE_VAMPIRE"),
		  imgsrc = "items/WEAPON_MELEE_KNIFE_VAMPIRE.png",
		type = "item_weapon"
	},
	
	
	
["WEAPON_LASSO"] =
	{
		label = "Lasso",
		description = "Capture, drag & bind.",
		weight = 0.6,
		canBeDropped = true,
		requireLvl = 4,
		weaponHash = GetHashKey("WEAPON_LASSO"),
		  imgsrc = "items/WEAPON_LASSO.png",
		type = "item_weapon"
	},
	
	
["WEAPON_THROWN_TOMAHAWK"] =
	{
		label = "Tomahawk",
		description = "The weapon of the Native tribes.",
		weight = 0.4,
		canBeDropped = true,
		requireLvl = 18,
		weaponHash = GetHashKey("WEAPON_THROWN_TOMAHAWK"),
		  imgsrc = "items/WEAPON_THROWN_TOMAHAWK.png",
		type = "item_weapon"
	},
	
	
	
["WEAPON_PISTOL_M1899"] =
	{
		label = "Pistol M1899",
		description = "A standard cost effective killing machine",
		weight = 0.8,
		canBeDropped = true,
		requireLvl = 30,
		weaponHash = GetHashKey("WEAPON_PISTOL_M1899"),
		  imgsrc = "items/WEAPON_PISTOL_M1899.png",
		type = "item_weapon"
	},


["WEAPON_PISTOL_MAUSER"] =
	{
		label = "Pistol Mauser",
		description = "A must for any advanced warfare",
		weight = 0.6,
		canBeDropped = true,
		requireLvl = 21,
		weaponHash = GetHashKey("WEAPON_PISTOL_MAUSER"),
		  imgsrc = "items/WEAPON_PISTOL_MAUSER.png",
		type = "item_weapon"
	},
	
	
["WEAPON_PISTOL_MAUSER_DRUNK"] =
	{
		label = "Decorated Mauser",
		description = "Gold, silver & metal... what a treat",
		weight = 0.8,
		canBeDropped = true,
		requireLvl = 20,
		weaponHash = GetHashKey("WEAPON_PISTOL_MAUSER_DRUNK"),
		  imgsrc = "items/WEAPON_PISTOL_MAUSER.png",
		type = "item_weapon"
	},
	
	
	
["WEAPON_PISTOL_SEMIAUTO"] =
	{
		label = "Pistol Semi-Automatic",
		description = "Goes bang more then once",
		weight = 0.6,
		canBeDropped = true,
		requireLvl = 16,
		weaponHash = GetHashKey("WEAPON_PISTOL_SEMIAUTO"),
		  imgsrc = "items/WEAPON_PISTOL_SEMIAUTO.png",
		type = "item_weapon"
	},
	
	
["WEAPON_PISTOL_VOLCANIC"] =
	{
		label = "Pistol Volcanic",
		description = "WARNING: Does not shoot lava",
		weight = 0.7,
		canBeDropped = true,
		requireLvl = 14,
		weaponHash = GetHashKey("WEAPON_PISTOL_VOLCANIC"),
		  imgsrc = "items/WEAPON_PISTOL_VOLCANIC.png",
		type = "item_weapon"
	},
	
	
["WEAPON_REPEATER_CARBINE"] =
	{
		label = "Repeated Carbine",
		description = "Medium range, high damage.",
		weight = 2.0,
		canBeDropped = true,
		requireLvl = 6,
		weaponHash = GetHashKey("WEAPON_REPEATER_CARBINE"),
		  imgsrc = "items/WEAPON_REPEATER_CARBINE.png",
		type = "item_weapon"
	},
	
	
["WEAPON_REPEATER_EVANS"] =
	{
		label = "Repeater Evans",
		description = "A feat in weapon mechanics",
		weight = 2.5,
		canBeDropped = true,
		requireLvl = 20,
		weaponHash = GetHashKey("WEAPON_REPEATER_EVANS"),
		  imgsrc = "items/WEAPON_REPEATER_CARBINE.png",
		type = "item_weapon"
	},
	
	
["WEAPON_REPEATER_HENRY"] =
	{
		label = "Litchfield Bolt-Action Rifle",
		description = "Great range & accuracy",
		weight = 2.3,
		canBeDropped = true,
		requireLvl = 22,
		weaponHash = GetHashKey("WEAPON_REPEATER_HENRY"),
		  imgsrc = "items/WEAPON_REPEATER_HENRY.png",
		type = "item_weapon"
	},
	
	
	
["WEAPON_RIFLE_VARMINT"] =
	{
		label = "Light Rifle",
		description = "Ride & Shoot!",
		weight = 1.5,
		canBeDropped = true,
		requireLvl = 14,
		weaponHash = GetHashKey("WEAPON_RIFLE_VARMINT"),
		  imgsrc = "items/WEAPON_REPEATER_HENRY.png",
		type = "item_weapon"
	},
	
	

["WEAPON_REPEATER_WINCHESTER"] =
	{
		label = "Lancaster Bolt-Action Rifle",
		description = "The famous lancaster",
		weight = 1.9,
		canBeDropped = true,
		requireLvl = 26,
		weaponHash = GetHashKey("WEAPON_REPEATER_WINCHESTER"),
		  imgsrc = "items/weapon_repeater_lancaster.png",
		type = "item_weapon"
	},
	

["WEAPON_REVOLVER_CATTLEMAN"] =
	{
		label = "Revolver Cattleman",
		description = "Its high noon!",
		weight = 0.4,
		canBeDropped = true,
		requireLvl = 2,
		weaponHash = GetHashKey("WEAPON_REVOLVER_CATTLEMAN"),
		  imgsrc = "items/WEAPON_REVOLVER_CATTLEMAN.png",
		type = "item_weapon"
	},
	
	

["WEAPON_REVOLVER_CATTLEMAN_JOHN"] =
	{
		label = "Revolver Cattleman",
		description = "Its high noon!",
		weight = 0.5,
		canBeDropped = true,
		requireLvl = 2,
		weaponHash = GetHashKey("WEAPON_REVOLVER_CATTLEMAN_JOHN"),
		  imgsrc = "items/WEAPON_REVOLVER_CATTLEMAN.png",
		type = "item_weapon"
	},
	

["WEAPON_REVOLVER_CATTLEMAN_MEXICAN"] =
	{
		label = "Revolver Cattleman",
		description = "Its high noon!",
		weight = 0.5,
		canBeDropped = true,
		requireLvl = 2,
		weaponHash = GetHashKey("WEAPON_REVOLVER_CATTLEMAN_MEXICAN"),
		  imgsrc = "items/WEAPON_REVOLVER_CATTLEMAN.png",
		type = "item_weapon"
	},


["WEAPON_REVOLVER_DOUBLEACTION"] =
	{
		label = "Double Action Revolver",
		description = "Double the action, same weight.",
		weight = 0.8,
		canBeDropped = true,
		requireLvl = 25,
		weaponHash = GetHashKey("WEAPON_REVOLVER_DOUBLEACTION"),
		  imgsrc = "items/WEAPON_REVOLVER_DOUBLEACTION.png",
		type = "item_weapon"
	},

	
	
["WEAPON_REVOLVER_DOUBLEACTION_EXOTIC"] =
	{
		label = "Exotic Double Action Revolver",
		description = "Just a bit more exotic*",
		weight = 0.8,
		canBeDropped = true,
		requireLvl = 12,
		weaponHash = GetHashKey("WEAPON_REVOLVER_DOUBLEACTION_EXOTIC"),
		  imgsrc = "items/WEAPON_REVOLVER_DOUBLEACTION.png",
		type = "item_weapon"
	},



["WEAPON_REVOLVER_DOUBLEACTION_GAMBLER"] =
	{
		label = "Self-Locking Revolver",
		description = "Dont forget to lock...",
		weight = 0.8,
		canBeDropped = true,
		requireLvl = 12,
		weaponHash = GetHashKey("WEAPON_REVOLVER_DOUBLEACTION_GAMBLER"),
		  imgsrc = "items/WEAPON_REVOLVER_DOUBLEACTION.png",
		type = "item_weapon"
	},
	
	

["WEAPON_REVOLVER_LEMAT"] =
	{
		label = "LeMat Revolver",
		description = "I think its french, it does go bang!",
		weight = 0.9,
		canBeDropped = true,
		requireLvl = 12,
		weaponHash = GetHashKey("WEAPON_REVOLVER_LEMAT"),
		  imgsrc = "items/WEAPON_REVOLVER_LEMAT.png",
		type = "item_weapon"
	},
	
	
	
["WEAPON_REVOLVER_SCHOFIELD"] =
	{
		label = "Revolver Schofield",
		description = "Great for prison breaks",
		weight = 0.7,
		canBeDropped = true,
		requireLvl = 20,
		weaponHash = GetHashKey("WEAPON_REVOLVER_SCHOFIELD"),
		  imgsrc = "items/WEAPON_REVOLVER_SCHOFIELD.png",
		type = "item_weapon"
	},
	
	

["WEAPON_REVOLVER_NAVY"] =
	{
		label = "Navy Revolver",
		description = "Just a typical revolver that is Navy",
		weight = 0.8,
		canBeDropped = true,
		requireLvl = 30,
		weaponHash = GetHashKey("WEAPON_REVOLVER_NAVY"),
		  imgsrc = "items/WEAPON_REVOLVER_NAVY.png",
		type = "item_weapon"
	},
	
	

["WEAPON_REVOLVER_SCHOFIELD_CALLOWAY"] =
	{
		label = "Engraved Schofield",
		description = "Unreadable engravings",
		weight = 0.6,
		canBeDropped = true,
		requireLvl = 15,
		weaponHash = GetHashKey("WEAPON_REVOLVER_SCHOFIELD_CALLOWAY"),
		  imgsrc = "items/WEAPON_REVOLVER_SCHOFIELD.png",
		type = "item_weapon"
	},
	
	

["WEAPON_RIFLE_BOLTACTION"] =
	{
		label = "Bolt Action Rifle",
		description = "Jams a lot, but works well when it doesnt.",
		weight = 2.3,
		canBeDropped = true,
		requireLvl = 30,
		weaponHash = GetHashKey("WEAPON_RIFLE_BOLTACTION"),
		  imgsrc = "items/WEAPON_RIFLE_BOLTACTION.png",
		type = "item_weapon"
	},
	
	
["WEAPON_SNIPERRIFLE_CARCANO"] =
	{
		label = "Carcano Rifle",
		description = "Range is the key!",
		weight = 4.0,
		canBeDropped = true,
		requireLvl = 60,
		weaponHash = GetHashKey("WEAPON_SNIPERRIFLE_CARCANO"),
		  imgsrc = "items/WEAPON_SNIPERRIFLE_CARCANO.png",
		type = "item_weapon"
	},
	
	
["WEAPON_SNIPERRIFLE_ROLLINGBLOCK"] =
	{
		label = "Rotary Rifle",
		description = "Line em up 500 metres away!",
		weight = 4.0,
		canBeDropped = true,
		requireLvl = 80,
		weaponHash = GetHashKey("WEAPON_SNIPERRIFLE_ROLLINGBLOCK"),
		  imgsrc = "items/WEAPON_SNIPERRIFLE_ROLLINGBLOCK.png",
		type = "item_weapon"
	},
	
	
["WEAPON_RIFLE_SPRINGFIELD"] =
	{
		label = "Springfield Rifle",
		description = "Military standard",
		weight = 2.0,
		canBeDropped = true,
		requireLvl = 32,
		weaponHash = GetHashKey("WEAPON_RIFLE_SPRINGFIELD"),
		  imgsrc = "items/WEAPON_RIFLE_SPRINGFIELD.png",
		type = "item_weapon"
	},
	
	
	
["WEAPON_SHOTGUN_DOUBLEBARREL"] =
	{
		label = "Double Action Shotgun",
		description = "Poorly designed, does the trick though.",
		weight = 3.0,
		canBeDropped = true,
		requireLvl = 13,
		weaponHash = GetHashKey("WEAPON_SHOTGUN_DOUBLEBARREL"),
		  imgsrc = "items/WEAPON_SHOTGUN_DOUBLEBARREL.png",
		type = "item_weapon"
	},
	
	
["WEAPON_SHOTGUN_DOUBLEBARREL_EXOTIC"] =
	{
		label = "Decorated Gun",
		description = "Close range death machine",
		weight = 3.0,
		canBeDropped = true,
		requireLvl = 18,
		weaponHash = GetHashKey("WEAPON_SHOTGUN_DOUBLEBARREL_EXOTIC"),
		  imgsrc = "items/WEAPON_SHOTGUN_DOUBLEBARREL.png",
		type = "item_weapon"
	},


["WEAPON_SHOTGUN_PUMP"] =
	{
		label = "Pump Shotgun",
		description = "WARNING: May mutilate",
		weight = 2.5,
		canBeDropped = true,
		requireLvl = 40,
		weaponHash = GetHashKey("WEAPON_SHOTGUN_PUMP"),
		  imgsrc = "items/WEAPON_SHOTGUN_PUMP.png",
		type = "item_weapon"
	},
	
	
["WEAPON_SHOTGUN_REPEATING"] =
	{
		label = "Repeating Shotgun",
		description = "Dont shoot too fast, you might jam it!",
		weight = 2.0,
		canBeDropped = true,
		requireLvl = 80,
		weaponHash = GetHashKey("WEAPON_SHOTGUN_REPEATING"),
		  imgsrc = "items/WEAPON_SHOTGUN_REPEATING.png",
		type = "item_weapon"
	},



["WEAPON_SHOTGUN_SAWEDOFF"] =
	{
		label = "Sawn-Off Shotgun",
		description = "Compact, high damage & close range",
		weight = 1.2,
		canBeDropped = true,
		requireLvl = 20,
		weaponHash = GetHashKey("WEAPON_SHOTGUN_SAWEDOFF"),
		  imgsrc = "items/WEAPON_SHOTGUN_SAWEDOFF.png",
		type = "item_weapon"
	},
	
	

["WEAPON_SHOTGUN_SEMIAUTO"] =
	{
		label = "Semi-Automatic Shotgun",
		description = "This may just save your life one day",
		weight = 2.2,
		canBeDropped = true,
		requireLvl = 51,
		weaponHash = GetHashKey("WEAPON_SHOTGUN_SEMIAUTO"),
		  imgsrc = "items/WEAPON_SHOTGUN_SEMIAUTO.png",
		type = "item_weapon"
	},
	
	
	
["WEAPON_BOW"] =
	{
		label = "Simple Bow",
		description = "A hunting bow",
		weight = 0.7,
		canBeDropped = true,
		requireLvl = 1,
		weaponHash = GetHashKey("WEAPON_BOW"),
		  imgsrc = "items/WEAPON_BOW.png",
		type = "item_weapon"
	},
	
	
["WEAPON_THROWN_DYNAMITE"] =
	{
		label = "Dynamite",
		description = "This baby will blow up in 3 seconds...",
		weight = 0.3,
		canBeDropped = true,
		canBeUsed = false,
		requireLvl = 35,
		limit = 8,
		imgsrc = "items/WEAPON_THROWN_DYNAMITE.png",
		type = "item_standard"
	},
	
	
	
["WEAPON_THROWN_MOLOTOV"] =
	{
		label = "Molotov",
		description = "A poor mans grenade",
		weight = 0.5,
		canBeDropped = true,
		requireLvl = 30,
		weaponHash = GetHashKey("WEAPON_THROWN_MOLOTOV"),
		  imgsrc = "items/WEAPON_THROWN_MOLOTOV.png",
		type = "item_weapon"
	},
	
["WEAPON_KIT_BINOCULARS"] =
	{
		label = "Binoculars",
		description = "Left lens quite scratched...",
		weight = 0.5,
		canBeDropped = true,
		requireLvl = 30,
		weaponHash = GetHashKey("WEAPON_KIT_BINOCULARS"),
		  imgsrc = "items/WEAPON_KIT_BINOCULARS.png",
		type = "item_weapon"
	},

	

}
