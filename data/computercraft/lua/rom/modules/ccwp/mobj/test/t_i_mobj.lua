local T_IMObj = {}
local corelog = require "corelog"

local IMObj = require "i_mobj"

local T_IInterface = require "test.t_i_interface"
local T_Class = require "test.t_class"

local MethodResultTest = require "method_result_test"
local MethodResultEqualTest = require "method_result_equal_test"

function T_IMObj.pt_all(className, class, cases, logOk)
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
        local constructBlueprintTest= case.constructBlueprintTest
        assert(constructBlueprintTest, "no constructBlueprintTest provided for "..caseName)
        local expectedBaseLocation  = case.expectedBaseLocation
        local upgradeParameters     = case.upgradeParameters
        local upgradeBlueprintTest  = case.upgradeBlueprintTest
        local dismantleBlueprintTest= case.dismantleBlueprintTest
        local indent                = "  "

        corelog.WriteToLog("* "..className.." "..caseName.." IMObj tests:")

        local obj = class:construct(constructParameters) assert(obj, "Failed obtaining "..className)

        -- first case?
        if i==1 then
            -- test type
            T_IMObj.pt_IsInstanceOf_IMObj(className, obj)
            T_IMObj.pt_Implements_IMObj(className, obj)
        end
        if i==1 then
            -- test getters
            T_IMObj.pt_getBaseLocation(className, obj, objName, expectedBaseLocation, indent, logOk)
        end

        -- test GetBuildBlueprint
        T_IMObj.pt_GetBuildBlueprint(className, obj, objName, constructParameters, constructBlueprintTest, indent, logOk)

        -- test getExtendBlueprint
        if upgradeParameters then
            T_IMObj.pt_getExtendBlueprint(className, obj, objName, upgradeParameters, upgradeBlueprintTest, indent, logOk)
        end

        -- test getDismantleBlueprint
        if dismantleBlueprintTest then
            T_IMObj.pt_getDismantleBlueprint(className, obj, objName, dismantleBlueprintTest, indent, logOk)
        end

        -- cleanup test
        obj:destruct()
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

function T_IMObj.pt_IsInstanceOf_IMObj(className, obj)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")

    -- test
    T_Class.pt_IsInstanceOf(className, obj, "IMObj", IMObj)
end

function T_IMObj.pt_Implements_IMObj(className, obj)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")

    -- test
    T_IInterface.pt_ImplementsInterface("IMObj", IMObj, className, obj)
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function T_IMObj.pt_getBaseLocation(className, obj, objName, expectedBaseLocation, indent, logOk)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(expectedBaseLocation) == "table", "no expectedBaseLocation provided")
    assert(type(indent) == "string", "no valid indent provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog(indent.."* "..className..":getBaseLocation() tests")

    -- test
    local test = MethodResultEqualTest:newInstance("getBaseLocation", expectedBaseLocation)
    test:test(obj, objName, indent, logOk)
end

function T_IMObj.pt_getBlueprint(className, methodName, isStaticMethod, obj, objName, blueprintTest, indent, logOk, ...)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(methodName) == "string", "no valid methodName provided")
    assert(type(isStaticMethod) == "boolean", "no valid isStaticMethod provided")
    assert(type(obj) == "table", "no valid obj provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(blueprintTest) == "table", "no valid blueprintTest provided")
    assert(type(indent) == "string", "no valid indent provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    local methodOperator = ":" if isStaticMethod then methodOperator = "." end
    corelog.WriteToLog(indent.."* "..className..methodOperator..methodName.."() tests (with "..objName..")")

    -- test
    local test = MethodResultTest:newInstance(methodName, isStaticMethod, blueprintTest, ...)
    test:test(obj, objName, indent, logOk)
end

function T_IMObj.pt_GetBuildBlueprint(className, obj, objName, constructParameters, blueprintTest, indent, logOk)
    -- test
    T_IMObj.pt_getBlueprint(className, "GetBuildBlueprint", true, obj, objName, blueprintTest, indent, logOk, constructParameters)
end

function T_IMObj.pt_getDismantleBlueprint(className, obj, objName, blueprintTest, indent, logOk)
    -- test
    T_IMObj.pt_getBlueprint(className, "getDismantleBlueprint", false, obj, objName, blueprintTest, indent, logOk)
end

function T_IMObj.pt_getExtendBlueprint(className, obj, objName, upgradeParameters, blueprintTest, indent, logOk)
    -- test
    T_IMObj.pt_getBlueprint(className, "getExtendBlueprint", false, obj, objName, blueprintTest, indent, logOk, upgradeParameters)
end

return T_IMObj
