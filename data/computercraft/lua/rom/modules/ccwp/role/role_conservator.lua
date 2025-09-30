-- define role
local role_conservator = {}

--[[
    This role deals with the management of items within storage containers (e.g. Chest's).
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"
local coremove = require "coremove"
local coreinventory = require "coreinventory"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local Inventory = require "obj_inventory"
local Location = require "obj_location"
local ItemTable = require "obj_item_table"

local ObjHost = require "obj_host"

local enterprise_dump

--    _______        _                   __  __      _        _____        _
--   |__   __|      | |          ___    |  \/  |    | |      |  __ \      | |
--      | | __ _ ___| | _____   ( _ )   | \  / | ___| |_ __ _| |  | | __ _| |_ __ _
--      | |/ _` / __| |/ / __|  / _ \/\ | |\/| |/ _ \ __/ _` | |  | |/ _` | __/ _` |
--      | | (_| \__ \   <\__ \ | (_>  < | |  | |  __/ || (_| | |__| | (_| | || (_| |
--      |_|\__,_|___/_|\_\___/  \___/\/ |_|  |_|\___|\__\__,_|_____/ \__,_|\__\__,_|

function role_conservator.FetchChestSlotsInventory_MetaData(...)
    -- get & check input from description
    local checkSuccess, location, accessDirection = InputChecker.Check([[
        This function returns the MetaData for FetchChestSlotsInventory_Task.

        Return value:
                                - (table) metadata

        Parameters:
            taskData            - (table) data about the Chest
                location        + (Location) location of the Chest
                accessDirection + (string) whether to access Chest from "bottom", "top", "left", "right", "front" or "back" (relative to location)
    ]], ...)
    if not checkSuccess then corelog.Error("role_conservator.FetchChestSlotsInventory_MetaData: Invalid input") return {} end

    -- determine needed items
    local workingLocation = location:getWorkingLocation(accessDirection)
    if not workingLocation then corelog.Error("role_conservator.FetchChestSlotsInventory_MetaData: Failed to determine workingLocation") return {} end
    local fuelNeeded = 5 -- task starts at workingLocation, very little (0) movement from there, a few extra to be sure

    -- return metadata
    return {
        startTime = coreutils.UniversalTime(),
        location = workingLocation:copy(),
        needTool = false,
        needTurtle = true,
        fuelNeeded = fuelNeeded,
        itemsNeeded = {}
    }
end

function role_conservator.FetchChestSlotsInventory_Task(...)
    -- get & check input from description
    local checkSuccess, location, accessDirection = InputChecker.Check([[
        This Task function fetches the slots inventory of a Chest.

        The slots inventory is retrieved by the list method as described here: https://tweaked.cc/generic_peripheral/inventory.html

        Return value:
                                - (table)
                success         - (boolean) when the inventory was successfully retrieved
                inventory       - (Inventory) the Inventory of the Chest

        Parameters:
            taskData            - (table) data about the Chest
                location        + (Location) location of the Chest
                accessDirection + (string) whether to access Chest from "bottom", "top", "left", "right", "front" or "back" (relative to location)
    ]], ...)
    if not checkSuccess then corelog.Error("role_conservator.FetchChestSlotsInventory_Task: Invalid input") return {success = false} end

    -- move to workingLocation
    local workingLocation = location:getWorkingLocation(accessDirection)
    if type(workingLocation) ~= "table" then corelog.Error("role_conservator.FetchChestSlotsInventory_Task: Failed to determine workingLocation") return {success = false} end
--    corelog.WriteToLog("  moving to workingLocation="..textutils.serialize(workingLocation))
    coremove.GoTo(workingLocation)

    -- get access to Chest
    local peripheralName = Location.ConvertAccessDirectionToPeripheralName(accessDirection)
    local chest = peripheral.wrap(peripheralName)
    if type(chest) ~= "table" then corelog.Error("role_conservator.FetchChestSlotsInventory_Task: No Chest at "..textutils.serialize(location).." accessible from "..accessDirection..".") return {success = false} end

    -- get inventory
    local slots = chest.list()
    local inventory = Inventory:newInstance(slots)

    -- end
    local result = {
        success     = true,
        inventory   = inventory,
    }
    return result
end

function role_conservator.FetchItemsFromChestIntoTurtle_MetaData(...)
    -- get & check input from description
    local checkSuccess, turtleId, location, accessDirection, priorityKey = InputChecker.Check([[
        This function returns the MetaData for FetchItemsFromChestIntoTurtle_Task.

        Return value:
                                - (table) metadata

        Parameters:
            taskData            - (table) data about the task
                turtleId        + (number, -1) optional id of the turtle that should get the items
                location        + (Location) location of the Chest
                accessDirection + (string) whether to access Chest from "bottom", "top", "left", "right", "front" or "back" (relative to location)
                itemsQuery      - (table) which items to be fetched
                priorityKey     + (string, "") priorityKey for this assignment
    ]], ...)
    if not checkSuccess then corelog.Error("role_conservator.FetchItemsFromChestIntoTurtle_MetaData: Invalid input") return { } end

    -- determine needed items
    local workingLocation = location:getWorkingLocation(accessDirection)
    if not workingLocation then corelog.Error("role_conservator.FetchItemsFromChestIntoTurtle_MetaData: Failed to determine workingLocation") return {} end
    local fuelNeeded = 5 -- task starts at workingLocation, very little (0) movement from there, a few extra to be sure

    -- check if specific turtle is needed
    local needWorkerId = nil
    if (turtleId >= 0) then
        needWorkerId = turtleId
    end

    -- return metadata
    return {
        startTime   = coreutils.UniversalTime(),
        location    = workingLocation:copy(),
        needTool    = false,
        needTurtle  = true,
        needWorkerId= needWorkerId,
        fuelNeeded  = fuelNeeded,
        itemsNeeded = {},

        priorityKey = priorityKey,
    }
end

local function MakeSlotEmpty(chestName, slotToClear)
    local chest = peripheral.wrap(chestName)
    if type(chest) ~= "table" then corelog.Error("role_conservator.MakeSlotEmpty: No Chest with chestName = "..chestName..".") return false end

    -- get slots inventory
    local slots = chest.list()
    if slots[slotToClear] then
        -- find slot for item in slot (either empty or with room)
        local countToClear = slots[slotToClear].count
        local nameToClear = slots[slotToClear].name
        local remainingItemsToMove = countToClear
--        corelog.WriteToLog("   moving "..countToClear.." "..nameToClear.." from slot "..slotToClear.." (e).")
        for iSlot=1,chest.size() do
            -- skip slotToClear
            if iSlot ~= slotToClear then
                -- determine countToMove
                local countToMove = 0
                local chestItem = slots[iSlot]
                if not chestItem then -- empty slot
                    countToMove = remainingItemsToMove
                elseif chestItem.name == nameToClear then
--                    corelog.WriteToLog("     chestItem.count="..chestItem.count.." (e).")
                    countToMove = math.min(remainingItemsToMove, coreinventory.GetStackSize(nameToClear) - chestItem.count)
                end

                -- move items
                if countToMove > 0 then
--                    corelog.WriteToLog("     try moving "..countToMove.." "..nameToClear.." from slot "..slotToClear.." to slot "..iSlot.." (e).")
                    local countTransferred = chest.pushItems(chestName, 1, countToMove, iSlot)
--                    corelog.WriteToLog("     countTransferred="..countTransferred.." (e).")
                    remainingItemsToMove = remainingItemsToMove - countTransferred
                    if remainingItemsToMove == 0 then break end
                end
            end
        end
        if remainingItemsToMove ~= 0 then corelog.Error("role_conservator.MakeSlotEmpty: could not find suitable slot to move remaining "..remainingItemsToMove.." "..nameToClear.."'s from slot "..slotToClear.." to.") return false end
    else
--        corelog.WriteToLog("   slot "..slotToClear.." already empty")
    end

    -- end
    return true
end

local function Suck(chestName, itemCount)
    if chestName == "bottom" then
        turtle.suckDown(itemCount)
    elseif chestName == "top" then
        turtle.suckUp(itemCount)
    elseif chestName == "front" then
        turtle.suck(itemCount)
    else
        corelog.Error("role_conservator.Suck: Don't know how to suck "..chestName..".") return 0
    end

    -- end
    return itemCount
end

local function Drop(chestName, itemCount)
    if chestName == "bottom" then
        turtle.dropDown(itemCount)
    elseif chestName == "top" then
        turtle.dropUp(itemCount)
    elseif chestName == "front" then
        turtle.drop(itemCount)
    else
        corelog.Error("role_conservator.Drop: Don't know how to drop "..chestName..".") return 0
    end

    -- end
    return itemCount
end

function role_conservator.FetchItemsFromChestIntoTurtle_Task(...)
    -- get & check input from description
    local checkSuccess, location, accessDirection, itemsQuery, turtleLocator = InputChecker.Check([[
        This Task function fetches items from a Chest into the inventory of a turtle.

        Return value:
                                        - (table)
                success                 - (boolean) whether the items were successfully fetched
                inventory               - (Inventory) the Inventory of the Chest (after the items have been removed)
                turtleOutputItemsLocator- (ObjLocator) locating the items that where fetched (into a turtle)

        Parameters:
            taskData                    - (table) data about the task
                turtleId                - (number, -1) optional id of the turtle that should get the items
                location                + (Location) location of the Chest
                accessDirection         + (string) whether to access Chest from "bottom", "top", "left", "right", "front" or "back" (relative to location)
                itemsQuery              + (table) which items to be fetched
                workerLocator           + (ObjLocator) locating the Turtle
    ]], ...)
    if not checkSuccess then corelog.Error("role_conservator.FetchItemsFromChestIntoTurtle_Task: Invalid input") return {success = false} end

    -- move to workingLocation
    local workingLocation = location:getWorkingLocation(accessDirection)
    if type(workingLocation) ~= "table" then corelog.Error("role_conservator.FetchItemsFromChestIntoTurtle_Task: Failed to determine workingLocation") return {success = false} end
--    corelog.WriteToLog("  moving to workingLocation="..textutils.serialize(workingLocation))
    coremove.GoTo(workingLocation)

    -- get access to Chest
    local chestName = Location.ConvertAccessDirectionToPeripheralName(accessDirection)
    local chest = peripheral.wrap(chestName)
    if type(chest) ~= "table" then corelog.Error("role_conservator.FetchItemsFromChestIntoTurtle_Task: No Chest at "..textutils.serialize(location).." accessible from "..accessDirection..".") return {success = false} end

    -- loop on requested items
    local itemResultQuery = {}
    for requestItemName, requestItemCount in pairs(itemsQuery) do
        -- check
        if type(requestItemName) ~= "string" then corelog.Error("role_conservator.FetchItemsFromChestIntoTurtle_Task: requestItemName of wrong type = "..type(requestItemName)..".") return {success = false} end
        if type(requestItemCount) ~= "number" then corelog.Error("role_conservator.FetchItemsFromChestIntoTurtle_Task: requestItemCount of wrong type = "..type(requestItemCount)..".") return {success = false} end
--        corelog.WriteToLog("   fetching "..requestItemCount.." "..requestItemName.."'s from Chest into Turtle")

        -- check enough items
        local inventory = Inventory:newInstance(chest.list())
        local items = inventory:getItemTable()
        if requestItemCount ~= 0 and (not items[requestItemName] or items[requestItemName] < requestItemCount) then corelog.Error("role_conservator.FetchItemsFromChestIntoTurtle_Task: not enough (="..requestItemCount..") "..requestItemName.." items available (="..(items[requestItemName] or "0")..") in Chest.") return {success = false} end

        -- empty first slot
        local firstSlot = 1
        if not MakeSlotEmpty(chestName, firstSlot) then corelog.Error("role_conservator.FetchItemsFromChestIntoTurtle_Task: Failed making slot "..firstSlot.." empty.") return {success = false} end

        -- transfer to first slot and suck until enough
        local remainingItemsToMove = requestItemCount
        for iSlot = 1, chest.size() do
                -- skip firstSlot
            if iSlot ~= firstSlot then
                -- get item details
                local chestItem = chest.getItemDetail(iSlot)
--                if type(chestItem) ~= "table" then corelog.Error("role_conservator.FetchItemsFromChestIntoTurtle_Task: chestItem of wrong type = "..type(chestItem)..".") return 0 end

                -- requested item in slot?
                if chestItem and chestItem.name == requestItemName then
                    -- move items to
                    local countToMove = math.min(remainingItemsToMove, chestItem.count)
--                    corelog.WriteToLog("   moving "..countToMove.." "..chestItem.name.." from slot "..iSlot.." to slot "..firstSlot)
                    chest.pushItems(chestName, iSlot, countToMove, firstSlot)

                    -- suck the items
                    local itemsSucked = Suck(chestName, countToMove)
--                    corelog.WriteToLog("   itemsSucked "..itemsSucked)
                    if itemsSucked ~= countToMove then corelog.Error("role_conservator.FetchItemsFromChestIntoTurtle_Task: not enough (="..countToMove..") "..requestItemName.." items sucked (="..itemsSucked..") from Chest.") return {success = false} end
                    itemResultQuery[requestItemName] = (itemResultQuery[requestItemName] or 0) + tonumber(itemsSucked)

                    -- more to move for this requested item?
                    remainingItemsToMove = remainingItemsToMove - countToMove
                    if remainingItemsToMove <= 0 then break end
                end
            end
        end
    end

    -- get final inventory
    local slots = chest.list()
    -- ToDo: consider double checking only exactly the requested items were moved to the turtle => itemResultQuery
    local inventory = Inventory:newInstance(slots)

    -- determine output locator
    local turtleOutputItemsLocator = turtleLocator:copy()
    turtleOutputItemsLocator:setQuery(itemResultQuery)

    -- end
    local result = {
        success                 = true,
        inventory               = inventory,
        turtleOutputItemsLocator= turtleOutputItemsLocator,
    }
    return result
end

function role_conservator.PutItemsFromTurtleIntoChest_MetaData(...)
    -- get & check input from description
    local checkSuccess, turtleId, location, accessDirection, priorityKey = InputChecker.Check([[
        This function returns the MetaData for PutItemsFromTurtleIntoChest_Task.

            Return value:
                                    - (table) metadata

        Parameters:
            taskData            - (table) data about the task
                turtleId        + (number) id of the turtle that has the items
                itemsQuery      - (table) which items to be put
                location        + (Location) location of the Chest
                accessDirection + (string) whether to access Chest from "bottom", "top", "left", "right", "front" or "back" (relative to location)
                priorityKey     + (string, "") priorityKey for this assignment
    --]], ...)
    if not checkSuccess then corelog.Error("role_conservator.PutItemsFromTurtleIntoChest_MetaData: Invalid input") return {success = false} end

    -- determine needed items
    local workingLocation = location:getWorkingLocation(accessDirection)
    if not workingLocation then corelog.Error("role_conservator.PutItemsFromTurtleIntoChest_MetaData: Failed to determine workingLocation") return {} end
    local fuelNeeded = 5 -- task starts at workingLocation, very little (0) movement from there, a few extra to be sure

    -- return metadata
    return {
        startTime   = coreutils.UniversalTime(),
        location    = workingLocation:copy(),
        needTool    = false,
        needTurtle  = true,
        needWorkerId= turtleId,
        fuelNeeded  = fuelNeeded,
        itemsNeeded = {},

        priorityKey = priorityKey,
    }
end

function role_conservator.PutItemsFromTurtleIntoChest_Task(...)
    -- get & check input from description
    local checkSuccess, turtleId, itemsQuery, location, accessDirection = InputChecker.Check([[
        This Task function puts items from a the inventory of a Turtle into a Chest.

        Return value:
                                - (table)
                success         - (boolean) whether the items were successfully put
                inventory       - (Inventory) the Inventory of the Chest (after the items have been put)

        Parameters:
            taskData            - (table) data about the task
                turtleId        + (number) id of the turtle that has the items
                itemsQuery      + (table) which items to be put
                location        + (Location) location of the Chest
                accessDirection + (string) whether to access Chest from "bottom", "top", "left", "right", "front" or "back" (relative to location)
    --]], ...)
    if not checkSuccess then corelog.Error("role_conservator.PutItemsFromTurtleIntoChest_Task: Invalid input") return {success = false} end

    -- check correct turtle
    local currentTurtleId = os.getComputerID()
    if currentTurtleId ~= turtleId then corelog.Error("role_conservator.PutItemsFromTurtleIntoChest_Task: incorrect turtle(id="..currentTurtleId..") to execute specific turtle(id="..turtleId..")") return {success = false} end

    -- move to workingLocation
    local workingLocation = location:getWorkingLocation(accessDirection)
    if type(workingLocation) ~= "table" then corelog.Error("role_conservator.PutItemsFromTurtleIntoChest_Task: Failed to determine workingLocation") return {success = false} end
--    corelog.WriteToLog("  moving to workingLocation="..textutils.serialize(workingLocation))
    coremove.GoTo(workingLocation)

    -- get access to Chest
    local chestName = Location.ConvertAccessDirectionToPeripheralName(accessDirection)
    local chest = peripheral.wrap(chestName)
    if type(chest) ~= "table" then corelog.Error("role_conservator.PutItemsFromTurtleIntoChest_Task: No Chest at "..textutils.serialize(location).." accessible from "..accessDirection..".") return {success = false} end

    -- loop on requested items
    for requestItemName, requestItemCount in pairs(itemsQuery) do
        -- check
        if type(requestItemName) ~= "string" then corelog.Error("role_conservator.PutItemsFromTurtleIntoChest_Task: requestItemName of wrong type = "..type(requestItemName)..".") return {success = false} end
        if type(requestItemCount) ~= "number" then corelog.Error("role_conservator.PutItemsFromTurtleIntoChest_Task: requestItemCount of wrong type = "..type(requestItemCount)..".") return {success = false} end
--        corelog.WriteToLog("   putting "..requestItemCount.." "..requestItemName.."'s from turtle into Chest")

        -- check enough items
        local turtleInventory = coreinventory.GetInventoryDetail()
        if requestItemCount ~=0 and (turtleInventory.items[requestItemName] or 0) < requestItemCount then corelog.Error("role_conservator.PutItemsFromTurtleIntoChest_Task: not enough (="..requestItemCount..") "..requestItemName.." items available (="..(turtleInventory.items[requestItemName] or "nil")..") in inventory of turtle.") return {success = false} end

        -- drop the items into Chest
        -- ToDo: handling (not enough) space in Chest
        local remainingItemsToDrop = requestItemCount
        for slot, turtleItem in pairs(turtleInventory.slots) do
            -- check
            if type(turtleItem) ~= "table" then corelog.Error("role_conservator.FetchItemsFromChestIntoTurtle_Task: turtleItem of wrong type = "..type(turtleItem)..".") return {success = false} end

            -- requested item in turtle slot?
            if turtleItem.itemName == requestItemName then
                -- select turtle slot
                turtle.select(slot)

                -- move items to
                local countToDrop = math.min(remainingItemsToDrop, turtleItem.itemCount)
--                corelog.WriteToLog("   dropping "..countToDrop.." "..turtleItem.itemName.." from turtle slot "..slot.." to Chest")
                local itemsDropped = Drop(chestName, countToDrop)

                -- more to move for this requested item?
                remainingItemsToDrop = remainingItemsToDrop - itemsDropped
                if remainingItemsToDrop <= 0 then break end
            end
        end
    end

    -- get final inventory
    local slots = chest.list()
    -- ToDo: consider double checking only exactly the requested items were put into the Chest
    local inventory = Inventory:newInstance(slots)

    -- end
    local result = {
        success         = true,
        inventory       = inventory,
    }
    return result
end

function role_conservator.CheckOutputChest(...)
    -- get & check input from description
    local checkSuccess, outputLocator = InputChecker.Check([[
        This function does the magic Guido made to check an output Chest.

        Return value:

        Parameters:
            outputLocator               + (ObjLocator) locating output Chest
    ]], ...)
    if not checkSuccess then corelog.Error("role_conservator.CheckOutputChest: Invalid input") return {success = false} end

    -- set timer for input box (15 sec)
    local chestName = "right"
    local outputChest = peripheral.wrap(chestName)
    if type(outputChest) ~= "table" then corelog.Error("role_conservator.CheckOutputChest: Failed obtaining outputChest") return {success = false} end
    local itemTable = ItemTable:new({})

    -- find first empty slot from the end
    local firstEmpty    = 27
    while firstEmpty > 0 do
        -- we are done if this slot is empty
        if outputChest.getItemDetail(firstEmpty) == nil then break end

        -- check another
        firstEmpty = firstEmpty - 1
    end

    -- any new items?
    local numberOfNewItems  = 0
    while numberOfNewItems < 27 do
        -- get the details of this slot
        local itemDetail = outputChest.getItemDetail(numberOfNewItems + 1)

        -- is the slot filled?
        if type(itemDetail) == "nil" then break end

        -- add items to the order
        itemTable:add(itemDetail.name, itemDetail.count)

        -- move the item to the end
        outputChest.pushItems(chestName, numberOfNewItems + 1, itemDetail.count, firstEmpty)

        -- update
        firstEmpty          = firstEmpty - 1
        numberOfNewItems    = numberOfNewItems + 1
    end

    -- did we find anything
    if itemTable and not itemTable:isEmpty() then
        -- add the items to the locator
        local outputItemsLocator = outputLocator:copy()
        outputItemsLocator:setQuery(itemTable)

        -- store the items in the default dump site
        enterprise_dump = enterprise_dump or require "enterprise_dump"
        local dumpLocator = enterprise_dump.GetDumpLocator()
        local dumpObject  = ObjHost.GetObj(dumpLocator)

        -- ask the dump to store our items
        if dumpObject == nil then return end
        dumpObject:storeItemsFrom_AOSrv({itemsLocator = outputItemsLocator}, Callback.GetNewDummyCallBack())
    end
end

return role_conservator
