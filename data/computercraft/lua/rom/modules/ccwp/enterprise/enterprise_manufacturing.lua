-- define class
local Class = require "class"
local MObjHost = require "mobj_host"
local enterprise_manufacturing = Class.NewClass(MObjHost)

--[[
    The enterprise_manufacturing is a MObjHost. It hosts ItemSupplier's (i.e. Factory's) that can produce items.

    There are (currently) two recipe types for producing items.
        The crafting recipe uses the crafting production technique to produce an output item from a set of input items (ingredients).
        The smelting recipe uses the smelting production technique to produce an output item from an input item (ingredient).
--]]

local db = {
    -- turtle slots
    -- [ 1] [ 2] [ 3] [ 4]
    -- [ 5] [ 6] [ 7] [ 8]
    -- [ 9] [10] [11] [12]
    -- [13] [14] [15] [16]
    recipes        = {
        ["minecraft:stick"] = {
            crafting  = {
                  [6]    = { itemName = "minecraft:birch_planks",   itemCount = 1 },
                 [10]    = { itemName = "minecraft:birch_planks",   itemCount = 1 },
                yield   = 4
            },
        },
        ["minecraft:charcoal"] = { -- ToDo consider similar format to crafting to simpify code
            smelting  = {
                itemName    = "minecraft:birch_log",
                yield       = 1,
            },
        },
        ["minecraft:torch"] = {
            crafting  = {
                 [6]    = { itemName = "minecraft:charcoal",        itemCount = 1 },
                [10]    = { itemName = "minecraft:stick",           itemCount = 1 },
               yield   = 4
           },
        },
        ["minecraft:birch_planks"] = {
            crafting  = {
                 [6]    = { itemName = "minecraft:birch_log",       itemCount = 1 },
                yield   = 4
            },
        },
        ["minecraft:chest"] = {
            crafting  = {
                 [6]    = { itemName = "minecraft:birch_planks",    itemCount = 1 },
                 [7]    = { itemName = "minecraft:birch_planks",    itemCount = 1 },
                 [8]    = { itemName = "minecraft:birch_planks",    itemCount = 1 },
                [10]    = { itemName = "minecraft:birch_planks",    itemCount = 1 },
                [12]    = { itemName = "minecraft:birch_planks",    itemCount = 1 },
                [14]    = { itemName = "minecraft:birch_planks",    itemCount = 1 },
                [15]    = { itemName = "minecraft:birch_planks",    itemCount = 1 },
                [16]    = { itemName = "minecraft:birch_planks",    itemCount = 1 },
                yield   = 1
            },
        },
        ["minecraft:furnace"] = {
            crafting  = {
                 [6]    = { itemName = "minecraft:cobblestone",    itemCount = 1 },
                 [7]    = { itemName = "minecraft:cobblestone",    itemCount = 1 },
                 [8]    = { itemName = "minecraft:cobblestone",    itemCount = 1 },
                [10]    = { itemName = "minecraft:cobblestone",    itemCount = 1 },
                [12]    = { itemName = "minecraft:cobblestone",    itemCount = 1 },
                [14]    = { itemName = "minecraft:cobblestone",    itemCount = 1 },
                [15]    = { itemName = "minecraft:cobblestone",    itemCount = 1 },
                [16]    = { itemName = "minecraft:cobblestone",    itemCount = 1 },
                yield   = 1
            },
        },
        ["minecraft:crafting_table"] = {
            crafting  = {
                [11]    = { itemName = "minecraft:birch_planks",   itemCount = 1 },
                [12]    = { itemName = "minecraft:birch_planks",   itemCount = 1 },
                [15]    = { itemName = "minecraft:birch_planks",   itemCount = 1 },
                [16]    = { itemName = "minecraft:birch_planks",   itemCount = 1 },
                yield   = 1
            },
        },
    }
}

-- ToDo: consider refactoring and putting this elsewhere (a recipe book?)
function enterprise_manufacturing.GetRecipes()
    return db.recipes
end

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

-- note: currently enterprise is treated like a singleton, but by directly using the name of the module
-- ToDo: consider making changes to enterprise to
--          - explicitly make it a singleton (by construction with :newInstance(hostName) and using the singleton pattern)
--          - properly initialise it (by adding and implementing the _init method)
--          - adopt other classes to these changes
enterprise_manufacturing._hostName   = "enterprise_manufacturing"

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function enterprise_manufacturing:getClassName()
    return "enterprise_manufacturing"
end

--                        _
--                       (_)
--    ___  ___ _ ____   ___  ___ ___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \
--   \__ \  __/ |   \ V /| | (_|  __/
--   |___/\___|_|    \_/ |_|\___\___|

return enterprise_manufacturing
