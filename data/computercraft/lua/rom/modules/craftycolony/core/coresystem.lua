-- define module
local CoreSystem = {}

-- imports
local CoreAction    = require "core.coreaction"
local CoreCom       = require "core.corecom"
local CoreDisk      = require "core.coredisk"
local CoreEvent     = require "core.coreevent"
local CoreUI        = require "core.coreui"

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
local function init()

    -- only if the system is just booted
    if db.status ~= "booted" then return end

   	-- run all init functions
    CoreAction.init()
    CoreCom.init()
    CoreDisk.init()
    CoreEvent.init()
    CoreUI.init()

	-- set the new status
	db.status = "initialized"
end

-- setup all core modules
local function setup()
	-- only if the system is just booted
    if db.status == "booted"		then Init() end
	if db.status ~= "initialized"	then return end

	-- run all setup functions
    CoreAction.setup()
    CoreCom.setup()
    CoreDisk.setup()
    CoreEvent.setup()
    CoreUI.setup()

	-- set new status
	db.status = "ready"
end

-- runs the callback function of the one who is using this system
-- when the callback is done, the system will shut down
local function runCallback()

    -- run the callback
    db.callback()

    -- since the callback is done, we are done and we shall shut down the system!
    CoreSystem.shutdown()
end

-- initiates the shutdown of the system
local function shutdown()

    -- only if we are running
    if db.status ~= "running" then return end

    -- set the new status
    db.status = "shutting down"

    -- run all shutdown functions
    CoreAction.shutdown()
    CoreCom.shutdown()
    CoreDisk.shutdown()
    CoreEvent.shutdown()
    CoreUI.shutdown()
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
function CoreSystem.Run(callback)

    -- check if the callback is a function
    if callback and type(callback) ~= "function" then error("CoreSystem.Run: callback is not a function") end

    -- save the callback
    db.callback = callback

    -- check the system status
    if db.status == "booted"		then init() end
    if db.status == "initialized"	then setup() end

    -- check for the right system status (would be weird if it was not ready here)
    if db.status == "ready" then

        -- we are now officially running!!
		db.status = "running"

    	-- run some functions in parallel
    	parallel.waitForAll(
			CoreAction.run,
			CoreCom.run,
			CoreDisk.run,
			CoreEvent.run,
			CoreUI.run,
            runCallback
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
return CoreSystem