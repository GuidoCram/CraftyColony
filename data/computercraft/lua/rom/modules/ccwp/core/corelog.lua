-- define module
local corelog = {}

-- ToDo: add proper module description
--[[
    This module ...
--]]

local coreassignment
local coreutils = require "coreutils"

local DisplayStation
local enterprise_employment = nil

local db	= {
	logfile			    = "/log/log.txt",
	assignmentLogFile   = "/log/coreassignment.log",
	projectsLogFile     = "/log/enterprise_projects.log",
	protocol		    = "corelog",
	loggerFunctions		= {},
	lastStack           = 0,
}

function corelog.Init()
	-- place markers in the logfile
	corelog.WriteToLog("--- starting up ---", "overwrite")
	corelog.WriteToAssignmentLog("--- starting up assignments ---", nil, "overwrite")
	corelog.WriteToProjectsLog("--- starting up projects ---", nil, "overwrite")
end

function corelog.Setup()
	corelog.WriteToLog("corelog.Setup()")
end

function corelog.SetLoggerFunction(func) table.insert(db.loggerFunctions, func) end

function corelog.ClearLog()
	-- just overwrite the logfile, this does create a first empty line
	coreutils.WriteToFile(db.logfile, nil, "overwrite")
end

function corelog.WriteToLog(message, writeMode)
	-- set the default
	writeMode = writeMode or "append"

	-- might be a table
	if type(message) == "table" then message = textutils.serialize(message)
								else message = tostring(message)
	end

	-- write to the logfile
	coreutils.WriteToFile(db.logfile, coreutils.UniversalTime()..': '..message, writeMode)

	-- process external loggers
	for i, func in ipairs(db.loggerFunctions) do func(message) end
end

function corelog.Warning(message)
	-- write to the logfile
	coreutils.WriteToFile(db.logfile, "WARNING:", "append") -- ToDo: consider calling WriteToLog
	coreutils.WriteToFile(db.logfile, message, "append") -- ToDo: consider calling WriteToLog

	-- format the warning
	if type(message) == "table" then message = textutils.serialize(message) end
	message = "WARNING: "..message

	-- process external loggers
	for i, func in ipairs(db.loggerFunctions) do func(message) end
end

function corelog.Error(message)
	-- write to the logfile
	coreutils.WriteToFile(db.logfile, "ERROR:", "append") -- ToDo: consider calling WriteToLog

	-- calling stack, just max once per tick
	if db.lastStack < os.clock() then

		-- reset
		db.lastStack = os.clock()

		-- write the callstack to the logfile
		coreutils.WriteToFile(db.logfile, debug.traceback())
	end

	-- requested messaage
	coreutils.WriteToFile(db.logfile, message, "append") -- ToDo: consider calling WriteToLog

	-- process external loggers
	message = "ERROR: "..message
	for i, func in ipairs(db.loggerFunctions) do func(message) end
end

function WriteToFormattedLog(message, id, logType, writeMode)
	-- set the default
	writeMode = writeMode or "append"

	-- write message to the logfile	in formatted log format
    local now = coreutils.UniversalTime()
    local computerId = os.getComputerID()
	local idStr = "assignment"
	local logFile = db.assignmentLogFile
	if logType == "projects" then
		idStr = "project"
		logFile = db.projectsLogFile
	end
	if id then
		idStr = idStr.." "..id.." | "
	else
		idStr = ""
	end
	coreutils.WriteToFile(logFile, "| time "..now.." | computer "..computerId.." | "..idStr..message.." |", writeMode)
end

function corelog.WriteToAssignmentLog(message, assignmentId, writeMode)
	WriteToFormattedLog(message, assignmentId, "assignment", writeMode)
end

function corelog.WriteToProjectsLog(message, projectId, writeMode)
	WriteToFormattedLog(message, projectId, "projects", writeMode)
end

function corelog.FindCaller(...) -- give ignore string as parameters. corelog.FindCaller("enterprise_projects", "enterprise_storage")
	local ignore = {method_executor = true}

	-- add all other keys to ignore
	for index, toIgnore in ipairs(arg) do ignore[ toIgnore ] = true end

	-- we don't need ourself (0) and the one calling this function (1), start witth 2
	local level = 2

	-- endless until we are at the end or found something
	while true do

		-- get the debug info
		local info = debug.getinfo(level, "Sl")

		-- at the end of the stack?
		if not info then return nil end

		-- just to be sure, skip C functions
		if info.what ~= "C" and ignore[info.short_src] == nil then -- not a C function and not in the ignore list

			-- Yahoo!
			return string.format("[%s]:%d", info.short_src, info.currentline)

		end

		-- still here, try the next level
		level = level + 1
	end
end

return corelog
