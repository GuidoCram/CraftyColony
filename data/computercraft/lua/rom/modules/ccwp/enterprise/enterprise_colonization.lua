-- define class
local Class = require "class"
local LObjHost = require "lobj_host"
local enterprise_colonization = Class.NewClass(LObjHost)

--[[
    The enterprise_colonization is a LObjHost. It hosts essential Obj's like Settlement's, Shop's etc.

    The enterprise_colonization provides basic functionality for colonizing the world.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local Location = require "obj_location"

local role_settler = require "role_settler"

local enterprise_projects = require "enterprise_projects"
local enterprise_employment
local enterprise_manufacturing = require "enterprise_manufacturing"
local enterprise_forestry = require "enterprise_forestry"
local enterprise_storage = require "enterprise_storage"
local enterprise_gathering = require "enterprise_gathering"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

-- note: currently enterprise is treated like a singleton, but by directly using the name of the module
-- ToDo: consider making changes to enterprise to
--          - explicitly make it a singleton (by construction with :newInstance(hostName) and using the singleton pattern)
--          - properly initialise it (by adding and implementing the _init method)
--          - adopt other classes to these changes
enterprise_colonization._hostName   = "enterprise_colonization"

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function enterprise_colonization:getClassName()
    return "enterprise_colonization"
end

--    ______       _                       _           _____      _             _          _   _
--   |  ____|     | |                     (_)         / ____|    | |           (_)        | | (_)
--   | |__   _ __ | |_ ___ _ __ _ __  _ __ _ ___  ___| |     ___ | | ___  _ __  _ ______ _| |_ _  ___  _ __
--   |  __| | '_ \| __/ _ \ '__| '_ \| '__| / __|/ _ \ |    / _ \| |/ _ \| '_ \| |_  / _` | __| |/ _ \| '_ \
--   | |____| | | | ||  __/ |  | |_) | |  | \__ \  __/ |___| (_) | | (_) | | | | |/ / (_| | |_| | (_) | | | |
--   |______|_| |_|\__\___|_|  | .__/|_|  |_|___/\___|\_____\___/|_|\___/|_| |_|_/___\__,_|\__|_|\___/|_| |_|
--                             | |
--                             |_|

-- ToDo: consider renaming to enterprise_colonization:createNewSettlement_AOSrv
function enterprise_colonization.CreateNewWorld_ASrv(...)
    -- get & check input from description
    local checkSuccess, callback = InputChecker.Check([[
        This public async service creates a new CCWorldPlatform world.
            It bootstraps the world logic by building an initiating several enterprise (sites).

            The turtle should already have (either equiped or in it's inventory)
                one modem
                one diamon axe
                one crafting table
                one birchSapling
            It is not necessary for the turtle to have any energy. The turtle will start by placing the sapling in front of itself.

            The function also defines the coordinate system by assuming the turtle starts at the Location {_x= 3, _y= 2, _z= 1, _dx=0, _dy=1}. This
            allows for the initial BirchForest that is build to fit in the 6x6 grid that is used in layers with the lower left coordinate of the base
            of that BirchForest being Location {_x= 0, _y= 0, _z= 1, _dx=0, _dy=1}

        Return value:
                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                - (table)
                success         - (boolean) whether the service executed successfully

        Parameters:
            serviceData         - (table) data about the service
                <currently none>
            callback            + (Callback) to call once service is ready
    --]], ...)
    if not checkSuccess then corelog.Error("enterprise_colonization.CreateNewWorld_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- ToDo: Controle of aan de voorwaarden is voldaan, modem, axe, crafting table, birch sapling

    -- get currentTurtleLocator
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local currentTurtleLocator = enterprise_employment:getCurrentWorkerLocator() if not currentTurtleLocator then corelog.Error("enterprise_colonization.CreateNewWorld_ASrv: Failed obtaining current turtleLocator") return Callback.ErrorCall(callback) end

    -- get Settlement from currentTurtleObj
    local currentTurtleObj = enterprise_employment:getObj(currentTurtleLocator) if not currentTurtleObj then corelog.Error("enterprise_colonization.CreateNewWorld_ASrv: Failed obtaining current Turtle "..currentTurtleLocator:getURI()) return Callback.ErrorCall(callback) end
    local settlementLocator = currentTurtleObj:getSettlementLocator() if not settlementLocator then corelog.Error("enterprise_colonization.CreateNewWorld_ASrv: Failed obtaining settlementLocator") return Callback.ErrorCall(callback) end
    local settlementObj = enterprise_colonization:getObj(settlementLocator) if not settlementObj then corelog.Error("enterprise_colonization.CreateNewWorld_ASrv: Failed obtaining Settlement "..settlementLocator:getURI()) return Callback.ErrorCall(callback) end

    -- construct arguments
    local startLocation             = Location:newInstance(3, 2, 1, 0, 1)
    local forestLocation            = Location:newInstance(0, 0, 1, 0, 1)
    local mineLocation              = Location:newInstance(0, -12, 1, 0, 1):getRelativeLocation(3, 3, 0)
    local initialiseCoordinatesTaskData =  {
        startLocation               = startLocation:copy(),
        workerLocator               = currentTurtleLocator,
    }
    local factoryLocation           = Location:newInstance(12, 0, 1, 0, 1)
    local nTreeswanted = 6
    local projectData = {
        currentTurtleLocator            = currentTurtleLocator:copy(),
        shopLocator                     = settlementObj:getMainShopLocator(),

        wasteItemDepotLocator           = currentTurtleLocator:copy(), -- ToDo: at some point use obj_wastehandler here + somehow pass this to enterprise_employment:triggerTurtleRefuelIfNeeded

        startLocation                   = startLocation:copy(),

        initialiseCoordinatesMetaData   = role_settler.InitialiseCoordinates_MetaData(initialiseCoordinatesTaskData),
        initialiseCoordinatesTaskCall   = TaskCall:newInstance("role_settler", "InitialiseCoordinates_Task", initialiseCoordinatesTaskData),

        factoryHostLocator              = enterprise_manufacturing:getHostLocator(),
        factoryClassName                = "Factory",
        factoryConstructParameters0     = {
            level                           = 0,

            baseLocation                    = startLocation:copy(),
        },

        forestHostLocator               = enterprise_forestry:getHostLocator(),
        forestClassName                 = "BirchForest",
        forestConstructParameters_Lm1T1 = {
            level                           = -1,

            baseLocation                    = forestLocation:copy(),
            nTrees                          = 1,
        },

        upgradeParametersToForestL0T1   = {
            level                           = 0,

            nTrees                          = 1,
        },
        upgradeParametersToForestL1T1   = {
            level                           = 1,

            nTrees                          = 1,
        },
        upgradeParametersToForestL1T2   = {
            level                           = 1,

            nTrees                          = 2,
        },
        upgradeParametersToForestL1T4   = {
            level                           = 1,

            nTrees                          = 4,
        },
        upgradeParametersToForestL1T6   = {
            level                           = 1,

            nTrees                          = nTreeswanted,
        },
        upgradeParametersToForestL2T6   = {
            level                           = 2,

            nTrees                          = nTreeswanted,
        },

        energyL0                        = 0,
        energyL1                        = 1,
        energyL2                        = 2,
        energyL3                        = 3,

        mineHostLocator                 = enterprise_gathering:getHostLocator(),
        mineClassName                   = "MineShaft",
        mineConstructParameters         = {
            baseLocation                    = mineLocation:copy(),
            maxDepth                        = 37,
        },

        factoryConstructParameters1     = {
            level                           = 1,

            baseLocation                    = factoryLocation:copy(),
        },

        upgradeParametersToFactory2     = {
            level                           = 2,
        },

        siloHostLocator                 = enterprise_storage:getHostLocator(),
        siloClassName                   = "Silo",
        siloConstructParameters         = {
            baseLocation                    = Location:newInstance(12, -12, 1, 0, 1),
            nTopChests                      = 2,
            nLayers                         = 2,
        },
    }

    -- create project definition
    local projectDef = {
        steps   = { -- ToDo: introduce enterprise_energy.UpgradeSite_ASrv and wrap create steps in it as documented here https://docs.google.com/spreadsheets/d/1yqShiBSVzldGMauvwqLkRrJOjc38RUuAtjk7L1cR7Uk/edit#gid=91593168
            -- register current Turtle in Shop
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "registerItemSupplier_SOSrv", locatorStep = 0, locatorKeyDef = "shopLocator" }, stepDataDef = {
                { keyDef = "itemSupplierLocator"            , sourceStep = 0, sourceKeyDef = "currentTurtleLocator" },
            }, description = "Registering current Turtle in Shop"},
            -- initial (L0) enterprise_energy (refuelAmount = 0, fuelNeed_Refuel = 0)
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_energy", serviceName = "UpdateEnterprise_SSrv" }, stepDataDef = {
                { keyDef = "enterpriseLevel"                , sourceStep = 0, sourceKeyDef = "energyL0" },
            }},
            -- initialise coordinates
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"                       , sourceStep = 0, sourceKeyDef = "initialiseCoordinatesMetaData" },
                { keyDef = "taskCall"                       , sourceStep = 0, sourceKeyDef = "initialiseCoordinatesTaskCall" },
            }, description = "Setting coordinates"},
            -- host, build and register initial (L0) Factory (crafting spot, i.e. in place hole in the ground)
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "buildAndHostMObj_ASrv", locatorStep = 0, locatorKeyDef = "factoryHostLocator" }, stepDataDef = {
                { keyDef = "className"                      , sourceStep = 0, sourceKeyDef = "factoryClassName" },
                { keyDef = "constructParameters"            , sourceStep = 0, sourceKeyDef = "factoryConstructParameters0" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "shopLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Building first Factory"},
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "registerItemSupplier_SOSrv", locatorStep = 0, locatorKeyDef = "shopLocator" }, stepDataDef = {
                { keyDef = "itemSupplierLocator"            , sourceStep = 4, sourceKeyDef = "mobjLocator" },
            }},
            -- host, build and register initial (L-1) BirchForest (1 sapling in front of turtle)
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "buildAndHostMObj_ASrv", locatorStep = 0, locatorKeyDef = "forestHostLocator" }, stepDataDef = {
                { keyDef = "className"                      , sourceStep = 0, sourceKeyDef = "forestClassName" },
                { keyDef = "constructParameters"            , sourceStep = 0, sourceKeyDef = "forestConstructParameters_Lm1T1" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "shopLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Building first BirchForest"},
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "registerItemSupplier_SOSrv", locatorStep = 0, locatorKeyDef = "shopLocator" }, stepDataDef = {
                { keyDef = "itemSupplierLocator"            , sourceStep = 6, sourceKeyDef = "mobjLocator" },
            }},
            -- update enterprise_energy to L1 (refuelAmount = 1 log = 60, fuelNeed_Refuel = fuelNeed_Harvest + fuelNeed_Production + fuelNeed_ForestFactoryTravel)
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_energy", serviceName = "UpdateEnterprise_SSrv" }, stepDataDef = {
                { keyDef = "enterpriseLevel"                , sourceStep = 0, sourceKeyDef = "energyL1" },
                { keyDef = "forestLocator"                  , sourceStep = 6, sourceKeyDef = "mobjLocator" },
                { keyDef = "factoryLocator"                 , sourceStep = 4, sourceKeyDef = "mobjLocator" },
            }},
            -- upgrade BirchForest to L0 (1 tree/ sapling)
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "extendAndUpgradeMObj_ASrv", locatorStep = 0, locatorKeyDef = "forestHostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 6, sourceKeyDef = "mobjLocator" },
                { keyDef = "upgradeParameters"              , sourceStep = 0, sourceKeyDef = "upgradeParametersToForestL0T1" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "shopLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
                -- if "no OR low on fuel"
                --  => HarvestForest_Task ("Waiting for first tree" => chop first log) => refuel to 60
                -- if still "low on fuel"
                --  => HarvestForest_Task ("chop remainder of first tree")
            }, description = "Extending BirchForest to L0 and 1 tree"},
            -- update enterprise_energy to L2 (refuelAmount = 1 tree = 300, fuelNeed_Refuel = fuelNeed_Harvest + fuelNeed_ExtraTree + fuelNeed_Production + fuelNeed_ForestFactoryTravel)
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_energy", serviceName = "UpdateEnterprise_SSrv" }, stepDataDef = {
                { keyDef = "enterpriseLevel"                , sourceStep = 0, sourceKeyDef = "energyL2" },
                { keyDef = "forestLocator"                  , sourceStep = 6, sourceKeyDef = "mobjLocator" },
                { keyDef = "factoryLocator"                 , sourceStep = 4, sourceKeyDef = "mobjLocator" },
            }},
            -- host, build and register MineShaft (to be able to gather cobblestone for furnance)
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "buildAndHostMObj_ASrv", locatorStep = 0, locatorKeyDef = "mineHostLocator" }, stepDataDef = {
                { keyDef = "className"                      , sourceStep = 0, sourceKeyDef = "mineClassName" },
                { keyDef = "constructParameters"            , sourceStep = 0, sourceKeyDef = "mineConstructParameters" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "shopLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Building MineShaft"},
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "registerItemSupplier_SOSrv", locatorStep = 0, locatorKeyDef = "shopLocator" }, stepDataDef = {
                { keyDef = "itemSupplierLocator"            , sourceStep = 11, sourceKeyDef = "mobjLocator" },
            }},
            -- host, build and register new L1 Factory (crafting + smelting spot)
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "buildAndHostMObj_ASrv", locatorStep = 0, locatorKeyDef = "factoryHostLocator" }, stepDataDef = {
                { keyDef = "className"                      , sourceStep = 0, sourceKeyDef = "factoryClassName" },
                { keyDef = "constructParameters"            , sourceStep = 0, sourceKeyDef = "factoryConstructParameters1" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "shopLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Building a better Factory"},
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "registerItemSupplier_SOSrv", locatorStep = 0, locatorKeyDef = "shopLocator" }, stepDataDef = {
                { keyDef = "itemSupplierLocator"            , sourceStep = 13, sourceKeyDef = "mobjLocator" },
            }},
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_energy", serviceName = "UpdateEnterprise_SSrv" }, stepDataDef = {
                { keyDef = "enterpriseLevel"                , sourceStep = 0, sourceKeyDef = "energyL3" }, -- ToDo: back to wanted energyL2
                -- ToDo: investigate how we can postpone L3 to later ... somehow this sometimes fails. Is this because we do not yet claim resources inside the turtle??
                { keyDef = "forestLocator"                  , sourceStep = 6, sourceKeyDef = "mobjLocator" },
                { keyDef = "factoryLocator"                 , sourceStep = 13, sourceKeyDef = "mobjLocator" },
            }},
            -- delist, dismantle and release initial crafting spot
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "delistItemSupplier_SOSrv", locatorStep = 0, locatorKeyDef = "shopLocator" }, stepDataDef = {
                { keyDef = "itemSupplierLocator"            , sourceStep = 4, sourceKeyDef = "mobjLocator" },
            }},
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "dismantleAndReleaseMObj_ASrv", locatorStep = 0, locatorKeyDef = "factoryHostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 4, sourceKeyDef = "mobjLocator" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "shopLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Removing initial Factory"},
            -- upgrade BirchForest to L1 with 1 tree
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "extendAndUpgradeMObj_ASrv", locatorStep = 0, locatorKeyDef = "forestHostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 6, sourceKeyDef = "mobjLocator" },
                { keyDef = "upgradeParameters"              , sourceStep = 0, sourceKeyDef = "upgradeParametersToForestL1T1" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "shopLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Extending BirchForest to L1 and 1 tree"},
            -- upgrade BirchForest to L1 with 2 trees
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "extendAndUpgradeMObj_ASrv", locatorStep = 0, locatorKeyDef = "forestHostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 6, sourceKeyDef = "mobjLocator" },
                { keyDef = "upgradeParameters"              , sourceStep = 0, sourceKeyDef = "upgradeParametersToForestL1T2" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "shopLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Extending BirchForest to L1 and 2 trees"},
            -- upgrade BirchForest to L1 with 4 trees
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "extendAndUpgradeMObj_ASrv", locatorStep = 0, locatorKeyDef = "forestHostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 6, sourceKeyDef = "mobjLocator" },
                { keyDef = "upgradeParameters"              , sourceStep = 0, sourceKeyDef = "upgradeParametersToForestL1T4" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "shopLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Extending BirchForest to L1 and 4 trees"},
            -- upgrade BirchForest to L1 with 6 trees
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "extendAndUpgradeMObj_ASrv", locatorStep = 0, locatorKeyDef = "forestHostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 6, sourceKeyDef = "mobjLocator" },
                { keyDef = "upgradeParameters"              , sourceStep = 0, sourceKeyDef = "upgradeParametersToForestL1T6" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "shopLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Extending BirchForest to L1 and 6 trees"},
            -- upgrade BirchForest to L2 (in/out chests + 6 trees)
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "extendAndUpgradeMObj_ASrv", locatorStep = 0, locatorKeyDef = "forestHostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 6, sourceKeyDef = "mobjLocator" },
                { keyDef = "upgradeParameters"              , sourceStep = 0, sourceKeyDef = "upgradeParametersToForestL2T6" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "shopLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Extending BirchForest to L2 and 6 trees"},
            -- upgrade/ replace existing L1 Factory to/ with L2 Factory (in/out chests, crafting + smelting spot)
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "extendAndUpgradeMObj_ASrv", locatorStep = 0, locatorKeyDef = "factoryHostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 13, sourceKeyDef = "mobjLocator" },
                { keyDef = "upgradeParameters"              , sourceStep = 0, sourceKeyDef = "upgradeParametersToFactory2" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "shopLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Extending Factory to L2"},
            -- host, build and register Silo
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "buildAndHostMObj_ASrv", locatorStep = 0, locatorKeyDef = "siloHostLocator" }, stepDataDef = {
                { keyDef = "className"                      , sourceStep = 0, sourceKeyDef = "siloClassName" },
                { keyDef = "constructParameters"            , sourceStep = 0, sourceKeyDef = "siloConstructParameters" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "shopLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Building silo"},
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "registerItemSupplier_SOSrv", locatorStep = 0, locatorKeyDef = "shopLocator" }, stepDataDef = {
                { keyDef = "itemSupplierLocator"            , sourceStep = 24, sourceKeyDef = "mobjLocator" },
            }},
            -- delist current Turtle from Shop
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "delistItemSupplier_SOSrv", locatorStep = 0, locatorKeyDef = "shopLocator" }, stepDataDef = {
                { keyDef = "itemSupplierLocator"            , sourceStep = 0, sourceKeyDef = "currentTurtleLocator" },
            }, description = "Delisting current Turtle from Shop"},
            --
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_dump", serviceName = "ListItemDepot_SSrv" }, stepDataDef = {
                { keyDef = "itemDepotLocator"               , sourceStep = 24, sourceKeyDef = "mobjLocator" },
            }},
            -- dump all gathered waste from current Turtle
            -- ToDo: implement
            -- update enterprise_energy to L3 (refuelAmount = 6 trees = 1800, fuelNeed_Refuel = fuelNeed_Harvest + fuelNeed_ExtraTree + fuelNeed_Production + fuelNeed_ForestFactoryTravel)
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_energy", serviceName = "UpdateEnterprise_SSrv" }, stepDataDef = {
                { keyDef = "enterpriseLevel"                , sourceStep = 0, sourceKeyDef = "energyL3" },
                { keyDef = "forestLocator"                  , sourceStep = 6, sourceKeyDef = "mobjLocator" },
                { keyDef = "factoryLocator"                 , sourceStep = 13, sourceKeyDef = "mobjLocator" },
            }},
        },
        returnData  = {
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Project colonize", description = "Creating a new world" },
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function enterprise_colonization.RecoverNewWorld_SSrv(...)
    -- get & check input from description
    local checkSuccess = InputChecker.Check([[
        This public async service recovers an earlier created CCWorldPlatform world.

        It assumed the CreateNewWorld_ASrv had been run earlier but the corresponding created objects got lost in the dht. It recreates them.

        Return value:
                success         - (boolean) whether the service executed successfully

        Parameters:
            serviceData         - (table) data about the service
                <currently none>
    --]], ...)
    if not checkSuccess then corelog.Error("enterprise_colonization.RecoverNewWorld_Srv: Invalid input") return { success = false } end

    -- get currentTurtleLocator
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local currentTurtleLocator = enterprise_employment:getCurrentWorkerLocator() if not currentTurtleLocator then corelog.Error("enterprise_colonization.RecoverNewWorld_SSrv: Failed obtaining current turtleLocator") return { success = false } end

    -- get Settlement from currentTurtleObj
    local currentTurtleObj = enterprise_employment:getObj(currentTurtleLocator) if not currentTurtleObj then corelog.Error("enterprise_colonization.RecoverNewWorld_SSrv: Failed obtaining current Turtle "..currentTurtleLocator:getURI()) return { success = false } end
    local settlementLocator = currentTurtleObj:getSettlementLocator() if not settlementLocator then corelog.Error("enterprise_colonization.RecoverNewWorld_SSrv: Failed obtaining settlementLocator") return { success = false } end
    local settlementObj = enterprise_colonization:getObj(settlementLocator) if not settlementObj then corelog.Error("enterprise_colonization.RecoverNewWorld_SSrv: Failed obtaining Settlement "..settlementLocator:getURI()) return { success = false } end

    -- construct arguments
    local forestLocation            = Location:newInstance(0, 0, 1, 0, 1)
    local factoryLocation           = Location:newInstance(12, 0, 1, 0, 1)
    local mineLocation              = Location:newInstance(0, -12, 1, 0, 1):getRelativeLocation(3, 3, 0)
    local nTreeswanted = 6
    local projectData = {
        shopLocator                     = settlementObj:getMainShopLocator(),

        factoryHostLocator              = enterprise_manufacturing:getHostLocator(),
        factoryClassName                = "Factory",
        factoryConstructParameters      = {
            level                           = 2,

            baseLocation                    = factoryLocation:copy(),
        },

        forestHostLocator               = enterprise_forestry:getHostLocator(),
        forestClassName                 = "BirchForest",
        forestConstructParameters       = {
            level                           = 2,

            baseLocation                    = forestLocation:copy(),
            nTrees                          = nTreeswanted,
        },

        mineHostLocator                 = enterprise_gathering:getHostLocator(),
        mineClassName                   = "MineShaft",
        mineConstructParameters         = {
            baseLocation                    = mineLocation:copy(),
            maxDepth                        = 37,
        },

        energyL3                        = 3,

        siloHostLocator                 = enterprise_storage:getHostLocator(),
        siloClassName                   = "Silo",
        siloConstructParameters         = {
            baseLocation                    = Location:newInstance(12, -12, 1, 0, 1),
            nTopChests                      = 2,
            nLayers                         = 2,
        },
    }
    local callback = Callback.GetNewDummyCallBack()

    -- create project definition
    local projectDef = {
        steps   = {
            -- host and register BirchForest
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "hostLObj_SSrv", locatorStep = 0, locatorKeyDef = "forestHostLocator" }, stepDataDef = {
                { keyDef = "className"                      , sourceStep = 0, sourceKeyDef = "forestClassName" },
                { keyDef = "constructParameters"            , sourceStep = 0, sourceKeyDef = "forestConstructParameters" },
            }, description = "Hosting BirchForest"},
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "registerItemSupplier_SOSrv", locatorStep = 0, locatorKeyDef = "shopLocator" }, stepDataDef = {
                { keyDef = "itemSupplierLocator"            , sourceStep = 1, sourceKeyDef = "mobjLocator" },
            }},
            -- host and register Factory
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "hostLObj_SSrv", locatorStep = 0, locatorKeyDef = "factoryHostLocator" }, stepDataDef = {
                { keyDef = "className"                      , sourceStep = 0, sourceKeyDef = "factoryClassName" },
                { keyDef = "constructParameters"            , sourceStep = 0, sourceKeyDef = "factoryConstructParameters" },
            }, description = "Hosting Factory"},
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "registerItemSupplier_SOSrv", locatorStep = 0, locatorKeyDef = "shopLocator" }, stepDataDef = {
                { keyDef = "itemSupplierLocator"            , sourceStep = 3, sourceKeyDef = "mobjLocator" },
            }},
            -- host and register MineShaft
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "hostLObj_SSrv", locatorStep = 0, locatorKeyDef = "mineHostLocator" }, stepDataDef = {
                { keyDef = "className"                      , sourceStep = 0, sourceKeyDef = "mineClassName" },
                { keyDef = "constructParameters"            , sourceStep = 0, sourceKeyDef = "mineConstructParameters" },
            }, description = "Hosting MineShaft"},
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "registerItemSupplier_SOSrv", locatorStep = 0, locatorKeyDef = "shopLocator" }, stepDataDef = {
                { keyDef = "itemSupplierLocator"            , sourceStep = 5, sourceKeyDef = "mobjLocator" },
            }},
            -- host and register Silo
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "hostLObj_SSrv", locatorStep = 0, locatorKeyDef = "siloHostLocator" }, stepDataDef = {
                { keyDef = "className"                      , sourceStep = 0, sourceKeyDef = "siloClassName" },
                { keyDef = "constructParameters"            , sourceStep = 0, sourceKeyDef = "siloConstructParameters" },
            }, description = "Hosting Silo"},
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "registerItemSupplier_SOSrv", locatorStep = 0, locatorKeyDef = "shopLocator" }, stepDataDef = {
                { keyDef = "itemSupplierLocator"            , sourceStep = 7, sourceKeyDef = "mobjLocator" },
            }},
            --
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_dump", serviceName = "ListItemDepot_SSrv" }, stepDataDef = {
                { keyDef = "itemDepotLocator"               , sourceStep = 7, sourceKeyDef = "mobjLocator" },
            }},
            -- update enterprise_energy to L3 (refuelAmount = 6 trees = 1800, fuelNeed_Refuel = fuelNeed_Harvest + fuelNeed_ExtraTree + fuelNeed_Production + fuelNeed_ForestFactoryTravel)
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_energy", serviceName = "UpdateEnterprise_SSrv" }, stepDataDef = {
                { keyDef = "enterpriseLevel"            , sourceStep = 0, sourceKeyDef = "energyL3" },
                { keyDef = "forestLocator"              , sourceStep = 1, sourceKeyDef = "mobjLocator" },
                { keyDef = "factoryLocator"             , sourceStep = 3, sourceKeyDef = "mobjLocator" },
            }},
        },
        returnData  = {
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Project colonize", description = "Creating a new world" },
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

return enterprise_colonization
