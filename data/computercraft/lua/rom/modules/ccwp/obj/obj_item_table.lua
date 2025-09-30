-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ItemTable = Class.NewClass(ObjBase)

--[[
    This module implements the class ItemTabel.

    An item table object for comparing and calculating
--]]

local corelog = require "corelog"
local InputChecker = require "input_checker"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function ItemTable:_init(...)
    -- get & check input from description
    local checkSuccess, itemsTable = InputChecker.Check([[
        Initialise a ItemTable.

        Parameters:
            itemsTable              + (table, {}) with key, value pairs of items
    ]], ...)
    if not checkSuccess then corelog.Error("ItemTable:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    for itemName, itemCount in pairs(itemsTable) do
        if type(itemName) ~= "string" then
            corelog.Warning("ItemTable:_init: itemName type(="..type(itemName)..") not a string => skipped")
        elseif type(itemCount) ~= "number" then
            corelog.Warning("ItemTable:_init: itemName type(="..type(itemCount)..") not a number => skipped")
        else
            self[itemName] = itemCount
        end
    end
end

-- ToDo: should be renamed to newFromTable at some point
function ItemTable:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a Inventory.

        Parameters:
            o                           + (table, {}) table with object fields
    ]], ...)
    if not checkSuccess then corelog.Error("ItemTable:new: Invalid input") return {} end

    setmetatable(o, self)
    self.__index = self
    return o
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function ItemTable:getClassName()
    return "ItemTable"
end

--    _____ _              _______    _     _
--   |_   _| |            |__   __|  | |   | |
--     | | | |_ ___ _ __ ___ | | __ _| |__ | | ___
--     | | | __/ _ \ '_ ` _ \| |/ _` | '_ \| |/ _ \
--    _| |_| ||  __/ | | | | | | (_| | |_) | |  __/
--   |_____|\__\___|_| |_| |_|_|\__,_|_.__/|_|\___|

function ItemTable:isEmpty()
    -- end
    return next(self) == nil
end

function ItemTable:hasNoItems()
    -- loop all items
    for itemName, itemCount in pairs(self) do if itemCount ~= 0 then return false end end

    -- if we get here, there were no items
    return true
end

function ItemTable:nEntries()
    --[[
        Return the number of item entries in the ItemTable.
    ]]

    local nEntries = 0
    for itemName, itemCount in pairs(self) do nEntries = nEntries + 1 end

    -- end
    return nEntries
end

function ItemTable:nSlotsNeeded()
    --[[
        Return the number of free slots needed to store all items
    ]]

    local nSlotsNeeded = 0
    for itemName, itemCount in pairs(self) do
        -- use slots for item
        local stackSize = 64 -- ToDo: use change this to use real stackSize
        local nItemSlots = math.ceil(itemCount/ stackSize)

        nSlotsNeeded = nSlotsNeeded + nItemSlots
    end

    -- end
    return nSlotsNeeded
end

function ItemTable:add(itemName, itemCount)
    -- check parameters
    if type(itemName) ~= "string" or type(itemCount) ~= "number" then corelog.Warning("ItemTable:add(): bad parameter(s)") return end

    -- just add this one item to the self
    self[itemName]  = (self[itemName] or 0) + itemCount
end

function ItemTable.combine(...)
    -- get & check input from description
    local checkSuccess, firstItemList, secondItemList = InputChecker.Check([[
        This function combine two tables to one new item table

        Return value:
                            - (itemTable) new item table with both item tables combined

        Parameters:
            firstItemList   + (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs)
            secondItemList  + (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs)
        --]], ...)
    if not checkSuccess then corelog.Error("ItemTable.combine: Invalid input") return nil end

    -- for the new list
    local combined      = {}

    -- loop the first, copy all to the combined
    for itemName, itemCount in pairs(firstItemList) do combined[ itemName ] = itemCount end

    -- loop the second, might be a value present
    for itemName, itemCount in pairs(secondItemList) do combined[ itemName ] = (combined[ itemName ] or 0) + itemCount end

    -- no need to thank us
    return ItemTable:newInstance(combined)
end

function ItemTable.compare(...)
    -- get & check input from description
    local checkSuccess, firstItemList, secondItemList = InputChecker.Check([[
        This function compares two item tables, to see which items/counts are unique, and which are shared.
        This function can be used to substract an ItemTable from another ItemTable, since the remainder is what's unique in the first.

        Return value:
                            - (itemTable) unique in first
                            - (itemTable) shared in both
                            - (itemTable) unique in second

        Parameters:
            firstItemList   + (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs)
            secondItemList  + (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs)
        --]], ...)
    if not checkSuccess then corelog.Error("ItemTable.compare: Invalid input") return nil, nil, nil end

    -- this is what we will return
    local uniqueFirst   = {}
    local common        = {}
    local uniqueSecond  = {}

    -- loop the first
    for firstName, firstCount in pairs(firstItemList) do

        -- is this one also in the seconed?
        if type(secondItemList[ firstName ]) == "number" then

            -- both have this item, see which has the least
            local itemCount = math.min(firstCount, secondItemList[ firstName ])

            -- this is what both have in common
            common[ firstName ] = itemCount

            -- this is what's left in the first
            if firstCount > itemCount then

                -- the first had more
                uniqueFirst[ firstName ] = firstCount - itemCount

            -- maybe the second had more
            elseif secondItemList[ firstName ] > itemCount then

                -- the first had more
                uniqueSecond[ firstName ] = secondItemList[ firstName ] - itemCount
            end

        else
            -- nope, this item is only in the first
            uniqueFirst[ firstName ] = firstCount
        end
    end

    -- might be in the second but not in the first.
    for secondName, secondCount in pairs(secondItemList) do

            -- unique for the second?
            if firstItemList[ secondName ] == nil then

                -- yes, unique to the second item table
                uniqueSecond[ secondName ] = secondCount
            end
    end

    -- end
    return ItemTable:newInstance(uniqueFirst), ItemTable:newInstance(common), ItemTable:newInstance(uniqueSecond)
end

function ItemTable.LargeItemCount()
    return 99999
end

return ItemTable
