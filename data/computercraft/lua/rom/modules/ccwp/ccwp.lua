local ccwp = {}

local coreLibrary = require "core.library"
local baseLibrary = require "base.library"
local objLibrary = require "obj.library"
local roleLibrary = require "role.library"
local lobjLibrary = require "lobj.library"
local mobjLibrary = require "mobj.library"
local enterpriseLibrary = require "enterprise.library"
local testLibrary = require "test.library"

function ccwp.Init()
    -- add & init libraries
    coreLibrary.Init()
    baseLibrary.Init()
    objLibrary.Init()
    roleLibrary.Init()
    lobjLibrary.Init()
    mobjLibrary.Init()
    enterpriseLibrary.Init()
    testLibrary.Init()
end

local function ExecuteAll(t)
    local options = nil
    return ExecuteXObjTest(t, "All", options, ExecuteAll)
end

function ccwp.Startup()
    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("t_ccwp", "t_ccwp")

    -- set main ccwp menu
    local coredisplay = require "coredisplay"
    coredisplay.MainMenuAddItem("1", "All", ExecuteAll, {filename = "t_ccwp"})
    coredisplay.MainMenuAddItem("2", "Exec code", ExecuteCode, {})
    coredisplay.MainMenuAddItem("3", "Load event", ExecuteAll, {})

    -- setup libraries
    coreLibrary.Setup()
    baseLibrary.Setup()
    objLibrary.Setup()
    roleLibrary.Setup()
    lobjLibrary.Setup()
    mobjLibrary.Setup()
    enterpriseLibrary.Setup()
    testLibrary.Setup()

    -- initialize core modules (old style)
    local core = require "core"
    core.Init()

    -- setup core modules
    core.Setup()

    -- nu werkelijk aan de slag
    core.Run()
end

return ccwp