-- define library
local library = {}

local libraryName = "lobj"

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/"..libraryName.."/?;/rom/modules/ccwp/"..libraryName.."/?.lua"
end

function library.T_All()
    -- prepare test
    local corelog = require "corelog"
    corelog.WriteToLog("*** "..libraryName.." library tests ***")

    local T_LObjTest = require "test.t_lobj_test"
    local T_ItemStorageFake = require "test.t_item_storage_fake"
    local t_lobj_host = require "test.t_lobj_host"

    local T_LObjLocator = require "test.t_lobj_locator"
    local T_Shop = require "test.t_shop"
    local T_Settlement = require "test.t_settlement"

    -- library tests
    T_LObjTest.T_All()
    T_ItemStorageFake.T_All()
    t_lobj_host.T_All()

    T_LObjLocator.T_All()
    T_Shop.T_All()
    T_Settlement.T_All()
end

function library.T_AllPhysical()
    -- prepare test
    local corelog = require "corelog"
    corelog.WriteToLog("*** "..libraryName.." library physical tests ***")

    local T_ItemStorageFake = require "test.t_item_storage_fake"

    local T_Shop = require "test.t_shop"
    local T_Settlement = require "test.t_settlement"

    -- library tests
    T_ItemStorageFake.T_AllPhysical()

    T_Shop.T_AllPhysical()
    T_Settlement.T_AllPhysical()
end

local function ExecuteLibraryTest(t)
    -- forward call with options
    local options	= {
        {key = "1", desc = "All",               func = ExecuteLibraryTest, param = {filename = "T_LObjLibrary"}},

        {key = "2", desc = "LObjTest",          func = ExecuteLibraryTest, param = {filename = "T_LObjTest"}},
        {key = "3", desc = "ItemStorageFake",   func = ExecuteLibraryTest, param = {filename = "T_ItemStorageFake"}},
        {key = "h", desc = "LObjHost",          func = ExecuteLibraryTest, param = {filename = "T_LObjHost"}},

        {key = "l", desc = "LObjLocator",		func = ExecuteLibraryTest, param = {filename = "T_LObjLocator"}},

        {key = "s", desc = "Shop",              func = ExecuteLibraryTest, param = {filename = "T_Shop"}},
        {key = "v", desc = "Settlement",        func = ExecuteLibraryTest, param = {filename = "T_Settlement"}},
        {key = "x", desc = "Back to main menu", func = function () return true end }
    }
    return ExecuteXObjTest(t, "mobj", options, ExecuteLibraryTest)
end

function library.Setup()
    -- register library classes
    local ObjectFactory = require "object_factory"
    local objectFactory = ObjectFactory:getInstance()
    objectFactory:registerClass("LObjTest",     require "test.lobj_test")
    objectFactory:registerClass("ItemStorageFake",  require "test.item_storage_fake")
    objectFactory:registerClass("LObjHost",     require "lobj_host")

    objectFactory:registerClass("LObjLocator",  require "lobj_locator")
    objectFactory:registerClass("Shop",         require "shop")
    objectFactory:registerClass("Settlement",   require "settlement")

    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("lobj_host") -- ToDo: beetje dubbel op met ook in ObjectFactory...
    moduleRegistry:requireAndRegisterModule("IItemSupplier", "i_item_supplier")
    moduleRegistry:requireAndRegisterModule("IItemDepot", "i_item_depot")

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModule("T_LObjLibrary", libraryName..".library")

    moduleRegistry:requireAndRegisterModule("T_LObjTest", "test.t_lobj_test")
    moduleRegistry:requireAndRegisterModule("T_ItemStorageFake", "test.t_item_storage_fake")
    moduleRegistry:requireAndRegisterModule("T_LObjHost", "test.t_lobj_host")

    moduleRegistry:requireAndRegisterModule("T_IItemSupplier", "test.t_i_item_supplier")
    moduleRegistry:requireAndRegisterModule("T_IItemDepot", "test.t_i_item_depot")
    moduleRegistry:requireAndRegisterModule("T_LObjLocator", "test.t_lobj_locator")
    moduleRegistry:requireAndRegisterModule("T_Shop", "test.t_shop")
    moduleRegistry:requireAndRegisterModule("T_Settlement", "test.t_settlement")

    -- add library test menu
    local coredisplay = require "coredisplay"
    coredisplay.MainMenuAddItem("l", libraryName.." lib tests", ExecuteLibraryTest, {})

    -- do other stuff
end

return library