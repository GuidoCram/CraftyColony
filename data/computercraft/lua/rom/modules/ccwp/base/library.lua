-- define library
local library = {}

local libraryName = "base"

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/"..libraryName.."/?;/rom/modules/ccwp/"..libraryName.."/?.lua"
end

function library.T_All()
    -- prepare test
    local corelog = require "corelog"
    corelog.WriteToLog("*** "..libraryName.." library tests ***")

    local T_ModuleRegistry = require "test.t_module_registry"
    local T_Class = require "test.t_class"
    local T_ObjectFactory = require "test.t_object_factory"
    local T_MethodExecutor = require "test.t_method_executor"

    -- library tests
    T_ModuleRegistry.T_All()
    T_Class.T_All()
    T_ObjectFactory.T_All()
    T_MethodExecutor.T_All()
end

local function ExecuteLibraryTest(t)
	-- forward call with options
	local options	= {
        {key = "1", desc = "All",			    func = ExecuteLibraryTest, param = {filename = "T_BaseLibrary"}},

		{key = "m", desc = "ModuleRegistry", 	func = ExecuteLibraryTest, param = {filename = "T_ModuleRegistry"}},
		{key = "c", desc = "Class", 			func = ExecuteLibraryTest, param = {filename = "T_Class"}},
		{key = "f", desc = "ObjectFactory", 	func = ExecuteLibraryTest, param = {filename = "T_ObjectFactory"}},
		{key = "e", desc = "MethodExecutor", 	func = ExecuteLibraryTest, param = {filename = "T_MethodExecutor"}},
		{key = "x", desc = "Back to main menu", func = function () return true end }
	}
	return ExecuteXObjTest(t, "obj", options, ExecuteLibraryTest)
end

function library.Setup()
    -- register library classes
    -- local ObjectFactory = require "object_factory"
    -- local objectFactory = ObjectFactory:getInstance()

    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("MethodExecutor", "method_executor")

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModule("T_BaseLibrary", libraryName..".library")

    moduleRegistry:requireAndRegisterModule("T_ModuleRegistry", "test.t_module_registry")
    moduleRegistry:requireAndRegisterModule("T_Class", "test.t_class")
    moduleRegistry:requireAndRegisterModule("T_ObjectFactory", "test.t_object_factory")
    moduleRegistry:requireAndRegisterModule("T_MethodExecutor", "test.t_method_executor")

    -- add library test menu
    local coredisplay = require "coredisplay"
    coredisplay.MainMenuAddItem("b", "base lib tests", ExecuteLibraryTest, {})

    -- do other stuff
end

return library