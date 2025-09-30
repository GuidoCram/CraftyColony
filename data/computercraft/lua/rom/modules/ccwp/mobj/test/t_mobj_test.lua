local T_MObjTest = {}
local corelog = require "corelog"
local coreutils = require "coreutils"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local Location = require "obj_location"

local LObjTest = require "test.lobj_test"
local MObjTest = require "test.mobj_test"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"
local IsBlueprintTest = require "test.is_blueprint_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"
local T_IMObj = require "test.t_i_mobj"

function T_MObjTest.T_All()
    -- initialisation
    T_MObjTest.T__init()
    T_MObjTest.T_new()

    -- IObj
    T_MObjTest.T_IObj_All()

    -- ILObj
    T_MObjTest.T_ILObj_All()

    -- IMObj
    T_MObjTest.T_IMObj_All()
end

function T_MObjTest.T_AllPhysical()
end

local testClassName = "MObjTest"
local testObjName = "mobjTest"

local logOk = false

local baseLocation0  = Location:newInstance(-6, 0, 1, 0, 1)
local field1_0 = "field1 0"
local field1_1 = "field1 1"

local constructParameters0 = {
    baseLocation    = baseLocation0,
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

function T_MObjTest.CreateTestObj(id, baseLocation, field1)
    -- check input
    id = id or coreutils.NewId()
    baseLocation = baseLocation or baseLocation0
    field1 = field1 or field1_0

    -- create testObj
    local testObj = MObjTest:newInstance(id, baseLocation:copy(), field1)

    -- end
    return testObj
end

function T_MObjTest.CreateInitialisedTest(id, baseLocation, field1)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string") -- note: allow for testing only the type (instead of also the value)
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation),
        FieldValueEqualTest:newInstance("_field1", field1)
    )

    -- end
    return test
end

function T_MObjTest.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_MObjTest.CreateTestObj(id, baseLocation0, field1_0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_MObjTest.CreateInitialisedTest(id, baseLocation0, field1_0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_MObjTest.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = MObjTest:new({
        _id             = id,

        _baseLocation   = baseLocation0:copy(),
        _field1         = field1_0,
    })
    local test = T_MObjTest.CreateInitialisedTest(id, baseLocation0, field1_0)
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

function T_MObjTest.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_MObjTest.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_MObjTest.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

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

function T_MObjTest.T_ILObj_All()
    -- prepare test
    local obj = T_MObjTest.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "LObjTest", LObjTest)
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function T_MObjTest.T_IMObj_All()
    -- prepare test
    local isBlueprintTest = IsBlueprintTest:newInstance(baseLocation0)

    -- test cases
    T_IMObj.pt_all(testClassName, MObjTest, {
        {
            objName                 = testObjName,
            constructParameters     = constructParameters0,
            constructBlueprintTest  = isBlueprintTest,
            expectedBaseLocation    = baseLocation0:copy(),
            upgradeParameters       = upgradeParameters0,
            upgradeBlueprintTest    = isBlueprintTest,
            dismantleBlueprintTest  = isBlueprintTest,
        },
    }, logOk)
end

return T_MObjTest
