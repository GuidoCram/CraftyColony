local T_MineShaft = {}

local corelog = require "corelog"
local coreutils = require "coreutils"

local IObj = require "i_obj"
local IItemSupplier = require "i_item_supplier"
local ObjBase = require "obj_base"
local Location = require "obj_location"

local MineShaft = require "mine_shaft"

local role_energizer = require "role_energizer"

local enterprise_gathering = require "enterprise_gathering"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"
local IsBlueprintTest = require "test.is_blueprint_test"

local T_IInterface = require "test.t_i_interface"
local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"
local T_ILObj = require "test.t_i_lobj"
local T_IMObj = require "test.t_i_mobj"
local T_IItemSupplier = require "test.t_i_item_supplier"

local enterprise_employment
local t_employment

function T_MineShaft.T_All()
    -- initialisation
    T_MineShaft.T__init()
    T_MineShaft.T_new()
    T_MineShaft.T_Getters()

    -- IObj
    T_MineShaft.T_IObj_All()

    -- ILObj
    T_MineShaft.T_ILObj_All()

    -- IMObj
    T_MineShaft.T_IMObj_All()

    -- IItemSupplier
    T_MineShaft.T_IItemSupplier_All()
end

function T_MineShaft.T_AllPhysical()
    -- IItemSupplier
    T_MineShaft.T_provideItemsTo_AOSrv_cobblestone_ToTurtle()
end

local testClassName = "MineShaft"
local testObjName = "mineShaft"
local testObjName0 = testObjName.."0"
local testHost = enterprise_gathering

local logOk = false

local baseLocation0 = Location:newInstance(0, -12, 1, 0, 1):getRelativeLocation(3, 3, 0)
local currentDepth0 = 2
local maxDepth0 = 37
local maxDepth1 = 48

local constructParameters0 = {
    baseLocation    = baseLocation0,
    maxDepth        = maxDepth0,
}

local upgradeParameters0 = {
    maxDepth        = maxDepth1,
}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_MineShaft.CreateTestObj(id, baseLocation, currentDepth, maxDepth)
    -- check input
    id = id or coreutils.NewId()
    baseLocation = baseLocation or baseLocation0
    currentDepth = currentDepth or currentDepth0
    maxDepth = maxDepth or maxDepth0

    -- create testObj
    local testObj = MineShaft:newInstance(id, baseLocation:copy(), currentDepth, maxDepth)

    -- end
    return testObj
end

function T_MineShaft.CreateInitialisedTest(id, baseLocation, currentDepth, maxDepth)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string") -- note: allow for testing only the type (instead of also the value)
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation),
        FieldValueEqualTest:newInstance("_currentDepth", currentDepth),
        FieldValueEqualTest:newInstance("_maxDepth", maxDepth)
    )

    -- end
    return test
end

function T_MineShaft.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_MineShaft.CreateTestObj(id, baseLocation0, currentDepth0, maxDepth0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_MineShaft.CreateInitialisedTest(id, baseLocation0, currentDepth0, maxDepth0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_MineShaft.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = MineShaft:new({
        _id                     = id,

        _baseLocation           = baseLocation0:copy(),
        _currentDepth           = currentDepth0,
        _maxDepth               = maxDepth0,
    })
    local test = T_MineShaft.CreateInitialisedTest(id, baseLocation0, currentDepth0, maxDepth0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_MineShaft.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." getter tests")
    local id = coreutils.NewId()
    local obj = T_MineShaft.CreateTestObj(id, baseLocation0, currentDepth0, maxDepth0) assert(obj, "Failed obtaining "..testClassName)

    -- test
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getCurrentDepth", currentDepth0),
        MethodResultEqualTest:newInstance("getMaxDepth", maxDepth0)
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

function T_MineShaft.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_MineShaft.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_MineShaft.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

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

function T_MineShaft.T_ILObj_All()
    -- prepare test
    local destructFieldsTest0 = TestArrayTest:newInstance()

    local fieldsTest0 = T_MineShaft.CreateInitialisedTest(nil, baseLocation0, 0, maxDepth0)
    local fieldsTest1 = T_MineShaft.CreateInitialisedTest(nil, baseLocation0, 0, maxDepth1)

    -- test cases
    T_ILObj.pt_all(testClassName, MineShaft, {
        {
            objName             = testObjName0,
            constructParameters = constructParameters0,
            constructFieldsTest = fieldsTest0,
            upgradeParameters   = upgradeParameters0,
            upgradeFieldsTest   = fieldsTest1,
            destructFieldsTest  = destructFieldsTest0,
        },
    }, logOk)

    -- cleanup test
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function T_MineShaft.T_IMObj_All()
    -- prepare test
    local isBlueprintTest = IsBlueprintTest:newInstance(baseLocation0)

    -- test cases
    T_IMObj.pt_all(testClassName, MineShaft, {
        {
            objName                 = testObjName0,
            constructParameters     = constructParameters0,
            constructBlueprintTest  = isBlueprintTest,
            upgradeParameters       = upgradeParameters0,
            upgradeBlueprintTest    = isBlueprintTest,
            dismantleBlueprintTest  = isBlueprintTest,
            expectedBaseLocation    = baseLocation0:copy()
        },
    }, logOk)
end

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

function T_MineShaft.T_IItemSupplier_All()
    -- prepare test
    local obj = T_MineShaft.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test type
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemSupplier", IItemSupplier)
    T_IInterface.pt_ImplementsInterface("IItemSupplier", IItemSupplier, testClassName, obj)

    -- test
    T_MineShaft.T_needsTo_ProvideItemsTo_SOSrv()
    T_MineShaft.T_can_ProvideItems_QOSrv()
end

function T_MineShaft.T_provideItemsTo_AOSrv_cobblestone_ToTurtle()
    -- prepare test
    local objLocator = testHost:hostLObj_SSrv({ className = testClassName, constructParameters = constructParameters0 }).mobjLocator assert(objLocator, "failed hosting "..testClassName.." on "..testHost:getHostName())
    local provideItems = { ["minecraft:cobblestone"] = 9 }

    t_employment = t_employment or require "test.t_employment"
    local itemDepotLocator = t_employment.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")
    local ingredientsItemSupplierLocator = t_employment.GetCurrentTurtleLocator() assert(ingredientsItemSupplierLocator, "Failed obtaining ingredientsItemSupplierLocator")
    local wasteItemDepotLocator = ingredientsItemSupplierLocator:copy()

    -- test
    T_IItemSupplier.pt_provideItemsTo_AOSrv(testClassName, objLocator, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, logOk)

    -- cleanup test
    testHost:releaseLObj_SSrv({ mobjLocator = objLocator})
end

function T_MineShaft.T_needsTo_ProvideItemsTo_SOSrv()
    -- prepare test
    local obj = T_MineShaft.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    local provideItems = {
        ["minecraft:cobblestone"]  = 9,
    }

    t_employment = t_employment or require "test.t_employment"
    local itemDepotLocator = t_employment.GetCurrentTurtleLocator()
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local turtleObj = enterprise_employment:getObj(itemDepotLocator) assert(turtleObj, "Failed obtaining turtleObj")
    local destinationLocation = turtleObj:getItemDepotLocation()

    -- test
    local expectedFuelNeed = role_energizer.NeededFuelToFrom(destinationLocation, obj:getBaseLocation()) + 4 + 2*obj:getMaxDepth() + 4
    T_IItemSupplier.pt_needsTo_ProvideItemsTo_SOSrv(testClassName, obj, testObjName, provideItems, itemDepotLocator, nil, {
        success         = true,
        fuelNeed        = expectedFuelNeed,
        ingredientsNeed = {},
    }, logOk)

    -- cleanup test
end

function T_MineShaft.T_can_ProvideItems_QOSrv()
    -- prepare test
    local obj = T_MineShaft.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- tests
    T_IItemSupplier.pt_can_ProvideItems_QOSrv(testClassName, obj, testObjName, { ["minecraft:cobblestone"] = 9}, true, logOk)
    T_IItemSupplier.pt_can_ProvideItems_QOSrv(testClassName, obj, testObjName, { ["minecraft:coal_ore"] = 2}, true, logOk)
    T_IItemSupplier.pt_can_ProvideItems_QOSrv(testClassName, obj, testObjName, { ["unknown"] = 10}, false, logOk)

    -- cleanup test
end

return T_MineShaft
