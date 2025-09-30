local T_CraftingSpot = {}

local corelog = require "corelog"
local coreutils = require "coreutils"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local Location = require "obj_location"

local CraftingSpot = require "crafting_spot"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"
local T_ILObj = require "test.t_i_lobj"

function T_CraftingSpot.T_All()
    -- initialisation
    T_CraftingSpot.T__init()
    T_CraftingSpot.T_new()
    T_CraftingSpot.T_Getters()

    -- IObj
    T_CraftingSpot.T_IObj_All()

    -- ILObj
    T_CraftingSpot.T_ILObj_All()

    -- CraftingSpot
    T_CraftingSpot.T_getFuelNeed_Production_Att()
end

function T_CraftingSpot.T_AllPhysical()
end

local testClassName = "CraftingSpot"
local testObjName = "craftingSpot"
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

function T_CraftingSpot.CreateTestObj(id, baseLocation)
    -- check input
    id = id or coreutils.NewId()
    baseLocation = baseLocation or baseLocation0

    -- create testObj
    local testObj = CraftingSpot:newInstance(id, baseLocation:copy())

    -- end
    return testObj
end

function T_CraftingSpot.CreateInitialisedTest(id, baseLocation)
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

function T_CraftingSpot.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_CraftingSpot.CreateTestObj(id, baseLocation0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_CraftingSpot.CreateInitialisedTest(id, baseLocation0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_CraftingSpot.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = CraftingSpot:new({
        _id             = id,

        _baseLocation   = baseLocation0:copy(),
    })
    local test = T_CraftingSpot.CreateInitialisedTest(id, baseLocation0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_CraftingSpot.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." base getter tests")
    local id = coreutils.NewId()
    local obj = T_CraftingSpot.CreateTestObj(id, baseLocation0) assert(obj, "Failed obtaining "..testClassName)

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

function T_CraftingSpot.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_CraftingSpot.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_CraftingSpot.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

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

function T_CraftingSpot.T_ILObj_All()
    -- prepare tests
    local destructFieldsTest = TestArrayTest:newInstance()

    local fieldsTest0 = T_CraftingSpot.CreateInitialisedTest(nil, baseLocation0)

    -- test cases
    T_ILObj.pt_all(testClassName, CraftingSpot, {
        {
            objName             = testObjName0,
            constructParameters = constructParameters0,
            constructFieldsTest = fieldsTest0,
            destructFieldsTest  = destructFieldsTest
        },
    }, logOk)

    -- cleanup test
end

--     _____            __ _   _              _____             _
--    / ____|          / _| | (_)            / ____|           | |
--   | |     _ __ __ _| |_| |_ _ _ __   __ _| (___  _ __   ___ | |_
--   | |    | '__/ _` |  _| __| | '_ \ / _` |\___ \| '_ \ / _ \| __|
--   | |____| | | (_| | | | |_| | | | | (_| |____) | |_) | (_) | |_
--    \_____|_|  \__,_|_|  \__|_|_| |_|\__, |_____/| .__/ \___/ \__|
--                                      __/ |      | |
--                                     |___/       |_|

function T_CraftingSpot.T_getFuelNeed_Production_Att()
    -- prepare test crafting
    corelog.WriteToLog("* "..testClassName..":getFuelNeed_Production_Att() test")
    local objCraft = T_CraftingSpot.CreateTestObj() assert(objCraft, "Failed obtaining "..testClassName)
    local craftItems = { ["minecraft:birch_planks"] = 4 }

    -- test crafting
    local fuelNeed = objCraft:getFuelNeed_Production_Att(craftItems)
    local expectedFuelNeed = 0
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") not the same as expected(="..expectedFuelNeed..")")

    -- cleanup test
end

return T_CraftingSpot
