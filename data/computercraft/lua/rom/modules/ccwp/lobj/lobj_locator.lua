-- define class
local Class = require "class"
local ObjLocator = require "obj_locator"
local LObjLocator = Class.NewClass(ObjLocator)

--[[
    This module implements the class LObjLocator.

    A LObjLocator is a ObjLocator that locates an LObj.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"

local ILObj = require "i_lobj"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function LObjLocator:_init(...)
    -- get & check input from description
    local checkSuccess, hostName, lobj, query = InputChecker.Check([[
        Initialise a LObjLocator.

        Parameters:
            hostName                + (string) with hostName of the Host
            lobj                    + (?) with ILObj
            query                   + (table, {}) of key-value pairs with (item) query segments
    ]], ...)
    if not checkSuccess then corelog.Error("LObjLocator:_init: Invalid input") return nil end
    if not Class.IsInstanceOf(lobj, ILObj) then corelog.Error("LObjLocator:_init: lobj is not an ILObj") return nil end

    -- determine objRef
    local objClassName = lobj:getClassName()
    local objRef = lobj:getId()

    -- initialisation
    ObjLocator._init(self, hostName, objClassName, objRef, query)
end

function LObjLocator:getObjId()
    return self:getObjRef()
end


--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function LObjLocator:getClassName()
    return "LObjLocator"
end

return LObjLocator
