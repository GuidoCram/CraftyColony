-- define class
local Class = require "class"
local MultipleValuesTest = require "multiple_values_test"
local IsBlueprintTest = Class.NewClass(MultipleValuesTest)

--[[
    This module implements the class IsBlueprintTest.

    It is a test class for (partly) testing if a result represents a Blueprint.
--]]

local Location = require "obj_location"

local TestArrayTest = require "test_array_test"
local ValueEqualTest = require "value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

-- ToDo: consider extending this test class by testing the blueprint a bit more in details.
--      Also take into account we want implement a Blueprint class, which likely replaces part of this test.
function IsBlueprintTest:_init(buildLocation)
    -- check input
    assert(Class.IsInstanceOf(buildLocation, Location), "Provided buildLocation argument "..textutils.serialise(buildLocation).." not aLocation")

    -- initialisation
    MultipleValuesTest._init(self,
        -- result value 1
        ValueEqualTest:newInstance(buildLocation),
        -- result value 2
        TestArrayTest:newInstance(
            FieldValueTypeTest:newInstance("layerList", "table"),
            FieldValueTypeTest:newInstance("escapeSequence", "table")
        )
    )
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function IsBlueprintTest:getClassName()
    return "IsBlueprintTest"
end

--    _____ _______        _
--   |_   _|__   __|      | |
--     | |    | | ___  ___| |_
--     | |    | |/ _ \/ __| __|
--    _| |_   | |  __/\__ \ |_
--   |_____|  |_|\___||___/\__|

return IsBlueprintTest
