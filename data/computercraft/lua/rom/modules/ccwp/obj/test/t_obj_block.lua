local T_Block = {}
local corelog = require "corelog"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local Block = require "obj_block"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_Block.T_All()
    -- initialisation
    T_Block.T__init()
    T_Block.T_new()

    -- IObj
    T_Block.T_IObj_All()

    -- specific
    T_Block.T_isMinecraftItem()
    T_Block.T_isAnyBlock()
    T_Block.T_isNoneBlock()
    T_Block.T_isComputercraftItem()
    T_Block.T_hasValidDirection()
end

local testClassName = "Block"
local testObjName = "block"
local logOk = false
local dx1 = 0
local dy1 = 1
local saplingItemName = "minecraft:birch_sapling"
local computerItemName = "computercraft:computer_normal"

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_Block.CreateTestObj(blockName, dx, dy)
    -- check input
    blockName = blockName or saplingItemName
    dx = dx or dx1
    dy = dy or dy1

    -- create testObj
    local testObj = Block:newInstance(blockName, dx, dy)

    -- end
    return testObj
end

function T_Block.CreateInitialisedTest(blockName, dx, dy)
    -- check input

    -- create test
    local test = TestArrayTest:newInstance(
        FieldValueEqualTest:newInstance("_name", blockName),
        FieldValueEqualTest:newInstance("_dx", dx),
        FieldValueEqualTest:newInstance("_dy", dy)
    )

    -- end
    return test
end

function T_Block.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")

    -- test
    local obj = T_Block.CreateTestObj(saplingItemName, dx1, dy1) assert(obj, "Failed obtaining "..testClassName)
    local test = T_Block.CreateInitialisedTest(saplingItemName, dx1, dy1)
    test:test(obj, testObjName, "", logOk)

    -- test without orientations (i.e dx, dy)
    obj = Block:newInstance(saplingItemName)
    test = T_Block.CreateInitialisedTest(saplingItemName, 0, 0)
    test:test(obj, testObjName, "", logOk)

    -- test default
    obj = Block:newInstance()
    test = T_Block.CreateInitialisedTest("", 0, 0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_Block.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test full
    local obj = Block:new({
        _dx     = dx1,
        _dy     = dy1,

        _name   = saplingItemName,
    })
    local test = T_Block.CreateInitialisedTest(saplingItemName, dx1, dy1)
    test:test(obj, testObjName, "", logOk)

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

function T_Block.T_IObj_All()
    -- prepare test
    local obj = T_Block.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_Block.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

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

function T_Block.T_isMinecraftItem()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":isMinecraftItem() tests")
    local blockName = saplingItemName
    local obj = Block:newInstance(blockName, dx1, dy1)

    -- test minecraft item
    local isMinecraftItem = obj:isMinecraftItem()
    assert(isMinecraftItem, "gotten isMinecraftItem(="..tostring(isMinecraftItem)..") for "..blockName.." not the same as expected(true)")

    -- test blockNameAny
    blockName = Block.AnyBlockName()
    obj:setName(blockName)
    isMinecraftItem = obj:isMinecraftItem()
    assert(not isMinecraftItem, "gotten isMinecraftItem(="..tostring(isMinecraftItem)..") for "..blockName.." not the same as expected(false)")

    -- test blockNameNone
    blockName = Block.NoneBlockName()
    obj:setName(blockName)
    isMinecraftItem = obj:isMinecraftItem()
    assert(not isMinecraftItem, "gotten isMinecraftItem(="..tostring(isMinecraftItem)..") for "..blockName.." not the same as expected(false)")

    -- cleanup test
end

function T_Block.T_isAnyBlock()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":isAnyBlock() tests")
    local blockName = Block.AnyBlockName()
    local obj = Block:newInstance(blockName, dx1, dy1)

    -- test any Block
    local isAnyBlock = obj:isAnyBlock()
    assert(isAnyBlock, "gotten isAnyBlock(="..tostring(isAnyBlock)..") for "..blockName.." not the same as expected(true)")

    -- test not any Block
    blockName = saplingItemName
    obj:setName(blockName)
    isAnyBlock = obj:isAnyBlock()
    assert(not isAnyBlock, "gotten isAnyBlock(="..tostring(isAnyBlock)..") for "..blockName.." not the same as expected(false)")

    -- cleanup test
end

function T_Block.T_isNoneBlock()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":isNoneBlock() tests")
    local blockName = Block.NoneBlockName()
    local obj = Block:newInstance(blockName, dx1, dy1)

    -- test any Block
    local isNoneBlock = obj:isNoneBlock()
    assert(isNoneBlock, "gotten isNoneBlock(="..tostring(isNoneBlock)..") for "..blockName.." not the same as expected(true)")

    -- test not any Block
    blockName = saplingItemName
    obj:setName(blockName)
    isNoneBlock = obj:isNoneBlock()
    assert(not isNoneBlock, "gotten isNoneBlock(="..tostring(isNoneBlock)..") for "..blockName.." not the same as expected(false)")

    -- cleanup test
end

function T_Block.T_isComputercraftItem()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":isComputercraftItem() tests")
    local blockName = computerItemName
    local obj = Block:newInstance(blockName, dx1, dy1)

    -- test computercraft item
    local isComputercraftItem = obj:isComputercraftItem()
    assert(isComputercraftItem, "gotten isComputercraftItem(="..tostring(isComputercraftItem)..") for "..blockName.." not the same as expected(true)")

    -- test blockNameAny
    blockName = Block.AnyBlockName()
    obj:setName(blockName)
    isComputercraftItem = obj:isComputercraftItem()
    assert(not isComputercraftItem, "gotten isComputercraftItem(="..tostring(isComputercraftItem)..") for "..blockName.." not the same as expected(false)")

    -- test blockNameNone
    blockName = Block.NoneBlockName()
    obj:setName(blockName)
    isComputercraftItem = obj:isComputercraftItem()
    assert(not isComputercraftItem, "gotten isComputercraftItem(="..tostring(isComputercraftItem)..") for "..blockName.." not the same as expected(false)")

    -- cleanup test
end

function T_Block.T_hasValidDirection()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":hasValidDirection() tests")
    local blockName = saplingItemName
    local obj = Block:newInstance(blockName)

    -- test default (0,0)
    local expectedDirectionValid = false
    local directionValid = obj:hasValidDirection()
    assert(directionValid == expectedDirectionValid, "gotten hasValidDirection(="..tostring(directionValid)..") for "..blockName.." not the same as expected("..tostring(expectedDirectionValid)..")")

    -- test (0,1)
    expectedDirectionValid = true
    obj._dx = 0
    obj._dy = 1
    directionValid = obj:hasValidDirection()
    assert(directionValid == expectedDirectionValid, "gotten hasValidDirection(="..tostring(directionValid)..") for "..blockName.." not the same as expected("..tostring(expectedDirectionValid)..")")

    -- test (0,-1)
    expectedDirectionValid = true
    obj._dx = 0
    obj._dy = -1
    directionValid = obj:hasValidDirection()
    assert(directionValid == expectedDirectionValid, "gotten hasValidDirection(="..tostring(directionValid)..") for "..blockName.." not the same as expected("..tostring(expectedDirectionValid)..")")

    -- test (1,0)
    expectedDirectionValid = true
    obj._dx = 1
    obj._dy = 0
    directionValid = obj:hasValidDirection()
    assert(directionValid == expectedDirectionValid, "gotten hasValidDirection(="..tostring(directionValid)..") for "..blockName.." not the same as expected("..tostring(expectedDirectionValid)..")")

    -- test (-1,0)
    expectedDirectionValid = true
    obj._dx = -1
    obj._dy = 0
    directionValid = obj:hasValidDirection()
    assert(directionValid == expectedDirectionValid, "gotten hasValidDirection(="..tostring(directionValid)..") for "..blockName.." not the same as expected("..tostring(expectedDirectionValid)..")")

    -- test (0,9)
    expectedDirectionValid = false
    obj._dx = 0
    obj._dy = 9
    directionValid = obj:hasValidDirection()
    assert(directionValid == expectedDirectionValid, "gotten hasValidDirection(="..tostring(directionValid)..") for "..blockName.." not the same as expected("..tostring(expectedDirectionValid)..")")

    -- test (9,0)
    expectedDirectionValid = false
    obj._dx = 9
    obj._dy = 0
    directionValid = obj:hasValidDirection()
    assert(directionValid == expectedDirectionValid, "gotten hasValidDirection(="..tostring(directionValid)..") for "..blockName.." not the same as expected("..tostring(expectedDirectionValid)..")")

    -- cleanup test
end

return T_Block
