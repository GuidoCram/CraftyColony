-- define class
local Class = require "class"
local LObjHost = require "lobj_host"
local enterprise_test = Class.NewClass(LObjHost)

--[[
    The test enterprise offers test services for debugging/ testing purposes.
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"

local Location = require "obj_location"

local enterprise_assignmentboard = require "enterprise_assignmentboard"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

-- note: currently enterprise is treated like a singleton, but by directly using the name of the module
-- ToDo: consider making changes to enterprise to
--          - explicitly make it a singleton (by construction with :newInstance(hostName) and using the singleton pattern)
--          - properly initialise it (by adding and implementing the _init method)
--          - adopt other classes to these changes
enterprise_test._hostName   = "enterprise_test"

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function enterprise_test:getClassName()
    return "enterprise_test"
end

function enterprise_test.Test_SSrv(...)
    -- get & check input from description
    local checkSuccess, serviceData, testArg = InputChecker.Check([[
        This public sync service returns a test argument.

        Return value:
            success             - (boolean) whether the service executed successfully
            input               - (?) the test input argument

        Parameters:
            serviceData         + (table) data about the service
                testArg         + (?) as a test argument
    --]], ...)
    if not checkSuccess then corelog.Error("enterprise_test.Test_SSrv: Invalid input") return {success = false} end

--    corelog.WriteToLog(">calling enterprise_test.Test_SSrv("..textutils.serialize(serviceData)..")")

    -- determine result to return
    local serviceResult = {
        success = true,
        input = testArg,
    }
    if type(serviceData.serviceResult) == "table" then
        serviceResult.success = serviceData.serviceResult.success
    end

    return serviceResult
end

function enterprise_test.Test_ASrv(...)
    -- get & check input from description
    local checkSuccess, testArg, callback = InputChecker.Check([[
        This public async service executes an assignment with a Callback.

        Return value:
                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                - (table)
                success         - (boolean) whether the service executed successfully
                input           - (?) the test input argument

        Parameters:
            serviceData         - (table) data about the service
                testArg         + (number) as a test argument
            callback            + (Callback) to call once service is ready
    --]], ...)
    if not checkSuccess then corelog.Error("enterprise_test.Test_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- create assignment arguments
    local taskData = {
        arg1 = testArg
    }
    local metaData = {
        startTime = coreutils.UniversalTime(),
        location = Location:newInstance(0, 0, 1, 0, 1),
        needTool = false,
        needTurtle = false,
        fuelNeeded = 0
    }

    -- do assignment
    local taskCall = TaskCall:newInstance("role_test", "Func1_Task", taskData)
    local assignmentServiceData = {
        metaData    = metaData,
        taskCall    = taskCall,
    }
    corelog.WriteToLog(">starting task "..textutils.serialize(taskCall, { compact = true }))
    return enterprise_assignmentboard.DoAssignment_ASrv(assignmentServiceData, callback)
end

return enterprise_test
