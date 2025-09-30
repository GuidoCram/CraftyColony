-- define interface
local IWorker = {
}

--[[
    This module specifies the interface IWorker.

    The IWorker interface defines methods for computational entities (i.e. computercraft computers and turtles) that can perform work (i.e. assignments). They are the
    objects on which the CCWP code is run. Objects of a class implementing the interface are referred to as Worker's.
--]]

local IInterface = require "i_interface"

--    _______          __        _
--   |_   _\ \        / /       | |
--     | |  \ \  /\  / /__  _ __| | _____ _ __
--     | |   \ \/  \/ / _ \| '__| |/ / _ \ '__|
--    _| |_   \  /\  / (_) | |  |   <  __/ |
--   |_____|   \/  \/ \___/|_|  |_|\_\___|_|

function IWorker:getWorkerId()
    --[[
        Get the Worker workerId.

        Return value:
                                - (number) the Worker workerId
    ]]

    IInterface.UnimplementedMethodError("IWorker", "getWorkerId")

    -- end
    return -1
end

function IWorker:activate()
    --[[
        Activate the Worker. This implies the Worker is available for work.

        Return value:
                                + (boolean) if the Worker is active
    ]]

    IInterface.UnimplementedMethodError("IWorker", "activate")

    -- end
    return false
end

function IWorker:deactivate()
    --[[
        Deactivate the Worker. This implies the Worker is not available for work.

        Return value:
                                + (boolean) if the Worker is inactive
    ]]

    IInterface.UnimplementedMethodError("IWorker", "deactivate")

    -- end
    return false
end

function IWorker:isActive()
    --[[
        Get if the Worker is active.

        Return value:
                                + (boolean) if the Worker is active
    ]]

    IInterface.UnimplementedMethodError("IWorker", "isActive")

    -- end
    return false
end

function IWorker:reset()
    --[[
        Reset the Worker. This implies the Worker is reset to construct conditions.

        Return value:
    ]]

    IInterface.UnimplementedMethodError("IWorker", "reset")
end

function IWorker:getWorkerLocation()
    --[[
        Get the (current) location of the Worker

        Return value:
            baseLocation        + (Location) current location of the Worker
    ]]

    IInterface.UnimplementedMethodError("IWorker", "getWorkerLocation")

    return nil
end

function IWorker:getWorkerResume()
    --[[
        Get Worker resume for selecting Assignment's.

        The resume gives information on the Worker and is used to determine if the Worker is (best) suitable to take an Assignment.
            This is can e.g. be used to indicate location, fuel level and equiped items.

        Return value:
            resume              - (table) Worker "resume" to consider in selecting Assignment's
    --]]

    IInterface.UnimplementedMethodError("IWorker", "getWorkerResume")

    -- end
    return {}
end

function IWorker:getMainUIMenu()
    --[[
        Get the main (start) UI menu of the Worker.

        This menu can be used in conjuction with coredisplay.MainMenu.

        Return value:
                                - (table)
                clear           - (boolean) whether or not to clear the display,
                func	        - (function) menu function to call
                param	        - (table, {}) parameter to pass to menu function
                intro           - (string) intro to print
                question        - (string, nil) final question to print
    ]]

    IInterface.UnimplementedMethodError("IWorker", "getMainUIMenu")

    -- end
    return {}
end

function IWorker:getAssignmentFilter()
    --[[
        Get assignment filter for finding the next best Assignment for the Worker.

        The assignment filter is used to indicate to only accept assignments that satisfy certain conditions. This can e.g. be used
            to only accept assignments with high priority.

        Return value:
            assignmentFilter    - (table) filter to apply in finding an Assignment
    --]]

    IInterface.UnimplementedMethodError("IWorker", "getAssignmentFilter")

    -- end
    return {}
end

return IWorker
