-- define module
local enterprise_energy = {}

--[[
    The enterprise_energy offers services for handling energy (fuel).
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"
local coredht = require "coredht"

local role_energizer = require "role_energizer"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local ObjHost = require "obj_host"

local enterprise_projects = require "enterprise_projects"

local db = {
    dhtRoot         = "enterprise_energy",
    dhtParameters   = "fuelParameters",
}

--                _     _ _         __                  _   _
--               | |   | (_)       / _|                | | (_)
--    _ __  _   _| |__ | |_  ___  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | '_ \| | | | '_ \| | |/ __| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | |_) | |_| | |_) | | | (__  | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   | .__/ \__,_|_.__/|_|_|\___| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--   | |
--   |_|

local function FuelItemsForFuel(fuel)
    -- get parameters
    local parameters = enterprise_energy.GetParameters()

    -- determine fuelItems
    local fuelItemGain = parameters.fuelItemGain
    local fuelItemCount = math.ceil(fuel / fuelItemGain)
    local fuelItemName = parameters.fuelItemName
    local fuelItems = { [fuelItemName] = fuelItemCount }

    -- end
--    corelog.WriteToLog("   fuelItems="..textutils.serialise(fuelItems)..")")
    return fuelItems
end

local function Refuel_ASrv(...)
    -- get & check input from description
    local checkSuccess, turtleLocator, fuelItems, ingredientsItemSupplierLocator, wasteItemDepotLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
        This public async service (re)fuels a turtle from fuelItems.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table) data about this service
                turtleLocator                   + (ObjLocator) locator of the turtle
                fuelItems                       + (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs) to fuel with
                ingredientsItemSupplierLocator  + (ObjLocator) locating where ingredients can be retrieved
                wasteItemDepotLocator           + (ObjLocator) locating where waste material can be delivered
                assignmentsPriorityKey          + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                            + (Callback) to call once service is ready
    --]], ...)
    if not checkSuccess then corelog.Error("enterprise_energy.Refuel_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- create project service data
    local turtleObj = ObjHost.GetObj(turtleLocator) if not turtleObj then corelog.Error("enterprise_energy.Refuel_ASrv: Failed obtaining turtle "..turtleLocator:getURI()) return Callback.ErrorCall(callback) end
    local workerId = turtleObj:getWorkerId()
    local refuelTaskData = {
        -- ToDo: consider passing turtleLocator
        turtleId    = workerId,
        fuelItems   = coreutils.DeepCopy(fuelItems),

        priorityKey = assignmentsPriorityKey,
    }
    local buildBlueprintProjectDef = {
        steps   = {
            -- get fuel
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "provideItemsTo_AOSrv", locatorStep = 0, locatorKeyDef = "ingredientsItemSupplierLocator" }, stepDataDef = {
                { keyDef = "provideItems"                   , sourceStep = 0, sourceKeyDef = "fuelItems" },
                { keyDef = "itemDepotLocator"               , sourceStep = 0, sourceKeyDef = "turtleLocator" },
                { keyDef = "ingredientsItemSupplierLocator" , sourceStep = 0, sourceKeyDef = "ingredientsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
                { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }, description = "Getting fuel for Turtle "..workerId},
            -- refuel turtle
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"                       , sourceStep = 0, sourceKeyDef = "refuelMetaData" },
                { keyDef = "taskCall"                       , sourceStep = 0, sourceKeyDef = "refuelTaskCall" },
            }, description = "Refuelling Turtle "..workerId},
        },
        returnData  = {
        }
    }
    local projectData = {
        fuelItems                       = coreutils.DeepCopy(fuelItems),

        turtleLocator                   = turtleLocator,
        ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
        wasteItemDepotLocator           = wasteItemDepotLocator,

        refuelMetaData                  = role_energizer.Refuel_MetaData(refuelTaskData),
        refuelTaskCall                  = TaskCall:newInstance("role_energizer", "Refuel_Task", refuelTaskData),

        assignmentsPriorityKey          = assignmentsPriorityKey,
    }
    local projectServiceData = {
        projectDef  = buildBlueprintProjectDef,
        projectData = projectData,
        projectMeta = { title = "Turtle "..workerId.." needs more fuel. Helping out...", description = "We help it refuel with "..textutils.serialise(fuelItems, {compact = true}).."" },
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function enterprise_energy.ProvideFuelTo_ASrv(...)
    -- get & check input from description
    local checkSuccess, turtleLocator, fuelAmount, ingredientsItemSupplierLocator, wasteItemDepotLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
        This public async service provides fuel to a turtle.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table) data about this service
                turtleLocator                   + (ObjLocator) locator of the turtle
                fuelAmount                      + (number) fuel amount to provide to turtle
                ingredientsItemSupplierLocator  + (ObjLocator) locating where the fuel ingredients can be retrieved
                wasteItemDepotLocator           + (ObjLocator) locating where waste material can be delivered
                assignmentsPriorityKey          + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                            + (Callback) to call once service is ready
    --]], ...)
    if not checkSuccess then corelog.Error("enterprise_energy.ProvideFuelTo_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- check there is actually fuel requested
    if fuelAmount == 0 then corelog.Warning("enterprise_energy.ProvideFuelTo_ASrv: Requesting 0 fuel for Turtle"..turtleLocator:getURI().." => skip") return callback:call({success = true}) end

    -- determine fuelItemsNeed
    local fuelItemsNeed = FuelItemsForFuel(fuelAmount)

    -- (re)fuel turtle
    local refuelServiceData = {
        turtleLocator                   = turtleLocator,
        fuelItems                       = fuelItemsNeed,
        ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
        wasteItemDepotLocator           = wasteItemDepotLocator,
        assignmentsPriorityKey          = assignmentsPriorityKey,
    }
    corelog.WriteToLog("* Refuelling Turtle "..turtleLocator:getURI().." with "..fuelAmount.." fuel *")
    return Refuel_ASrv(refuelServiceData, callback)
end

function enterprise_energy.GetFuelNeed_Refuel_Att()
    --[[
        enterprise_energy attribute with the current fuelNeed for refueling.
    --]]

    -- get parameters
    local parameters = enterprise_energy.GetParameters()

    -- determine fuelNeed
    local fuelNeed = 0
    local enterpriseLevel = parameters.enterpriseLevel
    if enterpriseLevel > 0 then
        -- get BirchForest
        local forestLocator = parameters.forestLocator
        local forest = nil
        local enterprise_forestry = require "enterprise_forestry"
        forest = enterprise_forestry:getObj(forestLocator)
        if type(forest) ~= "table" then corelog.Warning("enterprise_energy.GetFuelNeed_Refuel_Att: forest "..forestLocator:getURI().." not found") return enterprise_energy.GetLargeFuelAmount_Att() end

        -- determine fuelNeed by BirchForest
        local fuelNeed_Harvest = forest:getFuelNeed_Harvest_Att()

        -- determine fuelNeed for 1 extra tree (to anticipate for fuelNeed in case the forest gets upgraded)
        local fuelNeed_ExtraTree = 0
        if enterpriseLevel > 1 then
            fuelNeed_ExtraTree = forest:getFuelNeedExtraTree_Att()
        end

        -- get Factory
        local factoryLocator = parameters.factoryLocator
        local factory = nil
        local enterprise_manufacturing = require "enterprise_manufacturing"
        factory = enterprise_manufacturing:getObj(factoryLocator)
        if type(factory) ~= "table" then corelog.Warning("enterprise_energy.GetFuelNeed_Refuel_Att: factory "..factoryLocator:getURI().." not found") return enterprise_energy.GetLargeFuelAmount_Att() end

        -- determine fuelNeed by Factory
        local items = FuelItemsForFuel(1)
        local fuelNeed_Production = factory:getFuelNeed_Production_Att(items)

        -- determine fuelNeed for traveling between BirchForest and Factory
        local forestLocation = forest:getBaseLocation()
        local factoryLocation = factory:getBaseLocation()
        local fuelNeed_ForestFactoryTravel = role_energizer.NeededFuelToFrom(factoryLocation, forestLocation)

        -- add fuelNeed
        -- corelog.WriteToLog("E  fuelNeed_Harvest="..fuelNeed_Harvest..", fuelNeed_ExtraTree="..fuelNeed_ExtraTree..", fuelNeed_Production="..fuelNeed_Production..", fuelNeed_ForestFactoryTravel="..fuelNeed_ForestFactoryTravel)
        fuelNeed = fuelNeed + fuelNeed_Harvest + fuelNeed_ExtraTree + fuelNeed_Production + fuelNeed_ForestFactoryTravel
    end

    -- end
    return fuelNeed
end

function enterprise_energy.GetRefuelAmount_Att()
    --[[
        enterprise_energy attribute with the current refuel amount.
    --]]

    -- get parameters
    local parameters = enterprise_energy.GetParameters()
    local enterpriseLevel = parameters.enterpriseLevel
    if enterpriseLevel == 0 then
        return 0
    elseif enterpriseLevel == 1 then
        return 60 -- 1 log = 4 planks = 60 fuel
    elseif enterpriseLevel == 2 then
        return 300 -- 1 tree = min 5 logs = 20 planks = 300 fuel
    elseif enterpriseLevel == 3 then
        return 1800 -- 6 tree = min 30 logs = 120 planks = 1800 fuel
    else
        corelog.Warning("enterprise_energy.GetRefuelAmount_Att: not (yet) implemented for enterpriseLevel="..enterpriseLevel)
        return enterprise_energy.GetLargeFuelAmount_Att()
    end
end

function enterprise_energy.GetLargeFuelAmount_Att()
    return 999999
end

function enterprise_energy.GetParameters()
    -- get parameters
    local parameters = coredht.GetData(db.dhtRoot, db.dhtParameters)
    if not parameters then parameters = enterprise_energy.ResetParameters() end

    return parameters
end

--    _                 _    __                  _   _
--   | |               | |  / _|                | | (_)
--   | | ___   ___ __ _| | | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | |/ _ \ / __/ _` | | |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | (_) | (_| (_| | | | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_|\___/ \___\__,_|_| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/

function enterprise_energy.ResetParameters()
--    corelog.WriteToLog("enterprise_energy: resetting parameters")
    return coredht.SaveData({
        enterpriseLevel             = 0,

        forestLocator               = nil,
        factoryLocator              = nil,

        fuelItemName                = "minecraft:birch_planks",
        fuelItemGain                = 15,
    }, db.dhtRoot, db.dhtParameters)
end

function enterprise_energy.UpdateEnterprise_SSrv(...)
    -- get & check input from description
    local checkSuccess, enterpriseLevel, forestLocator, factoryLocator = InputChecker.Check([[
        This private sync service updates the enterprise information.

        Return value:
                                        - (table)
                success                 - (boolean) whether the service executed successfully

        Parameters:
            serviceData                 - (table) data about the service
                enterpriseLevel         + (number) with enterprise level
                forestLocator           + (ObjLocator, nil) locating the BirchForest intended for raw fuel materials
                factoryLocator          + (ObjLocator, nil) locating the Factory intended for producing fuel items
    --]], ...)
    if not checkSuccess then corelog.Error("enterprise_energy.UpdateEnterprise_SSrv: Invalid input") return {success = false} end

    -- check forestLocator
    if enterpriseLevel > 0 and not forestLocator then corelog.Error("enterprise_energy.UpdateEnterprise_SSrv: Invalid forestLocator(=nil) for enterpriseLevel="..enterpriseLevel) return {success = false} end

    -- check factoryLocator
    if enterpriseLevel > 0 and not factoryLocator then corelog.Error("enterprise_energy.UpdateEnterprise_SSrv: Invalid factoryLocator(=nil) for enterpriseLevel="..enterpriseLevel) return {success = false} end

    -- get parameters
    local parameters = enterprise_energy.GetParameters()

    -- set enterprise information
    parameters.enterpriseLevel = enterpriseLevel
    parameters.forestLocator = forestLocator
    parameters.factoryLocator = factoryLocator

    -- save parameters
    coredht.SaveData(parameters, db.dhtRoot, db.dhtParameters)

    -- end
    corelog.WriteToLog(">Updated enterprise_energy (level="..enterpriseLevel..")")
    return {success = true}
end

return enterprise_energy
