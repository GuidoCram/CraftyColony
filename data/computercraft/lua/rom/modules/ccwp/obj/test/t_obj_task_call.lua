local T_TaskCall = {}

local corelog = require "corelog"

local TaskCall = require "obj_task_call"

function T_TaskCall.T_All()
    -- initialisation methods

    -- specific
    T_TaskCall.T_call()
end

local moduleName1 = "T_TaskCall"
local methodName1 = "Test_Task"
local taskData1 = {"some task data"}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function T_TaskCall.T_call()
    -- prepare test
    corelog.WriteToLog("* TaskCall:call() test")
    local taskCall = TaskCall:newInstance(moduleName1, methodName1, taskData1)

    -- test
    local callResult = taskCall:call()
    local expectedSuccess = true
    assert(type(callResult) == "table", "gotten callResult(="..textutils.serialise(callResult, compact)..") not a table")
    assert(callResult.success == expectedSuccess, "gotten callResult.success(="..tostring(callResult.success)..") not the same as expected(="..tostring(expectedSuccess)..")")

    -- cleanup test
end

function T_TaskCall.Test_Task(taskData)
    -- test (cont)
    assert(taskData == taskData1, "gotten taskData(="..textutils.serialise(taskData, compact)..") not the same as expected(="..textutils.serialise(taskData1, compact)..")")

    -- end
    local result = {
        success = true,
    }
    return result
end

return T_TaskCall
