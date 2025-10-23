-- define module
local Move = {}

-- imports
local CoreData	= require("craftycolony.core.coredata")

local Direction	= require("craftycolony.utilities.direction")
local Location	= require("craftycolony.utilities.location")

--[[
      _                     _       _   _
     | |                   (_)     | | (_)
   __| | ___  ___  ___ _ __ _ _ __ | |_ _  ___  _ __
  / _` |/ _ \/ __|/ __| '__| | '_ \| __| |/ _ \| '_ \
 | (_| |  __/\__ \ (__| |  | | |_) | |_| | (_) | | | |
  \__,_|\___||___/\___|_|  |_| .__/ \__|_|\___/|_| |_|
                             | |
                             |_|


  This module implements some generative functions, like unique id generation.

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

	-- moduleName
	moduleName		= "Move",

	-- is this module initialized?
	initialized		= false,

	-- this is our location
	location		= { x = 0, y = 0, z = 0 },
	direction		= { dx = 0, dy = 1},
}

--[[
                      _       _        _       _ _
                     | |     | |      (_)     (_) |
  _ __ ___   ___   __| |_   _| | ___   _ _ __  _| |_
 | '_ ` _ \ / _ \ / _` | | | | |/ _ \ | | '_ \| | __|
 | | | | | | (_) | (_| | |_| | |  __/ | | | | | | |_
 |_| |_| |_|\___/ \__,_|\__,_|_|\___| |_|_| |_|_|\__|

--]]


--[[
  _                 _
 | |               | |
 | | ___   ___ __ _| |
 | |/ _ \ / __/ _` | |
 | | (_) | (_| (_| | |
 |_|\___/ \___\__,_|_|

--]]

local function init()
	-- get the data from CoreData
	data = CoreData.getData(db.moduleName)

	-- load last known location and direction
	if data.location	then db.location	= data.location end
	if data.direction	then db.direction	= data.direction end

	-- update initialized
	db.initialized = true
end

local function saveDB()
	-- save the database
	CoreData.setData(db.moduleName, { location = db.location, direction = db.direction })
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

function Move.setLocation(location)
	-- usefull when a new computer is just created and has no location yet

	-- make sure we are initialized
	if not db.initialized then init() end

	-- update the location
	db.location = Location.clone(location)

	-- save the database
	saveDB()

	-- done
	return location
end

function Move.forward(steps)
	-- move forward a number of steps (default 1)

	-- not usefull for computers
	if not turtle then error("Move.forward: turtle API not available") end

	-- make sure we are initialized
	if not db.initialized then init() end

	-- default steps to 1
	steps = steps or 1
	steps = math.max(1, math.floor(steps + 0.5))

	-- step by step
	for i = 1, steps do

		-- try to move forward
		local success, err = turtle.forward()
		
		if not success then
			error("Move.forward: unable to move forward at step "..i..": "..tostring(err))
		end

		-- update location
		db.location = Location.move(db.location, db.direction, 1)

		-- save the database
		saveDB()
	end

	-- actually move the turtle
	if turtle and turtle.forward then
		for i = 1, steps do
			turtle.forward()
		end
	end

	-- update location
	db.location = Location.move(db.location, db.direction, steps)

	-- save the database
	saveDB()

	-- done
	return db.location
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
return Move