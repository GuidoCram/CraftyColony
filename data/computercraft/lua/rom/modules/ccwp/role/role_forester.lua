-- define role
local role_forester = {}

-- ToDo: add proper module description
--[[
    This role ...
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

function FuelNeededPerTree()
    return 35 + 1
end

function role_forester.FuelNeededPerRound(nTrees)
    local fuelNeededBetweenTrees = 6 -- to move from one to the next tree
    local fuelNeededPerColumn = (nTrees - 1) * fuelNeededBetweenTrees
    local fuelNeededBetweenRows = math.floor(nTrees/ 6) * fuelNeededBetweenTrees

    return nTrees*FuelNeededPerTree() + 2 * fuelNeededPerColumn + 2 * fuelNeededBetweenRows -- ToDo: make more accurate once we have a better forest implementation
end

function role_forester.HarvestForest_MetaData(...)
    -- get & check input from description
    local checkSuccess, forestLevel, firstTreeLocation, nTrees, priorityKey = InputChecker.Check([[
        This function returns the MetaData for HarvestForest_Task.

        Return value:
                                            - (table) metadata

        Parameters:
            taskData                        - (table) data about the task
                forestLevel                 + (number) forest level
                firstTreeLocation           + (table) location of first tree of the forest
                nTrees                      + (number) the number of trees in (the y direction of) the forest
                waitForFirstTree            - (boolean) if harvesting should wait for the first tree
                priorityKey                 + (string, "") priorityKey for this assignment
    ]], ...)
    if not checkSuccess then corelog.Error("role_forester.HarvestForest_MetaData: Invalid input") return {success = false} end

    -- determine fuelNeed
    local fuelNeed = 0
    if forestLevel > -1 then
        fuelNeed = role_forester.FuelNeededPerRound(nTrees)
    end

    -- determine itemsNeeded
    local itemsNeeded = {
        ["minecraft:crafting_table"] = 1,
        -- ToDo: figure out why is this need actually there (it is a remnent of old times that can be removed, or is it really needed? check also starting with a fresh and empty Turtle)
    }

    -- end
    return {
        startTime   = coreutils.UniversalTime(),
        location    = firstTreeLocation:copy(),
        needTool    = true,
        needTurtle  = true,
        fuelNeeded  = fuelNeed,
        itemsNeeded = itemsNeeded,

        priorityKey = priorityKey,
    }
end

function role_forester.HarvestForest_Task(...)
    -- get & check input from description
    local checkSuccess, forestLevel, firstTreeLocation, nTrees, waitForFirstTree, turtleLocator = InputChecker.Check([[
        This Task function harvests a forest.

        Return value:
            task result                     - (table)
                success                     - (boolean) whether the task was succesfull
                turtleOutputLogsLocator     - (ObjLocator) locating the logs that where harvested (in the turtle)
                turtleOutputSaplingsLocator - (ObjLocator) locating the saplings that where harvested (in the turtle)
                turtleWasteItemsLocator     - (ObjLocator) locating waste items collected (in the turtle) during harvesting

        Parameters:
            taskData                        - (table) data about the task
                forestLevel                 + (number) forest level
                firstTreeLocation           + (table) location of first tree of the forest
                nTrees                      + (number) the number of trees in (the y direction of) the forest
                waitForFirstTree            + (boolean) if harvesting should wait for the first tree
                workerLocator               + (ObjLocator) locating the Turtle
    ]], ...)
    if not checkSuccess then corelog.Error("role_forester.HarvestForest_Task: Invalid input") return {success = false} end

    -- what are we searching for?
    local logName = "minecraft:birch_log"
    local saplingName = "minecraft:birch_sapling"
    local searchItems = ItemTable:newInstance({ [logName] = ItemTable.LargeItemCount(), [saplingName] = ItemTable.LargeItemCount()})

    -- get turtle we are doing task with
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local turtleObj = enterprise_employment:getObj(turtleLocator)
    if not turtleObj then corelog.Error("role_forester.HarvestForest_Task: Failed obtaining Turtle "..turtleLocator:getURI()) return {success = false} end

    -- equip diamond_pickaxe
    -- note this statement should be before remember input items, otherwise possible other equiped tools will be considered waste!
    local axePresent = coreinventory.Equip("minecraft:diamond_pickaxe")
    if not axePresent then corelog.Error("role_forester.HarvestForest_Task: No axePresent ") return {success = false} end

    -- remember input items
    local beginTurtleItems = turtleObj:getInventoryAsItemTable()

    -- go to first tree position
    coremove.GoTo(firstTreeLocation)

    -- check for L0 case with very little fuel
    local fuelLevel = turtle.getFuelLevel()
    if forestLevel == -1 and fuelLevel < FuelNeededPerTree() then
        -- wait and chop first log
        WaitAndChopFirstLog()
    else
        -- optionally wait for tree
        if waitForFirstTree and forestLevel > -1 then
            WaitForTree()
        end

        -- harvest forest
        local dontCleanup = true
        Rondje({
            depth       = nTrees, -- ToDo: modify to spread nTrees over depth and width
            width       = 1,
            dontCleanup = dontCleanup,
        })
    end

    -- determine output & waste items
    local serviceResults = turtleObj:getOutputAndWasteItemsSince(beginTurtleItems, searchItems)
    if not serviceResults or not serviceResults.success then corelog.Error("role_forester.HarvestForest_Task: Failed obtaining output & waste items") return {success = false} end

    -- determine output locators
    local outputItems = serviceResults.outputItems
    local turtleOutputLogsLocator = turtleLocator:copy()
    turtleOutputLogsLocator:setQuery({ [logName] = outputItems[logName] })
    local turtleOutputSaplingsLocator = turtleLocator:copy()
    turtleOutputSaplingsLocator:setQuery({ [saplingName] = outputItems[saplingName] })

    -- determine waste locator
    local wasteItems = serviceResults.otherItems
    local turtleWasteItemsLocator = turtleLocator:copy()
    turtleWasteItemsLocator:setQuery(wasteItems)
    if next(wasteItems) ~= nil then
        corelog.WriteToLog(">harvesting waste: "..textutils.serialise(wasteItems, {compact = true}))
    end

    -- end
    return {
        success                     = true,
        turtleOutputLogsLocator     = turtleOutputLogsLocator,
        turtleOutputSaplingsLocator = turtleOutputSaplingsLocator,
        turtleWasteItemsLocator     = turtleWasteItemsLocator,
    }
end

--    _                 _    __                  _   _
--   | |               | |  / _|                | | (_)
--   | | ___   ___ __ _| | | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | |/ _ \ / __/ _` | | |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | (_) | (_| (_| | | | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_|\___/ \___\__,_|_| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/

function WaitAndChopFirstLog()
    -- equip pickage
    coreinventory.Equip("minecraft:diamond_pickaxe")

    -- wait for a tree
    corelog.WriteToLog(">Waiting for first tree")
    WaitForTree()

    -- blok voor ons omhakken
    corelog.WriteToLog(">Chopping one block of first tree")
    turtle.dig()
end

function WaitForTree()
    local has_block, data = turtle.inspect()

    while not has_block or type(data) ~= "table" or data.name ~= "minecraft:birch_log" do
        -- ff wachten
        os.sleep(0.25)

        -- opnieuw kijken
        has_block, data = turtle.inspect()
    end
end

function Rondje(funcData)
    -- debug
    corelog.WriteToLog(">Forester.Rondje()")

    -- init
    local depth = funcData.depth
    local width = funcData.width
    local dontCleanup = funcData.dontCleanup
--    print ("Rondje with: depth=" .. depth .. ", width=" .. width .. ", dontCleanup=" .. tostring(dontCleanup))

    -- eerst in positie komen (in de stam van de eerste boom)
    coremove.Up()
    Vooruit(1)

    -- naar de tweede boomn lopen, start positie van de lussen
    if depth > 1 then Vooruit(6) end

    -- banen langs lopen
    local aantalBanen = math.ceil(width / 2)
    local lastBaanHalf = (width % 2 == 1)
    for i=1, aantalBanen do
        -- determine last baan
        local lastBaan = (i == aantalBanen)

        -- move to "top right" baan
        Vooruit(6 * (depth - 2))

        -- move to "top left" baan
        coremove.Left()
        if not lastBaan or not lastBaanHalf then
            Vooruit(6)
        end

        -- move to "bottom left" baan
        coremove.Left()
        Vooruit(6 * (depth - 2))

        -- (optionally) move and turn to start ("bottom right") next baan
        if not lastBaan then
            coremove.Right()
            Vooruit(6)
            coremove.Right()
        end
    end

    -- terug naar huis, kan wat speciale dingen met zich mee brengen
    if depth    > 1 then Vooruit(6)         end

    -- over de volledige breedte terug naar
    coremove.Left()
    Vooruit(6 * (width - 1))

    -- terug in positie
    coremove.Left()
    coremove.Backward()
    coremove.Down()

    -- spullen opruimen
    if not dontCleanup then
        Opruimen()
    end
end

function Vooruit(aantal)
    aantal = aantal or 1

    -- het gewenste aantal stappen zetten
    for stap = 1, aantal do

        -- staat er een boom recht voor ons?
        if DetecteedBoom() then

            -- ja, omhakken dus (doet meteen een stap naar voren)
            KapBoom()
        else

            -- niks te zien, gewoon vooruit
            coremove.Forward()
        end
    end
end
--[[
function role_forester.TestMoveCallback()
    coremove.Forward(6*5 + 1, true, KapBoomCallback)
    coremove.GoTo({x = 3, y = 0, z = 0, dx = 0, dy = 1}, true, KapBoomCallback)
    coremove.GoTo({x = 0, y = 0, z = 0, dx = 0, dy = 1}, true, KapBoomCallback)
end
]]
-- te gebruiken voor de callback functie van coremove
function KapBoomCallback()
    -- staat er een boom recht voor ons? Dan omhakken!
    if DetecteedBoom() then return KapBoom() end
end

function DetecteedBoom()
    local success, data = turtle.inspect()

    -- staat er een berkenboom voor onze neus?
    return success and type(data) == "table" and data.name == "minecraft:birch_log"
end

function KapBoom() -- kost ongeveer 37 movement (inclusief buiten bladeren) - 1 blok hout levert ~ 70 movement op
    local schaarste = true
    local hoogte    = 1

    -- eerste stukkie stam weghalen en op de plek van de stam gaan staan
    turtle.dig()
    coremove.Forward(1)
    turtle.digDown()

    -- omhoog gaan totdat we bladeren zien
    while not turtle.inspect() do
        -- omhoog
        turtle.digUp()
        coremove.Up()

        -- bijhouden
        hoogte = hoogte + 1
    end

    -- eentje boven de eerste bladen staan
    turtle.digUp()
    coremove.Up()

    -- al het hout is weg (op het top blok na), nu de bladeren
    OogstBladerenVolledig()
    -- if schaarste then OogstBladerenBuitenkant(true) end
    -- OogstBladerenBuitenkant(false)

    -- terug (top blok nog ff hakken)
    turtle.digUp()

    -- do we need the crown too?
    if coreinventory.CountItem("minecraft:birch_sapling") < 2 then ChopCrown() end

    -- back to where we started
    coremove.Down(hoogte)

    -- staat er een berkenboom sapling voor onze neus?
    local success, data = turtle.inspectDown()
    if not success or type(data) ~= "table" or data.name ~= "minecraft:birch_sapling" then

        -- als er een blok staat, weghalen
        if success then turtle.digDown() end

        -- hebben we nu een sapling?
        if coreinventory.SelectItem("minecraft:birch_sapling")  then turtle.placeDown()
                                                                else corelog.Error("No birch sapling to plant") end
    end

    -- there is no other way then succes, way of being
    return true
end

function OogstBladerenVolledig()
-- 561→2
-- ↑↓↑9↓
-- ↑↓0↑↓
-- ↑7→8↓
-- 4←←←3

    OogstBladerenForward(true)
    OogstBladerenForward(false)
    coremove.Right()            -- 1
    OogstBladerenForward(false)
    OogstBladerenForward(false)
    coremove.Right()            -- 2
    OogstBladerenForward(false)
    OogstBladerenForward(false)
    OogstBladerenForward(false)
    OogstBladerenForward(false)
    coremove.Right()            -- 3
    OogstBladerenForward(false)
    OogstBladerenForward(false)
    OogstBladerenForward(false)
    OogstBladerenForward(false)
    coremove.Right()            -- 4
    OogstBladerenForward(false)
    OogstBladerenForward(false)
    OogstBladerenForward(false)
    OogstBladerenForward(false)
    coremove.Right()            -- 5
    OogstBladerenForward(false)
    coremove.Right()            -- 6
    OogstBladerenForward(true)
    OogstBladerenForward(true)
    OogstBladerenForward(true)
    coremove.Left()             -- 7
    OogstBladerenForward(true)
    OogstBladerenForward(true)
    coremove.Left()             -- 8
    OogstBladerenForward(true)
    OogstBladerenForward(true)
    coremove.Left()             -- 9
    coremove.Forward()
    coremove.Right()
    coremove.Backward()         -- returg op 0
end

function OogstBladerenForward(ookBoven)
    turtle.dig()
    coremove.Forward()
    if ookBoven then turtle.digUp() end
    turtle.digDown()
end

function OogstBladerenBuitenkant(buitenKant)
    -- in positie komen, twee vooruit en draaien
    if buitenKant then turtle.dig() coremove.Forward() end
    turtle.dig()
    coremove.Forward()
    coremove.Right()

    -- 4x een hoek nemen
    for i=1,4 do
        -- twee stappen naar de hoek
        if buitenKant then OogstBladerenStap(not buitenKant) end
        OogstBladerenStap(not buitenKant)

        -- draaien
        coremove.Right()

        -- twee stappen naar het midden
        if buitenKant then OogstBladerenStap(not buitenKant) end
        OogstBladerenStap(not buitenKant)
    end

    -- terug lopen
    coremove.Left()
    if buitenKant then coremove.Backward() end
    coremove.Backward()
end

function OogstBladerenStap(ookBoven)
    turtle.digDown()
    if ookBoven then turtle.digUp() end
    turtle.dig()
    coremove.Forward()
end

function ChopCrown()
    -- get to the crown
    for i=1,2 do coremove.Up() turtle.digUp() end

    -- dig around
    for i=1,4 do turtle.dig() coremove.Right() end

    -- back into position
    for i=1,2 do coremove.Down() end
end

function Opruimen()
    coremove.Backward()
    coremove.Left()
    coreinventory.DropAll("minecraft:birch_sapling")
    coreinventory.GetEmptySlot()
    turtle.suck(64)
    coremove.Left()
    coremove.Left()
    coreinventory.DropAll("minecraft:stick")
    coremove.Left()
    coremove.Forward()
    coremove.Right()
    coremove.Forward()
    coreinventory.DropAll("minecraft:birch_log")
    coremove.Backward()
    coremove.Left()
end

return role_forester
