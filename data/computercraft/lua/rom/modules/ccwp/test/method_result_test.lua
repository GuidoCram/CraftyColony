-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ITest = require "i_test"
local MethodResultTest = Class.NewClass(ObjBase, ITest)

--[[
    This module implements the class MethodResultTest.

    It is a generic test class for testing the results of a method call on an object.
--]]

local corelog = require "corelog"

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function MethodResultTest:_init(methodName, isStaticMethod, resultTest, ...)
    -- check input
    assert(type(methodName) == "string", "no valid methodName provided")
    assert(type(isStaticMethod) == "boolean", "no valid isStaticMethod provided")
    assert(Class.IsInstanceOf(resultTest, ITest), "Provided resultTest argument not an ITest")
    local methodArguments = {...}

    -- initialisation
    self._resultTest        = resultTest
    self._methodName        = methodName
    self._isStaticMethod    = isStaticMethod
    self._methodArguments   = methodArguments
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function MethodResultTest:getClassName()
    return "MethodResultTest"
end

--    _____ _______        _
--   |_   _|__   __|      | |
--     | |    | | ___  ___| |_
--     | |    | |/ _ \/ __| __|
--    _| |_   | |  __/\__ \ |_
--   |_____|  |_|\___||___/\__|

function MethodResultTest:test(testObj, testObjName, indent, logOk)
    -- check input
    assert(type(testObjName) == "string", "no valid testObjName provided")
    assert(type(indent) == "string", "no valid indent provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")

    -- prepare test
    local testFieldStr = testObjName..":"..self._methodName.."() result"

    local method = testObj[self._methodName]
    assert(method, indent..testFieldStr..": test "..testObjName.."(="..textutils.serialise(testObj, compact)..") does not have method")

    -- test (via _resultTest)
    local methodResults = nil
    if self._isStaticMethod then
        methodResults = {method(table.unpack(self._methodArguments))} -- note: collect possible multiple results
    else
        methodResults = {method(testObj, table.unpack(self._methodArguments))} -- note: collect possible multiple results
    end
    self._resultTest:test(methodResults, testFieldStr, indent.."  ", logOk)

    -- complete test
    if logOk then corelog.WriteToLog(indent..testFieldStr.." ok") end

    -- cleanup test
end

return MethodResultTest
