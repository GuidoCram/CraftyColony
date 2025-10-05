-- define module
local coresys = {}

-- imports
local coreact       = require "core.act"
local corecom       = require "core.com"
local coredisk      = require "core.disk"
local coreevent     = require "core.event"
local coreui        = require "core.ui"

--[[
      _                     _       _   _
     | |                   (_)     | | (_)
   __| | ___  ___  ___ _ __ _ _ __ | |_ _  ___  _ __
  / _` |/ _ \/ __|/ __| '__| | '_ \| __| |/ _ \| '_ \
 | (_| |  __/\__ \ (__| |  | | |_) | |_| | (_) | | | |
  \__,_|\___||___/\___|_|  |_| .__/ \__|_|\___/|_| |_|
                             | |
                             |_|


    This module is the basis of the CraftyColony system. It runs the parallel processes of the other core components and runs the callback function when everything is set up.
    Once the callback function is done, the system will shut down all components and exit.

--]]

--[[
      _       _
     | |     | |
   __| | __ _| |_ __ _
  / _` |/ _` | __/ _` |
 | (_| | (_| | || (_| |
  \__,_|\__,_|\__\__,_|

--]]

local db	    = {
    -- status of the system: booted, initialized, ready, running, shutting down
    status          = "booted",

    -- for transferring the callback function after the parallel call which does not allow parameters
    callback        = nil,
}

--[[
  _                 _
 | |               | |
 | | ___   ___ __ _| |
 | |/ _ \ / __/ _` | |
 | | (_) | (_| (_| | |
 |_|\___/ \___\__,_|_|

--]]

-- initialize all core modules
local function Init()

    -- only if the system is just booted
    if db.status ~= "booted" then return end

   	-- run all init functions
    coreact.Init()
    corecom.Init()
    coredisk.Init()
    coreevent.Init()
    coreui.Init()

	-- set the new status
	db.status = "initialized"
end

-- setup all core modules
local function Setup()
	-- only if the system is just booted
    if db.status == "booted"		then Init() end
	if db.status ~= "initialized"	then return end

	-- run all setup functions
    coreact.Setup()
    corecom.Setup()
    coredisk.Setup()
    coreevent.Setup()
    coreui.Setup()

	-- set new status
	db.status = "ready"
end

-- runs the callback function of the one who is using this system
-- when the callback is done, the system will shut down
local function RunCallback()

    -- run the callback
    db.callback()

    -- since the callback is done, we are done and we shall shut down the system!
    coresys.Shutdown()
end

-- initiates the shutdown of the system
local function Shutdown()

    -- only if we are running
    if db.status ~= "running" then return end

    -- set the new status
    db.status = "shutting down"

    -- run all shutdown functions
    coreact.Shutdown()
    corecom.Shutdown()
    coredisk.Shutdown()
    coreevent.Shutdown()
    coreui.Shutdown()
end

--[[
              _     _ _
             | |   | (_)
  _ __  _   _| |__ | |_  ___
 | '_ \| | | | '_ \| | |/ __|
 | |_) | |_| | |_) | | | (__
 | .__/ \__,_|_.__/|_|_|\___|
 | |
 |_|
--]]

-- actually run the stuff
function coresys.Run(callback)

    -- check if the callback is a function
    if callback and type(callback) ~= "function" then error("coresys.Run: callback is not a function") end

    -- save the callback
    db.callback = callback

    -- check the system status
    if db.status == "booted"		then Init() end
    if db.status == "initialized"	then Setup() end

    -- check for the right system status (would be weird if it was not ready here)
    if db.status == "ready" then

        -- we are now officially running!!
		db.status = "running"

    	-- run some functions in parallel
    	parallel.waitForAll(
			coreact.Run,
			corecom.Run,
			coredisk.Run,
			coreevent.Run,
			coreui.Run,
            RunCallback
		)

        -- no longer running, we're done (unless the system is shutting down)
		if db.status == "running" then db.status = "ready" end
    end
end

--[[
           _
          | |
  _ __ ___| |_ _   _ _ __ _ __
 | '__/ _ \ __| | | | '__| '_ \
 | | |  __/ |_| |_| | |  | | | |
 |_|  \___|\__|\__,_|_|  |_| |_|


--]]

-- done
return coresys