local t_gathering = {}

local corelog = require "corelog"

local Location = require "obj_location"

local LObjLocator = require "lobj_locator"

local MineShaft = require "mine_shaft"

local enterprise_gathering = require "enterprise_gathering"

local T_MineShaft = require "test.t_mine_shaft"
local T_MineLayer = require "test.t_mine_layer"
local T_LObjHost = require "test.t_lobj_host"
local T_MObjHost = require "test.t_mobj_host"

function t_gathering.T_All()
    -- LObjHost
    t_gathering.T_hostLObj_SSrv_MineShaft()
    t_gathering.T_upgradeLObj_SSrv_MineShaft()
    t_gathering.T_releaseLObj_SSrv_MineShaft()

    t_gathering.T_hostLObj_SSrv_MineLayer()
    t_gathering.T_upgradeLObj_SSrv_MineLayer()
    t_gathering.T_releaseLObj_SSrv_MineLayer()
end

function t_gathering.T_AllPhysical()
    -- IObj

    -- MObjHost
    local mobjLocator = t_gathering.T_buildAndHostMObj_ASrv_MineShaft()
    t_gathering.T_extendAndUpgradeMObj_ASrv_MineShaft(mobjLocator)
    t_gathering.T_dismantleAndReleaseMObj_ASrv_MineShaft(mobjLocator)

    mobjLocator = t_gathering.T_buildAndHostMObj_ASrv_MineLayer()
    t_gathering.T_extendAndUpgradeMObj_ASrv_MineLayer(mobjLocator)
    t_gathering.T_dismantleAndReleaseMObj_ASrv_MineLayer(mobjLocator)
end

local testMineShaftClassName = "MineShaft"
local testMineShaftName = "mineShaft"
local testMineShaftName0 = testMineShaftName.."0"
local testMineLayerClassName = "MineLayer"
local testMineLayerName = "mineLayer"
local testMineLayerName0 = testMineLayerName.."0"

local baseLocation_MineShaft0 = Location:newInstance(0, -12, 1, 0, 1):getRelativeLocation(3, 3, 0)
local baseLocation_MineLayer0 = Location:newInstance(0, -12, -36, 0, 1):getRelativeLocation(3, 3, 0)
local currentDepth0 = 0
local maxDepth0 = 37
local maxDepth1 = 48
local currentHalfRib0 = 3

local constructParameters_MineShaft0 = {
    baseLocation    = baseLocation_MineShaft0,
    maxDepth        = maxDepth0,
}
local constructParameters_MineLayer0 = {
    baseLocation    = baseLocation_MineLayer0,
}

local upgradeParameters_MineShaft0 = {
    maxDepth        = maxDepth1,
}
local upgradeParameters_MineLayer0 = {
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

-- ** MineShaft **

function t_gathering.T_hostLObj_SSrv_MineShaft()
    -- prepare test
    local constructFieldsTest = T_MineShaft.CreateInitialisedTest(nil, baseLocation_MineShaft0, currentDepth0, maxDepth0)

    -- test
    local serviceResults = T_LObjHost.pt_hostLObj_SSrv(enterprise_gathering, testMineShaftClassName, constructParameters_MineShaft0, testMineShaftName0, constructFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_gathering.T_upgradeLObj_SSrv_MineShaft()
    -- prepare test
    local upgradeFieldsTest = T_MineShaft.CreateInitialisedTest(nil, baseLocation_MineShaft0, currentDepth0, maxDepth1)

    -- test
    local serviceResults = T_LObjHost.pt_upgradeLObj_SSrv(enterprise_gathering, testMineShaftClassName, constructParameters_MineShaft0, upgradeParameters_MineShaft0, testMineShaftName0, upgradeFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_gathering.T_releaseLObj_SSrv_MineShaft()
    -- prepare test

    -- test
    local serviceResults = T_LObjHost.pt_releaseLObj_SSrv(enterprise_gathering, testMineShaftClassName, constructParameters_MineShaft0, testMineShaftName0, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

-- ** MineLayer **

function t_gathering.T_hostLObj_SSrv_MineLayer()
    -- prepare test
    local constructFieldsTest = T_MineLayer.CreateInitialisedTest(nil, baseLocation_MineLayer0, currentHalfRib0)

    -- test
    local serviceResults = T_LObjHost.pt_hostLObj_SSrv(enterprise_gathering, testMineLayerClassName, constructParameters_MineLayer0, testMineLayerName0, constructFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_gathering.T_upgradeLObj_SSrv_MineLayer()
    -- prepare test
    local upgradeFieldsTest = T_MineLayer.CreateInitialisedTest(nil, baseLocation_MineLayer0, currentHalfRib0)

    -- test
    local serviceResults = T_LObjHost.pt_upgradeLObj_SSrv(enterprise_gathering, testMineLayerClassName, constructParameters_MineLayer0, upgradeParameters_MineLayer0, testMineLayerName0, upgradeFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_gathering.T_releaseLObj_SSrv_MineLayer()
    -- prepare test

    -- test
    local serviceResults = T_LObjHost.pt_releaseLObj_SSrv(enterprise_gathering, testMineLayerClassName, constructParameters_MineLayer0, testMineLayerName0, logOk)
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

-- ** MineShaft **

local mobjLocator_MineShaft = nil

function t_gathering.T_buildAndHostMObj_ASrv_MineShaft()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_gathering, testMineShaftClassName, constructParameters_MineShaft0, testMineShaftName0, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_MineShaft = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_gathering.T_extendAndUpgradeMObj_ASrv_MineShaft(mobjLocator)
    -- prepare test
    local upgradeFieldsTest = T_MineShaft.CreateInitialisedTest(nil, baseLocation_MineShaft0, currentDepth0, maxDepth1)

    if not mobjLocator then
        -- check if we locally remembered a mobjLocator
        assert(mobjLocator_MineShaft, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_MineShaft
    end

    -- test
    local serviceResults = T_MObjHost.pt_extendAndUpgradeMObj_ASrv(enterprise_gathering, mobjLocator, upgradeParameters_MineShaft0, testMineShaftName0, upgradeFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_gathering.T_dismantleAndReleaseMObj_ASrv_MineShaft(mobjLocator)
    -- prepare test
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator
        assert(mobjLocator_MineShaft, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_MineShaft
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(enterprise_gathering, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_MineShaft = nil
end

function t_gathering.T_dismantleFillAndRelease_CurrentMineShaft()
    -- prepare test

    -- get mobjLocator of first MineShaft in enterprise_gathering
    local mineShafts = enterprise_gathering:getObjects("MineShaft")
    if not mineShafts then corelog.Warning("t_gathering.T_dismantleFillAndRelease_CurrentMineShaft: No MineShafts to dismantle, fill and release") return nil end
    local mineShaft = nil
    for k, objTable in pairs(mineShafts) do
        mineShaft = MineShaft:new(objTable)
        break
    end
    if not mineShaft then corelog.Warning("t_gathering.T_dismantleFillAndRelease_CurrentMineShaft: No MineShaft to dismantle, fill and release") return nil end
    local mobjLocator = LObjLocator:newInstance("enterprise_gathering", mineShaft) assert(mobjLocator, "Failed obtaining mobjLocator")

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(enterprise_gathering, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_MineShaft = nil
end

-- ** MineLayer **

local mobjLocator_MineLayer = nil

function t_gathering.T_buildAndHostMObj_ASrv_MineLayer()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_gathering, testMineLayerClassName, constructParameters_MineLayer0, testMineLayerName0, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_MineLayer = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_gathering.T_extendAndUpgradeMObj_ASrv_MineLayer(mobjLocator)
    -- prepare test
    local upgradeFieldsTest = T_MineShaft.CreateInitialisedTest(nil, baseLocation_MineLayer0, currentHalfRib0)

    if not mobjLocator then
        -- check if we locally remembered a mobjLocator
        assert(mobjLocator_MineLayer, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_MineLayer
    end

    -- test
    local serviceResults = T_MObjHost.pt_extendAndUpgradeMObj_ASrv(enterprise_gathering, mobjLocator, upgradeParameters_MineLayer0, testMineLayerName0, upgradeFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_gathering.T_dismantleAndReleaseMObj_ASrv_MineLayer(mobjLocator)
    -- prepare test
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator
        assert(mobjLocator_MineLayer, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_MineLayer
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(enterprise_gathering, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_MineLayer = nil
end

return t_gathering
