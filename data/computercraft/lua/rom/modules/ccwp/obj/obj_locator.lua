-- define class
local Class = require "class"
local URL = require "obj_url"
local ObjLocator = Class.NewClass(URL)

--[[
    This module implements the class ObjLocator.

    A ObjLocator is a URL that locates an Obj.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

local objClassNameStr = "class"
local objRefStr = "ref"

function ObjLocator:_init(...)
    -- get & check input from description
    local checkSuccess, hostName, objClassName, objRef, query = InputChecker.Check([[
        Initialise a ObjLocator.

        Parameters:
            hostName                + (string) with hostName of the Host
            objClassName            + (string) with className of the Obj
            objRef                  + (string, "") with a Obj reference (e.g. the id of the LObj)
            query                   + (table, {}) of key-value pairs with (item) query segments
    ]], ...)
    if not checkSuccess then corelog.Error("ObjLocator:_init: Invalid input") return nil end

    -- determine objPath
    local objPath = "/objects/"..objClassNameStr.."="..objClassName
    if objRef ~= "" then
        objPath = objPath.."/"..objRefStr.."="..objRef
    end

    -- initialisation
    local port = nil
    URL._init(self, hostName, objPath, query, port)
end

local classNamePattern = "%/"..objClassNameStr.."=([%w]+)"
function ObjLocator:getObjClassName()
    -- determine objClassName from path
    local objClassName = self:getPath():match(classNamePattern)
    if not objClassName then corelog.Warning("ObjLocator:getObjClassName: no objClassName in path of "..self:getURI()) end

    -- end
    return objClassName
end

function ObjLocator:getObjClass()
    -- determine objClass
    local objClassName = self:getObjClassName()
    local objClass = objectFactory:getClass(objClassName)
    if not objClass then corelog.Warning("ObjLocator:getObjClass: objClass of ObjLocator "..self:getURI().." not found in objectFactory") end

    -- end
    return objClass
end

local objRefPattern = "%/"..objRefStr.."=([%w:]+)"
function ObjLocator:getObjRef()
    -- get objClassName from path
    local objRef = self:getPath():match(objRefPattern)
    if not objRef then corelog.Warning("ObjLocator:getObjRef: no objRef in path of "..self:getURI()) return nil end

    -- end
    return objRef
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function ObjLocator:getClassName()
    return "ObjLocator"
end

return ObjLocator
