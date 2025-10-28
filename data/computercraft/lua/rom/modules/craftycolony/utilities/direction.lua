-- define module
local Direction = {}

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
	if not Direction.isValid(direction) then return error("Direction.clone(direction) - Invalid direction value") end
	return Direction.new(direction.dx, direction.dy)
end

function Direction.equals(dir1, dir2)
	if not Direction.isValid(dir1) then return error("Direction.equals(dir1, dir2) - Invalid direction value (dir1)") end
	if not Direction.isValid(dir2) then return error("Direction.equals(dir1, dir2) - Invalid direction value (dir2)") end
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