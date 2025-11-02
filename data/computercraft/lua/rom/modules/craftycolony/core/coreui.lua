-- Core UI utilities for CraftyColony
--
-- module for the user interface components of CraftyColony
-- helps handling display and user interactions


local CoreUI = {
  -- Public API Overview:
  -- init() - Initialize the module
  -- setup() - Setup the module
  -- run() - Run the module
  -- shutdown() - Shutdown the module
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


    This modules handles the user interface of a computer, turtle or pocket. Not implemented yet.

--]]

--[[
      _       _
     | |     | |
   __| | __ _| |_ __ _
  / _` |/ _` | __/ _` |
 | (_| | (_| | || (_| |
  \__,_|\__,_|\__\__,_|

--]]

local db = {

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

function CoreUI.init()
	-- nothing to initialize at the moment
end

function CoreUI.setup()
	-- nothing to setup at the moment
end

function CoreUI.run()

    -- run until we are shutting down
    while not db.shuttingDown do

		-- currently nothing to do, just sleep a bit
		os.sleep(0.1)
    end
end

function CoreUI.shutdown()
    -- set the flag to stop running
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
return CoreUI