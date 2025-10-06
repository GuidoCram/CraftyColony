-- Core event handling for CraftyColony
-- module for managing events and interactions within CraftyColony
-- helps with event registration, handling, and dispatching
-- stuff not used yet

local CoreEvent = {}

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


    This modules handles events and allows other modules to register event listeners.

--]]

--[[
      _       _
     | |     | |
   __| | __ _| |_ __ _
  / _` |/ _` | __/ _` |
 | (_| | (_| | || (_| |
  \__,_|\__,_|\__\__,_|

--]]

-- allemaal event spullen
local db = {

    -- keep a list of the known timers
    timers			= {},		        -- list of all known timers

	-- keep track of known listeners
	listeners		= {},		        -- list of all known listeners

	-- keep going?
	shuttingDown	= false,            -- are we shutting down?

    -- for development
    debug			= false,
    logfile			= "/log/CoreEvent.log",
}

--[[
  _                 _
 | |               | |
 | | ___   ___ __ _| |
 | |/ _ \ / __/ _` | |
 | | (_) | (_| (_| | |
 |_|\___/ \___\__,_|_|

--]]

local doTimerEvent()
	-- todo: consider working with handlers

	-- set new timer for the next tick
	CoreEvent.CreateTimeEvent(1, doTimerEvent)
end

-- local function to process a timer event
local function processTimerEvent(id)

	-- is it a known timer?
	if db.timers[id] ~= nil then

		-- retrieve the timer information
		local timer = db.timers[id]
		db.timers[id] = nil

		-- call the callback function
		pcall(timer.callback, timer.data)

		-- timer handled, return nothing more
		return nil
	else
		-- we don't know this timer, continue with the event as it was
		return 'timer', id
	end
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

-- init of core event
function CoreEvent.init()
end

-- event setup
function CoreEvent.setup()

    -- this will create a loop of one event every tick at least, I don't think this is usefull for event, maybe for messaging
    CoreEvent.createTimeEvent(2, doTimerEvent)
end

-- function to fire an event in a specific number of seconds
function CoreEvent.createTimeEvent(ticks, callback, data)
	-- ticks is in 1/20 seconds, so 20 ticks is 1 second
	-- callback is the function to call when the timer expires
	-- data is optional data to pass to the function when called

	-- store the id
	local id = os.startTimer(ticks/20)

	-- add this one to our memory
	db.timers[id] = {callback=callback, data=data, finished=os.clock() + ticks / 20}

	-- return the id of the timer, in case our caller wants to clear the timer
	return id
end

-- not sure if anyone will ever cancel a timer or just let it run out
function CoreEvent.cancelTimeEvent(id)
	-- clear the timer in the os queue
	os.cancelTimer(id)

	-- clear the data from our memory
	db.timers[id] = nil
end

-- to add a custom functions to the event listener
function CoreEvent.addEventListener(func, protocol, subject)

    -- not sure if we allow an event listeren without a subject...
	if subject then
	    -- add this function to the listeners (create table if needed)
	    if type(listener[protocol]) ~= "table" then listener[protocol] = {} end
	    listener[protocol][subject] = func
	else
	    -- ok, but only if there is no table present!
		if type(listener[protocol]) ~= "table" then listener[protocol] = func end
	end
end

-- to remove the custom functions to the event listener. Without subject all functions for this protocol are cleared.
function CoreEvent.removeEventListener(protocol, subject)

    -- check if we need to remove all from this protocol
	if subject  then listener[protocol][subject]    = nil
			    else listener[protocol]             = nil
	end
end

-- listener to every event incoming
function CoreEvent.run()

    -- events we ignore in the global event listener these events in case we have logging on
	local ignore    = {

		-- list of all events, see https://tweaked.cc/event/alarm.html (other events in the menu on the left) for details
		-- some events will be handled. Most will not. Mark the event below false if you want a log message when that type of event is not handled
		["alarm"]				= true,
		["char"]				= true,
		["computer_command"]	= true,
		["disk"]				= true,
		["disk_eject"]			= true,
		["file_transfer"]		= true,
		["http_check"]			= true,
		["http_failure"]		= true,
		["http_success"]		= true,
		["key"]					= true,
		["key_up"]				= true,
		["modem_message"]		= true,
		["monitor_resize"]		= true,
		["monitor_touch"]		= true,
		["mouse_click"]			= true,
		["mouse_drag"]			= true,
		["mouse_scroll"]		= true,
		["mouse_up"]			= true,
		["paste"]				= true,
		["peripheral"]			= true,
		["peripheral_detach"] 	= true,
		["rednet_message"]		= true,
		["redstone"]			= true,
		["speaker_audio_empty"]	= true,
		["task_complete"]		= true,
		["term_resize"]			= true,
		["terminate"]			= true,
		["timer"]				= true,
		["turtle_inventory"]	= true,
		["websocket_closed"]	= true,
		["websocket_failure"]	= true,
		["websocket_message"]	= true,
		["websocket_success"]	= true,
	}

	-- this function never stops as long as we have any function that could take action (or the display is active, so the human could start something)
	-- dit gaat niet werken nu, moet nog aangepast worden !!!
	while not db.shuttingDown do

        -- listen for new messages, remember the time
		local event, p1, p2, p3, p4, p5 = os.pullEvent()
		local now                       = os.clock()
		local originalEvent             = event

		-- todo: as a normal handler
		if event == "timer"		    then event, p1 = ProcessTimerEvent(p1) end

		-- log not ignored events
		if not ignore[event] and db.debug then
 			-- log to file
--			coreutils.WriteToFile(db.logfile, tostring(coreutils.UniversalTime()) .. " " .. "event = " .. event .. ", p1 = " .. (p1 or ""), "a")
		end

		-- dispatch event to the right listener
		if      type(listener[event]) == "function"                                             then listener[event](p1, p2, p3, p4, p5)
		elseif  type(listener[event]) == "table" and type(listener[event][p1]) == "function"    then listener[event][p1](p1, p2, p3, p4, p5)
		end

        -- time mesurement, to see how long this took
		local period = os.clock() - now
		if period > 0.16 then
		    coredisplay.UpdateToDisplay("WARNING: "..event.." ("..(p1 or '')..") took "..period.." seconds", 5)
		    corelog.WriteToLog("WARNING: "..event.." ("..(p1 or '')..") took "..period.." seconds")
		end
	end

	-- show we are done!
	print("CoreEvent.Run() is complete")
end

function CoreDisk.shutdown()
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
return CoreEvent