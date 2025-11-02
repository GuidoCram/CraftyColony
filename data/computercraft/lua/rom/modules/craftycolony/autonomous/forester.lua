-- define module
local Forester = {}

-- imports
local CoreDisk	= require("craftycolony.core.coredisk")

local Equiped	= require("craftycolony.turtle.equiped")
local Inventory	= require("craftycolony.turtle.inventory")
local Move		= require("craftycolony.turtle.move")

local Direction	= require("craftycolony.utilities.direction")
local Location	= require("craftycolony.utilities.location")
local Timer		= require("craftycolony.utilities.timer")

--[[
      _                     _       _   _
     | |                   (_)     | | (_)
   __| | ___  ___  ___ _ __ _ _ __ | |_ _  ___  _ __
  / _` |/ _ \/ __|/ __| '__| | '_ \| __| |/ _ \| '_ \
 | (_| |  __/\__ \ (__| |  | | |_) | |_| | (_) | | | |
  \__,_|\___||___/\___|_|  |_| .__/ \__|_|\___/|_| |_|
                             | |
                             |_|


  This module implements the forrester role for turtles, which
  involves cutting down trees and collecting wood resources.

--]]

--[[
  Local Functions Overview:
  - initCallback(data) - Callback for loading saved data
  - init() - Initialize the forester module
  - harvestBirchCrownLeaves() - Harvest the crown leaves of a birch tree
  - forwardAndHarvestBirchLeaves(harvestAbove) - Move forward and harvest birch leaves
  - harvestBirchLeaves() - Harvest all leaves from a birch tree
  - harvestBirchTree() - Complete birch tree harvesting process
  - detectTree() - Detect if there's a tree in front
  - forwardThroughForest(n) - Move forward through the forest
  - forwardToNextTree(n) - Move forward to the next tree
  - walkForestRound() - Walk one complete round through the forest
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

	-- moduleName
	moduleName		= "Forester",

	-- is this module initialized?
	initialized		= false,

	-- data about our forest
	maxWidth		= 6,
	maxDepth		= 6,

	currentWidth	= 1,
	currentDepth	= 1,

	-- locations
	restLocation			= Location.new(3, 2,  0),
	startLocation			= Location.new(3, 2,  1),
	firstTreeLocation		= Location.new(3, 3,  1),
	saplingChestLocation	= Location.new(4, 1, -1),
	logChestLocation		= Location.new(5, 2, -1),
	charcoalChestLocation	= Location.new(5, 4, -1),

	-- directions
	restDirection			= Direction.new("north"), -- same as { dx = 0, dy = 1 }
	startDirection			= Direction.new("north"), -- same as { dx = 0, dy = 1 }

	-- fuel usage
	maxFuelPerTree		= 35,
	maxFuelBetweenTrees	= 6,

	-- state of the forest
	neverGrown		= {},
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

local function initCallback(data)
	-- did we get data?
	if type(data) == "table" then

		-- load data
		if type(data.currentWidth)	== "number" then db.currentWidth	= data.currentWidth end
		if type(data.currentDepth)	== "number" then db.currentDepth	= data.currentDepth end

	end

	-- update initialized
	db.initialized = true
end

local function init()

	-- read our data from disk (if any)
	CoreDisk.readFileIntoTable("/craftycolony/foresterdb.json", initCallback)

	-- update initialized
	db.initialized = true
end

local function harvestBirchCrownLeaves()

    -- get to the crown
    for i=1,2 do Move.up() turtle.digUp() end

    -- dig around
    for i=1,4 do turtle.dig() Move.turnRight() end

    -- back into position
    for i=1,2 do Move.down() end
end

local function forwardAndHarvestBirchLeaves(harvestAbove)

	-- make space in front of us
    turtle.dig()

	-- move forward
    Move.forward()

	-- some spots have leaves above us
    if harvestAbove then turtle.digUp() end

	-- all spots have leaves below us
    turtle.digDown()
end

local function harvestBirchLeaves()
--[[

561→2
↑↓↑9↓
↑↓0↑↓
↑7→8↓
4←←←3

--]]

	-- 0 → 1
    forwardAndHarvestBirchLeaves(true)
    forwardAndHarvestBirchLeaves(false)

	-- 1 → 2
    Move.turnRight()
    forwardAndHarvestBirchLeaves(false)
    forwardAndHarvestBirchLeaves(false)

	-- 2 → 3
    Move.turnRight()
    forwardAndHarvestBirchLeaves(false)
    forwardAndHarvestBirchLeaves(false)
    forwardAndHarvestBirchLeaves(false)
    forwardAndHarvestBirchLeaves(false)

	-- 3 → 4
    Move.turnRight()
    forwardAndHarvestBirchLeaves(false)
    forwardAndHarvestBirchLeaves(false)
    forwardAndHarvestBirchLeaves(false)
    forwardAndHarvestBirchLeaves(false)

	-- 4 → 5
    Move.turnRight()
    forwardAndHarvestBirchLeaves(false)
    forwardAndHarvestBirchLeaves(false)
    forwardAndHarvestBirchLeaves(false)
    forwardAndHarvestBirchLeaves(false)

	-- 5 → 6
    Move.turnRight()
    forwardAndHarvestBirchLeaves(false)

	-- 6 → 7
    Move.turnRight()
    forwardAndHarvestBirchLeaves(true)
    forwardAndHarvestBirchLeaves(true)
    forwardAndHarvestBirchLeaves(true)

	-- 7 → 8
    Move.turnLeft()
    forwardAndHarvestBirchLeaves(true)
    forwardAndHarvestBirchLeaves(true)

	-- 8 → 9
    Move.turnLeft()
    forwardAndHarvestBirchLeaves(true)
    forwardAndHarvestBirchLeaves(true)

	-- 9 → 0
    Move.turnLeft()		-- terug naar de 0-1 lijn
    Move.forward()		-- terug naar de 0-1 lijn
    Move.turnRight()	-- achteruit inparkeren
    Move.back()			-- achteruit inparkeren
end

local function harvestBirchTree()

	-- variables
    local height    = 1	-- starting height (we're one block above ground level)

    -- move forward to get to the base of the tree
    turtle.dig()
    Move.forward()
    turtle.digDown() -- remove the log at our feet

	-- this is the location where the sapling was planted, aperently the tree has grown
	db.neverGrown[Location.toString(Move.getLocation())] = nil

    -- move up until we see leaves
    while not turtle.inspect() do

        -- move up
        turtle.digUp()
        Move.up()

        -- keep track of height
        height = height + 1
    end

    -- eentje boven de eerste bladen staan
    turtle.digUp()
    Move.up()

    -- all the wood is gone (except for the top block), now the leaves
    harvestBirchLeaves()

    -- do we need the crown too?
	local inventory = Inventory.getItemCounts()
    if inventory["minecraft:birch_sapling"] < 2 then harvestBirchCrownLeaves()	-- move to the top and harvest leaves (5 leaves, not much chance for sapling but better than nothing)
												else turtle.digUp() end			-- remove topblock (it's still there to prevent leaves from decaying too early)

    -- back to where we started
    Move.down(height)

    -- plant a new sapling below us
    local success, data = turtle.inspectDown()
    if not success or type(data) ~= "table" or data.name ~= "minecraft:birch_sapling" then

        -- if there is a block below us, remove it
        if success then turtle.digDown() end

        -- do we have a sapling in the inventory?
        if Inventory.selectItem("minecraft:birch_sapling")	then turtle.placeDown()
															else print("No birch sapling to plant")
		end
    end

    -- there is no other way then succes, it is our way of being
    return true
end

local function detectTree()
	-- check block in front of turtle
    local success, data = turtle.inspect()

	-- any block in front of the turtle?
    if not success or type(data) ~= "table" or type(data.name) ~= "string" then return nil end

    -- staat er een berkenboom voor onze neus?
    if data.name == "minecraft:birch_log" then

		-- yes, return type
		return "birch"
	else

		-- make space, should never be needed, just to be safe
		turtle.dig()
		turtle.attack()

		-- no tree detected
		return nil
	end
end

local function forwardThroughForest(n)
	-- set default
	n = n or 1

    -- het gewenste aantal stappen zetten
    for _ = 1, n do

        -- something in front of us?
		local treeType = detectTree()
        if treeType then

			-- which tree is it?
			if treeType == "birch"	then harvestBirchTree()
									else print("Unknown tree type: "..tostring(treeType))
			end

		-- nothing in front of us
        else Move.forward()
        end
    end
end

local function forwardToNextTree(n)
	-- set default
	n = n or 1

	-- do n times
	for _ = 1, n do

		-- move forward to next tree position
		forwardThroughForest(6)

		-- check if there is a sappling under us
		local success, data = turtle.inspectDown()
		if not success or type(data) ~= "table" or data.name ~= "minecraft:birch_sapling" then

			-- only useful when we actually have a sapling
			local inventory = Inventory.getItemCounts()
			if inventory["minecraft:birch_sapling"] then

				-- if there is a block below us, remove it
				if success then turtle.digDown() end

				-- check for the ground
				Move.down()
				local success, data = turtle.inspectDown()

				-- if its dirt or grass, we can plant a sapling
				if success and type(data) == "table" and type(data.tags) == "table" and data.tags["minecraft:dirt"] then

					-- plant sapling
					Move.up()
					Inventory.selectItem("minecraft:birch_sapling")
					db.neverGrown[Location.toString(Move.getLocation())] = true
					turtle.placeDown()
				else

					-- it's not suitable, maybe we have dirt with us
					if inventory["minecraft:dirt"] then

						-- remove item below us
						if success then turtle.digDown() end

						-- place dirt
						if Inventory.selectItem("minecraft:dirt")	then turtle.placeDown()
																	else Inventory.selectItem("minecraft:grass_block") turtle.placeDown()
						end

						-- plant sapling
						Move.up()
						Inventory.selectItem("minecraft:birch_sapling")
						db.neverGrown[Location.toString(Move.getLocation())] = true
						turtle.placeDown()
					else
						-- just back up, we failed
						Move.up()
					end
				end
			end
		end
	end
end


local function walkForestRound()

	-- eerst in positie komen (in de stam van de eerste boom)
    Move.goTo(db.startLocation)
	forwardThroughForest(1)


--[[
↓←↓←↓←
↓↑↓↑↓↑
↓↑↓↑↓↑
↓↑↓↑↓↑
↓↑←↑←↑
→→→→→O
--]]

    -- calculate the route through the forest
    local numberOfLanes	= math.ceil(db.currentWidth / 2)			-- number of lanes is the number of pairs of rows
    local lastLaneHalf	= (db.currentWidth % 2 == 1)				-- is the last lane only half a lane?

	-- walking to the second row is only usefull when depth > 1
    if db.currentDepth > 1 then forwardToNextTree() end

    -- move for every lane (up and down)
    for i=1, numberOfLanes do

        -- determine last lane
        local lastLane = (i == numberOfLanes)

        -- move to "top right" lane
		forwardToNextTree(db.currentDepth - 2)

        -- we are at the top now, turn left for positioning to the next lane
        Move.turnLeft()

		-- do we have a next lane? just don't do it when we are at the end
        if not (lastLane and lastLaneHalf) then forwardToNextTree() end

        -- move to "bottom left" lane
        Move.turnLeft()
		forwardToNextTree(db.currentDepth - 2)

        -- (optionally) move and turn to start ("bottom right") next lane
        if not lastLane then
            Move.turnRight()
            forwardToNextTree()
            Move.turnRight()
        end
    end

    -- terug naar huis, kan wat speciale dingen met zich mee brengen
    if db.currentDepth > 1 then forwardToNextTree() end

    -- over de volledige breedte terug naar
    Move.turnLeft()
    forwardToNextTree(db.currentWidth - 1)

    -- terug in positie
	Move.goTo(db.restLocation)
	Move.turnTo(db.restDirection)

	-- organize the inventory
	Inventory.organize()
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

-- just one public function: harvest the forest
function Forester.harvestForest()

	-- make sure we're initialized
	if not db.initialized then init() end

	-- do the forest round
	walkForestRound()

	-- inspect chests



	-- store items




	-- all done
	return true

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
return Forester