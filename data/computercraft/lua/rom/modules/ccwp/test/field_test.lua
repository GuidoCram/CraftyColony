-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ITest = require "i_test"
local FieldTest = Class.NewClass(ObjBase, ITest)

--[[
    This module implements the class FieldTest.

    It is a generic test class for testing a field of an object.
--]]

local corelog = require "corelog"

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function FieldTest:_init(fieldName, fieldTest)
    -- check input
    local fieldNameType = type(fieldName)
    assert(fieldNameType == "string" or fieldNameType == "number", "type fieldName(="..fieldNameType..") not a string or number")
    assert(Class.IsInstanceOf(fieldTest, ITest), "Provided fieldTest argument not an ITest")

    -- initialisation
    self._fieldName     = fieldName
    self._fieldTest     = fieldTest
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function FieldTest:getClassName()
    return "FieldTest"
end

--    _____ _______        _
--   |_   _|__   __|      | |
--     | |    | | ___  ___| |_
--     | |    | |/ _ \/ __| __|
--    _| |_   | |  __/\__ \ |_
--   |_____|  |_|\___||___/\__|

function FieldTest:test(testObj, testObjName, indent, logOk)
    -- check input
    assert(type(testObjName) == "string", "no valid testObjName provided")
    assert(type(indent) == "string", "no valid indent provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")

    -- prepare test
    local testFieldStr = testObjName.."."..self._fieldName.." field"

    local fieldValue = testObj[self._fieldName]
    if self._fieldTest._expectedType ~= "nil" then
--        assert(fieldValue, indent..testFieldStr..": test "..testObjName.."(="..textutils.serialise(testObj, compact)..") does not have field")
        assert(type(fieldValue) ~= "nil", indent..testFieldStr..": test "..testObjName.." does not have field") -- note: serialising testObj is a bit dangerous as it might contain functions
    end

    -- test (via _fieldTest)
    self._fieldTest:test(fieldValue, testFieldStr, indent.."  ", logOk)

    -- complete test
    if logOk then corelog.WriteToLog(indent..testFieldStr.." ok") end

    -- cleanup test
end

return FieldTest
