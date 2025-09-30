-- define module
local coredisplay = {}

-- ToDo: add proper module description
--[[
    This module ...
--]]

local coresystem	= require "coresystem"
local coredht		= require "coredht"
local corelog		= require "corelog"
local coreutils		= require "coreutils"
local coretest		= require "coretest"

local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local MethodExecutor = require "method_executor"

local enterprise_employment

-- declare display space
local db    = {
    x           = 0,
    y           = 0,
    update      = {}								-- list with all schreen updates
}
local screen    = {}

-- init function for the display
function coredisplay.Init()
    -- get current position
    db.x, db.y = term.getSize()

    -- direct even doen
    if db.defaultMainMenu == nil then
        db.defaultMainMenu = {
            clear   = true,
            intro   = "Choose your action",
            option  = {
                {key = "q", desc = "Quit",          	func = coresystem.DoQuit,		param = {}},
            },
            question	= "Make your choice",
        }
    end
end

local function DHTReadySetup()
    -- determine main menu of current worker
    local mainMenu = nil
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local workerLocator = enterprise_employment:getCurrentWorkerLocator()
    if not workerLocator then corelog.Error("coredisplay.DHTReadySetup: Failed obtaining current workerLocator")
    else
        local workerObj = enterprise_employment:getObj(workerLocator)
        if not workerObj then corelog.Error("coredisplay.DHTReadySetup: Failed obtaining Worker "..workerLocator:getURI())
        else
            mainMenu = workerObj:getMainUIMenu()
        end
    end
    if not mainMenu then
        corelog.WriteToLog("coredisplay.DHTReadySetup: Using DummyWorkerMenu")
        mainMenu = enterprise_employment:getDummyWorkerMenu()
    end

    -- set start screen
    coredisplay.MainMenu(mainMenu)
end

-- setup function for the display
function coredisplay.Setup()
    -- pas als de dht klaar is...
    coredht.DHTReadyFunction(DHTReadySetup)
end

-- to know if the dislay is still being used
function Active() return db.mainmenu ~= nil end

-- endless loop function for the display
function coredisplay.Run()
    -- is de dth al beschikbaar?
    while not coredht.IsReady() do

        -- gewoon ff wachten
        os.sleep(0.25)
    end

    -- only continue as long as there is a main menu defined
    while db.mainmenu ~= nil and coresystem.IsRunning() do
        -- get de next screen definition
        local nextScreenData = coredisplay.NextScreen()

        -- custom screen?
        if nextScreenData.custom	then nextScreenData.custom(nextScreenData)	-- zo te zien wordt deze optie nergens gebruikt
                                    else DoScreen(nextScreenData)
        end
    end

	-- show we are done!
	print("coredisplay.Run() is complete")
end

-- gets or sets the next screen
function coredisplay.NextScreen(t)
    if t				then screen[#screen + 1] = t
    elseif #screen > 0	then return table.remove(screen)
                        else return coredisplay.MainMenu()
    end
end

local function EndOfString(str, numberOfChars)
    -- get the length of the string
    local lengthOfString    = string.len(str)

    -- we show the number of chars, unless the string is not long enough
    local charsShown        = math.min(lengthOfString, numberOfChars)

    -- done
    return string.sub(str, lengthOfString - charsShown + 1, lengthOfString)
end

-- function to execute a screen from a screentable
function DoScreen(t)
    local success
    local response

    -- now print the screen
    if not t.dontclear then term.clear() term.setCursorPos(1,1) end

    -- print the intro
    if t.intro then print(t.intro) end

    -- print the list
    if t.option then

        -- weinig opties, dan de oude werkwijze?
        if #t.option < 11 then

            -- one big list
            for i=1,#t.option do print(t.option[i].key, t.option[i].desc) end
        else

            -- fixed for now
            local rightOffset	= 10
            local maxDesc       = 17

            -- might look nicer this way
            if #t.option > 10 and #t.option < 20 then rightOffset = math.floor((1 + #t.option) / 2) end

            -- we have max 10 lines
            for i=1,10 do
                local keyLeft	= ""
                local keyRight	= ""
                local textLeft	= ""
                local textRight	= ""

                -- left side is easy
                if t.option[i] and i <= rightOffset then
                    keyLeft			= t.option[i].key
                    textLeft		= t.option[i].desc
                end

                -- right side just as easy
                if t.option[i + rightOffset] then
                    keyRight		= t.option[i + rightOffset].key
                    textRight		= t.option[i + rightOffset].desc
                end

                -- print the damn line
                print(string.format("%-1.1s %-17.17s %-1.1s %-17.17s", keyLeft, EndOfString(textLeft, maxDesc), keyRight, EndOfString(textRight, maxDesc)))
            end
        end

--[[ 		-- too many options?
        if #t.option < 11 then
            -- one big list
            for i=1,#t.option do print(t.option[i].key, t.option[i].desc) end
        else
            -- two coloums
            for i=1,#t.option do
                print(string.format("%-1.1s %-17.17s %-1.1s %-17.17s", t.option[i].key, t.option[i].desc, t.option[i].key, t.option[i].desc))
            end
        end
--]]
    end

    -- print the final question
    if t.question then write(t.question.." ") end

    -- print any messages
    coredisplay.UpdateToDisplay()

    -- wait for input...
    while not success do
        if t.option then
            -- wait for the key
            response = ReadChar()

            -- find the right function to run
            for i=1,#t.option do
                if not success and response == t.option[i].key then
                    success = t.option[i].func(t.option[i].param, response)
                end
            end
        else
            -- when there are no options, read a line
            success = t.func(t.param, ReadLine())
        end
    end

    -- run the function -- weird again, can never happen !!!
--    	if func then func(response, param) end
end

function IndexToKey(i) if i < 10 then return tostring(i) else return string.char(87 + i) end end

function ReadChar()
    -- just wait for a char event
    while true do
        local event, c = os.pullEvent()
        if event == "char" then return c end
    end
end

function ReadLine() return read() end

-- for executing custom code
function ExecuteCode(t, code)
    -- first screen?
    if t.boss == nil then
        coredisplay.NextScreen({
            clear   = true,
            intro   = "Who is runnig the show?",
            option  = {
                {key = "r", desc = "Rutger",  			func = ExecuteCode,	param = {boss = 'rutger'}},
                {key = "g", desc = "Guido",				func = ExecuteCode,	param = {boss = 'guido'}},
                {key = "x", desc = "Back to main menu",	func = function () return true end},
            },
            question	= "Make your choice",
        })

        -- next screen
        return true
    else
        -- mark as not loaded
        package.loaded[t.boss] = nil

        -- require the package
             if t.boss == 'rutger' then require 'rutger'
        else if t.boss == 'guido'  then require 'guido'
        end end

        -- done, but stay on screen
        return false
    end
end

function ExecuteXObjTest(t, menuName, menuOptions, ExecuteXObjTest)
    if type(t) == "table" and type(t.func) == "string" and type(t.filename) == "string" then
        -- execute function

        -- seems our user has made a choice
        local f = MethodExecutor.GetModuleMethod(t.filename, t.func)
        if not f then corelog.Warning("coredisplay.ExecuteXObjTest(...): Function "..t.func.." not found in file "..t.filename) return false end

        -- executing the code as wordt
        coretest.AddTest(f, nil, t.filename.."."..t.func.."()")
        coredisplay.UpdateToDisplay(t.filename.."."..t.func.." is queued for execution")

        -- stay on the testing screen when executing an command
        return false

    elseif type(t) == "table" and type(t.filename) == "string" then
        -- test functions screen

        -- get file
        local file = moduleRegistry:getRegistered(t.filename)
        if not file then corelog.Warning("coredisplay.ExecuteXObjTest(...): File "..t.filename.." not found in moduleRegistry") return false end

        -- variables
        local functions	= {}
        local options	= {}

        -- get all functions in test file / object
        for key, value in pairs(file) do
            -- add key if the value is a function and name starts with T_
            if type(value) == "function" and string.find(key, "T_") then table.insert(functions, key) end
        end

        -- order this shit
        table.sort(functions)

        -- create the list of options
        for i, name in ipairs(functions) do options[i] = {key = IndexToKey(i), desc = string.sub(name,3,-1), func = ExecuteXObjTest, param = {func = name, filename = t.filename}} end
        table.insert(options, {key = "x", desc = "Back to "..menuName.." test menu", func = ExecuteXObjTest, param = {}})

        -- this is the next screen
        coredisplay.NextScreen({
            clear       = true,
            intro       = "Choose a "..menuName.." test function",
            option      = options,
            question    = "Make your choice"
        })
    elseif type(t) ~= "table" or type(t.func) ~= "string" then
        -- test files screen

        if menuOptions then
            -- this is the next screen
            coredisplay.NextScreen({
                clear       = true,
                intro       = "Choose a "..menuName.." test type",
                option      = menuOptions,
                question    = "Make your choice"
            })
        end
    else
        corelog.WriteToLog("ExecuteXObjTest: should not happen")
    end

    -- done
    return true
end

-- for loading an event from file
function LoadEvent(t)
    -- first screen
    if t == nil or t.dir == nil then
        local list	= fs.list("/event/")
        local tmp	= {}

        -- create the list of options
        for i=1,#list do tmp[i] = {key = IndexToKey(i), desc = list[i], func = LoadEvent, param = {dir = list[i]}} end
        tmp[#tmp + 1] = {key = "x", desc = "Back to main menu", func = function () return true end}

        -- this is the next screen
        coredisplay.NextScreen({
            clear       = true,
            intro       = "Choose a protocol",
            option      = tmp,
            question    = "Make your choice"
        })

    -- second screen
    elseif t.dir and t.filename == nil then
        local list	= fs.list( "/event/"..t.dir.."/" )
        local tmp	= {}

        -- create the list of options
        print(#list)
        for i=1,#list do tmp[i] = {key = IndexToKey(i), desc = list[i], func = LoadEvent, param = {dir = t.dir, filename = list[i]}} end
        tmp[#tmp + 1] = {key = "x", desc = "Back to protocol selection", func = LoadEvent, param = {}}

        -- this is the next screen
        coredisplay.NextScreen({
            clear       = true,
            intro       = "Choose a file (protocol="..t.dir..")",
            option      = tmp,
            question    = "Make your choice"
        })
    elseif t.dir and t.filename then
        local envelope = coreutils.ReadTableFromFile("/event/"..t.dir.."/"..t.filename)
        os.queueEvent("modem_message", nil, envelope.to, envelope.from, textutils.serialize(envelope), envelope.distance)
    end

    -- always good!
    return true
end

-- local function to update the display with messages for the user.
function coredisplay.UpdateToDisplay(update, alive)
    local now	= os.clock()
    alive       = alive or 5

    -- do we have a new update?
    if update then db.update[#db.update + 1] = {text = update, endTime = now + alive} end

    -- presever the current coordinates
    local x, y = term.getCursorPos()
    local c = #db.update

    -- write second update?
    if c > 1 then
        term.setCursorPos( 1, db.y - 0 )
        term.clearLine()
        term.write( db.update[c - 1].text )
    end

    -- write third update?
    if c > 0 then
        term.setCursorPos( 1, db.y - 1 )
        term.clearLine()
        term.write( db.update[c].text )
    end

    -- resotre cursor
    term.setCursorPos( x, y )
end

function coredisplay.MainMenuAddItem(key, desc, func, param)
    if type(key) ~= "string" and type(desc) ~= "string" and type(func) ~= "function" then
        return corelog.Warning("coredisplay.MainMenuAddItem(): New menu item ignored")
    end

    -- default value
    if type(param) ~= "table" then param = {} end

    -- before init.... not so nice
    if db.defaultMainMenu == nil then coredisplay.Init() end

    -- add the menu item
    local o = db.defaultMainMenu.option
    table.insert(o, #o, {key = string.sub(key, 1, 1), desc = desc, func = func, param = param})
end

-- function to get or set the main menu
function coredisplay.MainMenu(t)
    if t then db.mainmenu = t
    else return db.mainmenu
    end
end

-- a nice default main menu, very usefull
function coredisplay.DefaultMainMenu()
    return db.defaultMainMenu
end

return coredisplay
