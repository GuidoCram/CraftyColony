-- config.lua
-- Configuration file for CraftyColony

local config = {}

-- Global CraftyColony settings
config.global = {
    version = "1.0.0",
    networkProtocol = "craftycolony",
    baseLocation = {x = 0, y = 64, z = 0},
    enableGPS = true,
    debugMode = false
}

-- Forester role configuration
config.forester = {
    saplingSlot = 1,
    boneMealSlot = 2,
    maxTreeHeight = 20,
    replantSaplings = true,
    useBoneMeal = true,
    torchPlacement = true,
    workArea = {
        minX = -15,
        maxX = 15,
        minZ = -15,
        maxZ = 15
    },
    treeTypes = {"oak", "birch", "spruce"}
}

-- Miner role configuration
config.miner = {
    fuelSlot = 16,
    torchSlot = 15,
    maxDepth = 64,
    targetDepth = 12, -- Diamond level
    torchInterval = 8,
    stripMineWidth = 3,
    shaftSpacing = 4,
    workArea = {
        minX = -30,
        maxX = 30,
        minZ = -30,
        maxZ = 30
    },
    priorityOres = {
        "minecraft:diamond_ore",
        "minecraft:emerald_ore",
        "minecraft:gold_ore",
        "minecraft:iron_ore"
    }
}

-- Farmer role configuration
config.farmer = {
    seedSlots = {1, 2, 3},
    toolSlot = 4,
    waterBucketSlot = 5,
    boneMealSlot = 6,
    farmSize = {width = 9, length = 9},
    waterPlacement = 4,
    harvestWhenFull = true,
    cropRotation = true,
    farms = {
        {x = 0, z = 0, crop = "wheat"},
        {x = 15, z = 0, crop = "carrots"},
        {x = 0, z = 15, crop = "potatoes"},
        {x = 15, z = 15, crop = "beetroot"}
    }
}

-- Builder role configuration
config.builder = {
    blueprintSlot = 1,
    buildHeight = 10,
    materialSlots = {2, 3, 4, 5, 6, 7, 8, 9},
    supportBlocks = {
        "minecraft:cobblestone",
        "minecraft:stone",
        "minecraft:oak_planks"
    },
    autoRepair = true,
    qualityCheck = true,
    defaultMaterials = {
        wall = "minecraft:cobblestone",
        floor = "minecraft:stone",
        roof = "minecraft:oak_planks",
        foundation = "minecraft:stone"
    }
}

-- Storage role configuration
config.storage = {
    baseLocation = {x = 0, y = 64, z = 0},
    chestLocations = {
        {x = 1, y = 64, z = 0, type = "ores"},
        {x = -1, y = 64, z = 0, type = "building"},
        {x = 0, y = 64, z = 1, type = "farming"},
        {x = 0, y = 64, z = -1, type = "tools"},
        {x = 2, y = 64, z = 0, type = "misc"}
    },
    autoSort = true,
    compactItems = true,
    alertWhenFull = true,
    sortingRules = {
        ores = {
            "diamond", "emerald", "gold", "iron", 
            "coal", "copper", "lapis", "redstone"
        },
        building = {
            "cobblestone", "stone", "dirt", "sand", 
            "gravel", "planks", "glass", "brick"
        },
        farming = {
            "wheat", "carrot", "potato", "beetroot", 
            "seeds", "bone_meal", "water_bucket"
        },
        tools = {
            "pickaxe", "axe", "shovel", "hoe", 
            "sword", "torch", "bucket"
        }
    }
}

-- Communication settings
config.communication = {
    broadcastChannel = 1000,
    responseTimeout = 5,
    maxRetries = 3,
    discoveryInterval = 30,
    statusUpdateInterval = 60,
    emergencyChannel = 999
}

-- Return configuration
return config