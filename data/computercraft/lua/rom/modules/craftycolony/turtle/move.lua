-- define module
-- Public API overview (empty stubs; real implementations are defined below)
local Move = {
	-- Get the current location of the turtle.
	-- returns {x, y, z}
	getLocation = function() end,

	-- Get the current direction the turtle is facing.
	-- returns {dx, dy}
	getDirection = function() end,

	-- Set the turtle's location (useful for initialization).
	-- returns {x, y, z}
	setLocation = function(location) end,

	-- Move forward a number of steps (default 1).
	-- returns (true|false, err)
	forward = function(steps) end,

	-- Move backward a number of steps (default 1).
	-- returns (true|false, err)
	back = function(steps) end,

	-- Move up a number of steps (default 1).
	-- returns (true|false, err)
	up = function(steps) end,

	-- Move down a number of steps (default 1).
	-- returns (true|false, err)
	down = function(steps) end,

	-- Turn left a number of times (default 1).
	-- returns (true|false, err)
	turnLeft = function(turns) end,

	-- Turn right a number of times (default 1).
	-- returns (true|false, err)
	turnRight = function(turns) end,

	-- Turn to face a specific direction.
	-- returns (true|false, err)
	turnTo = function(direction) end,

	-- Navigate to target location(s) using Dijkstra pathfinding with automatic obstacle avoidance.
	-- Accepts single location {x,y,z} or array of locations.
	-- returns (true|false, err)
	goTo = function(targetLocations) end,
}

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

-- convert location {x,y,z} to string key "x:y:z"
local function makeKey(location)
	return location.x .. ":" .. location.y .. ":" .. location.z
end

-- convert string key "x:y:z" back to location {x,y,z}
local function parseKey(key)
	-- variables
	local parts = {}

	-- convert key to array
	for part in string.gmatch(key, "[^:]+") do table.insert(parts, tonumber(part)) end

	-- convert array to location
	return { x = parts[1], y = parts[2], z = parts[3] }
end

-- calculate cuboid bounds from two locations with expansion
local function getCuboidBounds(loc1, targetKeys, expansion)

	-- start with the start location
	local cuboid = {
		minX = loc1.x - expansion,
		maxX = loc1.x + expansion,
		minY = loc1.y - expansion,
		maxY = loc1.y + expansion,
		minZ = loc1.z - expansion,
		maxZ = loc1.z + expansion,
	}

	-- now loop all target locations to expand the cuboid if needed
	for key, _ in pairs(targetKeys) do

		-- we need a location, not a key
		local loc = parseKey(key)

		-- expand cuboid as needed
		if cuboid.minX > loc.x - expansion then cuboid.minX = loc.x - expansion end
		if cuboid.maxX < loc.x + expansion then cuboid.maxX = loc.x + expansion end
		if cuboid.minY > loc.y - expansion then cuboid.minY = loc.y - expansion end
		if cuboid.maxY < loc.y + expansion then cuboid.maxY = loc.y + expansion end
		if cuboid.minZ > loc.z - expansion then cuboid.minZ = loc.z - expansion end
		if cuboid.maxZ < loc.z + expansion then cuboid.maxZ = loc.z + expansion end
	end

	-- return the final cuboid
	return cuboid
end

-- get all 6 neighbors of a location within bounds
local function getNeighbors(location, bounds, blocked)

	-- initialize neighbors list
	local neighbors = {}

	-- allowed directions
	local deltas = {
		{ dx =  1, dy =  0, dz =  0 }, -- +X
		{ dx = -1, dy =  0, dz =  0 }, -- -X
		{ dx =  0, dy =  1, dz =  0 }, -- +Y
		{ dx =  0, dy = -1, dz =  0 }, -- -Y
		{ dx =  0, dy =  0, dz =  1 }, -- +Z
		{ dx =  0, dy =  0, dz = -1 }, -- -Z
	}

	-- find neighbors
	for _, delta in ipairs(deltas) do
		local neighbor = {
			x = location.x + delta.dx,
			y = location.y + delta.dy,
			z = location.z + delta.dz,
		}

		-- check if within bounds
		if neighbor.x >= bounds.minX and neighbor.x <= bounds.maxX and
		   neighbor.y >= bounds.minY and neighbor.y <= bounds.maxY and
		   neighbor.z >= bounds.minZ and neighbor.z <= bounds.maxZ then

			-- check if not blocked
			local key = makeKey(neighbor)
			if not blocked[key] then table.insert(neighbors, neighbor) end
		end
	end

	-- these are the neighbors
	return neighbors
end

local function convertTargetLocations(targetLocations)

	-- variables
	local targetKeys = {}

	-- targetLocations should be a list of locations, or maybe just a single location
	if type(targetLocations) ~= "table" then return nil, "Move.convertTargetLocations: targetLocations must be a table" end

	-- check if this is a single location
	if Location.isValid(targetLocations) then targetLocations = { targetLocations } end

	-- I guess a list of targets
	for _, location in ipairs(targetLocations) do
		if Location.isValid(location) then targetKeys[ makeKey(location) ] = true end
	end

	-- check if we found any valid target locations
	if next(targetKeys) == nil	then return nil, "Move.convertTargetLocations: no valid target locations found"
								else return targetKeys
	end
end

-- dijkstra pathfinding from start to goal within bounds, avoiding blocked cells
-- returns path as array of locations, or nil if no path found
local function dijkstra(start, goalKeys, bounds, blocked)
	local startKey	= makeKey(start)

	-- already at goal
--	if startKey == goalKey then return {} end -- dijkstra will return an empty path anyway when we are already there

	-- priority queue (simple array, we'll find minimum each time)
	local openSet	= { startKey }
	local distances	= { [startKey] = 0 }
	local previous	= {}
	local visited	= {}					-- all the locations already processed

	-- main loop, as long as there are nodes to explore
	while #openSet > 0 do

--[[
		-- this would be usefull when the openSet was not sorted; maybe one day when turning costs are added

		-- find node with minimum distance
		local currentKey	= nil
		local minDist		= math.huge
		local minIndex		= nil

		for i, key in ipairs(openSet) do
			if distances[key] < minDist then
				minDist = distances[key]
				currentKey = key
				minIndex = i
			end
		end

		-- remove from open set
		table.remove(openSet, minIndex)
--]]
		-- the first in the openSet should be the best one to process next
		local currentKey	= table.remove(openSet, 1)
		local minDist		= distances[currentKey]

		-- check if we reached the goal
		if goalKeys[currentKey] then

			-- reconstruct path
			local path = {}
			local key = currentKey
			while previous[key] do
				table.insert(path, 1, parseKey(key))
				key = previous[key]
			end
			return path
		end

		-- mark as visited
		visited[currentKey] = true

		-- check all neighbors
		local currentLoc = parseKey(currentKey)
		local neighbors = getNeighbors(currentLoc, bounds, blocked)

		-- loop the neighbors, if any
		for _, neighbor in ipairs(neighbors) do
			local neighborKey = makeKey(neighbor)

			-- only if not visited, otherwise the location is already processed or already in the openSet
			if not visited[neighborKey] then

				-- calculate cost, just 1 per move
				local newDist 	= distances[currentKey] + 1 -- all moves cost 1

				-- update distance if first time or better then previous
				if not distances[neighborKey] or newDist < distances[neighborKey] then

					-- if there is no distance yet, it means we need to add it to the open set
					local addToOpenSet = distances[neighborKey] == nil

					-- update distance and previous
					distances[neighborKey]	= newDist
					previous[neighborKey]	= currentKey

					-- add to open set if not already there
					if addToOpenSet then table.insert(openSet, neighborKey) end
				end
			end
		end
	end

	-- no path found
	return nil
end

-- execute a path step by step, return true if successful, or false with blocked location
local function executePath(path)

	-- step by step
	for i, targetLoc in ipairs(path) do

		-- calculate delta from current to target
		local dx = targetLoc.x - db.location.x
		local dy = targetLoc.y - db.location.y
		local dz = targetLoc.z - db.location.z

		-- determine move type and execute
		local success, err

		-- up and down are easy
			if dz ==  1 then success, err = Move.up(1)
		elseif dz == -1 then success, err = Move.down(1)
		else --elseif dx ~= 0 or dy ~= 0 then

			-- need to turn to face the right direction
			local targetDirection = Direction.new(dx, dy)

			-- turn until facing the right direction
			while not Direction.isEquel(db.direction, targetDirection) do

				-- this is what left looks like
				local leftDir = Direction.turnLeft(db.direction)

				-- requested direction same as left?
				if Direction.isEquel(leftDir, targetDirection)	then Move.turnLeft(1)
																else Move.turnRight(1)
				end
			end

			-- now move forward
			success, err = Move.forward(1)
		end

		-- check if move succeeded and if not, return false with blocked location
		if not success then return false, targetLoc end
	end

	-- all done if we are still here
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

function Move.getLocation()
	-- make sure we are initialized
	if not db.initialized then init() end

	-- return a clone of our location
	return Location.clone(db.location)
end

function Move.getDirection()
	-- make sure we are initialized
	if not db.initialized then init() end

	-- return a clone of our direction
	return Direction.clone(db.direction)
end

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

function Move.turnTo(direction)

	-- not usefull for computers
	if not turtle then error("Move.turnTo: turtle API not available") end

	-- check direction parameter
	if not Direction.isValid(direction) then return false, "Move.turnTo: invalid direction parameter" end

	-- make sure we are initialized
	if not db.initialized then init() end

	-- turn until facing the right direction
	while not Direction.isEquel(db.direction, direction) do

		-- this is what left looks like
		local leftDir = Direction.turnLeft(db.direction)

		-- requested direction same as left?
		if Direction.isEquel(leftDir, direction)	then Move.turnLeft(1)
												else Move.turnRight(1)
		end
	end

	-- done
	return true
end

-- function to go to a target location {x,y,z}
-- returns (true|false, err): whether the turn was successful or not
function Move.goTo(targetLocations)

	-- not usefull for computers
	if not turtle then error("Move.goTo: turtle API not available") end

	-- make sure we are initialized
	if not db.initialized then init() end

	-- validate target locations
	local targetKeys, err = convertTargetLocations(targetLocations)
	if not targetKeys then return false, "Move.goTo: invalid target location: "..err end

	-- initialize blocked cells map (persists across expansion)
	local blocked = {}
	local expansion = 0

	-- our start location
	local startLocation = Location.clone(db.location)

	-- main loop: expand cuboid and retry until we reach the target
	while turtle.getFuelLevel() > 0 do

		-- calculate current cuboid bounds
		local bounds = getCuboidBounds(startLocation, targetKeys, expansion)

		-- run dijkstra to find a path
		local path = dijkstra(db.location, targetKeys, bounds, blocked)

		if not path then
			-- no path found, expand the cuboid and try again
			expansion = expansion + 1
		else
			-- path found, try to execute it
			local success, blockedLoc = executePath(path)

			-- successfully reached target, we master this!!
			if success then	return true
			else
				-- movement was blocked, mark the location and re-run dijkstra
				local blockedKey = makeKey(blockedLoc)
				blocked[blockedKey] = true
			end
		end
	end

	-- running out of fuel?
	return false, "Move.goTo: unable to reach target location, out of fuel"
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