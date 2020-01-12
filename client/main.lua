local ITEMS = {}
local active = false
local PickPrompt
local wait = 0
local gotItems = false
------------------------- EVENTS -------------------------

RegisterNetEvent("gui:ReloadMenu")
AddEventHandler("gui:ReloadMenu", function()
    loadPlayerInventory()
end)

RegisterNetEvent("item:LoadPickups")
AddEventHandler("item:LoadPickups", function(pick)
    Pickups = pick
	print("LOADED PICKUPS")
end)


RegisterNetEvent("gui:getItems")
AddEventHandler("gui:getItems", function(THEITEMS)
    ITEMS = THEITEMS
    gotItems = true
end)



--------------------DROP ITEM ------------------------------------------
function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    local px,py,pz=table.unpack(GetGameplayCamCoord())
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
    local factor = (string.len(text)) / 150
    DrawSprite("generic_textures", "hud_menu_4a", _x, _y+0.0125,0.015+ factor, 0.03, 0.1, 100, 1, 1, 190, 0)
end

function SetupPickPrompt()
    Citizen.CreateThread(function()
        local str = 'Pick up'
        PickPrompt = PromptRegisterBegin()
        PromptSetControlAction(PickPrompt, 0xF84FA74F)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(PickPrompt, str)
        PromptSetEnabled(PickPrompt, false)
        PromptSetVisible(PickPrompt, false)
        PromptSetHoldMode(PickPrompt, true)
        PromptRegisterEnd(PickPrompt)

    end)

end

RegisterNetEvent('player:anim')
AddEventHandler('player:anim', function(obj)
  local dict = "amb_work@world_human_box_pickup@1@male_a@stand_exit_withprop"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
		Citizen.Wait(10)
    end
    TaskPlayAnim(PlayerPedId(), dict, "exit_front", 1.0, 8.0, -1, 1, 0, false, false, false)
	Wait(1200)
	PlaySoundFrontend("CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", true, 1)
  	  print("start")
	Wait(1000)
	ClearPedTasks(PlayerPedId())
end)

Citizen.CreateThread(function()
    SetupPickPrompt()
    while true do
        Citizen.Wait(wait)

        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        -- if there's no nearby Pickups we can wait a bit to save performance
        if next(Pickups) == nil then
            Citizen.Wait(500)
        end

        for k,v in pairs(Pickups) do
            local distance = GetDistanceBetweenCoords(coords, v.coords.x, v.coords.y, v.coords.z, true)

            if distance >= 15.0 then
                wait = 2000
                print("chill")
            else
                wait = 0

            end

            if distance <= 5.0 then
                DrawText3D(v.coords.x, v.coords.y, v.coords.z-0.5, v.name.." ".."["..v.amount.."]")

            end

            if distance <= 0.7 and not v.inRange  then
                TaskLookAtEntity(playerPed, v.obj , 3000 ,2048 , 3)
                if active == false then
                    PromptSetEnabled(PickPrompt, true)
                    PromptSetVisible(PickPrompt, true)
                    active = true
                end
                if PromptHasHoldModeCompleted(PickPrompt) then                    
                    TriggerServerEvent("item:onpickup",v.obj)
                    TriggerEvent("redemrp_notification:start", "COLLECTED: "..v.name.." ".."["..v.amount.."]", 3, "success")
                    v.inRange = true
                end
            else
                if active == true then
                    PromptSetEnabled(PickPrompt, false)
                    PromptSetVisible(PickPrompt, false)
                    active = false
                end
            end
        end
    end
end)
RegisterNetEvent('item:removePickup')
AddEventHandler('item:removePickup', function(obj)
    print(obj)
    Wait(1500)
    SetEntityAsMissionEntity(obj, false, true)
    NetworkRequestControlOfEntity(obj)
    local timeout = 0
    while not NetworkHasControlOfEntity(obj) and timeout < 5000 do
        timeout = timeout+100
        if timeout == 5000 then
            print('Never got control of' .. obj)
        end
        Wait(100)
    end
    DeleteEntity(obj)
    FreezeEntityPosition(obj , false)
end)

RegisterNetEvent('item:pickup')
AddEventHandler('item:pickup', function(name, amount , hash)
    local ped     = PlayerPedId()
    local _hash = tonumber(hash)
    local coords  = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local x, y, z = table.unpack(coords + forward * 1.6)
    print(x)
    print(y)
    print(_hash)
    if not HasModelLoaded("P_COTTONBOX01X") then
        RequestModel("P_COTTONBOX01X")
    end
    while not HasModelLoaded("P_COTTONBOX01X") do
        Wait(1)
    end
    local obj = CreateObject("P_COTTONBOX01X", x, y, z, true, true, true)
    PlaceObjectOnGroundProperly(obj)
    SetEntityAsMissionEntity(obj, true, false)
    FreezeEntityPosition(obj , true)
    TriggerServerEvent("item:SharePickupServer",name, obj , amount, x, y, z , _hash)
    PlaySoundFrontend("show_info", "Study_Sounds", true, 0)
end)

RegisterNetEvent('item:Sharepickup')
AddEventHandler('item:Sharepickup', function(name, obj , amount, x, y, z , value , hash)
    print(hash)
    if value == 1 then
        Pickups[obj] = {
            name = name,
            obj = obj,
            amount = amount,
            hash = hash,
            inRange = false,
            coords = {x = x, y = y, z = z}
        }
    else
        Pickups[obj] = nil
    end
end)


RegisterNetEvent('player:loadWeapons')
AddEventHandler('player:loadWeapons', function()
    Citizen.Wait(5000)
    RemoveAllPedWeapons(PlayerPedId() , true , true)
    Citizen.Wait(2000)
    for k, v in pairs(ITEMS) do
        if tonumber(v) == nil then
            Citizen.InvokeNative(0x5E3BDDBCB83F3D84, PlayerPedId(), v[2], 0, false, true)
            SetPedAmmo(PlayerPedId(), v[2] , v[1])
        end
    end
end)

RegisterNetEvent('player:giveWeapon')
AddEventHandler('player:giveWeapon', function(ammo , hash)
    Citizen.Wait(1000)
    Citizen.InvokeNative(0x5E3BDDBCB83F3D84, PlayerPedId(), hash, 0, false, true)
    SetPedAmmo(PlayerPedId(), hash , ammo)
end)


RegisterCommand('getinv', function(source, args)
    TriggerServerEvent("player:getItems", source)
end)




------------------------- GENERAL METHODS -------------------------


GetClosestPlayer = function(coords)
    local players         = GetPlayers()
    local closestDistance = 5
    local closestPlayer   = {}
    local coords          = coords
    local usePlayerPed    = false
    local playerPed       = PlayerPedId()
    local playerId        = PlayerId()

    if coords == nil then
        usePlayerPed = true
        coords       = GetEntityCoords(playerPed)
    end

    for i=1, #players, 1 do
        local target = GetPlayerPed(players[i])

        if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then
            local targetCoords = GetEntityCoords(target)
            local distance     = GetDistanceBetweenCoords(targetCoords, coords.x, coords.y, coords.z, true)

            if closestDistance > distance then
                table.insert(closestPlayer, players[i])
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

function GetPlayers()
    local players = {}

    for i = 0, 31 do
        if NetworkIsPlayerActive(i) then
            print(i)
            table.insert(players, i)
        end
    end

    return players
end


--------------------------------------------------------------------------------
local isInInventory = false


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(1, 0x4CC0E2FE) and IsInputDisabled(0) then
            openInventory()
        end
    end
end)

function openInventory()
    loadPlayerInventory()
    isInInventory = true
    SendNUIMessage({
        action = "display"
    })
    SetNuiFocus(true, true)
end
RegisterCommand('close', function(source, args)
    isInInventory = false
    SendNUIMessage({
        action = "hide"
    })
    SetNuiFocus(false, false)
end)
RegisterNUICallback('NUIFocusOff', function()
    isInInventory = false
    SendNUIMessage({
        action = "hide"
    })
    SetNuiFocus(false, false)
end)
RegisterCommand('test_pl', function(source, args)
    local players = {}
    players = GetClosestPlayer()

    for i=1, #players, 1 do
        print(players[i])
    end

end)

RegisterNUICallback('sound', function()
    PlaySoundFrontend("BACK", "RDRO_Character_Creator_Sounds", true, 0)
end)

RegisterNUICallback('GetNearPlayers', function(data, cb)
    local playerPed = PlayerPedId()
    local players = {}
    players = GetClosestPlayer()

    local foundPlayers = false
    local elements     = {}

    for i=1, #players, 1 do
        foundPlayers = true
        print("znaleziono")
        table.insert(elements, {
            label = GetPlayerName(players[i]),
            player = GetPlayerServerId(players[i])
        })

    end
    if not foundPlayers then
        print("nope")
    else
        SendNUIMessage({
            action = "nearPlayers",
            foundAny = foundPlayers,
            players = elements,
            item = data.item,
            hash = data.hash,
            count = data.count,
            type = data.type,
            what = data.what
        })
    end

    --  cb("ok")
end)

RegisterNUICallback('UseItem', function(data, cb)
if data.type == "item_standard" then
    TriggerServerEvent("item:use" , data.item)
	elseif data.type == "item_weapon" then
	 Citizen.InvokeNative(0x5E3BDDBCB83F3D84, PlayerPedId(), tonumber(data.hash), 0, false, true)
    SetPedAmmo(PlayerPedId(), tonumber(data.hash) , tonumber(data.amount))
	end
end)

RegisterNUICallback('DropItem', function(data, cb)
    print(data.type)
    if data.type == "item_standard" then
        local test = 1
        TriggerServerEvent("item:drop", data.item, tonumber(data.number) , test)
    else
        TriggerServerEvent("item:drop", data.item, GetAmmoInPedWeapon(PlayerPedId(), tonumber(data.hash)), tonumber(data.hash))
        RemoveWeaponFromPed(PlayerPedId(), tonumber(data.hash) , false)
    end
    --	cb("ok")
end)

RegisterNUICallback('GiveItem', function(data, cb)
    local playerPed = PlayerPedId()
    local players = GetClosestPlayer()

    for i=1, #players, 1 do
        if players[i] ~= PlayerId() then
            if GetPlayerServerId(players[i]) == data.player then
                local name = tostring(data.data.item)
                local amount = tonumber(data.data.count)
                local hash = tonumber(data.data.hash)
                local target = tonumber(data.player)
                if data.data.type == "item_standard" then
                    local test = 1
                    TriggerServerEvent('test_lols', name, amount, target , test)
                else
                    TriggerServerEvent('test_lols', name, GetAmmoInPedWeapon(PlayerPedId(), tonumber(hash)), target , hash)
		    RemoveWeaponFromPed(PlayerPedId(), hash , true)
                end
                break
            end
        end
    end
end)

function shouldSkipAccount (accountName)
    for index, value in ipairs(Config.ExcludeAccountsList) do
        if value == accountName then
            return true
        end
    end

    return false
end

function loadPlayerInventory()
    local test  = {}
    local value = 1

    for k, v in pairs(ITEMS) do
        local use = false
        if tonumber(v) ~= nil then
            if tonumber(v) > 0 then
                for _, u in pairs(Config.Usable) do
                    if k == u then
                        use = true
                        break
                    end
                end
                local cK = k
                if Config.Labels[k] ~= nil then
                    cK = Config.Labels[k]
                end
                table.insert(test, value,{
                    label     = cK,
                    type      = 'item_standard',
                    count     = v,
                    name     = k,
                    hash     = nil,
                    usable    = use,
                    rare      = false,
                    limit      = 64,
                    canRemove = true
                })
                value = value + 1

            end

        else

            table.insert(test, value,{
                label     = k,
                type      = 'item_weapon',
                count     = GetAmmoInPedWeapon(PlayerPedId() , v[2]),
                name     = k,
                hash     = v[2],
                usable    = true,
                rare      = false,
                limit      = -1,
                canRemove = true
            })
            value = value + 1
        end
    end




    SendNUIMessage({
        action = "setItems",
        itemList = test
    })
end


local time = math.random(500000,700000)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(time)
		if gotItems == true then       
        print("save")
		 for k, v in pairs(ITEMS) do
		  if tonumber(v) == nil then
		   print (k)
			v[1] = GetAmmoInPedWeapon(PlayerPedId() , v[2])
		
		 end
		 end
          TriggerServerEvent("weapon:saveAmmo", ITEMS)
        time = math.random(500000,700000)
		end
    end
end)


