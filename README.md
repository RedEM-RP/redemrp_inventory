# redem_inventory 1.0v

## 1. Requirements

[redem-roleplay](https://github.com/RedEM-RP/redem_roleplay/)

[redemrp_identity](https://github.com/RedEM-RP/redemrp_identity/)

[redemrp_respawn](https://github.com/RedEM-RP/redemrp_respawn/)

[redemrp_notification](https://github.com/Ktos93/redemrp_notification/)

## 2. Installation
First of all you need to insert the .sql file into your database.

Add ```ensure redem_inventory``` in server.cfg

## 3. How to start
You can use:

/getinv -to load inventory

/giveitem -to add item (name amount)

press [E] to open inventory
## 4. Auto load inventory
put code to redemrp_respawn line 90 CLIENT

looks before (90)

```
	NetworkSetFriendlyFireOption(true)
	TriggerEvent("redemrp_respawn:camera", coords)
	if new_character == 1 then
	TriggerEvent("redemrp_skin:openCreator")
	print("new character")...........
```
 looks if we add auto load  (90) CLIENT
```
	NetworkSetFriendlyFireOption(true)
	TriggerEvent("redemrp_respawn:camera", coords)
	TriggerServerEvent("player:getItems", source)
	if new_character == 1 then
	TriggerEvent("redemrp_skin:openCreator")
	print("new character")..............
```
we add this

```TriggerServerEvent("player:getItems", source)```

If you want register usable item then then you need add to your SERVER script this and replace wood on something else
```
RegisterServerEvent("RegisterUsableItem:wood")
AddEventHandler("RegisterUsableItem:wood", function()
    print("test")
end)
```
next you need add in redem_inventory config item name 

```Usable = {"wood", "your_item_name"}```


If you want delete , add or check item amount then you need add to your SERVER script this

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
