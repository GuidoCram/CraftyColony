-- define module
local Class = require "class"
local IRegistry = require "i_registry"
local ModuleRegistry = Class.NewClass(IRegistry)

--[[
    The ModuleRegistry is a Registry of LUA modules.
--]]

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

local instance = nil
function ModuleRegistry:getInstance()
    if not instance then
        instance = Class.newInstance(ModuleRegistry)
        instance._modules = {}
    end
    return instance
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function ModuleRegistry:getRegistered(name)
    return self._modules[name]
end

function ModuleRegistry:register(name, module)
    self._modules[name] = module

    return true
end

function ModuleRegistry:isRegistered(name)
    return self._modules[name] ~= nil
end

function ModuleRegistry:delist(name)
    self._modules[name] = nil

    return true
end

function ModuleRegistry:requireAndRegisterModule(name, requireName)
    -- use require to get module
    requireName = requireName or name
    local module = require(requireName)

    -- register object
    self:register(name, module)
end

function ModuleRegistry:requireAndRegisterModuleTests(name)
    self:requireAndRegisterModule(name, "test."..name)
end

return ModuleRegistry
