-- adjust package path to include crafty colony modules
package.path = package.path..";/rom/modules/craftycolony/?;/rom/modules/craftycolony/?.lua"

-- import crafty colony CoreSystem
local CoreSystem = require "core.coresystem"

local function dummyCallback()
	print("Callback function executed.")
end

-- let's go
CoreSystem.run(dummyCallback)

-- ccwp.Init()
-- ccwp.Startup()
