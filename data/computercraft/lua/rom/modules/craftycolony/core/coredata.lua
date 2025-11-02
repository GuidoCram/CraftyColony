-- define module
local CoreData = {
  -- Public API Overview:
  -- init() - Initialize the module
  -- setup() - Setup the module
  -- run() - Run the module
  -- shutdown() - Shutdown the module
  -- getData(moduleName) - Get the data for the given module
  -- setData(moduleName, data) - Set the data for the given module
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


    This module keeps the data of this computer. Other modules can store computer data here.

	Every module has one entry in the database, identified by the module name.
	Each module can store any data it wants in its entry, as long as it is serializable to JSON.

--]]

--[[
      _       _
     | |     | |
   __| | __ _| |_ __ _
  / _` |/ _` | __/ _` |
 | (_| | (_| | || (_| |
  \__,_|\__,_|\__\__,_|

--]]

local db	    = {

	-- the actual data table
	CoreData			= {

		-- data for modules goes here
		dbFilename		= "CoreData.lua",

		-- this is me
		me				= os.getComputerID(),
	},
}

--[[
                      _       _        _       _ _
                     | |     | |      (_)     (_) |
  _ __ ___   ___   __| |_   _| | ___   _ _ __  _| |_
 | '_ ` _ \ / _ \ / _` | | | | |/ _ \ | | '_ \| | __|
 | | | | | | (_) | (_| | |_| | |  __/ | | | | | | |_
 |_| |_| |_|\___/ \__,_|\__,_|_|\___| |_|_| |_|_|\__|

--]]

-- read data from disk now
local loadedData = CoreDisk.loadTableSync(db.CoreData.dbFilename)

-- check for first time run, leave the db if no data is loaded
if loadedData then

	-- checks
	if type(loadedData) ~= "table" 				then error("CoreData: loadedData is not a table") end
	if type(loadedData.CoreData) ~= "table" 	then error("CoreData: loadedData.CoreData is not a table") end
	if type(loadedData.CoreData.me) ~= "number" then error("CoreData: loadedData.CoreData.me is not a number") end
	if loadedData.CoreData.me ~= db.CoreData.me	then error("CoreData: loadedData belongs to a different computer") end

	-- take over loaded data
	db = loadedData
end

-- Just for testing
CoreDisk.writeTableToFile(db.CoreData.dbFilename, db)

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

function CoreData.init()
	-- nothing to initialize at the moment
end

function CoreData.setup()
	-- nothing to setup at the moment
end

-- main run function, runs in parallel to the other core modules
function CoreData.run()
	-- nothing to do while running
end

-- initializes shutting down, stops accepting new work
function CoreData.shutdown()
	-- no shutting down
end

function CoreData.getData(moduleName)
	-- ensure module data table exists
	if db[moduleName] == nil then db[moduleName] = {} end

	-- just return the data - note to caller: this is a reference to the internal data table, don't alter it directly without using CoreData.setData!
	return db[moduleName]
end

function CoreData.setData(moduleName, data)

	-- ensure parameter is valid
	if type(moduleName) ~= "string" or moduleName == "" then error("CoreData.setData: moduleName must be a (non-empty) string") end

	-- set the data
	db[moduleName] = data

	-- save data to disk asynchronously
	CoreDisk.writeTableToFile(db.CoreData.dbFilename, db)
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
return CoreData