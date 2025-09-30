local T_LObjLocator = {}

local corelog = require "corelog"
local coreutils = require "coreutils"

local Class = require "class"

local IObj = require "i_obj"
local ILObj = require "i_lobj"
local ObjBase = require "obj_base"
local ObjLocator = require "obj_locator"

local LObjLocator = require "lobj_locator"
local LObjTest = require "test.lobj_test"

local TestArrayTest = require "test_array_test"
local MethodResultEqualTest = require "method_result_equal_test"

local T_Class = require "test.t_class"
local T_ObjLocator = require "test.t_obj_locator"
local T_IObj = require "test.t_i_obj"
local T_LObjTest = require "test.t_lobj_test"

function T_LObjLocator.T_All()
    -- initialisation
    T_LObjLocator.T__init()
    T_LObjLocator.T_new()
    T_LObjLocator.T_Getters()

    -- IObj
    T_LObjLocator.T_IObj_All()
end

local testClassName = "LObjLocator"
local testObjName = "lobjLocator"
local logOk = false

local hostName0 = "TestObjHost"
local locatedLObj0 = T_LObjTest.CreateTestObj()

local noQuery = {}
local itemName0 = "minecraft:torch"
local itemCount0 = 5
local itemName1 = "minecraft:birch_log"
local itemCount1 = 3
local query0 = {[itemName0] = itemCount0, [itemName1] = itemCount1}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_LObjLocator.CreateTestObj(hostName, locatedLObj, query)
    -- check input
    hostName = hostName or hostName0
    locatedLObj = locatedLObj or locatedLObj0
    query = query or {[itemName0] = itemCount0, [itemName1] = itemCount1}

    -- create testObj
    local testObj = LObjLocator:newInstance(hostName, locatedLObj, query)

    -- end
    return testObj
end

function T_LObjLocator.CreateInitialisedTest(hostName, locatedLObj, query)
    -- check input
    assert(Class.IsInstanceOf(locatedLObj, ILObj), "locatedLObj not an ILObj")

    -- create test
    local objClassName = locatedLObj:getClassName()
    local objRef = locatedLObj:getId()

    local test = T_ObjLocator.CreateInitialisedTest(hostName, objClassName, objRef, query)

    -- end
    return test
end

function T_LObjLocator.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")

    -- test
    local obj = T_LObjLocator.CreateTestObj(hostName0, locatedLObj0, query0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_LObjLocator.CreateInitialisedTest(hostName0, locatedLObj0, query0)
    test:test(obj, testObjName, "", logOk)

    -- test default
    obj = LObjLocator:newInstance(hostName0, locatedLObj0)
    test = T_LObjLocator.CreateInitialisedTest(hostName0, locatedLObj0, noQuery)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_LObjLocator.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local locatedLObjClassName = locatedLObj0:getClassName()
    local objRef = locatedLObj0:getId()
    local objPath = "/objects/class="..locatedLObjClassName.."/ref="..objRef

    -- test full
    local obj = LObjLocator:new({
        _host   = hostName0,
        _path   = objPath,
        _query  = query0,
        _port   = nil,
    })
    local test = T_LObjLocator.CreateInitialisedTest(hostName0, locatedLObj0, query0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_LObjLocator.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." base getter tests")
    local obj = T_LObjLocator.CreateTestObj(hostName0, locatedLObj0, query0) assert(obj, "Failed obtaining "..testClassName)
    local locatedLObjId = locatedLObj0:getId()

    -- test
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getObjId", locatedLObjId)
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

function T_LObjLocator.T_IObj_All()
    -- prepare test
    local obj = T_LObjLocator.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_LObjLocator.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjLocator", ObjLocator) -- ToDo: is this the right place to put this statement (as it's not IObj related)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

return T_LObjLocator
