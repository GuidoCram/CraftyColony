-- define interface
local IRegistry = {
}

--[[
    This module specifies the IRegistry interface.

    It defines methods for a class to be a Registry. A Registry registers things (typically a table or Obj) with a key. The things
    can be retrieved from the registry with that key.
--]]

local corelog = require "corelog"

local IInterface = require "i_interface"
local InputChecker = require "input_checker"

--    _____ _____            _     _
--   |_   _|  __ \          (_)   | |
--     | | | |__) |___  __ _ _ ___| |_ _ __ _   _
--     | | |  _  // _ \/ _` | / __| __| '__| | | |
--    _| |_| | \ \  __/ (_| | \__ \ |_| |  | |_| |
--   |_____|_|  \_\___|\__, |_|___/\__|_|   \__, |
--                      __/ |                __/ |
--                     |___/                |___/

function IRegistry:getRegistered(...)
    -- get & check input from description
    local checkSuccess, key = InputChecker.Check([[
        This method provides the thing registered by 'key' in the Registry.

        Return value:
            ???                 - (???) registered thing

        Parameters:
            key                 + (???) key of the registered thing
    --]], ...)
    if not checkSuccess then corelog.Error("IRegistry:getRegistered: Invalid input") return nil end

    IInterface.UnimplementedMethodError("IRegistry", "getRegistered")

    return nil
end

function IRegistry:register(...)
    -- get & check input from description
    local checkSuccess, key, thing = InputChecker.Check([[
        This method registers a 'thing' by 'key' in the Registry.

        Return value:
                                    - (boolean) whether the method executed successfully

        Parameters:
            key                     + (???) key of the registered thing
            thing                   + (???) the thing to register
    --]], ...)
    if not checkSuccess then corelog.Error("IRegistry:register: Invalid input") return false end

    IInterface.UnimplementedMethodError("IRegistry", "register")

    return false
end

function IRegistry:isRegistered(...)
    -- get & check input from description
    local checkSuccess, key = InputChecker.Check([[
        This method returns if a thing is registered by 'key' in the Registry.

        Return value:
                                    - (boolean) whether a things is registered by 'key'

        Parameters:
            key                     + (???) key of the registered thing
    ]], ...)
    if not checkSuccess then corelog.Error("IRegistry:isRegistered: Invalid input") return false end

    IInterface.UnimplementedMethodError("IRegistry", "isRegistered")

    return false
end

function IRegistry:delist(...)
    -- get & check input from description
    local checkSuccess, key = InputChecker.Check([[
        This method delists a thing registered by 'key' from the Registry.

        Return value:
                                    - (boolean) whether the method executed successfully

        Parameters:
            key                     + (???) key of the registered thing
    ]], ...)
    if not checkSuccess then corelog.Error("IRegistry:delist: Invalid input") return false end

    IInterface.UnimplementedMethodError("IRegistry", "delist")

    return false
end

return IRegistry
