-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local Inventory = Class.NewClass(ObjBase)

--[[
    This module implements the class Inventory.

    A Inventory object represents an inventory in the minecraft world.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function Inventory:_init(...)
    -- get & check input from description
    local checkSuccess, slotTable, itemTable = InputChecker.Check([[
        Initialise a Chest.

        Parameters:
            slotTable               + (table, {}) slotTable
            itemTable               + (table, {}) itemTable
    ]], ...)
    if not checkSuccess then corelog.Error("Inventory:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._slotTable = slotTable
    self._itemTable = itemTable
end

-- ToDo: should be renamed to newFromTable at some point
function Inventory:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a Inventory.

        Parameters:
            o                           + (table, {}) table with object fields
                _slotTable              - (table, {}) slotTable
                _itemTable              - (table, {}) itemTable
    ]], ...)
    if not checkSuccess then corelog.Error("Inventory:new: Invalid input") return {} end

    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function Inventory:getSlotTable()
    return self._slotTable
end

function Inventory:setSlotTable(slotTable)
    -- check input
    if not Inventory.IsSlotTable(slotTable) then corelog.Error("Inventory:setSlotTable: invalid slotTable: "..type(slotTable)) return end

    self._slotTable = slotTable
    self._itemTable = {} -- note: drop current and have it rebuild once needed
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function Inventory:getClassName()
    return "Inventory"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function Inventory:isEmpty()
    -- check
    local isEmpty = next(self._slotTable) == nil

    -- end
    return isEmpty
end

function Inventory:hasNoItems()
    -- get getItemTable
    local itemTable = self:getItemTable()

    -- check
    local hasNoItems = next(itemTable) == nil

    -- end
    return hasNoItems
end

function Inventory:getItemTable()
    -- check _itemTable already build
    if not self:isEmpty() and next(self._itemTable) == nil then
        self._itemTable = self:buildItemTable()
    end

    return self._itemTable
end

function Inventory:buildItemTable()
    -- new itemTable
    local itemTable = {}

    -- loop on slots
    for slot, item in pairs(self._slotTable) do
        -- right item?
        if type(item) == "table" then
            -- add to items
            itemTable[ item.name ]  = (itemTable[ item.name ] or 0) + item.count

            -- remove key (in case of substract)
            if itemTable[ item.name ] == 0 then itemTable[ item.name ] = nil end
        end
    end

    -- end
    return itemTable
end

function Inventory:hasItems(...)
    -- get & check input from description
    local checkSuccess, items = InputChecker.Check([[
        This sync public query service answers the question whether the ItemSupplier can provide specific items.

        Return value:
                            - (boolean) whether the answer to the question is true

        Parameters:
            items           + (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs)
    --]], ...)
    if not checkSuccess then corelog.Error("Inventory:hasItems: Invalid input") return false end

    -- query chests inventory
    local itemTable = self:getItemTable()
    for itemName, itemCount in pairs(items) do
        if type(itemName) ~= "string" then corelog.Error("Inventory:hasItems: itemName of wrong type = "..type(itemName)..".") return false end
        if type(itemCount) ~= "number" then corelog.Error("Inventory:hasItems: itemCount of wrong type = "..type(itemCount)..".") return false end

        local inventoryCount = itemTable[itemName]
        if itemCount ~= 0 and (inventoryCount == nil or inventoryCount < itemCount) then
            return false
        end
    end

    -- end
    return true
end

function Inventory:substract(...)
    -- get & check input from description
    local checkSuccess, inventoryToCompare = InputChecker.Check([[
        Basic subtraction of two inventories, self and given by parameter
        Warning: Uses negative slots
        Note: has itemTable calculated

        Return value:
                            - (Inventory) new inventory with differences between self and given inventory.

        Parameters:
            inventory       + (Inventory) inventory to subtract from self
    --]], ...)
    if not checkSuccess then corelog.Error("Inventory:substract: Invalid input") return false end

    -- the variable we are going to calculate
    local calculatedSlotList = {}

    -- loop all slots
    for slot = 1, 16 do

        -- here we go, use negative slots because the itemName can be different
        if inventoryToCompare._slotTable[slot]  ~= nil then calculatedSlotList[-slot]   = { name = inventoryToCompare._slotTable[slot].name,    count = -inventoryToCompare._slotTable[slot].count }    end
        if self._slotTable[slot]                ~= nil then calculatedSlotList[slot]    = { name = self._slotTable[slot].name,                  count = self._slotTable[slot].count }                   end
    end

    local calculatedInventory = Inventory:newInstance(calculatedSlotList)
    calculatedInventory:getItemTable()

    -- we are done!!
    return calculatedInventory
end

--    _          _                    __                  _   _
--   | |        | |                  / _|                | | (_)
--   | |__   ___| |_ __   ___ _ __  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | '_ \ / _ \ | '_ \ / _ \ '__| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | | |  __/ | |_) |  __/ |    | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_| |_|\___|_| .__/ \___|_|    |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--                | |
--                |_|

function Inventory.IsItemTable(itemTable)
    -- check table
    if type(itemTable) ~= "table" then return false end

    -- check elements
    for itemName, itemCount in pairs(itemTable) do
        if type(itemName) ~= "string" then return false end
        if type(itemCount) ~= "number" then return false end
    end

    -- end
    return true
end

function Inventory.IsEqualItemTable(itemTableA, itemTableB)
    -- check input
    if not Inventory.IsItemTable(itemTableA) or not Inventory.IsItemTable(itemTableB) then return false end

    -- check all itemTableA elements are in itemTableB
    local sizeA = 0
    for itemNameA, itemCountA in pairs(itemTableA) do
        local itemBCount = itemTableB[itemNameA]
        sizeA = sizeA + 1

        -- check same
        if itemCountA ~= itemBCount then return false end
    end

    -- check same size
    local sizeB = 0
    for _ in pairs(itemTableB) do
        sizeB = sizeB + 1
    end
    if sizeA ~= sizeB then return false end

    -- end
	return true
end

function Inventory.ItemTableCopy(itemTable)
    -- check input
    if not Inventory.IsItemTable(itemTable) then corelog.Error("Inventory.ItemTableCopy: invalid itemTable: "..type(itemTable)) return end

    local copy = {}
    -- copy elements
    for itemName, itemCount in pairs(itemTable) do
        -- add to items
        copy[ itemName ] = itemCount
    end

    -- end
	return copy
end

function Inventory.IsSlotTable(slotTable)
    -- check table
    if type(slotTable) ~= "table" then return false end

    -- check elements
    for slot, item in pairs(slotTable) do
        if type(slot) ~= "number" then return false end
        if type(item) ~= "table" then return false end
        if type(item.name) ~= "string" then return false end
        if type(item.count) ~= "number" then return false end
    end

    -- end
    return true
end

function Inventory.IsEqualSlotTable(slotTableA, slotTableB)
    -- check input
    if not Inventory.IsSlotTable(slotTableA) or not Inventory.IsSlotTable(slotTableB) then return false end

    -- check all slotTableA elements are the same as in slotTableB
    local sizeA = 0
    for slot, itemA in pairs(slotTableA) do
        local itemB = slotTableB[slot]
        sizeA = sizeA + 1

        -- check same
        if itemA.name ~= itemB.name then return false end
        if itemA.count ~= itemB.count then return false end
    end

    -- check same size
    local sizeB = 0
    for _ in pairs(slotTableB) do
        sizeB = sizeB + 1
    end
    if sizeA ~= sizeB then return false end

    -- end
	return true
end

function Inventory.SlotTableCopy(slotTable)
    -- check input
    if not Inventory.IsSlotTable(slotTable) then corelog.Error("Inventory.SlotTableCopy: invalid slotTable: "..type(slotTable)) return end

    local copy = {}
    -- copy elements
    for slot, item in pairs(slotTable) do
        -- add to items
        copy[ slot ] = {
            name = item.name,
            count = item.count
        }
    end

    -- end
	return copy
end

return Inventory
