-- define module
-- Public API overview (empty stubs; real implementations are defined below)
local Location = {
	-- Create a new location table with x, y, z coordinates (defaults to 0, 0, 0).
	-- returns {x, y, z}
	new = function(x, y, z) end,

	-- Validate a location table: { x = number, y = number, z = number }.
	-- returns boolean
	isValid = function(location) end,

	-- Check if loc1 is directly above loc2 (z + 1).
	-- returns boolean or nil, error
	isTop = function(loc1, loc2) end,

	-- Check if loc1 is directly below loc2 (z - 1).
	-- returns boolean or nil, error
	isBottom = function(loc1, loc2) end,

	-- Check if two locations are equal.
	-- returns boolean or nil, error
	isEqual = function(loc1, loc2) end,

	-- Clone a location table.
	-- returns {x, y, z} or nil, error
	clone = function(location) end,

	-- Move location up by n steps (default 1).
	-- returns {x, y, z} or nil, error
	up = function(location, n) end,

	-- Move location down by n steps (default 1).
	-- returns {x, y, z} or nil, error
	down = function(location, n) end,

	-- Move location forward by n steps (default 1) in the given direction.
	-- returns {x, y, z} or nil, error
	forward = function(location, n, direction) end,

	-- Move location backward by n steps (default 1) in the given direction.
	-- returns {x, y, z} or nil, error
	back = function(location, n, direction) end,

	-- Get all 6 neighboring locations (east, west, south, north, up, down).
	-- returns array of 6 locations or nil, error
	allNeighborLocations = function(location) end,

	-- Get the 4 horizontal neighboring locations (east, west, south, north).
	-- returns array of 4 locations or nil, error
	sideLocations = function(location) end,

	-- Convert location to string representation "(x,y,z)".
	-- returns string or nil, error
	toString = function(location) end,

	-- Parse a string "(x,y,z)" into a location table.
	-- returns {x, y, z} or nil, error
	fromString = function(str) end,
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

function Location.isTop(loc1, loc2)
	-- check parameters
	if not Location.isValid(loc1) then return nil, "invalid location" end
	if not Location.isValid(loc2) then return nil, "invalid location" end


	return loc1.x == loc2.x and loc1.y == loc2.y and loc1.z == loc2.z - 1
end

function Location.isBottom(loc1, loc2)

	-- use existing function
	return Location.isTop(loc2, loc1)
end

function Location.isEqual(loc1, loc2)
	-- check parameters
	if not Location.isValid(loc1) then return nil, "invalid location" end
	if not Location.isValid(loc2) then return nil, "invalid location" end

	return loc1.x == loc2.x and loc1.y == loc2.y and loc1.z == loc2.z
end

function Location.clone(location)
	-- check parameters
	if not Location.isValid(location) then return nil, "invalid location" end

	return Location.new(location.x, location.y, location.z)
end

function Location.up(location, n)
	-- check parameters
	if not Location.isValid(location) then return nil, "invalid location" end
	if type(n) ~= "number" then n = 1 end

	return Location.new(location.x, location.y, location.z + n)
end

function Location.down(location, n)
	-- check parameters
	if not Location.isValid(location) then return nil, "invalid location" end
	if type(n) ~= "number" then n = 1 end

	return Location.new(location.x, location.y, location.z - n)
end

function Location.forward(location, n, direction)
	-- check parameters
	if not Location.isValid(location) then return nil, "invalid location" end
	if type(n) ~= "number" then n = 1 end

	return Location.new(location.x + direction.dx * n, location.y + direction.dy * n, location.z)
end

function Location.back(location, n, direction)
	if not Location.isValid(location) then return nil, "invalid location" end
	if type(n) ~= "number" then n = 1 end

	return Location.new(location.x - direction.dx * n, location.y - direction.dy * n, location.z)
end

function Location.allNeighborLocations(location)
	-- check parameters
	if not Location.isValid(location) then return nil, "invalid location" end

	return {{x = location.x + 1, y = location.y,     z = location.z    }, -- east
			{x = location.x - 1, y = location.y,     z = location.z    }, -- west
			{x = location.x,     y = location.y + 1, z = location.z    }, -- south
			{x = location.x,     y = location.y - 1, z = location.z    }, -- north
			{x = location.x,     y = location.y,     z = location.z + 1}, -- up
			{x = location.x,     y = location.y,     z = location.z - 1}} -- down
end

function Location.sideLocations(location)
	-- check parameters
	if not Location.isValid(location) then return nil, "invalid location" end

	return {{x = location.x + 1, y = location.y,     z = location.z    }, -- east
			{x = location.x - 1, y = location.y,     z = location.z    }, -- west
			{x = location.x,     y = location.y + 1, z = location.z    }, -- south
			{x = location.x,     y = location.y - 1, z = location.z    }} -- north
end

function Location.toString(location)
	-- check parameters
	if not Location.isValid(location) then return nil, "invalid location" end

	-- return string representation
	return "("..location.x..","..location.y..","..location.z..")"
end

function Location.fromString(str)
	-- check parameters
	if type(str) ~= "string" then return nil, "invalid string" end

	-- try to parse
	local x, y, z = string.match(str, "^%s*%(%s*(-?%d+)%s*,%s*(-?%d+)%s*,%s*(-?%d+)%s*%)%s*$")
	if x == nil or y == nil or z == nil then return nil, "string does not represent a location" end

	-- return location
	return Location.new(tonumber(x), tonumber(y), tonumber(z))
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