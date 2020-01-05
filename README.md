# redem_inventory 1.0v

## 1. Requirements

[redem-roleplay](https://github.com/RedEM-RP/redem_roleplay/)

[redemrp_identity](https://github.com/RedEM-RP/redemrp_identity/)

[redemrp_respawn](https://github.com/RedEM-RP/redemrp_respawn/)

[redemrp_notification](https://github.com/Ktos93/redemrp_notification/)

## 2. Installation
- Insert the .sql file into your database.
- Add ```ensure redem_inventory``` in server.cfg

## 3. How to use
Press [B] to open inventory

- /getinv - to reload inventory(dev)
- /giveitem name count - to give yourself an item

## 4. Usable Items
- To Register a usable item, use an example provided below (server-side)
```
RegisterServerEvent("RegisterUsableItem:your_item_name")
AddEventHandler("RegisterUsableItem:your_item_name", function(source)
    print("test")
end)
```
- You need also to add usable item in redem_inventory config.lua file (example provided below)

```Usable = {"wood", "your_item_name"}```

## 5. Developing
If you want to delete, add or check item amount you need use an example provided below (server-side)

```
data = {}
TriggerEvent("redem_inventory:getData",function(call)
		data = call
end)
```
Functions examples:

```
print(data.checkItem(_source,"water"))
data.delItem(_source,"water", 2)
data.addItem(_source,"bread", 10)
```
TO DO :
*Server code require optimization

![alt text](https://i.imgur.com/PxCRpBv.png)

## 5. Credits
[Ktos93](http://github.com/Ktos93)

[z00t](https://github.com/z00t) - Thanks for huge help

[PokeSer](https://github.com/PokeSer) - Thanks for with testing and repair this

Join discord to get support! - https://discord.gg/FKH4uwb
