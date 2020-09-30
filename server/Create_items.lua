
function CreateItem (name, amount, meta)
    local self = {}
    self.data = Config.Items[name]
    self.name = name
    self.amount = amount
    self.meta = meta

    local rTable = {}

    rTable.getAmount = function()
        return self.amount
    end
	
	rTable.getName = function()
        return self.name
    end

    rTable.addAmount = function(number)
        if number > 0 then
            self.amount = self.amount + tonumber(number)
        end
    end
	
	 rTable.setAmount = function(number)
        if number >= 0 then
            self.amount =  tonumber(number)
        end
    end
  
   rTable.setMeta = function(meta)
         self.meta = meta
    end

    rTable.removeAmount = function(number)
        if number > 0 and self.amount - tonumber(number) >= 0 then
            self.amount = self.amount - tonumber(number)
        end
        if self.data.type == "item_standard" then
            if self.amount == 0 then
                return true
            else
                return false
            end
        end
    end

    rTable.getData = function()
        return self.data
    end

    rTable.getMeta = function()
        return self.meta
    end

    return rTable
end



function CreateInventory(items)
    local items_table = {}
    local weight = 0.0
    for i,k in pairs(items) do
        local meta = k.meta or {}
		if Config.Items[i] then
            table.insert(items_table, CreateItem(i, k.amount, meta))
            if items_table[#items_table].getData().type == "item_standard" then
                weight = weight + items_table[#items_table].getData().weight * k.amount
            else
                weight = weight + items_table[#items_table].getData().weight
            end
		end
    end
    return items_table, weight 
end


function PrepareToOutput(items)
    local items_table = {}
	local _items = items or {}
	local id = 0
    for i,k in pairs(_items) do
		table.insert(items_table ,{name = k.getName(), amount = k.getAmount(), meta = k.getMeta(), label = k.getData().label , type = k.getData().type , weaponHash = k.getData().weaponHash ,  weight = k.getData().weight , description = k.getData().description , imgsrc = k.getData().imgsrc})
	end
    return items_table
end
