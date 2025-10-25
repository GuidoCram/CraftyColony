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

-- function to move forward|back|up|down a number of steps
-- steps: number of steps to move (default 1)
-- return (true|false, err): whether the move was successful or not
local function move(steps, direction)
	-- move a number of steps (default 1)

	-- not usefull for computers
	if not turtle then error("Move.forward: turtle API not available") end

	-- make sure we are initialized
	if not db.initialized then init() end

	-- default steps to 1
	steps = steps or 1
	steps = math.max(1, math.floor(steps + 0.5))

	-- check fuel level?
	if turtle.getFuelLevel() < steps then return false, "Move.forward: not enough fuel to move "..steps.." steps" end

	-- our functions to use
	local turtleMoveFunc = nil
	local locationUpdateFunc = nil

	-- what is the requested direction?
		if direction == "forward"	then turtleMoveFunc = turtle.forward	locationUpdateFunc = Location.forward
	elseif direction == "back"		then turtleMoveFunc = turtle.back		locationUpdateFunc = Location.back
	elseif direction == "up"		then turtleMoveFunc = turtle.up			locationUpdateFunc = Location.up
	elseif direction == "down"		then turtleMoveFunc = turtle.down		locationUpdateFunc = Location.down
									else error("Move.move: invalid direction: "..tostring(direction))
	end

	-- step by step
	for i = 1, steps do

		-- try to move forward
		local success, err = turtleMoveFunc()

		-- should be done better one day...
		if not success then return false, "Move.forward: unable to move forward at step "..i..": "..tostring(err) end

		-- update location
		db.location = locationUpdateFunc(db.location, db.direction, 1)
		saveDB()
	end

	-- well done!
	return true
end

-- function to turn left
local function turn(turns, direction)

	-- not usefull for computers
	if not turtle then error("Move.turn: turtle API not available") end

	-- make sure we are initialized
	if not db.initialized then init() end

	-- default turns to 1
	turns = turns or 1
	turns = math.max(1, math.floor(turns + 0.5))

	local turtleTurnFunc = nil
	local directionUpdateFunc = nil

	-- what is the requested direction?
		if direction == "left"	then turtleTurnFunc = turtle.turnLeft	directionUpdateFunc = Direction.turnLeft
	elseif direction == "right"	then turtleTurnFunc = turtle.turnRight	directionUpdateFunc = Direction.turnRight
								else error("Move.turn: invalid direction: "..tostring(direction))
	end

	-- do the turns
	for i = 1, turns do

		-- try to turn the turtle left
		local success, err = turtleTurnFunc()
		if not success then return false, "Move.turn: unable to turn at turn "..i..": "..tostring(err) end

		-- update direction
		db.direction = directionUpdateFunc(db.direction)
		saveDB()
	end

	-- well done!
	return true
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

-- function to move forward a number of steps
-- steps: number of steps to move forward (default 1)
-- return (true|false, err): whether the move was successful or not
function Move.forward(steps)
	-- easy
	return move(steps, "forward")
end

-- function to move backwards a number of steps
-- steps: number of steps to move backwards (default 1)
-- return (true|false, err): whether the move was successful or not
function Move.back(steps)
	-- easy
	return move(steps, "back")
end

-- function to move up a number of steps
-- steps: number of steps to move up (default 1)
-- return (true|false, err): whether the move was successful or not
function Move.up(steps)
	-- easy
	return move(steps, "up")
end

-- function to move down a number of steps
-- steps: number of steps to move down (default 1)
-- return (true|false, err): whether the move was successful or not
function Move.down(steps)
	-- easy
	return move(steps, "down")
end

-- function to turn left
-- turns: number of turns to turn left (default 1)
-- return (true|false, err): whether the turn was successful or not
function Move.turnLeft(turns)
	-- easy
	return turn(turns, "left")
end

-- function to turn right
-- turns: number of turns to turn right (default 1)
-- return (true|false, err): whether the turn was successful or not
function Move.turnRight(turns)
	-- easy
	return turn(turns, "right")
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