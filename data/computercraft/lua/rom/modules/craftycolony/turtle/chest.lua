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
	local chestSize	= chest.size()
	local itemList	= chest.list()

	-- just move everything to the back, ignore errors
	for source = chestSize - 1, 1, -1 do

		-- anything in this slot?
		if itemList[source] and itemList[source].count then

			-- transfer to whatever is allowed
			for target = chestSize, source + 1, -1 do

				-- get details of the target slot
				local details = chest.getItemDetail(target)

				-- check if we can transfer to this slot, then transfer the maximum possible
				if not itemList[target] or (itemList[target].name == itemList[source].name and details.count < details.maxCount) then

					-- if we don't have a target, that is bad so we better simulate a target with count 0
					details = chest.getItemDetail(source)
					details.count = 0

					-- if we have no target, that is bad so we better prevent that by adding it with count 0
					if not itemList[target] then itemList[target] = { name = itemList[source].name, count = 0, maxCount = details.maxCount } end

					-- calc amount to transfer
					local amount = math.min( itemList[source].count, details.maxCount - details.count )

					-- actually transfer the items
					chest.pushItems(peripheral.getName(chest), source, amount, target)

					-- update target
					itemList[target].count	= itemList[target].count + amount

					-- update source
					itemList[source].count = itemList[source].count - amount
					if itemList[source].count <= 0 then itemList[source] = nil break end
				end
			end
		end
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
