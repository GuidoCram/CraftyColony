-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ObjArray = Class.NewClass(ObjBase)

--[[
    This module implements the class ObjArray.

    A ObjArray is an array of Obj's of the same 'class'. The class should implement the IObj interface.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"
local IObj = require "i_obj"
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function ObjArray:_init(...)
    -- get & check input from description
    local checkSuccess, objClassName, objsArray = InputChecker.Check([[
        Initialise a ObjArray.

        Parameters:
            objClassName            + (string, "") with className of objects in ObjArray (e.g. "Chest")
            objsArray               + (table, {}) with array of Obj in ObjArray
    ]], ...)
    if not checkSuccess then corelog.Error("ObjArray:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._objClassName  = objClassName
    local objClass = objectFactory:getClass(objClassName)
    for i, obj in ipairs(objsArray) do
        if not Class.IsInstanceOf(obj, IObj) then
            corelog.Warning("ObjArray:_init: obj not an IObj => skipped")
        else
            if not Class.IsInstanceOf(obj, objClass) then
                corelog.Warning("ObjArray:_init: obj type(="..obj:getClassName()..") not "..objClassName.." => skipped")
            else
                self[i] = obj
            end
        end
    end
end

-- ToDo: should be renamed to newFromTable at some point
function ObjArray:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Constructs an ObjArray.

        Parameters:
            o                   + (table, {}) table with
                _objClassName   - (string, "") with className of objects in ObjArray (e.g. "Chest")
    ]], ...)
    if not checkSuccess then corelog.Error("ObjArray:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- transform Obj's if needed
    o:transformObjectTables()

    -- end
    return o
end

function ObjArray:getObjClassName()
    return self._objClassName
end

function ObjArray:getObjClass()
    local objClass = objectFactory:getClass(self._objClassName)
    if not objClass then corelog.Error("ObjArray:getObjClass(): failed obtaining class "..self._objClassName.." from objectFactory (did we forget to set _objClassName?)") end

    return objClass
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function ObjArray:getClassName()
    return "ObjArray"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function ObjArray:nObjs()
    return #self
end

function ObjArray:transformObjectTables(suppressWarning)
    --[[
        Transform the objects in the ObjArray that are still object tables into objects of type 'objClass'.

        Parameters:
            suppressWarning         + (boolean, false) if Warning should be suppressed
    --]]
    suppressWarning = suppressWarning or false

    -- check if empty
    if table.getn(self) == 0 then return end

    -- get objClass
    local objClassName = self:getObjClassName()
    local objClass = self:getObjClass()
    if not objClass then corelog.Error("ObjArray:transformObjectTables(): failed obtaining objClass "..objClassName) return end
    if Class.IsInstanceOf(objClass, IObj) then
        -- ok
    else
        corelog.Error("ObjArray:transformObjectTables(): objClass "..objClassName.." does not implement IObj interface") return
    end

    -- transform objectTable's
    local nrSkipped = 0
    for i, objectTable in ipairs(self) do
        -- check if objectTable already an Obj
        local objectTableClassName = nil
        if Class.IsInstanceOf(objectTable, IObj) then
            objectTableClassName = objectTable:getClassName()
        end

        -- determine obj
        local obj = nil
        if objectTableClassName then
            -- check Obj of correct type
            if Class.IsInstanceOf(objectTable, objClass) then
                obj = objectTable -- already an object of (at least) type 'objClass'
            else
                if not suppressWarning then corelog.Warning("ObjArray:transformObjectTables(): objectTable class (="..objectTableClassName..") different from objClassName(="..objClassName..")") end
            end
        else
            obj = objClass:new(objectTable) -- transform
        end

        -- add/ change in self ObjArray
        self[i] = nil
        self[i-nrSkipped] = obj

        -- check obj obtained
        if not obj then
            if not suppressWarning then corelog.Warning("ObjArray:transformObjectTables(): failed transforming objectTable(="..textutils.serialize(objectTable)..") to a "..objClassName.." object => skipped") end
            nrSkipped = nrSkipped + 1
        end
    end
end

return ObjArray
