-- define module
local Generate = {}

-- imports

local CoreDisk = require("CraftyColony.core.CoreDisk")

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

	-- is this module initialized?
	initialized		= false,

	-- just some knowledge about us
	me				= os.getComputerID(),

	-- keep track of the last used id
	lastID			= 0,				-- last used id

	-- this is where we keep our data on disk
	dbFilename		= "/CraftyColony/GenerateDB.json",
}

--[[
                      _       _        _       _ _
                     | |     | |      (_)     (_) |
  _ __ ___   ___   __| |_   _| | ___   _ _ __  _| |_
 | '_ ` _ \ / _ \ / _` | | | | |/ _ \ | | '_ \| | __|
 | | | | | | (_) | (_| | |_| | |  __/ | | | | | | |_
 |_| |_| |_|\___/ \__,_|\__,_|_|\___| |_|_| |_|_|\__|

--]]

-- read data from disk
CoreDisk.readFile(db.dbFilename, initCallback)

--[[
  _                 _
 | |               | |
 | | ___   ___ __ _| |
 | |/ _ \ / __/ _` | |
 | | (_) | (_| (_| | |
 |_|\___/ \___\__,_|_|

--]]

local function initCallback(data)

	-- if we have data, then
	if not data or type(data) ~= "table" then data = {} end

	-- use the data from disk
	db.lastID = data.lastID or 0

	-- now we are done
	db.initialized = true
end

local function saveDB()

	-- save the database to disk, asynchronously
	CoreDisk.writeFile(db.dbFilename, data)
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

function Generate.id()

	-- we should be initialized
	if db.initialized then

		-- increase the id
		db.lastID = db.lastID + 1

		-- save the database
		saveDB()

		-- return the new id
		return db.me..":"..db.lastID

	else
		-- generate a temporary id
		local tempID = ""
		for n = 1, 12 do tempID = tempID..string.char(math.random(string.byte("a"), string.byte("z"))) end

		-- done
		return db.me..":"..tempID
	end
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
return Generate