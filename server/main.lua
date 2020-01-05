RegisterServerEvent("player:getItems")
RegisterServerEvent("item:giveItem")
local invTable = {}

data = {}
local inventory = {}
data = inventory

AddEventHandler('redemrp_inventory:getData', function(cb)
    cb(data)
end)

AddEventHandler("player:getItems", function()
    local _source = source

    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")
        --print(identifier)

        MySQL.Async.fetchAll('SELECT * FROM user_inventory WHERE `identifier`=@identifier AND `charid`=@charid;', {identifier = identifier, charid = charid}, function(inventory)

                if inventory[1] ~= nil then
                    print("doing stuff")
                    local inv = json.decode(inventory[1].items)
                    table.insert(invTable, {id = identifier, charid = charid , inventory = inv})
                    for i,k in pairs(invTable) do
                        if k.id == identifier and k.charid == charid then
                            TriggerClientEvent("gui:getItems", _source, k.inventory)
                            break end
                    end

                else
                    local test = {
                        ["water"] = 3,
                        ["bread"] = 3,
                    }  MySQL.Async.execute('INSERT INTO user_inventory (`identifier`, `charid`, `items`) VALUES (@identifier, @charid, @items);',
                        {
                            identifier = identifier,
                            charid = charid,
                            items = json.encode(test)
                        }, function(rowsChanged)
                        end)
                    table.insert(invTable, {id = identifier, charid = charid , inventory = test})
                    for i,k in pairs(invTable) do
                        if k.id == identifier and k.charid == charid then
                            TriggerClientEvent("gui:getItems", _source, k.inventory)
                            break end
                    end
                end
        end)

    end)
end)


AddEventHandler('player:savInvSv', function(source, id)
    local _source = source
    local _id = id

    if _id ~= nil then
        _source = tonumber(_id)
        print(source, 'forcing save for', _source, '...')
    end
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")
        --print(identifier)
        for i,k in pairs(invTable) do
            if k.id == identifier and k.charid == charid then
                for name,value in pairs(k.inventory) do
			          if value == 0 then
			              k.inventory[name] = nil
			         end
			    end
                MySQL.Async.execute('UPDATE user_inventory SET items = @items WHERE identifier = @identifier AND charid = @charid', {
                    ['@identifier']  = identifier,
                    ['@charid']  = charid,
                    ['@items'] = json.encode(k.inventory)
                }, function (rowsChanged)
                    if rowsChanged == 0 then
                        print(('user_inventory: Something went wrong saving %s!'):format(identifier .. ":" .. charid))
                    else
                        print("saved")
                    end
                end)

                break end
        end

    end)
end)

AddEventHandler("item:add", function(source, arg, identifier , charid)
    local _source = source
    for i,k in pairs(invTable) do
        if k.id == identifier and k.charid == charid then
            local name = tostring(arg[1])
            local amount = arg[2]
            if k.inventory[(name)] ~= nil then
                local val = k.inventory[name]
                newVal = val + amount
                print(val)
                print(qty)
                print(newVal)
                k.inventory[name]= tonumber(math.floor(newVal))
                TriggerClientEvent("gui:getItems", _source, k.inventory)
                TriggerEvent("player:savInvSv", _source)
                break
            else
                TriggerEvent("item:new",_source, name, amount, identifier , charid)
            end
        end
    end

end)

AddEventHandler("item:new", function(source, item, amount, identifier , charid)
    local _source = source
    for i,k in pairs(invTable) do
        if k.id == identifier and k.charid == charid then
            local name = tostring(item)
            local val = tonumber(amount)
            k.inventory[(name)] = val
            TriggerClientEvent("gui:getItems", _source, k.inventory)
            TriggerEvent("player:savInvSv", _source)
            break end
    end

end)

AddEventHandler("item:delete", function(source, arg, identifier , charid)
    local _source = source
    for i,k in pairs(invTable) do
        if k.id == identifier and k.charid == charid then
            local name = tostring(arg[1])
            local qty = tonumber(arg[2])
            local val = tonumber(k.inventory[name])
            newVal = val - qty
            k.inventory[name]= tonumber(newVal)
            TriggerClientEvent("gui:getItems", _source, k.inventory)
            TriggerEvent("player:savInvSv", _source)
            break end
    end
end)


RegisterServerEvent("item:onpickup")
AddEventHandler("item:onpickup", function(id)
    local _source = source
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")
        for i,k in pairs(invTable) do
            if k.id == identifier and k.charid == charid then
                local pickup  = Pickups[id]
                TriggerEvent("item:add", _source ,{pickup.name, pickup.amount}, identifier , charid)
                TriggerClientEvent("item:Sharepickup", -1, pickup.name, pickup.obj , pickup.amount, x, y, z, 2)
                TriggerClientEvent('item:removePickup', -1, pickup.obj)
                Pickups[id] = nil
                TriggerClientEvent('gui:ReloadMenu', _source)
                break
            end
        end
    end)
end)



RegisterCommand('giveitem', function(source, args)
    local _source = source
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")
        for i,k in pairs(invTable) do
            if k.id == identifier and k.charid == charid then
                local item = args[1]
                local amount = args[2]
                TriggerEvent("item:add", _source, {item, amount}, identifier , charid)
                print("add")
                TriggerClientEvent('gui:ReloadMenu', _source)
                break
            end
        end
    end)
end)


RegisterServerEvent("item:use")
AddEventHandler("item:use", function(val)
    local _source = source
    local name = val
    local amount = 1
    print("poszlo")
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")
        for i,k in pairs(invTable) do
            if k.id == identifier and k.charid == charid then
                TriggerEvent("RegisterUsableItem:"..name, _source)
                TriggerClientEvent("redemrp_notification:start", _source, "Item used: "..name, 3, "success")
                TriggerClientEvent('gui:ReloadMenu', _source)
                break
            end
        end
    end)
end)



RegisterServerEvent("item:drop")
AddEventHandler("item:drop", function(val, amount)
    local _source = source
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")
        for i,k in pairs(invTable) do
            if k.id == identifier and k.charid == charid then
                local name = val
                local value = k.inventory[name]
                print(value)
                print(amount)
                local all = value-amount
                print(all)
                if all >= 0 then
                    TriggerClientEvent('item:pickup',_source, name, amount)
                    TriggerEvent("item:delete", _source, {name , amount}, identifier , charid)
                    TriggerClientEvent('gui:ReloadMenu', _source)
                end
                break
            end
        end
    end)
end)

RegisterServerEvent("item:SharePickupServer")
AddEventHandler("item:SharePickupServer", function(name, obj , amount, x, y, z)
    TriggerClientEvent("item:Sharepickup", -1, name, obj , amount, x, y, z, 1)
    print("poszlo server")
    Pickups[obj] = {
        name = name,
        obj = obj,
        amount = amount,
        inRange = false,
        coords = {x = x, y = y, z = z}
    }
end)

RegisterServerEvent("test_lols")
AddEventHandler("test_lols", function(name, amount , target)
    local _target = target
    local _source = source
    local _name = name
    local _amount = amount
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")
        for i,k in pairs(invTable) do
            if k.id == identifier and k.charid == charid then
                local value = k.inventory[name]
                local all = value-amount
                if all >= 0 then
                    TriggerEvent("item:delete",_source, { name , amount}, identifier , charid)
                    TriggerEvent('test_lols222', _target , name , amount)
                    TriggerClientEvent('gui:ReloadMenu', _source)
                    TriggerClientEvent("redemrp_notification:start", _source, "You have given: [X"..tonumber(amount).."]"..name.. " to " ..GetPlayerName(_target), 3, "success")
                    TriggerClientEvent("redemrp_notification:start", _target, "You've received [X"..tonumber(amount).."]"..name.. " from " ..GetPlayerName(_source), 3, "success")
                end
                break
            end
        end
    end)
end)

RegisterServerEvent("test_lols222")
AddEventHandler("test_lols222", function(source, name, amount)
    local _source = source
    local _name = name
    local _amount = amount
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")
        for i,k in pairs(invTable) do
            if k.id == identifier and k.charid == charid then
                TriggerEvent("item:add",_source, {name, amount}, identifier , charid)
                TriggerClientEvent('gui:ReloadMenu', _source)

                break
            end
        end
    end)
end)

function inventory.checkItem(_source, name)
    local value = 0
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")
        for i,k in pairs(invTable) do
            if k.id == identifier and k.charid == charid then
                value = k.inventory[name]
            end
        end
    end)
    return tonumber(value)
end
function inventory.addItem(_source, name , amount)
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")

        TriggerEvent("item:add", _source ,{name, amount}, identifier , charid)
    end)
end

function inventory.delItem(_source, name , amount)
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")

        TriggerEvent("item:delete", _source, {name , amount}, identifier , charid)
    end)
end
--------EXAMPLE---------Register Usable item---------------EXAMPLE
RegisterServerEvent("RegisterUsableItem:wood")
AddEventHandler("RegisterUsableItem:wood", function(source)
    print("test")
end)
------------------------EXAMPLE----------------------------EXAMPLE

