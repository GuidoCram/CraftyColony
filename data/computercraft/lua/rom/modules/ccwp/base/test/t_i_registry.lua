local T_IRegistry = {}

local corelog = require "corelog"
local IRegistry = require "i_registry"
local Class = require "class"

local T_IInterface = require "test.t_i_interface"
local T_Class = require "test.t_class"

function T_IRegistry.pt_all(registryName, registry, key, thing, key2, thing2, thingName)
    -- type
    T_Class.pt_IsInstanceOf(registryName, registry, "IRegistry", IRegistry)
    T_IInterface.pt_ImplementsInterface("IRegistry", IRegistry, registryName, registry)

    -- IRegistry
    T_IRegistry.pt_register_isRegistered(registryName, registry, key, thing, thingName)
    T_IRegistry.pt_delist(registryName, registry, key, thing, thingName)
    T_IRegistry.pt_getRegistered(registryName, registry, key, thing, key2, thing2, thingName)
end

local compact = { compact = true }

--    _____ _____            _     _
--   |_   _|  __ \          (_)   | |
--     | | | |__) |___  __ _ _ ___| |_ _ __ _   _
--     | | |  _  // _ \/ _` | / __| __| '__| | | |
--    _| |_| | \ \  __/ (_| | \__ \ |_| |  | |_| |
--   |_____|_|  \_\___|\__, |_|___/\__|_|   \__, |
--                      __/ |                __/ |
--                     |___/                |___/

function T_IRegistry.pt_register_isRegistered(registryName, registry, key, thing, thingName)
    -- prepare test
    assert(registryName, "no registryName provided")
    assert(registry, "no registry provided")
    assert(key, "no key provided")
    assert(thing, "no thing provided")
    assert(thingName, "no thingName provided")
    corelog.WriteToLog("* "..registryName..":register() and "..registryName..":isRegistered() tests")

    assert(not registry:isRegistered(key), thingName.." "..key.." already registered")

    -- test
    local registered = registry:register(key, thing)
    assert(registered, "Failed registering "..thingName.." "..key)
    assert(registry:isRegistered(key), thingName.." "..key.." not registered")

    -- cleanup test
    registry:delist(key)
end

function T_IRegistry.pt_delist(registryName, registry, key, thing, thingName)
    -- prepare test
    assert(registryName, "no registryName provided")
    assert(registry, "no registry provided")
    assert(key, "no key provided")
    assert(thing, "no thing provided")
    assert(thingName, "no thingName provided")
    corelog.WriteToLog("* "..registryName..":delist() test")

    registry:register(key, thing)
    assert(registry:isRegistered(key), thingName.." "..key.." not registered")

    -- test
    local delisted = registry:delist(key)
    assert(delisted, "Failed delisting "..thingName.." "..key)
    assert(not registry:isRegistered(key), thingName.." "..key.." not delisted")

    -- cleanup
end

function T_IRegistry.pt_getRegistered(registryName, registry, key, thing, key2, thing2, thingName)
    -- prepare test
    assert(registryName, "no registryName provided")
    assert(registry, "no registry provided")
    assert(key, "no key provided")
    assert(thing, "no thing provided")
    assert(key2, "no key2 provided")
    assert(thing2, "no thing2 provided")
    assert(thingName, "no thingName provided")
    corelog.WriteToLog("* "..registryName..":getRegistered() tests")

    assert(not registry:isRegistered(key), thingName.." "..key.." already registered")
    registry:register(key, thing)

    assert(not registry:isRegistered(key2), thingName.." "..key2.." already registered")
    registry:register(key2, thing2)

    local IObj = require "i_obj"

    -- test
    local retrievedThing1 = registry:getRegistered(key)
    local retrievedIsEqual = retrievedThing1 == thing
    if Class.IsInstanceOf(thing, IObj) then
        retrievedIsEqual = thing:isEqual(retrievedThing1)
    end
    assert(retrievedIsEqual, "Retrieved "..thingName.."1 (="..textutils.serialise(retrievedThing1, compact)..") does not match original "..thingName.."1 (="..textutils.serialise(thing, compact)..")")
    local retrievedThing2 = registry:getRegistered(key2)
    retrievedIsEqual = retrievedThing2 == thing2
    if Class.IsInstanceOf(thing2, IObj) then
        retrievedIsEqual = thing2:isEqual(retrievedThing2)
    end
    assert(retrievedIsEqual, "Retrieved "..thingName.."2 (="..textutils.serialise(retrievedThing1, compact)..") does not match original "..thingName.."2 (="..textutils.serialise(thing, compact)..")")

    -- cleanup test
    registry:delist(key)
    registry:delist(key2)
end

return T_IRegistry
