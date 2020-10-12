local Inventory = {}
local InventoryWeight = {}
local Locker = {}
local DroppedItems = {}
local CreatedLockers = {}
local SharedInventoryFunctions = {}
local CreatedCraftings = {}
math.randomseed(os.time())
AddEventHandler('redemrp_inventory:getData', function(cb)
    cb(SharedInventoryFunctions)
end)

AddEventHandler("redemrp:playerLoaded", function(source, user)
    local _source = source
        local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")
        local money = user.getMoney()
		local job = user.getJob()
        TriggerClientEvent("redemrp_inventory:SendLockers", _source, CreatedLockers)
		TriggerClientEvent("redemrp_inventory:SendCraftings", _source, CreatedCraftings, job)
        TriggerClientEvent("redemrp_inventory:UpdatePickups", _source, DroppedItems)
        MySQL.Async.fetchAll('SELECT * FROM user_inventory WHERE `identifier`=@identifier AND `charid`=@charid;', {identifier = identifier, charid = charid}, function(db_items)
            if db_items[1] ~= nil then
                local inv = json.decode(db_items[1].items)
                Inventory[identifier .. "_" .. charid] , InventoryWeight[identifier .. "_" .. charid]  = CreateInventory(inv)

            else
                local start_items = {
                    ["water"] = {amount = 3, meta =  {}},
                    ["bread"] = {amount = 3, meta = {}},
                }
                MySQL.Async.execute('INSERT INTO user_inventory (`identifier`, `charid`, `items`) VALUES (@identifier, @charid, @items);',
                    {
                        identifier = identifier,
                        charid = charid,
                        items = json.encode(start_items)
                    }, function(rowsChanged)
                    end)
                Inventory[identifier .. "_" .. charid] , InventoryWeight[identifier .. "_" .. charid] , _ = CreateInventory(start_items)
            end

            MySQL.Async.fetchAll('SELECT * FROM user_locker WHERE `identifier`=@identifier AND `charid`=@charid;', {identifier = identifier, charid = charid}, function(db_locker)
                if db_locker[1] ~= nil then
                    local lock = json.decode(db_locker[1].items)
                    Locker[identifier .. "_" .. charid] , _  = CreateInventory(lock)
                else
                    Locker[identifier .. "_" .. charid] = {}
					  MySQL.Async.execute('INSERT INTO user_locker (`identifier`, `charid`, `items`) VALUES (@identifier, @charid, @items);',
                    {
                        identifier = identifier,
                        charid = charid,
                        items = json.encode({})
                    }, function(rowsChanged)
                    end)
                end
                TriggerClientEvent("redemrp_inventory:SendItems", _source, PrepareToOutput(Inventory[identifier .. "_" .. charid]) ,  {} , money , InventoryWeight[identifier .. "_" .. charid])
            end)
        end)
end)


RegisterServerEvent("redemrp_inventory:update")
AddEventHandler("redemrp_inventory:update", function(_type ,data , target, LockerID)
    local _source = source
    local _target = target
    local itemData = Config.Items[data.name]
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")
        local money = user.getMoney()
        local lvl = user.getLevel()
        if _target == 0 then
            if _type == "delete" then
                if  removeItem(data.name, data.amount, data.meta, identifier , charid) then
                    if LockerID == "private" then
                        addItemLocker(data.name, data.amount, data.meta, identifier .. "_" .. charid)
                    else
                        addItemLocker(data.name, data.amount, data.meta, LockerID)
                    end
                    if itemData.type == "item_weapon" then
                        TriggerClientEvent("redemrp_inventory:removeWeapon", _source, itemData.weaponHash)
                    end
                end
            elseif _type == "add" then
                if LockerID == "private" then
                    if removeItemLocker(data.name, data.amount, data.meta, identifier .. "_" .. charid) then
                        if not addItem(data.name ,data.amount, data.meta, identifier , charid , lvl) then
                            addItemLocker(data.name, data.amount, data.meta, identifier .. "_" .. charid)
                        end
                    end
                else
                    if  removeItemLocker(data.name, data.amount, data.meta, LockerID) then
                        if not  addItem(data.name ,data.amount, data.meta, identifier , charid , lvl) then
                            addItemLocker(data.name, data.amount, data.meta, LockerID)
                        end
                    end
                end
            end
            if LockerID == "private" then
                TriggerClientEvent("redemrp_inventory:SendItems", _source, PrepareToOutput(Inventory[identifier .. "_" .. charid]) ,  PrepareToOutput(Locker[identifier .. "_" .. charid]) , money , InventoryWeight[identifier .. "_" .. charid] , true)
            else
                TriggerClientEvent("redemrp_inventory:SendItems", _source, PrepareToOutput(Inventory[identifier .. "_" .. charid]) ,  PrepareToOutput(Locker[LockerID]) , money , InventoryWeight[identifier .. "_" .. charid] , true)
            end
        else
            TriggerEvent('redemrp:getPlayerFromId', _target, function(user2)
                local identifier_target = user2.getIdentifier()
                local charid_target = user2.getSessionVar("charid")
                local money_target = user2.getMoney()
                local lvl_target = user.getLevel()
                if _type == "delete" then
                    if removeItem(data.name, data.amount, data.meta, identifier , charid) then
                        if not addItem(data.name ,data.amount, data.meta , identifier_target ,charid_target ,lvl_target) then
                            addItem(data.name, data.amount, data.meta, identifier , charid, lvl)
                        else
                            if itemData.type == "item_weapon" then
                                TriggerClientEvent("redemrp_inventory:removeWeapon", _source, itemData.weaponHash)
                            end
                        end
                    end
                elseif _type == "add" then
                    if removeItem(data.name, data.amount, data.meta, identifier_target ,charid_target) then
                        if not addItem(data.name ,data.amount, data.meta, identifier , charid , lvl) then
                            addItem(data.name, data.amount, data.meta, identifier_target ,charid_target , lvl_target)
                        else
                            if itemData.type == "item_weapon" then
                                TriggerClientEvent("redemrp_inventory:removeWeapon", _target, itemData.weaponHash)
                            end
                        end
                    end
                end
                TriggerClientEvent("redemrp_inventory:SendItems", _target, PrepareToOutput(Inventory[identifier_target .. "_" .. charid_target]) ,  {} , money_target , InventoryWeight[identifier_target .. "_" .. charid_target])
                TriggerClientEvent("redemrp_inventory:SendItems", _source, PrepareToOutput(Inventory[identifier .. "_" .. charid]) ,  PrepareToOutput(Inventory[identifier_target .. "_" .. charid_target]) , money , InventoryWeight[identifier .. "_" .. charid], true , _target)

            end)
        end
    end)
end)

----=======================SAVE ================================
AddEventHandler("redemrp:playerDropped", function(_player)
    local player = _player
    local charid = player.getSessionVar("charid")
    local identifier = player.get('identifier')
    local player_inventory =  Inventory[identifier .. "_" .. charid]
    local player_locker =  Locker[identifier .. "_" .. charid]
    local ToSaveInventory = {}
    local ToSaveLocker = {}
    if player_inventory[1] ~= nil then
        for i,k in pairs(player_inventory) do
            table.insert(ToSaveInventory ,{name = k.getName(), amount = k.getAmount(), meta = k.getMeta()})

        end
    end
    if player_locker[1] ~= nil then
        for i,k in pairs(player_locker) do
            table.insert(ToSaveLocker ,{name = k.getName(), amount = k.getAmount(), meta = k.getMeta()}) 
        end
    end
    local JsonItemsInventory = json.encode(ToSaveInventory)
    local JsonItemsLocker = json.encode(ToSaveLocker)
    MySQL.Async.execute('UPDATE user_inventory SET items = @items WHERE identifier = @identifier AND charid = @charid', {
        ['@identifier']  = identifier,
        ['@charid']  = charid,
        ['@items'] = JsonItemsInventory
    }, function (rowsChanged)
        if rowsChanged == 0 then
            print(('user_inventory: Something went wrong saving %s!'):format(identifier .. ":" .. charid))
        else
            print("saved")
        end
    end)
    MySQL.Async.execute('UPDATE user_locker SET items = @items WHERE identifier = @identifier AND charid = @charid', {
        ['@identifier']  = identifier,
        ['@charid']  = charid,
        ['@items'] = JsonItemsLocker
    }, function (rowsChanged)
        if rowsChanged == 0 then
            print(('user_inventory: Something went wrong saving locker %s!'):format(identifier .. ":" .. charid))
        else
            print("saved locker")
        end
    end)
        Inventory[identifier .. "_" .. charid] = nil
        Locker[identifier .. "_" .. charid] = nil
end)


AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print('The resource ' .. resourceName .. ' was stopped.')
    for j,l in pairs(Locker) do
        local player_locker  = l
        local identifier = j:sub(1, -3)
        local charid = j:sub(#j ,#j)
        if "number" ~= type(charid) and string.len(j) ~= 23 then
            identifier = j
            charid = 0

            local ToSaveLocker = {}
            if player_locker[1] ~= nil then
                for i,k in pairs(player_locker) do
                   table.insert(ToSaveLocker ,{name = k.getName(), amount = k.getAmount(), meta = k.getMeta()})
                end
            end
            local JsonItemsLocker = json.encode(ToSaveLocker)

            MySQL.Async.execute('UPDATE user_locker SET items = @items WHERE identifier = @identifier AND charid = @charid', {
                ['@identifier']  = identifier,
                ['@charid']  = charid,
                ['@items'] = JsonItemsLocker
            }, function (rowsChanged)
            end)
        end
    end
end)



 function savePlayerInventory()
    SetTimeout(900000, function()
        Citizen.CreateThread(function()
            local saved  = 0
            for j,l in pairs(Inventory) do
                local player_inventory  = l
                local identifier = j:sub(1, -3)
                local charid = j:sub(#j ,#j)
                saved = saved + 1
                local ToSaveInventory = {}
                if player_inventory[1] ~= nil then
                    for i,k in pairs(player_inventory) do
                        table.insert(ToSaveInventory ,{name = k.getName(), amount = k.getAmount(), meta = k.getMeta()})

                    end
                end
                local JsonItemsInventory = json.encode(ToSaveInventory)
                MySQL.Async.execute('UPDATE user_inventory SET items = @items WHERE identifier = @identifier AND charid = @charid', {
                    ['@identifier']  = identifier,
                    ['@charid']  = charid,
                    ['@items'] = JsonItemsInventory
                }, function (rowsChanged)
                    if rowsChanged == 0 then
                        print(('user_inventory: Something went wrong saving %s!'):format(identifier .. ":" .. charid))
                    else
                    end
                end)
            end
			 local saved_locker  = 0
            for j,l in pairs(Locker) do
                local player_locker  = l
                local identifier = j:sub(1, -3)
                local charid = j:sub(#j ,#j)
				saved_locker = saved_locker + 1
                if "number" ~= type(charid) and string.len(j) ~= 23 then
                    identifier = j
                    charid = 0
                end
                local ToSaveLocker = {}
                if player_locker[1] ~= nil then
                    for i,k in pairs(player_locker) do
                        table.insert(ToSaveLocker ,{name = k.getName(), amount = k.getAmount(), meta = k.getMeta()})
                    end
                end
                local JsonItemsLocker = json.encode(ToSaveLocker)

                MySQL.Async.execute('UPDATE user_locker SET items = @items WHERE identifier = @identifier AND charid = @charid', {
                    ['@identifier']  = identifier,
                    ['@charid']  = charid,
                    ['@items'] = JsonItemsLocker
                }, function (rowsChanged)
                    if rowsChanged == 0 then
                        print(('user_inventory: Something went wrong saving locker %s!'):format(identifier .. ":" .. charid))
                    else
                        print("saved locker")
                    end
                end)
            end
            print("Zapisano łącznie: "..saved.." inventory")
			print("Zapisano łącznie: "..saved_locker.." schowkow")

            savePlayerInventory()
        end)
    end)
end


savePlayerInventory()

----=======================SAVE ================================

--==================== D R O P =======================================

RegisterServerEvent("redemrp_inventory:drop")
AddEventHandler("redemrp_inventory:drop", function(data)
    local _source = source
    local itemData = Config.Items[data.name]
    if itemData.canBeDropped then
        TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
            local identifier = user.getIdentifier()
            local charid = user.getSessionVar("charid")
            local money = user.getMoney()
            removeItem(data.name, data.amount, data.meta, identifier , charid)
            TriggerClientEvent("redemrp_inventory:SendItems", _source, PrepareToOutput(Inventory[identifier .. "_" .. charid]) ,  {} , money , InventoryWeight[identifier .. "_" .. charid])
            TriggerClientEvent("redemrp_inventory:CreatePickup", _source, data.name , data.amount, data.meta , itemData.label, itemData.imgsrc)
            if itemData.type == "item_weapon" then
                TriggerClientEvent("redemrp_inventory:removeWeapon", _source, itemData.weaponHash)
            end
        end)
    end
end)


RegisterServerEvent("redemrp_inventory:AddPickupServer")
AddEventHandler("redemrp_inventory:AddPickupServer", function(name, amount, meta, label, img, x, y, z , id)
    DroppedItems[id] = {
        name = name,
        meta = meta,
        amount = amount,
        label = label,
        img = img,
        inRange = false,
        coords = {x = x, y = y, z = z}
    }
    TriggerClientEvent("redemrp_inventory:UpdatePickups", -1, DroppedItems)
end)


RegisterServerEvent("redemrp_inventory:onPickup")
AddEventHandler("redemrp_inventory:onPickup", function(id)
    local _source = source
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")
        local money = user.getMoney()
        local lvl = user.getLevel()
        if addItem(DroppedItems[id].name ,DroppedItems[id].amount, DroppedItems[id].meta, identifier , charid , lvl) then
            TriggerClientEvent("redemrp_inventory:SendItems", _source, PrepareToOutput(Inventory[identifier .. "_" .. charid]) ,  {} , money , InventoryWeight[identifier .. "_" .. charid])
            TriggerClientEvent('redemrp_inventory:removePickup', -1, id)
            TriggerClientEvent('redemrp_inventory:PickupAnim', _source)
            TriggerClientEvent("pNotify:SendNotification", _source, {
                text = "<img src='nui://redemrp_inventory/html/"..DroppedItems[id].img.."' height='40' width='40' style='float:left; margin-bottom:10px; margin-left:20px;' />Pickup: ".. DroppedItems[id].label.."<br>+"..tonumber(DroppedItems[id].amount),
                type = "success",
                timeout = math.random(2000, 3000),
                layout = "centerRight",
                queue = "right"
            })
            DroppedItems[id] = nil
            TriggerClientEvent("redemrp_inventory:UpdatePickups", -1, DroppedItems)
		else
			 TriggerClientEvent("ak_notification:Left", _source, "Torba", "Nie możesz podnieść tego przedmiotu" , tonumber(2000))
        end
    end)
    TriggerClientEvent('redemrp_inventory:ReEnablePrompt', _source)
end)

--==================== D R O P =======================================


--==================== U S E =======================================
RegisterServerEvent("redemrp_inventory:use")
AddEventHandler("redemrp_inventory:use", function(data)
    local _source = source
    local itemData = Config.Items[data.name]
    if itemData.canBeUsed then
        TriggerEvent("RegisterUsableItem:"..data.name, _source)
        TriggerClientEvent("ak_notification:Left", _source, "Użyto przedmiotu" , itemData.label, tonumber(1000))
    end
    if itemData.type == "item_weapon" then
        TriggerClientEvent('redemrp_inventory:UseWeapon', _source , itemData.weaponHash, data.amount ,data.meta , data.name)
    end
end)
--==================== U S E =======================================



RegisterServerEvent("redemrp_inventory:ChangeAmmoAmount")
AddEventHandler("redemrp_inventory:ChangeAmmoAmount", function(table)
    local _source = source
    local _table = table
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")
        local player_inventory =  Inventory[identifier .. "_" .. charid]
        for i,k in pairs(_table) do
            local item , id = getInventoryItemFromName(k.name, player_inventory ,k.meta)
            item.setAmount(tonumber(k.Ammo))
        end
    end)
end)


RegisterCommand('giveitem', function(source, args)
    local _source = source
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")
        local lvl = user.getLevel()
        local money = user.getMoney()
        if user.getGroup() == 'superadmin' and _source ~= 0 then
            addItem(args[1], tonumber(args[2]) ,{} , identifier , charid ,lvl )
            TriggerClientEvent("redemrp_inventory:SendItems", _source, PrepareToOutput(Inventory[identifier .. "_" .. charid]) ,  {} , money , InventoryWeight[identifier .. "_" .. charid])
        end
    end)
end)



function getInventoryItemFromName(name, items_table , meta)
    for i,k in pairs(items_table) do
        if  k.getData().type ~= "item_weapon" and not  meta.fishweight and not meta.waterlevel then
            if name == k.getName() then
                return items_table[i] , i
            end
        else
		
            if meta.uid then
                if name == k.getName() and tostring(meta.uid) == tostring(k.getMeta().uid)  then
                    return items_table[i] , i
                end
			end
            if meta.fishweight then
                if name == k.getName() and tostring(meta.fishweight) == tostring(k.getMeta().fishweight) then
                    return items_table[i] , i
                end
            end
            if meta.waterlevel then
                if name == k.getName() and tostring(meta.waterlevel) == tostring(k.getMeta().waterlevel) then
                    return items_table[i] , i
                end
            end
        end
    end
    return false, false
end



function addItem (name, amount ,meta , identifier , charid , lvl )
    local _name = name
    local _amount = amount
    local _meta = meta or {}
    local output = false
    if _amount >=0 then
        local itemData = Config.Items[_name]
        local player_inventory =  Inventory[identifier .. "_" .. charid]
        if not _meta.uid and itemData.type == "item_weapon" then
            local numBase0 = math.random(100,999)
            local numBase1 = math.random(0,9999)
            local generetedUid = string.format("%03d%04d", numBase0, numBase1)
            _meta.uid = generetedUid
        end
        local item , id = getInventoryItemFromName(_name, player_inventory ,_meta)
        if itemData.requireLvl <= lvl then
            if not item then
                if itemData.type == "item_standard" then
				  if _amount >0 then
                    if InventoryWeight[identifier .. "_" .. charid] + (itemData.weight * _amount) <= Config.MaxWeight  and itemData.limit >= _amount then
                        table.insert(player_inventory, CreateItem(_name ,_amount, _meta))
                        InventoryWeight[identifier .. "_" .. charid] = InventoryWeight[identifier .. "_" .. charid] + (itemData.weight * _amount)
                        output = true
                    end
				end
                elseif itemData.type == "item_weapon" then
                    if InventoryWeight[identifier .. "_" .. charid] + itemData.weight <= Config.MaxWeight then
                        table.insert(player_inventory, CreateItem(_name ,_amount, _meta))
                        InventoryWeight[identifier .. "_" .. charid] = InventoryWeight[identifier .. "_" .. charid] + itemData.weight
                        output = true
                    end
                end
            else
                if itemData.type == "item_standard" then
				  if _amount >0 then
                    if InventoryWeight[identifier .. "_" .. charid] + (itemData.weight * _amount) <= Config.MaxWeight and itemData.limit >= _amount + item.getAmount() then
                        item.addAmount(_amount)
                        InventoryWeight[identifier .. "_" .. charid] = InventoryWeight[identifier .. "_" .. charid] + (itemData.weight * _amount)
                        output = true
                    end
				end
                end
            end
        end
    end
    return output
end



function removeItem (name, amount, meta, identifier , charid)
    local _name = name
    local _amount = amount
    local _meta = meta or {}
    local output = false
    if _amount >=0 then
        local itemData = Config.Items[_name]
        local player_inventory =  Inventory[identifier .. "_" .. charid]
        local item , id = getInventoryItemFromName(_name, player_inventory ,_meta)
        if item then
            if itemData.type == "item_standard" then
			  if _amount > 0 then
                if item.removeAmount(_amount) then
                    table.remove(player_inventory , id)
                end
                InventoryWeight[identifier .. "_" .. charid] = InventoryWeight[identifier .. "_" .. charid] - (itemData.weight * _amount)
                output = true
				end
            elseif itemData.type == "item_weapon" then
                table.remove(player_inventory , id)
                InventoryWeight[identifier .. "_" .. charid] = InventoryWeight[identifier .. "_" .. charid] - itemData.weight
                output = true
            end
        end
    end
    return output
end


function addItemLocker (name, amount ,meta, lockerId)
    local _source = source
    local _name = name
    local _amount = amount
    local output = false
    local _meta = meta or {}
    if _amount >=0 then
        local itemData = Config.Items[_name]
        local player_locker =  Locker[lockerId]
        local item , id = getInventoryItemFromName(_name, player_locker ,_meta)
        if not item then

            if itemData.type == "item_standard" then
			  if _amount >0 then
                table.insert(player_locker, CreateItem(_name ,_amount, _meta))
                output = true
				end
            elseif itemData.type == "item_weapon" then
                if not _meta.uid then
                    local numBase0 = math.random(100,999)
                    local numBase1 = math.random(0,9999)
                    local generetedUid = string.format("%03d%04d", numBase0, numBase1)
                    _meta.uid = generetedUid
                end
                table.insert(player_locker, CreateItem(_name ,_amount, _meta))
                output = true
            end
        else
		  if _amount >0 then
            if itemData.type == "item_standard" then
                item.addAmount(_amount)
                output = true
            end
			end
        end
    end
    return output
end


function removeItemLocker ( name, amount,meta, lockerId)
    local _name = name
    local _amount = amount
    local _meta = meta or {}
    local output = false
    if _amount >=0 then
        local itemData = Config.Items[_name]
        local player_locker =  Locker[lockerId]
        local item , id = getInventoryItemFromName(_name, player_locker ,_meta)
        if item then
            if itemData.type == "item_standard" then
			  if _amount >0 then
                if item.removeAmount(_amount) then
                    table.remove(player_locker , id)
                end
                output = true
			end
            elseif itemData.type == "item_weapon" then
                table.remove(player_locker , id)
                output = true
            end
        end
    end
    return output
end




RegisterServerEvent("redemrp_inventory:GetLocker")
AddEventHandler("redemrp_inventory:GetLocker", function(id)
    local _source = source
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")
        local money = user.getMoney()
        local job = user.getJob()
		 TriggerEvent('redemrp_db:getCurrentGang', identifier, charid, function(gang_data)
        if id == "private" then
		if CreatedLockers[id] ~= nil then
            if CreatedLockers[id].requireJob == job or CreatedLockers[id].requireJob == nil or  CreatedLockers[id].requireJob == gang_data.gang then
                TriggerClientEvent("redemrp_inventory:SendItems", _source, PrepareToOutput(Inventory[identifier .. "_" .. charid]) ,  PrepareToOutput(Locker[identifier .. "_" .. charid]) , money , InventoryWeight[identifier .. "_" .. charid], true)
            end
		else
		                TriggerClientEvent("redemrp_inventory:SendItems", _source, PrepareToOutput(Inventory[identifier .. "_" .. charid]) ,  PrepareToOutput(Locker[identifier .. "_" .. charid]) , money , InventoryWeight[identifier .. "_" .. charid], true)
		end
        else
            if CreatedLockers[id].requireJob == job or CreatedLockers[id].requireJob == nil  or  CreatedLockers[id].requireJob == gang_data.gang then
                TriggerClientEvent("redemrp_inventory:SendItems", _source, PrepareToOutput(Inventory[identifier .. "_" .. charid]) ,  PrepareToOutput(Locker[id]) , money , InventoryWeight[identifier .. "_" .. charid] , true)
            end
        end
		end)
    end)
end)


RegisterServerEvent("redemrp_inventory:GetPlayer")
AddEventHandler("redemrp_inventory:GetPlayer", function(target)
    local _source = source
    local _target = target
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")
        local money = user.getMoney()
        TriggerEvent('redemrp:getPlayerFromId', _target, function(user2)
            local identifier_target = user2.getIdentifier()
            local charid_target = user2.getSessionVar("charid")
            TriggerClientEvent("redemrp_inventory:SendItems", _source, PrepareToOutput(Inventory[identifier .. "_" .. charid]) ,  PrepareToOutput(Inventory[identifier_target .. "_" .. charid_target]) , money , InventoryWeight[identifier .. "_" .. charid], true ,_target)
        end)
    end)
end)
----=======================SHARED FUNCTIONS  ================================


function SharedInventoryFunctions.createLocker(type, x , y , z , job)
    local _type = type
    local _x = x
    local _y = y
    local _z = z
    local _job = job
	if CreatedLockers[_type] == nil then
    CreatedLockers[_type] = {
        coords = {x = _x, y = _y, z = _z},
        requireJob = _job
    }
    if _type ~= "private"  then
        MySQL.Async.fetchAll('SELECT * FROM user_locker WHERE `identifier`=@identifier AND `charid`=@charid;',
            {
                identifier = _type,
                charid = 0
            }, function(db_items)
                if db_items[1] ~= nil then
                    local data = json.decode(db_items[1].items)
                    Locker[_type] , _  = CreateInventory(data)
                else
                    MySQL.Async.execute('INSERT INTO user_locker (`identifier`, `charid`, `items`) VALUES (@identifier, @charid, @items);',
                        {
                            identifier = _type,
                            charid = 0,
                            items = json.encode({})
                        }, function(rowsChanged)
                            Locker[_type], _ , _ =  CreateInventory({})
                        end)
                end
            end)
    end
	end
end

function SharedInventoryFunctions.updateLockers(_source)
   TriggerClientEvent("redemrp_inventory:SendLockers", _source, CreatedLockers)
end

function SharedInventoryFunctions.existLocker(name)
	if CreatedLockers[name] then
		return true
	else
		return false
	end
end

function SharedInventoryFunctions.changeLockerData( type, x , y , z , job)
    local _type = type
    local _x = x
    local _y = y
    local _z = z
    local _job = job
	 CreatedLockers[_type] = nil
    CreatedLockers[_type] = {
        coords = {x = _x, y = _y, z = _z},
        requireJob = _job
    }
end

function SharedInventoryFunctions.CreateCraftingStation(name, x , y , z , type, job)
    local _name = name
    local _x = x
    local _y = y
    local _z = z
	local _type = type
    local _job = job
	CreatedCraftings[_name] = nil
    CreatedCraftings[_name] = {
        coords = {x = _x, y = _y, z = _z},
		type = _type,
        requireJob = _job
    }
end


function SharedInventoryFunctions.updateCraftings(_source)
   TriggerClientEvent("redemrp_inventory:SendCraftings", _source, CreatedCraftings)
end
function SharedInventoryFunctions.updateRemoveCraftings(id)
	local _id = id
   CreatedCraftings[_id] = nil
end

function SharedInventoryFunctions.removeLocker(_source , id)
	local _id = id
    CreatedLockers[_id] = nil
	 MySQL.Async.fetchAll('DELETE FROM user_locker WHERE `identifier`=@identifier AND `charid`=@charid;', {identifier = _id, charid = 0}, function(result)

    end)
	TriggerClientEvent("redemrp_inventory:SendLockers", _source, CreatedLockers)
end

function SharedInventoryFunctions.getItemData(name)
    return Config.Items[name]
end

function SharedInventoryFunctions.getPlayerInventory(_source)
local output = {}
        TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
            local identifier = user.getIdentifier()
            local charid = user.getSessionVar("charid")
			local player_inventory =  Inventory[identifier .. "_" .. charid]
				output = PrepareToOutput(player_inventory)
			end)
return output
end

function SharedInventoryFunctions.getItem(_source, name , meta)
    local data = {}
    if name ~= nil then
        TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
            local identifier = user.getIdentifier()
            local charid = user.getSessionVar("charid")
            local player_inventory =  Inventory[identifier .. "_" .. charid]
            local lvl = user.getLevel()
            local money = user.getMoney()
            local item , id = getInventoryItemFromName(name, player_inventory , meta or {})
			
            if item then
                data.ItemInfo = item.getData()
                data.ItemMeta = item.getMeta()
                data.ItemAmount = item.getAmount()
                function data.ChangeMeta(meta)
                  item.setMeta(meta)
				  TriggerClientEvent("redemrp_inventory:SendItems", _source, PrepareToOutput(Inventory[identifier .. "_" .. charid]) ,  {} , money , InventoryWeight[identifier .. "_" .. charid])
                end
                function data.AddItem(amount)
                    local output = false
                    output =  addItem(name, amount, data.ItemMeta, identifier , charid , lvl)
                    if not output then
                        if data.ItemInfo.type ~= "item_weapon" then
                            local freeWeight = Config.MaxWeight - InventoryWeight[identifier .. "_" .. charid]
                            local canBeAdded = math.floor(freeWeight/data.ItemInfo.weight)
							if canBeAdded > amount then
								canBeAdded = data.ItemInfo.limit - data.ItemAmount
							end
							output = addItem(name, canBeAdded, data.ItemMeta, identifier , charid , lvl)
							if amount-canBeAdded > 0 then
								TriggerClientEvent("redemrp_inventory:CreatePickup", _source, name , amount-canBeAdded, data.ItemMeta, data.ItemInfo.label, data.ItemInfo.imgsrc)
							end
					   else
                            TriggerClientEvent("redemrp_inventory:CreatePickup", _source, name , amount, data.ItemMeta, data.ItemInfo.label, data.ItemInfo.imgsrc)
							TriggerClientEvent("redemrp_inventory:removeWeapon", _source, data.ItemInfo.weaponHash)
						end
					end
                    if output then
                        TriggerClientEvent("redemrp_inventory:SendItems", _source, PrepareToOutput(Inventory[identifier .. "_" .. charid]) ,  {} , money , InventoryWeight[identifier .. "_" .. charid])
                    end
                    return output
                end
                function data.RemoveItem(amount)
                    local output = false
                    output =  removeItem(name, amount, meta, identifier , charid)
                    if output then
                        TriggerClientEvent("redemrp_inventory:SendItems", _source, PrepareToOutput(Inventory[identifier .. "_" .. charid]) ,  {}, money , InventoryWeight[identifier .. "_" .. charid])
						 if data.ItemInfo.type == "item_weapon" then
							TriggerClientEvent("redemrp_inventory:removeWeapon", _source, data.ItemInfo.weaponHash) 
						 end
                    end
                    return output
                end
            else
                data.ItemInfo = Config.Items[name]
                data.ItemMeta = {}
                data.ItemAmount = 0
                 function data.AddItem(amount)
                    local output = false
                    output =  addItem(name, amount, meta, identifier , charid , lvl)
                    if not output then
                        if data.ItemInfo.type ~= "item_weapon" then
                            local freeWeight = Config.MaxWeight - InventoryWeight[identifier .. "_" .. charid]
                            local canBeAdded = math.floor(freeWeight/data.ItemInfo.weight)
							if canBeAdded > amount then
								canBeAdded = data.ItemInfo.limit
							end
							if canBeAdded > 0 then
								output =  addItem(name, canBeAdded, meta, identifier , charid , lvl)
								TriggerClientEvent("redemrp_inventory:CreatePickup", _source, name , amount-canBeAdded, meta or {}, data.ItemInfo.label, data.ItemInfo.imgsrc)
							end
					   else
							local freeWeight = Config.MaxWeight - InventoryWeight[identifier .. "_" .. charid]
							if freeWeight < data.ItemInfo.weight then
								TriggerClientEvent("redemrp_inventory:CreatePickup", _source, name , amount,  meta or {}, data.ItemInfo.label, data.ItemInfo.imgsrc)
							else
								output =  addItem(name, amount, meta, identifier , charid , lvl)
							end
                        end
                    end
                    if output then
                        TriggerClientEvent("redemrp_inventory:SendItems", _source, PrepareToOutput(Inventory[identifier .. "_" .. charid]) ,  {} , money , InventoryWeight[identifier .. "_" .. charid])
                    end
                    return output
                end
                function data.RemoveItem(amount)
                    return false
                end
            end
        end)
    end
    return data
end

----=======================SHARED FUNCTIONS  ================================

RegisterServerEvent("redemrp_inventory:craft")
AddEventHandler("redemrp_inventory:craft", function(data , type)
    local _source = source
    local _type = type
    local itemtoCraft
    local table_value =  {}
    for v,k in pairs(data) do
        if  k[1] ~= "empty" then
            table.insert(table_value, k[2])
        end
    end
	if table_value[1] then
    local arraymin = math.min(table.unpack(table_value))
    for a,b in pairs(Config.Crafting) do
        local craftCheck = true
        if data.slot_1[1] ~= b.items[1] then
            craftCheck = false
        end
        if data.slot_2[1] ~= b.items[2] then
            craftCheck = false
        end
        if data.slot_3[1] ~= b.items[3] then
            craftCheck = false
        end
        if data.slot_4[1] ~= b.items[4] then
            craftCheck = false
        end
        if data.slot_5[1] ~= b.items[5] then
            craftCheck = false
        end
        if data.slot_6[1] ~= b.items[6] then
            craftCheck = false
        end
        if data.slot_7[1] ~= b.items[7] then
            craftCheck = false
        end
        if data.slot_8[1] ~= b.items[8] then
            craftCheck = false
        end
        if data.slot_9[1] ~= b.items[9] then
            craftCheck = false
        end
        if craftCheck then
            itemtoCraft = a
            break
        end

    end
    if itemtoCraft ~= nil then
        local  CraftData = Config.Crafting[itemtoCraft]
        if CraftData.type == _type or CraftData.type == "empty" then
            TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
                local job = user.getJob()
                if CraftData.requireJob == job or CraftData.requireJob == "empty"  then
                    for v,k in pairs(data) do
                        if  k[1] ~= "empty" and k[1] ~= "WEAPON_MELEE_KNIFE" then
                            local itemData1 = SharedInventoryFunctions.getItem(_source, k[1])
                            itemData1.RemoveItem(arraymin)
                        end
                    end
					local itemData2
					if itemtoCraft == "flask_clean" then
						local meta = {}
						meta.waterlevel =  data.slot_5[3].waterlevel
						itemData2 = SharedInventoryFunctions.getItem(_source, itemtoCraft , meta)
					elseif itemtoCraft == "flask" then
						local meta = {}
						meta.waterlevel = 0
						itemData2 = SharedInventoryFunctions.getItem(_source, itemtoCraft , meta)		
					else
						itemData2 = SharedInventoryFunctions.getItem(_source, itemtoCraft)
					end
						itemData2.AddItem(arraymin * CraftData.amount)
                end
            end)
        end
    end
	end
end)




RegisterServerEvent("redemrp_inventory:deleteInv")
AddEventHandler("redemrp_inventory:deleteInv", function(charid, Callback)
    local _source = source
    local id
    for k,v in ipairs(GetPlayerIdentifiers(_source))do
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            id = v
            break
        end
    end
    Inventory[id .. "_" .. charid] = nil
    Locker[id .. "_" .. charid] = nil
    MySQL.Async.fetchAll('DELETE FROM user_inventory WHERE `identifier`=@identifier AND `charid`=@charid;', {identifier = id, charid = charid}, function(result)
        end)
    MySQL.Async.fetchAll('DELETE FROM user_locker WHERE `identifier`=@identifier AND `charid`=@charid;', {identifier = id, charid = charid}, function(result)
        end)
end)

