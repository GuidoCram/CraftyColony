-- define class
local Class = require "class"
local MObjHost = require "mobj_host"
local enterprise_gathering = Class.NewClass(MObjHost)

--[[
    The enterprise_gathering is a MObjHost. It provides services for building and using MObj's where materials can be gathered, like mines and on the surface.
--]]

-- minable items below the surface (from https://minecraft.fandom.com/wiki/Altitude)
local minableItems = {
    "minecraft:deepslate",
    "minecraft:cobblestone",
    "minecraft:clay",
--    "minecraft:water", -- note: propably needs a special gathering technique with a bucket. doesn't it?
    "minecraft:gravel",
    "minecraft:copper_ore",
    "minecraft:coal_ore",
--    "minecraft:lava", -- note: propably needs a special gathering technique with a bucket. doesn't it?
    "minecraft:iron_ore",
    "minecraft:redstone_ore",
    "minecraft:diamond_ore",
    "minecraft:gold_ore",
    "minecraft:lapis_ore",
--    "minecraft:emerald_ore",
}

-- ToDo: consider refactoring and putting this elsewhere in some dictionary?
function enterprise_gathering.GetMinableItems()
    return minableItems
end

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

-- note: currently enterprise is treated like a singleton, but by directly using the name of the module
-- ToDo: consider making changes to enteprise to
--          - explicitly make it a singleton (by construction with :newInstance(hostName) and using the singleton pattern)
--          - properly initialise it (by adding and implementing the _init method)
--          - adopt other classes to these changes
enterprise_gathering._hostName  = "enterprise_gathering"

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function enterprise_gathering:getClassName()
    return "enterprise_gathering"
end

--                        _
--                       (_)
--    ___  ___ _ ____   ___  ___ ___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \
--   \__ \  __/ |   \ V /| | (_|  __/
--   |___/\___|_|    \_/ |_|\___\___|

return enterprise_gathering
