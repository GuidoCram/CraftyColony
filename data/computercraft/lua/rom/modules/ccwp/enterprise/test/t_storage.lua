local t_storage = {}

local corelog = require "corelog"

local Callback = require "obj_callback"
local Location = require "obj_location"
local ObjLocator = require "obj_locator"
local Inventory = require "obj_inventory"

local TestArrayTest = require "test_array_test"
local FieldTest = require "field_test"
local ValueTypeTest = require "value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"

local T_Chest = require "test.t_mobj_chest"
local T_Silo = require "test.t_mobj_silo"
local T_LObjHost = require "test.t_lobj_host"
local T_MObjHost = require "test.t_mobj_host"

local enterprise_projects = require "enterprise_projects"
local enterprise_storage

function t_storage.T_All()
    -- IObj

    -- LObjHost
    t_storage.T_hostLObj_SSrv_Chest()
    t_storage.T_releaseLObj_SSrv_Chest()

    t_storage.T_hostLObj_SSrv_Silo()
    t_storage.T_releaseLObj_SSrv_Silo()
end

function t_storage.T_AllPhysical()
    -- IObj

    -- MObjHost
    local mobjLocator = t_storage.T_buildAndHostMObj_ASrv_Chest()
    t_storage.T_dismantleAndReleaseMObj_ASrv_Chest(mobjLocator)

    mobjLocator = t_storage.T_buildAndHostMObj_ASrv_Silo()
    t_storage.T_dismantleAndReleaseMObj_ASrv_Silo(mobjLocator)
end

local testChestClassName = "Chest"
local testChestName = "chest"

local testStartLocation  = Location:newInstance(-6, 0, 1, 0, 1)
local testStartLocation2  = Location:newInstance(-6, 6, 1, 0, 1)
local baseLocation_Chest0 = testStartLocation:getRelativeLocation(2, 5, 0)
local accessDirection0 = "top"
local inventory1 = Inventory:newInstance() -- optionally add elements

local constructParameters_Chest0 = {
    baseLocation    = baseLocation_Chest0,
    accessDirection = accessDirection0,
}

local testSiloClassName = "Silo"
local testSiloName = "silo"

local baseLocation_Silo0  = Location:newInstance(12, -12, 1, 0, 1)
local entryLocation_Silo0 = baseLocation_Silo0:getRelativeLocation(3, 3, 0)
local dropLocation0 = 1
local pickupLocation0 = 2
local nTopChests0 = 2
local nLayers0 = 2
local constructParameters_Silo0 = {
    baseLocation    = baseLocation_Silo0,
    nTopChests      = nTopChests0,
    nLayers         = nLayers0,
}

local logOk = false

--    _      ____  _     _ _    _           _
--   | |    / __ \| |   (_) |  | |         | |
--   | |   | |  | | |__  _| |__| | ___  ___| |_
--   | |   | |  | | '_ \| |  __  |/ _ \/ __| __|
--   | |___| |__| | |_) | | |  | | (_) \__ \ |_
--   |______\____/|_.__/| |_|  |_|\___/|___/\__|
--                     _/ |
--                    |__/

-- ** Chest **

function t_storage.T_hostAndUpdateChest()
    enterprise_storage = enterprise_storage or require "enterprise_storage"
    corelog.WriteToLog("* Test host and update Chest")
    local callback = Callback:newInstance("t_ccwp", "Func1_Callback", { } )

    -- create project
    local projectData = {
        hostLocator         = enterprise_storage:getHostLocator(),
        className           = "Chest",
        constructParameters = {
            baseLocation    = testStartLocation2:getRelativeLocation(2, 5, 0),
            accessDirection = "back",
        }
    }
    local projectServiceData = {
        projectDef  = t_storage.GetHostAndUpdateChestProjectDef(),
        projectData = projectData,
        projectMeta = { title = "Testing", description = "Register and update Chest" },
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function t_storage.GetHostAndUpdateChestProjectDef()
    return {
        steps = {
            -- host Chest
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "hostLObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "className"          , sourceStep = 0, sourceKeyDef = "className" },
                { keyDef = "constructParameters", sourceStep = 0, sourceKeyDef = "constructParameters" },
            }},
            -- update Chest
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "updateChestRecord_AOSrv", locatorStep = 1, locatorKeyDef = "mobjLocator" }, stepDataDef = {
            }, description = "Updating Chest record"},
        },
        returnData = {
            { keyDef = "chestLocator"           , sourceStep = 1, sourceKeyDef = "mobjLocator" },
        }
    }
end

function t_storage.T_hostLObj_SSrv_Chest()
    -- prepare test
    enterprise_storage = enterprise_storage or require "enterprise_storage"
    local constructFieldsTest = T_Chest.CreateInitialisedTest(nil, baseLocation_Chest0, accessDirection0, inventory1)

    -- test
    local serviceResults = T_LObjHost.pt_hostLObj_SSrv(enterprise_storage, testChestClassName, constructParameters_Chest0, testChestName, constructFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_storage.T_releaseLObj_SSrv_Chest()
    -- prepare test
    enterprise_storage = enterprise_storage or require "enterprise_storage"

    -- test
    local serviceResults = T_LObjHost.pt_releaseLObj_SSrv(enterprise_storage, testChestClassName, constructParameters_Chest0, testChestName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

-- ** Silo **

function t_storage.T_hostLObj_SSrv_Silo()
    -- prepare test
    enterprise_storage = enterprise_storage or require "enterprise_storage"
    local topChestsConstructTest = FieldTest:newInstance("_topChests", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", ObjLocator:getClassName()),
        MethodResultEqualTest:newInstance("nObjs", nTopChests0)
    ))
    local storageChestsConstructTest = FieldTest:newInstance("_storageChests", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", ObjLocator:getClassName()),
        MethodResultEqualTest:newInstance("nObjs", nLayers0*4)
    ))
    local constructFieldsTest = T_Silo.CreateInitialisedTest(nil, baseLocation_Silo0, entryLocation_Silo0, dropLocation0, pickupLocation0, topChestsConstructTest, storageChestsConstructTest)

    -- test
    local serviceResults = T_LObjHost.pt_hostLObj_SSrv(enterprise_storage, testSiloClassName, constructParameters_Silo0, testSiloName, constructFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_storage.T_releaseLObj_SSrv_Silo()
    -- prepare test
    enterprise_storage = enterprise_storage or require "enterprise_storage"

    -- test
    local serviceResults = T_LObjHost.pt_releaseLObj_SSrv(enterprise_storage, testSiloClassName, constructParameters_Silo0, testSiloName, logOk)
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

-- ** Chest **

local mobjLocator_Chest = nil

function t_storage.T_buildAndHostMObj_ASrv_Chest()
    -- prepare test
    enterprise_storage = enterprise_storage or require "enterprise_storage"

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_storage, testChestClassName, constructParameters_Chest0, testChestName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Chest = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_storage.T_dismantleAndReleaseMObj_ASrv_Chest(mobjLocator)
    -- prepare test
    enterprise_storage = enterprise_storage or require "enterprise_storage"
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator
        assert(mobjLocator_Chest, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_Chest
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(enterprise_storage, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Chest = nil
end

-- ** Silo **

local mobjLocator_Silo = nil

function t_storage.T_buildAndHostMObj_ASrv_Silo()
    -- prepare test
    enterprise_storage = enterprise_storage or require "enterprise_storage"

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_storage, testSiloClassName, constructParameters_Silo0, testSiloName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Silo = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_storage.T_dismantleAndReleaseMObj_ASrv_Silo(mobjLocator)
    -- prepare test
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator
        assert(mobjLocator_Silo, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_Silo
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(enterprise_storage, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Silo = nil
end

return t_storage
