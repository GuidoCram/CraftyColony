-- define module
local Forester = {}

-- imports
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

	currentWidth	= 2,
	currentDepth	= 6,

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
    if db.currentDepth > 1 then forwardThroughForest(6) end

    -- move for every lane (up and down)
    for i=1, numberOfLanes do

        -- determine last lane
        local lastLane = (i == numberOfLanes)

        -- move to "top right" lane
        forwardThroughForest(6 * (db.currentDepth - 2))

        -- we are at the top now, turn left for positioning to the next lane
        Move.turnLeft()

		-- do we have a next lane? just don't do it when we are at the end
        if not (lastLane and lastLaneHalf) then forwardThroughForest(6) end

        -- move to "bottom left" lane
        Move.turnLeft()
        forwardThroughForest(6 * (db.currentDepth - 2))

        -- (optionally) move and turn to start ("bottom right") next lane
        if not lastLane then
            Move.turnRight()
            forwardThroughForest(6)
            Move.turnRight()
        end
    end

    -- terug naar huis, kan wat speciale dingen met zich mee brengen
    if db.currentDepth > 1 then forwardThroughForest(6) end

    -- over de volledige breedte terug naar
    Move.turnLeft()
    forwardThroughForest(6 * (db.currentWidth - 1))

    -- terug in positie
	Move.goTo(db.restLocation)
	Move.turnTo(db.restDirection)
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

--[[
	-- let's get into position
	Move.goTo(db.startLocation)
	Move.turnTo(db.startDirection)

	-- debug, harvest the tree in front of us
	local treeType = detectTree()
	if treeType == "birch" then harvestBirchTree() end

	-- let's get into position
	Move.goTo(db.restLocation)
	Move.turnTo(db.restDirection)
--]]

	-- all done
	return true

end

function Forester.getStatus()

	return {
		currentWidth	= db.currentWidth,
		currentDepth	= db.currentDepth,
		maxWidth		= db.maxWidth,
		maxDepth		= db.maxDepth,
	}
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