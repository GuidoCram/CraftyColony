-- adjust package path to include crafty colony modules
-- package.path = package.path..";/rom/modules/craftycolony/?;/rom/modules/craftycolony/?.lua"
package.path = package.path..";/rom/modules/?;/rom/modules/?.lua"



-- import crafty colony CoreSystem
local CoreSystem	= require("craftycolony.core.coresystem")
-- local CoreUtilities	= require("craftycolony.core.coreutilities")
local Inventory		= require("craftycolony.turtle.inventory")



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

local function dummyCallback()
	print("Callback function executed.")

	writeFileSync("/startup_log.txt", "w", "Startup callback executed at "..os.date("%Y-%m-%d %H:%M:%S").."\n")

	local data = turtle.getItemDetail(3, true)
	writeFileSync("/startup_log.txt", "a", "turtle.getItemDetail(3, true) -- before organize\n")
	writeFileSync("/startup_log.txt", "a", textutils.serialize(data).."\n")

	data = Inventory.getItemCounts(true)
	writeFileSync("/startup_log.txt", "a", "Inventory.getItemCounts(true) -- before organize\n")
	writeFileSync("/startup_log.txt", "a", textutils.serialize(data).."\n")

	Inventory.organize()

	data = Inventory.getItemCounts(false)
	writeFileSync("/startup_log.txt", "a", "Inventory.getItemCounts(false) -- after organize\n")
	writeFileSync("/startup_log.txt", "a", textutils.serialize(data).."\n")

	sleep(1)
end

-- let's go
CoreSystem.run(dummyCallback)

