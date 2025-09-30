-- define library
local library = {}

local libraryName = "core"

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/"..libraryName.."/?;/rom/modules/ccwp/"..libraryName.."/?.lua"
end

function library.T_All()
    -- prepare test
    local corelog = require "corelog"
    corelog.WriteToLog("*** "..libraryName.." library tests ***")

    local t_coredht = require "test.t_coredht"

    -- library tests
    t_coredht.T_All()
end

local function MoveTurtle( t )
    -- screen to move the turtle around

    local coremove		= require "coremove"
    local coretask		= require "coretask"
    local coredisplay	= require "coredisplay"

    -- chech if this is a turtle
    if not turtle then coredisplay.UpdateToDisplay("Only available for turtles") return false end

    -- first screen?
    if t == nil or t.direction == nil then
        -- moves screen
        coredisplay.NextScreen({
            clear = true,
            intro = "Available actions",
            option = {
                {key = "w", desc = "Forward",		    func = MoveTurtle, param = {direction = "Forward"   }},
                {key = "s", desc = "Backward",		    func = MoveTurtle, param = {direction = "Backward"  }},
                {key = "a", desc = "Turn left",	        func = MoveTurtle, param = {direction = "Left"      }},
                {key = "d", desc = "Turn right",	    func = MoveTurtle, param = {direction = "Right"     }},
                {key = "e", desc = "Up",			    func = MoveTurtle, param = {direction = "Up"        }},
                {key = "q", desc = "Down",				func = MoveTurtle, param = {direction = "Down"      }},
                -- {key = "x", desc = "Back to main menu", func = function () return true end }
                {key = "x", desc = "Back to previous menu", func = library.ExecuteLibraryTest, param = {} }
            },
            question = "Which direction?"
        })
        return true
    else
        -- execute move
            if t.direction == "Forward"     then coretask.AddWork(function () coremove.Forward()    end, nil, "coremove.Forward()")
        elseif t.direction == "Backward"    then coretask.AddWork(function () coremove.Backward()   end, nil, "coremove.Backward()")
        elseif t.direction == "Left"        then coretask.AddWork(function () coremove.Left()       end, nil, "coremove.Left()")
        elseif t.direction == "Right"       then coretask.AddWork(function () coremove.Right()      end, nil, "coremove.Right()")
        elseif t.direction == "Up"          then coretask.AddWork(function () coremove.Up()         end, nil, "coremove.Up()")
        elseif t.direction == "Down"        then coretask.AddWork(function () coremove.Down()       end, nil, "coremove.Down()")
        end

        -- makes the previous screen stays loaded, so the human kan move the turtle again
        return false
    end
end

function library.ExecuteLibraryTest(t)

    -- import dht module
    local coredht = require "coredht"
    local coreenv = require "coreenv"

    -- forward call with options
    local options	= {
        {key = "1", desc = "All",			    func = library.ExecuteLibraryTest,  param = {filename = "T_CoreLibrary"}},

        {key = "m", desc = "coremove", 			func = library.ExecuteLibraryTest,  param = {filename = "t_coremove"}},
        {key = "d", desc = "coredht", 			func = library.ExecuteLibraryTest,  param = {filename = "t_coredht"}},
        {key = "e", desc = "edit dht", 			func = coredht.EditDHTDisplay,      param = {keyList = {}}},
        {key = "v", desc = "edit env", 			func = coreenv.EditEnvDisplay,      param = {}},
        {key = "i", desc = "coreinventory",		func = library.ExecuteLibraryTest,  param = {filename = "t_coreinventory"}},
        {key = "x", desc = "Back to main menu", func = function () return true end }
    }

    -- alleen een turtle kan bewogen worden
    -- ToDo: this is not only the case for this test/ script. Investigate where else to have menu depend on Worker type
    if turtle then table.insert(options, 2, {key = "2", desc = "Move turtle", func = MoveTurtle, param = {}}) end

    return ExecuteXObjTest(t, "core", options, library.ExecuteLibraryTest)
end

function library.Setup()
    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModule("T_CoreLibrary", libraryName..".library")

    moduleRegistry:requireAndRegisterModule("t_coremove", "test.t_coremove")
    moduleRegistry:requireAndRegisterModule("t_coredht", "test.t_coredht")
    moduleRegistry:requireAndRegisterModule("t_coreinventory", "test.t_coreinventory")

    -- add library test menu
    local coredisplay = require "coredisplay"
    coredisplay.MainMenuAddItem("c", "core lib tests", library.ExecuteLibraryTest, {})

    -- do other stuff
end

return library