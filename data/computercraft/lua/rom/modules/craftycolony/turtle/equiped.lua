-- define module
local Equiped = {}

-- imports
local CoreData	= require("craftycolony.core.coredata")
local Logger	= require("craftycolony.utilities.logger")

local Inventory	= require("craftycolony.turtle.inventory")

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

	-- current known equipment
	left  = nil,   -- e.g., "minecraft:diamond_pickaxe", "minecraft:crafting_table"
	right = nil,   -- e.g., "computercraft:wireless_modem"
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
	-- fetch persisted data
	local data = CoreData.getData(db.moduleName)

	-- adopt stored values if present
	if type(data) == "table" then
		db.left  = data.left
		db.right = data.right
	else
		-- check left
		data = turtle.getEquippedLeft()
		if type(data) == "table" then db.left = data.name end

		-- check right
		data = turtle.getEquippedRight()
		if type(data) == "table" then db.right = data.name end
	end


	-- ready
	db.initialized = true
end

-- saves the database to CoreData
-- no return
local function saveDB()

	-- store current data
	CoreData.setData(db.moduleName, { left = db.left, right = db.right })
end

-- helper to ensure this module is allowed to run on this device
-- no return
local function ensure()
	if not turtle then error("Equiped: turtle API not available") end
	if not db.initialized then init() end
end

local function setLeft(item)
	db.left = item
	saveDB()
end

local function setRight(item)
	db.right = item
	saveDB()
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

-- check if item is equiped on either side "minecraft:diamond_pickaxe"; passing nil checks for a free side
-- returns boolean (true|false)
function Equiped.isEquiped(item)

	-- always be sure
	ensure()

	-- check with db
	return db.left == item or db.right == item
end

-- basic function to equip items
-- accepts one or two item names
-- returns restore table if changes were made, nil if no changes, or false + error message on failure
function Equiped.equip(first, second)

	-- check parameter types
	if type(first)  ~= "string"								then return false, "Equiped.equip(): first item name must be a string, it is a "..type(first) end
	if type(second) ~= "string" and type(second) ~= "nil"	then return false, "Equiped.equip(): second item name must be a string or nil, it is a "..type(second) end

	-- always be sure
	ensure()

	-- capture state before any changes
	local before = { left = db.left, right = db.right }
	local changed = false

	-- check what we should do left and right
	local leftItem, rightItem = first, second	-- sets default

	-- swap the default based on database if usefull
	if rightItem == db.left or leftItem == db.right then

		-- swap
		leftItem, rightItem = second, first

	else
		-- check for empty spot, make sure it's used
		if (leftItem ~= nil and db.right == nil) or (rightItem ~= nil and db.left == nil) then

			-- swap
			leftItem, rightItem = second, first
		end
	end

	-- equip left if needed
	if leftItem ~= db.left and leftItem ~= nil then

		local success = Inventory.selectItem(leftItem, true)
		if not success then return false, "Equiped.equip(): item not found in inventory: " .. leftItem end

		-- we take the left side
		local ok, err = turtle.equipLeft()
		if not ok then return false, "Equiped.equip() - turtle.equipLeft() error: " .. tostring(err) end

		-- still here? Then the equip to the left side worked
		setLeft(leftItem)

		-- mark as changed
		changed = true
	end

	-- equip right if needed
	if rightItem ~= db.right and rightItem ~= nil then

		local success = Inventory.selectItem(rightItem, true)
		if not success then return false, "Equiped.equip(): item not found in inventory: " .. rightItem end

		-- we take the right side
		local ok, err = turtle.equipRight()
		if not ok then return false, "Equiped.equip() - turtle.equipRight() error: " .. tostring(err) end

		-- still here? Then the equip to the right side worked
		setRight(rightItem)

		-- mark as changed
		changed = true
	end

	-- return restore table only if changes were made
	if changed	then return before
				else return nil
	end
end

-- free up an items from a side (unequip)
-- returns boolean (true|false), errorMessage
function Equiped.free(item)

	-- is the item equiped? (this also ensures initialization)
	if not Equiped.isEquiped(item) then return false, "item "..item.." not equipped" end

	-- get a free slot
	local ok = Inventory.selectEmpty(true)
	if not ok then return false, "Equiped.free("..item.."): no empty inventory slot available" end

	-- left side?
	if db.left == item then

		-- remove it
		ok = turtle.equipLeft()

		-- update database?
		if ok then setLeft(nil) end

		-- done
		return ok

	-- right side?
	elseif db.right == item then

		-- remove it
		ok = turtle.equipRight()

		-- update database?
		if ok then setRight(nil) end

		-- done
		return ok

	end
end


-- function restores the equipment based on a restore table previously returned by Equiped.equip()
-- returns nothing
function Equiped.restore(restoreTable)

	-- check paramters first
	if type(restoreTable) ~= "table" then error("Equiped.restore(): restoreTable must be a table, it is a "..type(restoreTable)) end

	-- always be sure
	ensure()

	-- do this twice, since the tool for one side may be on the other side and there is not much free space
	for i = 1, 2 do

		-- unequip left?
		if (restoreTable.left == nil or restoreTable.left ~= db.left) and db.left ~= nil then

			-- find a free inventory spot
			local ok = Inventory.selectEmpty()
			if ok then

				-- ok, we have a free spot
				local ok, err = turtle.equipLeft()
				if ok then setLeft(nil) end
			end
		end

		-- unequip right?
		if (restoreTable.right == nil or restoreTable.right ~= db.right) and db.right ~= nil then

			-- find a free inventory spot
			local ok = Inventory.selectEmpty()
			if ok then

				-- ok, we have a free spot
				local ok, err = turtle.equipRight()
				if ok then setRight(nil) end
			end
		end

		-- equip something on the left side?
		if restoreTable.left ~= nil and restoreTable.left ~= db.left then

			-- find the requested item in the inventory
			local ok = Inventory.selectItem(restoreTable.left)
			if ok then

				-- ok, we have the item we need
				local ok, err = turtle.equipLeft()
				if ok then setLeft(restoreTable.left) end
			end
		end

		-- equip something on the right side?
		if restoreTable.right ~= nil and restoreTable.right ~= db.right then

			-- find the requested item in the inventory
			local ok = Inventory.selectItem(restoreTable.right)
			if ok then

				-- ok, we have the item we need
				local ok, err = turtle.equipRight()
				if ok then setRight(restoreTable.right) end
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
return Equiped
