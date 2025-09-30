local t_alchemist = {}

local coreutils = require "coreutils"
local corelog = require "corelog"

local Location = require "obj_location"
local ItemTable = require "obj_item_table"

local role_alchemist = require "role_alchemist"

local t_employment

function t_alchemist.T_All()
    -- role_alchemist
end

function t_alchemist.T_AllPhysical()
    -- role_alchemist
    t_alchemist.T_Craft_Task()
    t_alchemist.T_Smelt_Task()
    t_alchemist.T_Pickup_Task()
end

local baseLocationV1 = Location:newInstance(12, 0, 1, 0, 1)

local logOk = false

local compact = { compact = true }

function t_alchemist.T_Craft_Task()
    -- prepare test
    corelog.WriteToLog("* role_alchemist.Craft_Task() tests")
    t_employment = t_employment or require "test.t_employment"
    local workerLocator = t_employment.GetCurrentTurtleLocator() assert(type(workerLocator) == "table", "Failed obtaining workerLocator")
    local provideItems = ItemTable:newInstance({ ["minecraft:birch_planks"] = 4, })
    local craftData = {
        recipe = {
            [6]         = { itemName = "minecraft:birch_log", itemCount = 1 },
           yield        = 4
        },
        provideItems    = provideItems,
        workingLocation = baseLocationV1:getRelativeLocation(3, 3, -4),

        workerLocator   = workerLocator,
    }

    local expectedTurtleOutputItemsLocator = workerLocator:copy()
    expectedTurtleOutputItemsLocator:setQuery(provideItems)
    local expectedTurtleWasteItemsLocator = workerLocator:copy() -- none

    -- test
    local result = role_alchemist.Craft_Task(craftData)

    -- check: result success
    assert(result, "no result returned")
    assert(result.success, "failed executing service")

    -- check: turtleOutputItemsLocator
    local turtleOutputItemsLocator = result.turtleOutputItemsLocator
    assert(turtleOutputItemsLocator:isEqual(expectedTurtleOutputItemsLocator), "gotten turtleOutputItemsLocator(="..textutils.serialize(turtleOutputItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedTurtleOutputItemsLocator, compact)..")")

    -- check: turtleWasteItemsLocator
    local turtleWasteItemsLocator = result.turtleWasteItemsLocator
    assert(turtleWasteItemsLocator:isEqual(expectedTurtleWasteItemsLocator), "gotten turtleOutputItemsLocator(="..textutils.serialize(turtleWasteItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedTurtleWasteItemsLocator, compact)..")")

    -- cleanup test
    if logOk then corelog.WriteToLog(" ok") end
end

function t_alchemist.T_Smelt_Task()
    -- prepare test
    corelog.WriteToLog("* role_alchemist.Smelt_Task() tests")
    t_employment = t_employment or require "test.t_employment"
    local workerLocator = t_employment.GetCurrentTurtleLocator() assert(type(workerLocator) == "table", "Failed obtaining workerLocator")
    local provideItems = ItemTable:newInstance({ ["minecraft:charcoal"] = 3, })
    local smeltData = {
        recipe = {
            itemName    = "minecraft:birch_log",
            yield       = 1
        },
        provideItems    = provideItems,
        workingLocation = baseLocationV1:getRelativeLocation(3, 3, -3),
        fuelItemName    = "minecraft:birch_planks",
        fuelItemCount   = 3,

        workerLocator   = workerLocator,
    }

    -- test
    local result = role_alchemist.Smelt_Task(smeltData)

    -- check: result success
    assert(result, "no result returned")
    assert(result.success, "failed executing service")

    -- check: smeltReadyTime
    local smeltReadyTime = result.smeltReadyTime
    assert(type(smeltReadyTime) == "number", "no smeltReadyTime returned")

    -- wait until smeltReadyTime
    local now = coreutils.UniversalTime()
    local waitSec = smeltReadyTime - now
    if logOk then corelog.WriteToLog(" waiting "..waitSec.." s ...") end
    os.sleep(waitSec*50) -- note: Each 'hour' on the os.time scale is 50 seconds in real-life

    -- cleanup test
    if logOk then corelog.WriteToLog(" ok") end
end

function t_alchemist.T_Pickup_Task()
    -- prepare test
    corelog.WriteToLog("* role_alchemist.Pickup_Task() tests")
    t_employment = t_employment or require "test.t_employment"
    local workerLocator = t_employment.GetCurrentTurtleLocator() assert(type(workerLocator) == "table", "Failed obtaining workerLocator")
    local provideItems = ItemTable:newInstance({ ["minecraft:charcoal"] = 3, })
    local pickupData = {
        provideItems    = provideItems,
        workingLocation = baseLocationV1:getRelativeLocation(3, 3, -3),

        workerLocator   = workerLocator,
    }

    local expectedTurtleOutputItemsLocator = workerLocator:copy()
    expectedTurtleOutputItemsLocator:setQuery(provideItems)
    local expectedTurtleWasteItemsLocator = workerLocator:copy() -- none
    expectedTurtleWasteItemsLocator:setQuery({ ["minecraft:birch_planks"] = 1, })

    -- test
    local result = role_alchemist.Pickup_Task(pickupData)

    -- check: result success
    assert(result, "no result returned")
    assert(result.success, "failed executing service")

    -- check: turtleOutputItemsLocator
    local turtleOutputItemsLocator = result.turtleOutputItemsLocator
    assert(turtleOutputItemsLocator:isEqual(expectedTurtleOutputItemsLocator), "gotten turtleOutputItemsLocator(="..textutils.serialize(turtleOutputItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedTurtleOutputItemsLocator, compact)..")")

    -- check: turtleWasteItemsLocator
    local turtleWasteItemsLocator = result.turtleWasteItemsLocator
    assert(turtleWasteItemsLocator:isEqual(expectedTurtleWasteItemsLocator), "gotten turtleOutputItemsLocator(="..textutils.serialize(turtleWasteItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedTurtleWasteItemsLocator, compact)..")")

    -- cleanup test
    if logOk then corelog.WriteToLog(" ok") end
end

return t_alchemist
