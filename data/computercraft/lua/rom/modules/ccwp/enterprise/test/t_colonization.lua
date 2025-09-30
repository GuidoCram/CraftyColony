local t_colonization = {}

local corelog = require "corelog"

local Callback = require "obj_callback"
local MethodExecutor = require "method_executor"

local enterprise_colonization = require "enterprise_colonization"

function t_colonization.T_All()
    -- enterprise_colonization
    t_colonization.T_RecoverNewWorld_SSrv()
end

function t_colonization.T_AllPhysical()
    -- enterprise_colonization
    t_colonization.T_CreateNewWorld_ASrv()
end


local testClassName = "enterprise_colonization"

--    ______       _                       _           _____      _             _          _   _
--   |  ____|     | |                     (_)         / ____|    | |           (_)        | | (_)
--   | |__   _ __ | |_ ___ _ __ _ __  _ __ _ ___  ___| |     ___ | | ___  _ __  _ ______ _| |_ _  ___  _ __
--   |  __| | '_ \| __/ _ \ '__| '_ \| '__| / __|/ _ \ |    / _ \| |/ _ \| '_ \| |_  / _` | __| |/ _ \| '_ \
--   | |____| | | | ||  __/ |  | |_) | |  | \__ \  __/ |___| (_) | | (_) | | | | |/ / (_| | |_| | (_) | | | |
--   |______|_| |_|\__\___|_|  | .__/|_|  |_|___/\___|\_____\___/|_|\___/|_| |_|_/___\__,_|\__|_|\___/|_| |_|
--                             | |
--                             |_|

function t_colonization.T_CreateNewWorld_ASrv()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..".CreateNewWorld_ASrv() test")

    -- test
    local serviceResults = MethodExecutor.DoASyncService_Sync("enterprise_colonization", "CreateNewWorld_ASrv", {
    })

    -- check: service success
    assert(serviceResults, "no serviceResults returned")
    assert(serviceResults.success, "failed executing service")

    -- cleanup test
end

function t_colonization.T_RecoverNewWorld_SSrv()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..".RecoverNewWorld_SSrv() test")
    local serviceData = {}

    -- test
    local scheduleResult = enterprise_colonization.RecoverNewWorld_SSrv(serviceData)
    assert(scheduleResult == true, "Failed schedulding RecoverNewWorld_SSrv")

    -- cleanup test
end

return t_colonization
