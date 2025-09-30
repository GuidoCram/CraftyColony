local T_ObjHost = {}

local coreutils = require "coreutils"
local corelog = require "corelog"

local IObj = require "i_obj"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local ObjLocator = require "obj_locator"

local ObjBase = require "obj_base"
local ObjHost = require "obj_host"

local ObjTest = require "test.obj_test"

local LObjTest = require "test.lobj_test"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_ObjHost.T_All()
    -- initialisation
    T_ObjHost.T__init()
    T_ObjHost.T_new()

    -- ObjHost
    T_ObjHost.T_saveObj()
    T_ObjHost.T_getObj()
    T_ObjHost.T_getNumberOfObjects()
    T_ObjHost.T_deleteObjects()

    -- class methods
    T_ObjHost.T_GetObj()
end

local testClassName = "ObjHost"
local testObjName = "objHost"
local logOk = false

local hostName1 = "TestObjHost"

local objHost1 = ObjHost:newInstance(hostName1)

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_ObjHost.CreateTestObj(hostName)
    -- check input
    hostName = hostName1 or hostName

    -- create testObj
    local testObj = ObjHost:newInstance(hostName)

    -- end
    return testObj
end

function T_ObjHost.CreateInitialisedTest(hostName)
    -- check input

    -- create test
    local test = TestArrayTest:newInstance(
        FieldValueEqualTest:newInstance("_hostName", hostName)
    )

    -- end
    return test
end

function T_ObjHost.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")

    -- test
    local obj = T_ObjHost.CreateTestObj(hostName1) assert(obj, "Failed obtaining "..testClassName)
    local test = T_ObjHost.CreateInitialisedTest(hostName1)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_ObjHost.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test full
    local obj = ObjHost:new({
        _hostName   = hostName1,
    })
    local test = T_ObjHost.CreateInitialisedTest(hostName1)
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

function T_ObjHost.T_IObj_All()
    -- prepare test
    local obj = T_ObjHost.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_ObjHost.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--     ____  _     _ _    _           _
--    / __ \| |   (_) |  | |         | |
--   | |  | | |__  _| |__| | ___  ___| |_
--   | |  | | '_ \| |  __  |/ _ \/ __| __|
--   | |__| | |_) | | |  | | (_) \__ \ |_
--    \____/|_.__/| |_|  |_|\___/|___/\__|
--               _/ |
--              |__/

local testObj = ObjTest:newInstance("field1", 4)
local testObjClassName = "ObjTest"

function T_ObjHost.T_saveObj()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":saveObj tests")
    local objRef = "someRef"
    local objId = coreutils.NewId()
    local testLObj = LObjTest:newInstance(objId, "field1")
    local testLObjClassName = "LObjTest"

    -- test with supplying objRef (Obj)
    local objLocator = objHost1:saveObj(testObj, objRef)
    local expectedLocator = ObjLocator:newInstance(hostName1, testObjClassName, objRef)
    assert(objLocator:isEqual(expectedLocator), "objLocator(="..objLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")
    objHost1:deleteResource(objLocator)
    assert(not objHost1:getResource(objLocator), "resource not deleted")

    -- test without supplying objRef (Obj)
    objLocator = objHost1:saveObj(testObj)
    expectedLocator = ObjLocator:newInstance(hostName1, testObjClassName)
    assert(objLocator:isEqual(expectedLocator), "objLocator(="..objLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")
    objHost1:deleteResource(objLocator)
    assert(not objHost1:getResource(objLocator), "resource not deleted")

    -- test with supplying objRef (LObj)
    objLocator = objHost1:saveObj(testLObj, objRef)
    expectedLocator = ObjLocator:newInstance(hostName1, testLObjClassName, objRef)
    assert(objLocator:isEqual(expectedLocator), "objLocator(="..objLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")
    objHost1:deleteResource(objLocator)
    assert(not objHost1:getResource(objLocator), "resource not deleted")

    -- test without supplying objRef (LObj)
    objLocator = objHost1:saveObj(testLObj)
    expectedLocator = ObjLocator:newInstance(hostName1, testLObjClassName, testLObj:getId())
    assert(objLocator:isEqual(expectedLocator), "objLocator(="..objLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")
    objHost1:deleteResource(objLocator)
    assert(not objHost1:getResource(objLocator), "resource not deleted")

    -- cleanup test
end

function T_ObjHost.T_getObj()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getObj tests")
    local objLocator = objHost1:saveObj(testObj)

    -- test get object
    local object = objHost1:getObj(objLocator)
    assert(object:isEqual(testObj), "object(="..textutils.serialise(object, compact)..") not the same as expected(="..textutils.serialise(testObj, compact)..")")

    -- cleanup test
    objHost1:deleteResource(objLocator)
    assert(not objHost1:getResource(objLocator), "resource not deleted")
end

function T_ObjHost.T_getNumberOfObjects()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getNumberOfObjects tests")
    local originalNObjects = objHost1:getNumberOfObjects(testObjClassName)
    local objectId = coreutils.NewId()

    -- test
    local objLocator = objHost1:saveObj(testObj, objectId) -- add an extra object
    local nObjects = objHost1:getNumberOfObjects(testObjClassName)
    local expectedNObjects = originalNObjects + 1
    assert(nObjects == expectedNObjects, "gotten nObjects(="..nObjects..") not the same as expected(="..expectedNObjects..")")

    -- cleanup test
    objHost1:deleteResource(objLocator)
    nObjects = objHost1:getNumberOfObjects(testObjClassName)
    assert(nObjects == originalNObjects, "gotten nObjects(="..nObjects..") not the same as expected(="..originalNObjects..")")
end

function T_ObjHost.T_deleteObjects()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":deleteObjects tests")

    -- test
    objHost1:deleteObjects(testObjClassName)
    local nObjects = objHost1:getNumberOfObjects(testObjClassName)
    local expectedNObjects = 0
    assert(nObjects == expectedNObjects, "gotten nObjects(="..nObjects..") not the same as expected(="..expectedNObjects..")")

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

function T_ObjHost.T_GetObj()
    -- prepare test
    corelog.WriteToLog("* ObjHost.GetObj(...) tests")
    moduleRegistry:register(hostName1, objHost1)

    -- test get Obj hosted by objHost1
    local objLocator = objHost1:saveObj(testObj)
    local obj = ObjHost.GetObj(objLocator)
    assert(obj and obj:isEqual(testObj), "obj(="..textutils.serialise(obj, compact)..") not the same as expected(="..textutils.serialise(testObj, compact)..")")

    -- test get objHost1 from itself
    local hostLocator = objHost1:getHostLocator()
    obj = ObjHost.GetObj(hostLocator)
    assert(obj and obj:isEqual(objHost1), "obj(="..textutils.serialise(obj, compact)..") not the same as expected(="..textutils.serialise(testObj, compact)..")")

    -- cleanup test
    objHost1:deleteResource(objLocator)
    moduleRegistry:delist(hostName1)
end

return T_ObjHost
