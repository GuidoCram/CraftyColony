local T_BirchForest = {}

local corelog = require "corelog"
local coreutils = require "coreutils"

local IObj = require "i_obj"
local IItemSupplier = require "i_item_supplier"
local ObjBase = require "obj_base"
local Location = require "obj_location"
local ObjLocator = require "obj_locator"

local BirchForest = require "mobj_birchforest"

local role_forester = require "role_forester"

local enterprise_employment = require "enterprise_employment"
local enterprise_storage = require "enterprise_storage"
local enterprise_forestry = require "enterprise_forestry"

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

function T_BirchForest.T_All()
    -- initialisation
    T_BirchForest.T__init()
    T_BirchForest.T_new()
    T_BirchForest.T_Getters()
    T_BirchForest.T_Setters()

    -- IObj
    T_BirchForest.T_IObj_All()

    -- ILObj
    T_BirchForest.T_ILObj_All()

    -- IMObj
    T_BirchForest.T_IMObj_All()

    -- IItemSupplier
    T_BirchForest.T_IItemSupplier_All()

    -- BirchForest
    T_BirchForest.T_getFuelNeed_Harvest_Att()
    T_BirchForest.T_getFuelNeedExtraTree_Att()
end

function T_BirchForest.T_AllPhysical()
    -- IItemSupplier
    T_BirchForest.T_provideItemsTo_AOSrv_Log_ToTurtle()
    T_BirchForest.T_provideItemsTo_AOSrv_Sapling_ToTurtle()
end

local testClassName = "BirchForest"
local testObjName = "birchForest"
local testObjNamem1 = testObjName.."-1"
local testObjName0 = testObjName.."0"
local testObjName1 = testObjName.."1"
local testObjName2 = testObjName.."2"
local testHost = enterprise_forestry

local logOk = false

local levelm1 = -1
local level0 = 0
local level1 = 1
local level2 = 2
local baseLocation0 = Location:newInstance(0, 0, 1, 0, 1)
local baseLocation1 = Location:newInstance(6, 12, 1, 0, 1)
local nTrees1 = 1
local nTrees2 = 2
local nTrees4 = 4
local localLogsLocator0 = enterprise_employment.GetAnyTurtleLocator()
local localSaplingsLocator0 = enterprise_employment.GetAnyTurtleLocator()
local localLogsLocatorTest0 = FieldValueEqualTest:newInstance("_localLogsLocator", localLogsLocator0)
local localSaplingsLocatorTest0 = FieldValueEqualTest:newInstance("_localSaplingsLocator", localSaplingsLocator0)

local constructParameters_Lm1T1 = {
    level           = levelm1,

    baseLocation    = baseLocation0,
    nTrees          = nTrees1,
}
local constructParameters_L0T1 = {
    level           = level0,

    baseLocation    = baseLocation0,
    nTrees          = nTrees1,
}
local constructParameters_L1T2 = {
    level           = level1,

    baseLocation    = baseLocation0,
    nTrees          = nTrees2,
}
local constructParameters_L2T4 = {
    level           = level2,

    baseLocation    = baseLocation0,
    nTrees          = nTrees4,
}

local upgradeParametersTo_L1T2 = {
    level           = level1,

    nTrees          = nTrees2,
}
local upgradeParametersTo_L2T4 = {
    level           = level2,

    nTrees          = nTrees4,
}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_BirchForest.CreateTestObj(id, level, baseLocation, nTrees, localLogsLocator, localSaplingsLocator)
    -- check input
    id = id or coreutils.NewId()
    level = level or level0
    baseLocation = baseLocation or baseLocation0
    nTrees = nTrees or nTrees1
    localLogsLocator = localLogsLocator or localLogsLocator0
    localSaplingsLocator = localSaplingsLocator or localSaplingsLocator0

    -- create testObj
    local testObj = BirchForest:newInstance(id, level, baseLocation:copy(), nTrees, localLogsLocator, localSaplingsLocator)

    -- end
    return testObj
end

function T_BirchForest.CreateInitialisedTest(id, level, baseLocation, nTrees, localLogsLocatorTest, localSaplingsLocatorTest)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string") -- note: allow for testing only the type (instead of also the value)
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_level", level),
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation),
        FieldValueEqualTest:newInstance("_nTrees", nTrees),
        localLogsLocatorTest,
        localSaplingsLocatorTest
    )

    -- end
    return test
end

function T_BirchForest.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_BirchForest.CreateTestObj(id, level0, baseLocation0, nTrees1, localLogsLocator0, localSaplingsLocator0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_BirchForest.CreateInitialisedTest(id, level0, baseLocation0, nTrees1, localLogsLocatorTest0, localSaplingsLocatorTest0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_BirchForest.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = BirchForest:new({
        _id                     = id,
        _level                  = level0,

        _baseLocation           = baseLocation0:copy(),
        _nTrees                 = nTrees1,

        _localLogsLocator       = localLogsLocator0,
        _localSaplingsLocator   = localSaplingsLocator0,
    })
    local test = T_BirchForest.CreateInitialisedTest(id, level0, baseLocation0, nTrees1, localLogsLocatorTest0, localSaplingsLocatorTest0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_BirchForest.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." getter tests")
    local id = coreutils.NewId()
    local localLogsLocator = enterprise_employment.GetAnyTurtleLocator() assert(localLogsLocator, "Failed obtaining localLogsLocator")
    local localSaplingsLocator = enterprise_employment.GetAnyTurtleLocator() assert(localSaplingsLocator, "Failed obtaining localLogsLocator")
    local obj = T_BirchForest.CreateTestObj(id, level0, baseLocation0, nTrees1, localLogsLocator0, localSaplingsLocator0) assert(obj, "Failed obtaining "..testClassName)

    -- test
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getLevel", level0),
        MethodResultEqualTest:newInstance("getNTrees", nTrees1),
        MethodResultEqualTest:newInstance("getLocalLogsLocator", localLogsLocator0),
        MethodResultEqualTest:newInstance("getLocalSaplingsLocator", localSaplingsLocator0)
    )
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_BirchForest.T_Setters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." setter tests")
    local obj = T_BirchForest.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local localLogsLocator1 = enterprise_storage:hostLObj_SSrv({className="Chest",constructParameters={ baseLocation = baseLocation1:getRelativeLocation(2, 2, 0), }}).mobjLocator if not localLogsLocator1 then corelog.Error("failed registering Chest") return end
    local localSaplingsLocator1 = enterprise_storage:hostLObj_SSrv({className="Chest",constructParameters={ baseLocation = baseLocation1:getRelativeLocation(4, 2, 0), }}).mobjLocator if not localSaplingsLocator1 then corelog.Error("failed registering Chest") return end

    -- test
    obj:setLevel(level2)
    obj:setNTrees(nTrees2)
    obj:setLocalLogsLocator(localLogsLocator1)
    obj:setLocalSaplingsLocator(localSaplingsLocator1)
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getLevel", level2),
        MethodResultEqualTest:newInstance("getNTrees", nTrees2),
        MethodResultEqualTest:newInstance("getLocalLogsLocator", localLogsLocator1),
        MethodResultEqualTest:newInstance("getLocalSaplingsLocator", localSaplingsLocator1)
    )
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
    return enterprise_storage:releaseLObj_SSrv({ mobjLocator = localLogsLocator1 }) and enterprise_storage:releaseLObj_SSrv({ mobjLocator = localSaplingsLocator1 })
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function T_BirchForest.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_BirchForest.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_BirchForest.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

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

function T_BirchForest.T_ILObj_All()
    -- prepare test
    local destructFieldsTest0 = TestArrayTest:newInstance()

    local localLogsLocatorTest2 = FieldTest:newInstance("_localLogsLocator", TestArrayTest:newInstance(
        ValueTypeTest:newInstance(ObjLocator:getClassName()),
        MethodResultEqualTest:newInstance("getHost", "enterprise_storage")
    ))
    local localSaplingsLocatorTest2 = FieldTest:newInstance("_localSaplingsLocator", TestArrayTest:newInstance(
        ValueTypeTest:newInstance(ObjLocator:getClassName()),
        MethodResultEqualTest:newInstance("getHost", "enterprise_storage")
    ))

    local fieldsTestm1 = T_BirchForest.CreateInitialisedTest(nil, levelm1, baseLocation0, nTrees1, localLogsLocatorTest0, localSaplingsLocatorTest0)
    local fieldsTest0 = T_BirchForest.CreateInitialisedTest(nil, level0, baseLocation0, nTrees1, localLogsLocatorTest0, localSaplingsLocatorTest0)
    local fieldsTest1 = T_BirchForest.CreateInitialisedTest(nil, level1, baseLocation0, nTrees2, localLogsLocatorTest0, localSaplingsLocatorTest0)
    local fieldsTest2 = T_BirchForest.CreateInitialisedTest(nil, level2, baseLocation0, nTrees4, localLogsLocatorTest2, localSaplingsLocatorTest2)

    -- test cases
    T_ILObj.pt_all(testClassName, BirchForest, {
        {
            objName             = testObjNamem1,
            constructParameters = constructParameters_Lm1T1,
            constructFieldsTest = fieldsTestm1,
            destructFieldsTest  = destructFieldsTest0,
        },
        {
            objName             = testObjName0,
            constructParameters = constructParameters_L0T1,
            constructFieldsTest = fieldsTest0,
            upgradeParameters   = upgradeParametersTo_L1T2,
            upgradeFieldsTest   = fieldsTest1,
        },
        {
            objName             = testObjName1,
            constructParameters = constructParameters_L1T2,
            constructFieldsTest = fieldsTest1,
            upgradeParameters   = upgradeParametersTo_L2T4,
            upgradeFieldsTest   = fieldsTest2,
        },
        {
            objName             = testObjName2,
            constructParameters = constructParameters_L2T4,
            constructFieldsTest = fieldsTest2,
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

function T_BirchForest.T_IMObj_All()
    -- prepare test
    local buildLocation_Lm1 = baseLocation0:getRelativeLocation(3, 2, 0)
    local isBlueprintTest_Lm1 = IsBlueprintTest:newInstance(buildLocation_Lm1)
    local isBlueprintTest = IsBlueprintTest:newInstance(baseLocation0)
    local buildLocation_FromL1T2_ToL2T4 = baseLocation0:getRelativeLocation(0, 1, 0) -- note: offset because row 1 is already build
    local isBlueprintTest_FromL1T2_ToL2T4 = IsBlueprintTest:newInstance(buildLocation_FromL1T2_ToL2T4)

    -- test cases
    T_IMObj.pt_all(testClassName, BirchForest, {
        {
            objName                 = testObjNamem1,
            constructParameters     = constructParameters_Lm1T1,
            constructBlueprintTest  = isBlueprintTest_Lm1,
            expectedBaseLocation    = baseLocation0:copy(),
        },
        {
            objName                 = testObjName0,
            constructParameters     = constructParameters_L0T1,
            constructBlueprintTest  = isBlueprintTest,
            upgradeParameters       = upgradeParametersTo_L1T2,
            upgradeBlueprintTest    = isBlueprintTest,
            dismantleBlueprintTest  = isBlueprintTest,
        },
        {
            objName                 = testObjName1,
            constructParameters     = constructParameters_L1T2,
            constructBlueprintTest  = isBlueprintTest,
            upgradeParameters       = upgradeParametersTo_L2T4,
            upgradeBlueprintTest    = isBlueprintTest_FromL1T2_ToL2T4,
            dismantleBlueprintTest  = isBlueprintTest,
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

function T_BirchForest.T_IItemSupplier_All()
    -- prepare test
    local obj = T_BirchForest.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test type
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemSupplier", IItemSupplier)
    T_IInterface.pt_ImplementsInterface("IItemSupplier", IItemSupplier, testClassName, obj)

    -- test
    T_BirchForest.T_needsTo_ProvideItemsTo_SOSrv()
    T_BirchForest.T_can_ProvideItems_QOSrv()
end

function T_BirchForest.T_provideItemsTo_AOSrv_Log_ToTurtle()
    -- prepare test
    local objLocator = testHost:hostLObj_SSrv({ className = testClassName, constructParameters = constructParameters_L2T4 }).mobjLocator assert(objLocator, "failed hosting "..testClassName.." on "..testHost:getHostName())
    local provideItems = { ["minecraft:birch_log"] = 10 }

    t_employment = t_employment or require "test.t_employment"
    local itemDepotLocator = t_employment.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")
    local ingredientsItemSupplierLocator = t_employment.GetCurrentTurtleLocator() assert(ingredientsItemSupplierLocator, "Failed obtaining ingredientsItemSupplierLocator")
    local wasteItemDepotLocator = ingredientsItemSupplierLocator:copy()

    -- test
    T_IItemSupplier.pt_provideItemsTo_AOSrv(testClassName, objLocator, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, logOk)

    -- cleanup test
    testHost:releaseLObj_SSrv({ mobjLocator = objLocator})
end

function T_BirchForest.T_provideItemsTo_AOSrv_Sapling_ToTurtle()
    -- prepare test
    local objLocator = testHost:hostLObj_SSrv({ className = testClassName, constructParameters = constructParameters_L2T4 }).mobjLocator assert(objLocator, "failed hosting "..testClassName.." on "..testHost:getHostName())

    local provideItems = { ["minecraft:birch_sapling"] = 1 }

    t_employment = t_employment or require "test.t_employment"
    local itemDepotLocator = t_employment.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")
    local ingredientsItemSupplierLocator = t_employment.GetCurrentTurtleLocator() assert(ingredientsItemSupplierLocator, "Failed obtaining ingredientsItemSupplierLocator")
    local wasteItemDepotLocator = ingredientsItemSupplierLocator:copy()

    -- test
    T_IItemSupplier.pt_provideItemsTo_AOSrv(testClassName, objLocator, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, logOk)

    -- cleanup test
    testHost:releaseLObj_SSrv({ mobjLocator = objLocator})
end

function T_BirchForest.T_needsTo_ProvideItemsTo_SOSrv()
    -- prepare test
    local obj = T_BirchForest.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }

    t_employment = t_employment or require "test.t_employment"
    local itemDepotLocator = t_employment.GetCurrentTurtleLocator()

    -- test
    local storeFuelPerRound = 1 + 1
    local expectedFuelNeed = role_forester.FuelNeededPerRound(nTrees1) + storeFuelPerRound
    T_IItemSupplier.pt_needsTo_ProvideItemsTo_SOSrv(testClassName, obj, testObjName, provideItems, itemDepotLocator, nil, {
        success         = true,
        fuelNeed        = expectedFuelNeed,
        ingredientsNeed = {},
    }, logOk)

    -- cleanup test
end

function T_BirchForest.T_can_ProvideItems_QOSrv()
    -- prepare test
    local obj = T_BirchForest.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- tests
    T_IItemSupplier.pt_can_ProvideItems_QOSrv(testClassName, obj, testObjName, { ["minecraft:birch_log"] = 20}, true, logOk)
    T_IItemSupplier.pt_can_ProvideItems_QOSrv(testClassName, obj, testObjName, { ["minecraft:birch_sapling"] = 2}, true, logOk)
    T_IItemSupplier.pt_can_ProvideItems_QOSrv(testClassName, obj, testObjName, { ["minecraft:dirt"] = 10}, false, logOk)

    -- cleanup test
end

--    ____  _          _     ______                  _
--   |  _ \(_)        | |   |  ____|                | |
--   | |_) |_ _ __ ___| |__ | |__ ___  _ __ ___  ___| |_
--   |  _ <| | '__/ __| '_ \|  __/ _ \| '__/ _ \/ __| __|
--   | |_) | | | | (__| | | | | | (_) | | |  __/\__ \ |_
--   |____/|_|_|  \___|_| |_|_|  \___/|_|  \___||___/\__|

function T_BirchForest.T_getFuelNeed_Harvest_Att()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getFuelNeed_Harvest_Att() tests")
    local obj = T_BirchForest.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    local fuelNeed = obj:getFuelNeed_Harvest_Att()
    local expectedFuelNeed = 36
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") for "..nTrees1.."trees not the same as expected(="..expectedFuelNeed..")")

    obj:setNTrees(nTrees2)
    fuelNeed = obj:getFuelNeed_Harvest_Att()
    expectedFuelNeed = 2*36 + 2 * 6
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") for "..nTrees2.."trees not the same as expected(="..expectedFuelNeed..")")

    -- cleanup test
end

function T_BirchForest.T_getFuelNeedExtraTree_Att()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getFuelNeedExtraTree_Att() tests")
    local obj = T_BirchForest.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    local fuelNeed = obj:getFuelNeedExtraTree_Att()
    local expectedFuelNeed = 36 + 2*6
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") for "..nTrees1.."trees not the same as expected(="..expectedFuelNeed..")")

    obj:setNTrees(nTrees2)
    fuelNeed = obj:getFuelNeedExtraTree_Att()
    expectedFuelNeed = 36 + 2*6
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") for "..nTrees2.."trees not the same as expected(="..expectedFuelNeed..")")

    -- cleanup test
end

return T_BirchForest
