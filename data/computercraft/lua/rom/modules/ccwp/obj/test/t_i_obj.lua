local T_IObj = {}
local corelog = require "corelog"

local Class = require "class"
local IObj = require "i_obj"

function T_IObj.pt_all(className, obj, otherObj)
    -- IObj
    T_IObj.pt_getClassName(className, obj)
    T_IObj.pt_isEqual(className, obj, otherObj)
    T_IObj.pt_copy(className, obj)
end

local compact = { compact = true }

--    _
--   | |
--   | |_ _   _ _ __   ___
--   | __| | | | '_ \ / _ \
--   | |_| |_| | |_) |  __/
--    \__|\__, | .__/ \___|
--         __/ | |
--        |___/|_|

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function T_IObj.pt_getClassName(className, obj)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")
    corelog.WriteToLog("* "..className..":getClassName() tests")

    -- test
    assert(obj:getClassName() == className, "gotten className(="..obj:getClassName()..") not the same as expected(="..className..")")

    -- cleanup test
end

local function pt_isNotEqual_anotherValue(obj, otherObj, otherTable, fieldName, fieldValue, anotherFieldValue)
    -- change value
    otherTable[fieldName] = anotherFieldValue

    -- test not equal
    local isEqual = obj:isEqual(otherObj)
    local expectedIsEqual = false
    assert(isEqual == expectedIsEqual, "isEqual not "..tostring(expectedIsEqual).." for field "..fieldName.." of type "..type(fieldValue).." with original value "..textutils.serialise(fieldValue).." and anotherFieldValue "..textutils.serialise(anotherFieldValue))

    -- restore original value (for follow up tests)
    otherTable[fieldName] = fieldValue
end

local function pt_isNotEqual_tableField(origObj, origTable, otherObj, otherTable, indent)
    --[[
        This function tests obj and otherObj are not the same if a field in otherTable is changed w.r.t. the input.
    ]]

    -- test fields
    for fieldName, fieldValue in pairs(otherTable) do
--        corelog.WriteToLog(indent.."->test Obj's with different field "..fieldName.." are not equal, value="..textutils.serialise(fieldValue, compact))
        corelog.WriteToLog(indent.."->test Obj's with different field "..fieldName.." are not equal")
        -- check for table
        if type(fieldValue) == "table" then
            if Class.IsInstanceOf(fieldValue, IObj) then
--                corelog.WriteToLog(indent.."type=IObj")
                local anotherFieldValue = "a string instead of an IObj"
                -- note: the actual class of the IObj field should have it's own isEqual test so we only need to test here it's inequality with something else (a string in this case)

                -- test anotherValue
                pt_isNotEqual_anotherValue(origObj, otherObj, otherTable, fieldName, fieldValue, anotherFieldValue)
            else
--                corelog.WriteToLog(indent.."type=plain table")
                -- trigger test of equality of plain table fields
                local origFieldValue = origTable[fieldName]
                pt_isNotEqual_tableField(origObj, origFieldValue, otherObj, fieldValue, indent.."  ")
            end
        else
--            corelog.WriteToLog(indent.."type="..type(fieldValue)..", value="..textutils.serialise(fieldValue))
            -- figure out anotherFieldValue
            local anotherFieldValue = nil
            if type(fieldValue) == "nil" then anotherFieldValue = "not nil" -- will probably never occur because key wouldn't be present
            elseif type(fieldValue) == "number" then anotherFieldValue = fieldValue + 1
            elseif type(fieldValue) == "string" then anotherFieldValue = fieldValue..", a longer string"
            elseif type(fieldValue) == "boolean" then anotherFieldValue = not fieldValue
            else
                assert(false, "testing field of type "..type(fieldValue).." not supported (yet)")
            end

            -- test anotherValue
            pt_isNotEqual_anotherValue(origObj, otherObj, otherTable, fieldName, fieldValue, anotherFieldValue)
        end
    end

    -- test extra original field not equal
    local extraFieldName = "_extraStrField"
    corelog.WriteToLog(indent.."->test Obj's with extra field "..extraFieldName.." are not equal")
    origTable[extraFieldName] = "extra string field"
    local isEqual = origObj:isEqual(otherObj)
    local expectedIsEqual = false
    if isEqual ~= expectedIsEqual then -- ToDo: consider removing this at some point. It is however usefull for debugging at the moment
        corelog.Warning("Gotten isEqual(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..")")
        corelog.WriteToLog("origObj:")
        corelog.WriteToLog(origObj)
        corelog.WriteToLog("otherObj:")
        corelog.WriteToLog(otherObj)
    end
    assert(isEqual == expectedIsEqual, "gotten isEqual(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..")")
    origTable[extraFieldName]  = nil

    -- test extra other field not equal
    otherTable[extraFieldName]  = "extra string field"
    isEqual = origObj:isEqual(otherObj)
    expectedIsEqual = false
    assert(isEqual == expectedIsEqual, "gotten isEqual(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..")")
    otherTable[extraFieldName]  = nil
end

function T_IObj.pt_isEqual(className, obj, otherObj) -- note: obj and otherObj are assumed to be the same at the start of the test
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")
    assert(type(otherObj) == "table", "no valid otherObj provided")
    corelog.WriteToLog("* "..className..":isEqual() tests")

    -- test identical obj equal
    corelog.WriteToLog("->test identical Obj's are equal")
    local isEqual = obj:isEqual(obj)
    local expectedIsEqual = true
    assert(isEqual == expectedIsEqual, "gotten isEqual(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..")")

    -- test equal obj equal
    corelog.WriteToLog("->test equal Obj's are equal")
    isEqual = obj:isEqual(otherObj)
    expectedIsEqual = true
    assert(isEqual == expectedIsEqual, "gotten isEqual(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..")")

    -- test different fields not equal
    pt_isNotEqual_tableField(obj, obj, otherObj, otherObj, "")

    -- cleanup test
end

function T_IObj.pt_copy(className, obj)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")
    corelog.WriteToLog("* "..className..":copy() tests")

    -- test
    local copy = obj:copy()
    assert(copy:isEqual(obj), "gotten copy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(obj, compact)..")")

    -- cleanup test
end

return T_IObj
