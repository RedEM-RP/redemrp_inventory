RedEM = exports["redem_roleplay"]:RedEM()

local Inventory = {}
local InventoryWeight = {}
local Locker = {}
local Stash = {}
local DroppedItems = {}
local CreatedLockers = {}
local SharedInventoryFunctions = {}
local HandsUp = {}

local StashMaxWeights = {}

math.randomseed(os.time())
AddEventHandler(
    "redemrp_inventory:getData",
    function(cb)
        cb(SharedInventoryFunctions)
    end
)

RegisterServerEvent("redemrp_inventory:server:HandsUp", function(toggle)
    local _src = source
    HandsUp[_src] = toggle
end)

RedEM.RegisterCallback('redemrp_inventory:server:HasItem', function(source, cb, itemName)
	local Player = RedEM.GetPlayer(source)
    if Player then
        local Item = SharedInventoryFunctions.getItem(source, itemName)
        if Item.ItemAmount >= 1 then
            cb(true)
        else
            cb(false)
        end
    end
end)

AddEventHandler(
    "redemrp:playerLoaded",
    function(source, user)
        local _source = source
        local identifier = user.GetIdentifier()
        local charid = user.GetActiveCharacter()
        local job = user.GetJob()
        TriggerClientEvent("redemrp_inventory:UpdatePickups", _source, DroppedItems)
        MySQL.query(
            "SELECT * FROM user_inventory WHERE `identifier`=@identifier AND `charid`=@charid;",
            {identifier = identifier, charid = charid},
            function(db_items)
                if db_items[1] ~= nil then
                    local inv = json.decode(db_items[1].items)
                    Inventory[identifier .. "_" .. charid], InventoryWeight[identifier .. "_" .. charid] =
                        CreateInventory(inv)
                else
                    local start_items = {
                        ["water"] = {amount = 3, meta = {}},
                        ["bread"] = {amount = 3, meta = {}}
                    }
                    MySQL.update(
                        "INSERT INTO user_inventory (`identifier`, `charid`, `items`) VALUES (@identifier, @charid, @items);",
                        {
                            identifier = identifier,
                            charid = charid,
                            items = json.encode(start_items)
                        },
                        function(rowsChanged)
                        end
                    )
                    Inventory[identifier .. "_" .. charid], InventoryWeight[identifier .. "_" .. charid], _ =
                        CreateInventory(start_items)
                end
                TriggerClientEvent("redemrp_inventory:SendItems", _source, PrepareToOutput(Inventory[identifier .. "_" .. charid]),  {}, InventoryWeight[identifier .. "_" .. charid])
            end
        )
    end
)

RegisterServerEvent("redemrp_inventory:update")
AddEventHandler(
    "redemrp_inventory:update",
    function(_type, data, target, LockerID, stashId)
        local _source = source
        local _target = target
        if not data then
            print("update called from client ".._source.." with nil data")
            return
        end
        if not data.name then
            print("update called from client ".._source.." with nil data.name")
            return
        end
        local itemData = Config.Items[data.name]
        local Player = RedEM.GetPlayer(_source)
        local identifier = Player.GetIdentifier()
        local charid = Player.GetActiveCharacter()
        local lvl = 0
        local retVal = true
        if _target == 0 then
            if _type == "delete" then
                if removeItem(data.name, data.amount, data.meta, identifier, charid) then
                    if stashId then
                        retVal = addItemStash(_source, data.name, data.amount, data.meta, stashId)
                        if retVal == false then
                            addItem(data.name, data.amount, data.meta, identifier, charid, lvl)
                            TriggerClientEvent("redem_roleplay:NotifyLeft", _source, "Not enough space!", "This inventory is full.", "menu_textures", "menu_icon_alert", 3000)
                        end
                    end
                    if itemData.type == "item_weapon" then
                        TriggerClientEvent("redemrp_inventory:removeWeapon", _source, itemData.weaponHash)
                    end
                end
            elseif _type == "add" then
                if stashId then
                    if removeItemStash(_source, data.name, data.amount, data.meta, stashId) then
                        if not addItem(data.name, data.amount, data.meta, identifier, charid, lvl) then
                            addItemStash(_source, data.name, data.amount, data.meta, stashId)
                        end
                    end
                end
            end
            if stashId then
                TriggerClientEvent(
                    "redemrp_inventory:SendItems",
                    _source,
                    PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                    PrepareToOutput(Stash[stashId]),
                    InventoryWeight[identifier .. "_" .. charid],
                    true
                )
            elseif LockerID == "private" then
                TriggerClientEvent(
                    "redemrp_inventory:SendItems",
                    _source,
                    PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                    PrepareToOutput(Locker[identifier .. "_" .. charid]),
                    InventoryWeight[identifier .. "_" .. charid],
                    true
                )
            else
                TriggerClientEvent(
                    "redemrp_inventory:SendItems",
                    _source,
                    PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                    PrepareToOutput(Locker[LockerID]),
                    InventoryWeight[identifier .. "_" .. charid],
                    true
                )
            end
        else
            local TargetPlayer = RedEM.GetPlayer(_target)
            if TargetPlayer then
                local identifier_target = TargetPlayer.GetIdentifier()
                local charid_target = TargetPlayer.GetActiveCharacter()
                local lvl_target = 0

                local PlayerPos = GetEntityCoords(GetPlayerPed(_source))
                local TargetPos = GetEntityCoords(GetPlayerPed(_target))

                if #(PlayerPos - TargetPos) < 3.0 or Player.GetGroup() == "admin" or Player.GetGroup() == "superadmin" then
                    if _type == "delete" then
                        if removeItem(data.name, data.amount, data.meta, identifier, charid) then
                            if
                                not addItem(
                                    data.name,
                                    data.amount,
                                    data.meta,
                                    identifier_target,
                                    charid_target,
                                    lvl_target
                                )
                            then
                                addItem(data.name, data.amount, data.meta, identifier, charid, lvl)
                            else
                                if itemData.type == "item_weapon" then
                                    TriggerClientEvent(
                                        "redemrp_inventory:removeWeapon",
                                        _source,
                                        itemData.weaponHash
                                    )
                                end 
                            end
                        end
                    elseif _type == "add" then
                        if removeItem(data.name, data.amount, data.meta, identifier_target, charid_target) then
                            if not addItem(data.name, data.amount, data.meta, identifier, charid, lvl) then
                                addItem(
                                    data.name,
                                    data.amount,
                                    data.meta,
                                    identifier_target,
                                    charid_target,
                                    lvl_target
                                )
                            else
                                if itemData.type == "item_weapon" then
                                    TriggerClientEvent(
                                        "redemrp_inventory:removeWeapon",
                                        _target,
                                        itemData.weaponHash
                                    )
                                end
                            end
                        end
                    end
                else
                    TriggerClientEvent("redem_roleplay:NotifyRight", _source, "You are too far away!", 3000)
                    TriggerClientEvent("redemrp_inventory:closeinv", _source)
                end
                TriggerClientEvent(
                    "redemrp_inventory:SendItems",
                    _target,
                    PrepareToOutput(Inventory[identifier_target .. "_" .. charid_target]),
                    {},
                    InventoryWeight[identifier_target .. "_" .. charid_target]
                )
                TriggerClientEvent(
                    "redemrp_inventory:SendItems",
                    _source,
                    PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                    PrepareToOutput(Inventory[identifier_target .. "_" .. charid_target]),
                    InventoryWeight[identifier .. "_" .. charid],
                    true,
                    _target
                )
            end
        end
    end
)

----=======================SAVE ================================
AddEventHandler(
    "redemrp:playerDropped",
    function(_player)
        local player = _player
        local charid = player.GetActiveCharacter()
        local identifier = player.GetIdentifier()
        local player_inventory = Inventory[identifier .. "_" .. charid]
        local player_locker = Locker[identifier .. "_" .. charid]
        local ToSaveInventory = {}
        local ToSaveLocker = {}
        if player_inventory[1] ~= nil then
            for i, k in pairs(player_inventory) do
                table.insert(ToSaveInventory, {name = k.getName(), amount = k.getAmount(), meta = k.getMeta()})
            end
        end
        local JsonItemsInventory = json.encode(ToSaveInventory)
        MySQL.update(
            "UPDATE user_inventory SET items = @items WHERE identifier = @identifier AND charid = @charid",
            {
                ["@identifier"] = identifier,
                ["@charid"] = charid,
                ["@items"] = JsonItemsInventory
            },
            function(rowsChanged)
                if rowsChanged == 0 then
                    print(("user_inventory: Something went wrong saving %s!"):format(identifier .. ":" .. charid))
                else
                    print("Saved inventory on disconnect")
                end
            end
        )
        Inventory[identifier .. "_" .. charid] = nil
    end
)

AddEventHandler("txAdmin:events:serverShuttingDown", function(eventData)
    CreateThread(function()
        print("^4[DB]^0 5 seconds before restart... saving all stashes!")
        SaveStashes()
    end)
end)

RegisterCommand("savestashes", function(source, args)
    local Player = RedEM.GetPlayer(source)
    if Player.GetGroup() == "superadmin" then
        CreateThread(function()
            print("^4[DB]^0 Saving all stashes by admin command!")
            SaveStashes()
        end)
    end
end)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining == 60 then
        CreateThread(function()
            print("^4[DB]^0 60 seconds before restart... saving all stashes!")
            SaveStashes()
        end)
    end
end)

function savePlayerInventory()
    SetTimeout(
        900000,
        function()
            Citizen.CreateThread(
                function()
                    local saved = 0
                    for j, l in pairs(Inventory) do
                        local player_inventory = l
                        local identifier = j:sub(1, -3)
                        local charid = j:sub(#j, #j)
                        saved = saved + 1
                        local ToSaveInventory = {}
                        if player_inventory[1] ~= nil then
                            for i, k in pairs(player_inventory) do
                                table.insert(
                                    ToSaveInventory,
                                    {name = k.getName(), amount = k.getAmount(), meta = k.getMeta()}
                                )
                            end
                        end
                        local JsonItemsInventory = json.encode(ToSaveInventory)
                        MySQL.update(
                            "UPDATE user_inventory SET items = @items WHERE identifier = @identifier AND charid = @charid",
                            {
                                ["@identifier"] = identifier,
                                ["@charid"] = charid,
                                ["@items"] = JsonItemsInventory
                            },
                            function(rowsChanged)
                                if rowsChanged == 0 then
                                    print(
                                        ("user_inventory: Something went wrong saving %s!"):format(
                                            identifier .. ":" .. charid
                                        )
                                    )
                                else
                                end
                            end
                        )
                    end
                    print("^4[DB]^0 Saved ^3"..saved.."^0 player inventories.")
                    savePlayerInventory()
                end
            )
        end
    )
end

savePlayerInventory()

function SaveAllPlayersInv()
    Citizen.CreateThread(
        function()
            local saved = 0
            for j, l in pairs(Inventory) do
                local player_inventory = l
                local identifier = j:sub(1, -3)
                local charid = j:sub(#j, #j)
                saved = saved + 1
                local ToSaveInventory = {}
                if player_inventory[1] ~= nil then
                    for i, k in pairs(player_inventory) do
                        table.insert(
                            ToSaveInventory,
                            {name = k.getName(), amount = k.getAmount(), meta = k.getMeta()}
                        )
                    end
                end
                local JsonItemsInventory = json.encode(ToSaveInventory)
                MySQL.update(
                    "UPDATE user_inventory SET items = @items WHERE identifier = @identifier AND charid = @charid",
                    {
                        ["@identifier"] = identifier,
                        ["@charid"] = charid,
                        ["@items"] = JsonItemsInventory
                    },
                    function(rowsChanged)
                        if rowsChanged == 0 then
                            print(
                                ("user_inventory: Something went wrong saving %s!"):format(
                                    identifier .. ":" .. charid
                                )
                            )
                        else
                        end
                    end
                )
            end
            print("^4[DB]^0 Saved ^3"..saved.."^0 inventories.")
        end
    )
end

----=======================SAVE ================================

--==================== D R O P =======================================

RegisterServerEvent("redemrp_inventory:drop")
AddEventHandler("redemrp_inventory:drop",function(data, letterSend)
    letterSend = letterSend or false
    local _source = source
    local itemData = Config.Items[data.name]
    if data.name == "letter" and letterSend then
        TriggerClientEvent("redemrp_inventory:CreateLetterPickup",
            _source,
            data.name,
            data.amount,
            data.meta,
            itemData.label,
            itemData.imgsrc
        )
    elseif itemData.canBeDropped then
        print("drop")
        local user = RedEM.GetPlayer(_source)
        local identifier = user.GetIdentifier()
        local charid = user.GetActiveCharacter()
        local output = removeItem(data.name, data.amount, data.meta, identifier, charid)
        if output then
            TriggerClientEvent(
                "redemrp_inventory:SendItems",
                _source,
                PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                {},
                InventoryWeight[identifier .. "_" .. charid]
            )
            if data.name == "letter" then
                TriggerClientEvent("redemrp_inventory:CreateLetterPickup",
                    _source,
                    data.name,
                    data.amount,
                    data.meta,
                    itemData.label,
                    itemData.imgsrc
                )
            else
                TriggerClientEvent(
                    "redemrp_inventory:CreatePickup",
                    _source,
                    data.name,
                    data.amount,
                    data.meta,
                    itemData.label,
                    itemData.imgsrc
                )
            end
            if itemData.type == "item_weapon" then
                TriggerClientEvent("redemrp_inventory:removeWeapon", _source, itemData.weaponHash)
            end
        end
    end
end)

RegisterServerEvent("redemrp_inventory:giveItem")
AddEventHandler(
    "redemrp_inventory:giveItem",
    function(data, toPlayer)
        local _source = source
        local itemData = Config.Items[data.name]

        if not toPlayer then return print("ERROR: Nil player target") end
        local Player = RedEM.GetPlayer(_source)
        local identifier = Player.GetIdentifier()
        local charid = Player.GetActiveCharacter()
        if removeItem(data.name, data.amount, data.meta, identifier, charid) then
            TriggerClientEvent(
                "redemrp_inventory:SendItems",
                _source,
                PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                {},
                InventoryWeight[identifier .. "_" .. charid]
            )
            local ToPlayer = RedEM.GetPlayer(toPlayer)
            local identifier2 = ToPlayer.GetIdentifier()
            local charid2 = ToPlayer.GetActiveCharacter()
            if addItem(data.name, data.amount, data.meta, identifier2, charid2) then
                TriggerClientEvent(
                    "redemrp_inventory:SendItems",
                    toPlayer,
                    PrepareToOutput(Inventory[identifier2 .. "_" .. charid2]),
                    {},
                    InventoryWeight[identifier2 .. "_" .. charid2]
                )
                if itemData.type == "item_weapon" then
                    TriggerClientEvent("redemrp_inventory:removeWeapon", _source, itemData.weaponHash)
                end
                TriggerClientEvent("redem_roleplay:NotifyRight", toPlayer, "You were given "..data.amount.."x "..itemData.label, 3000)
                TriggerClientEvent("redem_roleplay:NotifyRight", _source, "You gave "..data.amount.."x "..itemData.label, 3000)
            else
                addItem(data.name, data.amount, data.meta, identifier, charid)
                TriggerClientEvent(
                    "redemrp_inventory:SendItems",
                    _source,
                    PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                    {},
                    InventoryWeight[identifier .. "_" .. charid]
                )
            end
        else
            print("error removing item")
        end
    end
)

RegisterServerEvent("redemrp_inventory:AddPickupServer")
AddEventHandler(
    "redemrp_inventory:AddPickupServer",
    function(name, amount, meta, label, img, x, y, z, id)
        DroppedItems[id] = {
            name = name,
            meta = meta,
            amount = amount,
            label = label,
            img = img,
            inRange = false,
            coords = {x = x, y = y, z = z},
            time = os.time()
        }
        TriggerClientEvent("redemrp_inventory:UpdatePickups", -1, DroppedItems)
    end
)

local otodropitemdelete = 120 -- second for each item
Citizen.CreateThread(function()
    while true do
        Wait(5000)
        for k, v in pairs(DroppedItems) do
            if v.time + otodropitemdelete < os.time() then
                DroppedItems[k] = nil
                TriggerClientEvent('redemrp_inventory:removePickup', -1, k)
            end
        end
        TriggerClientEvent("redemrp_inventory:UpdatePickups", -1, DroppedItems)
    end
end)

RegisterCommand("deletedrops", function(source, args)
    local _source = source
    local Player = RedEM.GetPlayer(_source)
    if Player.GetGroup() == "admin" or Player.GetGroup() == "superadmin" then
        DroppedItems = {}
        TriggerClientEvent("redemrp_inventory:UpdatePickups", -1, DroppedItems)
        TriggerClientEvent("redem_roleplay:NotifyRight", _source, "Deleted all dropped items.", 3000)
    end
end)

RegisterServerEvent("redemrp_inventory:RemoveAllPickups", function()
    local _source = source
    local Player = RedEM.GetPlayer(_source)
    if Player.GetGroup() == "admin" or Player.GetGroup() == "superadmin" then
        DroppedItems = {}
        TriggerClientEvent("redemrp_inventory:UpdatePickups", -1, DroppedItems)
        TriggerClientEvent("redem_roleplay:NotifyRight", _source, "Deleted all dropped items.", 3000)
    end
end)

RegisterServerEvent("redemrp_inventory:onPickup")
AddEventHandler(
    "redemrp_inventory:onPickup",
    function(id)
        local _source = source
        local Player = RedEM.GetPlayer(_source)
        local identifier = Player.GetIdentifier()
        local charid = Player.GetActiveCharacter()
        local lvl = 0
        if
            addItem(
                DroppedItems[id].name,
                DroppedItems[id].amount,
                DroppedItems[id].meta,
                identifier,
                charid,
                lvl
            )
            then
            TriggerClientEvent(
                "redemrp_inventory:SendItems",
                _source,
                PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                {},
                InventoryWeight[identifier .. "_" .. charid]
            )
            TriggerClientEvent("redemrp_inventory:removePickup", -1, id)
            TriggerClientEvent("redemrp_inventory:PickupAnim", _source)
            TriggerClientEvent(
                "pNotify:SendNotification",
                _source,
                {
                    text = "<img src='nui://redemrp_inventory/html/" ..
                        DroppedItems[id].img ..
                            "' height='40' width='40' style='float:left; margin-bottom:10px; margin-left:20px;' />Pickup: " ..
                                DroppedItems[id].label .. "<br>+" .. tonumber(DroppedItems[id].amount),
                    type = "success",
                    timeout = math.random(2000, 3000),
                    layout = "centerRight",
                    queue = "right"
                }
            )
            DroppedItems[id] = nil
            TriggerClientEvent("redemrp_inventory:UpdatePickups", -1, DroppedItems)
        else
            TriggerClientEvent("redem_roleplay:NotifyRight", _source, "You cannot pick this up!", 3000)
        end
        TriggerClientEvent("redemrp_inventory:ReEnablePrompt", _source)
    end
)

--==================== D R O P =======================================

--==================== U S E =======================================
RegisterServerEvent("redemrp_inventory:use")
AddEventHandler(
    "redemrp_inventory:use",
    function(data)
        local _source = source
        local itemData = Config.Items[data.name]
        local Player = RedEM.GetPlayer(_source)
        if itemData.canBeUsed then
            TriggerEvent("RegisterUsableItem:" .. data.name, _source, data)
            --TriggerClientEvent("ak_notification:Left", _source, "Użyto przedmiotu", itemData.label, tonumber(1000))
            TriggerClientEvent("redem_roleplay:NotifyLeft", _source, "Item Used", itemData.label, "generic_textures", "tick", 3000)
            TriggerClientEvent("redemrp_inventory:PlaySound", _source, 1)
        end
        if itemData.type == "item_letter" then
            TriggerEvent("redemrp_pigeoncarrier:server:UseLetter", _source, data)
            TriggerClientEvent("redemrp_inventory:closeinv", _source)
        end
        if itemData.type == "item_weapon" then
            TriggerClientEvent(
                "redemrp_inventory:UseWeapon",
                _source,
                itemData.weaponHash,
                data.amount,
                data.meta,
                data.name
            )
            TriggerClientEvent("redem_roleplay:NotifyLeft", _source, "Weapon Equipped", data.label, "menu_textures", "menu_icon_holster", 1000)
            TriggerClientEvent("redemrp_inventory:PlaySound", _source, 1)
        end
    end
)

--==================== U S E =======================================

RegisterServerEvent("weapons:server:ApplyDamage")
AddEventHandler(
    "weapons:server:ApplyDamage",
    function(table)
        local _source = source
        local _table = table
        local Player = RedEM.GetPlayer(_source)
        if Player then
            local identifier = Player.GetIdentifier()
            local charid = Player.GetActiveCharacter()
            local player_inventory = Inventory[identifier .. "_" .. charid]
            for i, k in pairs(_table) do
                local item, id = getInventoryItemFromName(k.name, player_inventory, {})
                if item then
                    if not k.meta.damage then
                        k.meta.damage = 0.0
                    end
                    if not k.meta.dirt then
                        k.meta.dirt = 0.0
                    end
                    --print("Saved weapon damage "..k.meta.damage.." and dirt "..k.meta.dirt.." for weapon "..k.name)
                    item.setMeta(k.meta)
                    TriggerClientEvent(
                        "redemrp_inventory:SendItems",
                        _source,
                        PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                        {},
                        InventoryWeight[identifier .. "_" .. charid]
                    )
                end
            end
        end
    end
)

RegisterServerEvent("redemrp_inventory:ChangeAmmoAmount")
AddEventHandler(
    "redemrp_inventory:ChangeAmmoAmount",
    function(table)
        local _source = source
        local _table = table
        local Player = RedEM.GetPlayer(_source)
        if Player then
            local identifier = Player.GetIdentifier()
            local charid = Player.GetActiveCharacter()
            local player_inventory = Inventory[identifier .. "_" .. charid]
            for i, k in pairs(_table) do
                local item, id = getInventoryItemFromName(k.name, player_inventory, k.meta)
                if item then
                    item.setAmount(tonumber(k.Ammo))
                end
            end
        end
    end
)

RegisterCommand("listitems", function(source,args)
    local _source = source
    local Player = RedEM.GetPlayer(_source)
    if Player.GetGroup() == "superadmin" or Player.GetGroup() == "admin" then
        local itemsList = ""
        local counter = 0
        for k,v in pairs(Config.Items) do
            counter = counter + 1
            itemsList = itemsList .. k .. ", "
        end
        print(counter .." items")
        print(itemsList)
    else
        return TriggerClientEvent("redem_roleplay:NotifyRight", _source, "Insufficient permissions!", 3000)
    end
end)

RegisterCommand("lookupitem", function(source, args)
    local _source = source
    local Player = RedEM.GetPlayer(_source)
    if Player.GetGroup() == "superadmin" or Player.GetGroup() == "admin" then
        if not args[1] then
            return TriggerClientEvent("redem_roleplay:NotifyRight", _source, "/lookupitem [Item Partial Name]", 3000)
        end
        local itemsList = ""
        local counter = 0
        for k,v in pairs(Config.Items) do
            if string.find(k, args[1]) then
                counter = counter + 1
                itemsList = itemsList .. k .. ", "
            end
        end
        print(counter .." items")
        print(itemsList)
    else
        return TriggerClientEvent("redem_roleplay:NotifyRight", _source, "Insufficient permissions!", 3000)
    end
end)

RegisterCommand(
    "giveitem",
    function(source, args)
        local _source = source
        local Player = RedEM.GetPlayer(_source)
        if Player.GetGroup() == "admin" or Player.GetGroup() == "superadmin" then
            if not args[1] or not args[2] or not args[3] then
                return TriggerClientEvent("redem_roleplay:NotifyRight", _source, "/giveitem [Player ID] [Item Name] [Amount]", 3000)
            end
            local TargetPlayer = RedEM.GetPlayer(args[1])
            if not TargetPlayer then
                return TriggerClientEvent("redem_roleplay:NotifyRight", _source, "Invalid player.", 3000)
            end
            local identifier = TargetPlayer.GetIdentifier()
            local charid = TargetPlayer.GetActiveCharacter()
            local lvl = 0
            local retVal = addItem(args[2], tonumber(args[3]), {}, identifier, charid, lvl)
            if retVal ~= -1 then
                if retVal then
                    TriggerClientEvent("redem_roleplay:NotifyRight", _source, "You gave "..GetPlayerName(tonumber(args[1])).." "..args[3].."x "..args[2].."!", 3000)
                    TriggerClientEvent("redem_roleplay:NotifyRight", tonumber(args[1]), "You were given "..args[3].."x "..args[2].." by server staff!", 3000)
                    TriggerClientEvent(
                        "redemrp_inventory:SendItems",
                        tonumber(args[1]),
                        PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                        {},
                        InventoryWeight[identifier .. "_" .. charid]
                    )
                else
                    TriggerClientEvent("redem_roleplay:NotifyRight", _source, "There was an error! Possibly the player has no room or hit limit?", 3000)
                end
            else
                TriggerClientEvent("redem_roleplay:NotifyRight", _source, "There was an error! Possibly the item doesn't exist?", 3000)
            end
        else
            TriggerClientEvent("redem_roleplay:NotifyRight", _source, "Insufficient permissions!", 3000)
        end
    end
)

RegisterCommand(
    "removeitem",
    function(source, args)
        local _source = source
        local Player = RedEM.GetPlayer(_source)

        if Player.GetGroup() == "admin" or Player.GetGroup() == "superadmin" then
            if not args[1] or not args[2] or not args[3] then
                return TriggerClientEvent("redem_roleplay:NotifyRight", _source, "/removeitem [Player ID] [Item Name] [Amount]", 3000)
            end
            local TargetPlayer = RedEM.GetPlayer(tonumber(args[1]))
            if not TargetPlayer then
                return TriggerClientEvent("redem_roleplay:NotifyRight", _source, "Invalid player.", 3000)
            end
            local identifier = TargetPlayer.GetIdentifier()
            local charid = TargetPlayer.GetActiveCharacter()
            local lvl = 0
            local retVal = removeItem(args[2], tonumber(args[3]), {}, identifier, charid, lvl)
            if retVal ~= -1 then
                TriggerClientEvent("redem_roleplay:NotifyRight", _source, "You removed "..args[3].."x "..args[2].." from "..GetPlayerName(tonumber(args[1])).."!", 3000)
                TriggerClientEvent("redem_roleplay:NotifyRight", tonumber(args[1]), "You had "..args[3].."x "..args[2].." removed by server staff!", 3000)
                TriggerClientEvent(
                    "redemrp_inventory:SendItems",
                    tonumber(args[1]),
                    PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                    {},
                    InventoryWeight[identifier .. "_" .. charid]
                )
            else
                TriggerClientEvent("redem_roleplay:NotifyRight", _source, "There was an error! Possibly the item doesn't exist?", 3000)
            end
        else
            TriggerClientEvent("redem_roleplay:NotifyRight", _source, "Insufficient permissions!", 3000)
        end
    end
)

function getInventoryItemFromName(name, items_table, meta)
    for i, k in pairs(items_table) do
        if meta ~= "empty" then
            if next(meta) == nil then
                if name == k.getName() then
                    return items_table[i], i
                end
            else
                if name == k.getName() then
                    if deep_compare(meta, k.getMeta()) then
                        return items_table[i], i
                    end
                end
            end
        else
            if name == k.getName() and next(k.getMeta()) == nil then
                return items_table[i], i
            end
        end
    end
    return false, false
end


function print_table(node)
    local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k,v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k,v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str,"}",output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str,"\n",output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "["..tostring(k).."]"
                else
                    key = "['"..tostring(k).."']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                    table.insert(stack,node)
                    table.insert(stack,v)
                    cache[node] = cur_index+1
                    break
                else
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output,output_str)
    output_str = table.concat(output)

    print(output_str)
end

function getMetaOutput(m)
    if m == "empty" then
        return m
    else
        local meta = m or {}
        if next(meta) == nil then
            meta = "empty"
        end
        return meta
    end
end

function addItem(name, amount, meta, identifier, charid, lvl)
    local _name = name
    local _amount = tonumber(amount)
    local _meta = meta or {}
    local output = false
    if _name == nil or _amount == nil then
        print("^6[redemrp_inventory]^0 Invalid add item parameters (name or amount)")
        return -1
    end
    if _amount >= 0 then
        if not Config.Items[_name] then
            print("^6[redemrp_inventory]^0 Attempted to add an invalid item. (".._name..")")
            return -1
        end
        local itemData = Config.Items[_name]
        if not _meta.uid and itemData.type == "item_weapon" then
            local numBase0 = math.random(100, 999)
            local numBase1 = math.random(0, 9999)
            local generetedUid = string.format("%03d%04d", numBase0, numBase1)
            _meta.uid = generetedUid
        end
        local item, id = getInventoryItemFromName(_name, Inventory[identifier .. "_" .. charid], getMetaOutput(meta))
        if not item then
            if itemData.type == "item_standard" then
                if _amount > 0 then
                    if
                        InventoryWeight[identifier .. "_" .. charid] + (itemData.weight * _amount) <=
                            Config.MaxWeight and itemData.limit >= _amount
                        then
                        table.insert(Inventory[identifier .. "_" .. charid], CreateItem(_name, _amount, _meta))
                        InventoryWeight[identifier .. "_" .. charid] =
                            InventoryWeight[identifier .. "_" .. charid] + (itemData.weight * _amount)
                        output = true
                    end
                end
            elseif itemData.type == "item_weapon" or itemData.type == "item_letter" then
                if InventoryWeight[identifier .. "_" .. charid] + itemData.weight <= Config.MaxWeight then
                    table.insert(Inventory[identifier .. "_" .. charid], CreateItem(_name, _amount, _meta))
                    InventoryWeight[identifier .. "_" .. charid] =
                        InventoryWeight[identifier .. "_" .. charid] + itemData.weight
                    output = true
                else
                    print("Weight")
                end
            end
        else
            if itemData.type == "item_standard" then
                if _amount > 0 then
                    if
                        InventoryWeight[identifier .. "_" .. charid] + (itemData.weight * _amount) <=
                            Config.MaxWeight and itemData.limit >= _amount + item.getAmount()
                        then
                        item.addAmount(_amount)
                        InventoryWeight[identifier .. "_" .. charid] =
                            InventoryWeight[identifier .. "_" .. charid] + (itemData.weight * _amount)
                        output = true
                    end
                end
            end
        end
        local charName = ""
        local playerName = ""
        local FoundPlayer = false
    end
    return output
end

function removeItem(name, amount, meta, identifier, charid)
    local _name = name
    local _amount = tonumber(amount)
    local _meta = meta or {}
    local output = false
    if _amount >= 0 then
        local itemData = Config.Items[_name]
        local player_inventory = Inventory[identifier .. "_" .. charid]
        local item, id = getInventoryItemFromName(_name, player_inventory, getMetaOutput(meta))
        if item then
            if itemData.type == "item_standard" then
                if _amount > 0 then
                    if item.getAmount() >= _amount then
                        if item.removeAmount(_amount) then
                            table.remove(player_inventory, id)
                        end
                        InventoryWeight[identifier .. "_" .. charid] =
                        InventoryWeight[identifier .. "_" .. charid] - (itemData.weight * _amount)
                        output = true
                    end
                end
            elseif itemData.type == "item_weapon" or itemData.type == "item_letter" then
                table.remove(player_inventory, id)
                InventoryWeight[identifier .. "_" .. charid] =
                    InventoryWeight[identifier .. "_" .. charid] - itemData.weight
                output = true
            end
        else
            print("Couldnt find item to remove? ["..name..", "..amount..", "..json.encode(meta).."]")
        end
        local charName = ""
        local FoundPlayer = false
    end
    return output
end

function addItemStash(source, name, amount, meta, stashId)
    local _source = source
    local Player = RedEM.GetPlayer(_source)
    local _name = name
    local _amount = tonumber(amount)
    local output = false
    local _meta = meta or {}
    if _amount >= 0 then
        local itemData = Config.Items[_name]
        local stash = Stash[stashId]
        local item, id = getInventoryItemFromName(_name, stash, getMetaOutput(meta))
        local weight = GetStashWeight(stashId)

        local weightLimit = StashMaxWeights[_source] or 60.0
        if itemData.type == "item_weapon" or itemData.type == "item_letter" then
            --("Boss stash weight: ".. weight .." vs ".. weightLimit)
            TriggerClientEvent("redemrp_inventory:client:WeightNotif", _source, "Storage Weight: ~n~"..string.format("%.2f", weight + (itemData.weight)).."kg / "..string.format("%.2f", weightLimit).."kg", 2000)
            --(weight + (itemData.weight * amount))
            if weight + (itemData.weight) > weightLimit then
                return output
            end
        else
            --("Boss stash weight: ".. weight .." vs ".. weightLimit)
            TriggerClientEvent("redemrp_inventory:client:WeightNotif", _source, "Storage Weight: ~n~"..string.format("%.2f", weight + (itemData.weight * amount)).."kg / "..string.format("%.2f", weightLimit).."kg", 2000)
            --(weight + (itemData.weight * amount))
            if weight + (itemData.weight * amount) > weightLimit then
                return output
            end
        end
        
        if not item then
            if itemData.type == "item_standard" then
                if _amount > 0 then
                    table.insert(stash, CreateItem(_name, _amount, _meta))
                    output = true
                end
            elseif itemData.type == "item_weapon" or itemData.type == "item_letter" then
                if not _meta.uid and itemData.type == "item_weapon" then
                    local numBase0 = math.random(100, 999)
                    local numBase1 = math.random(0, 9999)
                    local generetedUid = string.format("%03d%04d", numBase0, numBase1)
                    _meta.uid = generetedUid
                end
                table.insert(stash, CreateItem(_name, _amount, _meta))
                output = true
            end
        else
            if _amount > 0 then
                if itemData.type == "item_standard" then
                    item.addAmount(_amount)
                    output = true
                end
            end
        end
    end
    return output
end

function removeItemStash(source, name, amount, meta, stashId)
    local _source = source
    local Player = RedEM.GetPlayer(_source)
    local _name = name
    local _amount = tonumber(amount)
    local _meta = meta or {}
    local output = false
    if _amount >= 0 then
        local itemData = Config.Items[_name]
        local stash = Stash[stashId]
        local item, id = getInventoryItemFromName(_name, stash, getMetaOutput(meta))
        local weight = GetStashWeight(stashId)

        if item then
            --print(item.getAmount(), _amount)
            if itemData.type == "item_standard" then
                if _amount > 0 then
                    if item.getAmount() >= _amount then
                        if item.removeAmount(_amount) then
                            table.remove(stash, id)
                        end
                        output = true
                    end
                end
            elseif itemData.type == "item_weapon" or itemData.type == "item_letter" then
                table.remove(stash, id)
                output = true
            end
        end
    end
    
    local weightLimit = StashMaxWeights[_source] or 60.0
    --print("Bank stash weight: ".. weight .." vs ".. weightLimit)
    TriggerClientEvent("redemrp_inventory:client:WeightNotif", _source, "Storage Weight: ~n~"..string.format("%.2f", GetStashWeight(stashId)).."kg / "..string.format("%.2f", weightLimit).."kg", 2000)
    return output
end

Citizen.CreateThread(function ()
    MySQL.query(
        "SELECT * FROM stashes;",
        {},
        function(db_stashes)
            if db_stashes[1] ~= nil then
                for k,v in pairs(db_stashes) do
                    local StashData = json.decode(db_stashes[k].items)
                    Stash[db_stashes[k].stashid], _ = CreateInventory(StashData)
                end
            end
        end
    )
end)

exports('GetStashWeight', GetStashWeight)
GetStashWeight = function(stashId)
    local weight = 0
    if Stash[stashId] ~= nil then
        for i, j in pairs(Stash[stashId]) do
            if j.getData().type == "item_weapon" then
                weight = weight + j.getData().weight
            else
                weight = weight + (j.getData().weight * j.getAmount())
            end
        end
    end
    return weight
end


stashesSaved = 0


Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(300000)
        SaveStashes()
    end
end)

AddEventHandler(
    "onResourceStop",
    function(resourceName)
        if resourceName == GetCurrentResourceName() then
            SaveStashes()
        end
    end
)

function SaveStashes()
    stashesSaved = 0
    for k,v in pairs(Stash) do
        local _Stash = {}
        local ToSaveInventory = {}
        local ToSaveStash = {}
        if v[1] ~= nil then
            for i, j in pairs(v) do
                table.insert(ToSaveStash, {name = j.getName(), amount = j.getAmount(), meta = j.getMeta()})
            end
        end
        local JsonItemsStash = json.encode(ToSaveStash)
        MySQL.query(
            "SELECT * FROM stashes WHERE `stashid`=@stashid;",
            {
                stashid = k,
            },
            function(db_items)
                if db_items[1] == nil then
                    MySQL.update(
                        "INSERT INTO stashes (`stashid`, `items`) VALUES (@stashid, @items);",
                        {
                            ["@stashid"] = k,
                            ["@items"] = JsonItemsStash
                        },
                        function(rowsChanged)
                        end
                    )
                    stashesSaved = stashesSaved + 1
                else
                    MySQL.update(
                        "UPDATE stashes SET items = @items WHERE stashid = @stashid",
                        {
                            ["@stashid"] = k,
                            ["@items"] = JsonItemsStash
                        },
                        function(rowsChanged)
                        end
                    )
                    stashesSaved = stashesSaved + 1
                end
            end
        )
    end
    Citizen.Wait(1000)
    print("^4[DB]^0 Saved ^3"..stashesSaved.."^0 stashes.")
end

RegisterServerEvent("redemrp_inventory:GetStash",
    function(id, weight)
        --print(weight)
        local _source = source
        local Player = RedEM.GetPlayer(_source)

        local identifier = Player.GetIdentifier()
        local charid = Player.GetActiveCharacter()
        local job = Player.GetJob()

        StashMaxWeights[_source] = weight

        if Stash[id] then
            TriggerClientEvent(
                "redemrp_inventory:SendItems",
                _source,
                PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                PrepareToOutput(Stash[id]),
                InventoryWeight[identifier .. "_" .. charid],
                true
            )
        else
            Stash[id] = {}
            TriggerClientEvent(
                "redemrp_inventory:SendItems",
                _source,
                PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                {},
                InventoryWeight[identifier .. "_" .. charid],
                true
            )
        end
    end
)


RegisterServerEvent("redemrp_inventory:GetPlayer",
    function(target, hogtied)
        local _source = source
        local _target = target
        local Player = RedEM.GetPlayer(_source)
        local TargetPlayer = RedEM.GetPlayer(_target)

        local identifier = Player.GetIdentifier()
        local charid = Player.GetActiveCharacter()

        TriggerEvent("redemrp_respawn:IsPlayerDead", _target, function(isDead)
            if isDead then
                return TriggerClientEvent("redem_roleplay:NotifyLeft", _source, "Cannot search!", "Cannot search downed players.", "menu_textures", "menu_icon_alert", 3000)
            end
            if HandsUp[_target] or hogtied then
                if not exports["redem_roleplay"]:RedEM().CrimeDisabled then
                    local identifier_target = TargetPlayer.GetIdentifier()
                    local charid_target = TargetPlayer.GetActiveCharacter()
                    TriggerClientEvent("redem_roleplay:NotifyRight", _source, "Player Cash: $"..comma_value(string.format("%.2f", TargetPlayer.getMoney())), 3000)
                    TriggerClientEvent(
                        "redemrp_inventory:SendItems",
                        _source,
                        PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                        PrepareToOutput(Inventory[identifier_target .. "_" .. charid_target]),
                        InventoryWeight[identifier .. "_" .. charid],
                        true,
                        _target
                    )
                else
                    TriggerClientEvent("redem_roleplay:NotifyRight", _source, "You cannot rob anyone <span style=\"color:lightblue\">30 minutes</span> before a storm!", 3000)
                end
            else
                TriggerClientEvent("redem_roleplay:NotifyLeft", _source, "Cannot search!", "Player must have their hands up or be hogtied.", "menu_textures", "menu_icon_alert", 3000)
            end
        end)
    end
)

function comma_value(amount)
    local formatted = amount
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
            break
        end
    end
    return formatted
end

RegisterServerEvent("redemrp_inventory:GetPlayerAsPolice",
    function(target)
        local _source = source
        local _target = target
        local Player = RedEM.GetPlayer(_source)
        local TargetPlayer = RedEM.GetPlayer(_target)

        local identifier = Player.GetIdentifier()
        local charid = Player.GetActiveCharacter()

        if Player.GetJob() == "police" or Player.GetJob() == "police2" or Player.GetJob() == "police3" or Player.GetJob() == "police4" or Player.GetJob() == "police5" or Player.GetJob() == "marshal" or Player.GetJob() == "ranger" then
            local identifier_target = TargetPlayer.GetIdentifier()
            local charid_target = TargetPlayer.GetActiveCharacter()
            TriggerClientEvent(
                "redemrp_inventory:SendItems",
                _source,
                PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                PrepareToOutput(Inventory[identifier_target .. "_" .. charid_target]),
                InventoryWeight[identifier .. "_" .. charid],
                true,
                _target
            )
        else
            TriggerClientEvent("redem_roleplay:NotifyLeft", _source, "Cannot search!", "You must be police to use this.", "menu_textures", "menu_icon_alert", 3000)
        end
    end
)

RegisterServerEvent("redemrp_inventory:OpenPlayerInventory",
    function(sourceId, target)
        local _source = sourceId
        local _target = target
        local Player = RedEM.GetPlayer(_source)
        local TargetPlayer = RedEM.GetPlayer(_target)

        local identifier = Player.GetIdentifier()
        local charid = Player.GetActiveCharacter()

        local identifier_target = TargetPlayer.GetIdentifier()
        local charid_target = TargetPlayer.GetActiveCharacter()

        TriggerClientEvent(
            "redemrp_inventory:SendItems",
            _source,
            PrepareToOutput(Inventory[identifier .. "_" .. charid]),
            PrepareToOutput(Inventory[identifier_target .. "_" .. charid_target]),
            InventoryWeight[identifier .. "_" .. charid],
            true,
            _target
        )
    end
)

function SharedInventoryFunctions.getItemData(name)
    return Config.Items[name]
end

function SharedInventoryFunctions.getPlayerInventory(_source)
    local output = {}
    local Player = RedEM.GetPlayer(_source)

    local identifier = Player.GetIdentifier()
    local charid = Player.GetActiveCharacter()
    local player_inventory = Inventory[identifier .. "_" .. charid]
    output = PrepareToOutput(player_inventory)

    return output
end

function SharedInventoryFunctions.removePlayerInventory(_source)
    local Player = RedEM.GetPlayer(_source)

    local identifier = Player.GetIdentifier()
    local charid = Player.GetActiveCharacter()
    Inventory[identifier .. "_" .. charid] = {}
    InventoryWeight[identifier .. "_" .. charid] = 0.0
    TriggerClientEvent(
        "redemrp_inventory:SendItems",
        _source,
        PrepareToOutput(Inventory[identifier .. "_" .. charid]),
        {},
        InventoryWeight[identifier .. "_" .. charid]
    )
end

function SharedInventoryFunctions.getItem(source, name, meta)
    local _source = source
    local data = {}
    if name ~= nil then
        local user = RedEM.GetPlayer(_source)
        local identifier = user.GetIdentifier()
        local charid = user.GetActiveCharacter()
        local player_inventory = Inventory[identifier .. "_" .. charid]
        local lvl = 0
        local item, id = getInventoryItemFromName(name, player_inventory, meta or {})

        if item then
            data.ItemInfo = item.getData()
            data.ItemMeta = item.getMeta()
            data.ItemAmount = item.getAmount()
            function data.getAllItemOfName(name)
                local fullInventory = PrepareToOutput(Inventory[identifier .. "_" .. charid])
                local output = {}
                for k, v in pairs(fullInventory) do
                    if v.name == name then
                        table.insert(output, v)
                    end
                end
                return output
            end
            function data.ChangeMeta(m)
                item.setMeta(m)
                TriggerClientEvent(
                    "redemrp_inventory:SendItems",
                    _source,
                    PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                    {},
                    InventoryWeight[identifier .. "_" .. charid]
                )
            end
            function data.AddItem(amount, makepickup)
                local output = false
                if data.ItemInfo.type == "item_weapon" then
                    data.ItemMeta = meta or {}
                end
                if data.ItemInfo.type == "item_letter" then
                    data.ItemMeta = meta or {}
                end
                output = addItem(name, amount, data.ItemMeta, identifier, charid, lvl)
                if not output then
                    if data.ItemInfo.type ~= "item_weapon" then
                        local freeWeight = Config.MaxWeight - InventoryWeight[identifier .. "_" .. charid]
                        local canBeAdded = math.floor(freeWeight / data.ItemInfo.weight)
                        if canBeAdded > amount then
                            canBeAdded = data.ItemInfo.limit - data.ItemAmount
                        end
                        output = addItem(name, canBeAdded, data.ItemMeta, identifier, charid, lvl)
                        if amount - canBeAdded > 0 then
                            if makepickup == nil or makepickup == true then
                                TriggerClientEvent(
                                    "redemrp_inventory:CreatePickup",
                                    _source,
                                    name,
                                    amount - canBeAdded,
                                    data.ItemMeta,
                                    data.ItemInfo.label,
                                    data.ItemInfo.imgsrc
                                )
                            end
                        end
                    else
                        TriggerClientEvent(
                            "redemrp_inventory:CreatePickup",
                            _source,
                            name,
                            amount,
                            data.ItemMeta,
                            data.ItemInfo.label,
                            data.ItemInfo.imgsrc
                        )
                        TriggerClientEvent("redemrp_inventory:removeWeapon", _source, data.ItemInfo.weaponHash)
                    end
                end
                if output then
                    TriggerClientEvent(
                        "redemrp_inventory:SendItems",
                        _source,
                        PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                        {},
                        InventoryWeight[identifier .. "_" .. charid]
                    )
                end
                return output
            end
            function data.RemoveItem(amount)
                local output = false
                output = removeItem(name, amount, data.ItemMeta, identifier, charid)
                if output then
                    TriggerClientEvent(
                        "redemrp_inventory:SendItems",
                        _source,
                        PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                        {},
                        InventoryWeight[identifier .. "_" .. charid]
                    )
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
            function data.AddItem(amount, makepickup)
                local output = false
                output = addItem(name, amount, meta, identifier, charid, lvl)
                if not output then
                    if data.ItemInfo.type ~= "item_weapon" then
                        local freeWeight = Config.MaxWeight - InventoryWeight[identifier .. "_" .. charid]
                        local canBeAdded = math.floor(freeWeight / data.ItemInfo.weight)
                        if canBeAdded > amount then
                            canBeAdded = data.ItemInfo.limit
                        end
                        if canBeAdded > 0 then
                            if makepickup == nil or makepickup == true then
                                output = addItem(name, canBeAdded, meta, identifier, charid, lvl)
                                TriggerClientEvent(
                                    "redemrp_inventory:CreatePickup",
                                    _source,
                                    name,
                                    amount - canBeAdded,
                                    meta or {},
                                    data.ItemInfo.label,
                                    data.ItemInfo.imgsrc
                                )
                            else
                                output = false
                            end
                        end
                    else
                        local freeWeight = Config.MaxWeight - InventoryWeight[identifier .. "_" .. charid]
                        if freeWeight < data.ItemInfo.weight then
                            TriggerClientEvent(
                                "redemrp_inventory:CreatePickup",
                                _source,
                                name,
                                amount,
                                meta or {},
                                data.ItemInfo.label,
                                data.ItemInfo.imgsrc
                            )
                        else
                            output = addItem(name, amount, meta, identifier, charid, lvl)
                        end
                    end
                end
                if output then
                    TriggerClientEvent(
                        "redemrp_inventory:SendItems",
                        _source,
                        PrepareToOutput(Inventory[identifier .. "_" .. charid]),
                        {},
                        InventoryWeight[identifier .. "_" .. charid]
                    )
                end
                return output
            end
            function data.RemoveItem(amount)
                return false
            end
        end
    end
    return data
end

RegisterServerEvent("redemrp_inventory:deleteInv",
    function(charid, Callback)
        local _source = source
        local id
        for k, v in ipairs(GetPlayerIdentifiers(_source)) do
            if string.sub(v, 1, string.len("steam:")) == "steam:" then
                id = v
                break
            end
        end
        Inventory[id .. "_" .. charid] = nil
        Locker[id .. "_" .. charid] = nil
    end
)

function deep_compare(tbl1, tbl2)
	if tbl1 == tbl2 then
		return true
	elseif type(tbl1) == "table" and type(tbl2) == "table" then
		for key1, value1 in pairs(tbl1) do
			local value2 = tbl2[key1]

			if value2 == nil then
				-- avoid the type call for missing keys in tbl2 by directly comparing with nil
				return false
			elseif value1 ~= value2 then
				if type(value1) == "table" and type(value2) == "table" then
					if not deep_compare(value1, value2) then
						return false
					end
				else
					return false
				end
			end
		end

		-- check for missing keys in tbl1
		for key2, _ in pairs(tbl2) do
			if tbl1[key2] == nil then
				return false
			end
		end

		return true
	end

	return false
end

function is_table_equal(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or is_table_equal(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

RegisterServerEvent("redemrp_inventory:craft", function(data, id)
    local _source = source
    local Player = RedEM.GetPlayer(_source)

    local itemstoremove = {}

    local outputItem, multipliedOutputItemAmount = CheckForSingleBlueprintCollision(data)

    if not outputItem then
        outputItem, multipliedOutputItemAmount = CheckForSingleBlueprintMultipleCollisions(data)
    end

    if outputItem then
        local CraftData = Config.Crafting[outputItem]
        if CraftData.requireId then
            if CraftData.requireId ~= id then
                return
            end
        end

        if CraftData.requireTool then
            local itemDatatool = SharedInventoryFunctions.getItem(_source, CraftData.requireTool)
            if itemDatatool.ItemAmount < 1 then
                return
            end
        end

        local CanContinue = false
        if CraftData.requireJob then
            local hasJob = false
            for k,v in pairs(CraftData.requireJob) do
                if Player.job == v then
                    hasJob = true
                end
            end
            if hasJob then
                CanContinue = true
            end
        else
            CanContinue = true
        end

        if CanContinue then
            local bpInputs = CraftData.items
            local strmatch = string.match

            for v,k in pairs(data) do
                local inputItem = k[1]

                if  inputItem ~= "empty" then
                    local bpInput = bpInputs[v]
                    local _, bpInputAmount = strmatch(bpInput, '(%a+)%s*,%s*(%d+)')

                    bpInputAmount = tonumber(bpInputAmount) or 1

                    local checkitemdata = SharedInventoryFunctions.getItem(_source, inputItem)
                    if checkitemdata.ItemAmount >= bpInputAmount*multipliedOutputItemAmount then
                        table.insert(itemstoremove, {inputItem, bpInputAmount*multipliedOutputItemAmount})
                    else
                        return RedEM.Functions.NotifyLeft(_source, "Crafting failed!", "You're missing items!", "menu_textures", "menu_icon_alert", 3000)
                    end
                end
            end

            TriggerClientEvent("redemrp_inventory:client:StartCraftingProgress", _source, itemstoremove, outputItem, multipliedOutputItemAmount)

        else
            RedEM.Functions.NotifyLeft(_source, "Crafting failed!", "Incorrect job for this recipe!", "menu_textures", "menu_icon_alert", 3000)
        end
    end
end)

RegisterServerEvent("redemrp_inventory:server:FinishCraftingProgress", function(itemstoremove, outputItem, outputItemAmount)
    local _source = source
    for v,k in pairs(itemstoremove) do
        local itemData1 = SharedInventoryFunctions.getItem(_source, k[1])
        --print("Removing ", k[1], k[2])
        if not itemData1.RemoveItem(k[2]) then
            return RedEM.Functions.NotifyLeft(_source, "Crafting failed!", "You're missing items!", "menu_textures", "menu_icon_alert", 3000)
        end
    end

    --print(outputItem, outputItemAmount)
    local itemData2 = SharedInventoryFunctions.getItem(_source, outputItem)
    local name = outputItem
    if itemData2.ItemInfo.label ~= nil then
        name = itemData2.ItemInfo.label
    end
    if itemData2.AddItem(outputItemAmount) then
        RedEM.Functions.NotifyLeft(_source, "Items Crafted", "You crafted "..outputItemAmount.."x "..name.."!", "menu_textures", "menu_icon_alert", 3000)
    else
        RedEM.Functions.NotifyLeft(_source, "Crafting failed!", "Not enough room!", "menu_textures", "menu_icon_alert", 3000)
    end
end)

function IterateThroughBlueprints(inputSlots, next)
    local collisions = {}

    local strmatch = string.match

    for bpOutputItem, bp in pairs(Config.Crafting) do
        local bpOutputAmount = 1
        local bpInputs = bp.items

        local itSucceeded = true

        local multipliers = { }

        for i = 1, 9 do
            local bpInput = bpInputs[i]

            local bpInputItem, bpInputAmount = strmatch(bpInput, '(%a+)%s*,%s*(%d+)')
            bpInputItem = bpInputItem or bpInput
            bpInputAmount = tonumber(bpInputAmount) or 1

            if bpInputItem == 'empty' then
                bpInputAmount = 0
            end

            local input = inputSlots[i]
            local inputItem = input[1]
            local inputAmount = input[2]

            local continue, mult = nextc(bpInputItem, bpInputAmount, inputItem, inputAmount)

            -- If it is `-1` then we're checking against an `empty` item.
            if mult ~= -1 then
                table.insert(multipliers, mult)
            end

            if #multipliers == 9 then
                multipliers = {
                    1
                }
            end

            if not continue then
                itSucceeded = false
                break
            end
        end

        if itSucceeded then

            local highestMultiplier = math.max(table.unpack(multipliers))
            local lowestMultiplier = highestMultiplier

            for _, multiplier in ipairs(multipliers) do
                --print("MULT: "..multiplier)
                if multiplier <= lowestMultiplier then
                    lowestMultiplier = multiplier
                end
            end

            table.insert(collisions, {bpOutputItem, bpOutputAmount, lowestMultiplier})
        end
    end

    local retItem
    local retAmount 

    local numCollisions = #collisions

    if numCollisions == 1 then
        local col = collisions[1]

        --print(col[1], col[2], col[3])
        retItem = col[1]
        retAmount = col[2] * col[3]

    elseif numCollisions > 1 then

        local chosenCollision
        local highestMultiplier = 0

        for _, col in ipairs(collisions) do

            local mult = col[3]

            if mult > highestMultiplier then
                chosenCollision = col
                highestMultiplier = mult
            end
        end

        if chosenCollision then
            retItem = chosenCollision[1]
            retAmount = chosenCollision[2] * chosenCollision[3]
        end
    end

    return retItem, retAmount
end

function CheckForSingleBlueprintCollision(inputSlots)
    local insert = table.insert

    local t = {}
    for _, d in ipairs(inputSlots) do 
        if d[1] ~= 'empty' then
            insert(t, d[2])
        end
    end
	
    if t[1] == nil then
	    return false
    end
	
    local lowestInputAmount = math.min(table.unpack(t))

    nextc = function(bpInputItem, bpInputAmount, inputItem, inputAmount)
        if inputItem ~= bpInputItem then
            return false
        end

        if inputAmount ~= bpInputAmount and inputAmount ~= (bpInputAmount * lowestInputAmount) then
            return false
        end

        return true, lowestInputAmount
    end

    return IterateThroughBlueprints(inputSlots, nextc)
end

function CheckForSingleBlueprintMultipleCollisions(inputSlots)
    nextc = function(bpInputItem, bpInputAmount, inputItem, inputAmount)
        local possibleMultiplier = -1

        if bpInputItem ~= "empty" then
            if inputItem ~= bpInputItem then
                return false
            end

            possibleMultiplier = math.floor(inputAmount / bpInputAmount)
        end

        return true, possibleMultiplier
    end

    return IterateThroughBlueprints(inputSlots, nextc)
end