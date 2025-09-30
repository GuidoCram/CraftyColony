-- defines the class (nothing special)
local enterprise_dump       = {} --Class.NewClass(ObjHost)

--[[
    The enterprise_dump is not a ObjHost. It remembers the possible depot's for waste processing.
--]]

-- basics
local coredht       = require "coredht"
local corelog       = require "corelog"
local Class         = require "class"
local ObjHost       = require "obj_host"
local InputChecker  = require "input_checker"
local ObjLocator    = require "obj_locator"

-- interfaces
local IItemDepot = require "i_item_depot"

-- enterprises
local enterprise_employment = require "enterprise_employment"

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

local dhtRoot = "enterprise_dump" -- just a list of available depot locators

local function LoadData()
    local dumpData  = nil                       -- silly two liner to suppress lua warning
    dumpData        = coredht.GetData(dhtRoot)  -- silly two liner to suppress lua warning

    -- check data
    if type(dumpData) ~= "table" or type(dumpData[1]) ~= "table" then dumpData = enterprise_dump.Reset() end

    -- check if we are present...
    return dumpData
end

-- get your locator for the best dump (just 1 at the moment)
function enterprise_dump.GetDumpLocator()

    -- get the data
    local dumpData = LoadData()

    -- the requested ObjLocator, create from table
    local depotLocator = ObjLocator:new(dumpData[#dumpData])

    -- we return
    return depotLocator
end

local function SaveData(dumpData)
    -- check if we are present...
    coredht.SaveData(dumpData, dhtRoot)
end

local function ListItemDepot(itemDepotLocator, mode)

    -- get the data
    local dumpData = LoadData()

    -- add the locator, depending on the mode overwrite or append
    if mode == "overwrite" or mode == "w"   then dumpData[#dumpData] = itemDepotLocator
                                            else table.insert(dumpData, itemDepotLocator)
    end

    -- save this shit
    SaveData(dumpData)
end

-- add a depot to the dump
function enterprise_dump.ListItemDepot_SSrv(...)
    local checkSuccess, itemDepotLocator, mode = InputChecker.Check([[
        For enlisting a new item depot to the dump

        Return value:
                                    - (table)
            success                 - (boolean) whether the service executed successfully

        Parameters:
            serviceData             - (table) data for the service
                itemDepotLocator    + (ObjLocator) the depot locator to add to the dump
                mode                + (string, "append") append or overwrite the last known depot in the dump]], ...)
    if not checkSuccess then corelog.Error("enterprise_dump.ListItemDepot_SSrv: Invalid input") return {succes = false} end

    -- check ItemDepot
    local objClass = itemDepotLocator:getObjClass()
    if not Class.IsInstanceOf(objClass, IItemDepot) then corelog.Error("enterprise_dump.ListItemDepot_SSrv: objClass of ObjLocator "..itemDepotLocator:getURI().." is not an IItemDepot") return {success = false} end

    -- do the works
    ListItemDepot(itemDepotLocator, mode)

    -- done!
    return {success = true}
end

-- remove a depot to the dump
function enterprise_dump.DelistItemDepot(itemDepotLocator)
    -- vars
    local found     = false
    local dumpData  = LoadData()

    -- check if this one is in our list
    for i, loc in ipairs(dumpData) do

        -- check if both ObjLocator's are the same

    end

    -- save this shit
    if found then SaveData(dumpData) end
end

--    _                 _
--   | |               | |
--   | | ___   ___ __ _| |
--   | |/ _ \ / __/ _` | |
--   | | (_) | (_| (_| | |
--   |_|\___/ \___\__,_|_|
--
--

function enterprise_dump.Reset()
    -- start over
    local dumpData = {}

    -- add any turtle
    table.insert(dumpData, enterprise_employment.GetAnyTurtleLocator())

    -- save!
    SaveData(dumpData)

    -- yahoo!
    return dumpData

    --    -- if you like one liners, not so readable
--    return SaveData({enterprise_employment.GetAnyTurtleLocator()})
end

-- done
return enterprise_dump
