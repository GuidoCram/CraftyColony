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
	lastScan   = nil, -- os.clock() timestamp
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
	-- restore cached snapshot if present (optional)
	local data = CoreData.getData(db.moduleName)
	if type(data) == "table" then
		if type(data.slots) == "table" then db.slots = data.slots end
		if type(data.lastScan) == "number" then db.lastScan = data.lastScan end
	end
	db.initialized = true
end

local function saveDB()
	CoreData.setData(db.moduleName, { slots = db.slots, lastScan = db.lastScan })
end

local function ensure()
	if not turtle then error("Inventory: turtle API not available") end
	if not db.initialized then init() end
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

-- Perform an inventory scan, optionally detailed
-- returns a shallow copy of the slots table
function Inventory.scan(detailed)
	ensure()

	local slots = {}
	for slot = 1, 16 do
		local detail = turtle.getItemDetail(slot, detailed and true or false)
		if detail then
			-- Normalize fields we rely on
			slots[slot] = {
				name        = detail.name,
				count       = detail.count,
				displayName = detail.displayName,
				damage      = detail.damage, -- may be nil on some versions
			}
		else
			slots[slot] = nil
		end
	end

	-- store snapshot
	db.slots = slots
	db.lastScan = os.clock()
	saveDB()

	-- return copy
	local copy = {}
	for i = 1, 16 do copy[i] = slots[i] end
	return copy
end

-- get last known snapshot (may be stale)
function Inventory.getSlots()
	if not db.initialized then init() end
	local copy = {}
	for i = 1, 16 do copy[i] = db.slots[i] end
	return copy
end

function Inventory.getSlot(slot)
	if not db.initialized then init() end
	if type(slot) ~= "number" or slot % 1 ~= 0 or slot < 1 or slot > 16 then error("Inventory.getSlot: invalid slot") end
	return db.slots[slot]
end

-- find first slot containing an item with the exact name
function Inventory.findFirstByName(name, rescan)
	ensure()
	if rescan or not db.lastScan then Inventory.scan(false) end
	for slot = 1, 16 do
		local it = db.slots[slot]
		if it and it.name == name then return slot, it.count end
	end
	return nil, 0
end

-- find all slots for a name; returns { {slot, count}, ... }, totalCount
function Inventory.findAllByName(name, rescan)
	ensure()
	if rescan or not db.lastScan then Inventory.scan(false) end
	local results = {}
	local total = 0
	for slot = 1, 16 do
		local it = db.slots[slot]
		if it and it.name == name then
			table.insert(results, { slot = slot, count = it.count })
			total = total + (it.count or 0)
		end
	end
	return results, total
end

-- total count of an item name
function Inventory.totalCount(name, rescan)
	local _, total = Inventory.findAllByName(name, rescan)
	return total
end

-- find first empty slot
function Inventory.firstEmptySlot(rescan)
	ensure()
	if rescan or not db.lastScan then Inventory.scan(false) end
	for slot = 1, 16 do
		if not db.slots[slot] then return slot end
	end
	return nil
end

-- select first slot containing the item by name; returns slot or false,err
function Inventory.selectFirstByName(name, rescan)
	ensure()
	local slot = select(1, Inventory.findFirstByName(name, rescan))
	if not slot then return false, "item not found: " .. tostring(name) end
	turtle.select(slot)
	return slot
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
