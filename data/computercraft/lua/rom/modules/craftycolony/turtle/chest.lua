-- define module
-- Public API overview (empty stubs; real implementations are defined below)
local Chest = {
	-- Wrap a chest at the given location as a peripheral if it's adjacent to the turtle.
	-- returns peripheral object or (nil, error)
	wrap = function(chestLocation) end,
}

-- imports
local CoreData	= require("craftycolony.core.coredata")

local Inventory	= require("craftycolony.turtle.inventory")
local Move		= require("craftycolony.turtle.move")

local Direction	= require("craftycolony.utilities.direction")
local Location	= require("craftycolony.utilities.location")
local Logger	= require("craftycolony.utilities.logger")


--[[
      _                     _       _   _
     | |                   (_)     | | (_)
   __| | ___  ___  ___ _ __ _ _ __ | |_ _  ___  _ __
  / _` |/ _ \/ __|/ __| '__| | '_ \| __| |/ _ \| '_ \
 | (_| |  __/\__ \ (__| |  | | |_) | |_| | (_) | | | |
  \__,_|\___||___/\___|_|  |_| .__/ \__|_|\___/|_| |_|
                             | |
                             |_|


  For interacting with chests: storing and retrieving items.

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
	-- module identity
	moduleName  = "Chest",

	-- lifecycle
	initialized = false,

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


-- basic init function to setup the database
-- no return
local function init()

	-- ready
	db.initialized = true
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

function Chest.wrap(chestLocation)

	-- check for valid location
	if not Location.isValid(chestLocation) then Logger.logError("Chest.wrap: invalid chest location") return nil end

	-- get current location and direction
	local currentLocation	= Move.getLocation()

	-- maybe top
	if Location.isTop(   currentLocation, chestLocation) then return peripheral.wrap("top") end
	if Location.isBottom(currentLocation, chestLocation) then return peripheral.wrap("bottom") end

	-- hopefully on one of the sides
	local currentDirection	= Move.getDirection()
	local side				= Direction.getSide(currentDirection, currentLocation, chestLocation)

	-- did we get anything?
	if side then return peripheral.wrap(side)
	else return nil, "chest not found as neighbor"
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
return Chest
