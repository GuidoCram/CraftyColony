-- Core event handling for CraftyColony
-- module for managing events and interactions within CraftyColony
-- helps with event registration, handling, and dispatching
-- stuff not used yet

local CoreEvent = {}

-- imports
local CoreDisk = require("core.coredisk")

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

-- setup of core event
function CoreEvent.setup()
end

-- to add a custom functions to the event listener
function CoreEvent.addEventListener(eventType, func)

    -- not sure if we allow an event listener without a subject...
	if eventType and type(eventType) == "string" then

		-- create list if not yet present
		if type(db.listeners[eventType]) ~= "table" then db.listeners[eventType] = {} end

	    -- add to the list
		table.insert(db.listeners[eventType], func)
	end
end

-- to remove the custom functions to the event listener.
function CoreEvent.removeEventListener(eventType, func)

    -- check if the request is valid
	if eventType and type(eventType) == "string" and type(db.listeners[eventType]) == "table" then

		-- remove specific function from the list, walk through the list backwards to avoid issues with changing indices
		for i = #db.listeners[eventType], 1, -1 do

			-- remove if found
			if db.listeners[eventType][i] == func then table.remove(db.listeners[eventType], i) end
		end
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

	-- as long we are not shutting down, we will run the main loop
	while not db.shuttingDown do

        -- listen for new messages, remember the time
		local event, p1, p2, p3, p4, p5 = os.pullEvent()
		local now                       = os.clock()

		-- dispatch event to the right listener
		if type(listener[event]) == "table" then

			-- execute all listeners for this event
			for _, func in ipairs(listener[event]) do
				-- pcall to avoid a crash of the whole system
				pcall(func, p1, p2, p3, p4, p5)
			end

		-- no table present means there is no listener for this event
		else

			-- only log in debug and not ignored -- todo: write to log
			if db.debug and not ignore[event] then end
		end

        -- time mesurement, to see how long this took
		local period = os.clock() - now
		if period > 0.16 then
			-- todo: write to log
		end
	end
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