-- define module
local coreact = {}

-- imports
--local coreact       = require "core.act"
--local corecom       = require "core.com"
--local coredisk      = require "core.disk"
--local coreevent     = require "core.event"
--local coreui        = require "core.ui"

--[[
      _                     _       _   _
     | |                   (_)     | | (_)
   __| | ___  ___  ___ _ __ _ _ __ | |_ _  ___  _ __
  / _` |/ _ \/ __|/ __| '__| | '_ \| __| |/ _ \| '_ \
 | (_| |  __/\__ \ (__| |  | | |_) | |_| | (_) | | | |
  \__,_|\___||___/\___|_|  |_| .__/ \__|_|\___/|_| |_|
                             | |
                             |_|


    This modules handles all actions of the turtle, like moving, digging, placing blocks, etc.
	It provides a queue system to queue actions and execute them one by one.
	There are three quest, based on priority:
		- high priority: for actions that need to be executed immediately, like refueling, etc.
		- normal priority: for actions that are part of the main task.
		- low priority: for actions that can be executed later, cleaning up, etc.

	The module runs in parallel to the other core modules and executes the queued actions one by one.
	It also provides functions to add actions to the queue and to check the status of the turtle.

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
	-- three queues for actions
	highQueue		= {},				-- high priority queue
	normalQueue		= {},				-- normal priority queue
	lowQueue		= {},				-- low priority queue
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

function coreact.AddActivity(func, data, priority)
	-- add the function to the appropriate queue based on priority
		if priority == "high"	then table.insert(db.highQueue, 	{ func=func, data=data })
	elseif priority == "low"	then table.insert(db.lowQueue, 		{ func=func, data=data })
								else table.insert(db.normalQueue,	{ func=func, data=data })
	end
end

function coreact.Init()
end

function coreact.Setup()
end

function coreact.Run()
end

function coreact.Shutdown()
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
return coreact