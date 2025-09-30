local T_Settlement = {}
local corelog = require "corelog"
local coreutils = require "coreutils"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local ObjLocator = require "obj_locator"

local Settlement = require "settlement"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"

local T_ILObj = require "test.t_i_lobj"

function T_Settlement.T_All()
    -- initialisation
    T_Settlement.T__init()
    T_Settlement.T_new()
    T_Settlement.T_Getters()

    -- IObj
    T_Settlement.T_IObj_All()

    -- ILObj
    T_Settlement.T_ILObj_All()
end

function T_Settlement.T_AllPhysical()
end

local testClassName = "Settlement"
local testObjName = "settlement0"
local testHostName = "enterprise_colonization"

local logOk = false

local mainShopLocator0 = ObjLocator:newInstance(testHostName, "Shop")

local constructParameters0 = {
}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_Settlement.CreateTestObj(id, mainShopLocator)
    -- check input
    id = id or coreutils.NewId()
    mainShopLocator = mainShopLocator or mainShopLocator0

    -- create testObj
    local testObj = Settlement:newInstance(id, mainShopLocator:copy())

    -- end
    return testObj
end

function T_Settlement.CreateInitialisedTest(id, mainShopLocator)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string") -- note: allow for testing only the type (instead of also the value)
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local mainShopLocatorTest = FieldValueTypeTest:newInstance("_mainShopLocator", "ObjLocator")
    if id then mainShopLocatorTest = FieldValueEqualTest:newInstance("_mainShopLocator", mainShopLocator) end
    local test = TestArrayTest:newInstance(
        idTest,
        mainShopLocatorTest
    )

    -- end
    return test
end

function T_Settlement.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_Settlement.CreateTestObj(id, mainShopLocator0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_Settlement.CreateInitialisedTest(id, mainShopLocator0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_Settlement.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = Settlement:new({
        _id                     = id,

        _mainShopLocator        = mainShopLocator0:copy(),
    })
    local test = T_Settlement.CreateInitialisedTest(id, mainShopLocator0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_Settlement.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." getter tests")
    local id = coreutils.NewId()
    local obj = T_Settlement.CreateTestObj(id, mainShopLocator0) if not obj then corelog.Error("Failed obtaining "..testClassName) return end

    -- test
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getMainShopLocator", mainShopLocator0)
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

function T_Settlement.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_Settlement.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_Settlement.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

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

function T_Settlement.T_ILObj_All()
    -- prepare test
    local destructFieldsTest = TestArrayTest:newInstance()

    local fieldsTest1 = T_Settlement.CreateInitialisedTest(nil, nil)

    -- test cases
    T_ILObj.pt_all(testClassName, Settlement, {
        {
            objName             = testObjName,
            constructParameters = constructParameters0,
            constructFieldsTest = fieldsTest1,
            destructFieldsTest  = destructFieldsTest,
        },
    }, logOk)
end

--     _____      _   _   _                           _
--    / ____|    | | | | | |                         | |
--   | (___   ___| |_| |_| | ___ _ __ ___   ___ _ __ | |_
--    \___ \ / _ \ __| __| |/ _ \ '_ ` _ \ / _ \ '_ \| __|
--    ____) |  __/ |_| |_| |  __/ | | | | |  __/ | | | |_
--   |_____/ \___|\__|\__|_|\___|_| |_| |_|\___|_| |_|\__|

return T_Settlement
