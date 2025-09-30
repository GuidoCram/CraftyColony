local t_builder = {}

local corelog = require "corelog"

local ObjTable = require "obj_table"
local Location = require "obj_location"
local Block = require "obj_block"
local CodeMap = require "obj_code_map"
local LayerRectangle = require "obj_layer_rectangle"

local role_builder = require "role_builder"

function t_builder.T_All()
    -- role_builder
    t_builder.T_BuildLayer_MetaData()
    t_builder.T_BuildBlueprint_MetaData()
end

function t_builder.T_AllPhysical()
    -- role_builder
    t_builder.T_BuildLayer_Task_Down()
    t_builder.T_BuildLayer_Task_Up()
    t_builder.T_BuildLayer_Task_Front()
end

local testStartLocation_Down = Location:newInstance(-6, 0, 1, 0, 1)
local testStartLocation_Up = Location:newInstance(-12, 6, 2, 0, 1)
local testStartLocation_Front = Location:newInstance(-12, 1, 1, 0, 1)

local size_x1 = 4
local size_y1 = 6
local chestItemName = "minecraft:chest"
local torchItemName = "minecraft:torch"
local saplingItemName = "minecraft:birch_sapling"
local codeTable1 = ObjTable:newInstance(Block:getClassName(), {
    ["T"]   = Block:newInstance(torchItemName),
    ["C"]   = Block:newInstance(chestItemName, 0, 1),
    ["?"]   = Block:newInstance(Block.AnyBlockName()),
    [" "]   = Block:newInstance(Block.NoneBlockName()),
})
local codeMap1 = CodeMap:newInstance({
    [6] = "  C ",
    [5] = "    ",
    [4] = "T   ",
    [3] = "    ",
    [2] = "    ",
    [1] = "   T",
}) assert(codeMap1, "Failed obtaining codeMap1")
local testBuildLayer1 = LayerRectangle:newInstance(codeTable1:copy(), codeMap1:copy()) assert(testBuildLayer1, "Failed obtaining testBuildLayer1")

local testBuildLayer_Up = LayerRectangle:newInstance(
    ObjTable:newInstance(Block:getClassName(), {
        ["C"]   = Block:newInstance(chestItemName, -1, 0),
        ["D"]   = Block:newInstance(chestItemName, 0, 1),
        ["E"]   = Block:newInstance(chestItemName, 0, -1),
        ["F"]   = Block:newInstance(chestItemName, 1, 0),
        [" "]   = Block:newInstance(Block.NoneBlockName()),
    }),
    CodeMap:newInstance({
        [3] = "DDF",
        [2] = "C F",
        [1] = "CEE",
    })
) assert(testBuildLayer_Up, "Failed obtaining testBuildLayer_Up")

local testBuildLayer_Down = LayerRectangle:newInstance(
    ObjTable:newInstance(Block:getClassName(), {
        ["T"]   = Block:newInstance(torchItemName),
        ["C"]   = Block:newInstance(chestItemName, -1, 0),
        ["D"]   = Block:newInstance(chestItemName, 0, 1),
        ["?"]   = Block:newInstance(Block.AnyBlockName()),
        [" "]   = Block:newInstance(Block.NoneBlockName()),
    }),
    CodeMap:newInstance({
        [6] = "C D  T",
        [5] = "    T ",
        [4] = "   T  ",
        [3] = "??T   ",
        [2] = " T    ",
        [1] = "T    D",
    })
) assert(testBuildLayer_Down, "Failed obtaining testBuildLayer_Down")

local testBuildLayer_Front = LayerRectangle:newInstance(
    ObjTable:newInstance(Block:getClassName(), {
        ["T"]   = Block:newInstance(torchItemName),
        ["C"]   = Block:newInstance(chestItemName),
        ["S"]   = Block:newInstance(saplingItemName),
        ["M"]   = Block:newInstance("computercraft:monitor_normal"),
        ["?"]   = Block:newInstance(Block.AnyBlockName()),
        [" "]   = Block:newInstance(Block.NoneBlockName()),
    }),
    CodeMap:newInstance({
        [4] = " M M?",
        [3] = " M C?",
        [2] = " M   ",
        [1] = "   ST",
    })
    -- note: directional block placement is a bit tricky, see https://github.com/cc-tweaked/CC-Tweaked/issues/204 for the algorithm
) assert(testBuildLayer_Front, "Failed obtaining testBuildLayer_Front")

local compact = { compact = true }

function t_builder.T_BuildLayer_MetaData()
    -- prepare test
    corelog.WriteToLog("* role_builder.BuildLayer_MetaData() tests")
    local buildDirection = "Down"
    local buildData = {
        startpoint      = testStartLocation_Down,
        buildDirection  = buildDirection,
        layer           = testBuildLayer1
    }

    -- test Down
    local metaData = role_builder.BuildLayer_MetaData(buildData) assert(metaData, "Failed obtaining metaData")
    local expectedLocation = testStartLocation_Down:getLocationUp()
    assert(metaData.location:isEqual(expectedLocation), "gotten location(="..textutils.serialize(metaData.location, compact)..") not the same as expected(="..textutils.serialize(expectedLocation, compact)..")")
    assert(metaData.needTool, "gotten needTool(="..tostring(metaData.needTool)..") not the same as expected(=true)")
    assert(metaData.needTurtle, "gotten needTurtle(="..tostring(metaData.needTurtle)..") not the same as expected(=true)")
    local expectedFuelNeeded = size_x1*size_y1 - 1
    assert(metaData.fuelNeeded == expectedFuelNeeded, "gotten fuelNeeded(="..metaData.fuelNeeded..") not the same as expected(="..expectedFuelNeeded..")")
    assert(metaData.itemsNeeded[chestItemName] == 1, "gotten itemCount(="..metaData.itemsNeeded[chestItemName]..") for "..chestItemName.."'s not the same as expected(=1)")
    assert(metaData.itemsNeeded[torchItemName] == 2, "gotten itemCount(="..metaData.itemsNeeded[torchItemName]..") for "..torchItemName.."'s not the same as expected(=2)")

    -- test Up
    buildData.buildDirection = "Up"
    metaData = role_builder.BuildLayer_MetaData(buildData) assert(metaData, "Failed obtaining metaData")
    expectedLocation = testStartLocation_Down:getLocationDown()
    assert(metaData.location:isEqual(expectedLocation), "gotten location(="..textutils.serialize(metaData.location, compact)..") not the same as expected(="..textutils.serialize(expectedLocation, compact)..")")

    -- test Front
    buildData.buildDirection = "Front"
    metaData = role_builder.BuildLayer_MetaData(buildData) assert(metaData, "Failed obtaining metaData")
    expectedLocation = testStartLocation_Down:getLocationFront(-1)
    assert(metaData.location:isEqual(expectedLocation), "gotten location(="..textutils.serialize(metaData.location, compact)..") not the same as expected(="..textutils.serialize(expectedLocation, compact)..")")

    -- cleanup test
end

function t_builder.T_BuildBlueprint_MetaData()
    -- prepare test
    corelog.WriteToLog("* role_builder BuildBlueprint_MetaData test")
    local testBlueprint = {
        layerList = {
            { startpoint = Location:newInstance(0, 0, 0), buildDirection = "Down", layer = testBuildLayer1:copy()},
            { startpoint = Location:newInstance(3, 3, -1), buildDirection = "Up", layer = testBuildLayer_Up:copy()},
        },
        escapeSequence = {
            Location:newInstance(3, 3, 1),
        }
    }
    local blueprintBuildData = {blueprintStartpoint = testStartLocation_Down:getRelativeLocation(6, 0, 0), blueprint = testBlueprint}

    -- test
    local metaData = role_builder.BuildBlueprint_MetaData(blueprintBuildData)
    local expectedLocation = testStartLocation_Down:getRelativeLocation(6, 0, 0)
    assert(metaData.location:isEqual(expectedLocation), "gotten location(="..textutils.serialize(metaData.location, compact)..") not the same as expected(="..textutils.serialize(expectedLocation, compact)..")")
    assert(metaData.needTool, "gotten needTool(="..tostring(metaData.needTool)..") not the same as expected(=true)")
    assert(metaData.needTurtle, "gotten needTurtle(="..tostring(metaData.needTurtle)..") not the same as expected(=true)")
    local expectedFuelNeeded = 47
    assert(metaData.fuelNeeded == expectedFuelNeeded, "gotten fuelNeeded(="..metaData.fuelNeeded..") not the same as expected(="..expectedFuelNeeded..")")
    assert(metaData.itemsNeeded[chestItemName] == 9, "gotten itemCount(="..metaData.itemsNeeded[chestItemName]..") for "..chestItemName.."'s not the same as expected(=9)")
    assert(metaData.itemsNeeded[torchItemName] == 2, "gotten itemCount(="..metaData.itemsNeeded[torchItemName]..") for "..torchItemName.."'s not the same as expected(=2)")

    -- cleanup test
end

function t_builder.pt_BuildLayer_Task(startpoint, buildDirection, layer)
    -- prepare test
    assert(startpoint, "no startpoint provided")
    assert(buildDirection, "no buildDirection provided")
    assert(layer, "no layer provided")
    corelog.WriteToLog("* role_builder.BuildLayer_Task() test ("..buildDirection..")")
    local buildData = {
        startpoint              = startpoint:copy(),
        buildDirection          = buildDirection,
        replacePresentObjects   = false,
        layer                   = layer:copy()
    }

    -- test
    role_builder.BuildLayer_Task(buildData)

    -- cleanup test
end

function t_builder.T_BuildLayer_Task_Down()
    -- prepare test

    -- test
    t_builder.pt_BuildLayer_Task(testStartLocation_Down, "Down", testBuildLayer_Down)

    -- cleanup test
end

function t_builder.T_BuildLayer_Task_Up()
    -- prepare test

    -- test
    t_builder.pt_BuildLayer_Task(testStartLocation_Up, "Up", testBuildLayer_Up)

    -- cleanup test
end

function t_builder.T_BuildLayer_Task_Front()
    -- prepare test

    -- test
    t_builder.pt_BuildLayer_Task(testStartLocation_Front, "Front", testBuildLayer_Front)

    -- cleanup test
end
--[[
local role_forester = require "role_forester"
function t_builder.T_MoveCallback()
    role_forester.TestMoveCallback()
end
]]
return t_builder
