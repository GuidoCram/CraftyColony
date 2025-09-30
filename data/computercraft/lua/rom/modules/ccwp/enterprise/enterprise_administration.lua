-- define class
local Class = require "class"
local ObjHost = require "obj_host"
local enterprise_administration = Class.NewClass(ObjHost)

--[[
    The enterprise_administration is a ObjHost. It hosts administration administrators.
--]]

local corelog = require "corelog"

local ObjTable = require "obj_table"
local WIPAdministrator = require "obj_wip_administrator"

local ObjLocator = require "obj_locator"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

-- note: currently enterprise is treated like a singleton, but by directly using the name of the module
-- ToDo: consider making changes to enterprise to
--          - explicitly make it a singleton (by construction with :newInstance(hostName) and using the singleton pattern)
--          - properly initialise it (by adding and implementing the _init method)
--          - adopt other classes to these changes
enterprise_administration._hostName   = "enterprise_administration"

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function enterprise_administration:getClassName()
    return "enterprise_administration"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function enterprise_administration:getWIPAdministrator()
    --[[
        This function returns the WIPAdministrator.

        Return value:
            wipHandler                  - (WIPAdministrator) the WIPAdministrator
    --]]

    local administrator = self:getObjects("WIPAdministrator")
--    corelog.WriteToLog("administrator:")
--    corelog.WriteToLog(administrator)

    if next(administrator) == nil then
        -- the WIPAdministrator is not there yet => create it
        administrator = self:createNewWIPAdministrator()
    else
        administrator = WIPAdministrator:new(administrator)
    end

    -- end
    return administrator
end

function enterprise_administration:getWIPAdministratorLocator()
    --[[
        This function returns the WIPAdministrator locator.

        Return value:
            administratorLocator              - (ObjLocator) locating the WIPAdministrator
    --]]

    -- get WIPAdministrator
    local administrator = enterprise_administration:getWIPAdministrator()
    if not administrator then corelog.Error("enterprise_administration:getWIPAdministratorLocator: Failed getting administrator") return nil end

    -- get locator
    local objLocator = ObjLocator:newInstance("enterprise_administration", administrator:getClassName())

    -- end
    return objLocator
end

function enterprise_administration:createNewWIPAdministrator()
    -- create WIPAdministrator
    local administrator = WIPAdministrator:newInstance(ObjTable:newInstance("WIPQueue"))

    -- save it
    local objLocator = self:saveObj(administrator)
    if not objLocator then corelog.Error("enterprise_administration:createNewWIPAdministrator: Failed saving WIPAdministrator") return nil end

    -- end
    return administrator
end

function enterprise_administration:reset()
    -- reset WIPAdministrator
    self:getWIPAdministrator():reset()
end

--                        _
--                       (_)
--    ___  ___ _ ____   ___  ___ ___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \
--   \__ \  __/ |   \ V /| | (_|  __/
--   |___/\___|_|    \_/ |_|\___\___|

return enterprise_administration
