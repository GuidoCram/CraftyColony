-- adjust package path to include crafty colony modules
-- package.path = package.path..";/rom/modules/craftycolony/?;/rom/modules/craftycolony/?.lua"
package.path = package.path..";/rom/modules/?;/rom/modules/?.lua"



-- import crafty colony CoreSystem
local CoreAction	= require("craftycolony.core.coreaction")
local CoreSystem	= require("craftycolony.core.coresystem")
-- local CoreUtilities	= require("craftycolony.core.coreutilities")
-- local Inventory		= require("craftycolony.turtle.inventory")
-- local Equiped		= require("craftycolony.turtle.equiped")
local Inventory		= require("craftycolony.turtle.inventory")
local Move			= require("craftycolony.turtle.move")

local Direction		= require("craftycolony.utilities.direction")

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

	Move.setLocation({x=3, y=2, z=0})
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

	-- print the status of the Forester module
	if 1 then
		CoreAction.addActivity(Forester.harvestForest, nil, "normal", weAreDone, "Log Forester status")
		while not done do print("current time: "..os.date("%H:%M:%S")) sleep(7) end
	end

	local data = turtle.getEquippedLeft()
	writeFileSync("/startup_log.txt", "a", "turtle.getEquippedLeft()\n")
	writeFileSync("/startup_log.txt", "a", textutils.serialize(data).."\n\n")

	data = turtle.getEquippedRight()
	writeFileSync("/startup_log.txt", "a", "turtle.getEquippedRight()\n")
	writeFileSync("/startup_log.txt", "a", textutils.serialize(data).."\n")
end

-- let's go
CoreSystem.run(testCallback)

