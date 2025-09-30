-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ObjTable = Class.NewClass(ObjBase)

--[[
    This module implements the class ObjTable.

    A ObjTable is a key-value pair table of Obj's of the same 'class'. The class should implement the IObj interface.
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

function ObjTable:_init(...)
    -- get & check input from description
    local checkSuccess, objClassName, objsTable = InputChecker.Check([[
        Initialise a ObjTable.

        Parameters:
            objClassName            + (string, "") with className of objects in ObjTable (e.g. "Chest")
            objsTable               + (table, {}) with key, value pairs of Obj in ObjTable
    ]], ...)
    if not checkSuccess then corelog.Error("ObjTable:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._objClassName  = objClassName
    local objClass = objectFactory:getClass(objClassName)
    for key, obj in pairs(objsTable) do
        if key == "_objClassName" then
            corelog.Warning("ObjTable:_init: key of object in objsTable is not allowed to be reserved key _objClassName => skipped")
        else
            if not Class.IsInstanceOf(obj, IObj) then
                corelog.Warning("ObjTable:_init: obj not an IObj => skipped")
            else
                if not Class.IsInstanceOf(obj, objClass) then
                    corelog.Warning("ObjTable:_init: obj type(="..obj:getClassName()..") not "..objClassName.." => skipped")
                else
                    self[key] = obj
                end
            end
        end
    end
end

-- ToDo: should be renamed to newFromTable at some point
function ObjTable:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Constructs an ObjTable.

        Parameters:
            o                   + (table, {}) table with
                _objClassName   - (string, "") with className of objects in ObjTable (e.g. "Chest")
    ]], ...)
    if not checkSuccess then corelog.Error("ObjTable:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- transform Obj's if needed
    o:transformObjectTables()

    -- end
    return o
end

function ObjTable:getObjClassName()
    return self._objClassName
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function ObjTable:getClassName()
    return "ObjTable"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function ObjTable:getObjClass()
    local objClass = objectFactory:getClass(self._objClassName)
    if not objClass then corelog.Error("ObjTable:getObjClass(): failed obtaining class "..self._objClassName.." from objectFactory (did we forget to set _objClassName?)") end

    return objClass
end

function ObjTable:nObjs()
    -- count
    local nObj = 0
    for key, el in self:objs() do
        nObj = nObj + 1
    end

    -- end
    return nObj
end

function ObjTable:objs()
    --[[
        Factory for iterator over Obj's.

        note: this iterator ensures a proper iterator is obtained that skips the _objClassName field.
    --]]

    -- create iterator that skips _objClassName
    local function nextObj(table, key)
        local newKey, value = next(table, key)
        while newKey do
            if newKey ~= "_objClassName" then
                return newKey, value
            end
            newKey, value = next(table, newKey) -- Continue to the next key-value pair
        end
    end

    return nextObj, self, nil
end

function ObjTable:verifyObjsOfCorrectType(suppressWarning)
    --[[
        This method verifies of all Obj's in the ObjTable are of the correct type (i.e. equal to objClassName).

        note: normally this should be true. However, as it's allowed to add objects in the usual way of adding objects to a table we might want to verify.

        Parameters:
            suppressWarning         + (boolean, false) if Warning should be suppressed
    --]]

    suppressWarning = suppressWarning or false

    -- verify Obj's
    for key, obj in self:objs() do
        -- verfify IObj
        if not Class.IsInstanceOf(obj, IObj) then
            if not suppressWarning then corelog.Warning("ObjTable:verifyObjsOfCorrectType(): obj does not implement IObj interface") end
            return false
        end

        -- verfify className
        if obj:getClassName() ~= self:getObjClassName() then
            if not suppressWarning then corelog.Warning("ObjTable:verifyObjsOfCorrectType: obj type(="..obj:getClassName()..") not equal to "..self:getObjClassName()) end
            return false
        end
    end

    -- end
    return true
end

function ObjTable:transformObjectTables(suppressWarning)
    --[[
        Transform the objects in the ObjTable that are still object tables into objects of type 'objClass'.

        Parameters:
            suppressWarning         + (boolean, false) if Warning should be suppressed
    --]]
    suppressWarning = suppressWarning or false

    -- check if empty
    if self:nObjs() == 0 then return end

    -- get objClass
    local objClassName = self:getObjClassName()
    local objClass = self:getObjClass()
    if not objClass then corelog.Error("ObjTable:transformObjectTables(): failed obtaining objClass "..objClassName) return end
    if Class.IsInstanceOf(objClass, IObj) then
        -- ok
    else
        corelog.Error("ObjTable:transformObjectTables(): objClass "..objClassName.." does not implement IObj interface") return
    end

    -- transform objectTable's
    for key, objectTable in self:objs() do
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
                if not suppressWarning then corelog.Warning("ObjTable:transformObjectTables(): objectTable class (="..objectTableClassName..") different from objClassName(="..objClassName..")") end
            end
        else
            obj = objClass:new(objectTable) -- transform
        end

        -- add/ change in self ObjTable
        self[key] = obj

        -- check obj obtained
        if not obj then
            if not suppressWarning then corelog.Warning("ObjTable:transformObjectTables(): failed transforming objectTable(="..textutils.serialize(objectTable)..") to a "..objClassName.." object => skipped") end
        end
    end
end

return ObjTable
