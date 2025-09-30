-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ITest = require "i_test"
local TestArrayTest = Class.NewClass(ObjBase, ITest)

--[[
    This module implements the class TestArrayTest.

    It is a generic test class for testing multiple (i.e. an array of) tests on an object.
--]]

local corelog = require "corelog"

function TestArrayTest:_init(...)
    -- check input
    local tests = {...}
    for i, test in ipairs(tests) do
        assert(Class.IsInstanceOf(test, ITest), "Provided argument "..i.." (="..textutils.serialise(test)..") not an ITest")
    end

    -- initialisation
    self._tests = tests
end

function TestArrayTest:test(testObj, testObjName, indent, logOk)
    -- check input
    assert(type(testObj) ~= "nil", "no valid testObj provided (shouldn't be nil)")
    assert(type(testObjName) == "string", "no valid testObjName provided")
    assert(type(indent) == "string", "no valid indent provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")

    -- prepare test
    local testFieldsStr = testObjName.." tests"

    -- test all tests
    assert(self._tests, indent..testFieldsStr..": no tests provided")
    for i, fieldTest in ipairs(self._tests) do
        -- test
        fieldTest:test(testObj, testObjName, indent.."  ", logOk)
    end

    -- complete test
    if logOk then corelog.WriteToLog(indent..testFieldsStr.." ok") end

    -- cleanup test
end

return TestArrayTest
