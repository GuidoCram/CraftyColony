-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ITest = require "i_test"
local MultipleValuesTest = Class.NewClass(ObjBase, ITest)

--[[
    This module implements the class MultipleValuesTest.

    It is a generic test class for testing multitude values.
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

function MultipleValuesTest:_init(...)
    -- check input
    local valuesTests = {...}
    for i, valueTest in ipairs(valuesTests) do
        assert(Class.IsInstanceOf(valueTest, ITest), "Provided valueTest argument "..textutils.serialise(valueTest).." not an ITest")
    end

    -- initialisation
    self._valueTests = valuesTests
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function MultipleValuesTest:getClassName()
    return "MultipleValuesTest"
end

--    _____ _______        _
--   |_   _|__   __|      | |
--     | |    | | ___  ___| |_
--     | |    | |/ _ \/ __| __|
--    _| |_   | |  __/\__ \ |_
--   |_____|  |_|\___||___/\__|

function MultipleValuesTest:test(values, valuesName, indent, logOk)
    -- check input
    assert(type(valuesName) == "string", "no valid valuesName provided")
    assert(type(indent) == "string", "no valid indent provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")

    -- prepare test
--    local testContextStr = valuesName.." values "..textutils.serialise(values, compact)
    local testContextStr = valuesName.." values" -- note: serialising values is a bit dangerous as it might contain functions

    -- test all tests
    assert(self._valueTests, indent..testContextStr..": no tests provided")
    for i, valueTest in ipairs(self._valueTests) do
        -- test
        local value = values[i]
        valueTest:test(value, valuesName.."["..i.."]", indent.."  ", logOk)
    end

    -- complete test
    if logOk then corelog.WriteToLog(indent..testContextStr.." ok") end

    -- cleanup test
end

return MultipleValuesTest
