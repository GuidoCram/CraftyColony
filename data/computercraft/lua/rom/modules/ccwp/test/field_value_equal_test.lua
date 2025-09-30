-- define class
local Class = require "class"
local FieldTest = require "field_test"
local FieldValueEqualTest = Class.NewClass(FieldTest)

--[[
    This module implements the class FieldValueEqualTest.

    It is a generic test class for testing the equality of a field of an object.
--]]

local ValueEqualTest = require "value_equal_test"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function FieldValueEqualTest:_init(fieldName, expectedValue)
    -- check input
    local fieldNameType = type(fieldName)
    assert(fieldNameType == "string" or fieldNameType == "number", "type fieldName(="..fieldNameType..") not a string or number")

    -- initialisation
    FieldTest._init(self, fieldName, ValueEqualTest:newInstance(expectedValue))
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function FieldValueEqualTest:getClassName()
    return "FieldValueEqualTest"
end

--    _____ _______        _
--   |_   _|__   __|      | |
--     | |    | | ___  ___| |_
--     | |    | |/ _ \/ __| __|
--    _| |_   | |  __/\__ \ |_
--   |_____|  |_|\___||___/\__|

return FieldValueEqualTest
