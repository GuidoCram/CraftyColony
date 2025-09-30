-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local Host = Class.NewClass(ObjBase)

--[[
    This module implements the Host class.

    A Host is an object that "hosts" Resource's to be used both inside the Host as well as outside of it.

    A Host has a (unique) hostName.

    The Host is the owner of the Resource's it hosts. This makes the Host responsible for making sure the Resource's are
    available (and possibly persistent). The Host does so via the methods getResource, saveResource and deleteResource.

    In it's core a Resource is a LUA table. Each Resource hosted by a Host can be identified by a unique resourceLocator URL. The host component of these
    URL's are equal to the hostName of the Host.
--]]

local corelog = require "corelog"
local coredht = require "coredht"

local InputChecker = require "input_checker"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local URL = require "obj_url"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function Host:_init(...)
    -- get & check input from description
    local checkSuccess, hostName = InputChecker.Check([[
        Initialise a Host.

        Parameters:
            hostName                + (string) with hostName of the Host
    ]], ...)
    if not checkSuccess then corelog.Error("Host:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._hostName  = hostName
end

-- ToDo: should be renamed to newFromTable at some point
function Host:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a Host instance.

        Parameters:
            o                           + (table, {}) table with object fields
                _hostName               - (string) with hostName of the Host
    ]], ...)
    if not checkSuccess then corelog.Error("Host:new: Invalid input") return {} end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function Host:getHostName()
    return self._hostName
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function Host:getClassName()
    return "Host"
end

--                        _  __ _
--                       (_)/ _(_)
--    ___ _ __   ___  ___ _| |_ _  ___
--   / __| '_ \ / _ \/ __| |  _| |/ __|
--   \__ \ |_) |  __/ (__| | | | | (__
--   |___/ .__/ \___|\___|_|_| |_|\___|
--       | |
--       |_|

function Host:getHostLocator()
    --[[
        Attribute locating this Host.

        Return value:
            hostLocator             - (URL) locating this Host

        Parameters:
            nil
    --]]

    local hostURL = URL:newInstance(self:getHostName())

    return hostURL
end

function Host:isLocatorFromHost(...)
    -- get & check input from description
    local checkSuccess, locator = InputChecker.Check([[
        This method answers the question if a locator is from this Host.

        Return value:
                                    - (boolean) whether the locator is from this host

        Parameters:
            locator                 + (URL) that needs to be queried
    --]], ...)
    if not checkSuccess then corelog.Error("Host:isLocatorFromHost: Invalid input") return false end

    -- check if of this Host
    local hostField = locator:getHost()
    if type(hostField) ~= "string" then corelog.Error("Host:isLocatorFromHost: Invalid host field in locator (="..locator:getURI()..").") return false end
    if hostField == self:getHostName() then
        return true
    else
        return false
    end
end

function Host:getResource(...)
    -- get & check input from description
    local checkSuccess, resourceLocator = InputChecker.Check([[
        This method retrieves a Resource from the Host using a URL (that was once provided by the Host).

        Return value:
            resource                - (table) Resource obtained from the Host

        Parameters:
            resourceLocator         + (URL) locator of the Resource within the Host
    ]], ...)
    if not checkSuccess then corelog.Error("Host:getResource: Invalid input") return nil end

    -- get URL components
    local hostURI = resourceLocator:getHostURI()
    if hostURI ~= self:getHostName() then
        corelog.Error("  Host:getResource(): resourceLocator not for host.")
        corelog.WriteToLog("  resourceLocator:getURI() = " .. resourceLocator:getURI())
        corelog.WriteToLog("  hostURI = " .. hostURI)
        corelog.WriteToLog("  self:getHostName() = " .. self:getHostName())
        return nil
    end
    local portURI = resourceLocator:getPortURI()
    local pathSegments = resourceLocator:pathSegments()

    -- get Resource from dht using URL components
    -- note: all current implementations of Host assume the Resource's are stored in the dht. This is the current implementation decision.
    -- The method signatures are (?should) however defined in such a way that also another mechanism (e.g. with a local table) can be implemented.
    local resource = nil
    if portURI == "" then
        resource = coredht.GetData(hostURI, table.unpack(pathSegments))
    else
        resource = coredht.GetData(hostURI, portURI, table.unpack(pathSegments))
    end

    -- end
    return resource
end

function Host:saveResource(...)
    -- get & check input from description
    local checkSuccess, resource, resourceLocator = InputChecker.Check([[
        This method saves a Resource to the Host using a uniform resource locator (URL).

        Return value:
            resourceLocator         - (URL) locating the Resource

        Parameters:
            resource                + (table) representing the Resource
            resourceLocator         + (URL) locating the Resource within a Host
    ]], ...)
    if not checkSuccess then corelog.Error("Host:saveResource: Invalid input") return nil end

    -- get URL components
    local hostURI = resourceLocator:getHostURI()
    local portURI = resourceLocator:getPortURI()
    local pathSegments = resourceLocator:pathSegments()

    -- save Resource to dht using URL components
    local savedResource = nil
    if portURI == ""    then savedResource = coredht.SaveData(resource, hostURI, table.unpack(pathSegments))
                        else savedResource = coredht.SaveData(resource, hostURI, portURI, table.unpack(pathSegments))
    end
    if not savedResource then corelog.Error("Host:saveResource: Failed saving Resource located by "..resourceLocator:getURI()) return nil end

    -- end
    return resourceLocator
end

function Host:deleteResource(...)
    -- get & check input from description
    local checkSuccess, resourceLocator = InputChecker.Check([[
        This method deletes a Resource from the Host using a URL.

        Return value:
                                    + (boolean) if resource was succesfully removed

        Parameters:
            resourceLocator         + (URL) locator of the Resource within the Host
    ]], ...)
    if not checkSuccess then corelog.Error("Host:deleteResource: Invalid input") return false end

    -- get URL components
    local hostURI = resourceLocator:getHostURI()
    local portURI = resourceLocator:getPortURI()
    local pathSegments = resourceLocator:pathSegments()

    -- delete Resource from dht using URL components
    corelog.WriteToLog(">removing resource "..resourceLocator:getURI())
    local savedResource = nil
    if portURI == "" then
        savedResource = coredht.SaveData(nil, hostURI, table.unpack(pathSegments))
    else
        savedResource = coredht.SaveData(nil, hostURI, portURI, table.unpack(pathSegments))
    end
    -- ToDo: consider also deleting pathSegments remainders from dht when there are no longer resources present in the path

    -- end
    return savedResource == nil
end

--        _        _   _
--       | |      | | (_)
--    ___| |_ __ _| |_ _  ___
--   / __| __/ _` | __| |/ __|
--   \__ \ || (_| | |_| | (__
--   |___/\__\__,_|\__|_|\___|

function Host.GetHost(...)
    -- get & check input from description
    local checkSuccess, hostName, suppressWarning = InputChecker.Check([[
        This method retrieves a Host from a hostName.

        Return value:
            host                    - (Host) with the Host

        Parameters:
            hostName                + (string) with hostName of the Host
            suppressWarning         + (boolean, false) if Warning should be suppressed
    ]], ...)
    if not checkSuccess then corelog.Error("Host.GetHost: Invalid input") return nil end

    -- get Host
    local host = moduleRegistry:getRegistered(hostName)
    if not host then if not suppressWarning then corelog.Warning("Host.GetHost: No module registered with hostName="..hostName) end return nil end
    if not Class.IsInstanceOf(host, Host) then if not suppressWarning then corelog.Warning("Host.GetHost: Module "..hostName.." is not of type Host") end return nil end

    -- end
    return host
end

return Host
