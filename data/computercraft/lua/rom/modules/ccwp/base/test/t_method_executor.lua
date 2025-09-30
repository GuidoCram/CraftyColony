local T_MethodExecutor = {}

local corelog = require "corelog"

local Callback = require "obj_callback"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

local MethodExecutor = require "method_executor"

function T_MethodExecutor.T_All()
    T_MethodExecutor.T_CallMethod()
    T_MethodExecutor.T_CallModuleMethod()
    T_MethodExecutor.T_CallInstanceMethod()
    T_MethodExecutor.T_CallObjMethod()

    T_MethodExecutor.T_DoSyncService()
    T_MethodExecutor.T_DoSyncObjService()
    T_MethodExecutor.T_DoASyncService()
    T_MethodExecutor.T_DoASyncObjService()
end

local testMethod = function(num)
    return num + 1
end

function T_MethodExecutor.T_CallMethod()
    -- prepare test
    corelog.WriteToLog("* MethodExecutor.CallMethod() test")
    local myObject = {
        increment = testMethod
    }

    -- test
    local result = MethodExecutor.CallMethod(myObject, "increment", {5})
    assert(result == 6, "Unexpected result from increment method: " .. tostring(result))

    -- cleanup test
end

function T_MethodExecutor.T_CallModuleMethod()
    -- prepare test
    corelog.WriteToLog("* MethodExecutor.CallModuleMethod() test")
    local myModule = {
        increment = testMethod
    }
    moduleRegistry:register("myModule", myModule)

    -- test
    local result = MethodExecutor.CallModuleMethod("myModule", "increment", {5})
    assert(result == 6, "Unexpected result from increment method: " .. tostring(result))

    -- cleanup test
    moduleRegistry:delist("myModule")
end

function T_MethodExecutor.T_CallInstanceMethod()
    -- prepare test
    corelog.WriteToLog("* MethodExecutor.CallInstanceMethod() test")
    local field2Value = 3
    local ObjTest = require "test.obj_test"
    local object = ObjTest:newInstance("field1_1", field2Value)
    local methodName = "field2Plus"
    local addValue = 5
    local methodArguments = {
        addValue,
    }

    -- test
    local result = MethodExecutor.CallInstanceMethod(object, methodName, methodArguments)
    local expectedResult = field2Value + addValue
    assert(result == expectedResult, "Unexpected result(="..result..") from method, expected "..expectedResult)

    -- cleanup test
    moduleRegistry:delist("myModule")
end

function T_MethodExecutor.T_CallObjMethod()
    -- prepare test
    corelog.WriteToLog("* MethodExecutor.CallObjMethod() test")
    local className = "ObjTest"
    local field2Value = 3
    local objFieldsTable = {
        _field1 = "field1_1",
        _field2 = field2Value,
    }
    local methodName = "field2Plus"
    local addValue = 5
    local methodArguments = {
        addValue,
    }

    -- test
    local result = MethodExecutor.CallObjMethod(className, objFieldsTable, methodName, methodArguments)
    local expectedResult = field2Value + addValue
    assert(result == expectedResult, "Unexpected result(="..result..") from method, expected "..expectedResult)

    -- cleanup test
    moduleRegistry:delist("myModule")
end

local testValue = 20

function T_MethodExecutor.T_DoSyncService()
    -- prepare test
    corelog.WriteToLog("* MethodExecutor.DoSyncService() test")
    local moduleName = "enterprise_test"
    local serviceName = "Test_SSrv"
    assert(moduleRegistry:isRegistered(moduleName), "Module "..moduleName.." is not registered in the registry.")
    local serviceData = {
        testArg = testValue,
    }

    -- test
    local results = MethodExecutor.DoSyncService(moduleName, serviceName, serviceData)
    assert(type(results) == "table" , "no result table returned")
    assert(results.input == testValue, "Unexpected result from service: " .. tostring(results.input))

    -- cleanup test
end

function T_MethodExecutor.T_DoSyncObjService()
    -- prepare test
    corelog.WriteToLog("* MethodExecutor.DoSyncObjService() test")
    local className = "ObjTest"
    local serviceName = "test_SOSrv"
    assert(objectFactory:isRegistered(className), "Class "..className.." is not registered in the factory.")
    local objData = {
        _field1 = "field1_1",
        _field2 = 1,
    }
    local serviceData = {
        testArg = testValue,
    }

    -- test
    local results = MethodExecutor.DoSyncObjService(className, objData, serviceName, serviceData)
    assert(type(results) == "table" , "no result table returned")
    assert(results.input == testValue, "Unexpected result from service: " .. tostring(results.input))

    -- cleanup test
end

function T_MethodExecutor.T_DoASyncObjService_Sync()
    -- prepare test
    corelog.WriteToLog("* MethodExecutor.DoASyncObjService_Sync() test")
    local className = "ObjTest"
    local serviceName = "test_AOSrv"
    assert(objectFactory:isRegistered(className), "Class "..className.." is not registered in the factory.")
    local serviceData = {
        testArg = testValue,
    }
    local ObjTest = require "test.obj_test"
    local obj = ObjTest:newInstance("field1_1", 1)

    -- test
    local serviceResults = MethodExecutor.DoASyncObjService_Sync(obj, serviceName, serviceData)
    assert(type(serviceResults) == "table" , "no result table returned")
    assert(serviceResults.success, "failed executing async obj service")
    assert(serviceResults.input == testValue, "Unexpected result from service: " .. tostring(serviceResults.input))

    -- cleanup test
end

local callbackTestValue = "some callback data"

function T_MethodExecutor.T_DoASyncService()
    -- prepare test
    corelog.WriteToLog("* MethodExecutor.DoASyncService() test")
    local moduleName = "enterprise_test"
    local serviceName = "Test_ASrv"
    assert(moduleRegistry:isRegistered(moduleName), "Module "..moduleName.." is not registered in the registry.")
    local serviceData = {
        testArg = testValue,
    }
    local callback = Callback:newInstance("T_MethodExecutor", "DoASyncService_Callback", { [0] = callbackTestValue })

    -- test
    local result = MethodExecutor.DoASyncService(moduleName, serviceName, serviceData, callback)
    assert(result == true, "failed scheduling ASync Service")
end

function T_MethodExecutor.DoASyncService_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")
    local arg1 = serviceResults.input
    local expectedArg1 = testValue
    assert(arg1 == expectedArg1, "gotten arg1(="..arg1..") not the same as expected(="..expectedArg1..")")
    local callbackValue = callbackData[0]
    local expectedCallbackValue = callbackTestValue
    assert(callbackValue == expectedCallbackValue, "gotten callbackValue(="..(callbackValue or "nil")..") not the same as expected(="..expectedCallbackValue..")")

    -- cleanup test
end

function T_MethodExecutor.T_DoASyncObjService()
    -- prepare test
    corelog.WriteToLog("* MethodExecutor.DoASyncObjService() test")
    local className = "ObjTest"
    local serviceName = "test_AOSrv"
    assert(objectFactory:isRegistered(className), "Class "..className.." is not registered in the factory.")
    local objData = {
        _field1 = "field1_1",
        _field2 = 1,
    }
    local serviceData = {
        testArg = testValue,
    }
    local callback = Callback:newInstance("T_MethodExecutor", "DoASyncObjService_Callback", { [0] = callbackTestValue })

    -- test
    local result = MethodExecutor.DoASyncObjService(className, objData, serviceName, serviceData, callback)
    assert(result == true, "failed scheduling ASync Obj Service")
end

function T_MethodExecutor.DoASyncObjService_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async obj service")
    local arg1 = serviceResults.input
    local expectedArg1 = testValue
    assert(arg1 == expectedArg1, "gotten arg1(="..arg1..") not the same as expected(="..expectedArg1..")")
    local callbackValue = callbackData[0]
    local expectedCallbackValue = callbackTestValue
    assert(callbackValue == expectedCallbackValue, "gotten callbackValue(="..(callbackValue or "nil")..") not the same as expected(="..expectedCallbackValue..")")

    -- cleanup test
end

return T_MethodExecutor
