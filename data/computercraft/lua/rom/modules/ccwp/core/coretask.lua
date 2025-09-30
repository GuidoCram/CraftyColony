-- define module
local coretask = {}

-- ToDo: add proper module description
--[[
    This module ...
--]]

local corelog		= require "corelog"
local coresystem	= require "coresystem"
local coreevent		= require "coreevent"

-- object / function references
local work		        = {first = 0, last = -1}	-- list of known work items (as queue)
local idleHandler		= {}
local postWorkHandler   = {}

function coretask.Init()
end

function coretask.Setup()
end

-- deze functie werkt nergens gebruikt, werkt ook niet naar mijn verwachting
function coretask.TaskComplete(taskId)
	if type(taskId) == "number" then
		return taskId < work.first
	else
		return true
	end
end

-- add something to do, and have the system triggered to get to work if idle
function coretask.AddWork(func, data, desc)
    if type(func) == "function" then
    	work.last		= work.last + 1
    	work[work.last]	= {func = func, data = data, desc = desc}
    	os.queueEvent("dummy")
		return work.last
    else
        corelog.WriteToLog("taskAPI.AddWork: func not a function")
    end
end

-- add something to do right away, and have the system triggered to get to work if idle
function AddNextWork(func, data, desc)
    if type(func) == "function" then
		work.first			= work.first - 1
		work[work.first]	= {func = func, data = data, desc = desc}
		os.queueEvent("dummy")
		return work.first
    else
        corelog.WriteToLog("taskAPI.AddNextWork: func not a function")
    end
end

-- to add a new idle handler, max 1 per protocol
function coretask.AddIdleHandler(protocol, ticks, func)
	-- add the handler
	idleHandler[protocol] = {
		delta   = ticks / 20,
		func    = func,
		lastRun = os.clock()
	}
end

-- to remove the idle handler
function coretask.RemoveIdleHandler(protocol)
	idleHandler[protocol] = nil
end

-- things to do after every task. Usually logging for debug.
function AddPostWork(protocol, func)
    postWorkHandler[protocol] = func
end

-- to do the actual work, (almost) endless loop
function coretask.Run()
	-- work forever
	while coresystem.IsRunning() do

		-- is there any work to do?
		if work.first <= work.last then

			-- get the work item
			local nextWork = GetNextWork()

			-- do the work
--			corelog.WriteToLog("coretask.Run(): executing "..(nextWork.desc or "unknown function"))
			nextWork.func(nextWork.data)
--			corelog.WriteToLog("coretask.Run(): "..(nextWork.desc or "unknown function").." complete")

			-- mark work as complete
			NextWorkComplete()

			-- do the post work -- weird thing, do all post work, regardless of protocol... !!!
			for protocol, func in pairs(postWorkHandler) do corelog.WriteToLog("Work, postWorkHandler, protocol = ", protocol) func() end

			-- reset all idle timers -- weird, should be a db variable
			local now = os.clock()
			for protocol, data in pairs(idleHandler) do data.lastRun = now end

		-- nothing in the work list
		else
			-- keep track of the next event
			local nextProtocol
			local overTime	= 86400
			local now		= os.clock()

			-- reset the work list
			work			= {first = 0, last = -1}

			-- find a function to run
			for protocol, data in pairs(idleHandler) do
			    if overTime > (data.lastRun + data.delta - now) then
			        nextProtocol    = protocol
			        overTime        = data.lastRun + data.delta - now
			    end
			end

			-- did we find an idle function to run?
			if nextProtocol and overTime <= 0 then
				-- run the function
				idleHandler[nextProtocol].func()

				-- reset last rust
				idleHandler[nextProtocol].lastRun = os.clock()
			else
			    -- create an dummy event so we will never wait longer for an event then 20 ticks
			    local id = coreevent.CreateTimeEvent(20, "dummy")

				-- wait for any event, ignore result
				os.pullEvent()

				-- in case we have an other event
				coreevent.CancelTimeEvent(id)
			end
		end
	end

	-- usefull feedback
	print("coretask.Run() is complete")
end

-- get the next thing to do from the list, local function
function GetNextWork()
	-- get referece to the task
    local task			= work[work.first]

    -- return the table with function and data
    return task
end

function NextWorkComplete()
    -- remove item from the list
    work[work.first]	= nil
    work.first			= work.first + 1
end

function coretask.QueueLength()
	return 1 + work.last - work.first
end

return coretask
