-- define module
local Direction = {}

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

local function validDirection(direction)
	return (type(direction) == "table") and (type(direction.dx) == "number") and (type(direction.dy) == "number") and (math.abs(direction.dx + direction.dy) == 1) and (direction.dx * direction.dy == 0)
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

function Direction.new(dx, dy)

	-- check input
	if (type(dx) ~= "number") or (type(dy) ~= "number") or (math.abs(dx + dy) ~= 1) or (dx * dy ~= 0) then error("Direction.new(dx, dy) - Invalid direction values: (" .. tostring(dx) .. ", " .. tostring(dy) .. ")") end

	-- klaar
	return {
		dx = dx,
		dy = dy
	}
end

function Direction.clone(direction)
	if not validDirection(direction) then return error("Direction.clone(direction) - Invalid direction value") end
	return Direction.new(direction.dx, direction.dy)
end

function Direction.equals(dir1, dir2)
	if not validDirection(dir1) then return error("Direction.equals(dir1, dir2) - Invalid direction value (dir1)") end
	if not validDirection(dir2) then return error("Direction.equals(dir1, dir2) - Invalid direction value (dir2)") end
	return dir1.dx == dir2.dx and dir1.dy == dir2.dy
end

function Direction.left(direction)
	if not validDirection(direction) then return error("Direction.left(direction) - Invalid direction value") end
	return Direction.new(-direction.dy, direction.dx)
end

function Direction.right(direction)
	if not validDirection(direction) then return error("Direction.right(direction) - Invalid direction value") end
	return Direction.new(direction.dy, -direction.dx)
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