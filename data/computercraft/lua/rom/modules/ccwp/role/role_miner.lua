-- define role
local role_miner = {}

--[[
    This role deals with the mining of items within mining objects (e.g. MineShaft's).
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"
local coremove = require "coremove"
local coreinventory = require "coreinventory"

local InputChecker = require "input_checker"

local ItemTable = require "obj_item_table"

local enterprise_employment

--    _______        _                   __  __      _        _____        _
--   |__   __|      | |          ___    |  \/  |    | |      |  __ \      | |
--      | | __ _ ___| | _____   ( _ )   | \  / | ___| |_ __ _| |  | | __ _| |_ __ _
--      | |/ _` / __| |/ / __|  / _ \/\ | |\/| |/ _ \ __/ _` | |  | |/ _` | __/ _` |
--      | | (_| \__ \   <\__ \ | (_>  < | |  | |  __/ || (_| | |__| | (_| | || (_| |
--      |_|\__,_|___/_|\_\___/  \___/\/ |_|  |_|\___|\__\__,_|_____/ \__,_|\__\__,_|

function role_miner.MineShaft_MetaData(...)
    -- get & check input from description
    local checkSuccess, baseLocation, maxDepth, priorityKey = InputChecker.Check([[
        This function returns the MetaData for MineShaft_Task.

        Return value:
                                        - (table) metadata

        Parameters:
            taskData                    - (table) data about the task
                baseLocation            + (Location) base location of the MineShaft
                startDepth              - (number) with mining starting depth within the MineShaft
                maxDepth                + (number) with maximum depth of the MineShaft

                priorityKey             + (string, "") priorityKey for this assignment
    ]], ...)
    if not checkSuccess then corelog.Error("role_miner.MineShaft_MetaData: Invalid input") return {success = false} end

    return {
        startTime = coreutils.UniversalTime(),
        location = baseLocation:copy(),
        needTool = true,
        needTurtle = true,
        fuelNeeded = maxDepth,
        itemsNeeded = {
        },

        priorityKey = priorityKey,
    }
end

function role_miner.MineShaft_Task(...)
    -- get & check input from description
    local checkSuccess, baseLocation, startDepth, maxDepth, toProvideItems, escape, turtleLocator = InputChecker.Check([[
        This Task function mines a MineShaft for items.

        Return value:
            task result                 - (table)
                success                 - (boolean) whether the task was succesfull
                endDepth                - (number) with mining ending depth within the MineShaft
                turtleOutputItemsLocator- (ObjLocator) locating the provideItems that where gathered (in the turtle)
                turtleWasteItemsLocator - (ObjLocator) locating waste items collected (in the turtle) during gathering

        Parameters:
            taskData                    - (table) data about the task
                baseLocation            + (Location) base location of the MineShaft
                startDepth              + (number) with mining starting depth within the MineShaft
                maxDepth                + (number) with maximum depth of the MineShaft

                provideItems            + (ItemTable) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs) to mine
                escape                  + (boolean) whether Turtle should escape from the MineShaft after it's operation

                workerLocator           + (ObjLocator) locating the Turtle
    ]], ...)
    if not checkSuccess then corelog.Error("role_miner.MineShaft_Task: Invalid input") return {success = false} end

    -- get turtle we are doing task with
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local turtleObj = enterprise_employment:getObj(turtleLocator)
    if not turtleObj then corelog.Error("role_miner.MineShaft_Task: Failed obtaining Turtle "..turtleLocator:getURI()) return {success = false} end

    -- remember input items
    local beginTurtleItems = turtleObj:getInventoryAsItemTable()

    -- equip diamond_pickaxe
    local axePresent = coreinventory.Equip("minecraft:diamond_pickaxe")
    if not axePresent then corelog.Error("role_miner.MineShaft_Task: No axePresent ") return {success = false} end

    -- move to the baseLocation
    coremove.GoTo(baseLocation)

    -- perform entry sequence
    local currentDepth = startDepth
    local minStartDepth = 3
    if currentDepth < minStartDepth then currentDepth = minStartDepth end
    local entrySequence = {
        baseLocation:getRelativeLocation(1, 0, 0),
        baseLocation:getRelativeLocation(1, 0, -currentDepth),
        baseLocation:getRelativeLocation(0, 0, -currentDepth),
    }
    for i, entryLocation in ipairs(entrySequence) do
        coremove.GoTo(entryLocation, true)
    end

    -- dig a hole while depth left and not all provideItems found
    local allProvideItemsFound = false
    local outputItems = ItemTable:newInstance()
    local wasteItems = ItemTable:newInstance()
    while currentDepth < maxDepth and not allProvideItemsFound do
        -- one layer lower
        turtle.digDown()
        coremove.Down()
        currentDepth = currentDepth + 1

        -- go round
        for i=1,4 do turtle.dig() coremove.Right() end

        -- determine output & waste items
        local serviceResults = turtleObj:getOutputAndWasteItemsSince(beginTurtleItems, toProvideItems)
        if not serviceResults or not serviceResults.success then corelog.Error("role_forester.HarvestForest_Task: Failed obtaining output & waste items") return {success = false} end
        outputItems = serviceResults.outputItems
        wasteItems = serviceResults.otherItems

        -- did we already find all?
        local uniqueProvideItems, _commonItems, _uniqueFoundItems = ItemTable.compare(toProvideItems, outputItems)
        if not uniqueProvideItems then corelog.Error("role_miner.MineShaft_Task: Failed obtaining uniqueProvideItems") return {success = false} end
        if uniqueProvideItems:isEmpty() then
            allProvideItemsFound = true
        end
    end

    -- perform exit sequence
    if escape then
        local exitSequence = {
            baseLocation:getRelativeLocation(-1, 0, -currentDepth),
            baseLocation:getRelativeLocation(-1, 0, 0),
            baseLocation:getRelativeLocation(0, 0, 0),
        }
        for i, exitLocation in ipairs(exitSequence) do
            coremove.GoTo(exitLocation, true)
        end
    end

    -- determine output locator
    local turtleOutputItemsLocator = turtleLocator:copy()
    turtleOutputItemsLocator:setQuery(outputItems)

    -- determine waste locator
    local turtleWasteItemsLocator = turtleLocator:copy()
    turtleWasteItemsLocator:setQuery(wasteItems)
    if next(wasteItems) ~= nil then
        corelog.WriteToLog(">mining waste: "..textutils.serialise(wasteItems, {compact = true}))
    end

    -- end
    return {
        success                     = allProvideItemsFound,
        endDepth                    = currentDepth,
        turtleOutputItemsLocator    = turtleOutputItemsLocator,
        turtleWasteItemsLocator     = turtleWasteItemsLocator,
    }
end

function role_miner.MineLayer_MetaData(...)
    -- get & check input from description
    local checkSuccess, baseLocation, startHalfRib, priorityKey = InputChecker.Check([[
        This function returns the MetaData for MineLayer_Task.

        Return value:
                                        - (table) metadata

        Parameters:
            taskData                    - (table) data about the task
                baseLocation            + (Location) base location of the MineLayer
                startHalfRib            + (number) with mining start halfRib within the MineLayer

                priorityKey             + (string, "") priorityKey for this assignment
    ]], ...)
    if not checkSuccess then corelog.Error("role_miner.MineLayer_MetaData: Invalid input") return {success = false} end

    return {
        startTime = coreutils.UniversalTime(),
        location = baseLocation:copy(),
        needTool = true,
        needTurtle = true,
        fuelNeeded = 4*2*startHalfRib + 2*startHalfRib,
        itemsNeeded = {
        },

        priorityKey = priorityKey,
    }
end

function role_miner.MineLayer_Task(...)
    -- get & check input from description
    local checkSuccess, baseLocation, startHalfRib, toProvideItems, escape, turtleLocator = InputChecker.Check([[
        This Task function mines a MineShaft for items.

        Return value:
            task result                 - (table)
                success                 - (boolean) whether the task was succesfull
                endHalfRib              - (number) with mining ending depth within the MineLayer
                turtleOutputItemsLocator- (ObjLocator) locating the provideItems that where gathered (in the turtle)
                turtleWasteItemsLocator - (ObjLocator) locating waste items collected (in the turtle) during gathering

        Parameters:
            taskData                    - (table) data about the task
                baseLocation            + (Location) base location of the MineLayer
                startHalfRib            + (number) with mining start halfRib within the MineLayer

                provideItems            + (ItemTable) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs) to mine
                escape                  + (boolean) whether Turtle should escape from the MineLayer after it's operation

                workerLocator           + (ObjLocator) locating the Turtle
    ]], ...)
    if not checkSuccess then corelog.Error("role_miner.MineLayer_Task: Invalid input") return {success = false} end

    -- get turtle we are doing task with
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local turtleObj = enterprise_employment:getObj(turtleLocator)
    if not turtleObj then corelog.Error("role_miner.MineLayer_Task: Failed obtaining Turtle "..turtleLocator:getURI()) return {success = false} end

    -- remember input items
    local beginTurtleItems = turtleObj:getInventoryAsItemTable()

    -- equip diamond_pickaxe
    local axePresent = coreinventory.Equip("minecraft:diamond_pickaxe")
    if not axePresent then corelog.Error("role_miner.MineLayer_Task: No axePresent ") return {success = false} end

    -- perform entry sequence from main path to ribe start
    local entrySequence = {
        -- entry from main path to MineLayer shaft
        baseLocation:getRelativeLocation(1, 0, 0),
        -- prevent killing torch
        baseLocation:getRelativeLocation(1, 1, 0),
        baseLocation:getRelativeLocation(4, 1, 0),
        baseLocation:getRelativeLocation(4, 0, 0),
    }
    for i, entryLocation in ipairs(entrySequence) do coremove.MoveTo(entryLocation, true) end

    -- go to rib start position + direction
    coremove.GoTo(baseLocation:getRelativeLocation(startHalfRib, 0, 0), true)

    -- loop het vierkantje
    for iRand=1,4 do
        -- loop de 2e helft van de 1e rand
        for i=1,startHalfRib do
            coremove.Forward(1, true)
            turtle.digUp()
            turtle.digDown()
        end

        -- linksom
        coremove.Left()

        -- loop de 1e helft van de 2e rand
        for i=1,startHalfRib do
            coremove.Forward(1, true)
            turtle.digUp()
            turtle.digDown()
        end
    end

    -- determine output & waste items
    local serviceResults = turtleObj:getOutputAndWasteItemsSince(beginTurtleItems, toProvideItems)
    if not serviceResults or not serviceResults.success then corelog.Error("role_forester.HarvestForest_Task: Failed obtaining output & waste items") return {success = false} end
    local outputItems = serviceResults.outputItems
    local wasteItems = serviceResults.otherItems

    -- did we already find all?
    local uniqueProvideItems, _commonItems, _uniqueFoundItems = ItemTable.compare(toProvideItems, outputItems)
    if not uniqueProvideItems then corelog.Error("role_miner.MineLayer_Task: Failed obtaining uniqueProvideItems") return {success = false} end

    -- perform exit sequence
    local exitSequence = {
        -- prevent killing torch
        baseLocation:getRelativeLocation(startHalfRib, 1, 0),
        baseLocation:getRelativeLocation(0, 1, 0),
        -- to the base
        baseLocation,
        -- on my way out
        baseLocation:getRelativeLocation(-1, 0, 0),
    }
    for i, exitLocation in ipairs(exitSequence) do
        coremove.MoveTo(exitLocation, true)
    end

    -- determine output locator
    local turtleOutputItemsLocator = turtleLocator:copy()
    turtleOutputItemsLocator:setQuery(outputItems)

    -- determine waste locator
    local turtleWasteItemsLocator = turtleLocator:copy()
    turtleWasteItemsLocator:setQuery(wasteItems)
    if next(wasteItems) ~= nil then
        corelog.WriteToLog(">mining waste: "..textutils.serialise(wasteItems, {compact = true}))
    end

    -- end
    return {
        success                     = true,
        endHalfRib                  = startHalfRib,
        turtleOutputItemsLocator    = turtleOutputItemsLocator,
        turtleWasteItemsLocator     = turtleWasteItemsLocator,
    }
end

return role_miner
