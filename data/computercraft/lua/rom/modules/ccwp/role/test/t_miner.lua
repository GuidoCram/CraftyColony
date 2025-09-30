local t_miner = {}

local corelog = require "corelog"

local Location = require "obj_location"
local ItemTable = require "obj_item_table"

local role_miner = require "role_miner"

local t_employment

function t_miner.T_All()
    -- role_miner
end

function t_miner.T_AllPhysical()
    -- role_miner
end

local logOk = false

local baseLocation_MineShaft0 = Location:newInstance(0, -12, 1, 0, 1):getRelativeLocation(3, 3, 0)
local baseLocation_MineLayer0 = Location:newInstance(0, -12, -36, 0, 1):getRelativeLocation(3, 3, 0)
local startDepth = 0
local maxDepth = 32
local startHalfRib = 3 + 1

local provideItems0 = ItemTable:newInstance({ ["minecraft:cobblestone"] = 9, })

local compact = { compact = true }

function t_miner.T_MineShaft_Task()
    -- prepare test
    corelog.WriteToLog("* role_miner.MineShaft_Task() tests")
    t_employment = t_employment or require "test.t_employment"
    local workerLocator = t_employment.GetCurrentTurtleLocator() assert(type(workerLocator) == "table", "Failed obtaining workerLocator")
    local baseLocation = baseLocation_MineShaft0
    local taskData = {
        baseLocation    = baseLocation:copy(),
        startDepth      = startDepth,
        maxDepth        = maxDepth,
        provideItems    = provideItems0,
        escape          = true,

        workerLocator   = workerLocator,
    }
    local expectedTurtleOutputItemsLocator = workerLocator:copy()
    expectedTurtleOutputItemsLocator:setQuery(provideItems0)
    local expectedTurtleWasteLocator = workerLocator:copy()

    -- test
    local result = role_miner.MineShaft_Task(taskData)

    -- check: result success
    assert(result, "no result returned")
    assert(result.success, "failed executing service")

    -- check: endDepth
    assert(type(result.endDepth) == "number", "no endDepth returned")

    -- check: turtleOutputItemsLocator
    local turtleOutputItemsLocator = result.turtleOutputItemsLocator
    assert(turtleOutputItemsLocator:isEqual(expectedTurtleOutputItemsLocator), "gotten turtleOutputItemsLocator(="..textutils.serialize(turtleOutputItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedTurtleOutputItemsLocator, compact)..")")

    -- check: turtleWasteItemsLocator
    local turtleWasteItemsLocator = result.turtleWasteItemsLocator
    assert(turtleWasteItemsLocator:sameBase(expectedTurtleWasteLocator), "gotten turtleOutputItemsLocator(="..textutils.serialize(turtleWasteItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedTurtleWasteLocator, compact)..")")

    -- cleanup test
    if logOk then corelog.WriteToLog(" ok") end
end

function t_miner.T_MineLayer_Task()
    -- prepare test
    corelog.WriteToLog("* role_miner.MineLayer_Task() tests")
    t_employment = t_employment or require "test.t_employment"
    local workerLocator = t_employment.GetCurrentTurtleLocator() assert(type(workerLocator) == "table", "Failed obtaining workerLocator")
    local baseLocation = baseLocation_MineLayer0
    local taskData = {
        baseLocation    = baseLocation:copy(),
        startHalfRib    = startHalfRib,
        provideItems    = provideItems0,
        escape          = true,

        workerLocator   = workerLocator,
    }
    local expectedTurtleOutputItemsLocator = workerLocator:copy()
    expectedTurtleOutputItemsLocator:setQuery(provideItems0)
    local expectedTurtleWasteLocator = workerLocator:copy()

    -- test
    local result = role_miner.MineLayer_Task(taskData)

    -- check: result success
    assert(result, "no result returned")
    assert(result.success, "failed executing service")

    -- check: endHalfRib
    assert(type(result.endHalfRib) == "number", "no endHalfRib returned")

    -- check: turtleOutputItemsLocator
    local turtleOutputItemsLocator = result.turtleOutputItemsLocator
    assert(turtleOutputItemsLocator:isEqual(expectedTurtleOutputItemsLocator), "gotten turtleOutputItemsLocator(="..textutils.serialize(turtleOutputItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedTurtleOutputItemsLocator, compact)..")")

    -- check: turtleWasteItemsLocator
    local turtleWasteItemsLocator = result.turtleWasteItemsLocator
    assert(turtleWasteItemsLocator:sameBase(expectedTurtleWasteLocator), "gotten turtleOutputItemsLocator(="..textutils.serialize(turtleWasteItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedTurtleWasteLocator, compact)..")")

    -- cleanup test
    if logOk then corelog.WriteToLog(" ok") end
end

return t_miner
