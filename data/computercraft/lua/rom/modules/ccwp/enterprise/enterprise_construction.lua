-- define module
local enterprise_construction = {}

--[[
    The construction enterprise provides services to construct structures in the physical minecraft world.
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"

local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local InputChecker = require "input_checker"

local role_builder = require "role_builder"

local enterprise_projects = require "enterprise_projects"
local enterprise_assignmentboard = require "enterprise_assignmentboard"
local enterprise_employment

--                _     _ _         __                  _   _
--               | |   | (_)       / _|                | | (_)
--    _ __  _   _| |__ | |_  ___  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | '_ \| | | | '_ \| | |/ __| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | |_) | |_| | |_) | | | (__  | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   | .__/ \__,_|_.__/|_|_|\___| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--   | |
--   |_|

-- ToDo: consider introducing a Blueprint Obj replacing the current table
function enterprise_construction.BuildBlueprint_ASrv(...)
    -- get & check input from description
    local checkSuccess, blueprintStartpoint, blueprint, materialsItemSupplierLocator, wasteItemDepotLocator, callback = InputChecker.Check([[
        This async public service builds a blueprint as a single assignment/ task.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table) {success = true} if the blueprint was successfully build

        Parameters:
            buildData                           - (table) data about what to build
                blueprintStartpoint             + (table) top lower left coordinate to start building the blueprint
                blueprint                       + (table) blueprint to build
                    layerList                   - (table) layer to build
                    escapeSequence              - (table) escapeSequence of blueprint
                materialsItemSupplierLocator    + (ObjLocator) locating the host of the building materials
                wasteItemDepotLocator           + (ObjLocator) locating where waste material can be delivered
            callback                            + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("enterprise_construction.BuildBlueprint_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- construct assignment metadata
    local taskData = {
        blueprintStartpoint     = blueprintStartpoint,
        blueprint               = blueprint,
    }
    local metaData = role_builder.BuildBlueprint_MetaData(taskData)

    -- check if materials needed
    local materialsNeeded = coreutils.DeepCopy(metaData.itemsNeeded)
    local taskCall = TaskCall:newInstance("role_builder", "BuildBlueprint_Task", taskData)
    if next(materialsNeeded) == nil then
        -- directly do assignment
        local assignmentServiceData = {
            metaData    = metaData,
            taskCall    = taskCall,
        }
        corelog.WriteToLog("Starting task 'Building blueprint at "..textutils.serialise(blueprintStartpoint, {compact = true}).."' (without materials)")
        return enterprise_assignmentboard.DoAssignment_ASrv(assignmentServiceData, callback)
    end

    -- set local output location
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local itemDepotLocator = enterprise_employment.GetAnyTurtleLocator() if not itemDepotLocator then corelog.Error("enterprise_construction:BuildBlueprint_ASrv: Failed obtaining itemDepotLocator") return Callback.ErrorCall(callback) end

    -- create project service data
    local buildBlueprintProjectDef = {
        steps   = {
            -- get materials
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "provideItemsTo_AOSrv", locatorStep = 0, locatorKeyDef = "materialsItemSupplierLocator" }, stepDataDef = {
                { keyDef = "provideItems"                   , sourceStep = 0, sourceKeyDef = "materialsNeeded" },
                { keyDef = "itemDepotLocator"               , sourceStep = 0, sourceKeyDef = "itemDepotLocator" },
                { keyDef = "ingredientsItemSupplierLocator" , sourceStep = 0, sourceKeyDef = "ingredientsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Getting building materials(="..textutils.serialise(materialsNeeded, {compact = true})..")"},
            -- obtain workerId
            { stepType = "LSOMtd", stepTypeDef = { methodName = "getWorkerId", locatorStep = 1, locatorKeyDef = "destinationItemsLocator" }, stepDataDef = {
            }},
            -- do build assignment
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"                       , sourceStep = 0, sourceKeyDef = "metaData" },
                { keyDef = "metaData.needWorkerId"          , sourceStep = 2, sourceKeyDef = "methodResults" },
                { keyDef = "taskCall"                       , sourceStep = 0, sourceKeyDef = "taskCall" },
            }, description = "Building blueprint at "..textutils.serialise(blueprintStartpoint, {compact = true})},
        },
        returnData  = {
        }
    }
    local projectData = {
        materialsItemSupplierLocator    = materialsItemSupplierLocator,
        materialsNeeded                 = materialsNeeded,
        itemDepotLocator                = itemDepotLocator:copy(),
        ingredientsItemSupplierLocator  = materialsItemSupplierLocator:copy(),
        wasteItemDepotLocator           = wasteItemDepotLocator,

        metaData                        = metaData,
        taskCall                        = taskCall,
    }
    local projectServiceData = {
        projectDef  = buildBlueprintProjectDef,
        projectData = projectData,
        projectMeta = { title = "Building blueprint", description = "Use unknown" },
    }

    -- start project
--    corelog.WriteToLog(">Building blueprint at "..textutils.serialise(blueprintStartpoint))
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function enterprise_construction.BuildLayer_ASrv(...)
    -- get & check input from description
    local checkSuccess, startpoint, buildDirection, replacePresentObjects, layer, materialsItemSupplierLocator, wasteItemDepotLocator, callback = InputChecker.Check([[
        This async public service builds a rectangular layer in the x,y plane as a single assignment/ task.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table) {success = true} if the layer was successfully build

        Parameters:
            buildData                           - (table) data about what to build
                startpoint                      + (table) lower left coordinate to start building the layer
                buildDirection                  + (string) direction to build from (Up, Down, XXX)
                replacePresentObjects           + (boolean, false) whether objects should be replaced if it is already present in the minecraft world (default = false)
                layer                           + (LayerRectangle) layer to build
                materialsItemSupplierLocator    + (ObjLocator) locating the host of the building materials
                wasteItemDepotLocator           + (ObjLocator) locating where waste material can be delivered
            callback                            + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("enterprise_construction.BuildLayer_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- get assignment metadata
    local taskData = {
        startpoint              = startpoint,
        buildDirection          = buildDirection,
        replacePresentObjects   = replacePresentObjects,
        layer                   = layer,
    }
    local metaData = role_builder.BuildLayer_MetaData(taskData)
    if not metaData then corelog.Error("enterprise_construction.BuildLayer_ASrv: Failed obtaining metaData") return Callback.ErrorCall(callback) end

    -- check if materials needed
    local materialsNeeded = coreutils.DeepCopy(metaData.itemsNeeded)
    local taskCall = TaskCall:newInstance("role_builder", "BuildLayer_Task", taskData)
    if next(materialsNeeded) == nil then
        -- directly do assignment
        local assignmentServiceData = {
            metaData    = metaData,
            taskCall    = taskCall,
        }
        corelog.WriteToLog("Starting task 'Building blueprint layer at "..textutils.serialise(startpoint, {compact = true}).."' (without materials)")
        return enterprise_assignmentboard.DoAssignment_ASrv(assignmentServiceData, callback)
    end

    -- set local output location
    -- note:    Because BuildLayer_Task requires a turtle to have the goods in it's inventory at this point specify that a turtle
    --          should pick up the materials. We however do not yet specify which turtle as we leave it up to the (relayed services of)
    --          the service to find that out. Because of below statement the resulting destinationItemsLocator return value
    --          of that service should specify which turtle has the items in it's inventory.
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local itemDepotLocator = enterprise_employment.GetAnyTurtleLocator() if not itemDepotLocator then corelog.Error("enterprise_construction:BuildLayer_ASrv: Failed obtaining itemDepotLocator") return Callback.ErrorCall(callback) end

    -- create project service data
    local buildRectangularPatternProjectDef = {
        steps   = {
            -- get materials
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "provideItemsTo_AOSrv", locatorStep = 0, locatorKeyDef = "materialsItemSupplierLocator" }, stepDataDef = {
                { keyDef = "provideItems"                   , sourceStep = 0, sourceKeyDef = "materialsNeeded" },
                { keyDef = "itemDepotLocator"               , sourceStep = 0, sourceKeyDef = "itemDepotLocator" },
                { keyDef = "ingredientsItemSupplierLocator" , sourceStep = 0, sourceKeyDef = "ingredientsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Getting building materials(="..textutils.serialise(materialsNeeded, {compact = true})..")"},
            -- obtain workerId
            { stepType = "LSOMtd", stepTypeDef = { methodName = "getWorkerId", locatorStep = 1, locatorKeyDef = "destinationItemsLocator" }, stepDataDef = {
            }},
            -- do build assignment
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"                       , sourceStep = 0, sourceKeyDef = "metaData" },
                { keyDef = "metaData.needWorkerId"          , sourceStep = 2, sourceKeyDef = "methodResults" },
                { keyDef = "taskCall"                       , sourceStep = 0, sourceKeyDef = "taskCall" },
            }},
        },
        returnData  = {
        }
    }
    local projectData = {
        materialsItemSupplierLocator    = materialsItemSupplierLocator,
        materialsNeeded                 = materialsNeeded,
        itemDepotLocator                = itemDepotLocator:copy(),
        ingredientsItemSupplierLocator  = materialsItemSupplierLocator:copy(),
        wasteItemDepotLocator           = wasteItemDepotLocator,

        metaData                        = metaData,
        taskCall                        = taskCall,
    }
    local projectServiceData = {
        projectDef  = buildRectangularPatternProjectDef,
        projectData = projectData,
        projectMeta = { title = "Building blueprint layer at "..textutils.serialise(startpoint, {compact = true}), description = "Use unknown" },
    }

    -- start project
--    corelog.WriteToLog(">Building layer at "..textutils.serialise(startpoint))
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

--    _                 _    __                  _   _
--   | |               | |  / _|                | | (_)
--   | | ___   ___ __ _| | | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | |/ _ \ / __/ _` | | |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | (_) | (_| (_| | | | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_|\___/ \___\__,_|_| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/

return enterprise_construction
