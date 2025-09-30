local t_forester = {}

local corelog = require "corelog"
local coreinventory = require "coreinventory"
local coreutils = require "coreutils"
local coredht = require "coredht"
local coremove = require "coremove"

local Location = require "obj_location"

local role_forester = require "role_forester"

local t_employment

function t_forester.T_All()
    -- role_forester
end

function t_forester.T_AllPhysical()
    -- role_forester
end

local logOk = false

local baseLocation0 = Location:newInstance(0, 0, 1, 0, 1)

local compact = { compact = true }

function t_forester.T_HarvestForest_Task()
    -- prepare test
    corelog.WriteToLog("* role_forester.HarvestForest_Task() tests")
    t_employment = t_employment or require "test.t_employment"
    local workerLocator = t_employment.GetCurrentTurtleLocator() assert(type(workerLocator) == "table", "Failed obtaining workerLocator")
    local firstTreeLocation = baseLocation0:getRelativeLocation(3, 2, 0)
    local taskData = {
        forestLevel       = 2,
        firstTreeLocation = firstTreeLocation,
        nTrees            = 1,
        waitForFirstTree  = true,

        workerLocator   = workerLocator,
    }
    local expectedTurtleOutputLogsLocator = workerLocator:copy()
    local expectedTurtleOutputSaplingsLocator = workerLocator:copy()
    local expectedTurtleWasteLocator = workerLocator:copy()

    -- test
    local result = role_forester.HarvestForest_Task(taskData)

    -- check: result success
    assert(result, "no result returned")
    assert(result.success, "failed executing service")

    -- check: turtleOutputLogsLocator
    local turtleOutputLogsLocator = result.turtleOutputLogsLocator
    assert(turtleOutputLogsLocator:sameBase(expectedTurtleOutputLogsLocator), "gotten turtleOutputLogsLocator(="..textutils.serialize(turtleOutputLogsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedTurtleOutputLogsLocator, compact)..")")

    -- check: turtleOutputSaplingsLocator
    local turtleOutputSaplingsLocator = result.turtleOutputSaplingsLocator
    assert(turtleOutputSaplingsLocator:sameBase(expectedTurtleOutputSaplingsLocator), "gotten turtleOutputSaplingsLocator(="..textutils.serialize(turtleOutputSaplingsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedTurtleOutputSaplingsLocator, compact)..")")

    -- check: turtleWasteItemsLocator
    local turtleWasteItemsLocator = result.turtleWasteItemsLocator
    assert(turtleWasteItemsLocator:sameBase(expectedTurtleWasteLocator), "gotten turtleOutputItemsLocator(="..textutils.serialize(turtleWasteItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedTurtleWasteLocator, compact)..")")

    -- cleanup test
    if logOk then corelog.WriteToLog(" ok") end
end

function t_forester.T_BirchGrow()
    -- zorg dat er een kist onder de turtle staat met een paar saplings. De turtle moet een modem (links) en een diamond axe (rechts of inventory) hebben

    local saplings
    local logs
    local sticks

    local growTime
    local fuelUsage
    local harvestTime

    -- quip the axe / hatchet
    coreinventory.Equip("minecraft:diamond_axe")

    -- remove the ground under us, usefull for crafting later
    --turtle.digDown()

    -- plant the sapling
    turtle.suckDown(1)
    coreinventory.SelectItem("minecraft:birch_sapling")
    turtle.place()

    -- endless
    while true do
        -- sepling just planted, record the time
        growTime = coreutils.UniversalTime()

        -- wait for a tree
        local has_block, data
        while not has_block or type(data) ~= "table" or data.name ~= "minecraft:birch_log" do
            -- ff wachten
            os.sleep(0.25)

            -- opnieuw kijken
            has_block, data = turtle.inspect()
        end

        -- grown!
        growTime = coreutils.UniversalTime() - growTime

        -- move into position (don't count this step as harvesting)
        coremove.Up()
        fuelUsage   = turtle.getFuelLevel()
        harvestTime = coreutils.UniversalTime()

        -- boom omhakken
        role_forester.KapBoom()

        -- klaar met omhakken, wat hebben we geleerd?
        fuelUsage   = fuelUsage                 - turtle.getFuelLevel()
        harvestTime = coreutils.UniversalTime() - harvestTime

        -- terug naar onze plek
        coremove.Backward()
        coremove.Down()

        -- inventory tellen
        saplings    = coreinventory.CountItem("minecraft:birch_sapling") - 1
        logs        = coreinventory.CountItem("minecraft:birch_log")
        sticks      = coreinventory.CountItem("minecraft:stick")

        -- sapling in the Chest
        coreinventory.DropAll("minecraft:birch_sapling", "down")

        -- use as fuel what we can
        for slot=1,16 do turtle.select(slot) turtle.refuel() end

        -- clean inventory
        coreinventory.DropAllItems("down")

        -- save the data
        coredht.SaveData({
            saplings    = saplings,
            logs        = logs,
            sticks      = sticks,
            fuelUsage   = fuelUsage,
            growTime    = growTime,
            harvestTime = harvestTime,
        }, "test", "BirchGrow", coreutils.NewId())

        -- info
        print("Fuel level: "..turtle.getFuelLevel().."units")

        -- get one new sapling
        turtle.suckDown(1)
    end
end

function t_forester.T_BirchGrowToFile()
    -- get the data
    local filename  = '/log/birchgrow.csv'
    local data = coredht.GetData("test", "BirchGrow") if type(data) ~= "table" then corelog.Error("Failed obtaining data") return nil end

    corelog.WriteToLog("data:")
    corelog.WriteToLog(data)

    -- new file
    coreutils.WriteToFile(filename, "saplings;logs;sticks;fuelUsage;growTime;harvestTime", "overwrite")

    -- loop entries
    for k, v in pairs(data) do
        coreutils.WriteToFile(filename, v.saplings..";"..v.logs..";"..v.sticks..";"..v.fuelUsage..";"..string.format("%.3f", v.growTime)..";"..string.format("%.3f", v.harvestTime), "append")
    end
end

return t_forester
