-- define module
-- Public API overview (empty stubs; real implementations are defined below)
local Chest = {
	-- Wrap a chest at the given location as a peripheral if it's adjacent to the turtle.
	-- returns peripheral object or (nil, error)
	wrap = function(chestLocation) end,

	-- Get a list of items with their counts from the chest peripheral.
	-- returns table: itemName = count
	getItemCounts = function(chest) end,

	-- Organize items in the given chest peripheral.
	-- no return
	organize = function(chest) end
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
	local side				= Direction.getSide(currentDirection, chestLocation.x - currentLocation.x, chestLocation.y - currentLocation.y, chestLocation.z - currentLocation.z)

	-- did we get anything?
	if side then return peripheral.wrap(side)
	else return nil, "chest not found as neighbor"
	end
end

-- get a list of items with their counts
-- returns table: itemName = count
function Chest.getItemCounts(chest)

	-- build counts table
	local counts = {}
	local items = chest.list()

	for _, detail in pairs(items) do

		-- check for item detail
		if type(detail) == "table" and type(detail.name) == "string" and detail.name then counts[detail.name] = (counts[detail.name] or 0) + detail.count end
	end

	-- done
	return counts
end

-- organize the inventory by grouping items together
function Chest.organize(chest)

	-- variables
	local chestSize = chest.size()

	-- just move everything to the back, ignore errors
	for source = 1, chestSize do

		-- anything in this slot?
		if db.slots[source] and db.slots[source].count then

			-- transfer to whatever is allowed
			for target = chestSize, source + 1, -1 do

				-- check if we can transfer to this slot, then transfer the maximum possible
				if not db.slots[target] or (db.slots[target].name == db.slots[source].name and db.slots[target].count < db.slots[target].maxCount) then

					-- if we have no target, that is bad so we better prevent that by adding it with count 0
					if not db.slots[target] then db.slots[target] = { name = db.slots[source].name, count = 0, maxCount = db.slots[source].maxCount } end

					-- calc amount to transfer
					local amount = math.min( db.slots[source].count, db.slots[source].maxCount - db.slots[target].count )

					-- actually transfer the items
					if turtle.getSelectedSlot() ~= source then turtle.select(source) end
					turtle.transferTo(target, amount)

					-- update target
					db.slots[target].count	= db.slots[target].count + amount

					-- update source
					db.slots[source].count = db.slots[source].count - amount
					if db.slots[source].count <= 0 then db.slots[source] = nil break end
				end
			end
		end
	end

	-- done
	turtle.select(16)

	-- save the database
	saveDB()
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
