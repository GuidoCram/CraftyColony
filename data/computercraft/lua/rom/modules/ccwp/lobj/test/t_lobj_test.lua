local T_LObjTest = {}
local corelog = require "corelog"
local coreutils = require "coreutils"

local IObj = require "i_obj"
local ObjBase = require "obj_base"

local LObjTest = require "test.lobj_test"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"
local T_ILObj = require "test.t_i_lobj"

function T_LObjTest.T_All()
    -- initialisation
    T_LObjTest.T__init()
    T_LObjTest.T_new()
    T_LObjTest.T_Getters()

    -- IObj
    T_LObjTest.T_IObj_All()

    -- ILObj
    T_LObjTest.T_ILObj_All()
end

local testClassName = "LObjTest"
local testObjName = "lobjTest"

local logOk = false

local field1_0 = "field1 0"
local field1_1 = "field1 1"

local constructParameters0 = {
    field1Value     = field1_0,
}
local upgradeParameters0 = {
    field1 = field1_1
}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_LObjTest.CreateTestObj(id, field1)
    -- check input
    id = id or coreutils.NewId()
    field1 = field1 or field1_0

    -- create testObj
    local testObj = LObjTest:newInstance(id, field1)

    -- end
    return testObj
end

function T_LObjTest.CreateInitialisedTest(id, field1)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string") -- note: allow for testing only the type (instead of also the value)
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_field1", field1)
    )

    -- end
    return test
end

function T_LObjTest.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_LObjTest.CreateTestObj(id, field1_0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_LObjTest.CreateInitialisedTest(id, field1_0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_LObjTest.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = LObjTest:new({
        _id             = id,

        _field1         = field1_0,
    })
    local test = T_LObjTest.CreateInitialisedTest(id, field1_0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_LObjTest.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." base getter tests")
    local id = coreutils.NewId()
    local obj = T_LObjTest.CreateTestObj(id, field1_0) assert(obj, "Failed obtaining "..testClassName)

    -- test
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getField1", field1_0)
    )
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

function T_LObjTest.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_LObjTest.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_LObjTest.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function T_LObjTest.T_ILObj_All()
    -- prepare test
    local destructFieldsTest = TestArrayTest:newInstance()

    local constructFieldsTest = T_LObjTest.CreateInitialisedTest(nil, field1_0)

    local upgradeFieldsTest = T_LObjTest.CreateInitialisedTest(nil, field1_1)

    -- test cases
    T_ILObj.pt_all(testClassName, LObjTest, {
        {
            objName             = testObjName,
            constructParameters = constructParameters0,
            constructFieldsTest = constructFieldsTest,
            destructFieldsTest  = destructFieldsTest,
            upgradeParameters   = upgradeParameters0,
            upgradeFieldsTest   = upgradeFieldsTest,
        },
    }, logOk)
end

return T_LObjTest
