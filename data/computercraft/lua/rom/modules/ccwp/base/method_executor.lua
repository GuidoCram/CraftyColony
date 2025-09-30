-- define module
local MethodExecutor = {}

-- ToDo: add proper description here
--[[
    The MethodExecutor ...
--]]

local corelog = require "corelog"
local coreutils = require "coreutils"

local InputChecker = require "input_checker"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()
local Callback

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function MethodExecutor.DoSyncService(...)
    -- get & check input from description
    local checkSuccess, moduleName, serviceName, serviceData = InputChecker.Check([[
        This function executes a sync service method of a module.

        Return value:
            results                     - (?) service function return value

        Parameters:
            moduleName                  + (string) name of module with the service
            serviceName                 + (string) name of service function to execute
            serviceData                 + (table) with argument to supply to service function
    ]], ...)
    if not checkSuccess then corelog.Error("MethodExecutor.DoSyncService: Invalid input") return {success = false} end

    -- call method
    local results = MethodExecutor.CallModuleMethod(moduleName, serviceName, { serviceData })
    if type(results) ~= "table" then corelog.Error("MethodExecutor.DoSyncService: service function return value not a table(type="..type(results)..")") return {success = false} end

    -- end
    return results
end

function MethodExecutor.DoSyncObjService(...)
    -- get & check input from description
    local checkSuccess, className, objData, serviceName, serviceData = InputChecker.Check([[
        This function executes a sync service method of an obj.

        Return value:
            results                     - (?) service function return value

        Parameters:
            className                   + (string) name of class with the service
            objData                     + (table) with obj data
            serviceName                 + (string) name of service function to execute
            serviceData                 + (table) with argument to supply to service function
    ]], ...)
    if not checkSuccess then corelog.Error("MethodExecutor.DoSyncObjService: Invalid input") return nil end

    -- call method
    return MethodExecutor.CallObjMethod(className, objData, serviceName, { serviceData })
end

local doASyncService_Sync_serviceResults = {}

function MethodExecutor.DoASyncService_Sync(...)
    -- get & check input from description
    local checkSuccess, moduleName, serviceName, serviceData = InputChecker.Check([[
        This function executes an async service method of a module in a sync way. It does so by
            - creating an internal callback function
            - call the async service method with the callback
            - wait for the callback to be called
            - return the async service results the callback is called with

        It creates a callback function and waits for the callback to return.

        Return value:
            results                     - (?) service method return value

        Parameters:
            moduleName                  + (string) name of module with the service
            serviceName                 + (string) name of service function to execute
            serviceData                 + (table) with argument to supply to service function
    ]], ...)
    if not checkSuccess then corelog.Error("MethodExecutor.DoASyncService_Sync: Invalid input") return nil end

    -- create callback
    local callId = coreutils.NewId()
    Callback = Callback or require "obj_callback"
    local callback = Callback:newInstance("MethodExecutor", "doASyncService_Sync_Callback", {
        ["callId"] = callId,
    })

    -- call async service method
    MethodExecutor.CallModuleMethod(moduleName, serviceName, { serviceData, callback })

    -- wait for callback
    while not doASyncService_Sync_serviceResults[callId] do
        -- wait
        os.sleep(0.5)
    end

    -- get results
    local serviceResults = doASyncService_Sync_serviceResults[callId]
    doASyncService_Sync_serviceResults[callId] = nil -- remove temporary results

    -- end
    return serviceResults
end

function MethodExecutor.doASyncService_Sync_Callback(callbackData, serviceResults)
    -- temporary store results
    local callId = callbackData["callId"]
    doASyncService_Sync_serviceResults[callId] = serviceResults
    -- ToDo: consider if/ how we need to support this to work accross multiple turtles

    -- end
    return true
end

function MethodExecutor.DoASyncService(...)
    -- get & check input from description
    local checkSuccess, moduleName, serviceName, serviceData, callback = InputChecker.Check([[
        This function executes an async service method of a module.

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
            results                     - (?) service function return value

        Parameters:
            moduleName                  + (string) name of module with the service
            serviceName                 + (string) name of service function to execute
            serviceData                 + (table) with argument to supply to service function
            callback                    + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("MethodExecutor.DoASyncService: Invalid input") return nil end

    -- call method
    return MethodExecutor.CallModuleMethod(moduleName, serviceName, { serviceData, callback })
end

local doASyncObjService_Sync_serviceResults = {}

function MethodExecutor.DoASyncObjService_Sync(...)
    -- get & check input from description
    local checkSuccess, object, serviceName, serviceData = InputChecker.Check([[
        This function executes an async service method of an obj in a sync way. It does so by
            - creating an internal callback function
            - call the async service method with the callback
            - wait for the callback to be called
            - return the async service results the callback is called with

        It creates a callback function and waits for the callback to return.

        Return value:
            results                     - (?) service method return value

        Parameters:
            object                      + (table) object to execute on
            serviceName                 + (string) name of service function to execute
            serviceData                 + (table) with argument to supply to service function
    ]], ...)
    if not checkSuccess then corelog.Error("MethodExecutor.DoASyncObjServiceSync: Invalid input") return nil end

    -- create callback
    local callId = coreutils.NewId()
    Callback = Callback or require "obj_callback"
    local callback = Callback:newInstance("MethodExecutor", "doASyncObjService_Sync_Callback", {
        ["callId"] = callId,
    })

    -- call async service method
    MethodExecutor.CallInstanceMethod(object, serviceName, { serviceData, callback })

    -- wait for callback
    while not doASyncObjService_Sync_serviceResults[callId] do
        -- wait
        os.sleep(0.5)
    end

    -- get results
    local serviceResults = doASyncObjService_Sync_serviceResults[callId]
    doASyncObjService_Sync_serviceResults[callId] = nil -- remove temporary results

    -- end
    return serviceResults
end

function MethodExecutor.doASyncObjService_Sync_Callback(callbackData, serviceResults)
    -- temporary store results
    local callId = callbackData["callId"]
    doASyncObjService_Sync_serviceResults[callId] = serviceResults
    -- ToDo: consider if/ how we need to support this to work accross multiple turtles

    -- end
    return true
end

function MethodExecutor.DoASyncObjService(...)
    -- get & check input from description
    local checkSuccess, className, objData, serviceName, serviceData, callback = InputChecker.Check([[
        This function executes an async service method of an obj.

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
            results                     - (?) service method return value

        Parameters:
            className                   + (string) name of class with the service
            objData                     + (table) with obj data
            serviceName                 + (string) name of service function to execute
            serviceData                 + (table) with argument to supply to service function
            callback                    + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("MethodExecutor.DoASyncObjService: Invalid input") return nil end

    -- call method
    return MethodExecutor.CallObjMethod(className, objData, serviceName, { serviceData, callback })
end

function MethodExecutor.GetModuleMethod(...)
    -- get & check input from description
    local checkSuccess, moduleName, methodName = InputChecker.Check([[
        This method gets a method based on a methodName and a module with the name moduleName.

        Return value:
            results                     - (?) function return value(s)

        Parameters:
            moduleName                  + (string) name of module to get method from
            methodName                  + (string) name of method to execute
    ]], ...)
    if not checkSuccess then corelog.Error("MethodExecutor.GetModuleMethod(...): Invalid input") return nil end

    -- get module
    local module = moduleRegistry:getRegistered(moduleName)
    if not module then corelog.Warning("MethodExecutor.GetModuleMethod(...): Module "..moduleName.." not found") return nil end

    -- get method
    local method = module[methodName]
    if not method then corelog.Warning("MethodExecutor.GetModuleMethod(...): Method "..methodName.." not found in module "..moduleName) return nil end

    -- end
    return method
end

function MethodExecutor.CallModuleMethod(...)
    -- get & check input from description
    local checkSuccess, moduleName, methodName, methodArguments = InputChecker.Check([[
        This method executes a method of a module based on a methodName and the methodArguments.

        Return value:
            results                     - (?) function return value(s)

        Parameters:
            moduleName                  + (string) name of module to execute on
            methodName                  + (string) name of method to execute
            methodArguments             + (table) with arguments to supply to the method
    ]], ...)
    if not checkSuccess then corelog.Error("MethodExecutor.CallModuleMethod(...): Invalid input") return nil end

    -- get module
    local module = moduleRegistry:getRegistered(moduleName)
    if not module then corelog.Warning("MethodExecutor.CallModuleMethod(...): Module "..moduleName.." not found") return nil end

    -- call method
    local results = MethodExecutor.CallMethod(module, methodName, methodArguments)

    -- end
    return results
end

function MethodExecutor.CallObjMethod(...)
    -- get & check input from description
    local checkSuccess, className, objFieldsTable, methodName, methodArguments = InputChecker.Check([[
        This method executes a method of an Obj based on it's className + objFieldsTable and the methodName + the methodArguments.

        Return value:
            results                     - (?) function return value(s)

        Parameters:
            className                   + (string) name of class to execute on
            objFieldsTable              + (table) with obj data
            methodName                  + (string) name of method to execute
            methodArguments             + (table) with arguments to supply to the method
    ]], ...)
    if not checkSuccess then corelog.Error("MethodExecutor.CallObjMethod(...): Invalid input") return nil end

    -- get obj
    local obj = objectFactory:create(className, objFieldsTable)
    if not obj then corelog.Warning("MethodExecutor.CallObjMethod(...): Object "..className.." not created for objFields "..textutils.serialise(objFieldsTable, {compact = true}) ) return nil end

    -- call instance method
    local results = MethodExecutor.CallInstanceMethod(obj, methodName, methodArguments)

    -- end
    return results
end

function MethodExecutor.CallInstanceMethod(...)
    -- get & check input from description
    local checkSuccess, object, methodName, methodArguments = InputChecker.Check([[
        This method executes an instance method of an object based on a methodName and the methodArguments.

        Return value:
            results                     - (?) function return value(s)

        Parameters:
            object                      + (table) object to execute on
            methodName                  + (string) name of method to execute
            methodArguments             + (table) with arguments to supply to the method
    ]], ...)
    if not checkSuccess then corelog.Error("MethodExecutor.CallInstanceMethod(...): Invalid input") return nil end

    -- get method
    local method = object[methodName]
    if not method then corelog.Warning("MethodExecutor.CallInstanceMethod(...): Method "..methodName.." not found in object "..textutils.serialise(object, {compact = true})) return nil end

    -- call method
    local results = method(object, table.unpack(methodArguments))

    -- end
    return results
end

function MethodExecutor.CallMethod(...)
    -- get & check input from description
    local checkSuccess, object, methodName, methodArguments = InputChecker.Check([[
        This method executes a method of an object based on a methodName and the methodArguments.

        Return value:
            results                     - (?) function return value(s)

        Parameters:
            object                      + (table) object to execute on
            methodName                  + (string) name of method to execute
            methodArguments             + (table) with arguments to supply to the method
    ]], ...)
    if not checkSuccess then corelog.Error("MethodExecutor.CallMethod(...): Invalid input") return nil end

    -- get method
    local method = object[methodName]
    if not method then corelog.Warning("MethodExecutor.CallMethod(...): Method "..methodName.." not found in object ") return nil end

    -- call method
    local results = method(table.unpack(methodArguments))

    -- end
    return results
end

return MethodExecutor
