-- main.lua
-- Main entry point for CraftyColony autonomous turtle system

-- Add src directory to package path for require statements
package.path = package.path .. ";/src/?.lua;/src/lib/?.lua;/src/roles/?.lua"

local utils = require("lib.utils")
local communication = require("lib.communication")
local navigation = require("lib.navigation")
local inventory = require("lib.inventory")

-- Available roles
local roles = {
    forester = require("roles.forester"),
    miner = require("roles.miner"),
    farmer = require("roles.farmer"),
    builder = require("roles.builder"),
    storage = require("roles.storage")
}

-- Main CraftyColony system
local craftyColony = {}

-- Configuration
craftyColony.config = {
    version = "1.0.0",
    defaultRole = "forester",
    autoDetectRole = true,
    startupDelay = 2
}

-- Display startup banner
function craftyColony.showBanner()
    term.clear()
    term.setCursorPos(1, 1)
    
    utils.info("====================================")
    utils.info("      CraftyColony v" .. craftyColony.config.version)
    utils.info("   Autonomous Turtle Colony System")
    utils.info("====================================")
    utils.info("")
end

-- Detect turtle role based on equipment or user input
function craftyColony.detectRole()
    utils.info("Detecting turtle role...")
    
    -- Check equipment to determine role
    local detectedRole = nil
    
    -- Check for mining tools
    if inventory.findItem("minecraft:diamond_pickaxe") or 
       inventory.findItem("minecraft:iron_pickaxe") or
       inventory.findItem("minecraft:stone_pickaxe") then
        detectedRole = "miner"
    end
    
    -- Check for farming tools
    if inventory.findItem("minecraft:diamond_hoe") or 
       inventory.findItem("minecraft:iron_hoe") or
       inventory.findItem("minecraft:stone_hoe") or
       inventory.findItem("minecraft:wheat_seeds") or
       inventory.findItem("minecraft:carrot") then
        detectedRole = "farmer"
    end
    
    -- Check for building materials
    if inventory.findItem("minecraft:cobblestone") or 
       inventory.findItem("minecraft:stone") or
       inventory.findItem("minecraft:oak_planks") then
        detectedRole = "builder"
    end
    
    -- Check for forestry tools
    if inventory.findItem("minecraft:diamond_axe") or 
       inventory.findItem("minecraft:iron_axe") or
       inventory.findItem("minecraft:stone_axe") or
       inventory.findItem("minecraft:oak_sapling") then
        detectedRole = "forester"
    end
    
    -- Check for storage items
    if inventory.findItem("minecraft:chest") or 
       inventory.findItem("minecraft:barrel") then
        detectedRole = "storage"
    end
    
    if detectedRole then
        utils.info("Auto-detected role: " .. detectedRole)
        return detectedRole
    else
        utils.info("Could not auto-detect role")
        return nil
    end
end

-- Get role selection from user
function craftyColony.selectRole()
    if craftyColony.config.autoDetectRole then
        local autoRole = craftyColony.detectRole()
        if autoRole then
            return autoRole
        end
    end
    
    utils.info("Available roles:")
    local roleList = {}
    for roleName, _ in pairs(roles) do
        table.insert(roleList, roleName)
        utils.info("  " .. #roleList .. ". " .. roleName)
    end
    
    utils.info("Enter role number or name (default: " .. craftyColony.config.defaultRole .. "):")
    
    local input = read()
    
    if input == "" then
        return craftyColony.config.defaultRole
    end
    
    -- Check if input is a number
    local roleNumber = tonumber(input)
    if roleNumber and roleList[roleNumber] then
        return roleList[roleNumber]
    end
    
    -- Check if input is a role name
    if roles[input] then
        return input
    end
    
    utils.warn("Invalid role selection, using default: " .. craftyColony.config.defaultRole)
    return craftyColony.config.defaultRole
end

-- Initialize turtle with GPS if available
function craftyColony.initializePosition()
    utils.info("Initializing turtle position...")
    
    -- Try to get GPS coordinates
    local x, y, z = gps.locate(5)
    
    if x and y and z then
        navigation.setPosition(x, y, z, navigation.DIRECTIONS.NORTH)
        utils.info(string.format("GPS coordinates acquired: (%d, %d, %d)", x, y, z))
    else
        utils.warn("GPS not available, using default position (0, 64, 0)")
        navigation.setPosition(0, 64, 0, navigation.DIRECTIONS.NORTH)
    end
end

-- Setup turtle for operation
function craftyColony.setup()
    craftyColony.showBanner()
    
    utils.info("Starting CraftyColony initialization...")
    os.sleep(craftyColony.config.startupDelay)
    
    -- Initialize position
    craftyColony.initializePosition()
    
    -- Display inventory status
    inventory.printStatus()
    
    -- Select role
    local selectedRole = craftyColony.selectRole()
    utils.info("Selected role: " .. selectedRole)
    
    return selectedRole
end

-- Main execution function
function craftyColony.run()
    local selectedRole = craftyColony.setup()
    
    if not roles[selectedRole] then
        utils.error("Invalid role selected: " .. selectedRole)
        return false
    end
    
    local roleModule = roles[selectedRole]
    local turtleId = selectedRole .. "_" .. os.getComputerID()
    
    utils.info("Initializing " .. selectedRole .. " module...")
    
    if not roleModule.init(turtleId) then
        utils.error("Failed to initialize " .. selectedRole .. " module")
        return false
    end
    
    utils.info("Starting " .. selectedRole .. " work loop...")
    
    -- Start the main work loop for the selected role
    roleModule.workLoop()
    
    utils.info("CraftyColony session ended")
    return true
end

-- Command line interface
function craftyColony.handleCommand(command, ...)
    local args = {...}
    
    if command == "status" then
        utils.info("CraftyColony Status:")
        utils.info("Version: " .. craftyColony.config.version)
        utils.info("Computer ID: " .. os.getComputerID())
        navigation.printPosition()
        inventory.printStatus()
        
    elseif command == "test" then
        local testRole = args[1] or "forester"
        if roles[testRole] then
            utils.info("Testing " .. testRole .. " module...")
            local status = roles[testRole].getStatus()
            for key, value in pairs(status) do
                utils.info(key .. ": " .. tostring(value))
            end
        else
            utils.error("Unknown role: " .. testRole)
        end
        
    elseif command == "roles" then
        utils.info("Available roles:")
        for roleName, _ in pairs(roles) do
            utils.info("  " .. roleName)
        end
        
    elseif command == "discover" then
        if communication.init("discovery_" .. os.getComputerID()) then
            local turtles = communication.discoverTurtles()
            utils.info("Discovered turtles:")
            for _, turtleId in ipairs(turtles) do
                utils.info("  Turtle ID: " .. turtleId)
            end
            communication.close()
        end
        
    elseif command == "help" then
        utils.info("CraftyColony Commands:")
        utils.info("  status    - Show system status")
        utils.info("  test      - Test a role module")
        utils.info("  roles     - List available roles")
        utils.info("  discover  - Discover nearby turtles")
        utils.info("  help      - Show this help")
        utils.info("")
        utils.info("To start a turtle with a specific role:")
        utils.info("  lua main.lua [role_name]")
        
    else
        utils.info("Unknown command. Use 'help' for available commands.")
    end
end

-- Main entry point
function main(...)
    local args = {...}
    
    if #args > 0 then
        local command = args[1]
        
        -- Check if it's a command
        if command == "status" or command == "test" or command == "roles" or 
           command == "discover" or command == "help" then
            return craftyColony.handleCommand(unpack(args))
        end
        
        -- Otherwise treat as role selection
        if roles[command] then
            craftyColony.config.autoDetectRole = false
            craftyColony.config.defaultRole = command
        end
    end
    
    -- Run the main system
    return craftyColony.run()
end

-- Execute if this file is run directly
if ... == nil then
    main()
end

return craftyColony