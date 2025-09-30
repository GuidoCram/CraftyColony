-- define library
local library = {}

local libraryName = "enterprise"

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/"..libraryName.."/?;/rom/modules/ccwp/"..libraryName.."/?.lua"
end

function library.T_All()
    -- prepare test
    local corelog = require "corelog"
    corelog.WriteToLog("*** "..libraryName.." library tests ***")

    local t_test = require "test.t_test"
    local t_assignmentboard = require "test.t_assignmentboard"
    local t_employment = require "test.t_employment"
    local t_energy = require "test.t_energy"
    local t_forestry = require "test.t_forestry"
    local t_gathering = require "test.t_gathering"
    local t_isp = require "test.t_isp"
    local t_manufacturing = require "test.t_manufacturing"
    local t_projects = require "test.t_projects"
    local t_storage = require "test.t_storage"

    -- library tests
    t_test.T_All()
    t_assignmentboard.T_All()
    -- t_colonization.T_All()
    t_employment.T_All()
    t_energy.T_All()
    t_forestry.T_All()
    t_gathering.T_All()
    t_isp.T_All()
    t_manufacturing.T_All()
    t_projects.T_All()
    t_storage.T_All()
end

function library.T_AllPhysical()
    -- prepare test
    local corelog = require "corelog"
    corelog.WriteToLog("*** "..libraryName.." library physical tests ***")

    local t_employment = require "test.t_employment"
    local t_forestry = require "test.t_forestry"
    local t_gathering = require "test.t_gathering"
    local t_manufacturing = require "test.t_manufacturing"
    local t_storage = require "test.t_storage"

    -- library tests
    -- t_test.T_AllPhysical()
    -- t_assignmentboard.T_AllPhysical()
    -- t_colonization.T_AllPhysical()
    t_employment.T_AllPhysical()
    -- t_energy.T_AllPhysical()
    t_forestry.T_AllPhysical()
    t_gathering.T_AllPhysical()
    -- t_isp.T_AllPhysical()
    t_manufacturing.T_AllPhysical()
    -- t_projects.T_AllPhysical()
    t_storage.T_AllPhysical()
end

local function ExecuteLibraryTest(t)
	-- forward call with options
	local options	= {
		{key = "1", desc = "All",			    func = ExecuteLibraryTest, param = {filename = "T_EnterpriseLibrary"}},

		{key = "2", desc = "enterprise_test",   func = ExecuteLibraryTest, param = {filename = "t_test"}},
		{key = "a", desc = "assignmentboard",   func = ExecuteLibraryTest, param = {filename = "t_assignmentboard"}},
		{key = "n", desc = "colonization",      func = ExecuteLibraryTest, param = {filename = "t_colonization"}},
		{key = "c", desc = "construction",      func = ExecuteLibraryTest, param = {filename = "t_construction"}},
		{key = "t", desc = "employment",        func = ExecuteLibraryTest, param = {filename = "t_employment"}},
		{key = "e", desc = "energy",            func = ExecuteLibraryTest, param = {filename = "t_energy"}},
		{key = "f", desc = "forestry",          func = ExecuteLibraryTest, param = {filename = "t_forestry"}},
		{key = "g", desc = "gathering",         func = ExecuteLibraryTest, param = {filename = "t_gathering"}},
		{key = "i", desc = "isp",               func = ExecuteLibraryTest, param = {filename = "t_isp"}},
		{key = "m", desc = "manufacturing",     func = ExecuteLibraryTest, param = {filename = "t_manufacturing"}},
		{key = "p", desc = "projects",          func = ExecuteLibraryTest, param = {filename = "t_projects"}},
		{key = "s", desc = "storage",           func = ExecuteLibraryTest, param = {filename = "t_storage"}},
		{key = "x", desc = "Back to main menu", func = function () return true end }
	}
	return ExecuteXObjTest(t, "enterprise", options, ExecuteLibraryTest)
end

function library.Setup()
    -- register library classes
    -- local ObjectFactory = require "object_factory"
    -- local objectFactory = ObjectFactory:getInstance()

    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("enterprise_assignmentboard")
    moduleRegistry:requireAndRegisterModule("enterprise_colonization")
    moduleRegistry:requireAndRegisterModule("enterprise_construction")
    moduleRegistry:requireAndRegisterModule("enterprise_dump")
    moduleRegistry:requireAndRegisterModule("enterprise_energy")
    moduleRegistry:requireAndRegisterModule("enterprise_manufacturing")
    moduleRegistry:requireAndRegisterModule("enterprise_forestry")
    moduleRegistry:requireAndRegisterModule("enterprise_gathering")
    moduleRegistry:requireAndRegisterModule("enterprise_isp")
    moduleRegistry:requireAndRegisterModule("enterprise_projects")
    moduleRegistry:requireAndRegisterModule("enterprise_storage")
    moduleRegistry:requireAndRegisterModule("enterprise_employment")
    moduleRegistry:requireAndRegisterModule("enterprise_administration")

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModule("T_EnterpriseLibrary", libraryName..".library")

    moduleRegistry:requireAndRegisterModuleTests("t_assignmentboard")
    moduleRegistry:requireAndRegisterModuleTests("t_colonization")
    moduleRegistry:requireAndRegisterModuleTests("t_construction")
    moduleRegistry:requireAndRegisterModuleTests("t_energy")
    moduleRegistry:requireAndRegisterModuleTests("t_manufacturing")
    moduleRegistry:requireAndRegisterModuleTests("t_forestry")
    moduleRegistry:requireAndRegisterModuleTests("t_gathering")
    moduleRegistry:requireAndRegisterModuleTests("t_isp")
    moduleRegistry:requireAndRegisterModuleTests("t_projects")
    moduleRegistry:requireAndRegisterModuleTests("t_storage")
    moduleRegistry:requireAndRegisterModuleTests("enterprise_test")
    moduleRegistry:requireAndRegisterModuleTests("t_test")
    moduleRegistry:requireAndRegisterModuleTests("t_employment")

    -- add library test menu
    local coredisplay = require "coredisplay"
    coredisplay.MainMenuAddItem("e", "enterprise lib tests", ExecuteLibraryTest, {})

    -- do other stuff
end

return library