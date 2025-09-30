local t_test = {}

local corelog = require "corelog"

local Callback = require "obj_callback"

local enterprise_test = require "test.enterprise_test"

local testValue = 20
local testData = {
    testArg = testValue,
}
local callbackTestValue = "some callback data"

function t_test.T_All()
    t_test.T_Test_SSrv()
    t_test.T_Test_ASrv()
end

function t_test.T_Test_SSrv()
    -- prepare test
    corelog.WriteToLog("* enterprise_test.Test_SSrv() test")

    -- test
    local serviceResults = enterprise_test.Test_SSrv(testData)
    assert(serviceResults.success, "failed executing sync service")

    local input = serviceResults.input
    local expectedInput = testValue
    assert(input == expectedInput, "gotten input(="..input..") not the same as expected(="..expectedInput..")")

    -- cleanup test
end

function t_test.T_Test_ASrv()
    -- prepare test
    corelog.WriteToLog("* enterprise_test.Test_ASrv() test")
    local callback = Callback:newInstance("t_test", "Test_ASrv_Callback", { [0] = callbackTestValue })

    -- test
    return enterprise_test.Test_ASrv(testData, callback)
end

function t_test.Test_ASrv_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")
    local arg1 = serviceResults.input
    local expectedArg1 = testValue
    assert(arg1 == expectedArg1, "gotten arg1(="..arg1..") not the same as expected(="..expectedArg1..")")
    local callbackValue = callbackData[0]
    local expectedCallbackValue = callbackTestValue
    assert(callbackValue == expectedCallbackValue, "gotten callbackValue(="..(callbackValue or "nil")..") not the same as expected(="..expectedCallbackValue..")")

    -- cleanup test
end

return t_test
