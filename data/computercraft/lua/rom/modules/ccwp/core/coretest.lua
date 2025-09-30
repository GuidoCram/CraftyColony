-- define module
local coretest = {}

-- ToDo: add proper module description
--[[
    This module ...
--]]

local corelog		= require "corelog"
local coresystem	= require "coresystem"

-- object / function references
local work		        = {first = 0, last = -1}	-- list of known work items (as queue)

function coretest.Init()
end

function coretest.Setup()
end

-- add something to test
function coretest.AddTest(func, data, desc)

	-- safety, func must be a function
    if type(func) == "function" then

		-- we have a new last!
    	work.last		= work.last + 1

		-- add to the work list
    	work[work.last]	= {func = func, data = data, desc = desc}

		-- in case anybody cares
		return work.last
    else

		-- this should never be!
        corelog.WriteToLog("coretest.AddWork: func not a function")
    end
end

-- to do the actual work, (almost) endless loop
function coretest.Run()
	-- work forever
	while coresystem.IsRunning() do

		-- is there any work to do?
		if work.first <= work.last then

			-- get the work item
			local nextTest = work[work.first]

			-- do the work
			nextTest.func(nextTest.data)

			-- mark work as complete
			work[work.first]	= nil
			work.first			= work.first + 1
		else
			-- wait for any event, ignore result
			os.sleep(0.05)
		end
	end

	-- show we are done!
	print("coretest.Run() is complete")
end

return coretest
