local T_MObjHost = {}

local corelog = require "corelog"

local IObj = require "i_obj"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local MethodExecutor = require "method_executor"
local ObjBase = require "obj_base"

local Location = require "obj_location"
local LObjHost = require "lobj_host"

local MObjHost = require "mobj_host"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

local T_MObjTest = require "test.t_mobj_test"

local t_employment

function T_MObjHost.T_All()
    -- initialisation
    T_MObjHost.T_new()

    -- IObj
    T_MObjHost.T_IObj_All()
end

function T_MObjHost.T_AllPhysical()
    -- IObj

    -- MObjHost
    local mobjLocator = T_MObjHost.T_buildAndHostMObj_ASrv_MObjTest()
    T_MObjHost.T_extendAndUpgradeMObj_ASrv_MObjTest(mobjLocator)
    T_MObjHost.T_dismantleAndReleaseMObj_ASrv_MObjTest(mobjLocator)
end

local testClassName = "MObjHost"
local testObjName = "host"
local logOk = false

local test_mobjHostName1 = "TestMObjHost"
local test_mobjHost1 = MObjHost:newInstance(test_mobjHostName1)

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_MObjHost.CreateTestObj(hostName)
    -- check input
    hostName = test_mobjHostName1 or hostName

    -- create testObj
    local testObj = MObjHost:newInstance(hostName)

    -- end
    return testObj
end

function T_MObjHost.CreateInitialisedTest(hostName)
    -- check input

    -- create test
    local test = TestArrayTest:newInstance(
        FieldValueEqualTest:newInstance("_hostName", hostName)
    )

    -- end
    return test
end

function T_MObjHost.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test full
    local obj = MObjHost:new({
        _hostName   = test_mobjHostName1,
    })
    local test = T_MObjHost.CreateInitialisedTest(test_mobjHostName1)
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

function T_MObjHost.T_IObj_All()
    -- prepare test
    local obj = T_MObjHost.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_MObjHost.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_Class.pt_IsInstanceOf(testClassName, obj, "LObjHost", LObjHost) -- ToDo: consider moving to different section
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--    __  __  ____  _     _ _    _           _
--   |  \/  |/ __ \| |   (_) |  | |         | |
--   | \  / | |  | | |__  _| |__| | ___  ___| |_
--   | |\/| | |  | | '_ \| |  __  |/ _ \/ __| __|
--   | |  | | |__| | |_) | | |  | | (_) \__ \ |_
--   |_|  |_|\____/|_.__/| |_|  |_|\___/|___/\__|
--                      _/ |
--                     |__/

-- ** parameterised service tests **

function T_MObjHost.pt_buildAndHostMObj_ASrv(mobjHost, className, constructParameters, objName, logOk)
    -- prepare test
    assert(type(mobjHost) =="table", "no valid mobjHost provided")
    assert(type(className) == "string", "no valid className provided")
    assert(type(constructParameters) == "table", "no valid constructParameters provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog("* "..mobjHost:getHostName()..":buildAndHostMObj_ASrv() tests (of "..objName..")")
    t_employment = t_employment or require "test.t_employment"

    -- test
    local serviceResults = MethodExecutor.DoASyncObjService_Sync(mobjHost, "buildAndHostMObj_ASrv", {
        className                   = className,
        constructParameters         = constructParameters,
        materialsItemSupplierLocator= t_employment.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_employment.GetCurrentTurtleLocator(),
    })

    -- check: service success
    assert(serviceResults, "no serviceResults returned")
    assert(serviceResults.success, "failed executing service")

    -- check: mobj hosted on MObjHost (full check done in pt_hostLObj_SSrv)
    local mobjLocator = serviceResults.mobjLocator assert(mobjLocator, "no mobjLocator returned")
    local mobj = mobjHost:getObj(mobjLocator)
    assert(mobj, "MObj(="..mobjLocator:getURI()..") not hosted by "..mobjHost:getHostName())

    -- check: build blueprint build
    -- ToDo: add mock test

    -- cleanup test
    if logOk then corelog.WriteToLog(" ok") end

    -- return results
    return serviceResults
end

function T_MObjHost.pt_extendAndUpgradeMObj_ASrv(mobjHost, mobjLocator, upgradeParameters, objName, fieldsTest, logOk)
    -- prepare test
    assert(type(mobjHost) =="table", "no valid mobjHost provided")
    assert(type(mobjLocator) == "table", "no valid mobjLocator provided")
    assert(type(upgradeParameters) == "table", "no valid upgradeParameters provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(fieldsTest) == "table", "no valid fieldsTest provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog("* "..mobjHost:getHostName()..":extendAndUpgradeMObj_ASrv() tests (of "..objName..")")
    t_employment = t_employment or require "test.t_employment"

    -- test
    local serviceResults = MethodExecutor.DoASyncObjService_Sync(mobjHost, "extendAndUpgradeMObj_ASrv", {
        mobjLocator                 = mobjLocator,
        upgradeParameters           = upgradeParameters,
        materialsItemSupplierLocator= t_employment.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_employment.GetCurrentTurtleLocator(),
    })

    -- check: service success
    assert(serviceResults, "no serviceResults returned")
    assert(serviceResults.success, "failed executing service")

    -- check: extend blueprint build
    -- ToDo: add mock test

    -- check: mobj upgraded (i.e. fields values as expected)
    local mobj = mobjHost:getObj(mobjLocator) assert(mobj, "MObj(="..mobjLocator:getURI()..") not hosted by "..mobjHost:getHostName())
    fieldsTest:test(mobj, objName, "", logOk)

    -- cleanup test
    if logOk then corelog.WriteToLog(" ok") end

    -- return results
    return serviceResults
end

function T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(mobjHost, mobjLocator, logOk)
    -- prepare test
    assert(type(mobjHost) =="table", "no valid mobjHost provided")
    assert(type(mobjLocator) == "table", "no valid mobjLocator provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog("* "..mobjHost:getHostName()..":dismantleAndReleaseMObj_ASrv() tests (of "..mobjLocator:getURI()..")")
    t_employment = t_employment or require "test.t_employment"

    -- test
    local serviceResults = MethodExecutor.DoASyncObjService_Sync(mobjHost, "dismantleAndReleaseMObj_ASrv", {
        mobjLocator                 = mobjLocator,
        materialsItemSupplierLocator= t_employment.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_employment.GetCurrentTurtleLocator(),
    })

    -- check: service success
    assert(serviceResults, "no serviceResults returned")
    assert(serviceResults.success, "failed executing service")

    -- check: mobj released
    local mobjResourceTable = mobjHost:getResource(mobjLocator)
    assert(not mobjResourceTable, "MObj(="..mobjLocator:getURI()..") not released from MObjHost "..mobjHost:getHostName())

    -- check: dismantle blueprint "build"
    -- ToDo: add mock test

    -- cleanup test
    if logOk then corelog.WriteToLog(" ok") end

    -- return results
    return serviceResults
end

-- ** MObjTest **

local testMObjClassName = "MObjTest"
local testMObjName = "mobjTest"
local baseLocation0 = Location:newInstance(-12, 0, 1, 0, 1)
local field1_1 = "field1 1"
local field1_2 = "field1 2"
local constructParameters1 = {
    baseLocation    = baseLocation0,
    field1Value     = field1_1,
}
local upgradeParameters2 = {
    field1 = field1_2
}

local mobjLocator_MObjTest = nil

function T_MObjHost.T_buildAndHostMObj_ASrv_MObjTest()
    -- prepare test
    moduleRegistry:register(test_mobjHostName1, test_mobjHost1)

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(test_mobjHost1, testMObjClassName, constructParameters1, testMObjName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    moduleRegistry:delist(test_mobjHostName1)
    mobjLocator_MObjTest = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function T_MObjHost.T_extendAndUpgradeMObj_ASrv_MObjTest(mobjLocator)
    -- prepare test
    moduleRegistry:register(test_mobjHostName1, test_mobjHost1)
    local upgradeFieldsTest = T_MObjTest.CreateInitialisedTest(nil, baseLocation0, field1_2)

    if not mobjLocator then
        -- check if we locally remembered a mobjLocator
        assert(mobjLocator_MObjTest, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_MObjTest
    end

    -- test
    local serviceResults = T_MObjHost.pt_extendAndUpgradeMObj_ASrv(test_mobjHost1, mobjLocator, upgradeParameters2, testMObjName, upgradeFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    moduleRegistry:delist(test_mobjHostName1)
end

function T_MObjHost.T_dismantleAndReleaseMObj_ASrv_MObjTest(mobjLocator)
    -- prepare test
    moduleRegistry:register(test_mobjHostName1, test_mobjHost1)

    if not mobjLocator then
        -- check if we locally remembered a mobjLocator
        assert(mobjLocator_MObjTest, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_MObjTest
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(test_mobjHost1, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_MObjTest = nil
    moduleRegistry:delist(test_mobjHostName1)
end

return T_MObjHost
