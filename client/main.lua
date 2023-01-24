RedEM = exports["redem_roleplay"]:GetCoreObject()

local isInventoryOpen = false
local isOtherOpen = false
local InventoryItems = {}
local OtherItems = {}
local PlayerMoney = 0
local InventoryWeight = 0.0
local DroppedItems = {}
local OpenStash = nil
local UsedWeapons = {}
local PlayerJob = job
local CraftingId = nil
local IsCrafting = false

local WeaponsWithoutAmmo = {
    ["WEAPON_FISHINGROD"] = true,

	["WEAPON_MELEE_KNIFE"] = true,

    ["WEAPON_MELEE_KNIFE_JAWBONE"] = true,
    ["WEAPON_MELEE_KNIFE_TRADER"] = true,
    ["WEAPON_MELEE_KNIFE_HORROR"] = true,
    ["WEAPON_MELEE_KNIFE_RUSTIC"] = true,
    ["WEAPON_MELEE_KNIFE_MINER"] = true,
    ["WEAPON_MELEE_KNIFE_VAMPIRE"] = true,

    ["WEAPON_MELEE_MACHETE"] = true,
    ["WEAPON_MELEE_MACHETE_COLLECTOR"] = true,
    ["WEAPON_MELEE_MACHETE_HORROR"] = true,

	["WEAPON_LASSO"] = true,
    ["WEAPON_LASSO_IMPROVED"] = true,

	["WEAPON_MELEE_CLEAVER"] = true,
    ["WEAPON_MELEE_HATCHET"] = true,
    ["WEAPON_MELEE_HATCHET_HUNTER"] = true,
    ["WEAPON_MELEE_HATCHET_DOUBLE_BIT"] = true,

    ["WEAPON_MELEE_LANTERN"] = true,
	["WEAPON_MELEE_LANTERN_ELECTRIC"] = true,
    ["WEAPON_MELEE_LANTERN_HALLOWEEN"] = true,

	["WEAPON_MELEE_TORCH"] = true,

    ["WEAPON_KIT_BINOCULARS"] = true,
}

RegisterNetEvent("redemrp_inventory:client:ResetWeapons", function()
    UsedWeapons = {}
end)

RegisterNetEvent("redemrp_inventory:client:OpenCrafting", function(id)
    CraftingId = id
    isInventoryOpen = true
    IsCrafting = true
    SendNUIMessage(
        {
            type = 1,
            inventory = isInventoryOpen,
            otherinventory = isOtherOpen,
            crafting = true,
            items = InventoryItems,
            otheritems = OtherItems,
            money = RedEM.GetPlayerData().money,
            time = GetClockHours() .. ":" .. GetClockMinutes(),
            weight = InventoryWeight,
            target = 0
        }
    )
    SetNuiFocus(true, true)
end)

Citizen.CreateThread(
    function()
        TriggerServerEvent("redemrp_inventory:playerJoined")
        while true do
            Wait(1)
            if IsControlJustReleased(0, 0x4CC0E2FE) then
                isInventoryOpen = not isInventoryOpen

                if isInventoryOpen then
                    for i, k in pairs(InventoryItems) do
                        if k.type == "item_weapon" and not WeaponsWithoutAmmo[k.name] then
                            if HasPedGotWeapon(PlayerPedId(), tonumber(k.weaponHash)) then
                                if
                                    UsedWeapons[tonumber(k.weaponHash)] and
                                        UsedWeapons[tonumber(k.weaponHash)].meta.uid == k.meta.uid
                                    then
                                    InventoryItems[i].amount =
                                        GetAmmoInPedWeapon(PlayerPedId(), tonumber(k.weaponHash))
                                end
                            end
                        end
                    end
                    SendNUIMessage(
                        {
                            type = 1,
                            inventory = isInventoryOpen,
                            otherinventory = isOtherOpen,
                            crafting = false,
                            items = InventoryItems,
                            otheritems = OtherItems,
                            money = RedEM.GetPlayerData().money,
                            time = GetClockHours() .. ":" .. GetClockMinutes(),
                            weight = InventoryWeight,
                            target = 0
                        }
                    )

                    SetNuiFocus(true, true)
                else
                    SendNUIMessage(
                        {
                            type = 2
                        }
                    )
                    SetNuiFocus(false, false)
                    IsCrafting = false
                    isOtherOpen = false
                    SetNuiFocusKeepInput(false)
                end
            end
        end
    end
)

RegisterNetEvent(
    "redemrp_inventory:PlaySound",
    function(soundID)
        PlaySoundFrontend("HUD_SHOP_SOUNDSET", "PURCHASE", true, 0)
    end
)

RegisterNetEvent("redemrp_inventory:SearchPlayer")
AddEventHandler(
    "redemrp_inventory:SearchPlayer",
    function()
        local closestPlayer, closestDistance = GetClosestPlayer()
        if closestPlayer ~= -1 and closestDistance <= 1.5 then
            TriggerServerEvent("redemrp_inventory:GetPlayer", GetPlayerServerId(closestPlayer), Citizen.InvokeNative(0x3AA24CCC0D451379, GetPlayerPed(closestPlayer)))
        else
            RedEM.Functions.NotifyLeft("Can't Find", "No players nearby!", "menu_textures", "menu_icon_alert", 4000)
        end
    end
)

RegisterNetEvent("redemrp_inventory:PoliceSearchPlayer")
AddEventHandler(
    "redemrp_inventory:PoliceSearchPlayer",
    function()
        local closestPlayer, closestDistance = GetClosestPlayer()
        if closestPlayer ~= -1 and closestDistance <= 1.5 then
            TriggerServerEvent("redemrp_inventory:GetPlayerAsPolice", GetPlayerServerId(closestPlayer))
        else
            RedEM.Functions.NotifyLeft("Can't Find", "No players nearby!", "menu_textures", "menu_icon_alert", 4000)
        end
    end
)

RegisterNetEvent("redemrp_inventory:removeWeapon")
AddEventHandler(
    "redemrp_inventory:removeWeapon",
    function(hash)
        if UsedWeapons[tonumber(hash)] then
            UsedWeapons[tonumber(hash)] = nil
            ReloadWeapons()
        end
    end
)

RegisterNetEvent('redemrp_inventory:getUsedWeapons')
AddEventHandler('redemrp_inventory:getUsedWeapons', function(hash)
    TriggerServerEvent('redemrp_inventory:getUsedWeapons', UsedWeapons)
end)

RegisterNetEvent('redemrp_inventory:getUsedWeapons')
AddEventHandler('redemrp_inventory:getUsedWeapons', function(hash)
    TriggerServerEvent('redemrp_inventory:getUsedWeapons', UsedWeapons)
end)


local PistolsEquipped = 0

RegisterNetEvent("redemrp_inventory:UseWeapon")
AddEventHandler(
    "redemrp_inventory:UseWeapon",
    function(hash, ammoAmount, meta, name)
        local id = false
        local pweptype = Citizen.InvokeNative(0x5C2EA6C44F515F34, tonumber(hash))
        if (not UsedWeapons[tonumber(hash)]) or ((pweptype == 1681219929 or pweptype == 1950175060) and PistolsEquipped < 2) then
            if pweptype == 1681219929 or pweptype == 1950175060 then
                PistolsEquipped = PistolsEquipped + 1
            end
            for i, k in pairs(UsedWeapons) do
                if k.WeaponType == pweptype then
                    id = i
                    break
                end
            end
            if id and pweptype ~= 1681219929 and pweptype ~= 1950175060 then
                UsedWeapons[id] = nil
            end
            UsedWeapons[tonumber(hash)] = {
                WeaponHash = tonumber(hash),
                WeaponType = pweptype,
                Ammo = tonumber(ammoAmount),
                name = name,
                meta = meta
            }
        else
            if not WeaponsWithoutAmmo[UsedWeapons[tonumber(hash)].name] then
                UsedWeapons[tonumber(hash)].Ammo = GetAmmoInPedWeapon(PlayerPedId(), tonumber(hash))
            end
            TriggerServerEvent("redemrp_inventory:ChangeAmmoAmount", {UsedWeapons[tonumber(hash)]})
            UsedWeapons[tonumber(hash)] = nil
        end
        ReloadWeapons()
    end
)

local PistolsEquipping = 0

RegisterCommand("lanternbelt", function()
    for i, k in pairs(UsedWeapons) do
        if k.name == "WEAPON_MELEE_LANTERN" then
            SetCurrentPedWeapon(PlayerPedId(), `WEAPON_MELEE_LANTERN`, true, 12, false, false)
            if IsPedMale(PlayerPedId()) then
                TriggerServerEvent('3dme:shareDisplay', "ATTACHES HIS LANTERN TO HIS BELT")
            else
                TriggerServerEvent('3dme:shareDisplay', "ATTACHES HER LANTERN TO HER BELT")
            end
        end
    end
end)

function ReloadWeapons()
    Citizen.InvokeNative(0x1B83C0DEEBCBB214, PlayerPedId())
    RemoveAllPedWeapons(PlayerPedId(), true, true)
    addWardrobeInventoryItem("CLOTHING_ITEM_M_OFFHAND_000_TINT_004", 0xF20B6B4A);
    addWardrobeInventoryItem("UPGRADE_OFFHAND_HOLSTER", 0x39E57B01);
    PistolsEquipping = 0
    for i, k in pairs(UsedWeapons) do
        if k.name == "WEAPON_PISTOL_VOLCANIC" or
        k.name == "WEAPON_PISTOL_M1899" or
        k.name == "WEAPON_PISTOL_SEMIAUTO" or 
        k.name == "WEAPON_PISTOL_MAUSER" or
        k.name == "WEAPON_REVOLVER_DOUBLEACTION" or
        k.name == "WEAPON_REVOLVER_CATTLEMAN" or
        k.name == "WEAPON_REVOLVER_LEMAT" or
        k.name == "WEAPON_REVOLVER_SCHOFIELD" or
        k.name == "WEAPON_REVOLVER_NAVY" then
            PistolsEquipping = PistolsEquipping + 1
            if PistolsEquipping == 1 then
                givePlayerWeapon(k.WeaponHash, 2)
            elseif PistolsEquipping == 2 then
                givePlayerWeapon(k.WeaponHash, 3)
            else
                Citizen.InvokeNative(0x5E3BDDBCB83F3D84, PlayerPedId(), k.WeaponHash, 0, false, true) -- GIVE_WEAPON_TO_PED
            end
        elseif k.name == "WEAPON_MELEE_LANTERN" then
            GiveWeaponToPed_2(PlayerPedId(), `WEAPON_MELEE_LANTERN`, 0, true, true , 0, false, 0.5, 1.0, 752097756, false, 0, false)
            SetCurrentPedWeapon(PlayerPedId(), `WEAPON_MELEE_LANTERN`, true, 0, false, false)
        else
            Citizen.InvokeNative(0x5E3BDDBCB83F3D84, PlayerPedId(), k.WeaponHash, 0, false, true) -- GIVE_WEAPON_TO_PED
        end
        --GiveWeaponToPed_2(v, `weapon_revolver_cattleman`, 500, false, true, 1, false, 0.5, 1.0, 1.0, true, 0, 0)
        --print("Setting ammo for "..k.WeaponHash.." to "..k.Ammo)
        SetPedAmmo(PlayerPedId(), k.WeaponHash, k.Ammo)
        if k.meta.components ~= nil and k.meta.components["GLOBAL"] ~= nil then
            TriggerEvent('darkk_weapon_customization:Apply', k.WeaponHash, k.meta.components)
        end

        --[[
        Wait(100)
        if k.meta.damage ~= nil and k.meta.dirt ~= nil then
            local weapon = Citizen.InvokeNative(0x6CA484C9A7377E4F, PlayerPedId(), 1) -- _GET_PED_WEAPON_OBJECT
            while not DoesEntityExist(weapon) do 
                Wait(10)
                weapon = Citizen.InvokeNative(0x6CA484C9A7377E4F, PlayerPedId(), 1) -- _GET_PED_WEAPON_OBJECT
            end
            TriggerEvent('weapons:ApplyDamage', weapon, k.meta.damage, k.meta.dirt)
        end]]
    end
end

RegisterNetEvent("weapons:ApplyDamage", function(weaponObject, damagelevel, dirtlevel)
    if damagelevel == 1 then damagelevel = 1.0 end
    if dirtlevel == 1 then dirtlevel = 1.0 end
    if DoesEntityExist(weaponObject) then
        --print("Applied damage of "..damagelevel.." and dirt level "..dirtlevel.." to weapon object "..weaponObject)
        Citizen.InvokeNative(0xA7A57E89E965D839, weaponObject, damagelevel) -- _SET_WEAPON_DEGRADATION
        Citizen.InvokeNative(0x812CE61DEBCAB948, weaponObject, dirtlevel, 0) -- _SET_WEAPON_DIRT
        Citizen.InvokeNative(0xA9EF4AD10BDDDB57, weaponObject, dirtlevel, 0)
    end
end)

RegisterCommand('inspect', function(source, args, raw)
    local ped = PlayerPedId()
    local wep = GetCurrentPedWeaponEntityIndex(ped, 0)
    local _, wepHash = GetCurrentPedWeapon(ped, true, 0, true)
    local WeaponType = GetWeaponType(wepHash)
    if wepHash == `WEAPON_UNARMED` then return end
    ShowWeaponStats()
    if WeaponType == "SHOTGUN" then WeaponType = "LONGARM" end
    if WeaponType == "MELEE" then WeaponType = "SHORTARM" end
	if WeaponType == "BOW" then WeaponType = "SHORTARM" end
    Citizen.InvokeNative(0x72F52AA2D2B172CC,  PlayerPedId(), wepHash, wep, 0, GetHashKey(WeaponType.."_HOLD_ENTER"), 0, 0, -1.0)
end)

function GetWeaponType(hash)
	if Citizen.InvokeNative(0x959383DCD42040DA, hash)  or Citizen.InvokeNative(0x792E3EF76C911959, hash)   then
		return "MELEE"
	elseif Citizen.InvokeNative(0x6AD66548840472E5, hash) or Citizen.InvokeNative(0x0A82317B7EBFC420, hash) or Citizen.InvokeNative(0xDDB2578E95EF7138, hash) then
		return "LONGARM"
	elseif  Citizen.InvokeNative(0xC75386174ECE95D5, hash) then
		return "SHOTGUN"
	elseif  Citizen.InvokeNative(0xDDC64F5E31EEDAB6, hash) or Citizen.InvokeNative(0xC212F1D05A8232BB, hash) then
		return "SHORTARM"
	end
	return false
end

function ShowWeaponStats()
    local PlayerPed = PlayerPedId()
    local WeaponObject = GetObjectIndexFromEntityIndex(GetCurrentPedWeaponEntityIndex(PlayerPed , 0))
    local _, WeaponHash = GetCurrentPedWeapon(PlayerPed, true, 0, true)
    local Block = RequestFlowBlock(GetHashKey("PM_FLOW_WEAPON_INSPECT"))
    local Container = DatabindingAddDataContainerFromPath("" , "ItemInspection")
    exports["redemrp_weaponmods"]:GetWeaponStats(Container, WeaponHash)
    DatabindingAddDataBool(Container, "Visible", true)
    DatabindingAddDataString(Container, "tipText", GetLabelText(WeaponObject))
    DatabindingAddDataHash(Container, "itemLabel", WeaponHash)
    Citizen.InvokeNative(0x10A93C057B6BD944 ,Block)
    Citizen.InvokeNative(0x3B7519720C9DCB45	,Block, 0)
    Citizen.InvokeNative(0x4C6F2C4B7A03A266 ,-813354801, Block)
    Citizen.CreateThread(function()
        Wait(1000)
        while true do
            Wait(100)
            if not Citizen.InvokeNative(0x6AA3DCA2C6F5EB6D, PlayerPedId()) then
                Citizen.InvokeNative(0x4EB122210A90E2D8, -813354801)
                break
            end
        end
    end)
end

function GetLabelText(WeaponObject)
    local WeaponDegradation =  Citizen.InvokeNative(0x0D78E1097F89E637 ,WeaponObject , Citizen.ResultAsFloat())
    local WeaponPernamentDegradation =  Citizen.InvokeNative(0xD56E5F336C675EFA ,WeaponObject , Citizen.ResultAsFloat())
    if WeaponDegradation == 0.0 then
        return GetLabelTextByHash(1803343570)
    end
    if WeaponPernamentDegradation > 0.0 and WeaponDegradation == WeaponPernamentDegradation then
        return GetLabelTextByHash(-1933427003)
    end
    return GetLabelTextByHash(-54957657)
end

Citizen.CreateThread(function()
    while true do
        Wait(2000)
        local weaponObject = Citizen.InvokeNative(0x6CA484C9A7377E4F, PlayerPedId(), 1) -- _GET_PED_WEAPON_OBJECT
        local _,pedWeapon = GetCurrentPedWeapon(PlayerPedId(), 1)
        for i, k in pairs(UsedWeapons) do
            if k.WeaponHash == pedWeapon then
                TriggerEvent('weapons:ApplyDamage', weaponObject, UsedWeapons[i].meta.damage, UsedWeapons[i].meta.dirt)
                break
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(50)
        if IsPedShooting(PlayerPedId()) then
            local weaponObject = Citizen.InvokeNative(0x6CA484C9A7377E4F, PlayerPedId(), 1) -- _GET_PED_WEAPON_OBJECT
            local _,pedWeapon = GetCurrentPedWeapon(PlayerPedId(), 1)
            for i, k in pairs(UsedWeapons) do
                if k.WeaponHash == pedWeapon then
                    if not UsedWeapons[i].meta.damage then
                        UsedWeapons[i].meta.damage = 0.0
                    end
                    if not UsedWeapons[i].meta.dirt then
                        UsedWeapons[i].meta.dirt = 0.0
                    end
                    UsedWeapons[i].meta.damage = tonumber(math.format("%.2f", UsedWeapons[i].meta.damage + ((math.random(5, 9)/10) / 100)))
                    UsedWeapons[i].meta.dirt = tonumber(math.format("%.2f", UsedWeapons[i].meta.dirt + ((math.random(5, 9)/10) / 100)))
                    if UsedWeapons[i].meta.damage > 1.0 then
                        UsedWeapons[i].meta.damage = 1.0
                    end
                    if UsedWeapons[i].meta.dirt > 1.0 then
                        UsedWeapons[i].meta.dirt = 1.0
                    end
                    TriggerEvent('weapons:ApplyDamage', weaponObject, UsedWeapons[i].meta.damage, UsedWeapons[i].meta.dirt)
                    TriggerServerEvent('weapons:server:ApplyDamage', UsedWeapons)
                    --print("Damaged weapon "..k.name.." by 0.01 to ".. UsedWeapons[i].meta.damage)
                    --print("Dirtied weapon "..k.name.." by 0.02 to ".. UsedWeapons[i].meta.dirt)
                    break
                end
            end
        end
    end
end)

--[[
Citizen.CreateThread(function()
    while true do
        Wait(5000)
        if next(UsedWeapons) ~= nil then
            TriggerServerEvent('weapons:server:ApplyDamage', UsedWeapons)
            --print("Saving weapon damage with server")
        end
    end
end)]]

RegisterNetEvent("weapons:CleanAndRepairWeapon", function()
    TriggerEvent("redemrp_inventory:closeinv")
    local ped = PlayerPedId()
    local retval, weaponHash = GetCurrentPedWeapon(PlayerPedId(), false, weaponHash, false)
    if weaponHash ~= `WEAPON_UNARMED` then
        local Cloth= CreateObject(GetHashKey('s_balledragcloth01x'), GetEntityCoords(PlayerPedId()), false, true, false, false, true)
        local PropId = GetHashKey("CLOTH")
        local actshort = GetHashKey("SHORTARM_CLEAN_ENTER")
        local actlong = GetHashKey("LONGARM_CLEAN_ENTER")
        local model = GetWeapontypeGroup(weaponHash)
        local object = GetObjectIndexFromEntityIndex(GetCurrentPedWeaponEntityIndex(PlayerPedId(),0))
        -- print("Model --> "..model)
        -- print("Weapon hash --> "..weaponHash)
        -- print("NOmbre--> "..weaponName)
        if model == 416676503 or model == -1101297303 then
            Citizen.InvokeNative(0x72F52AA2D2B172CC,  PlayerPedId(), 1242464081, Cloth, PropId, actshort, 1, 0, -1.0)   
        else
            Citizen.InvokeNative(0x72F52AA2D2B172CC,  PlayerPedId(), 1242464081, Cloth, PropId, actlong, 1, 0, -1.0)   
        end
        RepairWeapon()
        TriggerServerEvent("redemrp_weaponshop:server:RemoveGunOil")
    end
end)

RepairWeapon = function()
    local weaponObject = Citizen.InvokeNative(0x6CA484C9A7377E4F, PlayerPedId(), 1)
    local _,pedWeapon = GetCurrentPedWeapon(PlayerPedId(), 1)
    for i, k in pairs(UsedWeapons) do
        if k.WeaponHash == pedWeapon then
            Citizen.InvokeNative(0xA7A57E89E965D839, weaponObject, 0.0)
            Citizen.InvokeNative(0x812CE61DEBCAB948, weaponObject, 0.0, 0)
            Citizen.InvokeNative(0xA9EF4AD10BDDDB57, weaponObject, 0.0, 0)
            UsedWeapons[i].meta.damage = 0.0
            UsedWeapons[i].meta.dirt = 0.0
            TriggerServerEvent('weapons:server:ApplyDamage', UsedWeapons)
            break
        end
    end
end

RegisterNetEvent("weapons:BreakWeapon", function()
    local weaponObject = Citizen.InvokeNative(0x6CA484C9A7377E4F, PlayerPedId(), 1)
    local _,pedWeapon = GetCurrentPedWeapon(PlayerPedId(), 1)
    for i, k in pairs(UsedWeapons) do
        if k.WeaponHash == pedWeapon then
            Citizen.InvokeNative(0xA7A57E89E965D839, weaponObject, 1.0)
            Citizen.InvokeNative(0x812CE61DEBCAB948, weaponObject, 1.0, 0)
            Citizen.InvokeNative(0xA9EF4AD10BDDDB57, weaponObject, 1.0, 0)
            UsedWeapons[i].meta.damage = 1.0
            UsedWeapons[i].meta.dirt = 1.0
            TriggerServerEvent('weapons:server:ApplyDamage', UsedWeapons)
            break
        end
    end
end)

--[[
RegisterCommand("weaponclean", function()
    TriggerEvent("weapons:CleanAndRepairWeapon")
end)

RegisterCommand("weaponbreak", function()
    TriggerEvent("weapons:BreakWeapon")
end)]]

Citizen.CreateThread(
    function()
        while true do
            Wait(10000)
            local Changed = false
            if next(UsedWeapons) ~= nil then
                for i, k in pairs(UsedWeapons) do
                    if HasPedGotWeapon(PlayerPedId(), i, 0, 0) then
                        if not WeaponsWithoutAmmo[k.name] then
                            Changed = true
                            UsedWeapons[i].Ammo = GetAmmoInPedWeapon(PlayerPedId(), i)
                        end
                    end
                end
                if Changed then
                    TriggerServerEvent("redemrp_inventory:ChangeAmmoAmount", UsedWeapons)
                end
            end
        end
    end
)


RegisterNetEvent(
    "redemrp_inventory:SendItems",
    function(data, data2, weight, other, target)
        InventoryItems = data
        OtherItems = data2
        InventoryWeight = weight
        local _target = 0
        if other then
            isOtherOpen = true
            isInventoryOpen = true
        end
        if target then
            _target = target
            for i, k in pairs(InventoryItems) do
                if k.type == "item_weapon" and not WeaponsWithoutAmmo[k.name] then
                    if HasPedGotWeapon(PlayerPedId(), tonumber(k.weaponHash)) then
                        if UsedWeapons[tonumber(k.weaponHash)].meta.uid == k.meta.uid then
                            InventoryItems[i].amount = GetAmmoInPedWeapon(PlayerPedId(), tonumber(k.weaponHash))
                        end
                    end
                end
            end
        end
        if isInventoryOpen then
            SendNUIMessage(
                {
                    type = 1,
                    inventory = isInventoryOpen,
                    otherinventory = isOtherOpen,
                    crafting = IsCrafting,
                    items = InventoryItems,
                    otheritems = OtherItems,
                    money = RedEM.GetPlayerData().money,
                    time = GetClockHours() .. ":" .. GetClockMinutes(),
                    weight = InventoryWeight,
                    target = _target
                }
            )
            SetNuiFocus(true, true)
        end
    end
)

RegisterNetEvent(
    "redem:addMoney",
    function(_money)
        PlayerMoney = _money
    end
)

RegisterNetEvent(
    "redem:activateMoney",
    function(_money)
        PlayerMoney = _money
    end
)

RegisterNUICallback(
    "additem",
    function(data)
        TriggerServerEvent("redemrp_inventory:update", "add", data.data, data.target, nil, OpenStash)
    end
)

RegisterNUICallback(
    "removeitem",
    function(data)
        TriggerServerEvent("redemrp_inventory:update", "delete", data.data, data.target, nil, OpenStash)
    end
)

local crafting = false

RegisterNetEvent("redemrp_inventory:client:StartCraftingProgress", function(itemstoremove, outputItem, outputAmount)
    if not crafting then
        TriggerEvent("redemrp_inventory:closeinv")
        crafting = true
        TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), -1, true, false, false, false)
        exports['progressBars']:startUI(3000 * outputAmount, "Crafting Items...")
        Wait(3000 * outputAmount)
        ClearPedTasks(PlayerPedId())
        TriggerServerEvent("redemrp_inventory:server:FinishCraftingProgress", itemstoremove, outputItem, outputAmount)
        crafting = false
    end
end)

--==================== D R O P =======================================

RegisterNetEvent("redemrp_inventory:closeinv")
AddEventHandler("redemrp_inventory:closeinv", function()
    SendNUIMessage(
        {
            type = 2
        }
    )
    SetNuiFocus(false, false)
    IsCrafting = false
    isInventoryOpen = false
    isOtherOpen = false
    SetNuiFocusKeepInput(false)
end)

function GetClosestPlayer()
    local players, closestDistance, closestPlayer = GetActivePlayers(), -1, -1
    local playerPed, playerId = PlayerPedId(), PlayerId()
    local coords, usePlayerPed = coords, false

    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        usePlayerPed = true
        coords = GetEntityCoords(playerPed)
    end

    for i = 1, #players, 1 do
        local tgt = GetPlayerPed(players[i])

        if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then
            local targetCoords = GetEntityCoords(tgt)
            local distance = #(coords - targetCoords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = players[i]
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

RegisterNUICallback(
    "dropitem",
    function(data)
        TriggerServerEvent("redemrp_inventory:drop", data.data)
    end
)

RegisterNUICallback(
    "giveitem",
    function(data)
        local closestPlayer, closestDistance = GetClosestPlayer()
        if closestPlayer ~= -1 and closestDistance <= 1.5 then
            --print(json.encode(data))
            TriggerServerEvent("redemrp_inventory:giveItem", data.data, GetPlayerServerId(closestPlayer))
        else
            RedEM.Functions.NotifyLeft("Can't Find", "No players nearby!", "menu_textures", "menu_icon_alert", 4000)
        end
    end
)

function modelrequest(model)
    Citizen.CreateThread(
        function()
            RequestModel(model)
        end
    )
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str, _x, _y)
    local factor = (string.len(text)) / 150
    DrawSprite("generic_textures", "hud_menu_4a", _x, _y + 0.0125, 0.015 + factor, 0.03, 0.1, 100, 1, 1, 190, 0)
end

RegisterNetEvent(
    "redemrp_inventory:CreatePickup",
    function(name, amount, meta, label, img)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local forward = GetEntityForwardVector(ped)
        local x, y, z = table.unpack(coords + forward * 1.6)
        while not HasModelLoaded(GetHashKey("P_COTTONBOX01X")) do
            Wait(500)
            modelrequest(GetHashKey("P_COTTONBOX01X"))
        end
        local obj = CreateObject("P_COTTONBOX01X", x, y, z, true, true, true)
        PlaceObjectOnGroundProperly(obj)
        SetEntityAsMissionEntity(obj, true, true)
        FreezeEntityPosition(obj, true)
        local _coords = GetEntityCoords(obj)
        TriggerServerEvent(
            "redemrp_inventory:AddPickupServer",
            name,
            amount,
            meta,
            label,
            img,
            _coords.x,
            _coords.y,
            _coords.z,
            ObjToNet(obj)
        )
        PlaySoundFrontend("show_info", "Study_Sounds", true, 0)
        SetModelAsNoLongerNeeded(GetHashKey("P_COTTONBOX01X"))
    end
)

RegisterNetEvent(
    "redemrp_inventory:CreateLetterPickup",
    function(name, amount, meta, label, img)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local forward = GetEntityForwardVector(ped)
        local x, y, z = table.unpack(coords + forward * 1.6)
        while not HasModelLoaded(GetHashKey("p_uniqletterbundle01x")) do
            Wait(500)
            modelrequest(GetHashKey("p_uniqletterbundle01x"))
        end
        local obj = CreateObject("p_uniqletterbundle01x", x, y, z, true, true, true)
        PlaceObjectOnGroundProperly(obj)
        SetEntityAsMissionEntity(obj, true, true)
        FreezeEntityPosition(obj, true)
        local _coords = GetEntityCoords(obj)
        TriggerServerEvent(
            "redemrp_inventory:AddPickupServer",
            name,
            amount,
            meta,
            label,
            img,
            _coords.x,
            _coords.y,
            _coords.z,
            ObjToNet(obj)
        )
        PlaySoundFrontend("show_info", "Study_Sounds", true, 0)
        SetModelAsNoLongerNeeded(GetHashKey("p_uniqletterbundle01x"))
    end
)

RegisterNetEvent(
    "redemrp_inventory:removePickup",
    function(netid)
        local obj = NetToObj(netid)
        SetEntityAsMissionEntity(obj, false, true)
        NetworkRequestControlOfEntity(obj)
        local timeout = 0
        while not NetworkHasControlOfEntity(obj) and timeout < 5000 do
            timeout = timeout + 100
            Wait(100)
        end
        FreezeEntityPosition(obj, false)
        DeleteEntity(obj)
    end
)

RegisterNetEvent(
    "redemrp_inventory:PickupAnim",
    function()
        local dict = "amb_work@world_human_box_pickup@1@male_a@stand_exit_withprop"
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(10)
        end
        TaskPlayAnim(PlayerPedId(), dict, "exit_front", 1.0, 8.0, -1, 1, 0, false, false, false)
        Wait(1200)
        PlaySoundFrontend("CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", true, 1)
        Wait(1000)
        ClearPedTasks(PlayerPedId())
    end
)

RegisterNetEvent(
    "redemrp_inventory:UpdatePickups",
    function(pick)
        DroppedItems = pick
    end
)

local PickupPromptGroup = GetRandomIntInRange(0, 0xffffff)
print("PickupPromptGroup: " .. PickupPromptGroup)
local PickupPrompt
local PromptActive = false

function SetupPickPrompt()
    Citizen.CreateThread(
        function()
            local str = "Pick Up"
            PickupPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
            PromptSetControlAction(PickupPrompt, 0xF84FA74F)
            str = CreateVarString(10, "LITERAL_STRING", str)
            PromptSetText(PickupPrompt, str)
            PromptSetEnabled(PickupPrompt, true)
            PromptSetVisible(PickupPrompt, true)
            PromptSetHoldMode(PickupPrompt, true)
            PromptSetGroup(PickupPrompt, PickupPromptGroup)
            PromptRegisterEnd(PickupPrompt)
        end
    )
end

Citizen.CreateThread(
    function()
        local wait = 1
        SetupPickPrompt()
        while true do
            Citizen.Wait(wait)

            local can_wait = true
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)

            if next(DroppedItems) == nil then
                Citizen.Wait(500)
            end

            if DroppedItems ~= nil then
                for k, v in pairs(DroppedItems) do
                    local distance = Vdist(coords, v.coords.x, v.coords.y, v.coords.z)
                    if distance <= 15.0 then
                        can_wait = false
                    end

                    if distance <= 5.0 then
                        DrawText3D(v.coords.x, v.coords.y, v.coords.z + 0.5, v.label .. " " .. "[" .. v.amount .. "]")
                    end

                    if distance <= 1.2 then
                        if not PromptActive then
                            TaskLookAtEntity(playerPed, v.obj, 3000, 2048, 3)
                            local PromptGroupName = CreateVarString(10, "LITERAL_STRING", v.label)
                            PromptSetActiveGroupThisFrame(PickupPromptGroup, PromptGroupName)
                            if PromptHasHoldModeCompleted(PickupPrompt) then
                                PromptActive = true
                                TriggerServerEvent("redemrp_inventory:onPickup", k)
                            end
                        end
                    end
                end
            end
            if can_wait == true then
                wait = 2000
            else
                wait = 1
            end
        end
    end
)

RegisterNetEvent(
    "redemrp_inventory:ReEnablePrompt",
    function()
        PromptActive = false
    end
)

RegisterNetEvent(
    "redemrp_inventory:OpenStash",
    function(id, weight)
        OpenStash = id
        CurrentMaxWeight = weight
        --print(weight)
        TriggerServerEvent("redemrp_inventory:GetStash", OpenStash, weight)
    end
)

local showingmsg = false

RegisterNetEvent("redemrp_inventory:client:WeightNotif", function(txt, time)
    ShowScreenMessage(txt, time)
end)

ShowScreenMessage = function(message, time)
    Citizen.CreateThread(function ()
        if not showingmsg then
            showingmsg = true
            local textTime = GetGameTimer()
            while GetGameTimer() - textTime < time do
                Citizen.Wait(0)
                DrawTxt(message, 0.50, 0.87, 0.7, 0.7, true, 255, 255, 255, 255, true)
            end
            showingmsg = false
        end
    end)
end

function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
	SetTextCentre(centre)
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
	Citizen.InvokeNative(0xADA9255D, 9);
    DisplayText(str, x, y)
end


--==================== D R O P =======================================

RegisterNUICallback(
    "useitem",
    function(data)
        TriggerServerEvent("redemrp_inventory:use", data.data)
    end
)

RegisterNUICallback('craft', function(data)
    TriggerServerEvent("redemrp_inventory:craft", data, CraftingId)
end)

RegisterNUICallback(
    "close",
    function()
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        IsCrafting = false
        isInventoryOpen = false
        isOtherOpen = false
    end
)
