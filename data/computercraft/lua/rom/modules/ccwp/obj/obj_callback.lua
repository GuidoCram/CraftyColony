-- define class
local Class = require "class"
local CallDef = require "obj_call_def"
local Callback = Class.NewClass(CallDef)

--[[
    This module implements the class Callback.

    A Callback defines a callback function and (minimum) callback data.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"
local MethodExecutor = require "method_executor"

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function Callback:getClassName()
    return "Callback"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function Callback:call(...)
    -- get & check input from description
    local checkSuccess, resultData = InputChecker.Check([[
        This method executes the callback with predefined callback data and the supplied data.

        Return value:
            ?                       - (?) return value of callback function

        Parameters:
            resultData              + (table) with second argument to supply to callback function, typically the return data of the task function
    ]], ...)
    if not checkSuccess then corelog.Error("Callback:call: Invalid input") return nil end

    -- call method
    return MethodExecutor.CallModuleMethod(self._moduleName, self._methodName, { self._data, resultData })
end

--    _          _                    __                  _   _
--   | |        | |                  / _|                | | (_)
--   | |__   ___| |_ __   ___ _ __  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | '_ \ / _ \ | '_ \ / _ \ '__| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | | |  __/ | |_) |  __/ |    | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_| |_|\___|_| .__/ \___|_|    |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--                | |
--                |_|

function Callback.ErrorCall(callback)
    -- check for callback
    if not Class.IsInstanceOf(callback, Callback) then
--        corelog.Warning("Callback.ErrorCall: Invalid callback (type="..type(callback)..")")
        return false -- schedule result
    end

    -- call method
    return callback:call({success = false}) -- call result
end

function Callback.GetNewDummyCallBack()
    -- construct dummy callback
    local callback = Callback:newInstance("Callback", "Dummy_Callback")

    -- end
    return callback
end

function Callback.Dummy_Callback(...)
    corelog.WriteToProjectsLog("Callback.Dummy_Callback called")
    -- do nothing

    -- end
    return true
end

return Callback
