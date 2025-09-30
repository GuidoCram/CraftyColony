-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ILObj = require "i_lobj"
local LObjTest = Class.NewClass(ObjBase, ILObj)

--[[
    This module implements the class LObjTest.

    A LObjTest object can be used for testing LObj related functionality.
--]]

local corelog = require "corelog"
local coreutils = require "coreutils"

local InputChecker = require "input_checker"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function LObjTest:_init(...)
    -- get & check input from description
    local checkSuccess, id, field1 = InputChecker.Check([[
        Initialise a LObjTest.

        Parameters:
            id                      + (string) id of the LObjTest
            field1                  + (string) field 1
    ]], ...)
    if not checkSuccess then corelog.Error("LObjTest:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id            = id
    self._field1        = field1
end

-- ToDo: should be renamed to newFromTable at some point
function LObjTest:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a LObjTest.

        Parameters:
            o                           + (table, {}) with object fields
                _id                     - (string) id of the LObjTest
                _field1                 - (string) field
    ]], ...)
    if not checkSuccess then corelog.Error("LObjTest:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function LObjTest:getField1()
    return self._field1
end

function LObjTest:setField1(strValue)
    -- check input
    if type(strValue) ~= "string" then corelog.Error("LObjTest:setField1: invalid strValue: "..type(strValue)) return end

    self._field1 = strValue
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function LObjTest:getClassName()
    return "LObjTest"
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function LObjTest:construct(...)
    -- get & check input from description
    local checkSuccess, field1Value = InputChecker.Check([[
        This method constructs a LObjTest instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        It also ensures all child MObj's the LObjTest spawns are hosted on the appropriate MObjHost (by calling hostLObj_SSrv).

        The constructed LObjTest is not yet saved in the LObjHost.

        Return value:
                                        - (LObjTest) the constructed LObjTest

        Parameters:
            constructParameters         - (table) parameters for constructing the MObj
                field1Value             + (string) value to set field1 to
    ]], ...)
    if not checkSuccess then corelog.Error("LObjTest:construct: Invalid input") return nil end

    -- determine LObjTest fields
    local id = coreutils.NewId()

    -- construct new LObjTest
    local obj = self:newInstance(id, field1Value)

    -- end
    return obj
end

function LObjTest:upgrade(...)
    -- get & check input from description
    local checkSuccess, field1 = InputChecker.Check([[
        This method upgrades a LObjTest instance from a table of parameters.

        The upgraded LObjTest is not yet saved in the LObjHost.

        Return value:
                                        - (boolean) whether the LObjTest was succesfully upgraded.

        Parameters:
            upgradeParameters           - (table) parameters for upgrading the LObjTest
                field1                  + (string) with field1 value to upgrade to
    ]], ...)
    if not checkSuccess then corelog.Error("LObjTest:upgrade: Invalid input") return false end

    -- upgrade
    if self._field1 == field1 then corelog.Warning("LObjTest:upgrade: field1 is already equal to "..field1) end
    self._field1 = field1

    -- end
    return true
end

function LObjTest:destruct()
    --[[
        This method destructs a LObjTest instance.

        It also ensures all child MObj's the LObjTest is the parent of are released from the appropriate MObjHost (by calling releaseLObj_SSrv).

        The LObjTest is not yet deleted from the LObjHost.

        Return value:
                                        - (boolean) whether the LObjTest was succesfully destructed.

        Parameters:
    ]]

    -- end
    return true
end

function LObjTest:getId()
    --[[
        Return a unique Id of the LObjTest.
    ]]

    return self._id
end

function LObjTest:getWIPId()
    --[[
        Returns the unique Id of the LObjTest used for administering WIP.
    ]]

    return self:getClassName().." "..self:getId()
end

return LObjTest
