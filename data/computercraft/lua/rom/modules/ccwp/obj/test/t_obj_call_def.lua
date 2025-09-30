local T_CallDef = {}

local corelog = require "corelog"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local CallDef = require "obj_call_def"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_CallDef.T_All()
    -- initialisation
    T_CallDef.T__init()
    T_CallDef.T_new()

    -- IObj
    T_CallDef.T_IObj_All()

    -- specific
end

local testClassName = "CallDef"
local logOk = false
local moduleName1 = "T_CallDef"
local methodName1 = "Call_Callback"
local data1 = {"some obj data"}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_CallDef.CreateTestObj(moduleName, methodName, data)
    -- check input
    moduleName = moduleName or moduleName1
    methodName = methodName or methodName1
    data = data or {"some obj data"}

    -- create testObj
    local testObj = CallDef:newInstance(moduleName, methodName, data)

    -- end
    return testObj
end

function T_CallDef.CreateInitialisedTest(moduleName, methodName, data)
    -- check input

    -- create test
    local test = TestArrayTest:newInstance(
        FieldValueEqualTest:newInstance("_moduleName", moduleName),
        FieldValueEqualTest:newInstance("_methodName", methodName),
        FieldValueTypeTest:newInstance("_data", "table")
    )

    -- end
    return test
end

function T_CallDef.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")

    -- test
    local obj = T_CallDef.CreateTestObj(moduleName1, methodName1, data1) assert(obj, "Failed obtaining "..testClassName)
    local test = T_CallDef.CreateInitialisedTest(moduleName1, methodName1, data1)
    test:test(obj, "calldef", "", logOk)

    -- test default
    obj = CallDef:newInstance()
    test = T_CallDef.CreateInitialisedTest("", "", {})
    test:test(obj, "calldef", "", logOk)

    -- cleanup test
end

function T_CallDef.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test full
    local obj = CallDef:new({
        _moduleName     = moduleName1,
        _methodName     = methodName1,
        _data           = data1,
    })
    local test = T_CallDef.CreateInitialisedTest(moduleName1, methodName1, data1)
    test:test(obj, "calldef", "", logOk)

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

function T_CallDef.T_IObj_All()
    -- prepare test
    local obj = T_CallDef.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_CallDef.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

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

return T_CallDef
