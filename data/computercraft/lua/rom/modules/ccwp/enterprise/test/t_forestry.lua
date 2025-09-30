local t_forestry = {}
local corelog = require "corelog"

local Location = require "obj_location"
local ObjLocator = require "obj_locator"

local enterprise_employment = require "enterprise_employment"
local enterprise_forestry = require "enterprise_forestry"

local TestArrayTest = require "test_array_test"
local FieldTest = require "field_test"
local FieldValueEqualTest = require "field_value_equal_test"
local ValueTypeTest = require "value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"

local T_BirchForest = require "test.t_mobj_birchforest"
local T_LObjHost = require "test.t_lobj_host"
local T_MObjHost = require "test.t_mobj_host"

function t_forestry.T_All()
    -- LObjHost
    t_forestry.T_hostLObj_SSrv_BirchForest()
    t_forestry.T_upgradeLObj_SSrv_BirchForest()
    t_forestry.T_releaseLObj_SSrv_BirchForest()
end

function t_forestry.T_AllPhysical()
    -- IObj

    -- MObjHost
    local mobjLocator = t_forestry.T_buildAndHostMObj_ASrv_BirchForest_Lm1T1()
    t_forestry.T_extendAndUpgradeMObj_ASrv_BirchForestTo_L0T1(mobjLocator)
    t_forestry.T_dismantleAndReleaseMObj_ASrv_BirchForest(mobjLocator)
    mobjLocator = t_forestry.T_buildAndHostMObj_ASrv_BirchForest_L0T1()
    t_forestry.T_dismantleAndReleaseMObj_ASrv_BirchForest(mobjLocator)
    mobjLocator = t_forestry.T_buildAndHostMObj_ASrv_BirchForest_L1T2()
    t_forestry.T_dismantleAndReleaseMObj_ASrv_BirchForest(mobjLocator)
    mobjLocator = t_forestry.T_buildAndHostMObj_ASrv_BirchForest_L1T2()
    t_forestry.T_extendAndUpgradeMObj_ASrv_BirchForestTo_L2T4(mobjLocator)
    t_forestry.T_dismantleAndReleaseMObj_ASrv_BirchForest(mobjLocator)
    mobjLocator = t_forestry.T_buildAndHostMObj_ASrv_BirchForest_L2T2()
    t_forestry.T_extendAndUpgradeMObj_ASrv_BirchForestTo_L2T4(mobjLocator)
    t_forestry.T_dismantleAndReleaseMObj_ASrv_BirchForest(mobjLocator)
end

local testMObjClassName = "BirchForest"
local testMObjName = "birchForest"
local testMObjNamem1 = testMObjName.."-1"
local testMObjName0 = testMObjName.."0"
local testMObjName1 = testMObjName.."1"
local testMObjName2 = testMObjName.."2"
local logOk = false

local levelm1 = -1
local level0 = 0
local level1 = 1
local level2 = 2
local baseLocation0 = Location:newInstance(0, 0, 1, 0, 1)
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
local constructParameters_L2T2 = {
    level           = level2,

    baseLocation    = baseLocation0,
    nTrees          = nTrees2,
}
local upgradeParametersTo_L0T1 = {
    level           = level0,

    nTrees          = nTrees1,
}
local upgradeParametersTo_L2T4 = {
    level           = level2,

    nTrees          = nTrees4,
}

--    _      ____  _     _ _    _           _
--   | |    / __ \| |   (_) |  | |         | |
--   | |   | |  | | |__  _| |__| | ___  ___| |_
--   | |   | |  | | '_ \| |  __  |/ _ \/ __| __|
--   | |___| |__| | |_) | | |  | | (_) \__ \ |_
--   |______\____/|_.__/| |_|  |_|\___/|___/\__|
--                     _/ |
--                    |__/

-- ** BirchForest **

function t_forestry.T_hostLObj_SSrv_BirchForest()
    -- prepare test
    local fieldsTest0 = T_BirchForest.CreateInitialisedTest(nil, level0, baseLocation0, nTrees1, localLogsLocatorTest0, localSaplingsLocatorTest0)

    -- test
    local serviceResults = T_LObjHost.pt_hostLObj_SSrv(enterprise_forestry, testMObjClassName, constructParameters_L0T1, testMObjName0, fieldsTest0, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_forestry.T_upgradeLObj_SSrv_BirchForest()
    -- prepare test
    local localLogsLocatorTest2 = FieldTest:newInstance("_localLogsLocator", TestArrayTest:newInstance(
        ValueTypeTest:newInstance(ObjLocator:getClassName()),
        MethodResultEqualTest:newInstance("getHost", "enterprise_storage")
    ))
    local localSaplingsLocatorTest2 = FieldTest:newInstance("_localSaplingsLocator", TestArrayTest:newInstance(
        ValueTypeTest:newInstance(ObjLocator:getClassName()),
        MethodResultEqualTest:newInstance("getHost", "enterprise_storage")
    ))
    local fieldsTest2 = T_BirchForest.CreateInitialisedTest(nil, level2, baseLocation0, nTrees4, localLogsLocatorTest2, localSaplingsLocatorTest2)

    -- test
    local serviceResults = T_LObjHost.pt_upgradeLObj_SSrv(enterprise_forestry, testMObjClassName, constructParameters_L1T2, upgradeParametersTo_L2T4, testMObjName1, fieldsTest2, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_forestry.T_releaseLObj_SSrv_BirchForest()
    -- prepare test

    -- test
    local serviceResults = T_LObjHost.pt_releaseLObj_SSrv(enterprise_forestry, testMObjClassName, constructParameters_L1T2, testMObjName1, logOk)
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

-- ** BirchForest **

local mobjLocator_BirchForest = nil

function t_forestry.T_buildAndHostMObj_ASrv_BirchForest_Lm1T1()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_forestry, testMObjClassName, constructParameters_Lm1T1, testMObjNamem1, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_BirchForest = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_forestry.T_buildAndHostMObj_ASrv_BirchForest_L0T1()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_forestry, testMObjClassName, constructParameters_L0T1, testMObjName0, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_BirchForest = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_forestry.T_buildAndHostMObj_ASrv_BirchForest_L1T2()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_forestry, testMObjClassName, constructParameters_L1T2, testMObjName1, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_BirchForest = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_forestry.T_buildAndHostMObj_ASrv_BirchForest_L2T2()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_forestry, testMObjClassName, constructParameters_L2T2, testMObjName2, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_BirchForest = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_forestry.T_extendAndUpgradeMObj_ASrv_BirchForestTo_L0T1(mobjLocator)
    -- prepare test
    local upgradeFieldsTest = T_BirchForest.CreateInitialisedTest(nil, level0, baseLocation0, nTrees1, localLogsLocatorTest0, localSaplingsLocatorTest0)

    if not mobjLocator then
        -- check if we locally remembered a mobjLocator
        assert(mobjLocator_BirchForest, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_BirchForest
    end

    -- test
    local serviceResults = T_MObjHost.pt_extendAndUpgradeMObj_ASrv(enterprise_forestry, mobjLocator, upgradeParametersTo_L0T1, mobjLocator:getURI(), upgradeFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_forestry.T_extendAndUpgradeMObj_ASrv_BirchForestTo_L2T4(mobjLocator)
    -- prepare test
    local localLogsLocatorTest2 = FieldTest:newInstance("_localLogsLocator", TestArrayTest:newInstance(
        ValueTypeTest:newInstance(ObjLocator:getClassName()),
        MethodResultEqualTest:newInstance("getHost", "enterprise_storage")
    ))
    local localSaplingsLocatorTest2 = FieldTest:newInstance("_localSaplingsLocator", TestArrayTest:newInstance(
        ValueTypeTest:newInstance(ObjLocator:getClassName()),
        MethodResultEqualTest:newInstance("getHost", "enterprise_storage")
    ))
    local upgradeFieldsTest = T_BirchForest.CreateInitialisedTest(nil, level2, baseLocation0, nTrees4, localLogsLocatorTest2, localSaplingsLocatorTest2)

    if not mobjLocator then
        -- check if we locally remembered a mobjLocator
        assert(mobjLocator_BirchForest, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_BirchForest
    end

    -- test
    local serviceResults = T_MObjHost.pt_extendAndUpgradeMObj_ASrv(enterprise_forestry, mobjLocator, upgradeParametersTo_L2T4, mobjLocator:getURI(), upgradeFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_forestry.T_dismantleAndReleaseMObj_ASrv_BirchForest(mobjLocator)
    -- prepare test
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator
        assert(mobjLocator_BirchForest, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_BirchForest
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(enterprise_forestry, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_BirchForest = nil
end

return t_forestry
