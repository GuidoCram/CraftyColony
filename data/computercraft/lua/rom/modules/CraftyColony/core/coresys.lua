-- define module
local coresys = {}

--[[
    This module is the basis of the CraftyColony system. It runs the parallel processes of the other core components.
--]]

local db	    = {
    status          = "booted",				-- booted, initialized, ready, running, shutting down
}

-- initialize all core modules
function coresys.Init()

    -- only if the system is just booted
    if db.status ~= "booted" then return end

   	-- run all init functions


	-- set the new status
	db.status = "initialized"
end

function coresys.Setup()
	-- only if the system is just booted
    if db.status == "booted"		then coresys.Init() end
	if db.status ~= "initialized"	then return end

	-- run all setup functions


	-- set new status
	db.status = "ready"
end

-- actually run the stuff
function coresys.Run()

    -- check the system status
    if db.status == "booted"		then coresys.Init()	end
    if db.status == "initialized"	then coresys.Setup()	end

    -- check for the right system status
    if db.status == "ready" then

        -- we are now officially running!!
		db.status = "running"

    	-- run some functions in parallel
--[[    	parallel.waitForAll(
			coreevent.Run,		-- process all event
			coretask.Run,		-- process small task, enabling async write to file
			coretest.Run,		-- for running test, won't interfere with rest of the systeem
			coreassignment.Run,	-- runs assignments / the assignment board
			coredisplay.Run		-- processes user interaction with the display
		)
]]--

        -- no longer running, we're done
		if db.status == "running" then db.status = "ready" end
    end
end

--                  _     _ _
--                 | |   | (_)
--      _ __  _   _| |__ | |_  ___
--     | '_ \| | | | '_ \| | |/ __|
--     | |_) | |_| | |_) | | | (__
--     | .__/ \__,_|_.__/|_|_|\___|
--     | |
--     |_|                         

function coresys.Shutdown()

    -- only if we are running
    if db.status ~= "running" then return end

    -- set the new status
    db.status = "shutting down"

    -- run all shutdown functions


-- done
return coresys