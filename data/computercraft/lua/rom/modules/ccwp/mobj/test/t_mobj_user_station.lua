local T_UserStation = {}

local corelog = require "corelog"

local IObj = require "i_obj"
local ObjBase = require "obj_base"

local Location = require "obj_location"
local ObjLocator = require "obj_locator"

local UserStation = require "mobj_user_station"

local enterprise_employment = require "enterprise_employment"

local TestArrayTest = require "test_array_test"
local FieldTest = require "field_test"
local FieldValueEqualTest = require "field_value_equal_test"
local ValueTypeTest = require "value_type_test"
local FieldValueTypeTest = require "field_value_type_test"
local IsBlueprintTest = require "test.is_blueprint_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"
local T_ILObj = require "test.t_i_lobj"
local T_IMObj = require "test.t_i_mobj"
local T_IWorker = require "test.t_i_worker"
local T_Settlement = require "test.t_settlement"

function T_UserStation.T_All()
    -- initialisation
    T_UserStation.T__init()
    T_UserStation.T_new()

    -- IObj
    T_UserStation.T_IObj_All()

    -- ILObj
    T_UserStation.T_ILObj_All()

    -- IMObj
    T_UserStation.T_IMObj_All()

    -- IWorker
    T_UserStation.T_IWorker_All()
end

function T_UserStation.T_AllPhysical()
end

local testClassName = "UserStation"
local testObjName = "userStation"
local testObjName0 = testObjName.."0"

local logOk = false

local workerId0 = 111111
local isActive_false = false
local settlementLocator0 = ObjLocator:newInstance("enterprise_colonization", "Settlement")
local baseLocation0 = Location:newInstance(-6, -12, 1, 0, 1)

local inputLocator0 = enterprise_employment.GetAnyTurtleLocator() assert(inputLocator0, "Failed obtaining inputLocator0")
local outputLocator0 = enterprise_employment.GetAnyTurtleLocator() assert(outputLocator0, "Failed obtaining outputLocator0")

local constructParameters0 = {
    workerId            = workerId0,
    settlementLocator   = settlementLocator0,
    baseLocation        = baseLocation0,
}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_UserStation.CreateTestObj(workerId, isActive, settlementLocator, baseLocation, inputLocator, outputLocator)
    -- check input
    workerId = workerId or workerId0
    isActive = isActive or isActive_false
    settlementLocator = settlementLocator or settlementLocator0
    baseLocation = baseLocation or baseLocation0
    inputLocator = inputLocator or inputLocator0
    outputLocator = outputLocator or outputLocator0

    -- create testObj
    local testObj = UserStation:newInstance(workerId, isActive, settlementLocator, baseLocation:copy(), inputLocator, outputLocator)

    -- end
    return testObj
end

function T_UserStation.CreateInitialisedTest(workerId, isActive, settlementLocator, baseLocation, inputLocatorTest, outputLocatorTest)
    -- check input

    -- create test
    local test = TestArrayTest:newInstance(
        FieldValueEqualTest:newInstance("_workerId", workerId),
        FieldValueEqualTest:newInstance("_isActive", isActive),
        FieldValueEqualTest:newInstance("_settlementLocator", settlementLocator),
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation),
        inputLocatorTest,
        outputLocatorTest
    )

    -- end
    return test
end

function T_UserStation.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")

    -- test
    local obj = T_UserStation.CreateTestObj(workerId0, isActive_false, settlementLocator0, baseLocation0, inputLocator0, outputLocator0) assert(obj, "Failed obtaining "..testClassName)
    local inputLocatorTest = FieldValueEqualTest:newInstance("_inputLocator", inputLocator0)
    local outputLocatorTest = FieldValueEqualTest:newInstance("_outputLocator", outputLocator0)
    local test = T_UserStation.CreateInitialisedTest(workerId0, isActive_false, settlementLocator0, baseLocation0, inputLocatorTest, outputLocatorTest)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_UserStation.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test
    local obj = UserStation:new({
        _workerId           = workerId0,
        _isActive           = isActive_false,
        _settlementLocator  = settlementLocator0,
        _baseLocation       = baseLocation0:copy(),

        _inputLocator       = inputLocator0:copy(),
        _outputLocator      = outputLocator0:copy(),
    })
    local inputLocatorTest = FieldValueEqualTest:newInstance("_inputLocator", inputLocator0)
    local outputLocatorTest = FieldValueEqualTest:newInstance("_outputLocator", outputLocator0)
    local test = T_UserStation.CreateInitialisedTest(workerId0, isActive_false, settlementLocator0, baseLocation0, inputLocatorTest, outputLocatorTest)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function T_UserStation.T_IObj_All()
    -- prepare test
    local obj = T_UserStation.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_UserStation.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

    -- testing type
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)

    -- test
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function T_UserStation.T_ILObj_All()
    -- prepare tests
    local destructFieldsTest = TestArrayTest:newInstance(
    )
    local inputLocatorTest = FieldTest:newInstance("_inputLocator", TestArrayTest:newInstance(
        ValueTypeTest:newInstance(ObjLocator:getClassName())
    ))
    local outputLocatorTest = FieldTest:newInstance("_outputLocator", TestArrayTest:newInstance(
        ValueTypeTest:newInstance(ObjLocator:getClassName())
    ))
    local fieldsTest0 = T_UserStation.CreateInitialisedTest(workerId0, isActive_false, settlementLocator0, baseLocation0, inputLocatorTest, outputLocatorTest)

    -- test cases
    T_ILObj.pt_all(testClassName, UserStation, {
        {
            objName             = testObjName,
            constructParameters = constructParameters0,
            constructFieldsTest = fieldsTest0,
            destructFieldsTest  = destructFieldsTest,
            expectedId          = tostring(workerId0),
        },
    }, logOk)

    -- cleanup test
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function T_UserStation.T_IMObj_All()
    -- prepare tests
    local isBlueprintTest = IsBlueprintTest:newInstance(baseLocation0)

    -- test cases
    T_IMObj.pt_all(testClassName, UserStation, {
        {
            objName                 = testObjName0,
            constructParameters     = constructParameters0,
            constructBlueprintTest  = isBlueprintTest,
            expectedBaseLocation    = baseLocation0:copy(),
            dismantleBlueprintTest  = isBlueprintTest,
        },
    }, logOk)

    -- cleanup test
end

--    _______          __        _
--   |_   _\ \        / /       | |
--     | |  \ \  /\  / /__  _ __| | _____ _ __
--     | |   \ \/  \/ / _ \| '__| |/ / _ \ '__|
--    _| |_   \  /\  / (_) | |  |   <  __/ |
--   |_____|   \/  \/ \___/|_|  |_|\_\___|_|

function T_UserStation.T_IWorker_All()
    -- prepare test
    local obj = T_UserStation.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local workerResumeTest = TestArrayTest:newInstance(
        FieldValueTypeTest:newInstance("workerId", "number"),
        FieldValueTypeTest:newInstance("location", "Location")
    )
    local isMainUIMenuTest = TestArrayTest:newInstance(
        FieldValueTypeTest:newInstance("clear", "boolean"),
        FieldValueTypeTest:newInstance("intro", "string"),
        FieldValueTypeTest:newInstance("param", "table"),
        FieldValueTypeTest:newInstance("question", "nil")
    )
    local assignmentFilterTest = TestArrayTest:newInstance(
    )

    -- test
    local expectedWorkerLocation = obj:getBaseLocation():getRelativeLocation(3, 3, 0)
    T_IWorker.pt_all(testClassName, obj, testObjName, expectedWorkerLocation, workerResumeTest, isMainUIMenuTest, assignmentFilterTest, logOk)
end

return T_UserStation
