-- startup.lua
-- Auto-startup script for CraftyColony turtles

-- This script will automatically run when the turtle starts up
-- It will launch the appropriate CraftyColony role based on configuration

print("CraftyColony Auto-Startup")
print("========================")

-- Check if CraftyColony is installed
if not fs.exists("src/main.lua") then
    print("ERROR: CraftyColony not found!")
    print("Please ensure src/main.lua exists")
    return
end

-- Add a small delay to ensure all systems are ready
sleep(2)

-- Try to determine the best role for this turtle
local function autoDetectRole()
    -- Check for specific items or equipment to determine role
    local detectedRole = nil
    
    -- Simple role detection based on computer ID or other factors
    local computerID = os.getComputerID()
    
    -- You can customize this logic based on your setup
    if computerID % 5 == 0 then
        detectedRole = "storage"
    elseif computerID % 5 == 1 then
        detectedRole = "miner"
    elseif computerID % 5 == 2 then
        detectedRole = "forester"
    elseif computerID % 5 == 3 then
        detectedRole = "farmer"
    else
        detectedRole = "builder"
    end
    
    return detectedRole
end

-- Get the role for this turtle
local role = autoDetectRole()
print("Auto-detected role: " .. role)

-- Launch CraftyColony with the detected role
print("Starting CraftyColony...")
print("")

-- Change to the correct directory and run main.lua
shell.run("src/main.lua", role)