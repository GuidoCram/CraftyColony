local T_IWorker = {}
local corelog = require "corelog"

local IWorker = require "i_worker"

local T_IInterface = require "test.t_i_interface"
local T_Class = require "test.t_class"

local MethodResultTest = require "method_result_test"
local MultipleValuesTest = require "multiple_values_test"
local MethodResultEqualTest = require "method_result_equal_test"

function T_IWorker.pt_all(className, obj, objName, expectedWorkerLocation, workerResumeTest, isMainUIMenuTest, assignmentFilterTest, logOk)
    -- type
    T_IWorker.pt_IsInstanceOf_IWorker(className, obj)
    T_IWorker.pt_Implements_IWorker(className, obj)

    -- IWorker methods
    T_IWorker.pt_getWorkerId(className, obj, objName, nil, logOk)
    T_IWorker.pt_active(className, obj, objName, logOk)
    T_IWorker.pt_getWorkerLocation(className, obj, objName, expectedWorkerLocation, logOk)
    T_IWorker.pt_getWorkerResume(className, obj, objName, workerResumeTest, logOk)
    T_IWorker.pt_getMainUIMenu(className, obj, objName, isMainUIMenuTest, logOk)
    T_IWorker.pt_getAssignmentFilter(className, obj, objName, assignmentFilterTest, logOk)
end

--    _
--   | |
--   | |_ _   _ _ __   ___
--   | __| | | | '_ \ / _ \
--   | |_| |_| | |_) |  __/
--    \__|\__, | .__/ \___|
--         __/ | |
--        |___/|_|

function T_IWorker.pt_IsInstanceOf_IWorker(className, obj)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")

    -- test
    T_Class.pt_IsInstanceOf(className, obj, "IWorker", IWorker)
end

function T_IWorker.pt_Implements_IWorker(className, obj)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")

    -- test
    T_IInterface.pt_ImplementsInterface("IWorker", IWorker, className, obj)
end

--    _______          __        _
--   |_   _\ \        / /       | |
--     | |  \ \  /\  / /__  _ __| | _____ _ __
--     | |   \ \/  \/ / _ \| '__| |/ / _ \ '__|
--    _| |_   \  /\  / (_) | |  |   <  __/ |
--   |_____|   \/  \/ \___/|_|  |_|\_\___|_|

function T_IWorker.pt_getWorkerId(className, obj, objName, expectedWorkerId, logOk)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")
    assert(type(objName) == "string", "no valid objName provided")
    expectedWorkerId = expectedWorkerId or obj._workerId
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog("* "..className..":getWorkerId() test")

    -- test
    local test = MethodResultEqualTest:newInstance("getWorkerId", expectedWorkerId)
    test:test(obj, objName, "", logOk)
end

function T_IWorker.pt_active(className, obj, objName, logOk)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")

    -- test activate
    corelog.WriteToLog("* "..className.." activate tests")
    local test = MethodResultEqualTest:newInstance("activate", true)
    test:test(obj, objName, "", logOk)
    test = MethodResultEqualTest:newInstance("isActive", true)
    test:test(obj, objName, "", logOk)

    -- test deactivate
    corelog.WriteToLog("* "..className.." deactivate tests")
    test = MethodResultEqualTest:newInstance("deactivate", true)
    test:test(obj, objName, "", logOk)
    test = MethodResultEqualTest:newInstance("isActive", false)
    test:test(obj, objName, "", logOk)

    -- test
end

function T_IWorker.pt_getWorkerLocation(className, obj, objName, expectedWorkerLocation, logOk)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(expectedWorkerLocation) == "table", "no valid expectedWorkerLocation provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog("* "..className..":getWorkerLocation() test")

    -- test
    local test = MethodResultEqualTest:newInstance("getWorkerLocation", expectedWorkerLocation)
    test:test(obj, objName, "", logOk)
end

function T_IWorker.pt_getWorkerResume(className, obj, objName, workerResumeTest, logOk)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(workerResumeTest) == "table", "no valid workerResumeTest provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog("* "..className..":getWorkerResume() tests")

    -- test
    local test = MethodResultTest:newInstance("getWorkerResume", false, MultipleValuesTest:newInstance(workerResumeTest))
    test:test(obj, objName, "", logOk)
end

function T_IWorker.pt_getMainUIMenu(className, obj, objName, isMainUIMenuTest, logOk)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(isMainUIMenuTest) == "table", "no valid isMainUIMenuTest provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog("* "..className..":getMainUIMenu() tests")

    -- test
    local test = MethodResultTest:newInstance("getMainUIMenu", false, MultipleValuesTest:newInstance(isMainUIMenuTest))
    test:test(obj, objName, "", logOk)
end

function T_IWorker.pt_getAssignmentFilter(className, obj, objName, assignmentFilterTest, logOk)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(assignmentFilterTest) == "table", "no assignmentFilterTest provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog("* "..className..":getAssignmentFilter() tests")

    -- test
    local test = MethodResultTest:newInstance("getAssignmentFilter", false, MultipleValuesTest:newInstance(assignmentFilterTest))
    test:test(obj, objName, "", logOk)
end

return T_IWorker
