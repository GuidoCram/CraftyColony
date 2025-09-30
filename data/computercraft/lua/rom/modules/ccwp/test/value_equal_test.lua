-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ITest = require "i_test"
local ValueEqualTest = Class.NewClass(ObjBase, ITest)

--[[
    This module implements the class ValueEqualTest.

    It is a generic test class for testing the equality of two values
--]]

local corelog = require "corelog"

local IObj = require "i_obj"

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function ValueEqualTest:_init(expectedValue)
    -- initialisation
    self._expectedValue = expectedValue
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function ValueEqualTest:getClassName()
    return "ValueEqualTest"
end

--    _____ _______        _
--   |_   _|__   __|      | |
--     | |    | | ___  ___| |_
--     | |    | |/ _ \/ __| __|
--    _| |_   | |  __/\__ \ |_
--   |_____|  |_|\___||___/\__|

local function anActualTest(expectedValue, value, valueName, indent, logOk)
    -- prepare test
    local testContextStr = valueName.." value "..textutils.serialise(value, compact)

    -- check expectedValue type
    if Class.IsInstanceOf(expectedValue, IObj) then
        assert(value:isEqual(expectedValue), indent..testContextStr.." not equal to expected IObj value "..textutils.serialise(expectedValue, compact))
    elseif type(expectedValue) == "table" then
        assert(type(value) == "table", indent..testContextStr.." not equal to expected type table")
        for key, expTblValue in pairs(expectedValue) do
            -- nested test
            local tblValue = value[key]
            local tblValueName = valueName.." sub field "..key
            anActualTest(expTblValue, tblValue, tblValueName, indent.."  ", logOk)

            -- complete nested test
            local testTblContextStr = tblValueName.." value "..textutils.serialise(tblValue, compact)
            if logOk then corelog.WriteToLog(indent.."  "..testTblContextStr.." ok") end
        end
        -- ToDo: consider testing for additional keys in value (see also ObjBase)
    else
        assert(value == expectedValue, indent..testContextStr.." not equal to expected value "..textutils.serialise(expectedValue, compact))
    end
end

function ValueEqualTest:test(value, valueName, indent, logOk)
    -- check input
    assert(type(valueName) == "string", "no valid valueName provided")
    assert(type(indent) == "string", "no valid indent provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")

    -- prepare test
    local testContextStr = valueName.." value "..textutils.serialise(value, compact)

    -- test
    anActualTest(self._expectedValue, value, valueName, indent, logOk)

    -- complete test
    if logOk then corelog.WriteToLog(indent..testContextStr.." ok") end

    -- cleanup test
end

return ValueEqualTest
