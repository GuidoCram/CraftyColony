-- define module
local ObjectFactory = {
    classes = {},
}

--[[
    This module implements the class ObjectFactory.

    The ObjectFactory object is a singleton representing a factory for creating (and obtaining) obj's based on a registered class.

    A class registered at the ObjectFactory should implement a "new" method that, supplied with a table with all object fields,
    creates a new instance of the object based on the class.
--]]

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

local instance = nil
function ObjectFactory:getInstance()
    if not instance then
        instance = setmetatable({}, { __index = ObjectFactory })
    end
    return instance
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

-- ToDo: consider revising using Class:newInstance
function ObjectFactory:create(className, objectFieldsTable)
--    local corelog = require "corelog"
--    corelog.WriteToLog("about to create "..className.." with "..textutils.serialise(objectFieldsTable))
    local class = self:getClass(className)
    if class then
        return class:new(objectFieldsTable)
    else
        return nil
    end
end

function ObjectFactory:registerClass(className, class)
    if class.new then
        self.classes[className] = class
--    else
--        error("ObjectFactory:registerClass: class "..className.." does not have new method: are we implementing newInstance instead?")
    end

    return self:isRegistered(className)
end

function ObjectFactory:getClass(className)
    return self.classes[className]
end

function ObjectFactory:isRegistered(className)
    return self:getClass(className) ~= nil
end

function ObjectFactory:delistClass(className)
    self.classes[className] = nil
end

return ObjectFactory
