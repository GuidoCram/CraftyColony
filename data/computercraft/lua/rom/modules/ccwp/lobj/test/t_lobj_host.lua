local T_LObjHost = {}

local corelog = require "corelog"

local Class = require "class"
local IObj = require "i_obj"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local ObjBase = require "obj_base"

local ObjLocator = require "obj_locator"
local ObjHost = require "obj_host"

local LObjHost = require "lobj_host"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

local T_LObjTest = require "test.t_lobj_test"

function T_LObjHost.T_All()
    -- initialisation
    T_LObjHost.T_new()

    -- IObj
    T_LObjHost.T_IObj_All()

    -- LObjHost
    T_LObjHost.T_hostLObj_SSrv_LObjTest()
    T_LObjHost.T_upgradeLObj_SSrv_LObjTest()
    T_LObjHost.T_releaseLObj_SSrv_LObjTest()
end

local testClassName = "LObjHost"
local testObjName = "host"
local logOk = false

local test_lobjHostName0 = "TestMObjHost"
local test_lobjHost0 = LObjHost:newInstance(test_lobjHostName0)

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_LObjHost.CreateTestObj(hostName)
    -- check input
    hostName = test_lobjHostName0 or hostName

    -- create testObj
    local testObj = LObjHost:newInstance(hostName)

    -- end
    return testObj
end

function T_LObjHost.CreateInitialisedTest(hostName)
    -- check input

    -- create test
    local test = TestArrayTest:newInstance(
        FieldValueEqualTest:newInstance("_hostName", hostName)
    )

    -- end
    return test
end

function T_LObjHost.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test full
    local obj = LObjHost:new({
        _hostName   = test_lobjHostName0,
    })
    local test = T_LObjHost.CreateInitialisedTest(test_lobjHostName0)
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

function T_LObjHost.T_IObj_All()
    -- prepare test
    local obj = T_LObjHost.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_LObjHost.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjHost", ObjHost) -- ToDo: consider moving to different section
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--    _      ____  _     _ _    _           _
--   | |    / __ \| |   (_) |  | |         | |
--   | |   | |  | | |__  _| |__| | ___  ___| |_
--   | |   | |  | | '_ \| |  __  |/ _ \/ __| __|
--   | |___| |__| | |_) | | |  | | (_) \__ \ |_
--   |______\____/|_.__/| |_|  |_|\___/|___/\__|
--                     _/ |
--                    |__/

-- ** parameterised service tests **

function T_LObjHost.pt_hostLObj_SSrv(mobjHost, className, constructParameters, objName, fieldsTest, logOk)
    -- prepare test
    assert(type(mobjHost) =="table", "no valid mobjHost provided")
    assert(type(className) == "string", "no valid className provided")
    assert(type(constructParameters) == "table", "no valid constructParameters provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(fieldsTest) == "table", "no valid fieldsTest provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog("* "..mobjHost:getHostName()..":hostLObj_SSrv() tests (of "..objName..")")

    -- test
    local serviceResults = mobjHost:hostLObj_SSrv({
        className           = className,
        constructParameters = constructParameters,
    })

    -- check: hosting success
    assert(serviceResults and serviceResults.success, "failed hosting "..className)

    -- check: mobjLocator returned
    local mobjLocator = serviceResults.mobjLocator
    assert(Class.IsInstanceOf(mobjLocator, ObjLocator), "incorrect mobjLocator returned")

    -- check: mobj saved
    local mobj = mobjHost:getObj(mobjLocator)
    assert(mobj, className.." not in host")

    -- check: mobj constructed (i.e. fields initialised as expected)
    fieldsTest:test(mobj, objName, "", logOk)

    -- check: child MObj's hosted
    -- ToDo: consider implementing testing this. Or shouldn't we as it's a choice to have/ responsibilty of the MObj to do this?

    -- cleanup test
    mobj:destruct()
    mobjHost:deleteResource(mobjLocator)
    if logOk then corelog.WriteToLog(" ok") end

    -- return results
    return serviceResults
end

function T_LObjHost.pt_upgradeLObj_SSrv(mobjHost, className, constructParameters, upgradeParameters, objName, fieldsTest, logOk)
    -- prepare test
    assert(type(mobjHost) =="table", "no valid mobjHost provided")
    assert(type(className) == "string", "no valid className provided")
    assert(type(constructParameters) == "table", "no valid constructParameters provided")
    assert(type(upgradeParameters) == "table", "no valid upgradeParameters provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(fieldsTest) == "table", "no valid fieldsTest provided")
    corelog.WriteToLog("* "..mobjHost:getHostName()..":upgradeLObj_SSrv() tests (of "..objName..")")

    local serviceResults = mobjHost:hostLObj_SSrv({
        className           = className,
        constructParameters = constructParameters,
    }) assert(serviceResults, "failed hosting "..className)
    local mobjLocator = serviceResults.mobjLocator

    -- test
    serviceResults = mobjHost:upgradeLObj_SSrv({
        mobjLocator         = mobjLocator,
        upgradeParameters   = upgradeParameters,
    })

    -- check: service success
    assert(serviceResults and serviceResults.success, "failed upgrading "..mobjLocator:getURI())

    -- check: mobj saved
    local mobj = mobjHost:getObj(mobjLocator)
    assert(mobj, mobjLocator:getURI().." not in host")

    -- check: mobj upgraded (i.e. fields values as expected)
    fieldsTest:test(mobj, objName, "", logOk)

    -- cleanup test
    mobj:destruct()
    mobjHost:deleteResource(mobjLocator)
    if logOk then corelog.WriteToLog(" ok") end

    -- return results
    return serviceResults
end

function T_LObjHost.pt_releaseLObj_SSrv(mobjHost, className, constructParameters, objName, logOk)
    -- prepare test
    assert(type(mobjHost) =="table", "no valid mobjHost provided")
    assert(type(className) == "string", "no valid className provided")
    assert(type(constructParameters) == "table", "no valid constructParameters provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog("* "..mobjHost:getHostName()..":releaseLObj_SSrv() tests (of "..objName..")")

    local serviceResults = mobjHost:hostLObj_SSrv({
        className           = className,
        constructParameters = constructParameters,
    }) assert(serviceResults, "failed hosting "..className)
    local mobjLocator = serviceResults.mobjLocator

    -- test
    serviceResults = mobjHost:releaseLObj_SSrv({
        mobjLocator         = mobjLocator,
    })

    -- check: releasing success
    assert(serviceResults and serviceResults.success, "failed releasing "..mobjLocator:getURI())

    -- check: mobj deleted
    local mobjResourceTable = mobjHost:getResource(mobjLocator)
    assert(not mobjResourceTable, mobjLocator:getURI().." not deleted")

    -- check child MObj's released
    -- ToDo: consider implementing testing this. Or shouldn't we as it's a responsibilty of the MObj to do this?

    -- cleanup test
    if logOk then corelog.WriteToLog(" ok") end

    -- return results
    return serviceResults
end

-- ** LObjTest **

local testLObjClassName = "LObjTest"
local testLObjName = "lobjTest"
local field1_1 = "field1 1"
local field1_2 = "field1 2"
local constructParameters1 = {
    field1Value     = field1_1,
}
local upgradeParameters2 = {
    field1 = field1_2
}

function T_LObjHost.T_hostLObj_SSrv_LObjTest()
    -- prepare test
    local constructFieldsTest = T_LObjTest.CreateInitialisedTest(nil, field1_1)

    -- test
    local serviceResults = T_LObjHost.pt_hostLObj_SSrv(test_lobjHost0, testLObjClassName, constructParameters1, testLObjName, constructFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function T_LObjHost.T_upgradeLObj_SSrv_LObjTest()
    -- prepare test
    moduleRegistry:register(test_lobjHostName0, test_lobjHost0)
    local upgradeFieldsTest = T_LObjTest.CreateInitialisedTest(nil, field1_2)

    -- test
    local serviceResults = T_LObjHost.pt_upgradeLObj_SSrv(test_lobjHost0, testLObjClassName, constructParameters1, upgradeParameters2, testLObjName, upgradeFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    moduleRegistry:delist(test_lobjHostName0)
end

function T_LObjHost.T_releaseLObj_SSrv_LObjTest()
    -- prepare test
    moduleRegistry:register(test_lobjHostName0, test_lobjHost0)

    -- test
    local serviceResults = T_LObjHost.pt_releaseLObj_SSrv(test_lobjHost0, testLObjClassName, constructParameters1, testLObjName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    moduleRegistry:delist(test_lobjHostName0)
end

return T_LObjHost
