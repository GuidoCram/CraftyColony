local T_WIPQueue = {}
local corelog = require "corelog"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local Callback = require "obj_callback"

local ObjArray = require "obj_array"
local WIPQueue = require "obj_wip_queue"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_WIPQueue.T_All()
    -- initialisation
    T_WIPQueue.T__init()
    T_WIPQueue.T_new()
    T_WIPQueue.T_addWork()
    T_WIPQueue.T_removeWork()
    T_WIPQueue.T_noWIP()
    T_WIPQueue.T_addCallback()

    -- IObj
    T_WIPQueue.T_IObj_All()

    -- specific
    T_WIPQueue.T_callAndReleaseCallbacks()
end

local testClassName = "WIPQueue"
local testObjName = "wipQueue"
local logOk = false

local workId1 = "id1"
local workId2 = "id2"
local workList1 = {
    workId1,
    workId2,
}
local workId = "id"
local callbackClassName = "Callback"
local callbackList1 = ObjArray:newInstance(callbackClassName) assert(callbackList1, "Failed obtaining callbackList1")
local callback1 = Callback.GetNewDummyCallBack()

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

local function workListCopy(workList)
    local copy = {}
    for i, aWorkId in ipairs(workList) do
        copy[i] = aWorkId
    end

    -- end
    return copy
end

function T_WIPQueue.CreateTestObj(workList, callbackList)
    -- check input
    workList = workList or workList1
    callbackList = callbackList or callbackList1

    -- create testObj
    local testObj = WIPQueue:newInstance(workListCopy(workList), callbackList:copy())

    -- end
    return testObj
end

function T_WIPQueue.CreateInitialisedTest(workList, callbackList)
    -- check input

    -- create test
    local test = TestArrayTest:newInstance(
        FieldValueEqualTest:newInstance("_workList", workList),
        FieldValueEqualTest:newInstance("_callbackList", callbackList)
    )

    -- end
    return test
end

function T_WIPQueue.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")

    -- test
    local obj = T_WIPQueue.CreateTestObj(workList1, callbackList1) assert(obj, "Failed obtaining "..testClassName)
    local test = T_WIPQueue.CreateInitialisedTest(workList1, callbackList1)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_WIPQueue.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test full
    local obj = WIPQueue:new({
        _workList       = workListCopy(workList1),
        _callbackList   = callbackList1:copy(),
    }) assert(obj)
    local test = T_WIPQueue.CreateInitialisedTest(workList1, callbackList1)
    test:test(obj, testObjName, "", logOk)

    assert(obj._workList[1] == workId1, "no workId1")
    assert(obj._workList[2] == workId2, "no workId2")
    assert(obj._callbackList:isEqual(callbackList1), "gotten _callbackList(="..textutils.serialise(obj._callbackList)..") not the same as expected(="..textutils.serialise(callbackList1)..")")

    -- cleanup test
end

local function hasWork(workList, someWorkId)
    for i, aWorkId in ipairs(workList) do
        if aWorkId == someWorkId then
            return true
        end
    end

    -- end
    return false
end

function T_WIPQueue.T_addWork()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":addWork() tests")
    local obj1 = T_WIPQueue.CreateTestObj() assert(obj1)
    assert(not hasWork(obj1._workList, workId), "workId already present")

    -- test
    obj1:addWork(workId)
    assert(hasWork(obj1._workList, workId), "workId not added")

    -- cleanup test
end

function T_WIPQueue.T_removeWork()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":removeWork() tests")
    local obj1 = T_WIPQueue.CreateTestObj() assert(obj1)
    obj1:addWork(workId)
    assert(hasWork(obj1._workList, workId), "workId not added")

    -- test
    obj1:removeWork(workId)
    assert(not hasWork(obj1._workList, workId), "workId not removed")

    -- cleanup test
end

function T_WIPQueue.T_noWIP()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":noWIP() tests")
    local obj1 = T_WIPQueue.CreateTestObj({}, callbackList1) assert(obj1)

    -- test noWIP
    local noWIP = obj1:noWIP()
    assert(noWIP, "unexpected WIP")

    -- test WIP
    obj1:addWork(workId)
    noWIP = obj1:noWIP()
    assert(not noWIP, "unexpected no WIP")

    -- cleanup test
end

local function hasCallback(callbackList, callback)
    for i, aCallback in ipairs(callbackList) do
        if aCallback:isEqual(callback) then
            return true
        end
    end

    -- end
    return false
end

function T_WIPQueue.T_addCallback()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":addCallback() tests")
    local obj1 = T_WIPQueue.CreateTestObj({}, callbackList1) assert(obj1)
    assert(not hasCallback(obj1._callbackList, callback1), "callback1 already present")

    -- test
    obj1:addCallback(callback1)
    assert(hasCallback(obj1._callbackList, callback1), "callback1 not added")

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

function T_WIPQueue.T_IObj_All()
    -- prepare test
    local obj = T_WIPQueue.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_WIPQueue.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

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

local callback2Called = false
local callback3Called = false

function T_WIPQueue.T_callAndReleaseCallbacks()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":callAndReleaseCallbacks() tests")
    local obj1 = T_WIPQueue.CreateTestObj({}, callbackList1) assert(obj1)

    local callback2 = Callback:newInstance("T_WIPQueue", "callAndReleaseCallbacks_Callback", { callbackName = "callback2", })
    obj1:addCallback(callback2)
    callback2Called = false

    local callback3 = Callback:newInstance("T_WIPQueue", "callAndReleaseCallbacks_Callback", { callbackName = "callback3", })
    obj1:addCallback(callback3)
    callback3Called = false

    -- test
    local succes = obj1:callAndReleaseCallbacks(callback1)
    assert(succes, "callAndReleaseCallbacks not a success")
    assert(callback2Called, "callback2 not called")
    assert(not hasCallback(obj1._callbackList, callback2), "callback2 not removed")
    assert(callback3Called, "callback3 not called")
    assert(not hasCallback(obj1._callbackList, callback3), "callback3 not removed")

    -- cleanup test
end

function T_WIPQueue.callAndReleaseCallbacks_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")

    -- callback2
    if callbackData["callbackName"] == "callback2" then
        callback2Called = true
    end

    -- callback3
    if callbackData["callbackName"] == "callback3" then
        callback3Called = true
    end

    -- cleanup test

    -- end
    return true
end

return T_WIPQueue
