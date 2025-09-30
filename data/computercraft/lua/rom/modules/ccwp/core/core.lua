-- define module
local core = {}

-- ToDo: add proper module description
--[[
    This module ...
--]]

local coresystem = require "coresystem"
local coreevent = require "coreevent"
local corelog = require "corelog"
local coredisplay = require "coredisplay"
local coreenv = require "coreenv"
local coredht = require "coredht"
local coreinventory = require "coreinventory"
local coreassignment = require "coreassignment"
local coreutils = require "coreutils"
local coremove = require "coremove"
local coretask = require "coretask"
local coretest = require "coretest"

local db	    = {
    me				= os.getComputerID(),
    idleId			= 0,                                -- part of task...
}

local apis		= {}

-- initialize all system stuff
function core.Init()
    -- only if the system is just booted
    if coresystem.getStatus() ~= "booted" then return end

	-- first things first
	coreinventory.Init()

	-- init other stuff
	coredht.Init()
	coredisplay.Init()
	coreenv.Init()
	coreevent.Init()
	coreassignment.Init()
	coremove.Init()
	coretask.Init()
	coretest.Init()
	coreutils.Init()
	corelog.Init()

	-- set the new status
	coresystem.setStatus("initialized")
end

function core.Setup()
	-- only if the system is just booted
    if coresystem.getStatus() == "booted"		then core.Init() end
	if coresystem.getStatus() ~= "initialized"	then return end

	-- run all setup functions
	coredht.Setup()
	coredisplay.Setup()
	coreenv.Setup()
	coreevent.Setup()
	coreinventory.Setup()
	coreassignment.Setup()
	coremove.Setup()
	coretask.Setup()
	coretest.Setup()
	coreutils.Setup()
	corelog.Setup()

	-- set new status
	coresystem.setStatus("ready")
end

-- actually run the stuff
function core.Run()
    -- check the system status
    if coresystem.getStatus() == "booted"		then core.Init()	end
    if coresystem.getStatus() == "initialized"	then core.Setup()	end

    -- check for the right system status
    if coresystem.getStatus() == "ready" then

        -- we are now officially running!!
		coresystem.setStatus("running")

    	-- run some functions in parallel
    	parallel.waitForAll(
			coreevent.Run,		-- process all event
			coretask.Run,		-- process small task, enabling async write to file
			coretest.Run,		-- for running test, won't interfere with rest of the systeem
			coreassignment.Run,	-- runs assignments / the assignment board
			coredisplay.Run		-- processes user interaction with the display
		)

        -- no longer running, we're done
		coresystem.setStatus("ready")
    end
end

return core