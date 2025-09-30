local T_LayerRectangle = {}
local corelog = require "corelog"

local Class = require "class"
local IObj = require "i_obj"
local ObjBase = require "obj_base"
local ObjTable = require "obj_table"
local Block = require "obj_block"
local CodeMap = require "obj_code_map"
local LayerRectangle = require "obj_layer_rectangle"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_LayerRectangle.T_All()
    -- initialisation
    T_LayerRectangle.T__init()
    T_LayerRectangle.T_new()

    -- IObj
    T_LayerRectangle.T_IObj_All()

    -- specific
    T_LayerRectangle.T_getBlock()
    T_LayerRectangle.T_itemsNeeded()
    T_LayerRectangle.T_transformToLayer()
    T_LayerRectangle.T_cleanCodeTable()
    T_LayerRectangle.T_buildData()
end

local testClassName = "LayerRectangle"
local logOk = false

local torchItemName = "minecraft:torch"
local saplingItemName = "minecraft:birch_sapling"
local chestItemName = "minecraft:chest"
local computerItemName = "computercraft:computer_normal"
local codeTable1 = ObjTable:newInstance(Block:getClassName(), {
    ["T"]   = Block:newInstance(torchItemName),
    ["S"]   = Block:newInstance(saplingItemName),
    ["C"]   = Block:newInstance(chestItemName, -1, 0),
    ["D"]   = Block:newInstance(chestItemName, 0, 1),
    ["K"]   = Block:newInstance(computerItemName),
    ["?"]   = Block:newInstance(Block.AnyBlockName()),
    [" "]   = Block:newInstance(Block.NoneBlockName()),
})
local codeMap1 = CodeMap:newInstance({
    [6] = "CD   ?",
    [5] = "      ",
    [4] = "T  S  ",
    [3] = "  ?   ",
    [2] = "   K  ",
    [1] = "   T  ",
}) assert(codeMap1, "Failed obtaining codeMap1")
local layer1 = LayerRectangle:newInstance(codeTable1:copy(), codeMap1) assert(layer1, "Failed obtaining layer1")

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_LayerRectangle.CreateTestObj(codeTable, codeMap)
    -- check input
    codeTable = codeTable or codeTable1:copy()
    codeMap = codeMap or codeMap1:copy()

    -- create testObj
    local testObj = LayerRectangle:newInstance(codeTable, codeMap)

    -- end
    return testObj
end

function T_LayerRectangle.CreateInitialisedTest(codeTable, codeMap)
    -- check input

    -- create test
    local test = TestArrayTest:newInstance(
        FieldValueEqualTest:newInstance("_codeTable", codeTable),
        FieldValueEqualTest:newInstance("_codeMap", codeMap)
    )

    -- end
    return test
end

function T_LayerRectangle.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")

    -- test
    local obj = T_LayerRectangle.CreateTestObj(codeTable1, codeMap1) assert(obj, "Failed obtaining "..testClassName)
    local test = T_LayerRectangle.CreateInitialisedTest(codeTable1, codeMap1)
    test:test(obj, "layer", "", logOk)

    -- note: no default test

    -- cleanup test
end

function T_LayerRectangle.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test full
    local layer = LayerRectangle:new({
        _codeTable  = codeTable1:copy(),
        _codeMap    = codeMap1:copy(),
    }) assert(layer, "Failed obtaining "..testClassName)
    local test = T_LayerRectangle.CreateInitialisedTest(codeTable1, codeMap1)
    test:test(layer, "location", "", logOk)

    -- cleanup test
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function T_LayerRectangle.T_IObj_All()
    -- prepare test
    local obj = T_LayerRectangle.CreateTestObj() assert(obj, "failed obtaining "..testClassName)
    local otherObj = T_LayerRectangle.CreateTestObj() assert(obj, "failed obtaining "..testClassName) assert(otherObj, "failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function T_LayerRectangle.T_getBlock()
    -- prepare test
    corelog.WriteToLog("* LayerRectangle:getBlock() tests")

    -- test full
    local layer = LayerRectangle:newInstance(codeTable1:copy(), codeMap1:copy()) assert(layer, "Failed obtaining layer")
    local block = layer:getBlock(4, 1)
    local expectedBlock = Block:newInstance(torchItemName)
    assert(block:isEqual(expectedBlock), "gotten block(="..textutils.serialize(block, compact)..") not the same as expected(="..textutils.serialize(expectedBlock, compact)..")")
    block = layer:getBlock(1, 4)
    expectedBlock = Block:newInstance(torchItemName)
    assert(block:isEqual(expectedBlock), "gotten block(="..textutils.serialize(block, compact)..") not the same as expected(="..textutils.serialize(expectedBlock, compact)..")")
    block = layer:getBlock(4, 4)
    expectedBlock = Block:newInstance(saplingItemName)
    assert(block:isEqual(expectedBlock), "gotten block(="..textutils.serialize(block, compact)..") not the same as expected(="..textutils.serialize(expectedBlock, compact)..")")
    block = layer:getBlock(1, 1)
    expectedBlock = Block:newInstance(Block.NoneBlockName())
    assert(block:isEqual(expectedBlock), "gotten block(="..textutils.serialize(block, compact)..") not the same as expected(="..textutils.serialize(expectedBlock, compact)..")")
    block = layer:getBlock(3, 3)
    expectedBlock = Block:newInstance(Block.AnyBlockName())
    assert(block:isEqual(expectedBlock), "gotten block(="..textutils.serialize(block, compact)..") not the same as expected(="..textutils.serialize(expectedBlock, compact)..")")
    block = layer:getBlock(1, 6)
    expectedBlock = Block:newInstance(chestItemName, -1, 0)
    assert(block:isEqual(expectedBlock), "gotten block(="..textutils.serialize(block, compact)..") not the same as expected(="..textutils.serialize(expectedBlock, compact)..")")

    -- cleanup test
end

function T_LayerRectangle.T_itemsNeeded()
    -- prepare test
    corelog.WriteToLog("* LayerRectangle:itemsNeeded() tests")

    -- test
    local needed = layer1:itemsNeeded()
    local name = torchItemName
    local expectedCount = 2
    assert(needed[name] == expectedCount, "gotten count(="..(needed[name] or 0)..") for "..name.."'s not the same as expected(="..expectedCount..")")
    name = saplingItemName
    expectedCount = 1
    assert(needed[name] == expectedCount, "gotten count(="..(needed[name] or 0)..") for "..name.."'s not the same as expected(="..expectedCount..")")
    name = chestItemName
    expectedCount = 2
    assert(needed[name] == expectedCount, "gotten count(="..(needed[name] or 0)..") for "..name.."'s not the same as expected(="..expectedCount..")")
    name = Block.AnyBlockName()
    expectedCount = 0
    assert(not needed[name], "gotten count(="..(needed[name] or 0)..") for "..name.."'s not the same as expected(="..expectedCount..")")
    name = Block.NoneBlockName()
    expectedCount = 0
    assert(not needed[name], "gotten count(="..(needed[name] or 0)..") for "..name.."'s not the same as expected(="..expectedCount..")")

    -- cleanup test
end

function T_LayerRectangle.T_transformToLayer()
    -- prepare test
    corelog.WriteToLog("* LayerRectangle:transformToLayer() tests")
    local fromLayer = LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["S"]   = Block:newInstance(saplingItemName),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [6] = "   S  ",
            [5] = "      ",
            [4] = "   S  ",
            [3] = "   ?  ",
            [2] = "   ?  ",
            [1] = "   ?  ",
        })
    ) assert(fromLayer, "Failed obtaining layer")
    local toLayer = LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["T"]   = Block:newInstance(torchItemName),
            ["S"]   = Block:newInstance(saplingItemName),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [6] = "   ?  ",
            [5] = "      ",
            [4] = "T  S  ",
            [3] = "      ",
            [2] = "   ?  ",
            [1] = "   T  ",
        })
    ) assert(toLayer, "Failed obtaining layer")

    -- test
    local transformLayer = fromLayer:transformToLayer(toLayer)
    local isInstanceOf = Class.IsInstanceOf(transformLayer, LayerRectangle)
    local expectedIsInstanceOf = true
    assert(isInstanceOf, "gotten isInstanceOf(="..tostring(isInstanceOf)..") not the same as expected(="..tostring(expectedIsInstanceOf)..")")
    local expectedLayer = LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(),{
            ["T"]   = Block:newInstance(torchItemName),
            ["S"]   = Block:newInstance(saplingItemName),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [6] = "??????",
            [5] = "??????",
            [4] = "T?????",
            [3] = "??? ??",
            [2] = "??????",
            [1] = "???T??",
        })
    )
    assert(transformLayer:isEqual(expectedLayer), "gotten transformToLayer(="..textutils.serialize(transformLayer, compact)..") not the same as expected(="..textutils.serialize(expectedLayer, compact)..")")

    -- test anyBlock added to _codeTable
    toLayer = LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["T"]   = Block:newInstance(torchItemName),
            ["S"]   = Block:newInstance(saplingItemName),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [6] = "      ",
            [5] = "      ",
            [4] = "T  S  ",
            [3] = "      ",
            [2] = "      ",
            [1] = "   T  ",
        })
    )
    transformLayer = fromLayer:transformToLayer(toLayer)
    isInstanceOf = Class.IsInstanceOf(transformLayer, LayerRectangle)
    expectedIsInstanceOf = true
    assert(isInstanceOf, "gotten isInstanceOf(="..tostring(isInstanceOf)..") not the same as expected(="..tostring(expectedIsInstanceOf)..")")
    expectedLayer = LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["T"]   = Block:newInstance(torchItemName),
            ["S"]   = Block:newInstance(saplingItemName),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [6] = "??? ??",
            [5] = "??????",
            [4] = "T?????",
            [3] = "??? ??",
            [2] = "??? ??",
            [1] = "???T??",
        })
    )
    assert(transformLayer:isEqual(expectedLayer), "gotten transformToLayer(="..textutils.serialize(transformLayer, compact)..") not the same as expected(="..textutils.serialize(expectedLayer, compact)..")")

    -- cleanup test
end

function T_LayerRectangle.T_cleanCodeTable()
    -- prepare test
    corelog.WriteToLog("* LayerRectangle:cleanCodeTable() tests")
    local layer = LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["T"]   = Block:newInstance(torchItemName),
            ["S"]   = Block:newInstance(saplingItemName),
            ["C"]   = Block:newInstance(chestItemName, -1, 0),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [4] = "    ",
            [3] = "T   ",
            [2] = "    ",
            [1] = " T  ",
        })
    ) assert(layer, "Failed obtaining layer")

    -- test
    layer:cleanCodeTable()
    local expectedCodeTable  = ObjTable:newInstance(Block:getClassName(), {
        ["T"]   = Block:newInstance(torchItemName),
        [" "]   = Block:newInstance(Block.NoneBlockName()),
    })
    assert(layer._codeTable:isEqual(expectedCodeTable), "result codeTable(="..textutils.serialize(layer._codeTable, compact)..") not the same as expected(="..textutils.serialize(expectedCodeTable, compact)..")")

    -- cleanup test
end

function T_LayerRectangle.T_getCodeCol()
    -- prepare test
    corelog.WriteToLog("* LayerRectangle:getCodeCol() tests")

    -- test
    local column = layer1:getCodeCol(4)
    local expectedColumn = "TK S  "
    assert(column == expectedColumn, "gotten column(="..column..") not the same as expected(="..expectedColumn..")")

    -- cleanup test
end

function T_LayerRectangle.T_buildData()
    -- prepare test
    corelog.WriteToLog("* LayerRectangle:buildData() tests")

    -- test right
    local layer = LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["T"]   = Block:newInstance(torchItemName),
            ["C"]   = Block:newInstance(chestItemName, -1, 0),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [6] = "??????",
            [5] = "??????",
            [4] = "??TC ?",
            [3] = "?? C??",
            [2] = "??? T?",
            [1] = "??????",
        })
    ) assert(layer, "Failed obtaining layer")
    local colOffset, rowOffset, buildLayer = layer:buildData()
    local expectedOffset = 1
    assert(rowOffset == expectedOffset, "gotten rowOffset(="..tostring(colOffset)..") for not the same as expected(="..tostring(expectedOffset)..")")
    expectedOffset = 2
    assert(colOffset == expectedOffset, "gotten colOffset(="..tostring(colOffset)..") for not the same as expected(="..tostring(expectedOffset)..")")
    local expectedLayer = LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["T"]   = Block:newInstance(torchItemName),
            ["C"]   = Block:newInstance(chestItemName, -1, 0),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [3] = "TC ",
            [2] = " C?",
            [1] = "? T",
        })
    )
    assert(buildLayer:isEqual(expectedLayer), "result layer(="..textutils.serialize(layer, compact)..") for not the same as expected(="..textutils.serialize(expectedLayer, compact)..")")

    -- cleanup test
end

return T_LayerRectangle
