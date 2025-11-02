-- define module
-- Public API overview (empty stubs; real implementations are defined below)
local Timer = {
	-- Create a one-time event that fires after 'ticks' (1/20 seconds). Calls callback(data) when timer expires.
	-- returns timer id
	createTimeEvent = function(ticks, callback, data) end,

	-- Cancel a previously created time event by id.
	-- no return
	cancelTimeEvent = function(id) end,

	-- Start a recurring ticker that fires every 'interval' ticks (1/20 seconds).
	-- no return
	startTicker = function(interval) end,

	-- Stop the currently running ticker.
	-- no return
	stopTicker = function() end,
}

-- imports

local CoreEvent = require("craftycolony.core.coreevent")

--[[
      _                     _       _   _
     | |                   (_)     | | (_)
   __| | ___  ___  ___ _ __ _ _ __ | |_ _  ___  _ __
  / _` |/ _ \/ __|/ __| '__| | '_ \| __| |/ _ \| '_ \
 | (_| |  __/\__ \ (__| |  | | |_) | |_| | (_) | | | |
  \__,_|\___||___/\___|_|  |_| .__/ \__|_|\___/|_| |_|
                             | |
                             |_|


  This module implements a simple timer based events based on CoreEvents.
  -- time based events, have your callback called in x seconds
  -- ticker events, create every x seconds an event to keep stuff going

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

	-- have we registered for the timer event?
	eventRegistered	= false,				-- true if we have registered for the event

	-- for the ticker options
	tickerInterval	= 1,             		-- interval in ticks for the ticker event
	tickerActive	= false,            	-- is the ticker active?
	tickerID		= nil,           		-- id of the ticker event

	-- keep a list of the known timers
    timers			= {},		        	-- list of all known timers
}

--[[
  _                 _
 | |               | |
 | | ___   ___ __ _| |
 | |/ _ \ / __/ _` | |
 | | (_) | (_| (_| | |
 |_|\___/ \___\__,_|_|

--]]

-- local function to redirect a timer event to the supplied callback
local function processTimerEvent(id)

	-- is it a known timer?
	if db.timers[id] ~= nil then

		-- retrieve the timer information
		local timer = db.timers[id]

		-- clear the timer from our memory
		db.timers[id] = nil

		-- call the callback function
		pcall(timer.callback, timer.data)

	end
end

-- function to register for the core event timer event
local function registerCoreEventCallback()

	-- first check if we have registered already
	if not db.eventRegistered then

		-- do it!
		CoreEvent.addEventListener("timer", processTimerEvent)
		db.eventRegistered = true
	end
end

-- function to unregister for the core event timer event
local function unregisterCoreEventCallback()

	-- only if we have registered
	if db.eventRegistered then

		-- unregister
		CoreEvent.removeEventListener("timer", processTimerEvent)
		db.eventRegistered = false
	end
end

-- for the ticker event, just re-register the timer
local function doTimerEvent()

	-- if the ticker is still active, re-register
	if db.tickerActive then db.tickerID = Timer.createTimeEvent(db.tickerInterval, doTimerEvent) end
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

--[[
  _   _                ______               _
 | | (_)              |  ____|             | |
 | |_ _ _ __ ___   ___| |____   _____ _ __ | |_
 | __| | '_ ` _ \ / _ \  __\ \ / / _ \ '_ \| __|
 | |_| | | | | | |  __/ |___\ V /  __/ | | | |_
  \__|_|_| |_| |_|\___|______\_/ \___|_| |_|\__|

--]]

-- function to fire an event in a specific number of seconds
function Timer.createTimeEvent(ticks, callback, data)
	-- ticks is in 1/20 seconds, so 20 ticks is 1 second
	-- callback is the function to call when the timer expires
	-- data is optional data to pass to the function when called

	-- make sure are registered
	registerCoreEventCallback()

	-- store the id
	local id = os.startTimer(ticks/20)

	-- add this one to our memory
	db.timers[id] = {callback=callback, data=data, finished=os.clock() + ticks / 20}

	-- return the id of the timer, in case our caller wants to clear the timer
	return id
end

-- not sure if anyone will ever cancel a timer or just let it run out
function Timer.cancelTimeEvent(id)
	-- clear the timer in the os queue
	os.cancelTimer(id)

	-- clear the data from our memory
	db.timers[id] = nil
end

--[[
  _   _      _
 | | (_)    | |
 | |_ _  ___| | _____ _ __
 | __| |/ __| |/ / _ \ '__|
 | |_| | (__|   <  __/ |
  \__|_|\___|_|\_\___|_|

--]]

function Timer.startTicker(interval)
	-- start a ticker event, that will fire every interval ticks
	-- interval is in ticks, so 20 ticks is 1 second

	-- remember the interval (if it's a positive integer)
	if interval and type(interval) == "number" and interval % 1 == 0 and interval > 0 then db.tickerInterval = interval end

	-- if we have not registered yet, do it now
	registerCoreEventCallback()

	-- if the ticker is already active, changing the interval is enough
	if not db.tickerActive then

		-- start the event
		db.tickerActive	= true

		-- start the timer event
		doTimerEvent()
	end
end

function Timer.stopTicker()

	-- only if active
	if db.tickerID then Timer.cancelTimeEvent(db.tickerID) end

	-- update variables
	db.tickerActive = false
	db.tickerID     = nil

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
return Timer