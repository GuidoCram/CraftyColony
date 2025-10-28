-- define module
local Location = {}

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
--	dbFilename		= "/craftycolony/locationdb.json",
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

function Location.new(x, y, z)
	return {
		x = x or 0,
		y = y or 0,
		z = z or 0
	}
end

function Location.isValid(location)
	return type(location) == "table"
	   and type(location.x) == "number"
	   and type(location.y) == "number"
	   and type(location.z) == "number"
end

function Location.clone(location)
	-- check parameters
	if not Location.isValid(location) then return nil, "invalid location" end

	return Location.new(location.x, location.y, location.z)
end

function Location.equals(loc1, loc2)
	-- check parameters
	if not Location.isValid(loc1) then return nil, "invalid location" end
	if not Location.isValid(loc2) then return nil, "invalid location" end

	return loc1.x == loc2.x and loc1.y == loc2.y and loc1.z == loc2.z
end

function Location.up(location, n)
	-- check parameters
	if not Location.isValid(location) then return nil, "invalid location" end
	if type(n) ~= "number" then n = 1 end

	location.z = location.z + n
	return location
end

function Location.down(location, n)
	-- check parameters
	if not Location.isValid(location) then return nil, "invalid location" end
	if type(n) ~= "number" then n = 1 end

	location.z = location.z - n
	return location
end

function Location.forward(location, n, direction)
	-- check parameters
	if not Location.isValid(location) then return nil, "invalid location" end
	if type(n) ~= "number" then n = 1 end

	location.x = location.x + direction.dx * n
	location.y = location.y + direction.dy * n
	return location
end

function Location.back(location, n, direction)
	if not Location.isValid(location) then return nil, "invalid location" end
	if type(n) ~= "number" then n = 1 end

	location.x = location.x - direction.dx * n
	location.y = location.y - direction.dy * n
	return location
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
return Location