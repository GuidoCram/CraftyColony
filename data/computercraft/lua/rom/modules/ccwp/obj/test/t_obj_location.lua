local T_Location = {}

local corelog = require "corelog"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local Location = require "obj_location"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_Location.T_All()
    -- initialisation
    T_Location.T__init()
    T_Location.T_new()

    -- IObj
    T_Location.T_IObj_All()

    -- specific
    T_Location.T_reset()
    T_Location.T_minLocation()
    T_Location.T_maxLocation()
    T_Location.T_getRelativeLocation()
    T_Location.T_getRelativeLocationFront()
    T_Location.T_getRelativeLocationUp()
    T_Location.T_getRelativeLocationDown()
    T_Location.T_getRelativeLocationLeft()
    T_Location.T_getRelativeLocationRight()
    T_Location.T_blockDistanceTo()
end

local testClassName = "Location"
local logOk = false
local x0 = 0
local y0 = 0
local z0 = 0
local dx0 = 0
local dy0 = 1
local x1 = 1
local y1 = 10
local z1 = -10
local dx1 = 0
local dy1 = -1
local x2 = 2
local y2 = 20
local z2 = -20
local dx2 = -1
local dy2 = 0

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_Location.CreateTestObj(x, y, z, dx, dy)
    -- check input
    x = x or x1
    y = y or y1
    z = z or z1
    dx = dx or dx1
    dy = dy or dy1

    -- create testObj
    local testObj = Location:newInstance(x, y, z, dx, dy)

    -- end
    return testObj
end

function T_Location.CreateInitialisedTest(x, y, z, dx, dy)
    -- check input

    -- create test
    local test = TestArrayTest:newInstance(
        FieldValueEqualTest:newInstance("_x", x),
        FieldValueEqualTest:newInstance("_y", y),
        FieldValueEqualTest:newInstance("_z", z),
        FieldValueEqualTest:newInstance("_dx", dx),
        FieldValueEqualTest:newInstance("_dy", dy)
    )

    -- end
    return test
end

function T_Location.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")

    -- test
    local obj = T_Location.CreateTestObj(x1, y1, z1, dx1, dy1) assert(obj, "Failed obtaining "..testClassName)
    local test = T_Location.CreateInitialisedTest(x1, y1, z1, dx1, dy1)
    test:test(obj, "location", "", logOk)

    -- test default
    obj = Location:newInstance()
    test = T_Location.CreateInitialisedTest(0, 0, 0, 0, 1)
    test:test(obj, "location", "", logOk)

    -- cleanup test
end

function T_Location.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test full
    local obj = Location:new({
        _x  = x1,
        _y  = y1,
        _z  = z1,
        _dx = dx1,
        _dy = dy1,
    })
    local test = T_Location.CreateInitialisedTest(x1, y1, z1, dx1, dy1)
    test:test(obj, "location", "", logOk)

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

function T_Location.T_IObj_All()
    -- prepare test
    local obj = T_Location.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_Location.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function T_Location.T_reset()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":reset() tests")
    local obj = Location:newInstance(x1, y1, z1, dx1, dy1)

    -- test
    obj:reset()
    local test = T_Location.CreateInitialisedTest(x0, y0, z0, dx0, dy0)
    test:test(obj, "location", "", logOk)

    -- cleanup test
end

function T_Location.T_minLocation()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":minLocation() tests")
    local obj1 = Location:newInstance(x1, y1, z1, dx1, dy1)
    local obj2 = Location:newInstance(x2, y2, z2, dx2, dy2)

    -- test
    local minLocation = obj1:minLocation(obj2)
    local test = T_Location.CreateInitialisedTest(math.min(x1, x2), math.min(y1, y2), math.min(z1, z2), math.min(dx1, dx2), math.min(dy1, dy2))
    test:test(minLocation, "minLocation", "", logOk)

    -- cleanup test
end

function T_Location.T_maxLocation()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":maxLocation() tests")
    local obj1 = Location:newInstance(x1, y1, z1, dx1, dy1)
    local obj2 = Location:newInstance(x2, y2, z2, dx2, dy2)

    -- test
    local maxLocation = obj1:maxLocation(obj2)
    local test = T_Location.CreateInitialisedTest(math.max(x1, x2), math.max(y1, y2), math.max(z1, z2), math.max(dx1, dx2), math.max(dy1, dy2))
    test:test(maxLocation, "maxLocation", "", logOk)

    -- cleanup test
end

function T_Location.T_getRelativeLocation()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getRelativeLocation() tests")
    local obj1 = Location:newInstance(x1, y1, z1, dx1, dy1)

    -- test
    local addX = 105
    local addY = 15
    local addZ = 5
    local relativeLocation = obj1:getRelativeLocation(addX, addY, addZ)
    local test = T_Location.CreateInitialisedTest(x1 + addX, y1 + addY, z1 + addZ, dx1, dy1)
    test:test(relativeLocation, "relativeLocation", "", logOk)

    -- cleanup test
end

function T_Location.T_getRelativeLocationFront()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getRelativeLocationFront() tests")
    local obj1 = Location:newInstance(x1, y1, z1, dx1, dy1)

    -- test forward 2
    local steps = 2
    local relativeLocation = obj1:getRelativeLocationFront(steps)
    local test = T_Location.CreateInitialisedTest(x1 + steps * dx1, y1 + steps * dy1, z1, dx1, dy1)
    test:test(relativeLocation, "relativeLocation", "", logOk)

    -- test backward 1
    steps = -1
    relativeLocation = obj1:getRelativeLocationFront(steps)
    test = T_Location.CreateInitialisedTest(x1 + steps * dx1, y1 + steps * dy1, z1, dx1, dy1)
    test:test(relativeLocation, "relativeLocation", "", logOk)

    -- cleanup test
end

function T_Location.T_getRelativeLocationUp()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getRelativeLocationUp() tests")
    local obj1 = Location:newInstance(x1, y1, z1, dx1, dy1)

    -- test up 2
    local steps = 2
    local relativeLocation = obj1:getRelativeLocationUp(steps)
    local test = T_Location.CreateInitialisedTest(x1, y1, z1 + steps, dx1, dy1)
    test:test(relativeLocation, "relativeLocation", "", logOk)

    -- cleanup test
end

function T_Location.T_getRelativeLocationDown()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getRelativeLocationDown() tests")
    local obj1 = Location:newInstance(x1, y1, z1, dx1, dy1)

    -- test down 2
    local steps = 2
    local relativeLocation = obj1:getRelativeLocationDown(steps)
    local test = T_Location.CreateInitialisedTest(x1, y1, z1 - steps, dx1, dy1)
    test:test(relativeLocation, "relativeLocation", "", logOk)

    -- cleanup test
end

function T_Location.T_getRelativeLocationLeft()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getRelativeLocationLeft() tests")
    local obj1 = Location:newInstance(x1, y1, z1, dx1, dy1)

    -- test left 1
    local steps = 1
    local relativeLocation = obj1:getRelativeLocationLeft(steps)
    local test = T_Location.CreateInitialisedTest(x1, y1, z1, -dy1, dx1)
    test:test(relativeLocation, "relativeLocation", "", logOk)

    -- test left 3
    steps = 3
    relativeLocation = obj1:getRelativeLocationLeft(steps)
    test = T_Location.CreateInitialisedTest(x1, y1, z1, dy1, -dx1)
    test:test(relativeLocation, "relativeLocation", "", logOk)

    -- cleanup test
end

function T_Location.T_getRelativeLocationRight()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getRelativeLocationRight() tests")
    local obj1 = Location:newInstance(x1, y1, z1, dx1, dy1)

    -- test right 1
    local steps = 1
    local relativeLocation = obj1:getRelativeLocationRight(steps)
    local test = T_Location.CreateInitialisedTest(x1, y1, z1, dy1, -dx1)
    test:test(relativeLocation, "relativeLocation", "", logOk)

    -- test right 2
    steps = 2
    relativeLocation = obj1:getRelativeLocationRight(steps)
    test = T_Location.CreateInitialisedTest(x1, y1, z1, -dx1, -dy1)
    test:test(relativeLocation, "relativeLocation", "", logOk)

    -- cleanup test
end

function T_Location.T_blockDistanceTo()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":blockDistanceTo() tests")
    local obj1 = Location:newInstance(x1, y1, z1, dx1, dy1)
    local obj2 = Location:newInstance(x2, y2, z2, dx2, dy2)

    -- test
    local blockDistance = obj1:blockDistanceTo(obj2)
    local expectedBlockDistance = math.abs(x2 - x1) + math.abs(y2 - y1) + math.abs(z2 - z1)
    assert(blockDistance == expectedBlockDistance, "gotten blockDistanceTo(="..blockDistance..") not the same as expected(="..expectedBlockDistance..")")

    -- cleanup test
end

return T_Location
