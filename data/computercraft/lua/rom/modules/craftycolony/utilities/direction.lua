-- define module
-- Public API overview (empty stubs; real implementations are defined below)
local Direction = {
	-- Create a new direction. Accepts either (dx, dy) or a compass string ("north","south","west","east").
	new = function(dx, dy) end,

	-- Validate a direction table: { dx = -1|0|1, dy = -1|0|1 } with |dx|+|dy| == 1
	isValid = function(direction) end,

	-- Clone a direction table.
	clone = function(direction) end,

	-- Check if two directions are equal.
	isEquel = function(dir1, dir2) end,

	-- Rotate 90 degrees counter-clockwise.
	turnLeft = function(direction) end,

	-- Rotate 90 degrees clockwise.
	turnRight = function(direction) end,

	-- Rotate 180 degrees.
	turnAround = function(direction) end,

	-- Determine relative side ("front","back","left","right") of targetLocation from baseLocation, given facing direction.
	getSide = function(direction, dx, dy, dz) end,

	-- Convert a direction to a compass string ("north","south","west","east").
	toString = function(direction) end,
}

-- imports
local CoreDisk	= require("craftycolony.core.coredisk")

--[[
      _                     _       _   _
     | |                   (_)     | | (_)
   __| | ___  ___  ___ _ __ _ _ __ | |_ _  ___  _ __
  / _` |/ _ \/ __|/ __| '__| | '_ \| __| |/ _ \| '_ \
 | (_| |  __/\__ \ (__| |  | | |_) | |_| | (_) | | | |
  \__,_|\___||___/\___|_|  |_| .__/ \__|_|\___/|_| |_|
                             | |
                             |_|


  This module implements the use of the location object, holding x, y and z coordinates.

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
--	initialized		= true,

	-- this is where we keep our data on disk
--	dbFilename		= "/craftycolony/directiondb.json",
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

function Direction.new(dx, dy)

	-- check input, maybe just a compass direction
	if type(dx) == "string" and type(dy) == "nil" then

		-- convert parameter to lower case
		local dir = string.lower(dx)

		-- which direction?
		if     dir == "north"	then return Direction.new( 0,  1)
		elseif dir == "south"	then return Direction.new( 0, -1)
		elseif dir == "west"	then return Direction.new(-1,  0)
		elseif dir == "east"	then return Direction.new( 1,  0)

		-- not good
		else return error("Direction.new(direction) - Invalid compass direction: " .. tostring(dx))
		end
	else
		-- must be numeric
		if (type(dx) ~= "number") or (type(dy) ~= "number") or (math.abs(dx + dy) ~= 1) or (dx * dy ~= 0) then error("Direction.new(dx, dy) - Invalid direction values: (" .. tostring(dx) .. ", " .. tostring(dy) .. ")") end

		-- klaar
		return {
			dx = dx,
			dy = dy
		}
	end
end

function Direction.isValid(direction)
	return (type(direction) == "table") and (type(direction.dx) == "number") and (type(direction.dy) == "number") and (math.abs(direction.dx + direction.dy) == 1) and (direction.dx * direction.dy == 0)
end

function Direction.clone(direction)
	-- in case someone is lazy and using the string form
	if type(direction) == "string" then direction = Direction.new(direction) end

	-- check parameters
	if not Direction.isValid(direction) then return error("Direction.clone(direction) - Invalid direction value (" .. type(direction) .. ")") end

	-- clone
	return Direction.new(direction.dx, direction.dy)
end

function Direction.isEquel(dir1, dir2)
	if not Direction.isValid(dir1) then return error("Direction.isEquel(dir1, dir2) - Invalid direction value (dir1)") end
	if not Direction.isValid(dir2) then return error("Direction.isEquel(dir1, dir2) - Invalid direction value (dir2)") end
	return dir1.dx == dir2.dx and dir1.dy == dir2.dy
end

function Direction.turnLeft(direction)
	if not Direction.isValid(direction) then return error("Direction.turnLeft(direction) - Invalid direction value") end
	return Direction.new(-direction.dy, direction.dx)
end

function Direction.turnRight(direction)
	if not Direction.isValid(direction) then return error("Direction.turnRight(direction) - Invalid direction value") end
	return Direction.new(direction.dy, -direction.dx)
end

function Direction.turnAround(direction)
	if not Direction.isValid(direction) then return error("Direction.turnAround(direction) - Invalid direction value") end
	return Direction.new(-direction.dx, -direction.dy)
end

function Direction.getSide(direction, dx, dy, dz)
	if not Direction.isValid(direction) then return error("Direction.getSide(direction, dx, dy, dz) - Invalid direction value") end

	-- does not work on z axis
	if type(dz) ~= "number" or dz ~= 0 then return nil end

	-- make direction of differences between self and target
	local targetDirection = Direction.new(dx, dy)

	-- check front and back
	if Direction.isEquel(direction, targetDirection) then return "front" end
	if Direction.isEquel(Direction.turnAround(direction), targetDirection) then return "back" end

	-- check left and right
	if Direction.isEquel(Direction.turnLeft(direction), targetDirection) then return "left" end
	if Direction.isEquel(Direction.turnRight(direction), targetDirection) then return "right" end

	-- not found, most likely further away
	return nil
end

function Direction.toString(direction)
	if not Direction.isValid(direction) then return error("Direction.toString(direction) - Invalid direction value") end

	if     direction.dx ==  0 and direction.dy ==  1 then return "north"
	elseif direction.dx ==  0 and direction.dy == -1 then return "south"
	elseif direction.dx == -1 and direction.dy ==  0 then return "west"
	elseif direction.dx ==  1 and direction.dy ==  0 then return "east"
	else
		return "unknown"
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
return Direction