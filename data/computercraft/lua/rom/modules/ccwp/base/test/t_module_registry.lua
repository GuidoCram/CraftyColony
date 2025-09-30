local T_ModuleRegistry = {}

local ModuleRegistry = require "module_registry"

local T_IRegistry = require "test.t_i_registry"

function T_ModuleRegistry.T_All()
    -- IRegistry
    T_ModuleRegistry.T_IRegistry_All()
end

--    _____ _____            _     _
--   |_   _|  __ \          (_)   | |
--     | | | |__) |___  __ _ _ ___| |_ _ __ _   _
--     | | |  _  // _ \/ _` | / __| __| '__| | | |
--    _| |_| | \ \  __/ (_| | \__ \ |_| |  | |_| |
--   |_____|_|  \_\___|\__, |_|___/\__|_|   \__, |
--                      __/ |                __/ |
--                     |___/                |___/

function T_ModuleRegistry.T_IRegistry_All()
    -- prepare test
    local testRegistryName = "ModuleRegistry"
    local registry = ModuleRegistry:getInstance()
    local thingName = "Module"
    local module1Name = "module1"
    local module1 = {aValue = 1}
    local module2Name = "module2"
    local module2 = {aValue = 2}

    -- test
    T_IRegistry.pt_all(testRegistryName, registry, module1Name, module1, module2Name, module2, thingName)
end

return T_ModuleRegistry
