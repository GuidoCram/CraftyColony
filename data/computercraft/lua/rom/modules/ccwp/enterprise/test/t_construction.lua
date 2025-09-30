local t_construction = {}

local corelog = require "corelog"

local Callback = require "obj_callback"
local ObjTable = require "obj_table"
local Location = require "obj_location"
local Block = require "obj_block"
local CodeMap = require "obj_code_map"
local LayerRectangle = require "obj_layer_rectangle"

local enterprise_projects = require "enterprise_projects"
local enterprise_construction = require "enterprise_construction"
local enterprise_storage = require "enterprise_storage"

local t_storage = require "test.t_storage"
local t_employment = require "test.t_employment"

local testStartLocation     = Location:newInstance(-6, 0, 1, 0, 1)
local testStartLocation2    = testStartLocation:getRelativeLocation(0, 6, 0)

local testBuildLayer1 = LayerRectangle:newInstance(
    ObjTable:newInstance(Block:getClassName(), {
        ["T"]   = Block:newInstance("minecraft:torch"),
        ["C"]   = Block:newInstance("minecraft:chest", 0, 1),
        [" "]   = Block:newInstance(Block.NoneBlockName()),
    }),
    CodeMap:newInstance({
        [6] = "  C ",
        [5] = "    ",
        [4] = "T   ",
        [3] = "    ",
        [2] = "    ",
        [1] = "   T",
    })
) assert(testBuildLayer1, "Failed obtaining testBuildLayer1")

local testBuildLayer2 = LayerRectangle:newInstance(
    ObjTable:newInstance(Block:getClassName(), {
        ["C"]   = Block:newInstance("minecraft:chest", -1, 0),
        ["D"]   = Block:newInstance("minecraft:chest", 0, 1),
        ["E"]   = Block:newInstance("minecraft:chest", 0, -1),
        ["F"]   = Block:newInstance("minecraft:chest", 1, 0),
        [" "]   = Block:newInstance(Block.NoneBlockName()),
    }),
    CodeMap:newInstance({
        [3] = "DDF",
        [2] = "C F",
        [1] = "CEE",
    })
) assert(testBuildLayer2, "Failed obtaining testBuildLayer2")

local testBuildLayer3 = LayerRectangle:newInstance(
    ObjTable:newInstance(Block:getClassName(), {
        ["T"]   = Block:newInstance("minecraft:torch"),
        ["C"]   = Block:newInstance("minecraft:chest", 0, 1),
        [" "]   = Block:newInstance(Block.NoneBlockName()),
    }),
    CodeMap:newInstance({
        [6] = "  C C ",
        [5] = "      ",
        [4] = "T     ",
        [3] = "      ",
        [2] = "      ",
        [1] = "   T  ",
    })
) assert(testBuildLayer3, "Failed obtaining testBuildLayer3")

local testBuildLayer4 = LayerRectangle:newInstance(
    ObjTable:newInstance(Block:getClassName(), {
        [" "]   = Block:newInstance(Block.NoneBlockName()),
    }),
    CodeMap:newInstance({
        [1] = " ",
    })
) assert(testBuildLayer4, "Failed obtaining testBuildLayer4")

function t_construction.T_BuildLayer_ASrv_FromTurtle()
    -- test service 1
    corelog.WriteToLog("* BuildLayer_ASrv (from turtle) test")
    local buildData = {
        startpoint                  = testStartLocation,
        buildDirection              = "Down",
        layer                       = testBuildLayer1,
        materialsItemSupplierLocator= t_employment.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_employment.GetCurrentTurtleLocator(),
    }
    local callback = Callback.GetNewDummyCallBack()

    corelog.WriteToLog("T_construction calling BuildLayer_ASrv("..textutils.serialise(buildData)..", ...)")
    return enterprise_construction.BuildLayer_ASrv(buildData, callback)
end

function t_construction.T_BuildLayer_ASrv_FromChest()
    -- test service
    corelog.WriteToLog("* BuildLayer_ASrv (from Chest) test")

    -- create project definition
    local buildRectangularPattern_ASrvProjectDef = {
        steps   = {
            -- host and update Chest
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_projects", serviceName = "StartProject_ASrv" }, stepDataDef = {
                { keyDef = "projectDef"             , sourceStep = 0, sourceKeyDef = "projectDef" },
                { keyDef = "projectData"            , sourceStep = 0, sourceKeyDef = "projectData" },
            }},
            -- BuildLayer_ASrv
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_construction", serviceName = "BuildLayer_ASrv" }, stepDataDef = {
                { keyDef = "startpoint"                     , sourceStep = 0, sourceKeyDef = "startpoint" },
                { keyDef = "buildDirection"                 , sourceStep = 0, sourceKeyDef = "buildDirection" },
                { keyDef = "layer"                          , sourceStep = 0, sourceKeyDef = "layer" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 1, sourceKeyDef = "chestLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 1, sourceKeyDef = "chestLocator" },
            }},
            -- cleanup
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "releaseLObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 1, sourceKeyDef = "chestLocator" },
            }},
        },
        returnData  = {
        }
    }
    local projectServiceData = {
        projectDef  = buildRectangularPattern_ASrvProjectDef,
        projectData = {
            -- Chest
            projectDef  = t_storage.GetHostAndUpdateChestProjectDef(),
            projectData = {
                hostLocator         = enterprise_storage:getHostLocator(),
                className           = "Chest",
                constructParameters = {
                    baseLocation    = testStartLocation:getRelativeLocation(2, 5, 0),
                    accessDirection = "top",
                }
            },
            hostLocator = enterprise_storage:getHostLocator(),

            -- build data
            startpoint              = testStartLocation2,
            buildDirection          = "Down",
            layer                   = testBuildLayer1,
        },
        projectMeta = { title = "Test: Build Layer from Chest", description = "Building a test layer" },
    }

    -- start project
    local callback = Callback.GetNewDummyCallBack()
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function t_construction.T_BuildBlueprint_ASrv()
    -- prepare test
    corelog.WriteToLog("* BuildBlueprint_ASrv test")
    local testBlueprint1 = {
        layerList = {
            { startpoint = Location:newInstance(0, 0, 0), buildDirection = "Down", layer = testBuildLayer3:copy()},
            { startpoint = Location:newInstance(3, 3, -1), buildDirection = "Up", layer = testBuildLayer4:copy()},
            { startpoint = Location:newInstance(2, 2, -2), buildDirection = "Up", layer = testBuildLayer2:copy()},
            { startpoint = Location:newInstance(2, 2, -3), buildDirection = "Up", layer = testBuildLayer2:copy()}
        },
        escapeSequence = {
            Location:newInstance(3, 3, 1),
        }
    }
    local blueprintBuildData = {
        blueprintStartpoint         = testStartLocation:getRelativeLocation(0, 12, 0),
        blueprint                   = testBlueprint1,
        materialsItemSupplierLocator= t_employment.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_employment.GetCurrentTurtleLocator(),
    }
    local callback = Callback.GetNewDummyCallBack()

    -- test
--    corelog.WriteToLog("T_construction calling BuildBlueprint_ASrv("..textutils.serialise(blueprintBuildData)..", ...)")
    enterprise_construction.BuildBlueprint_ASrv(blueprintBuildData, callback)

    -- cleanup test
end

return t_construction
