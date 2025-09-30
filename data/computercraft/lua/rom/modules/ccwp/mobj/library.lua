-- define library
local library = {}

local libraryName = "mobj"

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/"..libraryName.."/?;/rom/modules/ccwp/"..libraryName.."/?.lua"
end

function library.T_All()
    -- prepare test
    local corelog = require "corelog"
    corelog.WriteToLog("*** "..libraryName.." library tests ***")

    local T_MObjTest = require "test.t_mobj_test"
    local t_mobj_host = require "test.t_mobj_host"

    local T_BirchForest = require "test.t_mobj_birchforest"
    local T_Chest = require "test.t_mobj_chest"
    local T_CraftingSpot = require "test.t_crafting_spot"
    local T_DisplayStation = require "test.t_mobj_display_station"
    local T_Factory = require "test.t_mobj_factory"
    local T_MineLayer = require "test.t_mine_layer"
    local T_MineShaft = require "test.t_mine_shaft"
    local T_SmeltingSpot = require "test.t_smelting_spot"
    local T_Silo = require "test.t_mobj_silo"
    local T_Turtle = require "test.t_mobj_turtle"
    local T_UserStation = require "test.t_mobj_user_station"

    -- library tests
    T_MObjTest.T_All()
    t_mobj_host.T_All()

    T_BirchForest.T_All()
    T_Chest.T_All()
    T_CraftingSpot.T_All()
    T_DisplayStation.T_All()
    T_Factory.T_All()
    T_MineLayer.T_All()
    T_MineShaft.T_All()
    T_Silo.T_All()
    T_SmeltingSpot.T_All()
    T_Turtle.T_All()
    T_UserStation.T_All()
end

function library.T_AllPhysical()
    -- prepare test
    local corelog = require "corelog"
    corelog.WriteToLog("*** "..libraryName.." library physical tests ***")

    local T_MObjTest = require "test.t_mobj_test"
    local t_mobj_host = require "test.t_mobj_host"

    local T_BirchForest = require "test.t_mobj_birchforest"
    local T_Chest = require "test.t_mobj_chest"
    local T_CraftingSpot = require "test.t_crafting_spot"
    local T_DisplayStation = require "test.t_mobj_display_station"
    local T_Factory = require "test.t_mobj_factory"
    local T_MineLayer = require "test.t_mine_layer"
    local T_MineShaft = require "test.t_mine_shaft"
    local T_Silo = require "test.t_mobj_silo"
    local T_SmeltingSpot = require "test.t_smelting_spot"
    local T_Turtle = require "test.t_mobj_turtle"
    local T_UserStation = require "test.t_mobj_user_station"

    -- library tests
    T_MObjTest.T_AllPhysical()
    t_mobj_host.T_AllPhysical()

    T_BirchForest.T_AllPhysical()
    T_Chest.T_AllPhysical()
    T_CraftingSpot.T_AllPhysical()
    T_DisplayStation.T_AllPhysical()
    T_Factory.T_AllPhysical()
    T_MineLayer.T_AllPhysical()
    T_MineShaft.T_AllPhysical()
    T_Silo.T_AllPhysical()
    T_SmeltingSpot.T_AllPhysical()
    T_Turtle.T_AllPhysical()
    T_UserStation.T_AllPhysical()
end

local function ExecuteLibraryTest(t)
    -- forward call with options
    local options	= {
        {key = "1", desc = "All",               func = ExecuteLibraryTest, param = {filename = "T_MObjLibrary"}},

        {key = "2", desc = "MObjTest",          func = ExecuteLibraryTest, param = {filename = "T_MObjTest"}},
        {key = "h", desc = "MObjHost",          func = ExecuteLibraryTest, param = {filename = "T_MObjHost"}},

        {key = "b", desc = "BirchForest",       func = ExecuteLibraryTest, param = {filename = "T_BirchForest"}},
        {key = "c", desc = "Chest",             func = ExecuteLibraryTest, param = {filename = "T_Chest"}},
        {key = "3", desc = "CraftingSpot",      func = ExecuteLibraryTest, param = {filename = "T_CraftingSpot"}},
        {key = "d", desc = "DisplayStation",    func = ExecuteLibraryTest, param = {filename = "T_DisplayStation"}},
        {key = "f", desc = "Factory",           func = ExecuteLibraryTest, param = {filename = "T_Factory"}},
        {key = "l", desc = "MineLayer",         func = ExecuteLibraryTest, param = {filename = "T_MineLayer"}},
        {key = "m", desc = "MineShaft",         func = ExecuteLibraryTest, param = {filename = "T_MineShaft"}},
        {key = "s", desc = "Silo",              func = ExecuteLibraryTest, param = {filename = "T_Silo"}},
        {key = "4", desc = "SmeltingSpot",      func = ExecuteLibraryTest, param = {filename = "T_SmeltingSpot"}},
        {key = "t", desc = "Turtle",            func = ExecuteLibraryTest, param = {filename = "T_Turtle"}},
        {key = "u", desc = "UserStation",       func = ExecuteLibraryTest, param = {filename = "T_UserStation"}},

        {key = "x", desc = "Back to main menu", func = function () return true end }
    }
    return ExecuteXObjTest(t, "mobj", options, ExecuteLibraryTest)
end

function library.Setup()
    -- register library classes
    local ObjectFactory = require "object_factory"
    local objectFactory = ObjectFactory:getInstance()
    objectFactory:registerClass("MObjTest",     require "test.mobj_test")
    objectFactory:registerClass("MObjHost",     require "mobj_host")

    objectFactory:registerClass("BirchForest",  require "mobj_birchforest")
    objectFactory:registerClass("Chest",        require "mobj_chest")
    objectFactory:registerClass("CraftingSpot", require "crafting_spot")
    objectFactory:registerClass("DisplayStation",  require "mobj_display_station")
    objectFactory:registerClass("Factory",      require "mobj_factory")
    objectFactory:registerClass("MineLayer",    require "mine_layer")
    objectFactory:registerClass("MineShaft",    require "mine_shaft")
    objectFactory:registerClass("Silo",         require "mobj_silo")
    objectFactory:registerClass("SmeltingSpot", require "smelting_spot")
    objectFactory:registerClass("Turtle",       require "mobj_turtle")
    objectFactory:registerClass("UserStation",  require "mobj_user_station")

    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("mobj_host") -- ToDo: beetje dubbel op met ook in ObjectFactory...
    moduleRegistry:requireAndRegisterModule("IMObj", "i_mobj")

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModule("T_MObjLibrary", libraryName..".library")

    moduleRegistry:requireAndRegisterModule("T_MObjTest", "test.t_mobj_test")
    moduleRegistry:requireAndRegisterModule("T_MObjHost", "test.t_mobj_host")

    moduleRegistry:requireAndRegisterModule("T_BirchForest", "test.t_mobj_birchforest")
    moduleRegistry:requireAndRegisterModule("T_Chest", "test.t_mobj_chest")
    moduleRegistry:requireAndRegisterModule("T_CraftingSpot", "test.t_crafting_spot")
    moduleRegistry:requireAndRegisterModule("T_Factory", "test.t_mobj_factory")
    moduleRegistry:requireAndRegisterModule("T_MineLayer", "test.t_mine_layer")
    moduleRegistry:requireAndRegisterModule("T_MineShaft", "test.t_mine_shaft")
    moduleRegistry:requireAndRegisterModule("T_Silo", "test.t_mobj_silo")
    moduleRegistry:requireAndRegisterModule("T_SmeltingSpot", "test.t_smelting_spot")
    moduleRegistry:requireAndRegisterModule("T_Turtle", "test.t_mobj_turtle")
    moduleRegistry:requireAndRegisterModule("T_UserStation", "test.t_mobj_user_station")
    moduleRegistry:requireAndRegisterModule("T_DisplayStation", "test.t_mobj_display_station")

    -- add library test menu
    local coredisplay = require "coredisplay"
    coredisplay.MainMenuAddItem("m", libraryName.." lib tests", ExecuteLibraryTest, {})

    -- do other stuff
end

return library