local T_DisplayStation = {}

local corelog = require "corelog"

local IObj = require "i_obj"
local ObjBase = require "obj_base"

local Location = require "obj_location"

local DisplayStation = require "mobj_display_station"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"
local IsBlueprintTest = require "test.is_blueprint_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"
local T_ILObj = require "test.t_i_lobj"
local T_IMObj = require "test.t_i_mobj"
local T_IWorker = require "test.t_i_worker"

function T_DisplayStation.T_All()
    -- initialisation
    T_DisplayStation.T__init()
    T_DisplayStation.T_new()

    -- IObj
    T_DisplayStation.T_IObj_All()

    -- ILObj
    T_DisplayStation.T_ILObj_All()

    -- IMObj
    T_DisplayStation.T_IMObj_All()

    -- IWorker
    T_DisplayStation.T_IWorker_All()
end

function T_DisplayStation.T_AllPhysical()
end

local testClassName = "DisplayStation"
local testObjName = "displayStation"
local testObjName0 = testObjName.."0"

local logOk = false

local workerId0 = 111111
local isActive_false = false
local baseLocation0 = Location:newInstance(-6, -12, 1, 0, 1)

local constructParameters0 = {
    workerId        = workerId0,
    baseLocation    = baseLocation0,
}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_DisplayStation.CreateTestObj(workerId, isActive, baseLocation)
    -- check input
    workerId = workerId or workerId0
    isActive = isActive or isActive_false
    baseLocation = baseLocation or baseLocation0

    -- create testObj
    local testObj = DisplayStation:newInstance(workerId, isActive, baseLocation:copy())

    -- end
    return testObj
end

function T_DisplayStation.CreateInitialisedTest(workerId, isActive, baseLocation)
    -- check input

    -- create test
    local test = TestArrayTest:newInstance(
        FieldValueEqualTest:newInstance("_workerId", workerId),
        FieldValueEqualTest:newInstance("_isActive", isActive),
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation)
    )

    -- end
    return test
end

function T_DisplayStation.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")

    -- test
    local obj = T_DisplayStation.CreateTestObj(workerId0, isActive_false, baseLocation0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_DisplayStation.CreateInitialisedTest(workerId0, isActive_false, baseLocation0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_DisplayStation.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test
    local obj = DisplayStation:new({
        _workerId       = workerId0,
        _isActive       = isActive_false,
        _baseLocation   = baseLocation0:copy(),
    })
    local test = T_DisplayStation.CreateInitialisedTest(workerId0, isActive_false, baseLocation0)
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

function T_DisplayStation.T_IObj_All()
    -- prepare test
    local obj = T_DisplayStation.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_DisplayStation.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

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

function T_DisplayStation.T_ILObj_All()
    -- prepare tests
    local destructFieldsTest = TestArrayTest:newInstance(
    )
    local fieldsTest0 = T_DisplayStation.CreateInitialisedTest(workerId0, isActive_false, baseLocation0)

    -- test cases
    T_ILObj.pt_all(testClassName, DisplayStation, {
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

function T_DisplayStation.T_IMObj_All()
    -- prepare tests
    local isBlueprintTest = IsBlueprintTest:newInstance(baseLocation0)

    -- test cases
    T_IMObj.pt_all(testClassName, DisplayStation, {
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

function T_DisplayStation.T_IWorker_All()
    -- prepare test
    local obj = T_DisplayStation.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local workerResumeTest = TestArrayTest:newInstance(
        FieldValueTypeTest:newInstance("workerId", "number"),
        FieldValueTypeTest:newInstance("location", "Location")
    )
    local isMainUIMenuTest = TestArrayTest:newInstance(
        FieldValueTypeTest:newInstance("clear", "boolean"),
        FieldValueTypeTest:newInstance("intro", "string"),
        FieldValueTypeTest:newInstance("option", "table"),
        FieldValueTypeTest:newInstance("question", "string")
    )
    local assignmentFilterTest = TestArrayTest:newInstance(
        -- ToDo: add tests if we decide to have a specific filter
    )

    -- test
    local expectedWorkerLocation = obj:getBaseLocation():getRelativeLocation(3, 3, 2)
    T_IWorker.pt_all(testClassName, obj, testObjName, expectedWorkerLocation, workerResumeTest, isMainUIMenuTest, assignmentFilterTest, logOk)
end

return T_DisplayStation
