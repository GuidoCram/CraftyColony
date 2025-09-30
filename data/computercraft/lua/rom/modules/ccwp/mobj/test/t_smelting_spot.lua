local T_SmeltingSpot = {}

local corelog = require "corelog"
local coreutils = require "coreutils"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local Location = require "obj_location"

local SmeltingSpot = require "smelting_spot"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"
local T_ILObj = require "test.t_i_lobj"

function T_SmeltingSpot.T_All()
    -- initialisation
    T_SmeltingSpot.T__init()
    T_SmeltingSpot.T_new()
    T_SmeltingSpot.T_Getters()

    -- IObj
    T_SmeltingSpot.T_IObj_All()

    -- ILObj
    T_SmeltingSpot.T_ILObj_All()

    -- SmeltingSpot
    T_SmeltingSpot.T_getFuelNeed_Production_Att()
end

function T_SmeltingSpot.T_AllPhysical()
end

local testClassName = "SmeltingSpot"
local testObjName = "smeltingSpot"
local testObjName0 = testObjName.."0"

local logOk = false

local baseLocation0  = Location:newInstance(-6, 0, 1, 0, 1)

local constructParameters0 = {
    baseLocation    = baseLocation0,
}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_SmeltingSpot.CreateTestObj(id, baseLocation)
    -- check input
    id = id or coreutils.NewId()
    baseLocation = baseLocation or baseLocation0

    -- create testObj
    local testObj = SmeltingSpot:newInstance(id, baseLocation:copy())

    -- end
    return testObj
end

function T_SmeltingSpot.CreateInitialisedTest(id, baseLocation)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string")
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation)
    )

    -- end
    return test
end

function T_SmeltingSpot.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_SmeltingSpot.CreateTestObj(id, baseLocation0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_SmeltingSpot.CreateInitialisedTest(id, baseLocation0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_SmeltingSpot.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = SmeltingSpot:new({
        _id             = id,

        _baseLocation   = baseLocation0:copy(),
    })
    local test = T_SmeltingSpot.CreateInitialisedTest(id, baseLocation0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_SmeltingSpot.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." base getter tests")
    local id = coreutils.NewId()
    local obj = T_SmeltingSpot.CreateTestObj(id, baseLocation0) assert(obj, "Failed obtaining "..testClassName)

    -- test
    local test = TestArrayTest:newInstance(
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

function T_SmeltingSpot.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_SmeltingSpot.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_SmeltingSpot.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

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

function T_SmeltingSpot.T_ILObj_All()
    -- prepare tests
    local destructFieldsTest = TestArrayTest:newInstance()

    local fieldsTest0 = T_SmeltingSpot.CreateInitialisedTest(nil, baseLocation0)

    -- test cases
    T_ILObj.pt_all(testClassName, SmeltingSpot, {
        {
            objName             = testObjName0,
            constructParameters = constructParameters0,
            constructFieldsTest = fieldsTest0,
            destructFieldsTest  = destructFieldsTest
        },
    }, logOk)

    -- cleanup test
end

--    _____               _            _   _              _____             _
--   |  __ \             | |          | | (_)            / ____|           | |
--   | |__) | __ ___   __| |_   _  ___| |_ _  ___  _ __ | (___  _ __   ___ | |_
--   |  ___/ '__/ _ \ / _` | | | |/ __| __| |/ _ \| '_ \ \___ \| '_ \ / _ \| __|
--   | |   | | | (_) | (_| | |_| | (__| |_| | (_) | | | |____) | |_) | (_) | |_
--   |_|   |_|  \___/ \__,_|\__,_|\___|\__|_|\___/|_| |_|_____/| .__/ \___/ \__|
--                                                             | |
--                                                             |_|

function T_SmeltingSpot.T_getFuelNeed_Production_Att()
    -- prepare test smelting
    corelog.WriteToLog("* "..testClassName..":getFuelNeed_Production_Att() test")
    local objSmelt = T_SmeltingSpot.CreateTestObj() assert(objSmelt, "Failed obtaining "..testClassName)
    local smeltItems = { ["minecraft:charcoal"] = 8 }

    -- test smelting
    local fuelNeed = objSmelt:getFuelNeed_Production_Att(smeltItems)
    local expectedFuelNeed = 4 + 4
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") not the same as expected(="..expectedFuelNeed..")")

    -- cleanup test
end

return T_SmeltingSpot
