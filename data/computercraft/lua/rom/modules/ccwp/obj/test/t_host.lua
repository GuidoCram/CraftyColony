local T_Host = {}

local corelog = require "corelog"

local IObj = require "i_obj"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local URL = require "obj_url"
local Host = require "host"
local ObjBase = require "obj_base"

local ObjTest = require "test.obj_test"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_Host.T_All()
    -- initialisation
    T_Host.T__init()
    T_Host.T_new()

    -- IObj
    T_Host.T_IObj_All()

    -- specific
    T_Host.T_getHostLocator()
    T_Host.T_isLocatorFromHost()
    T_Host.T_get_save_delete_Resource()

    -- class methods
    T_Host.T_GetHost()
end

local testClassName = "Host"
local testObjName = "host"
local logOk = false

local hostName0 = "TestHost"
local hostName2 = "TestHost2"

local host0 = Host:newInstance(hostName0)

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_Host.CreateTestObj(hostName)
    -- check input
    hostName = hostName0 or hostName

    -- create testObj
    local testObj = Host:newInstance(hostName)

    -- end
    return testObj
end

function T_Host.CreateInitialisedTest(hostName)
    -- check input

    -- create test
    local test = TestArrayTest:newInstance(
        FieldValueEqualTest:newInstance("_hostName", hostName)
    )

    -- end
    return test
end

function T_Host.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")

    -- test
    local obj = T_Host.CreateTestObj(hostName0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_Host.CreateInitialisedTest(hostName0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_Host.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test full
    local obj = Host:new({
        _hostName   = hostName0,
    })
    local test = T_Host.CreateInitialisedTest(hostName0)
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

function T_Host.T_IObj_All()
    -- prepare test
    local obj = T_Host.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_Host.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

local resource = {
    aNumber     = 10,
    aString     = "top",
    aTable      = {_x= -10, _y= 0, _z= 1, _dx=0, _dy=1},
}

local resourcePath1 = "/resource/ref=10/subid=7"

local function SameATable(aTable1, aTable2)
    if aTable1 == nil and aTable2 == nil then return true end
    if aTable1 == nil or aTable2 == nil then return false end

    return aTable1.x == aTable2.x and aTable1.y == aTable2.y and aTable1.z == aTable2.z and aTable1.dx == aTable2.dx and aTable1.dy == aTable2.dy
end

local function SameResource(res1, res2)
    if res1 == nil and res2 == nil then return true end
    if res1 == nil or res2 == nil then return false end

    return res1.aNumber == res2.aNumber and res1.aString == res2.aString and SameATable(res1.aTable, res2.aTable)
end

function T_Host.T_getHostLocator()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getHostLocator() tests")

    -- test
    local hostLocator = host0:getHostLocator()
    local expectedLocator = URL:newInstance(hostName0)
    assert(hostLocator:isEqual(expectedLocator), "getHostLocator(="..hostLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")

    -- cleanup test
end

function T_Host.T_isLocatorFromHost()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":isLocatorFromHost() tests")
    local hostLocator = host0:getHostLocator()

    -- test
    local isFromHost = host0:isLocatorFromHost(hostLocator)
    local expectedIsFromHost = true
    assert(isFromHost == expectedIsFromHost, "gotten isLocatorFromHost(="..tostring(isFromHost)..") not the same as expected(="..tostring(expectedIsFromHost)..")")

    -- test other Host
    local otherHost = Host:newInstance(hostName2)
    isFromHost = otherHost:isLocatorFromHost(hostLocator)
    expectedIsFromHost = false
    assert(isFromHost == expectedIsFromHost, "gotten isLocatorFromHost(="..tostring(isFromHost)..") not the same as expected(="..tostring(expectedIsFromHost)..")")

    -- cleanup test
end

function T_Host.T_get_save_delete_Resource()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getResource, saveResource, deleteResource tests")
    local resourceLocator = URL:newInstance(hostName0, resourcePath1)

    -- test getResource (not yet present)
    local resourceGotten = host0:getResource(resourceLocator)
    assert(not resourceGotten, "unexpected resource(="..textutils.serialize(resourceGotten, compact)..") obtained (i.e. not nil)")

    -- test save
    resourceLocator = host0:saveResource(resource, resourceLocator)
    local expectedLocator = URL:newInstance()
    expectedLocator:setHost(hostName0)
    expectedLocator:setPath(resourcePath1)
    assert(resourceLocator:isEqual(expectedLocator), "resourceLocator(="..resourceLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")

    -- test getResource (now present)
    resourceGotten = host0:getResource(resourceLocator)
    assert(SameResource(resource, resourceGotten), "gotten resource(="..textutils.serialize(resourceGotten, compact)..") not the same as expected(="..textutils.serialize(resource, compact)..")")

    -- test delete
    local deleteSuccess = host0:deleteResource(resourceLocator)
    assert(deleteSuccess, "delete not succesfull")

    -- test getResource (no longer present)
    resourceGotten = host0:getResource(resourceLocator)
    assert(not resourceGotten, "unexpected resource(="..textutils.serialize(resourceGotten, compact)..") obtained (i.e. not nil)")

    -- cleanup test
end

--         _                                _   _               _
--        | |                              | | | |             | |
--     ___| | __ _ ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--    / __| |/ _` / __/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | (__| | (_| \__ \__ \ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--    \___|_|\__,_|___/___/ |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--
--

function T_Host.T_GetHost()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..".GetHost(...) tests")
    local module = moduleRegistry:getRegistered(hostName0)
    assert(not module, "a module with name="..hostName0.." already registered")

    -- test not registered Host
    local obj = Host.GetHost(hostName0, true)
    assert(not obj, "unexpectedly got a Host with hostName="..hostName0)

    -- test registered Host
    moduleRegistry:register(hostName0, host0)
    obj = Host.GetHost(hostName0)
    assert(obj, "Host with hostName="..hostName0.." not gotten")
    moduleRegistry:delist(hostName0)

    -- test other registered object
    local otherTestObj = ObjTest:newInstance("field1", 4)
    local otherTestObjName = "testObj"
    moduleRegistry:register(otherTestObjName, otherTestObj)
    obj = Host.GetHost(otherTestObjName, true)
    assert(not obj, "unexpectedly got a 'Host' with name="..testObjName)
    moduleRegistry:delist(otherTestObjName)

    -- cleanup test
end

return T_Host
