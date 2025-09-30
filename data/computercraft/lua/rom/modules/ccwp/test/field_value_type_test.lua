-- define class
local Class = require "class"
local FieldTest = require "field_test"
local FieldValueTypeTest = Class.NewClass(FieldTest)

--[[
    This module implements the class FieldValueTypeTest.

    It is a generic test class for testing the type of a field of an object.
--]]

local ValueTypeTest = require "value_type_test"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function FieldValueTypeTest:_init(fieldName, expectedType)
    -- check input
    assert(type(fieldName) == "string", "fieldName not a string")

    -- initialisation
    FieldTest._init(self, fieldName, ValueTypeTest:newInstance(expectedType))
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function FieldValueTypeTest:getClassName()
    return "FieldValueTypeTest"
end

--    _____ _______        _
--   |_   _|__   __|      | |
--     | |    | | ___  ___| |_
--     | |    | |/ _ \/ __| __|
--    _| |_   | |  __/\__ \ |_
--   |_____|  |_|\___||___/\__|

return FieldValueTypeTest
