-- define role
local role_settler = {}

-- ToDo: add proper module description
--[[
    This role ...
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"
local coremove = require "coremove"

local InputChecker = require "input_checker"

local enterprise_employment

--    _______        _                   __  __      _        _____        _
--   |__   __|      | |          ___    |  \/  |    | |      |  __ \      | |
--      | | __ _ ___| | _____   ( _ )   | \  / | ___| |_ __ _| |  | | __ _| |_ __ _
--      | |/ _` / __| |/ / __|  / _ \/\ | |\/| |/ _ \ __/ _` | |  | |/ _` | __/ _` |
--      | | (_| \__ \   <\__ \ | (_>  < | |  | |  __/ || (_| | |__| | (_| | || (_| |
--      |_|\__,_|___/_|\_\___/  \___/\/ |_|  |_|\___|\__\__,_|_____/ \__,_|\__\__,_|

function role_settler.InitialiseCoordinates_MetaData(...)
    -- get & check input from description
    local checkSuccess, turtleLocator = InputChecker.Check([[
        This function returns the MetaData for InitialiseCoordinates_Task.

        Return value:
                                        - (table) metadata

        Parameters:
            taskData                    - (table) data about the task
                startLocation           - (Location) locaton where the task should start
                workerLocator           + (ObjLocator) locating the Turtle
    ]], ...)
    if not checkSuccess then corelog.Error("role_settler.InitialiseCoordinates_MetaData: Invalid input") return {success = false} end

    -- get turtle we are doing task with
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local turtleObj = enterprise_employment:getObj(turtleLocator)
    if not turtleObj then corelog.Error("role_settler.InitialiseCoordinates_MetaData: Failed obtaining Turtle "..turtleLocator:getURI()) return {success = false} end
    local location = turtleObj:getWorkerLocation() --> use the current location for proper bootstrapping

    return {
        startTime = coreutils.UniversalTime(),
        location = location:copy(),
        needTool = false,
        needTurtle = true,
        fuelNeeded = 0,                         --> per definition the settler starts without fuel
        itemsNeeded = { }
    }
end

function role_settler.InitialiseCoordinates_Task(...)
    -- get & check input from description
    local checkSuccess, startLocation = InputChecker.Check([[
        This Task function does the first settling step: initialise starting world coordinates.

        Return value:
            task result                 - (table)
                success                 - (boolean) whether the task was succesfull

        Parameters:
            taskData                    - (table) data about the task
                startLocation           + (Location) locaton where first steps are to be taken
    ]], ...)
    if not checkSuccess then corelog.Error("role_settler.InitialiseCoordinates_Task: Invalid input") return {success = false} end

    -- coordinaten stelsel goed zetten
    coremove.SetLocation(startLocation)

    -- end
    return {success = true}
end

return role_settler
