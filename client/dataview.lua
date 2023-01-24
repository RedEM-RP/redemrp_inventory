
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
----------------- 			DATAVIEW FUNCTIONS					-------------
-----------------										-------------
----------------- 		BIG THNKS to gottfriedleibniz for this DataView in LUA.		-------------
----------------- https://gist.github.com/gottfriedleibniz/8ff6e4f38f97dd43354a60f8494eedff	-------------
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

local _strblob = string.blob or function(length)
    return string.rep("\0", math.max(40 + 1, length))
end

DataView = {
    EndBig = ">",
    EndLittle = "<",
    Types = {
        Int8 = { code = "i1", size = 1 },
        Uint8 = { code = "I1", size = 1 },
        Int16 = { code = "i2", size = 2 },
        Uint16 = { code = "I2", size = 2 },
        Int32 = { code = "i4", size = 4 },
        Uint32 = { code = "I4", size = 4 },
        Int64 = { code = "i8", size = 8 },
        Uint64 = { code = "I8", size = 8 },

        LuaInt = { code = "j", size = 8 },
        UluaInt = { code = "J", size = 8 },
        LuaNum = { code = "n", size = 8},
        Float32 = { code = "f", size = 4 },
        Float64 = { code = "d", size = 8 },
        String = { code = "z", size = -1, },
    },

    FixedTypes = {
        String = { code = "c", size = -1, },
        Int = { code = "i", size = -1, },
        Uint = { code = "I", size = -1, },
    },
}
DataView.__index = DataView
local function _ib(o, l, t) return ((t.size < 0 and true) or (o + (t.size - 1) <= l)) end
local function _ef(big) return (big and DataView.EndBig) or DataView.EndLittle end
local SetFixed = nil
function DataView.ArrayBuffer(length)
    return setmetatable({
        offset = 1, length = length, blob = _strblob(length)
    }, DataView)
end
function DataView.Wrap(blob)
    return setmetatable({
        offset = 1, blob = blob, length = blob:len(),
    }, DataView)
end
function DataView:Buffer() return self.blob end
function DataView:ByteLength() return self.length end
function DataView:ByteOffset() return self.offset end
function DataView:SubView(offset)
    return setmetatable({
        offset = offset, blob = self.blob, length = self.length,
    }, DataView)
end
for label,datatype in pairs(DataView.Types) do
    DataView["Get" .. label] = function(self, offset, endian)
        local o = self.offset + offset
        if _ib(o, self.length, datatype) then
            local v,_ = string.unpack(_ef(endian) .. datatype.code, self.blob, o)
            return v
        end
        return nil
    end

    DataView["Set" .. label] = function(self, offset, value, endian)
        local o = self.offset + offset
        if _ib(o, self.length, datatype) then
            return SetFixed(self, o, value, _ef(endian) .. datatype.code)
        end
        return self
    end
    if datatype.size >= 0 and string.packsize(datatype.code) ~= datatype.size then
        local msg = "Pack size of %s (%d) does not match cached length: (%d)"
        error(msg:format(label, string.packsize(fmt[#fmt]), datatype.size))
        return nil
    end
end
for label,datatype in pairs(DataView.FixedTypes) do
    DataView["GetFixed" .. label] = function(self, offset, typelen, endian)
        local o = self.offset + offset
        if o + (typelen - 1) <= self.length then
            local code = _ef(endian) .. "c" .. tostring(typelen)
            local v,_ = string.unpack(code, self.blob, o)
            return v
        end
        return nil
    end
    DataView["SetFixed" .. label] = function(self, offset, typelen, value, endian)
        local o = self.offset + offset
        if o + (typelen - 1) <= self.length then
            local code = _ef(endian) .. "c" .. tostring(typelen)
            return SetFixed(self, o, value, code)
        end
        return self
    end
end

SetFixed = function(self, offset, value, code)
    local fmt = { }
    local values = { }
    if self.offset < offset then
        local size = offset - self.offset
        fmt[#fmt + 1] = "c" .. tostring(size)
        values[#values + 1] = self.blob:sub(self.offset, size)
    end
    fmt[#fmt + 1] = code
    values[#values + 1] = value
    local ps = string.packsize(fmt[#fmt])
    if (offset + ps) <= self.length then
        local newoff = offset + ps
        local size = self.length - newoff + 1

        fmt[#fmt + 1] = "c" .. tostring(size)
        values[#values + 1] = self.blob:sub(newoff, self.length)
    end
    self.blob = string.pack(table.concat(fmt, ""), table.unpack(values))
    self.length = self.blob:len()
    return self
end

DataStream = { }
DataStream.__index = DataStream

function DataStream.New(view)
    return setmetatable({ view = view, offset = 0, }, DataStream)
end

for label,datatype in pairs(DataView.Types) do
    DataStream[label] = function(self, endian, align)
        local o = self.offset + self.view.offset
        if not _ib(o, self.view.length, datatype) then
            return nil
        end
        local v,no = string.unpack(_ef(endian) .. datatype.code, self.view:Buffer(), o)
        if align then
            self.offset = self.offset + math.max(no - o, align)
        else
            self.offset = no - self.view.offset
        end
        return v
    end
end

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
----------------- 										------------
-----------------		END OF DATAVIEW FUNCTIONS					------------
----------------- 										------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

function getGuidFromItemId(inventoryId, itemData, category, slotId) 
    local outItem = DataView.ArrayBuffer(8 * 13)
 
    if not itemData then
        itemData = 0
    end
 
    local success = Citizen.InvokeNative("0x886DFD3E185C8A89", inventoryId, itemData, category, slotId, outItem:Buffer()) --InventoryGetGuidFromItemid
    if success then
        return outItem:Buffer() --Seems to not return anythign diff. May need to pull from native above
    else
        return nil
    end
end
 
function addWardrobeInventoryItem(itemName, slotHash)
    local itemHash = GetHashKey(itemName)
    local addReason = GetHashKey("ADD_REASON_DEFAULT")
    local inventoryId = 1
 
    -- _ITEMDATABASE_IS_KEY_VALID
    local isValid = Citizen.InvokeNative("0x6D5D51B188333FD1", itemHash, 0) --ItemdatabaseIsKeyValid
    if not isValid then
        return false
    end
 
    local characterItem = getGuidFromItemId(inventoryId, nil, GetHashKey("CHARACTER"), 0xA1212100)
    if not characterItem then
        return false
    end
 
    local wardrobeItem = getGuidFromItemId(inventoryId, characterItem, GetHashKey("WARDROBE"), 0x3DABBFA7)
    if not wardrobeItem then
        return false 
    end
 
    local itemData = DataView.ArrayBuffer(8 * 13)
 
    -- _INVENTORY_ADD_ITEM_WITH_GUID
    local isAdded = Citizen.InvokeNative("0xCB5D11F9508A928D", inventoryId, itemData:Buffer(), wardrobeItem, itemHash, slotHash, 1, addReason);
    if not isAdded then
        return false
    end
 
    -- _INVENTORY_EQUIP_ITEM_WITH_GUID
    local equipped = Citizen.InvokeNative("0x734311E2852760D0", inventoryId, itemData:Buffer(), true);
    return equipped;
end

function givePlayerWeapon(weaponName, attachPoint)
    local addReason = GetHashKey("ADD_REASON_DEFAULT");
    local weaponHash = weaponName;
    local ammoCount = 0;
 
    -- RequestWeaponAsset
    Citizen.InvokeNative(0x72D4CB5DB927009C, weaponHash, 0, true);
    while not Citizen.InvokeNative(0xFF07CF465F48B830, weaponHash) do Wait(10) end
    -- GIVE_WEAPON_TO_PED
    Citizen.InvokeNative(0x5E3BDDBCB83F3D84, PlayerPedId(), weaponHash, ammoCount, true, false, attachPoint, true, 0.0, 0.0, addReason, true, 0.0, false);
end
