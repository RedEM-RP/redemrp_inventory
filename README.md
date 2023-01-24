## [Latest Documentation](https://sinatra.gitbook.io/redemrp/ "Latest Documentation")
![](https://img.shields.io/github/stars/RedEM-RP/redemrp_inventory) ![](https://img.shields.io/github/forks/RedEM-RP/redemrp_inventory) ![](https://img.shields.io/github/tag/RedEM-RP/redemrp_inventory) ![](https://img.shields.io/github/release/RedEM-RP/redemrp_inventory) ![](https://img.shields.io/github/issues/RedEM-RP/redemrp_inventory) ![](https://img.shields.io/discord/648268213859254309)

[![](https://i.ibb.co/FnNr3Z3/redemrpn.png)](https://discord.gg/nbmTmZR "")

# redemrp_inventory 2023.01

## 1. Requirements

[redem-roleplay](https://github.com/RedEM-RP/redem_roleplay/)
[redemrp_charselect](https://github.com/RedEM-RP/redemrp_charselect/)
[redemrp_respawn](https://github.com/RedEM-RP/redemrp_respawn/)

## 2. Installation
- Add ```ensure redemrp_inventory``` in server.cfg after redem_roleplay, redem_charselect

## 3. How to use
Press [B] to open inventory

- /giveitem name count - to give yourself an item. You cant give more than limit

## 4. Usable Items
- To Register usable item, use an example provided below (server-side)
```
RegisterServerEvent("RegisterUsableItem:your_item_name")
AddEventHandler("RegisterUsableItem:your_item_name", function(source)
    print("test")
end)
```
- You need also to add usable item in redemrp_inventory config.lua file (example provided below)

```
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


    }
```

## 5. Developing
If you want to delete, add or check item amount you need use an example provided below (server-side)

```
data = {}
TriggerEvent("redemrp_inventory:getData",function(call)
		data = call
end)
```
Functions examples:

```
local ItemData = data.getItem(_source, 'bread') -- this give you info and functions
print(ItemData.ItemAmount)
ItemData.RemoveItem(2)
ItemData.AddItem(7)


local ItemInfo = data.getItemData('bread') -- return info from config

========================

local playerInventory = data.getPlayerInventory(source) --- return player items
data.removePlayerInventory(source) -- remove player inventory
TriggerEvent("redemrp_inventory:SearchPlayer", target) -- search player
```

## 6. Credits
[Ktos93](http://github.com/Ktos93)

[youngsinatra99](http://github.com/youngsinatra99)


Join discord to get support! - https://discord.gg/FKH4uwb
