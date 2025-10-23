-- define module
local Inventory = {}

-- imports
local CoreData = require("craftycolony.core.coredata")
local Logger   = require("craftycolony.utilities.logger")

--[[
      _                     _       _   _
     | |                   (_)     | | (_)
   __| | ___  ___  ___ _ __ _ _ __ | |_ _  ___  _ __
  / _` |/ _ \/ __|/ __| '__| | '_ \| __| |/ _ \| '_ \
 | (_| |  __/\__ \ (__| |  | | |_) | |_| | (_) | | | |
  \__,_|\___||___/\___|_|  |_| .__/ \__|_|\___/|_| |_|
                             | |
                             |_|


  Turtle inventory helper: scans slots, finds items by name,
  and exposes helpers to select or retrieve counts.
  This module does not move items; it only inspects and selects.

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
	moduleName  = "Inventory",

	-- lifecycle
	initialized = false,

	-- last known slots snapshot: [1..16] = itemDetail|nil
	slots      = {},
	lastScan   = nil, 	-- os.epoch() / 3600 timestamp (ticks since the Minecraft game is created)
	detailed   = false, -- whether the last scan was detailed or not
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

-- init of this module, reading data from CoreData
local function init()

	-- restore cached snapshot if present (optional)
	local data = CoreData.getData(db.moduleName)
	if type(data) == "table" then
		if type(data.slots) == "table" then db.slots = data.slots end
		if type(data.lastScan) == "number" then db.lastScan = data.lastScan end
	end
	db.initialized = true
end

-- saves the database to CoreData
local function saveDB()
	CoreData.setData(db.moduleName, { slots = db.slots, lastScan = db.lastScan })
end

-- Perform an inventory scan, optionally detailed
-- returns a shallow copy of the slots table
local function scan(detailed)

	-- no ensure here, since this is called by ensure

	-- convert detailed to boolean
	detailed = detailed and true or false

	-- scan slot by slot
	local slots = {}
	for slot = 1, 16 do

		-- get the details
		local detail = turtle.getItemDetail(slot, detailed)
		if detail then

			-- normalize fields we rely on
			slots[slot] = {

				-- always available
				name        = detail.name,
				count       = detail.count,

				-- only when detailed is true, and maybe not even then
				damage		= detail.damage,
				displayName	= detail.displayName,
				maxCount	= detail.maxCount,
			}
		else

			-- nothing in this slot
			slots[slot] = nil
		end
	end

	-- store snapshot
	db.slots	= slots
	db.lastScan = os.epoch() / 3600 -- timestamp in ticks since the Minecraft game is created
	db.detailed = detailed
	saveDB()
end

-- easy ensure function used by other functions
function ensure(rescan, detailed)
	if not turtle then error("Inventory: turtle API not available") end
	if not db.initialized then init() end

	if rescan or not db.lastScan then scan(detailed) end
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


-- find an empty slot
-- returns true if successfull, false if not found
function Inventory.selectEmpty(rescan)

	-- to be sure we're ready
	ensure(rescan, false)

	-- loop the slots looking for empty slot
	for slot = 1, 16 do

		-- check empty
		if not db.slots[slot] then

			-- select and return
			turtle.select(slot)
			return true
		end
	end

	-- no empty slot found
	return false
end

-- select any slot containing the item by name;
-- returns true if successfull, false if not found
function Inventory.selectItem(name, rescan)

	-- to be sure we're ready
	ensure(rescan, false)

	-- loop the slots looking for empty slot
	for slot = 1, 16 do

		-- check for name match
		if db.slots[slot].name == name then

			-- select and return
			turtle.select(slot)
			return true
		end
	end

	-- item not found
	return false
end

-- get a list of items with their counts
-- returns table: itemName = count
function Inventory.getItemCounts(rescan)

	-- to be sure we're ready
	ensure(rescan, false)

	-- build counts table
	local counts = {}
	for slot = 1, 16 do

		-- get the details of this slot
		local detail = db.slots[slot]

		-- check for item detail
		if type(detail) == "table" and type(detail.name) == "string" and detail.name then counts[detail.name] = (counts[detail.name] or 0) + detail.count end
	end

	-- done
	return counts
end

-- organize the inventory by grouping items together
function Inventory.organize(rescan)

	-- to be sure we're ready (always rescan if we lack detailed data)
	ensure(rescan or db.detailed == false, true)

	-- just move everything to the back, ignore errors
	for source = 1, 15 do

		-- anything in this slot?
		if db.slots[source] and db.slots[source].count then

			-- transfer to whatever is allowed
			for target = 16, source + 1, -1 do

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
return Inventory
