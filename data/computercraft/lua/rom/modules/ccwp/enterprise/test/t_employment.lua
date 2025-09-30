local t_employment = {}

local corelog = require "corelog"

local Location = require "obj_location"
local ObjLocator = require "obj_locator"

local enterprise_employment = require "enterprise_employment"
local enterprise_energy = require "enterprise_energy"
local enterprise_forestry = require "enterprise_forestry"
local enterprise_manufacturing = require "enterprise_manufacturing"

local TestArrayTest = require "test_array_test"
local FieldTest = require "field_test"
local ValueTypeTest = require "value_type_test"

local T_BirchForest = require "test.t_mobj_birchforest"
local ObjTest = require "test.obj_test"
local T_LObjHost = require "test.t_lobj_host"
local T_MObjHost = require "test.t_mobj_host"
local T_IRegistry = require "test.t_i_registry"
local T_Turtle
local T_Settlement = require "test.t_settlement"
local T_UserStation = require "test.t_mobj_user_station"
local T_DisplayStation = require "test.t_mobj_display_station"

function t_employment.T_All()
    -- ObjHost
    t_employment.T_getObj()

    -- LObjHost
    t_employment.T_hostLObj_SSrv_Turtle()
    t_employment.T_releaseLObj_SSrv_Turtle()

    t_employment.T_hostLObj_SSrv_UtilStation()
    t_employment.T_releaseLObj_SSrv_UtilStation()

    t_employment.T_hostLObj_SSrv_DisplayStation()
    t_employment.T_releaseLObj_SSrv_DisplayStation()

    -- Worker
    t_employment.T_IRegistry_All()

    -- enterprise_employment
    --    t_employment.T_GetFuelLevels_Att()
    t_employment.T_GetAnyTurtleLocator()
end

function t_employment.T_AllPhysical()
    -- IObj

    -- MObjHost
    local mobjLocator = t_employment.T_buildAndHostMObj_ASrv_Turtle()
    t_employment.T_dismantleAndReleaseMObj_ASrv_Turtle(mobjLocator)

    mobjLocator = t_employment.T_buildAndHostMObj_ASrv_UtilStation()
    t_employment.T_dismantleAndReleaseMObj_ASrv_UtilStation(mobjLocator)

    mobjLocator = t_employment.T_buildAndHostMObj_ASrv_DisplayStation0()
    t_employment.T_dismantleAndReleaseMObj_ASrv_DisplayStation(mobjLocator)
end

local logOk = false
local testClassName = "enterprise_employment"
local testTurtleClassName = "Turtle"
local testTurtleName = "turtle"
local testUserStationClassName = "UserStation"
local testUserStationName = "userStation"
local testDisplayStationClassName = "DisplayStation"
local testDisplayStationName = "displayStation"
local testDisplayStationName0 = testDisplayStationName.."0"
local testDisplayStationName1 = testDisplayStationName.."1"

local level0 = 0
local workerId0 = 111111
local isActive_false = false
local settlementLocator0 = ObjLocator:newInstance("enterprise_colonization", "Settlement")
local baseLocation0 = Location:newInstance(1, -1, 3, 0, 1)
local baseLocation_UserStation = Location:newInstance(-6, -12, 1, 0, 1)
local baseLocation_DisplayStation0 = Location:newInstance(-6, -12, 1, 0, 1)
local baseLocation_DisplayStation1 = baseLocation_DisplayStation0:getRelativeLocation(0, 0, 10) -- a second station above the first
local workerLocation0 = baseLocation0:copy()
local workerLocation_UserStation = baseLocation_UserStation:getRelativeLocation(3, 3, 0)
local workerLocation_DisplayStation0 = baseLocation_DisplayStation0:getRelativeLocation(3, 3, 2)
local workerLocation_DisplayStation1 = baseLocation_DisplayStation1:getRelativeLocation(3, 3, 2)
local fuelPriorityKey = ""

local constructParameters_Turtle = {
    workerId            = workerId0,
    settlementLocator   = settlementLocator0,
    baseLocation        = baseLocation0,
    workerLocation      = workerLocation0,
}
local constructParameters_UserStation = {
    workerId            = workerId0,
    settlementLocator   = settlementLocator0,
    baseLocation        = baseLocation_UserStation,
    workerLocation      = workerLocation_UserStation,
}
local constructParameters_DisplayStation0 = {
    workerId            = workerId0,
    baseLocation        = baseLocation_DisplayStation0,
    workerLocation      = workerLocation_DisplayStation0,
}
local constructParameters_DisplayStation1 = {
    workerId            = workerId0,
    baseLocation        = baseLocation_DisplayStation1,
    workerLocation      = workerLocation_DisplayStation1,
}

local compact = { compact = true }

--     ____  _     _ _    _           _
--    / __ \| |   (_) |  | |         | |
--   | |  | | |__  _| |__| | ___  ___| |_
--   | |  | | '_ \| |  __  |/ _ \/ __| __|
--   | |__| | |_) | | |  | | (_) \__ \ |_
--    \____/|_.__/| |_|  |_|\___/|___/\__|
--               _/ |
--              |__/

function t_employment.T_getObj()
    -- prepare test
    corelog.WriteToLog("* enterprise_employment:getObj() tests")
    local testObject = ObjTest:newInstance("field1", 4)
    local objLocator = enterprise_employment:saveObj(testObject)
    local currentTurtleLocator = t_employment.GetCurrentTurtleLocator()
    local currentTurtle = enterprise_employment:getObj(currentTurtleLocator)

    -- test normal object works (similair to T_Host.T_getObj())
    local object = enterprise_employment:getObj(objLocator) assert(object, "t_employment.T_getObj: Failed obtaining Obj")
    assert(object:isEqual(testObject), "object(="..textutils.serialise(object, compact)..") not the same as expected(="..textutils.serialise(testObject, compact)..")")

    -- test "any turtle" provides current turtle
    local getAnyTurtleLocator = enterprise_employment.GetAnyTurtleLocator()
    object = enterprise_employment:getObj(getAnyTurtleLocator) assert(object, "t_employment.T_getObj: Failed obtaining Obj")
    assert(object:isEqual(currentTurtle), "object(="..textutils.serialise(object, compact)..") not the same as expected(="..textutils.serialise(currentTurtle, compact)..")")

    -- cleanup test
    enterprise_employment:deleteResource(objLocator)
    assert(not enterprise_employment:getResource(objLocator), "resource not deleted")
end

--    _      ____  _     _ _    _           _
--   | |    / __ \| |   (_) |  | |         | |
--   | |   | |  | | |__  _| |__| | ___  ___| |_
--   | |   | |  | | '_ \| |  __  |/ _ \/ __| __|
--   | |___| |__| | |_) | | |  | | (_) \__ \ |_
--   |______\____/|_.__/| |_|  |_|\___/|___/\__|
--                     _/ |
--                    |__/

-- ** Turtle **

function t_employment.T_hostLObj_SSrv_Turtle()
    -- prepare test
    T_Turtle = T_Turtle or require "test.t_mobj_turtle"
    local fieldsTest = T_Turtle.CreateInitialisedTest(nil, workerId0, isActive_false, settlementLocator0, baseLocation0, workerLocation0, fuelPriorityKey)

    -- test
    local serviceResults = T_LObjHost.pt_hostLObj_SSrv(enterprise_employment, testTurtleClassName, constructParameters_Turtle, testTurtleName, fieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_employment.T_releaseLObj_SSrv_Turtle()
    -- prepare test

    -- test
    local serviceResults = T_LObjHost.pt_releaseLObj_SSrv(enterprise_employment, testTurtleClassName, constructParameters_Turtle, testTurtleName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

-- ** UserStation **

function t_employment.T_hostLObj_SSrv_UtilStation()
    -- prepare test
    local inputLocatorTest = FieldTest:newInstance("_inputLocator", TestArrayTest:newInstance(
        ValueTypeTest:newInstance(ObjLocator:getClassName())
    ))
    local outputLocatorTest = FieldTest:newInstance("_outputLocator", TestArrayTest:newInstance(
        ValueTypeTest:newInstance(ObjLocator:getClassName())
    ))

    local fieldsTest = T_UserStation.CreateInitialisedTest(workerId0, isActive_false, settlementLocator0, baseLocation_UserStation, inputLocatorTest, outputLocatorTest)

    -- test
    local serviceResults = T_LObjHost.pt_hostLObj_SSrv(enterprise_employment, testUserStationClassName, constructParameters_UserStation, testUserStationName, fieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_employment.T_releaseLObj_SSrv_UtilStation()
    -- prepare test

    -- test
    local serviceResults = T_LObjHost.pt_releaseLObj_SSrv(enterprise_employment, testUserStationClassName, constructParameters_UserStation, testUserStationName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

-- ** DisplayStation **

function t_employment.T_hostLObj_SSrv_DisplayStation()
    -- prepare test
    local fieldsTest = T_DisplayStation.CreateInitialisedTest(workerId0, isActive_false, baseLocation_DisplayStation0)

    -- test
    local serviceResults = T_LObjHost.pt_hostLObj_SSrv(enterprise_employment, testDisplayStationClassName, constructParameters_DisplayStation0, testDisplayStationName0, fieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_employment.T_releaseLObj_SSrv_DisplayStation()
    -- prepare test

    -- test
    local serviceResults = T_LObjHost.pt_releaseLObj_SSrv(enterprise_employment, testDisplayStationClassName, constructParameters_DisplayStation0, testDisplayStationName0, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

--    __  __  ____  _     _ _    _           _
--   |  \/  |/ __ \| |   (_) |  | |         | |
--   | \  / | |  | | |__  _| |__| | ___  ___| |_
--   | |\/| | |  | | '_ \| |  __  |/ _ \/ __| __|
--   | |  | | |__| | |_) | | |  | | (_) \__ \ |_
--   |_|  |_|\____/|_.__/| |_|  |_|\___/|___/\__|
--                      _/ |
--                     |__/

-- ** Turtle **

local function GetNextTurtleBaseLocation()
    -- get # hosted Turtle's
    local nHostedTurtles = enterprise_employment:getNumberOfObjects("Turtle")

    -- determine next baseLocation
    local nextBaseLocation = Location:newInstance(nHostedTurtles, -1, 3, 0, 1) -- note: we base/ park the Turtle's along a line in x on the highway

    -- end
    return nextBaseLocation
end

local function GetNextTurtleConstructParameters()
    -- determine some parameters
    local nextBaseLocation = GetNextTurtleBaseLocation()
    local currentTurtleLocator = enterprise_employment:getCurrentWorkerLocator() assert(currentTurtleLocator, "Failed obtaining currentTurtleLocator")
    local turtleObj = enterprise_employment:getObj(currentTurtleLocator) assert(turtleObj, "Failed obtaining Turtle "..currentTurtleLocator:getURI())
    local settlementLocator = turtleObj:getSettlementLocator() assert(settlementLocator, "Failed obtaining settlementLocator")

    -- constructParameters
    local constructParameters = {
        workerId            = workerId0,
        settlementLocator   = settlementLocator,
        baseLocation        = nextBaseLocation,
        workerLocation      = nextBaseLocation:copy(),
    }

    -- end
    return constructParameters
end

local mobjLocator_Turtle = nil

function t_employment.T_buildAndHostMObj_ASrv_Turtle()
    -- prepare test
    local constructParameters = GetNextTurtleConstructParameters()

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_employment, testTurtleClassName, constructParameters, testTurtleName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Turtle = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_employment.T_dismantleAndReleaseMObj_ASrv_Turtle(mobjLocator)
    -- prepare test
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator
        assert(mobjLocator_Turtle, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_Turtle
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(enterprise_employment, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Turtle = nil
end

-- ** UserStation **

local mobjLocator_UtilStation = nil

function t_employment.T_buildAndHostMObj_ASrv_UtilStation()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_employment, testUserStationClassName, constructParameters_UserStation, testUserStationName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test

    -- remember what we just build
    mobjLocator_UtilStation = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_employment.T_dismantleAndReleaseMObj_ASrv_UtilStation(mobjLocator)
    -- prepare test
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator
        assert(mobjLocator_UtilStation, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_UtilStation
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(enterprise_employment, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_UtilStation = nil
end

-- ** DisplayStation **

local mobjLocator_DisplayStation = nil

function t_employment.T_0buildAndHostMObj_ASrv_DisplayStation0()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_employment, testDisplayStationClassName, constructParameters_DisplayStation0, testDisplayStationName0, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test

    -- remember what we just build
    mobjLocator_DisplayStation = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_employment.T_1buildAndHostMObj_ASrv_DisplayStation1()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_employment, testDisplayStationClassName, constructParameters_DisplayStation1, testDisplayStationName1, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test

    -- remember what we just build
    mobjLocator_DisplayStation = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_employment.T_dismantleAndReleaseMObj_ASrv_DisplayStation(mobjLocator)
    -- prepare test
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator
        assert(mobjLocator_DisplayStation, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_DisplayStation
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(enterprise_employment, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_UtilStation = nil
end

--   __          __        _
--   \ \        / /       | |
--    \ \  /\  / /__  _ __| | _____ _ __
--     \ \/  \/ / _ \| '__| |/ / _ \ '__|
--      \  /\  / (_) | |  |   <  __/ |
--       \/  \/ \___/|_|  |_|\_\___|_|

function t_employment.T_IRegistry_All()
    -- prepare test
    local thingName = "Worker"
    local workerLocator1 = ObjLocator:newInstance(testClassName, "AWorkerClass", "worker1") assert(workerLocator1, "Failed obtaining workerLocator1")
    local workerId2 = 222222
    local workerLocator2 = ObjLocator:newInstance(testClassName, "AWorkerClass", "worker2") assert(workerLocator2, "Failed obtaining workerLocator2")

    -- test
    T_IRegistry.pt_all(testClassName, enterprise_employment, workerId0, workerLocator1, workerId2, workerLocator2, thingName)
end

--    ______       _                       _          ______                 _                                  _
--   |  ____|     | |                     (_)        |  ____|               | |                                | |
--   | |__   _ __ | |_ ___ _ __ _ __  _ __ _ ___  ___| |__   _ __ ___  _ __ | | ___  _   _ _ __ ___   ___ _ __ | |_
--   |  __| | '_ \| __/ _ \ '__| '_ \| '__| / __|/ _ \  __| | '_ ` _ \| '_ \| |/ _ \| | | | '_ ` _ \ / _ \ '_ \| __|
--   | |____| | | | ||  __/ |  | |_) | |  | \__ \  __/ |____| | | | | | |_) | | (_) | |_| | | | | | |  __/ | | | |_
--   |______|_| |_|\__\___|_|  | .__/|_|  |_|___/\___|______|_| |_| |_| .__/|_|\___/ \__, |_| |_| |_|\___|_| |_|\__|
--                             | |                                    | |             __/ |
--                             |_|                                    |_|            |___/

function t_employment.T_resetWorkers()
    -- prepare test
    corelog.WriteToLog("* enterprise_employment:resetWorkers() tests")

    -- test
    enterprise_employment:resetWorkers()

    -- cleanup test
end

function t_employment.T_GetFuelLevels_Att()
    -- prepare test
    corelog.WriteToLog("# Test GetFuelLevels_Att")
    local forest = T_BirchForest.CreateTestObj() assert(forest, "Failed obtaining BirchForest")
    local forestLocator = enterprise_forestry:saveObj(forest)
    T_Turtle = T_Turtle or require "test.t_mobj_turtle"
    local turtleObj = T_Turtle.CreateTestObj() assert (turtleObj, "Failed obtaining Turtle")
    local location = turtleObj:getWorkerLocation()
    local factoryClassName = "Factory"
    local factoryConstructParameters = {
        level           = 0,

        baseLocation    = location,
    }

    local result = enterprise_manufacturing:hostLObj_SSrv({ className = factoryClassName, constructParameters = factoryConstructParameters}) assert(result.success, "Failed hosting Factory")
    local factoryLocator = result.mobjLocator

    local energyParameters = enterprise_energy.GetParameters()
    local originalLevel = energyParameters.enterpriseLevel
    local originalForestLocator = energyParameters.forestLocator
    local originalFactoryLocator = energyParameters.factoryLocator

    -- test
    enterprise_energy.UpdateEnterprise_SSrv({ enterpriseLevel = level0, forestLocator = forestLocator, factoryLocator = factoryLocator })
    local fuelLevels = enterprise_employment.GetFuelLevels_Att()
    local expectedFuelLevel_Priority = 41
    assert(fuelLevels.fuelLevel_Priority == expectedFuelLevel_Priority, "gotten fuelLevel_Priority(="..fuelLevels.fuelLevel_Priority..") for energy enterpriseLevel "..level0.." not the same as expected(="..expectedFuelLevel_Priority..")")
    local expectedFuelLevel_Assignment = 41 -- ToDo: consider taking enterprise_assignmentboard maxFuelNeed_Assignment into account as well
    assert(fuelLevels.fuelLevel_Assignment == expectedFuelLevel_Assignment, "gotten fuelLevel_Assignment(="..fuelLevels.fuelLevel_Assignment..") for energy enterpriseLevel "..level0.." not the same as expected(="..expectedFuelLevel_Assignment..")")

    -- cleanup test
    enterprise_energy.UpdateEnterprise_SSrv({ enterpriseLevel = originalLevel, forestLocator = originalForestLocator, factoryLocator = originalFactoryLocator })

    result = enterprise_manufacturing:releaseLObj_SSrv({ mobjLocator = factoryLocator}) assert(result, "Failed releasing Factory")

    enterprise_forestry:deleteResource(forestLocator)
end

function t_employment.T_GetAnyTurtleLocator()
    -- prepare test
    corelog.WriteToLog("* enterprise_employment.GetAnyTurtleLocator() tests")

    -- test
    local turtleLocator = enterprise_employment.GetAnyTurtleLocator() assert(turtleLocator, "t_employment.T_GetAnyTurtleLocator: Failed obtaining turtleLocator")
    local expectedLocator = enterprise_employment.GetAnyTurtleLocator()

    assert(turtleLocator:isEqual(expectedLocator), "gotten locator(="..textutils.serialise(turtleLocator, compact)..") not the same as expected(="..textutils.serialise(expectedLocator, compact)..")")

    -- cleanup test
end

-- ToDo: consider if all callers want replacing getCurrentWorkerLocator, or if some want something else! (e.g. an anyTurtle, or even a computer...)
function t_employment.GetCurrentTurtleLocator()
    --[[
        This method provides the locator of the current turtle (in enterprise_employment).

        Return value:
            turtleLocator       - (ObjLocator) locating the current turtle

        Parameters:
    --]]

    -- check turtle
    assert(turtle, "Current computer(ID="..os.getComputerID()..") not a Turtle")

    -- construct ObjLocator
    local currentTurtleLocator = enterprise_employment:getCurrentWorkerLocator()

    -- end
    return currentTurtleLocator
end

return t_employment
