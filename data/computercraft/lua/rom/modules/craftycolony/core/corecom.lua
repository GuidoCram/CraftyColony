-- define module
-- Public API overview (empty stubs; real implementations are defined below)
local CoreCom = {
	-- Initialize the communication system.
	-- no return
	init = function() end,

	-- Setup the communication system.
	-- no return
	setup = function() end,

	-- Main communication loop - handles messages and communication.
	-- no return
	run = function() end,

	-- Signal the communication system to shut down.
	-- no return
	shutdown = function() end,
}

-- imports

--[[
      _                     _       _   _
     | |                   (_)     | | (_)
   __| | ___  ___  ___ _ __ _ _ __ | |_ _  ___  _ __
  / _` |/ _ \/ __|/ __| '__| | '_ \| __| |/ _ \| '_ \
 | (_| |  __/\__ \ (__| |  | | |_) | |_| | (_) | | | |
  \__,_|\___||___/\___|_|  |_| .__/ \__|_|\___/|_| |_|
                             | |
                             |_|


    This modules handles all communications, not used yet but reserved for http and websockets.

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
    -- local status of shutting down
	shuttingDown	= false,
}

--[[
  _                 _
 | |               | |
 | | ___   ___ __ _| |
 | |/ _ \ / __/ _` | |
 | | (_) | (_| (_| | |
 |_|\___/ \___\__,_|_|

--]]


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

function CoreCom.init()
	-- nothing to initialize at the moment
end

function CoreCom.setup()
	-- nothing to setup at the moment
end

function CoreCom.run()

	-- run until we are shutting down
	while not db.shuttingDown do

        -- if no activity, sleep for a short time to prevent busy waiting
        os.sleep(0.1)
	end
end

function CoreCom.shutdown()
	-- just change the status, nothing more at this point. We need to wait for the work to finish
	db.shuttingDown = true
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
return CoreCom