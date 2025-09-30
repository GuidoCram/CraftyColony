-- define class
local Class = require "class"
local ObjHost = require "obj_host"
local LObjHost = Class.NewClass(ObjHost)

--[[
    The LObjHost is a ObjHost that hosts LObj's and provides additional services on and with these LObj's.

    This class typically is used as a base class for enterprise classes dealing with LObj's.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

local ILObj = require "i_lobj"
local LObjLocator = require "lobj_locator"

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
LObjHost._hostName   = "LObjHost"

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function LObjHost:getClassName()
    return "LObjHost"
end

--    _      ____  _     _ _    _           _
--   | |    / __ \| |   (_) |  | |         | |
--   | |   | |  | | |__  _| |__| | ___  ___| |_
--   | |   | |  | | '_ \| |  __  |/ _ \/ __| __|
--   | |___| |__| | |_) | | |  | | (_) \__ \ |_
--   |______\____/|_.__/| |_|  |_|\___/|___/\__|
--                     _/ |
--                    |__/

function LObjHost:hostLObj_SSrv(...)
    -- get & check input from description
    local checkSuccess, className, constructParameters = InputChecker.Check([[
        This sync public service hosts a new LObj in the LObjHost. Hosting consist of
            - construction of a new LObj instance
            - saving the instance in the LObjHost.

        Note that the LObj is not physically build in the world.

        Return value:
                                    - (table)
                success             - (boolean) whether the service executed successfully
                mobjLocator         - (ObjLocator) locating the created LObj

        Parameters:
            serviceData             - (table) data about this service
                className           + (string, "") with the name of the class of the LObj
                constructParameters + (table) parameters for constructing the LObj
    --]], ...)
    if not checkSuccess then corelog.Error("LObjHost:hostLObj_SSrv: Invalid input") return {success = false} end

    -- get class
    local class = objectFactory:getClass(className)
    if not class then corelog.Error("LObjHost:hostLObj_SSrv: Class "..className.." not found in objectFactory") return {success = false} end
    if not Class.IsInstanceOf(class, ILObj) then corelog.Error("LObjHost:hostLObj_SSrv: Class "..className.." is not an ILObj") return {success = false} end

    -- construct new LObj
    local mobj = class:construct(constructParameters)
    if not mobj then corelog.Error("LObjHost:hostLObj_SSrv: Failed constructing "..className.." from constructParameters(="..textutils.serialise(constructParameters)..")") return {success = false} end

    -- save the LObj
    local mobjLocator = self:saveObj(mobj)
    if not mobjLocator then corelog.Error("LObjHost:hostLObj_SSrv: Failed saving "..className.." "..textutils.serialise(mobj)..")") return {success = false} end

    -- log
    corelog.WriteToLog(">Hosting new "..className.." "..mobj:getId()..".")

    -- end
    local result = {
        success     = true,
        mobjLocator = mobjLocator,
    }
    return result
end

function LObjHost:upgradeLObj_SSrv(...)
    -- get & check input from description
    local checkSuccess, mobjLocator, upgradeParameters = InputChecker.Check([[
        This async public service upgrades a LObj in the LObjHost.

        Note that downgrading is not supported as it implies stopping running businesss etc.

        Note that the LObj is not physically extended in the world. If this is also required extendAndUpgradeMObj_ASrv should be called.

        Return value:
                                                - (table)
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table) data about this service
                mobjLocator                     + (ObjLocator) locating the LObj
                upgradeParameters               + (table) parameters for upgrading the LObj
    ]], ...)
    if not checkSuccess then corelog.Error("LObjHost:upgradeLObj_SSrv: Invalid input") return {success = false} end

    -- log
    corelog.WriteToLog(">Upgrading "..mobjLocator:getURI().." with "..textutils.serialise(upgradeParameters, {compact = true}))

    -- get LObj
    local mobj = ObjHost.GetObj(mobjLocator)
    if not mobj or not Class.IsInstanceOf(mobj, ILObj) then corelog.Error("LObjHost:upgradeLObj_SSrv: Failed obtaining an ILObj from mobjLocator "..mobjLocator:getURI()) return {success = false} end
    if not mobj.upgrade then corelog.Error("LObjHost:upgradeLObj_SSrv: LObj "..mobjLocator:getURI().." does not have upgrade method (yet)") return {success = false} end
    -- ToDo: consider if we want to make upgrade a mandatory method of ILObj

    -- upgrade LObj
    local success = mobj:upgrade(upgradeParameters)
    if not success then corelog.Error("LObjHost:upgradeLObj_SSrv: Failed upgrading "..mobjLocator:getURI().." from upgradeParameters(="..textutils.serialise(upgradeParameters)..")") return {success = false} end

    -- save the LObj
    mobjLocator = self:saveObj(mobj)
    if not mobjLocator then corelog.Error("LObjHost:upgradeLObj_SSrv: Failed saving "..textutils.serialise(mobj)..")") return {success = false} end

    -- end
    return {success = success}
end

function LObjHost:releaseLObj_SSrv(...)
    -- get & check input from description
    local checkSuccess, mobjLocator = InputChecker.Check([[
        This async public service releases a LObj from the LObjHost. Releasing implies
            - destruction of an LObj instance
            - deleting the instance from the LObjHost.

        Note that the LObj is not physically removed from the world.

        Return value:
                                                - (table)
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table) data about this service
                mobjLocator                     + (ObjLocator) locating the LObj
    ]], ...)
    if not checkSuccess then corelog.Error("LObjHost:releaseLObj_SSrv: Invalid input") return {success = false} end

    -- log
    corelog.WriteToLog(">Releasing "..mobjLocator:getURI())

    -- get LObj
    local mobj = ObjHost.GetObj(mobjLocator)
    if not mobj or not Class.IsInstanceOf(mobj, ILObj) then corelog.Error("LObjHost:releaseLObj_SSrv: Failed obtaining an ILObj from mobjLocator "..mobjLocator:getURI()) return {success = false} end

    -- destuct LObj
    local success = mobj:destruct()
    if not success then corelog.Error("LObjHost:releaseLObj_SSrv: Failed destructing "..mobjLocator:getURI()) return {success = false} end

    -- remove LObj from LObjHost
    success = self:deleteResource(mobjLocator)
    if not success then corelog.Error("LObjHost:releaseLObj_SSrv: Failed deleting "..mobjLocator:getURI()) return {success = false} end

    -- end
    return {success = success}
end

function LObjHost:releaseLObjs_SSrv(...)
    -- get & check input from description
    local checkSuccess, className = InputChecker.Check([[
        This async public service releases all LObj's from the LObjHost.

        Note that the LObj's are not physically removed from the world.

        Return value:
                                                - (table)
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table) data about this service
                className                       + (string) with the name of the class of the LObj's
    ]], ...)
    if not checkSuccess then corelog.Error("LObjHost:releaseLObjs_SSrv: Invalid input") return {success = false} end

    -- get LObj's
    local objects = self:getObjects(className)
    if type(objects) ~= "table" then corelog.Error("LObjHost:releaseLObjs_SSrv: Failed obtaining objects of class "..className) return nil end

    -- release all
    local releaseSuccess = true
    for _, lobj in pairs(objects) do
        -- convert to object
        lobj = objectFactory:create(className, lobj)

        -- get locator
        local lobjLocator = LObjLocator:newInstance(self:getClassName(), lobj)

        -- release
        local releaseResult = self:releaseLObj_SSrv({ mobjLocator = lobjLocator })
        if not releaseResult or not releaseResult.success then corelog.Warning("LObjHost:releaseLObjs_SSrv: Failed releasing lobj "..lobjLocator:getURI()) releaseSuccess = false end
    end

    -- end
    return {success = releaseSuccess}
end

return LObjHost
