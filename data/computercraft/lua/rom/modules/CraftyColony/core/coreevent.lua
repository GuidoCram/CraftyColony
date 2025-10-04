-- Core event handling for CraftyColony
-- module for managing events and interactions within CraftyColony
-- helps with event registration, handling, and dispatching
-- stuff not used yet

local coreevent = {}

-- allemaal event spullen
local db = {

    -- unique name for this module
    protocol		= "core:event",     -- protocol name for this module

    -- usefull information
    timers			= {},		        -- list of all known timers

    -- for development
    debug			= false,
    logfile			= "/log/core.event.log",
}

-- object / function references
local listener    	= {}
local eventready	= {}	-- list of functions to run when ready

-- init of core event
function coreevent.Init()
end

-- event setup
function coreevent.Setup()

    -- this will create a loop of one event every tick at least, I don't think this is usefull for event, maybe for messaging
--    coreevent.CreateTimeEvent(1, db.protocol, "tick timer")
end

-- others can register a function to be run when the event loop is (about to be) started
function coreevent.EventReadyFunction(func)

	-- just add function to the list
	table.insert(eventready, func)
end

-- function to fire an event in a specific number of seconds
function coreevent.CreateTimeEvent(ticks, protocol, p1, p2, p3, p4, p5)
	local id = os.startTimer(ticks/20)

	-- add this one to our memory
	db.timers[id] = {protocol=protocol, p1=p1, p2=p2, p3=p3, p4=p4, p5=p5, finished=os.clock() + ticks / 20}

	-- return the id of the timer, in case our caller wants to clear the timer
	return id
end

-- not sure if anyone will ever cancel a timer or just let it run out
function coreevent.CancelTimeEvent(id)
	-- clear the timer in the os queue
	os.cancelTimer(id)

	-- clear the data from our memory
	db.timers[id] = nil
end

-- to add a custom functions to the event listener
function coreevent.AddEventListener(func, protocol, subject)

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
function coreevent.RemoveEventListener(protocol, subject)

    -- check if we need to remove all from this protocol
	if subject  then listener[protocol][subject]    = nil
			    else listener[protocol]             = nil
	end
end

-- local function to process a timer event
local function ProcessTimerEvent(id)
    local timers = db.timers

	-- is it a known timer?
	if timers[id] ~= nil then

		-- return as a new event
		local timer = timers[id]
		timers[id] = nil
		return timer.protocol, timer.p1, timer.p2, timer.p3, timer.p4, timer.p5
	else
		-- we don't know this timer, continue with the event as it was
		return 'timer', id
	end
end

-- listener to every event incoming
function coreevent.Run()

    -- events we ignore in the global event listener these events in case we have logging on
	local ignore    = {
		["char"]				= true,
		["dummy"]				= true,
		["key"]					= true,
		["key_up"]				= true,
		["redstone"]			= true,
		["timer"]				= true,
		["turtle_inventory"]	= true,
		["turtle_response"]		= true,
	}

	-- run functions when event is (about to be) ready
	for i, func in ipairs(eventready) do func() end
	eventready = {}

	-- this function never stops as long as we have any function that could take action (or the display is active, so the human could start something)
	-- dit gaat niet werken nu, moet nog aangepast worden !!!
	while coresystem.IsRunning() do

        -- listen for new messages, remember the time
		local event, p1, p2, p3, p4, p5 = os.pullEvent()
		local now                       = os.clock()
		local originalEvent             = event

		-- if it is a modem message or timer, pre process the message so it's decompiled
		if event == "timer"		    then event, p1, p2, p3, p4, p5 = ProcessTimerEvent(p1) end

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
	print("coreevent.Run() is complete")
end

--                         _
--                        | |
--     _____   _____ _ __ | |_ ___
--    / _ \ \ / / _ \ '_ \| __/ __|
--   |  __/\ V /  __/ | | | |_\__ \
--    \___| \_/ \___|_| |_|\__|___/
--
--

local DoEventTickTimer(subject, envelope)
	-- todo: consider working with handlers

	-- set new timer for the next tick
	coreevent.CreateTimeEvent(1, db.protocol, "tick timer")
end

-- done
return coreevent