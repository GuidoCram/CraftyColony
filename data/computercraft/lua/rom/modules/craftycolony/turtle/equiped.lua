-- define module
local Equiped = {}

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


  Keeps track of items equipped on the turtle's left and right sides.
  Provides helpers to equip/unequip and query current equipment.

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
	moduleName  = "Equiped",

	-- lifecycle
	initialized = false,

	-- current known equipment; store minimal info for each side
	left  = nil,   -- e.g., { name = "minecraft:diamond_pickaxe" }
	right = nil,   -- e.g., { name = "minecraft:torch" }
}

--[[
                      _       _        _       _ _
                     | |     | |      (_)     (_) |
  _ __ ___   ___   __| |_   _| | ___   _ _ __  _| |_
 | '_ ` _ \ / _ \ / _` | | | | |/ _ \ | | '_ \| | __|
 | | | | | | (_) | (_| | |_| | |  __/ | | | | | | |_
 |_| |_| |_|\___/ \__,_|\__,_|_|\___| |_|_| |_|_|\__|

--]]

local function init()
	-- fetch persisted data
	local data = CoreData.getData(db.moduleName)

	-- adopt stored values if present
	if data.left  ~= nil then db.left  = data.left end
	if data.right ~= nil then db.right = data.right end

	-- ready
	db.initialized = true
end

local function saveDB()
	CoreData.setData(db.moduleName, { left = db.left, right = db.right })
end

--[[
  _                 _
 | |               | |
 | | ___   ___ __ _| |
 | |/ _ \ / __/ _` | |
 | | (_) | (_| (_| | |
 |_|\___/ \___\__,_|_|

--]]

local function ensure()
	if not turtle then error("Equiped: turtle API not available") end
	if not db.initialized then init() end
end

local function sideKey(side)
	if side == "left" or side == "right" then return side end
	error("Equiped: invalid side, expected 'left' or 'right'")
end

-- Determine the name that will be equipped based on the currently selected slot
local function currentSelectedItemName()
	local detail = turtle.getItemDetail()
	return detail and detail.name or nil
end

-- Generic equip/unequip primitive; when slot has an item, this equips it to the side;
-- when slot is empty, it unequips whatever is on that side into the selected slot (swap behavior).
local function doEquip(side, slot, intent)
	ensure()

	-- optionally select slot
	if slot ~= nil then
		if type(slot) ~= "number" or slot % 1 ~= 0 or slot < 1 or slot > 16 then
			error("Equiped." .. side .. ": invalid slot (1-16)")
		end
		turtle.select(slot)
	end

	-- remember what we're about to equip from inventory (if any)
	local incomingName = currentSelectedItemName()

	-- enforce intent semantics
	if intent == "equip" and not incomingName then
		return false, "selected slot is empty; cannot equip"
	elseif intent == "unequip" and incomingName then
		return false, "selected slot not empty; cannot unequip"
	end

	-- perform equip swap
	local ok, err
	if side == "left" then
		ok, err = turtle.equipLeft()
	else
		ok, err = turtle.equipRight()
	end
	if not ok then return false, (err or "equip failed") end

	-- if intent is equip, we equipped an item from inventory; if unequip, side is now empty
	if intent == "equip" then
		db[side] = { name = incomingName }
	else
		db[side] = nil
	end

	saveDB()
	return true, db[side]
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

-- Query current known equipment
function Equiped.get(side)
	if not db.initialized then init() end
	if side == nil then return { left = db.left, right = db.right } end
	return db[sideKey(side)]
end

function Equiped.getLeft()
	if not db.initialized then init() end
	return db.left
end

function Equiped.getRight()
	if not db.initialized then init() end
	return db.right
end

-- Equip helpers; if slot is provided, we select it first
function Equiped.equipLeft(slot)
	return doEquip("left", slot, "equip")
end

function Equiped.equipRight(slot)
	return doEquip("right", slot, "equip")
end

-- Unequip helpers; ensures the selected slot is empty (recommended) and swaps the current tool into it
function Equiped.unequipLeft(slot)
	return doEquip("left", slot, "unequip")
end

function Equiped.unequipRight(slot)
	return doEquip("right", slot, "unequip")
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
return Equiped
