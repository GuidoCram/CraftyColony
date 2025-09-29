-- deploy.lua
-- Deployment helper script for CraftyColony

local deploy = {}

-- Display deployment menu
function deploy.showMenu()
    term.clear()
    term.setCursorPos(1, 1)
    print("CraftyColony Deployment Helper")
    print("=============================")
    print("")
    print("1. Deploy Forester")
    print("2. Deploy Miner") 
    print("3. Deploy Farmer")
    print("4. Deploy Builder")
    print("5. Deploy Storage Manager")
    print("6. Auto-detect and Deploy")
    print("7. Setup Network")
    print("8. Test System")
    print("9. Exit")
    print("")
    print("Select option (1-9): ")
end

-- Deploy specific role
function deploy.deployRole(role)
    print("Deploying " .. role .. " turtle...")
    
    -- Check if we have the necessary files
    if not fs.exists("src/main.lua") then
        print("ERROR: CraftyColony source files not found!")
        return false
    end
    
    -- Create a custom startup script for this role
    local startupContent = string.format([[
-- Auto-generated startup for %s role
print("Starting CraftyColony %s...")
shell.run("src/main.lua", "%s")
]], role, role, role)
    
    local file = fs.open("startup", "w")
    file.write(startupContent)
    file.close()
    
    print("Created startup script for " .. role)
    print("Turtle will auto-start as " .. role .. " on reboot")
    
    -- Optionally start immediately
    print("Start immediately? (y/n): ")
    local input = read()
    if input:lower() == "y" then
        shell.run("src/main.lua", role)
    end
    
    return true
end

-- Setup network testing
function deploy.setupNetwork()
    print("Setting up network testing...")
    
    if not peripheral.find("modem") then
        print("ERROR: No wireless modem found!")
        print("Please attach a wireless modem to continue.")
        return false
    end
    
    -- Test communication
    print("Testing communication...")
    rednet.open(peripheral.find("modem"))
    
    print("Broadcasting test message...")
    rednet.broadcast("CraftyColony Test", "craftycolony_test")
    
    print("Listening for responses (5 seconds)...")
    local timer = os.startTimer(5)
    local responses = 0
    
    while true do
        local event, p1, p2, p3 = os.pullEvent()
        
        if event == "timer" and p1 == timer then
            break
        elseif event == "rednet_message" and p3 == "craftycolony_test" then
            responses = responses + 1
            print("Response from computer " .. p1)
        end
    end
    
    print("Network test complete. " .. responses .. " turtles responded.")
    rednet.close()
    return true
end

-- Auto-detect setup
function deploy.autoDetect()
    print("Auto-detecting turtle setup...")
    
    -- Check inventory for clues
    local items = {}
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item then
            items[item.name] = (items[item.name] or 0) + item.count
        end
    end
    
    -- Determine role based on items
    local role = "storage" -- default
    
    if items["minecraft:diamond_pickaxe"] or items["minecraft:iron_pickaxe"] then
        role = "miner"
    elseif items["minecraft:diamond_axe"] or items["minecraft:iron_axe"] then
        role = "forester"  
    elseif items["minecraft:diamond_hoe"] or items["minecraft:wheat_seeds"] then
        role = "farmer"
    elseif items["minecraft:cobblestone"] and items["minecraft:stone"] then
        role = "builder"
    end
    
    print("Auto-detected role: " .. role)
    print("Deploy as " .. role .. "? (y/n): ")
    
    local input = read()
    if input:lower() == "y" then
        return deploy.deployRole(role)
    end
    
    return false
end

-- Test system
function deploy.testSystem()
    print("Testing CraftyColony system...")
    
    local tests = {
        {name = "Source Files", test = function() return fs.exists("src/main.lua") end},
        {name = "Library Files", test = function() return fs.exists("src/lib/utils.lua") end},
        {name = "Role Files", test = function() return fs.exists("src/roles/forester.lua") end},
        {name = "Configuration", test = function() return fs.exists("src/config.lua") end},
        {name = "Wireless Modem", test = function() return peripheral.find("modem") ~= nil end}
    }
    
    local passed = 0
    for _, test in ipairs(tests) do
        local result = test.test()
        print(test.name .. ": " .. (result and "PASS" or "FAIL"))
        if result then passed = passed + 1 end
    end
    
    print("")
    print(string.format("Tests passed: %d/%d", passed, #tests))
    
    if passed == #tests then
        print("System ready for deployment!")
    else
        print("Please fix issues before deploying.")
    end
end

-- Main deployment interface
function deploy.run()
    while true do
        deploy.showMenu()
        local choice = read()
        
        if choice == "1" then
            deploy.deployRole("forester")
        elseif choice == "2" then
            deploy.deployRole("miner")
        elseif choice == "3" then
            deploy.deployRole("farmer")
        elseif choice == "4" then
            deploy.deployRole("builder")
        elseif choice == "5" then
            deploy.deployRole("storage")
        elseif choice == "6" then
            deploy.autoDetect()
        elseif choice == "7" then
            deploy.setupNetwork()
        elseif choice == "8" then
            deploy.testSystem()
        elseif choice == "9" then
            print("Goodbye!")
            break
        else
            print("Invalid choice. Press any key to continue...")
            read()
        end
        
        if choice ~= "9" then
            print("Press any key to continue...")
            read()
        end
    end
end

-- Run if executed directly
if ... == nil then
    deploy.run()
end

return deploy