-- adjust package path to include crafty colony modules
-- package.path = package.path..";/rom/modules/craftycolony/?;/rom/modules/craftycolony/?.lua"
package.path = package.path..";/rom/modules/?;/rom/modules/?.lua"



-- import crafty colony CoreSystem
local CoreSystem	= require("craftycolony.core.coresystem")
-- local CoreUtilities	= require("craftycolony.core.coreutilities")
local Inventory		= require("craftycolony.turtle.inventory")
local Equiped		= require("craftycolony.turtle.equiped")



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

local function testCallback()
	print("Callback function executing...")

	Equiped.restore({left = "minecraft:diamond_axe", 		right = "minecraft:diamond_pickaxe"})
	Equiped.restore({left = "minecraft:diamond_pickaxe",	right = "minecraft:diamond_axe"})

	Equiped.free("minecraft:diamond_pickaxe")
	Equiped.free("minecraft:diamond_axe")

	Equiped.equip("minecraft:diamond_pickaxe", "minecraft:diamond_axe")

--[[
	writeFileSync("/startup_log.txt", "w", "Startup callback executed at "..os.date("%Y-%m-%d %H:%M:%S").."\n\n")

	local data = turtle.getEquippedLeft()
	writeFileSync("/startup_log.txt", "a", "turtle.getEquippedLeft()\n")
	writeFileSync("/startup_log.txt", "a", textutils.serialize(data).."\n\n")

	data = turtle.getEquippedRight()
	writeFileSync("/startup_log.txt", "a", "turtle.getEquippedRight()\n")
	writeFileSync("/startup_log.txt", "a", textutils.serialize(data).."\n")
--]]
end

-- let's go
CoreSystem.run(testCallback)

