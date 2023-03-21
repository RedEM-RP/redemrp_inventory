Config = {}

Config.MaxWeight = 24.0 -- kg

Config.Crafting = {
    ["bandage"] = {
        items = {
            "empty","empty","empty",
            "cotton,3","purealcohol","empty",
            "empty","empty","empty"
        },
        requireJob = { "doctor" },
    },

    ["mbandage"] = {
        items = {
            "empty","empty","empty",
            "cotton,3","purealcohol,2","ginseng",
            "empty","empty","empty"
        },
        requireId = "cooking",
        requireJob = { "doctor" },
    },


    -------- cooking
    --
    --

    
    ["bread"] = {
        items = {
            "empty","flour","empty",
            "empty","water","empty",
            "empty","empty","empty"
        },
        requireId = "cooking",
    },
}

Config.Items = {
    ["water"] = {
        label = "Water",
        description = "Some refreshing water to keep you hydrated",
        weight = 0.01,
        canBeDropped = true,
        canBeUsed = true,
        limit = 200,
        imgsrc = "items/water.png",
        type = "item_standard"
    },
    ["bandage"] = {
        label = "Bandage",
        description = "A bandage to heal wounds and restore health",
        weight = 0.2,
        canBeDropped = true,
        canBeUsed = true,
        limit = 100,
        imgsrc = "items/bandage.png",
        type = "item_standard"
    },
    ["mbandage"] = {
        label = "Medicated Bandage",
        description = "A medicated bandage to heal wounds and restore health faster",
        weight = 0.2,
        canBeDropped = true,
        canBeUsed = true,
        limit = 100,
        imgsrc = "items/mbandage.png",
        type = "item_standard"
    },
    ["WEAPON_REVOLVER_CATTLEMAN"] = {
        label = "Cattleman Revolver",
        description = "Cattleman Revolver",
        weight = 0.5,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_REVOLVER_CATTLEMAN"),
        imgsrc = "items/WEAPON_REVOLVER_CATTLEMAN.png",
        type = "item_weapon"
    },
    ["WEAPON_REVOLVER_DOUBLEACTION"] = {
        label = "DoubleAction",
        description = "DoubleAction",
        weight = 0.5,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_REVOLVER_DOUBLEACTION"),
        imgsrc = "items/WEAPON_REVOLVER_DOUBLEACTION.png",
        type = "item_weapon"
    },
    ["WEAPON_REVOLVER_NAVY"] = {
        label = "Navy Revolver",
        description = "Navy Revolver",
        weight = 0.5,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_REVOLVER_NAVY"),
        imgsrc = "items/weapon_revolver_navy.png",
        type = "item_weapon",
    },
    ["WEAPON_PISTOL_VOLCANIC"] = {
        label = "Volcanic",
        description = "Volcanic",
        weight = 0.5,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_PISTOL_VOLCANIC"),
        imgsrc = "items/WEAPON_PISTOL_VOLCANIC.png",
        type = "item_weapon"
    },
    ["WEAPON_PISTOL_SEMIAUTO"] = {
        label = "SemiAuto",
        description = "SemiAuto",
        weight = 0.5,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_PISTOL_SEMIAUTO"),
        imgsrc = "items/WEAPON_PISTOL_SEMIAUTO.png",
        type = "item_weapon"
    },
    ["WEAPON_PISTOL_MAUSER"] ={
        label = "Mauser",
        description = "Mauser",
        weight = 0.5,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_PISTOL_MAUSER"),
        imgsrc = "items/WEAPON_PISTOL_MAUSER.png",
        type = "item_weapon"
    },
    ["WEAPON_PISTOL_M1899"] ={
        label = "M1899",
        description = "M1899",
        weight = 0.5,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_PISTOL_M1899"),
        imgsrc = "items/m1899.png",
        type = "item_weapon"
    },
    ["WEAPON_REVOLVER_LEMAT"] ={
        label = "Lemat",
        description = "Lemat",
        weight = 0.5,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_REVOLVER_LEMAT"),
        imgsrc = "items/WEAPON_REVOLVER_LEMAT.png",
        type = "item_weapon"
    },
    ["WEAPON_REVOLVER_SCHOFIELD"] = {
        label = "Schofield",
        description = "Schofield",
        weight = 0.7,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_REVOLVER_SCHOFIELD"),
        imgsrc = "items/WEAPON_REVOLVER_SCHOFIELD.png",
        type = "item_weapon"
    },
    --REAPEATERS
    ["WEAPON_REPEATER_CARBINE"] = {
        label = "Carbine",
        description = "Carbine",
        weight = 0.9,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_REPEATER_CARBINE"),
        imgsrc = "items/WEAPON_REPEATER_CARBINE.png",
        type = "item_weapon"
    },
    ["WEAPON_REPEATER_EVANS"] = {
        label = "Evans",
        description = "Evans",
        weight = 0.9,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_REPEATER_EVANS"),
        imgsrc = "items/WEAPON_REPEATER_EVANS.png",
        type = "item_weapon"
    },
    ["WEAPON_REPEATER_HENRY"] = {
        label = "Henry",
        description = "Henry",
        weight = 0.9,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_REPEATER_HENRY"),
        imgsrc = "items/WEAPON_REPEATER_HENRY.png",
        type = "item_weapon"
    },
    ["WEAPON_REPEATER_WINCHESTER"] = {
        label = "Winchester",
        description = "Winchester",
        weight = 0.9,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_REPEATER_WINCHESTER"),
        imgsrc = "items/WEAPON_REPEATER_LANCASTER.png",
        type = "item_weapon"
    },
    --RIFLES
    ["WEAPON_RIFLE_VARMINT"] = {
        label = "Varmint",
        description = "Varmint",
        weight = 0.9,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_RIFLE_VARMINT"),
        imgsrc = "items/WEAPON_RIFLE_VARMINT.png",
        type = "item_weapon"
    },
    ["WEAPON_RIFLE_BOLTACTION"] = {
        label = "Bolt action",
        description = "Bolt action",
        weight = 0.9,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_RIFLE_BOLTACTION"),
        imgsrc = "items/WEAPON_RIFLE_BOLTACTION.png",
        type = "item_weapon"
    },
    ["WEAPON_SNIPERRIFLE_CARCANO"] = {
        label = "Carcano",
        description = "Carcano",
        weight = 0.9,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_SNIPERRIFLE_CARCANO"),
        imgsrc = "items/WEAPON_SNIPERRIFLE_CARCANO.png",
        type = "item_weapon"
    },
    ["WEAPON_SNIPERRIFLE_ROLLINGBLOCK"] = {
        label = "Rolling block",
        description = "Rolling block",
        weight = 0.9,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_SNIPERRIFLE_ROLLINGBLOCK"),
        imgsrc = "items/WEAPON_SNIPERRIFLE_ROLLINGBLOCK.png",
        type = "item_weapon"
    },
    ["WEAPON_RIFLE_SPRINGFIELD"] = {
        label = "Springfield",
        description = "Springfield",
        weight = 0.9,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_RIFLE_SPRINGFIELD"),
        imgsrc = "items/WEAPON_RIFLE_SPRINGFIELD.png",
        type = "item_weapon"
    },
    --SHOTGUNS
    ["WEAPON_SHOTGUN_PUMP"] = {
        label = "Pump",
        description = "Pump",
        weight = 0.9,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_SHOTGUN_PUMP"),
        imgsrc = "items/WEAPON_SHOTGUN_PUMP.png",
        type = "item_weapon"
    },
    ["WEAPON_SHOTGUN_REPEATING"] = {
        label = "Repeating shotgun",
        description = "Repeating shotgun",
        weight = 0.9,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_SHOTGUN_REPEATING"),
        imgsrc = "items/WEAPON_SHOTGUN_REPEATING.png",
        type = "item_weapon"
    },
    ["WEAPON_SHOTGUN_DOUBLEBARREL"] = {
        label = "Doublebarrel",
        description = "Doublebarrel",
        weight = 0.9,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_SHOTGUN_DOUBLEBARREL"),
        imgsrc = "items/WEAPON_SHOTGUN_DOUBLEBARREL.png",
        type = "item_weapon"
    },
    ["WEAPON_SHOTGUN_SAWEDOFF"] = {
        label = "Sawed off",
        description = "Sawed off",
        weight = 0.9,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_SHOTGUN_SAWEDOFF"),
        imgsrc = "items/WEAPON_SHOTGUN_SAWEDOFF.png",
        type = "item_weapon"
    },
    ["WEAPON_SHOTGUN_SEMIAUTO"] = {
        label = "Semiauto Shotgun",
        description = "Semiauto Shotgun",
        weight = 0.9,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_SHOTGUN_SEMIAUTO"),
        imgsrc = "items/WEAPON_SHOTGUN_SEMIAUTO.png",
        type = "item_weapon"
    },
    --MELEE WEAPONS
    ["WEAPON_MELEE_HATCHET_HUNTER"] =
	{
		label = "Hunter Hatchet",
		description = "Hunting Wild Animals",
		weight = 1.0,
		canBeDropped = true,
		requireLvl = 1,
		weaponHash = GetHashKey("WEAPON_MELEE_HATCHET_HUNTER"),
		  imgsrc = "items/WEAPON_MELEE_HATCHET_HUNTER.png",
		type = "item_weapon"
	},
    ["WEAPON_MELEE_HATCHET_DOUBLE_BIT"] =
	{
		label = "Double Bit Hatchet",
		description = "Hunting Wild Animals",
		weight = 1.0,
		canBeDropped = true,
		requireLvl = 1,
		weaponHash = GetHashKey("WEAPON_MELEE_HATCHET_DOUBLE_BIT"),
		imgsrc = "items/WEAPON_MELEE_HATCHET_DOUBLE_BIT.png",
		type = "item_weapon"
	},
	["WEAPON_MELEE_CLEAVER"] =
	{
		label = "Cleaver",
		description = "Keep out of reach of kids",
		weight = 1.0,
		canBeDropped = true,
		requireLvl = 1,
		weaponHash = GetHashKey("WEAPON_MELEE_CLEAVER"),
		  imgsrc = "items/WEAPON_MELEE_CLEAVER.png",
		type = "item_weapon"
	},
    ["WEAPON_MELEE_KNIFE_JAWBONE"] =
	{
		label = "Jawbone Knife",
		description = "A symbol of designer tastes",
		weight = 1.0,
		canBeDropped = true,
		requireLvl = 1,
		weaponHash = GetHashKey("WEAPON_MELEE_KNIFE_JAWBONE"),
		  imgsrc = "items/WEAPON_MELEE_KNIFE_JAWBONE.png",
		type = "item_weapon"
	},
    ["WEAPON_MELEE_KNIFE_TRADER"] =
	{
		label = "Trader Knife",
		description = "A symbol of designer tastes",
		weight = 1.0,
		canBeDropped = true,
		requireLvl = 1,
		weaponHash = GetHashKey("WEAPON_MELEE_KNIFE_TRADER"),
		  imgsrc = "items/WEAPON_MELEE_KNIFE_TRADER.png",
		type = "item_weapon"
	},
    ["WEAPON_MELEE_KNIFE_HORROR"] =
	{
		label = "Horror Knife",
		description = "A symbol of designer tastes",
		weight = 1.0,
		canBeDropped = true,
		requireLvl = 1,
		weaponHash = GetHashKey("WEAPON_MELEE_KNIFE_HORROR"),
		  imgsrc = "items/WEAPON_MELEE_KNIFE_HORROR.png",
		type = "item_weapon"
	},
    ["WEAPON_MELEE_KNIFE_RUSTIC"] =
	{
		label = "Rustic Knife",
		description = "A symbol of designer tastes",
		weight = 1.0,
		canBeDropped = true,
		requireLvl = 1,
		weaponHash = GetHashKey("WEAPON_MELEE_KNIFE_RUSTIC"),
		  imgsrc = "items/WEAPON_MELEE_KNIFE_RUSTIC.png",
		type = "item_weapon"
	},
    ["WEAPON_MELEE_MACHETE"] =
    {
        label = "Hunting Machete",
        description = "A hunting machete",
        weight = 1,
        canBeDropped = true,
        requireLvl = 1,
        weaponHash = GetHashKey("WEAPON_MELEE_MACHETE"),
          imgsrc = "items/WEAPON_MELEE_MACHETE.png",
        type = "item_weapon"
    },
    ["WEAPON_MELEE_MACHETE_HORROR"] =
    {
        label = "Horror Machete",
        description = "A horror machete",
        weight = 1,
        canBeDropped = true,
        requireLvl = 1,
        weaponHash = GetHashKey("WEAPON_MELEE_MACHETE_HORROR"),
          imgsrc = "items/WEAPON_MELEE_MACHETE_HORROR.png",
        type = "item_weapon"
    },
    ["WEAPON_MELEE_MACHETE_COLLECTOR"] =
    {
        label = "Collector Machete",
        description = "A collector machete",
        weight = 1,
        canBeDropped = true,
        requireLvl = 1,
        weaponHash = GetHashKey("WEAPON_MELEE_MACHETE_COLLECTOR"),
        imgsrc = "items/WEAPON_MELEE_MACHETE_COLLECTOR.png",
        type = "item_weapon"
    },
    ["WEAPON_FISHINGROD"] = {
        label = "Fishing Rod",
        description = "Fishing Rod",
        weight = 0.5,
        canBeDropped = true,
        weaponHash = GetHashKey("WEAPON_FISHINGROD"),
        imgsrc = "items/weapon_fishingrod.png",
        type = "item_weapon"
    },
    ["WEAPON_MELEE_KNIFE"] = {
        label = "Knife",
        description = "Knife",
        weight = 0.5,
        canBeDropped = true,
        weaponHash = GetHashKey("WEAPON_MELEE_KNIFE"),
        imgsrc = "items/WEAPON_MELEE_KNIFE.png",
        type = "item_weapon"
    },
    ["WEAPON_MELEE_LANTERN"] = {
        label = "Lantern",
        description = "Lantern",
        weight = 0.5,
        canBeDropped = true,
        weaponHash = GetHashKey("WEAPON_MELEE_LANTERN"),
        imgsrc = "items/generic_horse_equip_lantern.png",
        type = "item_weapon"
    },
    ["WEAPON_MELEE_TORCH"] = {
        label = "Torch",
        description = "Torch",
        weight = 0.5,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_MELEE_TORCH"),
        imgsrc = "items/WEAPON_MELEE_TORCH.png",
        type = "item_weapon"
    },
    ["WEAPON_LANTERN_ELECTRIC"] = {
        label = "Electric Lantern",
        description = "Electric Lantern",
        weight = 0.5,
        canBeDropped = true,
        weaponHash = GetHashKey("WEAPON_MELEE_LANTERN_ELECTRIC"),
        imgsrc = "items/weapon_melee_electric_lantern.png",
        type = "item_weapon"
    },
    ["WEAPON_BOW"] = {
        label = "Bow",
        description = "Bow",
        weight = 0.25,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_BOW"),
        imgsrc = "items/WEAPON_BOW.png",
        type = "item_weapon"
    },
    ["WEAPON_BOW_IMPROVED"] = {
        label = "Improved Bow",
        description = "Improved Bow",
        weight = 0.25,
        canBeDropped = true,
        weaponHash = GetHashKey("WEAPON_BOW_IMPROVED"),
        imgsrc = "items/T_Bow_01ca.png",
        type = "item_weapon"
    },
    ["WEAPON_LASSO"] = {
        label = "Lasso",
        description = "Lasso",
        weight = 0.25,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_LASSO_REINFORCED"),
        imgsrc = "items/WEAPON_LASSO.png",
        type = "item_weapon"
    },
    ["WEAPON_MELEE_HATCHET"] = {
        label = "Hatchet",
        description = "Hatchet",
        weight = 0.5,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_MELEE_HATCHET"),
        imgsrc = "items/WEAPON_MELEE_HATCHET.png",
        type = "item_weapon"
    },
    ["WEAPON_THROWN_THROWING_KNIVES"] = {
        label = "Throwing knives",
        description = "Throwing knives",
        weight = 0.5,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_THROWN_THROWING_KNIVES"),
        imgsrc = "items/WEAPON_THROWN_THROWING_KNIVES.png",
        type = "item_weapon"
    },
    ["WEAPON_THROWN_TOMAHAWK"] = {
        label = "Tomahawk",
        description = "Tomahawk",
        weight = 0.5,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_THROWN_TOMAHAWK"),
        imgsrc = "items/WEAPON_THROWN_TOMAHAWK.png",
        type = "item_weapon"
    },
    ["WEAPON_THROWN_DYNAMITE"] = {
        label = "Dynamite stick",
        description = "Dynamite stick",
        weight = 0.5,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_THROWN_DYNAMITE"),
        imgsrc = "items/WEAPON_THROWN_DYNAMITE.png",
        type = "item_weapon"
    },
    ["WEAPON_THROWN_MOLOTOV"] = {
        label = "Molotov",
        description = "Molotov",
        weight = 0.25,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_THROWN_MOLOTOV"),
        imgsrc = "items/WEAPON_THROWN_MOLOTOV.png",
        type = "item_weapon"
    },
    ["WEAPON_KIT_BINOCULARS"] = {
        label = "Binoculars",
        description = "Binoculars",
        weight = 0.25,
        canBeDropped = true,
                weaponHash = GetHashKey("WEAPON_KIT_BINOCULARS"),
        imgsrc = "items/WEAPON_KIT_BINOCULARS.png",
        type = "item_weapon"
    },
}
exports("GetItemsList", function()
    return Config.Items
end)
