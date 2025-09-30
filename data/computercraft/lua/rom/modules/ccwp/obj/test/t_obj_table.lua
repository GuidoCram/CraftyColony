local T_ObjTable = {}

local corelog = require "corelog"

local Class = require "class"
local IObj = require "i_obj"
local ObjBase = require "obj_base"
local ObjTable = require "obj_table"
local ObjTest = require "test.obj_test"
local Location = require "obj_location"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_ObjTable.T_All()
    -- initialisation
    T_ObjTable.T__init()
    T_ObjTable.T_new()

    -- IObj
    T_ObjTable.T_IObj_All()

    -- specific
    T_ObjTable.T_nObjs()
    T_ObjTable.T_verifyObjsOfCorrectType()
    T_ObjTable.T_transformObjectTables()
    T_ObjTable.T_new_transformsObjTables()
end

local testClassName = "ObjTable"
local logOk = false
local objClassName1 = "ObjTest"
local testObj1 = ObjTest:newInstance("field1_1", 1)
local testObj2 = ObjTest:newInstance("field1_2", 2)
local wrongTestObj1 = Location:newInstance()

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_ObjTable.CreateTestObj(objClassName, objsTable)
    -- check input
    objClassName = objClassName or objClassName1
    objsTable = objsTable or {
        testObj1Key = testObj1:copy(),
        testObj2Key = testObj2:copy(),
    }

    -- create testObj
    local testObj = ObjTable:newInstance(objClassName, objsTable)

    -- end
    return testObj
end

function T_ObjTable.CreateInitialisedTest(objClassName, objsTable)
    -- check input

    -- create test
    local test = TestArrayTest:newInstance(
        FieldValueEqualTest:newInstance("_objClassName", objClassName)
    )
    for key, obj in pairs(objsTable) do
        table.insert(test._tests, FieldValueEqualTest:newInstance(key, obj))
    end

    -- end
    return test
end

function T_ObjTable.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local objsTable = {
        testObj1Key = testObj1:copy(),
        testObj2Key = testObj2:copy(),
    }

    -- test
    local obj = T_ObjTable.CreateTestObj(objClassName1, objsTable) assert(obj, "Failed obtaining "..testClassName)
    local test = T_ObjTable.CreateInitialisedTest(objClassName1, objsTable)
    test:test(obj, "objTable", "", logOk)

    -- test default
    obj = ObjTable:newInstance()
    test = T_ObjTable.CreateInitialisedTest("", {})
    test:test(obj, "objTable", "", logOk)

    -- cleanup test
end

function T_ObjTable.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local objsTable = {
        testObj1Key = testObj1:copy(),
        testObj2Key = testObj2:copy(),
    }

    -- test full
    local obj = ObjTable:new({
        _objClassName   = objClassName1,

        testObj1Key     = testObj1,
        testObj2Key     = testObj2,
    }) assert(obj, "Failed obtaining objTable")
    local test = T_ObjTable.CreateInitialisedTest(objClassName1, objsTable)
    test:test(obj, "objTable", "", logOk)

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

function T_ObjTable.T_IObj_All()
    -- prepare test
    local obj = T_ObjTable.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_ObjTable.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

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

function T_ObjTable.T_nObjs()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":nObjs() tests")
    local objsTable = {
        testObj1Key = testObj1:copy(),
        testObj2Key = testObj2:copy(),
    }
    local obj = T_ObjTable.CreateTestObj(objClassName1, objsTable) assert(obj, "Failed obtaining "..testClassName)

    -- test
    local expectedNElements = 2
    local nObjs = obj:nObjs()
    assert(nObjs == expectedNElements, " # elements(="..nObjs..") not the same as expected(="..expectedNElements..")")

    -- cleanup test
end

function T_ObjTable.T_verifyObjsOfCorrectType()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":verifyObjsOfCorrectType() tests")
    local objsTable = {
        testObj1Key = testObj1:copy(),
        testObj2Key = testObj2:copy(),
    }
    local obj = T_ObjTable.CreateTestObj(objClassName1, objsTable) assert(obj, "Failed obtaining "..testClassName)

    -- test with correct objs
    local objsOfCorrectType = obj:verifyObjsOfCorrectType()
    assert(objsOfCorrectType, "Unexpectedly not all objects of correct type")

    -- test with incorrect obj
    obj.testObj3Key = wrongTestObj1
    objsOfCorrectType = obj:verifyObjsOfCorrectType(true)
    assert(not objsOfCorrectType, "Unexpectedly all objects assumed to be of correct type")

    -- cleanup test
end

function T_ObjTable.T_transformObjectTables()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":transformObjectTables() tests")
    local obj = ObjTable:newInstance(objClassName1) assert(obj, "Failed obtaining "..testClassName)
    local testObject1Table = {
        _field1 = "field1_1",
        _field2 = 1,
    }
    local testObject2Table = {
        _field1 = "field1_2",
        _field2 = 2,
    }
    assert(not Class.IsInstanceOf(testObject1Table, ObjTest), "testObject1Table incorrectly of type "..objClassName1)
    assert(not Class.IsInstanceOf(testObject2Table, ObjTest), "testObject2Table incorrectly of type "..objClassName1)

    -- test already only Obj's (nothing should change)
    obj.testObj1Key = testObj1
    obj.testObj2Key = testObj2
    obj:transformObjectTables()
    local expectedNElements = 2
    assert(obj:nObjs() == expectedNElements, " # elements(="..obj:nObjs()..") not the same as expected(="..expectedNElements..")")
    assert(obj.testObj1Key:isEqual(testObj1), "obj 1 in array(="..textutils.serialise(obj.testObj1Key, compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(obj.testObj2Key:isEqual(testObj2), "obj 2 in array(="..textutils.serialise(obj.testObj2Key, compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")
    obj.testObj1Key = nil
    obj.testObj2Key = nil

    -- test different class Obj skipped
    obj.testObj1Key = testObj1
    obj.testObj3Key = wrongTestObj1
    obj.testObj2Key = testObj2
    obj:transformObjectTables(true)
    expectedNElements = 2
    assert(obj:nObjs() == expectedNElements, " # elements(="..obj:nObjs()..") not the same as expected(="..expectedNElements..")")
    assert(obj.testObj1Key:isEqual(testObj1), "obj 1 in array(="..textutils.serialise(obj.testObj1Key, compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(obj.testObj2Key:isEqual(testObj2), "obj 2 in array(="..textutils.serialise(obj.testObj2Key, compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")
    obj.testObj1Key = nil
    obj.testObj2Key = nil
    obj.testObj3Key = nil

    -- test only object tables
    obj.testObj1Key = testObject1Table
    obj.testObj2Key = testObject2Table
    obj:transformObjectTables()
    assert(obj.testObj1Key:isEqual(testObj1), "obj 1 in array(="..textutils.serialise(obj.testObj1Key, compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(obj.testObj2Key:isEqual(testObj2), "obj 2 in array(="..textutils.serialise(obj.testObj2Key, compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")
    obj.testObj1Key = nil
    obj.testObj2Key = nil

    -- test mix ObjTables and Obj's
    testObject2Table = {
        _field1 = "field1_2",
        _field2 = 2,
    }
    assert(not Class.IsInstanceOf(testObject2Table, ObjTest), "testObject2Table incorrectly of type "..objClassName1)

    obj.testObj1Key = testObj1
    obj.testObj2Key = testObject2Table
    obj:transformObjectTables()
    assert(obj.testObj1Key:isEqual(testObj1), "obj 1 in array(="..textutils.serialise(obj.testObj1Key, compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(obj.testObj2Key:isEqual(testObj2), "obj 2 in array(="..textutils.serialise(obj.testObj2Key, compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")
    obj.testObj1Key = nil
    obj.testObj2Key = nil

    -- cleanup test
end

function T_ObjTable.T_new_transformsObjTables()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() transforms objTables tests")
    local testObject1Table = {
        _field1 = "field1_1",
        _field2 = 1,
    }
    local testObject2Table = {
        _field1 = "field1_2",
        _field2 = 2,
    }

    -- test new transforms objTables
    local obj = ObjTable:new({
        _objClassName   = objClassName1,

        testObj1        = testObject1Table,
        testObj2        = testObject2Table,
    }) assert(obj, "Failed obtaining "..testClassName)
    assert(obj:getObjClassName() == objClassName1, "gotten getObjClassName(="..obj:getObjClassName()..") not the same as expected(="..objClassName1..")")
    local expectedNElements = 2
    assert(obj:nObjs() == expectedNElements, " # elements(="..obj:nObjs()..") not the same as expected(="..expectedNElements..")")
    local objClass = obj:getObjClass()
    assert(Class.IsInstanceOf(obj.testObj1, objClass), "obj 1 in ObjTable(="..textutils.serialise(obj.testObj1, compact)..") not of type "..objClassName1)
    assert(Class.IsInstanceOf(obj.testObj2, objClass), "obj 2 in ObjTable(="..textutils.serialise(obj.testObj2, compact)..") not of type "..objClassName1)

    -- cleanup test
end

return T_ObjTable
