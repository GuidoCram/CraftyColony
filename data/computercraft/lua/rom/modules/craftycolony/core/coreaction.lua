-- define module
local CoreAction = {}

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

	-- local status of shutting down
	acceptingWork	= true,
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

local function getNextActivity()

	-- check the queues in order of priority
	    if #db.highQueue   > 0 then return table.remove(db.highQueue, 1)
	elseif #db.normalQueue > 0 then return table.remove(db.normalQueue, 1)
	elseif #db.lowQueue    > 0 then return table.remove(db.lowQueue, 1)
	end

	-- still here, no activity
	return nil
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

-- function to add an activity to the queue
function CoreAction.addActivity(func, data, priority, callback, description)
	-- func			the function to call
	-- data			the data to pass to the function
	-- priority		the priority of the activity: 'high', 'normal', 'low' (default: 'normal')
	-- callback		to be executed when the activity is done (optional)
	-- description	the description of the activity (for debugging purposes)

	-- add the function to the appropriate queue based on priority
		if not db.acceptingWork then return
	elseif priority == "high"	then table.insert(db.highQueue, 	{ func = func, data = data, callback = callback, description = description })
	elseif priority == "low"	then table.insert(db.lowQueue, 		{ func = func, data = data, callback = callback, description = description })
								else table.insert(db.normalQueue,	{ func = func, data = data, callback = callback, description = description })
	end
end

function CoreAction.init()
	-- nothing to initialize at the moment
end

function CoreAction.setup()
	-- nothing to setup at the moment
end

-- main run function, runs in parallel to the other core modules
function CoreAction.run()

	-- run until we are shutting down
	while not db.shuttingDown do

		-- get the next activity from the queues
		local activity = getNextActivity()

		-- if there is an activity, run it
		if activity then

			-- call it! (pcall is protective call to catch errors)
			local status, err = pcall(activity.func, activity.data)

			-- check the result
			if not status then print("Error in CoreAction.run when processing '"..(activity.description or "unknown").."': "..err) end

			-- seems we're done, call the callback if present
			if type(activity.callback) == "function" then
				-- call it protected as well
				local cbStatus, cbErr = pcall(activity.callback)

				-- check the result
				if not cbStatus then print("Error in CoreAction.run callback when processing '"..(activity.description or "unknown").."': "..cbErr) end
			end

		else
			-- if no activity, sleep for a short time to prevent busy waiting
			if db.acceptingWork == false then

				-- we are shutting down, all work is done
				db.shuttingDown = true
			else

				-- just normal idle operation
				os.sleep(0.1)
			end
		end
	end
end

-- initializes shutting down, stops accepting new work
function CoreAction.shutdown()
	-- just change the status of accepting work so the queue will be cleared before actually shutting down
	db.acceptingWork = false
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
return CoreAction