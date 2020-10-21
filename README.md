# redemrp_inventory 2.0v

## 1. Requirements

[redem-roleplay](https://github.com/RedEM-RP/redem_roleplay/)

[redemrp_identity](https://github.com/RedEM-RP/redemrp_identity/)

[redemrp_respawn](https://github.com/RedEM-RP/redemrp_respawn/)

[pNotify](https://github.com/Nick78111/pNotify)

## 2. Installation
- Insert the .sql file into your database.
- Add ```ensure redemrp_inventory``` in server.cfg

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

====================
--- -1 is send to all
--- type is id "this_is_my_locker"
--- job is job name or nill
data.createLocker(type, x , y , z , job)
data.removeLocker(-1 , id) - remove locker with DB
data.changeLockerData(id , x , y , z , job) -- change locker data
data.updateLockers(-1) -- update locker for everyone

========================

--- obj is unique id
--- -1 is send to all
data.CreateCraftingStation(obj, x, y, z , "cooking" , "sheriff")
data.updateCraftings(-1)

data.updateRemoveCraftings(obj)
data.updateCraftings(-1) 

========================

local playerInventory = data.getPlayerInventory(source) --- return player items
TriggerEvent("redemrp_inventory:SearchPlayer", target) -- search player
```


![alt text](https://i.imgur.com/ivrqvgt.png)

## 6. Credits
[Ktos93](http://github.com/Ktos93)


Join discord to get support! - https://discord.gg/FKH4uwb
