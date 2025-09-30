-- define role
local role_interactor = {}

--[[
    This role deals with the interaction between various Worker's.
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"
local coremove = require "coremove"

local InputChecker = require "input_checker"
local Location = require "obj_location"

local enterprise_employment

--    _______        _                   __  __      _        _____        _
--   |__   __|      | |          ___    |  \/  |    | |      |  __ \      | |
--      | | __ _ ___| | _____   ( _ )   | \  / | ___| |_ __ _| |  | | __ _| |_ __ _
--      | |/ _` / __| |/ / __|  / _ \/\ | |\/| |/ _ \ __/ _` | |  | |/ _` | __/ _` |
--      | | (_| \__ \   <\__ \ | (_>  < | |  | |  __/ || (_| | |__| | (_| | || (_| |
--      |_|\__,_|___/_|\_\___/  \___/\/ |_|  |_|\___|\__\__,_|_____/ \__,_|\__\__,_|

function role_interactor.TurnOnWorker_MetaData(...)
    -- get & check input from description
    local checkSuccess, turtleId, workerLocation, accessDirection, priorityKey = InputChecker.Check([[
        This function returns the MetaData for TurnOnWorker_Task.

        Return value:
                                            - (table) metadata

        Parameters:
            taskData                        - (table) data about the crafting task
                turtleId                    + (number) id of the Turtle that has the items
                workerLocation              + (Location) location of the Worker to turn on
                accessDirection             + (string) whether to access Worker from "bottom", "top", "left", "right", "front" or "back" (relative to location)
                priorityKey                 + (string, "") priorityKey for this assignment
    ]], ...)
    if not checkSuccess then corelog.Error("role_interactor.TurnOnWorker_MetaData: Invalid input") return {} end

    -- determine metadata
    local workingLocation = workerLocation:getWorkingLocation(accessDirection)
    if not workingLocation then corelog.Error("role_interactor.TurnOnWorker_MetaData: Failed to determine workingLocation") return {} end
    local fuelNeeded = 0 -- task starts at workingLocation, 0 movement from there

    -- check if specific turtle is needed
    local needWorkerId = nil
    if (turtleId >= 0) then
        needWorkerId = turtleId
    end

    -- return metadata
    return {
        startTime   = coreutils.UniversalTime(),
        location    = workingLocation:copy(),
        needTool    = false,
        needTurtle  = true,
        needWorkerId= needWorkerId,
        fuelNeeded  = fuelNeeded,
        itemsNeeded = {},

        priorityKey = priorityKey,
    }
end

function role_interactor.TurnOnWorker_Task(...)
    -- get & check input from description
    local checkSuccess, workerLocation, accessDirection, turtleLocator = InputChecker.Check([[
        This Task function turns on a Worker.

        Return value:
            task result                     - (table)
                success                     - (boolean) whether the task was succesfull
                workerLocator               - (ObjLocator) locating the Worker that was turned on

        Parameters:
            serviceData                     - (table) data about this service
                workerLocation              + (Location) location of the Worker to turn on
                accessDirection             + (string) whether to access Worker from "bottom", "top", "left", "right", "front" or "back" (relative to location)
                workerLocator               + (ObjLocator) locating the Turtle that is doing the task
    ]], ...)
    if not checkSuccess then corelog.Error("role_interactor.TurnOnWorker_Task: Invalid input") return {success = false} end

    corelog.WriteToLog("   starting TurnOnWorker_Task...")

    -- move adjacent to Worker
    local workingLocation = workerLocation:getWorkingLocation(accessDirection)
    if type(workingLocation) ~= "table" then corelog.Error("role_interactor.TurnOnWorker_Task: Failed to determine workingLocation") return {success = false} end
--    corelog.WriteToLog("  moving to workingLocation="..textutils.serialize(workingLocation))
    coremove.GoTo(workingLocation)

    -- get Turtle we are doing task with
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local turtleObj = enterprise_employment:getObj(turtleLocator)
    if not turtleObj then corelog.Error("role_interactor.TurnOnWorker_Task: Failed obtaining Turtle "..turtleLocator:getURI().." to turn a Worker on") return {success = false} end

    -- turn Worker on
    local peripheralName = Location.ConvertAccessDirectionToPeripheralName(accessDirection)
    local worker = peripheral.wrap(peripheralName)
    if worker and worker.turnOn then
        worker.turnOn()
    else
        corelog.Error("role_interactor.TurnOnWorker_Task: Could not find a Worker at "..textutils.serialise(workerLocation, {compact = true}).." (from "..textutils.serialise(workingLocation, {compact = true})..")") return {success = false}
    end

    -- wait until worker isOn and has a label
    local waitCount = 0
    while (not worker.isOn() or not worker.getLabel()) and waitCount < 10 do
        -- wait a bit for worker to turn on
        os.sleep(0.25)
    end

    -- get workerId
    local workerId = worker.getID()
    -- corelog.WriteToLog("workerId:")
    -- corelog.WriteToLog(workerId)

    -- find corresponding mobjLocator
    local workerLocator = enterprise_employment:getRegistered(workerId)
    if not workerLocator then corelog.Warning("role_interactor.TurnOnWorker_Task: Could not find workerLocator for worker "..workerId) return {success = false} end
    -- corelog.WriteToLog("workerLocator:")
    -- corelog.WriteToLog(workerLocator)

    corelog.WriteToLog("  completed TurnOnWorker_Task...")

    -- end
    local result = {
        success         = true,
        workerLocator   = workerLocator,
    }
    return result
end

return role_interactor
