local T_MineLayer = {}

local corelog = require "corelog"
local coreutils = require "coreutils"

local IObj = require "i_obj"
local IItemSupplier = require "i_item_supplier"
local ObjBase = require "obj_base"
local Location = require "obj_location"
local ObjLocator = require "obj_locator"

local MineLayer = require "mine_layer"

local role_energizer = require "role_energizer"

local enterprise_employment = require "enterprise_employment"
local enterprise_gathering = require "enterprise_gathering"

local TestArrayTest = require "test_array_test"
local FieldTest = require "field_test"
local FieldValueEqualTest = require "field_value_equal_test"
local ValueTypeTest = require "value_type_test"
local FieldValueTypeTest = require "field_value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"
local IsBlueprintTest = require "test.is_blueprint_test"

local T_IInterface = require "test.t_i_interface"
local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"
local T_ILObj = require "test.t_i_lobj"
local T_IMObj = require "test.t_i_mobj"
local T_IItemSupplier = require "test.t_i_item_supplier"

local t_employment

function T_MineLayer.T_All()
    -- initialisation
    T_MineLayer.T__init()
    T_MineLayer.T_new()
    T_MineLayer.T_Getters()

    -- IObj
    T_MineLayer.T_IObj_All()

    -- ILObj
    T_MineLayer.T_ILObj_All()

    -- IMObj
    T_MineLayer.T_IMObj_All()

    -- IItemSupplier
    T_MineLayer.T_IItemSupplier_All()
end

function T_MineLayer.T_AllPhysical()
    -- IItemSupplier
    T_MineLayer.T_provideItemsTo_AOSrv_cobblestone_ToTurtle()
end

local testClassName = "MineLayer"
local testObjName = "mineLayer"
local testObjName0 = testObjName.."0"
local testHost = enterprise_gathering

local logOk = false

local baseLocation0 = Location:newInstance(0, -12, -36, 0, 1):getRelativeLocation(3, 3, 0)
local currentHalfRib0 = 3

local cacheItemsLocator0 = enterprise_employment.GetAnyTurtleLocator()
local cacheItemsLocatorTest0 = FieldValueEqualTest:newInstance("_cacheItemsLocator", cacheItemsLocator0)

local constructParameters0 = {
    baseLocation    = baseLocation0,
}

local upgradeParameters0 = {
}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_MineLayer.CreateTestObj(id, baseLocation, currentHalfRib, cacheItemsLocator)
    -- check input
    id = id or coreutils.NewId()
    baseLocation = baseLocation or baseLocation0
    currentHalfRib = currentHalfRib or currentHalfRib0
    cacheItemsLocator = cacheItemsLocator or cacheItemsLocator0

    -- create testObj
    local testObj = MineLayer:newInstance(id, baseLocation:copy(), currentHalfRib, cacheItemsLocator)

    -- end
    return testObj
end

function T_MineLayer.CreateInitialisedTest(id, baseLocation, currentHalfRib, cacheItemsLocatorTest)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string") -- note: allow for testing only the type (instead of also the value)
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation),
        FieldValueEqualTest:newInstance("_currentHalfRib", currentHalfRib)
    )

    -- end
    return test
end

function T_MineLayer.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_MineLayer.CreateTestObj(id, baseLocation0, currentHalfRib0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_MineLayer.CreateInitialisedTest(id, baseLocation0, currentHalfRib0, cacheItemsLocatorTest0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_MineLayer.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = MineLayer:new({
        _id                     = id,

        _baseLocation           = baseLocation0:copy(),
        _currentHalfRib         = currentHalfRib0,

        _cacheItemsLocator      = cacheItemsLocator0,
    })
    local test = T_MineLayer.CreateInitialisedTest(id, baseLocation0, currentHalfRib0, cacheItemsLocatorTest0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_MineLayer.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." getter tests")
    local id = coreutils.NewId()
    local obj = T_MineLayer.CreateTestObj(id, baseLocation0, currentHalfRib0, cacheItemsLocator0) assert(obj, "Failed obtaining "..testClassName)

    -- test
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getCurrentHalfRib", currentHalfRib0),
        MethodResultEqualTest:newInstance("getCacheItemsLocator", cacheItemsLocator0)
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

function T_MineLayer.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_MineLayer.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_MineLayer.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

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

function T_MineLayer.T_ILObj_All()
    -- prepare test
    local destructFieldsTest0 = TestArrayTest:newInstance()

    local cacheItemsLocatorTest1 = FieldTest:newInstance("_cacheItemsLocator", TestArrayTest:newInstance(
        ValueTypeTest:newInstance(ObjLocator:getClassName()),
        MethodResultEqualTest:newInstance("getHost", "enterprise_storage")
    ))

    local fieldsTest0 = T_MineLayer.CreateInitialisedTest(nil, baseLocation0, 3, cacheItemsLocatorTest1)
    local fieldsTest1 = T_MineLayer.CreateInitialisedTest(nil, baseLocation0, 3, cacheItemsLocatorTest1)

    -- test cases
    T_ILObj.pt_all(testClassName, MineLayer, {
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

function T_MineLayer.T_IMObj_All()
    -- prepare test
    local isBlueprintTest = IsBlueprintTest:newInstance(baseLocation0:getRelativeLocation(1, 0, 0))

    -- test cases
    T_IMObj.pt_all(testClassName, MineLayer, {
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

function T_MineLayer.T_IItemSupplier_All()
    -- prepare test
    local obj = T_MineLayer.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test type
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemSupplier", IItemSupplier)
    T_IInterface.pt_ImplementsInterface("IItemSupplier", IItemSupplier, testClassName, obj)

    -- test
    T_MineLayer.T_needsTo_ProvideItemsTo_SOSrv()
    T_MineLayer.T_can_ProvideItems_QOSrv()
end

function T_MineLayer.T_provideItemsTo_AOSrv_cobblestone_ToTurtle()
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

function T_MineLayer.T_needsTo_ProvideItemsTo_SOSrv()
    -- prepare test
    local obj = T_MineLayer.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    local provideItems = {
        ["minecraft:cobblestone"]  = 9,
    }

    t_employment = t_employment or require "test.t_employment"
    local itemDepotLocator = t_employment.GetCurrentTurtleLocator()
    local turtleObj = enterprise_employment:getObj(itemDepotLocator) assert(turtleObj, "Failed obtaining turtleObj")
    local destinationLocation = turtleObj:getItemDepotLocation()

    -- test
    local fuelNeedNextHalfRib = obj:getCurrentHalfRib() + 1
    local expectedFuelNeed = fuelNeedNextHalfRib + 2*4*fuelNeedNextHalfRib + fuelNeedNextHalfRib + role_energizer.NeededFuelToFrom(destinationLocation, obj:getBaseLocation())
    T_IItemSupplier.pt_needsTo_ProvideItemsTo_SOSrv(testClassName, obj, testObjName, provideItems, itemDepotLocator, nil, {
        success         = true,
        fuelNeed        = expectedFuelNeed,
        ingredientsNeed = {},
    }, logOk)

    -- cleanup test
end

function T_MineLayer.T_can_ProvideItems_QOSrv()
    -- prepare test
    local obj = T_MineLayer.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- tests
    T_IItemSupplier.pt_can_ProvideItems_QOSrv(testClassName, obj, testObjName, { ["minecraft:cobblestone"] = 9}, true, logOk)
    T_IItemSupplier.pt_can_ProvideItems_QOSrv(testClassName, obj, testObjName, { ["minecraft:coal_ore"] = 2}, true, logOk)
    T_IItemSupplier.pt_can_ProvideItems_QOSrv(testClassName, obj, testObjName, { ["unknown"] = 10}, false, logOk)

    -- cleanup test
end

return T_MineLayer
