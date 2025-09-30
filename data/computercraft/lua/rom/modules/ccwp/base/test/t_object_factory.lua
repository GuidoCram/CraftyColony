local T_ObjectFactory = {}

local corelog = require "corelog"

local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

function T_ObjectFactory.T_All()
    -- specific
    T_ObjectFactory.T_registerClass()
    T_ObjectFactory.T_create()
end

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

local TestClass = {
    _aField = ""
}

function TestClass:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

local InvalidTestClass = {
    _aField = ""
}

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function T_ObjectFactory.T_registerClass()
    -- prepare test
    corelog.WriteToLog("* ObjectFactory:registerClass() tests")

    -- test valid
    local className = "TestClass"
    local isRegistered = objectFactory:registerClass(className, TestClass)
    assert(isRegistered, "Failed to register class "..className)
    isRegistered = objectFactory:isRegistered(className)
    assert(isRegistered, "Class "..className.." not registered")
    objectFactory:delistClass(className)
    isRegistered = objectFactory:isRegistered(className)
    assert(not isRegistered, "Class "..className.." still registered")

    -- test invalid (no new)
    className = "InvalidTestClass"
    isRegistered = objectFactory:registerClass(className, InvalidTestClass)
    assert(not isRegistered, "Class "..className.." got incorrectly registered")
    isRegistered = objectFactory:isRegistered(className)
    assert(not isRegistered, "Class "..className.." incorrectly registered")

    -- cleanup test
end

function T_ObjectFactory.T_create()
    -- prepare test
    corelog.WriteToLog("* ObjectFactory:create() tests")
    objectFactory:registerClass("TestClass", TestClass)

    -- test valid
    local className = "TestClass"
    local objTable1 = { } -- default
    local obj1 = objectFactory:create(className, objTable1)
    assert(obj1, "Failed to create object of type " .. className)
    assert(type(obj1) == "table" and obj1.__index == TestClass, "Failed to create object of type "..className)
--    corelog.WriteToLog(" obj1="..obj1:getURI())

    -- test invalid
    className = "InvalidType"
    local objTable2 = { "some field" }
    local obj2 = objectFactory:create(className, objTable2)
    assert(not obj2, "Unexpectedly created object of type " .. className)

    -- cleanup test
    objectFactory:delistClass(className)
end

return T_ObjectFactory
