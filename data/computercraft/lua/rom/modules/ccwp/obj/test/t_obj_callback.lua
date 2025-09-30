local T_Callback = {}

local corelog = require "corelog"

local Callback = require "obj_callback"

function T_Callback.T_All()
    -- specific
    T_Callback.T_call()

    -- helper functions
    T_Callback.T_ErrorCall()
end

local moduleName1 = "T_Callback"
local methodName1 = "Call_Callback"
local data1 = {"some callback data"}

local compact = { compact = true }

local resultData1 = { someResult = "some result", success = true }

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function T_Callback.T_call()
    -- prepare test
    corelog.WriteToLog("* Callback:call() test")
    local callback = Callback:newInstance(moduleName1, methodName1, data1)

    -- test
    local callResult = callback:call(resultData1)
    local expectedCallResult = true
    assert(callResult == expectedCallResult, "gotten callResult(="..tostring(callResult)..") not the same as expected(="..tostring(expectedCallResult)..")")

    -- cleanup test
end

function T_Callback.Call_Callback(callbackData, resultData)
    -- test (cont)
    assert(callbackData == data1, "gotten callbackData(="..textutils.serialise(callbackData, compact)..") not the same as expected(="..textutils.serialise(data1, compact)..")")
    assert(resultData == resultData1, "gotten resultData(="..textutils.serialise(resultData, compact)..") not the same as expected(="..textutils.serialise(resultData1, compact)..")")

    -- end
    return true
end

--    _          _                    __                  _   _
--   | |        | |                  / _|                | | (_)
--   | |__   ___| |_ __   ___ _ __  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | '_ \ / _ \ | '_ \ / _ \ '__| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | | |  __/ | |_) |  __/ |    | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_| |_|\___|_| .__/ \___|_|    |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--                | |
--                |_|

function T_Callback.T_ErrorCall()
    -- prepare test
    corelog.WriteToLog("* Callback.ErrorCall() tests")
    local callback = Callback:newInstance(moduleName1, "ErrorCall_Callback", data1)

    -- test no callback returns false
    local callResult = callback.ErrorCall(nil)
    local expectedCallResult = false
    assert(callResult == expectedCallResult, "gotten callResult(="..tostring(callResult)..") not the same as expected(="..tostring(expectedCallResult)..")")

    -- test callback
    callResult = callback.ErrorCall(callback)
    expectedCallResult = true
    assert(callResult == expectedCallResult, "gotten callResult(="..tostring(callResult)..") not the same as expected(="..tostring(expectedCallResult)..")")

    -- cleanup test
end

function T_Callback.ErrorCall_Callback(callbackData, resultData)
    -- test (cont)
    assert(callbackData == data1, "gotten callbackData(="..textutils.serialise(callbackData, compact)..") not the same as expected(="..textutils.serialise(data1, compact)..")")
    local expectedSuccess = false
    assert(type(resultData) == "table", "gotten resultData(="..textutils.serialise(resultData, compact)..") not a table")
    assert(resultData.success == expectedSuccess, "gotten resultData.success(="..tostring(resultData.success)..") not the same as expected(="..tostring(expectedSuccess)..")")

    -- end
    return true
end

return T_Callback
