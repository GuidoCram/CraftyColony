-- adjust package path to include crafty colony modules
-- package.path = package.path..";/rom/modules/craftycolony/?;/rom/modules/craftycolony/?.lua"
package.path = package.path..";/rom/modules/?;/rom/modules/?.lua"

-- import crafty colony CoreSystem
local CoreSystem	= require("craftycolony.core.coresystem")
-- local CoreUtilities	= require("craftycolony.core.coreutilities")

local function dummyCallback()
	print("Callback function executed.")
--	print(CoreUtilities.Generate.id())
--	sleep(1)
end

-- let's go
CoreSystem.run(dummyCallback)

