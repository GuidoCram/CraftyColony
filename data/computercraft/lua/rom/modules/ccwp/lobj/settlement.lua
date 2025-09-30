-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ILObj = require "i_lobj"
local Settlement = Class.NewClass(ObjBase, ILObj)

--[[
    This module implements a Settlement.

    A Settlement represents a self-contained area within the minecraft world with associated L/MObj's.
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"

local InputChecker = require "input_checker"

local enterprise_colonization

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function Settlement:_init(...)
    -- get & check input from description
    local checkSuccess, id, mainShopLocator = InputChecker.Check([[
        Initialise a Settlement.

        Parameters:
            id                      + (string) id of the Settlement
            mainShopLocator         + (ObjLocator) with locator to the main shop
    ]], ...)
    if not checkSuccess then corelog.Error("Settlement:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id                    = id
    self._mainShopLocator       = mainShopLocator
end

-- ToDo: should be renamed to newFromTable at some point
function Settlement:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a Settlement.

        Parameters:
            o                           + (table, {}) table with object fields
                _id                     - (string) id of the forest
                _mainShopLocator        - (ObjLocator) with locator to the main shop
    ]], ...)
    if not checkSuccess then corelog.Error("Settlement:new: Invalid input") return {} end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function Settlement:getMainShopLocator()
    return self._mainShopLocator
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function Settlement:getClassName()
    return "Settlement"
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function Settlement:construct(...)
    -- get & check input from description
    local checkSuccess = InputChecker.Check([[
        This method constructs a Settlement instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        The constructed Settlement is not yet saved in the LObjHost.

        Return value:
                                        - (Settlement) the constructed Settlement

        Parameters:
            constructParameters         - (table) parameters for constructing the Settlement
    ]], ...)
    if not checkSuccess then corelog.Error("Settlement:construct: Invalid input") return nil end

    -- determine Settlement fields
    local id = coreutils.NewId()
    enterprise_colonization = enterprise_colonization or require "enterprise_colonization"
    local mainShopLocator = enterprise_colonization:hostLObj_SSrv({ className = "Shop", constructParameters = {
    }}).mobjLocator

    -- construct new Settlement
    local obj = Settlement:newInstance(id, mainShopLocator)

    -- end
    return obj
end

function Settlement:destruct()
    --[[
        This method destructs a Settlement instance.

        The Settlement is not yet deleted from the LObjHost.

        Return value:
                                        - (boolean) whether the Settlement was succesfully destructed.

        Parameters:
    ]]

    -- release Shop
    local destructSuccess = true
    enterprise_colonization = enterprise_colonization or require "enterprise_colonization"
    local releaseResult = enterprise_colonization:releaseLObj_SSrv({ mobjLocator = self._mainShopLocator })
    if not releaseResult or not releaseResult.success then corelog.Warning("Factory:destruct(): failed releasing mainShopLocator "..self._mainShopLocator:getURI()) destructSuccess = false end
    self._mainShopLocator = nil

    -- end
    return destructSuccess
end

function Settlement:getId()
    return self._id
end

function Settlement:getWIPId()
    --[[
        Returns the unique Id of the Settlement used for administering WIP.
    ]]

    return self:getClassName().." "..self:getId()
end

--     _____      _   _   _                           _
--    / ____|    | | | | | |                         | |
--   | (___   ___| |_| |_| | ___ _ __ ___   ___ _ __ | |_
--    \___ \ / _ \ __| __| |/ _ \ '_ ` _ \ / _ \ '_ \| __|
--    ____) |  __/ |_| |_| |  __/ | | | | |  __/ | | | |_
--   |_____/ \___|\__|\__|_|\___|_| |_| |_|\___|_| |_|\__|

return Settlement
