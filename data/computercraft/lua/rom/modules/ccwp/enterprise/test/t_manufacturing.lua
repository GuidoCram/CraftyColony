local t_manufacturing = {}

local ObjArray = require "obj_array"

local Location = require "obj_location"
local ObjLocator = require "obj_locator"

local enterprise_employment = require "enterprise_employment"
local enterprise_manufacturing = require "enterprise_manufacturing"

local TestArrayTest = require "test_array_test"
local FieldTest = require "field_test"
local FieldValueEqualTest = require "field_value_equal_test"
local ValueTypeTest = require "value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"

local T_Factory = require "test.t_mobj_factory"
local T_LObjHost = require "test.t_lobj_host"
local T_MObjHost = require "test.t_mobj_host"

function t_manufacturing.T_All()
    -- LObjHost
    t_manufacturing.T_hostLObj_SSrv_Factory()
    t_manufacturing.T_upgradeLObj_SSrv_Factory()
    t_manufacturing.T_releaseLObj_SSrv_Factory()
end

function t_manufacturing.T_AllPhysical()
    -- IObj

    -- MObjHost
    local mobjLocator = t_manufacturing.T_buildAndHostMObj_ASrv_Factory0()
    t_manufacturing.T_dismantleAndReleaseMObj_ASrv_Factory(mobjLocator)
    mobjLocator = t_manufacturing.T_buildAndHostMObj_ASrv_Factory1()
    t_manufacturing.T_dismantleAndReleaseMObj_ASrv_Factory(mobjLocator)
    mobjLocator = t_manufacturing.T_buildAndHostMObj_ASrv_Factory1()
    t_manufacturing.T_extendAndUpgradeMObj_ASrv_FactoryTo2(mobjLocator)
    t_manufacturing.T_dismantleAndReleaseMObj_ASrv_Factory(mobjLocator)
    mobjLocator = t_manufacturing.T_buildAndHostMObj_ASrv_Factory2()
    t_manufacturing.T_dismantleAndReleaseMObj_ASrv_Factory(mobjLocator)
end

local testMObjClassName = "Factory"
local testMObjName = "factory"
local testMObjName0 = testMObjName.."0"
local testMObjName1 = testMObjName.."1"
local testMObjName2 = testMObjName.."2"
local logOk = false

local level0 = 0
local level1 = 1
local level2 = 2

local baseLocation0 = Location:newInstance(6, 0, 1, 0, 1)
local baseLocation1 = Location:newInstance(12, 0, 1, 0, 1)
local baseLocation2 = baseLocation1:copy()

local inputLocator0 = enterprise_employment.GetAnyTurtleLocator()
local inputLocators0 = ObjArray:newInstance(ObjLocator:getClassName(), { inputLocator0, })

local outputLocator0 = enterprise_employment.GetAnyTurtleLocator()
local outputLocators0 = ObjArray:newInstance(ObjLocator:getClassName(), { outputLocator0, })

local craftingSpotLocatorsTest0 = FieldTest:newInstance("_craftingSpotLocators", TestArrayTest:newInstance(
    ValueTypeTest:newInstance("ObjArray"),
    MethodResultEqualTest:newInstance("getObjClassName", ObjLocator:getClassName()),
    MethodResultEqualTest:newInstance("nObjs", 1)
))

local smeltingSpotLocatorsTest1 = FieldTest:newInstance("_smeltingSpotLocators", TestArrayTest:newInstance(
    ValueTypeTest:newInstance("ObjArray"),
    MethodResultEqualTest:newInstance("getObjClassName", ObjLocator:getClassName()),
    MethodResultEqualTest:newInstance("nObjs", 1)
))

local constructParameters0 = {
    level           = level0,

    baseLocation    = baseLocation0,
}
local constructParameters1 = {
    level           = level1,

    baseLocation    = baseLocation1,
}
local constructParameters2 = {
    level           = level2,

    baseLocation    = baseLocation2,
}
local upgradeParametersTo2 = {
    level           = level2,
}

local inputLocatorsTest2 = FieldTest:newInstance("_inputLocators", TestArrayTest:newInstance(
    ValueTypeTest:newInstance("ObjArray"),
    MethodResultEqualTest:newInstance("getObjClassName", ObjLocator:getClassName()),
    MethodResultEqualTest:newInstance("nObjs", 1)
))
local outputLocatorsTest2 = FieldTest:newInstance("_outputLocators", TestArrayTest:newInstance(
    ValueTypeTest:newInstance("ObjArray"),
    MethodResultEqualTest:newInstance("getObjClassName", ObjLocator:getClassName()),
    MethodResultEqualTest:newInstance("nObjs", 1)
))

--    _      ____  _     _ _    _           _
--   | |    / __ \| |   (_) |  | |         | |
--   | |   | |  | | |__  _| |__| | ___  ___| |_
--   | |   | |  | | '_ \| |  __  |/ _ \/ __| __|
--   | |___| |__| | |_) | | |  | | (_) \__ \ |_
--   |______\____/|_.__/| |_|  |_|\___/|___/\__|
--                     _/ |
--                    |__/

-- ** Factory **

function t_manufacturing.T_hostLObj_SSrv_Factory()
    -- prepare test
    local inputLocatorsTest0 = FieldValueEqualTest:newInstance("_inputLocators", inputLocators0)
    local outputLocatorsTest0 = FieldValueEqualTest:newInstance("_outputLocators", outputLocators0)
    local constructFieldsTest = T_Factory.CreateInitialisedTest(nil, level1, baseLocation1, inputLocatorsTest0, outputLocatorsTest0, craftingSpotLocatorsTest0, smeltingSpotLocatorsTest1)

    -- test
    local serviceResults = T_LObjHost.pt_hostLObj_SSrv(enterprise_manufacturing, testMObjClassName, constructParameters1, testMObjName1, constructFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_manufacturing.T_upgradeLObj_SSrv_Factory()
    -- prepare test
    local upgradeFieldsTest = T_Factory.CreateInitialisedTest(nil, level2, baseLocation1, inputLocatorsTest2, outputLocatorsTest2, craftingSpotLocatorsTest0, smeltingSpotLocatorsTest1)

    -- test
    local serviceResults = T_LObjHost.pt_upgradeLObj_SSrv(enterprise_manufacturing, testMObjClassName, constructParameters1, upgradeParametersTo2, testMObjName1, upgradeFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_manufacturing.T_releaseLObj_SSrv_Factory()
    -- prepare test

    -- test
    local serviceResults = T_LObjHost.pt_releaseLObj_SSrv(enterprise_manufacturing, testMObjClassName, constructParameters1, testMObjName1, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

--    __  __  ____  _     _ _    _           _
--   |  \/  |/ __ \| |   (_) |  | |         | |
--   | \  / | |  | | |__  _| |__| | ___  ___| |_
--   | |\/| | |  | | '_ \| |  __  |/ _ \/ __| __|
--   | |  | | |__| | |_) | | |  | | (_) \__ \ |_
--   |_|  |_|\____/|_.__/| |_|  |_|\___/|___/\__|
--                      _/ |
--                     |__/

-- ** Factory **

local mobjLocator_Factory = nil

function t_manufacturing.T_buildAndHostMObj_ASrv_Factory0()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_manufacturing, testMObjClassName, constructParameters0, testMObjName0, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Factory = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_manufacturing.T_buildAndHostMObj_ASrv_Factory1()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_manufacturing, testMObjClassName, constructParameters1, testMObjName1, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Factory = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_manufacturing.T_buildAndHostMObj_ASrv_Factory2()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_manufacturing, testMObjClassName, constructParameters2, testMObjName2, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Factory = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_manufacturing.T_extendAndUpgradeMObj_ASrv_FactoryTo2(mobjLocator)
    -- prepare test
    local upgradeFieldsTest = T_Factory.CreateInitialisedTest(nil, level2, baseLocation1, inputLocatorsTest2, outputLocatorsTest2, craftingSpotLocatorsTest0, smeltingSpotLocatorsTest1)

    if not mobjLocator then
        -- check if we locally remembered a mobjLocator
        assert(mobjLocator_Factory, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_Factory
    end

    -- test
    local serviceResults = T_MObjHost.pt_extendAndUpgradeMObj_ASrv(enterprise_manufacturing, mobjLocator, upgradeParametersTo2, testMObjName1, upgradeFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_manufacturing.T_dismantleAndReleaseMObj_ASrv_Factory(mobjLocator)
    -- prepare test
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator
        assert(mobjLocator_Factory, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_Factory
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(enterprise_manufacturing, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Factory = nil
end

return t_manufacturing
