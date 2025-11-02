-- define module
-- Public API overview (empty stubs; real implementations are defined below)
local Logger = {
	-- Write a log message to mainLog.txt with timestamp and computer ID.
	-- no return
	log = function(message) end,

	-- Write a warning message to warningLog.txt and print to console.
	-- no return
	warning = function(message) end,

	-- Write an error message to errorLog.txt and print to console.
	-- no return
	error = function(message) end,

	-- Write a debug message to debugLog.txt (no console output).
	-- no return
	debug = function(message) end,
}

-- imports

local CoreDisk = require("craftycolony.core.coredisk")

--[[
      _                     _       _   _
     | |                   (_)     | | (_)
   __| | ___  ___  ___ _ __ _ _ __ | |_ _  ___  _ __
  / _` |/ _ \/ __|/ __| '__| | '_ \| __| |/ _ \| '_ \
 | (_| |  __/\__ \ (__| |  | | |_) | |_| | (_) | | | |
  \__,_|\___||___/\___|_|  |_| .__/ \__|_|\___/|_| |_|
                             | |
                             |_|


	This module implements some simple logging actions, for uniform logging.
	-- log
	-- warning
	-- error
	-- debug

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

	-- just some knowledge about us
	me					= string.format("%02d", os.getComputerID()),

	-- this is where we keep our data on disk
	logFilename			= "/log/mainLog.txt",
	warningFilename		= "/log/warningLog.txt",
	errorFilename		= "/log/errorLog.txt",
	debugFilename		= "/log/debugLog.txt",
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

function Logger.log(message)

	-- prepend with timestamp and computer ID
	local logMessage = "[" .. os.date("%H:%M:%S") .. "][" .. db.me .. "] " .. message .. "\n"

	-- write to log file
	CoreDisk.appendToFile(db.logFilename, logMessage)

end

function Logger.warning(message)

	-- prepend with timestamp and computer ID
	local logMessage = "[" .. os.date("%H:%M:%S") .. "][" .. db.me .. "] " .. message .. "\n"

	-- also print to console
	print('Warning: ' .. logMessage)

	-- write to warning log file
	CoreDisk.appendToFile(db.warningFilename, logMessage)

end

function Logger.error(message)

	-- prepend with timestamp and computer ID
	local logMessage = "[" .. os.date("%H:%M:%S") .. "][" .. db.me .. "] " .. message .. "\n"

	-- also print to console
	print('Error: ' .. logMessage)

	-- write to error log file
	CoreDisk.appendToFile(db.errorFilename, logMessage)

end

function Logger.debug(message)

	-- prepend with timestamp and computer ID
	local logMessage = "[" .. os.date("%H:%M:%S") .. "][" .. db.me .. "] " .. message .. "\n"

	-- write to debug log file
	CoreDisk.appendToFile(db.debugFilename, logMessage)

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
return Logger
