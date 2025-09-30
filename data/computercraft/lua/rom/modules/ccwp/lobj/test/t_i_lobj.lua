local T_ILObj = {}
local corelog = require "corelog"

local ILObj = require "i_lobj"

local T_IInterface = require "test.t_i_interface"
local T_Class = require "test.t_class"

local MethodResultEqualTest = require "method_result_equal_test"

function T_ILObj.pt_all(className, class, cases, logOk)
    -- prepare test all
    assert(type(className) == "string", "no valid className provided")
    assert(type(class) == "table", "no valid class provided")
    assert(type(cases) == "table", "no valid cases provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")

    -- loop on test cases
    for i, case in ipairs(cases) do
        -- prepare test case
        local objName               = case.objName
        assert(objName, "no objName provided for "..tostring(i))
        local caseName              = objName.." case"
        local constructParameters   = case.constructParameters
        assert(constructParameters, "no constructParameters provided for "..caseName)
        local constructFieldsTest   = case.constructFieldsTest
        assert(constructFieldsTest, "no constructFieldsTest provided for "..caseName)
        local expectedId            = case.expectedId
        local destructFieldsTest    = case.destructFieldsTest
        local upgradeParameters     = case.upgradeParameters
        local upgradeFieldsTest     = case.upgradeFieldsTest
        local indent                = "  "

        corelog.WriteToLog("* "..className.." "..caseName.." ILObj tests:")

        -- first case?
        local obj = nil
        if i==1 then
            -- prepare test
            obj = class:construct(constructParameters) assert(obj, "Failed obtaining "..className)

            -- test type
            T_ILObj.pt_IsInstanceOf_ILObj(className, obj)
            T_ILObj.pt_Implements_ILObj(className, obj)
        end
        if obj ~= nil then
            -- test getters
            T_ILObj.pt_getId(className, obj, objName, indent, logOk, expectedId)
            T_ILObj.pt_getWIPId(className, obj, objName, indent, logOk)

            -- cleanup test
            obj:destruct()
        end

        -- test destruct
        if destructFieldsTest then
            T_ILObj.pt_destruct(className, class, constructParameters, objName, destructFieldsTest, indent, logOk)
        end

        -- test construct
        T_ILObj.pt_construct(className, class, constructParameters, objName, constructFieldsTest, indent, logOk)

        -- test upgrade
        if upgradeParameters and upgradeFieldsTest then
            T_ILObj.pt_upgrade(className, class, constructParameters, objName, upgradeParameters, upgradeFieldsTest, indent, logOk)
        end
    end
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

function T_ILObj.pt_IsInstanceOf_ILObj(className, obj)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")

    -- test
    T_Class.pt_IsInstanceOf(className, obj, "ILObj", ILObj)
end

function T_ILObj.pt_Implements_ILObj(className, obj)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")

    -- test
    T_IInterface.pt_ImplementsInterface("ILObj", ILObj, className, obj)
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function T_ILObj.pt_destruct(className, class, constructParameters, objName, destructFieldsTest, indent, logOk)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(class) == "table", "no valid class provided")
    assert(type(constructParameters) == "table", "no valid constructParameters provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(destructFieldsTest) == "table", "no valid destructFieldsTest provided")
    assert(type(indent) == "string", "no valid indent provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog(indent.."* "..className..":destruct() test (with "..objName..")")
    local obj = class:construct(constructParameters) assert(obj, "Failed obtaining "..className)

    -- test
    local destructSuccess = obj:destruct()
    assert(destructSuccess, className..":destruct() not a success")
    local test = destructFieldsTest
    test:test(obj, objName, indent, logOk)

    -- ToDo: add tests if child LObj's have been released
end

function T_ILObj.pt_construct(className, class, constructParameters, objName, constructFieldsTest, indent, logOk)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(class) == "table", "no valid class provided")
    assert(type(constructParameters) == "table", "no valid constructParameters provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(constructFieldsTest) == "table", "no valid constructFieldsTest provided")
    assert(type(indent) == "string", "no valid indent provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog(indent.."* "..className..":construct() test (with "..objName..")")

    -- test
    local obj = class:construct(constructParameters) assert(obj, "Failed obtaining "..className)
    local test = constructFieldsTest
    test:test(obj, objName, indent, logOk)

    -- cleanup test
    obj:destruct()
end

function T_ILObj.pt_upgrade(className, class, constructParameters, objName, upgradeParameters, upgradeFieldsTest, indent, logOk)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(class) == "table", "no valid class provided")
    assert(type(constructParameters) == "table", "no valid constructParameters provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(upgradeParameters) == "table", "no valid upgradeParameters provided")
    assert(type(upgradeFieldsTest) == "table", "no valid upgradeFieldsTest provided")
    assert(type(indent) == "string", "no valid indent provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog(indent.."* "..className..":upgrade() test (with "..objName..")")
    local obj = class:construct(constructParameters) assert(obj, "Failed obtaining "..className)

    -- test
    local upgradeSuccess = obj:upgrade(upgradeParameters)
    assert(upgradeSuccess, className..":upgrade() not a success")
    local test = upgradeFieldsTest
    test:test(obj, objName, indent, logOk)

    -- cleanup test
    obj:destruct()
end

function T_ILObj.pt_getId(className, obj, objName, indent, logOk, expectedId)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(indent) == "string", "no valid indent provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    expectedId = expectedId or obj._id
    corelog.WriteToLog(indent.."* "..className..":getId() test")

    -- test
    local test = MethodResultEqualTest:newInstance("getId", expectedId)
    test:test(obj, objName, indent, logOk)
end

function T_ILObj.pt_getWIPId(className, obj, objName, indent, logOk)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(indent) == "string", "no valid indent provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog(indent.."* "..className..":getWIPId() test")

    -- test
    local expectedWIPId = className.." "..obj:getId()
    local test = MethodResultEqualTest:newInstance("getWIPId", expectedWIPId)
    test:test(obj, objName, indent, logOk)
end

return T_ILObj
