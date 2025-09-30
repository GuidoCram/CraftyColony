-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ITest = require "i_test"
local ValueTypeTest = Class.NewClass(ObjBase, ITest)

--[[
    This module implements the class ValueTypeTest.

    It is a generic test class for testing the type of a value
--]]

local corelog = require "corelog"

local IObj = require "i_obj"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function ValueTypeTest:_init(expectedType)
    -- check input
    assert(type(expectedType) == "string", "expectedType not a string")

    -- initialisation
    self._expectedType = expectedType
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function ValueTypeTest:getClassName()
    return "ValueTypeTest"
end

--    _____ _______        _
--   |_   _|__   __|      | |
--     | |    | | ___  ___| |_
--     | |    | |/ _ \/ __| __|
--    _| |_   | |  __/\__ \ |_
--   |_____|  |_|\___||___/\__|

function ValueTypeTest:test(value, valueName, indent, logOk)
    -- check input
    assert(type(valueName) == "string", "no valid valueName provided")
    assert(type(indent) == "string", "no valid indent provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")

    -- prepare test
    local valueType = type(value)
    if valueType == "table" and Class.IsInstanceOf(value, IObj) then
        valueType = value:getClassName()
    end
    local testContextStr = valueName.." type "..valueType

    -- test
    assert(valueType == self._expectedType, indent..testContextStr.." not equal to expected type "..textutils.serialise(self._expectedType))

    -- complete test
    if logOk then corelog.WriteToLog(indent..testContextStr.." ok") end

    -- cleanup test
end

return ValueTypeTest
