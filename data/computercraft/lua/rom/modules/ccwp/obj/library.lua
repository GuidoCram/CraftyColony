-- define library
local library = {}

local libraryName = "obj"

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/"..libraryName.."/?;/rom/modules/ccwp/"..libraryName.."/?.lua"
end

function library.T_All()
    -- prepare test
    local corelog = require "corelog"
    corelog.WriteToLog("*** "..libraryName.." library tests ***")

    local T_ObjBase = require "test.t_obj_base"
    local T_ObjArray = require "test.t_obj_array"
    local T_ObjTable = require "test.t_obj_table"
    local T_CallDef = require "test.t_obj_call_def"
    local T_Callback = require "test.t_obj_callback"
    local T_TaskCall = require "test.t_obj_task_call"
    local T_URL = require "test.t_obj_url"
    local T_ObjLocator = require "test.t_obj_locator"
    local T_Host = require "test.t_host"
    local T_ObjHost = require "test.t_obj_host"
    local T_Location = require "test.t_obj_location"
    local T_Block = require "test.t_obj_block"
    local T_CodeMap = require "test.t_obj_code_map"
    local T_LayerRectangle = require "test.t_obj_layer_rectangle"
    local T_Inventory = require "test.t_obj_inventory"
    local T_WIPQueue = require "test.t_obj_wip_queue"
    local T_WIPAdministrator = require "test.t_obj_wip_administrator"

    -- library tests
    T_ObjBase.T_All()
    T_ObjArray.T_All()
    T_ObjTable.T_All()
    T_CallDef.T_All()
    T_Callback.T_All()
    T_TaskCall.T_All()
    T_URL.T_All()
    T_ObjLocator.T_All()
    T_Host.T_All()
    T_ObjHost.T_All()
    T_Location.T_All()
    T_Block.T_All()
    T_CodeMap.T_All()
    T_LayerRectangle.T_All()
    T_Inventory.T_All()
    T_WIPQueue.T_All()
    T_WIPAdministrator.T_All()
end

local function ExecuteLibraryTest(t)
	-- forward call with options
	local options	= {
        {key = "1", desc = "All",			    func = ExecuteLibraryTest, param = {filename = "T_ObjLibrary"}},

		{key = "b", desc = "ObjBase", 			func = ExecuteLibraryTest, param = {filename = "T_ObjBase"}},
		{key = "a", desc = "ObjArray", 			func = ExecuteLibraryTest, param = {filename = "T_ObjArray"}},
		{key = "t", desc = "ObjTable", 			func = ExecuteLibraryTest, param = {filename = "T_ObjTable"}},
		{key = "d", desc = "CallDef", 			func = ExecuteLibraryTest, param = {filename = "T_CallDef"}},
		{key = "2", desc = "Callback", 			func = ExecuteLibraryTest, param = {filename = "T_Callback"}},
		{key = "t", desc = "TaskCall", 			func = ExecuteLibraryTest, param = {filename = "T_TaskCall"}},
		{key = "u", desc = "URL", 				func = ExecuteLibraryTest, param = {filename = "T_URL"}},
		{key = "l", desc = "ObjLocator",		func = ExecuteLibraryTest, param = {filename = "T_ObjLocator"}},
		{key = "h", desc = "Host", 				func = ExecuteLibraryTest, param = {filename = "T_Host"}},
		{key = "j", desc = "ObjHost", 			func = ExecuteLibraryTest, param = {filename = "T_ObjHost"}},
		{key = "3", desc = "Location",			func = ExecuteLibraryTest, param = {filename = "T_Location"}},
		{key = "4", desc = "Block",				func = ExecuteLibraryTest, param = {filename = "T_Block"}},
		{key = "m", desc = "CodeMap",			func = ExecuteLibraryTest, param = {filename = "T_CodeMap"}},
		{key = "r", desc = "LayerRectangle",	func = ExecuteLibraryTest, param = {filename = "T_LayerRectangle"}},
		{key = "i", desc = "Inventory",			func = ExecuteLibraryTest, param = {filename = "T_Inventory"}},
		{key = "g", desc = "ItemTable",			func = ExecuteLibraryTest, param = {filename = "T_ItemTable"}},
		{key = "q", desc = "WIPQueue",			func = ExecuteLibraryTest, param = {filename = "T_WIPQueue"}},
		{key = "w", desc = "WIPAdministrator",	func = ExecuteLibraryTest, param = {filename = "T_WIPAdministrator"}},
		{key = "x", desc = "Back to main menu", func = function () return true end }
	}
	return ExecuteXObjTest(t, "obj", options, ExecuteLibraryTest)
end

function library.Setup()
    -- register library classes
    local ObjectFactory = require "object_factory"
    local objectFactory = ObjectFactory:getInstance()
    objectFactory:registerClass("ObjBase", require "obj_base")
    objectFactory:registerClass("ObjArray", require "obj_array")
    objectFactory:registerClass("ObjTable", require "obj_table")
    objectFactory:registerClass("CallDef", require "obj_call_def")
    objectFactory:registerClass("Callback", require "obj_callback")
    objectFactory:registerClass("TaskCall", require "obj_task_call")
    objectFactory:registerClass("URL", require "obj_url")
    objectFactory:registerClass("ObjLocator", require "obj_locator")
    objectFactory:registerClass("Host", require "host")
    objectFactory:registerClass("ObjHost", require "obj_host")
    objectFactory:registerClass("Location", require "obj_location")
    objectFactory:registerClass("Block", require "obj_block")
    objectFactory:registerClass("CodeMap", require "obj_code_map")
    objectFactory:registerClass("LayerRectangle", require "obj_layer_rectangle")
    objectFactory:registerClass("Inventory", require "obj_inventory")
    objectFactory:registerClass("ItemTable", require "obj_item_table")
    objectFactory:registerClass("WIPQueue", require "obj_wip_queue")
    objectFactory:registerClass("WIPAdministrator", require "obj_wip_administrator")

    objectFactory:registerClass("ObjTest", require "test.obj_test")

    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("IObj", "i_obj")
    moduleRegistry:requireAndRegisterModule("CallDef", "obj_call_def")
    moduleRegistry:requireAndRegisterModule("Callback", "obj_callback")

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModule("T_ObjLibrary", libraryName..".library")

    moduleRegistry:requireAndRegisterModule("T_ObjectFactory", "test.t_object_factory")
    moduleRegistry:requireAndRegisterModule("T_ObjBase", "test.t_obj_base")
    moduleRegistry:requireAndRegisterModule("T_ObjArray", "test.t_obj_array")
    moduleRegistry:requireAndRegisterModule("T_ObjTable", "test.t_obj_table")
    moduleRegistry:requireAndRegisterModule("T_CallDef", "test.t_obj_call_def")
    moduleRegistry:requireAndRegisterModule("T_Callback", "test.t_obj_callback")
    moduleRegistry:requireAndRegisterModule("T_TaskCall", "test.t_obj_task_call")
    moduleRegistry:requireAndRegisterModule("T_URL", "test.t_obj_url")
    moduleRegistry:requireAndRegisterModule("T_ObjLocator", "test.t_obj_locator")
    moduleRegistry:requireAndRegisterModule("T_Host", "test.t_host")
    moduleRegistry:requireAndRegisterModule("T_ObjHost", "test.t_obj_host")
    moduleRegistry:requireAndRegisterModule("T_Location", "test.t_obj_location")
    moduleRegistry:requireAndRegisterModule("T_Block", "test.t_obj_block")
    moduleRegistry:requireAndRegisterModule("T_CodeMap", "test.t_obj_code_map")
    moduleRegistry:requireAndRegisterModule("T_LayerRectangle", "test.t_obj_layer_rectangle")
    moduleRegistry:requireAndRegisterModule("T_Inventory", "test.t_obj_inventory")
    moduleRegistry:requireAndRegisterModule("T_ItemTable", "test.t_obj_item_table")
    moduleRegistry:requireAndRegisterModule("T_WIPQueue", "test.t_obj_wip_queue")
    moduleRegistry:requireAndRegisterModule("T_WIPAdministrator", "test.t_obj_wip_administrator")

    -- add library test menu
    local coredisplay = require "coredisplay"
    coredisplay.MainMenuAddItem("o", "obj lib tests", ExecuteLibraryTest, {})

    -- do other stuff
end

return library