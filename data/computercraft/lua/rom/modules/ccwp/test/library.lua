-- define library
local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/test/?"..";/rom/modules/ccwp/test/?.lua"
end

local function ExecuteLibraryTest(t)
    -- forward call with options
    local options	= {
        {key = "x", desc = "Back to main menu", func = function () return true end }
    }
    return ExecuteXObjTest(t, "test", options, ExecuteLibraryTest)
end

function library.Setup()
    -- register library classes
    -- local ObjectFactory = require "object_factory"
    -- local objectFactory = ObjectFactory:getInstance()
    -- objectFactory:registerClass("XxxYyy", require "xxx_yyy")

    -- register library modules
    -- local ModuleRegistry = require "module_registry"
    -- local moduleRegistry = ModuleRegistry:getInstance()

    -- add library test menu
    local coredisplay = require "coredisplay"
    coredisplay.MainMenuAddItem("t", "test lib tests", ExecuteLibraryTest, {})

    -- do other stuff
end

return library
