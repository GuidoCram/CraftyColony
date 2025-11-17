-- adjust package path to include crafty colony modules
-- package.path = package.path..";/rom/modules/craftycolony/?;/rom/modules/craftycolony/?.lua"
package.path = package.path..";/rom/modules/?;/rom/modules/?.lua"



-- import crafty colony CoreSystem
local CoreAction	= require("craftycolony.core.coreaction")
local CoreSystem	= require("craftycolony.core.coresystem")
-- local CoreUtilities	= require("craftycolony.core.coreutilities")
-- local Inventory		= require("craftycolony.turtle.inventory")
-- local Equiped		= require("craftycolony.turtle.equiped")
local Chest			= require("craftycolony.turtle.chest")
local Inventory		= require("craftycolony.turtle.inventory")
local Move			= require("craftycolony.turtle.move")

local Direction		= require("craftycolony.utilities.direction")
local Location		= require("craftycolony.utilities.location")

local Forester		= require("craftycolony.autonomous.forester")

-- for writing files now
local function writeFileSync(path, mode, data)

	-- check the data, serialize if needed
	if type(data) == "table" then data = textutils.serialize(data) end

    -- check the mode. Anything else then write mode will be handled as append
    if mode ~= "w" then mode = "a" end

    -- now open the file
    local file = fs.open(path, mode)

    -- only when we could open the file
    if file then
        file.write(data)
        file.close()
    end
end

local done = false

local function weAreDone()
	done = true
end

local function testCallback()

	writeFileSync("/startup_log.txt", "w", "Startup callback executed at "..os.date("%Y-%m-%d %H:%M:%S").."\n\n")

	Move.setLocation({x=9, y=-2, z=1})
	local chestLocation = Location.new(10,-2,1)  -- x=10, y=-2, z=1
	local chest = Chest.wrap(chestLocation)

	print("Accessing chest at "..Location.toString(chestLocation))
	print("chest = "..tostring(chest))

	print("The name of the chest peripheral is: "..peripheral.getName(chest))
	print("The size of the chest is: "..chest.size().." slots")

	-- lets organize the chest
	Chest.organize(chest)

	-- list items in chest
	local items = chest.list()
	writeFileSync("/startup_log.txt", "a", "Items in chest at "..Location.toString(chestLocation)..":\n")
	writeFileSync("/startup_log.txt", "a", textutils.serialize(items).."\n\n")

	-- see what the limit it
	local details = chest.getItemDetail(5)
	writeFileSync("/startup_log.txt", "a", "Item details in chest at "..Location.toString(chestLocation).." slot 5:\n")
	writeFileSync("/startup_log.txt", "a", textutils.serialize(details).."\n\n")

	-- see what the limit it
	local limits = chest.getItemLimit(5)
	writeFileSync("/startup_log.txt", "a", "Item limits in chest at "..Location.toString(chestLocation).." slot 5:\n")
	writeFileSync("/startup_log.txt", "a", tostring(limits).."\n\n")

--	Move.setLocation({x=3, y=2, z=0})
--	Move.setDirection("north")
--	Move.goTo({{x=3, y= 2, z=0}})

--	local north = Direction.new("north")
--	Move.turnTo(north)  -- face north
--	print(textutils.serialize(north))
--[[
	local north = Direction.new("north")

	local currentDirection = Move.getDirection()
	print("Current direction: "..Direction.toString(currentDirection))

	Move.turnRight()
	local currentDirection = Move.getDirection()
	print("after turning right: "..Direction.toString(currentDirection))

	Move.turnRight()
	local currentDirection = Move.getDirection()
	print("after turning right: "..Direction.toString(currentDirection))

	Move.turnRight()
	local currentDirection = Move.getDirection()
	print("after turning right: "..Direction.toString(currentDirection))

	Move.turnTo(north)  -- face north
	local currentDirection = Move.getDirection()
	print("after turning to north: "..Direction.toString(currentDirection))
--]]

	-- run the Forester module
	if 0 == 1 then
		CoreAction.addActivity(Forester.harvestForest, nil, "normal", weAreDone, "Log Forester status")
		while not done do print("current time: "..os.date("%H:%M:%S")) sleep(7) end
	end

--	local data = turtle.getEquippedLeft()
--	writeFileSync("/startup_log.txt", "a", "turtle.getEquippedLeft()\n")
--	writeFileSync("/startup_log.txt", "a", textutils.serialize(data).."\n\n")

--	data = turtle.getEquippedRight()
--	writeFileSync("/startup_log.txt", "a", "turtle.getEquippedRight()\n")
--	writeFileSync("/startup_log.txt", "a", textutils.serialize(data).."\n")
end

-- let's go
CoreSystem.run(testCallback)

