-- define class
local Class = require "class"
local Host = require "host"
local ObjHost = Class.NewClass(Host)

--[[
    This module implements the ObjHost class.

    A ObjHost is a Host that hosts Obj/object's and provides additional services on and with these Obj's.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()
local IObj = require "i_obj"
local ObjLocator = require "obj_locator"

local ILObj = require "i_lobj"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function ObjHost:_init(...)
    -- get & check input from description
    local checkSuccess, hostName = InputChecker.Check([[
        Initialise an ObjHost.

        Parameters:
            hostName                + (string) with hostName of the ObjHost
    ]], ...)
    if not checkSuccess then corelog.Error("ObjHost:_init: Invalid input") return nil end

    -- initialisation
    Host._init(self, hostName)
end

-- ToDo: should be renamed to newFromTable at some point
function ObjHost:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a ObjHost instance.

        Parameters:
            o                           + (table, {}) table with object fields
                _hostName               - (string) with hostName of the ObjHost
    ]], ...)
    if not checkSuccess then corelog.Error("ObjHost:new: Invalid input") return {} end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function ObjHost:getClassName()
    return "ObjHost"
end

--     ____  _     _ _    _           _
--    / __ \| |   (_) |  | |         | |
--   | |  | | |__  _| |__| | ___  ___| |_
--   | |  | | '_ \| |  __  |/ _ \/ __| __|
--   | |__| | |_) | | |  | | (_) \__ \ |_
--    \____/|_.__/| |_|  |_|\___/|___/\__|
--               _/ |
--              |__/

function ObjHost:getObj(...)
    -- get & check input from description
    local checkSuccess, objLocator = InputChecker.Check([[
        This method retrieves an Obj from the ObjHost using a ObjLocator.

        Return value:
            obj                     - (?) Obj obtained from the ObjHost

        Parameters:
            objLocator              + (ObjLocator) locator of the Obj within the ObjHost
    ]], ...)
    if not checkSuccess then corelog.Error("ObjHost:getObj: Invalid input") return nil end

    -- get className
    local className = objLocator:getObjClassName()
    if type(className) ~= "string" then corelog.Error("ObjHost:getObj: failed obtaining className from objLocator="..objLocator:getURI()) return nil end

    -- get raw Resource
    local resourceTable = self:getResource(objLocator)
    if type(resourceTable) ~= "table" then corelog.Error("ObjHost:getObj: failed obtaining resourceTable from objLocator="..objLocator:getURI()) return nil end

    -- convert to Obj
    local obj = objectFactory:create(className, resourceTable)
    if not obj then corelog.Error("ObjHost:getObj: failed converting resourceTable(="..textutils.serialise(resourceTable)..") to "..className.." Obj for objLocator="..objLocator:getURI()) return nil end

    -- end
    return obj
end

function ObjHost:getObj_SSrv(...)
    -- get & check input from description
    local checkSuccess, objLocator = InputChecker.Check([[
        This sync service retrieves an Obj from the ObjHost using a ObjLocator.

        Return value:
                                - (table)
                success         - (boolean) whether the service executed successfully
                obj             - (IObj) Obj obtained from the ObjHost

        Parameters:
            serviceData         - (table) data for this service
                objLocator      + (ObjLocator) locator of the Obj within the ObjHost
    ]], ...)
    if not checkSuccess then corelog.Error("ObjHost:getObj_SSrv: Invalid input") return {success = false} end

    -- save object
    local obj = self:getObj(objLocator)
    if not obj then corelog.Error("ObjHost:getObj_SSrv: Failed obtaining from objLocator="..objLocator:getURI()) return {success = false} end

    -- end
    return {
        success         = true,
        obj             = obj,
    }
end

function ObjHost:saveObj(...)
    -- get & check input from description
    local checkSuccess, obj, objRef = InputChecker.Check([[
        This method saves an Obj in the ObjHost.

        If an objRef argument is supplied that Obj reference is used.
        If the objRef argument is "" and the Obj is an LObj the id of the LObj is used.

        Return value:
            objLocator              - (ObjLocator) locating the object

        Parameters:
            obj                     + (table) the Obj
            objRef                  + (string, "") with a Obj reference (e.g. the id of an LObj)
    ]], ...)
    if not checkSuccess then corelog.Error("ObjHost:saveObj: Invalid input") return nil end
    if not Class.IsInstanceOf(obj, IObj) then corelog.Error("ObjHost:saveObj: object is not an IObj") return nil end

    -- determine objLocator
    if objRef == "" and Class.IsInstanceOf(obj, ILObj) then
        objRef = obj:getId()
    end
    local objLocator = ObjLocator:newInstance(self:getHostName(), obj:getClassName(), objRef)

    -- save resource
    local resourceLocator = self:saveResource(obj, objLocator)
    if not resourceLocator then corelog.Error("ObjHost:saveObj: Failed saving Obj located by "..objLocator:getURI()) return nil end

    -- end
    return objLocator
end

function ObjHost:saveObj_SSrv(...)
    -- get & check input from description
    local checkSuccess, obj = InputChecker.Check([[
        This sync service saves an Obj in the ObjHost.

        Return value:
                                - (table)
                success         - (boolean) whether the service executed successfully
                objLocator      - (ObjLocator) locating the object

        Parameters:
            serviceData         - (table) data for this service
                obj             + (table) the Obj
    ]], ...)
    if not checkSuccess then corelog.Error("ObjHost:saveObj_SSrv: Invalid input") return {success = false} end

    -- save object
    local objLocator = self:saveObj(obj)
    if not objLocator then corelog.Error("ObjHost:saveObj_SSrv: Failed saving Obj "..textutils.serialise(obj)) return {success = false} end

    -- end
    return {
        success         = true,
        objLocator      = objLocator,
    }
end

function ObjHost:getObjects(...)
    -- get & check input from description
    local checkSuccess, className = InputChecker.Check([[
        This (private) method retrieves all the objects in the ObjHost with class className.

        Return value:
            objects                 - (table) with the objects

        Parameters:
            className               + (string) with the name of the class of the objects
    --]], ...)
    if not checkSuccess then corelog.Error("ObjHost:getObjects: Invalid input") return nil end

    -- get objectsLocator
    local objectsLocator = ObjLocator:newInstance(self:getHostName(), className)

    -- get objects
    local objects = self:getResource(objectsLocator)
    if not objects then
        -- (re)set objects
        objectsLocator = self:saveResource({}, objectsLocator)
        if not objectsLocator then corelog.Error("ObjHost:getObjects: Failed initialising "..className.."'s located by "..objectsLocator:getURI()) return nil end

        -- retrieve again
        objects = self:getResource(objectsLocator)
        if not objects then corelog.Error("ObjHost:getObjects: Failed (re)setting "..className.."'s") return nil end
    end

    -- end
    return objects
end

function ObjHost:getNumberOfObjects(...)
    -- get & check input from description
    local checkSuccess, className = InputChecker.Check([[
        This method returns the number of objects in the ObjHost with class className.

        Return value:
                                    - (number) of objects of class className hosted by the ObjHost.

        Parameters:
            className               + (string) with the name of the class of the objects
    --]], ...)
    if not checkSuccess then corelog.Error("ObjHost:getNumberOfObjects: Invalid input") return -1 end

    -- get objects
    local objects = self:getObjects(className)
    if type(objects) ~= "table" then corelog.Error("ObjHost:getNumberOfObjects: Failed obtaining objects of class "..className) return -1 end

    -- loop on objects
    local count = 0
    for k, object in pairs(objects) do
        count = count + 1
    end

    return count
end

function ObjHost:deleteObjects(...)
    -- get & check input from description
    local checkSuccess, className = InputChecker.Check([[
        This method deletes all the objects in the ObjHost with class className.

        Return value:

        Parameters:
            className               + (string) with the name of the class of the objects
    --]], ...)
    if not checkSuccess then corelog.Error("ObjHost:deleteObjects: Invalid input") return nil end

    -- get objects
    local objects = self:getObjects(className)
    if type(objects) ~= "table" then corelog.Error("ObjHost:deleteObjects: Failed obtaining objects of class "..className) return nil end

    -- delete all objects
--    corelog.Warning("All objects of class "..className.." are being deleted!")
    for id, _obj in pairs(objects) do
        -- get locator
        local objLocator = ObjLocator:newInstance(self:getHostName(), className, id)

        -- delete
        self:deleteResource(objLocator)
    end
end

--        _        _   _
--       | |      | | (_)
--    ___| |_ __ _| |_ _  ___
--   / __| __/ _` | __| |/ __|
--   \__ \ || (_| | |_| | (__
--   |___/\__\__,_|\__|_|\___|

function ObjHost.GetObj(...)
    -- get & check input from description
    local checkSuccess, objLocator = InputChecker.Check([[
        This method retrieves an Obj from a ObjHost using using a uniform resource locator (URL).

        The method first retrieves the ObjHost corresponding to the URL. If the URL locates the ObjHost itself it returns the ObjHost.
        Otherwise it will retrieve the Obj from the ObjHost with the getObj method of the ObjHost.

        Return value:
            object                  - (?) object obtained from the ObjHost

        Parameters:
            objLocator              + (URL) locator of the Obj within the ObjHost
    ]], ...)
    if not checkSuccess then corelog.Error("ObjHost.GetObj: Invalid input") return nil end

    -- get ObjHost
    local host = Host.GetHost(objLocator:getHost()) if not host then corelog.Error("ObjHost.GetObj: ObjHost of "..objLocator:getURI().." not found") return nil end

    -- check the ObjHost itself is wanted
    if objLocator:isEqual(host:getHostLocator()) then
        return host
    end

    -- get obj from ObjHost
    local obj = host:getObj(objLocator)
    if not obj then corelog.Error("ObjHost.GetObj: Failed getting object for objectLocator="..objLocator:getURI()) return nil end

    -- end
    return obj
end

return ObjHost
