-- define module
local coresystem = {}

-- ToDo: add proper module description
--[[
    This module ...
--]]

local db	    = {
    systemStatus    = "booted",							-- booted, initialized, ready, running, shutting down
}

function coresystem.getStatus()
	return db.systemStatus
end

function coresystem.setStatus(status)
	db.systemStatus = status
end

function coresystem.IsRunning()
    -- just check the currentstatus
    return db.systemStatus == "running"
end

-- user command
function coresystem.DoQuit()
    -- just set the new status
    db.systemStatus = "shutting down"

    -- nice!
    print("")

    -- this went well
    return true
end

return coresystem
