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

local function forwardAndHarvestLeaves(harvestAbove)

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
    forwardAndHarvestLeaves(true)
    forwardAndHarvestLeaves(false)

	-- 1 → 2
    Move.turnRight()
    forwardAndHarvestLeaves(false)
    forwardAndHarvestLeaves(false)

	-- 2 → 3
    Move.turnRight()
    forwardAndHarvestLeaves(false)
    forwardAndHarvestLeaves(false)
    forwardAndHarvestLeaves(false)
    forwardAndHarvestLeaves(false)

	-- 3 → 4
    Move.turnRight()
    forwardAndHarvestLeaves(false)
    forwardAndHarvestLeaves(false)
    forwardAndHarvestLeaves(false)
    forwardAndHarvestLeaves(false)

	-- 4 → 5
    Move.turnRight()
    forwardAndHarvestLeaves(false)
    forwardAndHarvestLeaves(false)
    forwardAndHarvestLeaves(false)
    forwardAndHarvestLeaves(false)

	-- 5 → 6
    Move.turnRight()
    forwardAndHarvestLeaves(false)

	-- 6 → 7
    Move.turnRight()
    forwardAndHarvestLeaves(true)
    forwardAndHarvestLeaves(true)
    forwardAndHarvestLeaves(true)

	-- 7 → 8
    Move.turnLeft()
    forwardAndHarvestLeaves(true)
    forwardAndHarvestLeaves(true)

	-- 8 → 9
    Move.turnLeft()
    forwardAndHarvestLeaves(true)
    forwardAndHarvestLeaves(true)

	-- 9 → 0
    Move.turnLeft()		-- terug naar de 0-1 lijn
    Move.forward()		-- terug naar de 0-1 lijn
    Move.turnRight()	-- achteruit inparkeren
    Move.back()			-- achteruit inparkeren
end

local function harvestTreeBirch()

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

    -- topblock last to prevent leaves from decaying too early
    turtle.digUp()

    -- do we need the crown too?
--    if Inventory.getItemCounts()["minecraft:birch_sapling"] < 2 then ChopCrown() end

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
    if data.name == "minecraft:birch_log"	then return "birch"
											else return nil
	end
end

local function moveThroughForest()
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

	-- let's get into position
	Move.goTo(db.startLocation)
	Move.turnTo(db.startDirection)

	-- debug, harvest the tree in front of us
	local treeType = detectTree()
	if treeType == "birch" then
		harvestTreeBirch()
	end

	-- let's get into position
	Move.goTo(db.restLocation)
	Move.turnTo(db.restDirection)


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