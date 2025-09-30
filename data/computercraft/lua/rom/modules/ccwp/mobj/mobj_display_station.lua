-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ILObj = require "i_lobj"
local IMObj = require "i_mobj"
local IWorker = require "i_worker"
local coredht = require "coredht"
local coreutils = require "coreutils"
local DisplayStation = Class.NewClass(ObjBase, ILObj, IMObj, IWorker)

--[[
    << a full size monitor has 40 lines and 82 char per line >>

    The DisplayStation Worker represents a station in the minecraft world and provides (production) services for developers to operate on that DisplayStation.

    A DisplayStation has at least 2 displays (consisting of minecraft monitors) attached. The main menu of the DisplayStation should at a minimum enable
    selecting what content is displayed on each of those displays.

    For seen content to display on the displays
        1)  Logging
        2)  Worker overview
        3)  Projects
        4)  Assignments (open, staffed, ...)
        5)  Inventory on stock
        6)  mobj's overview
--]]

local coresystem        = require "coresystem"
local coreassignment    = require "coreassignment"
local coreevent         = require "coreevent"
-- local coredisplay       = require "coredisplay"
local corelog           = require "corelog"

local InputChecker      = require "input_checker"
local ObjTable          = require "obj_table"
local Block             = require "obj_block"
local Location          = require "obj_location"
local CodeMap           = require "obj_code_map"
local LayerRectangle    = require "obj_layer_rectangle"

local enterprise_employment

local db = {
    -- facts
    maxLines            = 40,
    maxCharPerLine      = 82,

    -- basic parameters
    loggerChannel       = 65534,
    protocol            = "mobj_display_station",
    heartbeatTimer      = 100,

    -- monitor handlers
    monitorLeft         = nil,
    monitorRight        = nil,

    -- data containers
    statusInfo          = {},

    -- screen defaults
    textScale           = 1,

    -- screen holders
    loggingScreen       = {},
    workerScreen        = {textScale=2, maxLines=20},
    projectScreen       = {},
    assignmentScreen    = {textScale=2, maxLines=20},
    inventoryScreen     = {},
    mobjScreen          = {},

    -- general holder of screens
    registeredScreens   = {},
    screenDefinitions   = {},

    -- what screen is on which monitor?
    leftMonitorScreen   = nil,  -- can't be set here
    rightMonitorScreen  = nil,  -- can't be set here

    -- about myself
    iAmDisplayStation    = false,
}

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

-- ToDo: add initialising additional fields here (like e.g. what to display on which display)
function DisplayStation:_init(...)
    -- get & check input from description
    local checkSuccess, workerId, isActive, baseLocation = InputChecker.Check([[
        Initialise a DisplayStation.

        Parameters:
            workerId                + (number) workerId of the DisplayStation
            isActive                + (boolean) whether the DisplayStation is active
            baseLocation            + (Location) base location of the DisplayStation
    ]], ...)
    if not checkSuccess then corelog.Error("DisplayStation:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._workerId          = workerId
    self._isActive          = isActive
    self._baseLocation      = baseLocation
end

-- ToDo: add the same additional fields here in a similair way
function DisplayStation:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a DisplayStation.

        Parameters:
            o                           + (table, {}) with object fields
                _workerId               - (number) workerId of the DisplayStation
                _isActive               - (boolean, false) whether the DisplayStation is active
                _baseLocation           - (Location) location of the DisplayStation
    ]], ...)
    if not checkSuccess then corelog.Error("DisplayStation:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function DisplayStation:getClassName()
    return "DisplayStation"
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function DisplayStation:construct(...)
    -- get & check input from description
    local checkSuccess, workerId, baseLocation = InputChecker.Check([[
        This method constructs a DisplayStation instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        The constructed DisplayStation is not yet saved in the LObjHost.

        Return value:
                                        - (DisplayStation) the constructed DisplayStation

        Parameters:
            constructParameters         - (table) parameters for constructing the DisplayStation
                workerId                + (number) workerId of the DisplayStation
                baseLocation            + (Location) base location of the DisplayStation
    ]], ...)
    if not checkSuccess then corelog.Error("DisplayStation:construct: Invalid input") return nil end

    -- determine DisplayStation fields
    -- ToDo: add default values for additional fields here (like e.g. what to display on which display). Possibly them to constructParameters if you want to set defaults from a master/ world script later

    -- construct new DisplayStation
    local obj = DisplayStation:newInstance(workerId, false, baseLocation:copy()) -- ToDo: pass additional fields in here

    -- end
    return obj
end

function DisplayStation:destruct()
    --[[
        This method destructs a DisplayStation instance.

        The DisplayStation is not yet deleted from the LObjHost.

        Return value:
                                        - (boolean) whether the DisplayStation was succesfully destructed.

        Parameters:
    ]]

    -- release input/output locators
    local destructSuccess = true

    -- end
    return destructSuccess
end

function DisplayStation:getId()
    return tostring(self._workerId)
end

function DisplayStation:getWIPId()
    --[[
        Returns the unique Id of the DisplayStation used for administering WIP.
    ]]

    return self:getClassName().." "..self:getId()
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function DisplayStation:getBaseLocation() return self._baseLocation end

local function Computer_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["C"]   = Block:newInstance("computercraft:computer_normal", 0, -1),
        }),
        CodeMap:newInstance({
            [1] = "C",
        })
    )
end

local function ComputerDismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [1] = " ",
        })
    )
end

local function Modem_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["M"]   = Block:newInstance("computercraft:wireless_modem_normal"),
        }),
        CodeMap:newInstance({
            [1] = "M",
        })
    )
end

local function ModemDismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [1] = " ",
        })
    )
end

local function Monitor_Only_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["M"]   = Block:newInstance("computercraft:monitor_normal"),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
        }),
        CodeMap:newInstance({
            [1] = "MMMMMMMM?MMMMMMMM",
        })
    )
end

local function Dismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
        }),
        CodeMap:newInstance({
            [8] = "                 ",
            [7] = "                 ",
            [6] = "                 ",
            [5] = "                 ",
            [4] = "                 ",
            [3] = "                 ",
            [2] = "                 ",
            [1] = "???????   ???????",
        })
    )
end

function DisplayStation.GetBuildBlueprint(...)
    -- get & check input from description
    local checkSuccess, baseLocation = InputChecker.Check([[
        This method returns a blueprint for building a DisplayStation in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            constructParameters         - (table) parameters for constructing the DisplayStation
                baseLocation            + (Location) base location of the DisplayStation
    ]], ...)
    if not checkSuccess then corelog.Error("DisplayStation.GetBuildBlueprint: Invalid input") return nil, nil end

    -- layer list
    local layerList = {
        { startpoint = Location:newInstance(3, 3, 2), buildDirection = "Down", layer = Computer_layer()},
    }
    for i=7,2,-1 do
        table.insert(layerList, { startpoint = Location:newInstance(-5, 3, i), buildDirection = "Front", layer = Monitor_Only_layer()})
    end
    table.insert(layerList, { startpoint = Location:newInstance(3, 2, 2), buildDirection = "Front", layer = Modem_layer()})

    -- escapeSequence
    local escapeSequence = {}

    -- blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence,
    }

    -- buildLocation
    local buildLocation = baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

function DisplayStation:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the DisplayStation in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- layerList
    local layerList = {
        { startpoint = Location:newInstance(3, 2, 2), buildDirection = "Down", layer = ModemDismantle_layer()},
        { startpoint = Location:newInstance(-5, 3, 0), buildDirection = "Front", layer = Dismantle_layer()},
        { startpoint = Location:newInstance(3, 3, 0), buildDirection = "Down", layer = ComputerDismantle_layer()},
    }

    -- escapeSequence
    local escapeSequence = {}

    -- blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence
    }

    -- buildLocation
    local buildLocation = self._baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

--    _                 _
--   | |               | |
--   | | ___   ___ __ _| |
--   | |/ _ \ / __/ _` | |
--   | | (_) | (_| (_| | |
--   |_|\___/ \___\__,_|_|
--
--

local function ScreenToMonitor(screen, monitor)
    -- right monitor has bigger text size
    monitor.setTextScale(screen.textScale or db.textScale)

    -- loop all lines
    for i=1, (screen.maxLines or db.maxLines) do

        -- do the line
        monitor.setCursorPos(1, i)
        monitor.clearLine()
        monitor.write(screen[i] or "")
    end
end

local function ClearScreen(screen)
    -- loop all lines, make them empty
    for i=1, db.maxLines do screen[i] = "" end
end

local function ScreenScroll(screen)
    -- check input, do nothing without a table
    if type(screen) ~= "table" then return screen end

    -- remove the first element, move the other lines
    -- table.remove(screen, 1) -- this should be faster, but does not work...
    for i=1, (screen.maxLines or db.maxLines) - 1 do screen[i] = screen[i + 1] end

    -- last line should be empty now
    screen[(screen.maxLines or db.maxLines)] = ""

    -- done
    return screen
end

local function ScreenWriteLine(screen, line)

    -- start with scrolling the screen
    ScreenScroll(screen)

    -- add the new line to the bottom
    screen[(screen.maxLines or db.maxLines)] = line
end

local function UpdateMonitors()
    -- update the screen
    ScreenToMonitor(db.leftMonitorScreen,   db.monitorLeft)
    ScreenToMonitor(db.rightMonitorScreen,  db.monitorRight)
end

local function UpdateStatusScreen()
    -- clear the screen
    ClearScreen(db.workerScreen)

    -- sort the keys?
    local allKeys = {}
    for id, _ in pairs(db.statusInfo) do table.insert(allKeys, id) end
    table.sort(allKeys)

	-- here we go, loop all known workers
	for _, id in ipairs(allKeys) do

        -- get the data
        local data = db.statusInfo[id]

		-- check for dead mates
		local deadMessage		= "DEAD "
		if os.clock() - data.heartbeat < (db.heartbeatTimer / 20) or id == os.getComputerID() then deadMessage = "" end

        -- making stuff nicer
        if data.fuelLevel == 0 and data.kind == "turtle" then data.fuelLevel = "empty" end
        if data.fuelLevel == 0 and data.kind ~= "turtle" then data.fuelLevel = "n/a"   end
        if data.kind == "" then data.kind = "unknown" end

		-- write!
		ScreenWriteLine(db.workerScreen, "")
		ScreenWriteLine(db.workerScreen, deadMessage..(data.kind or "unknown kind").." "..id..":")
		ScreenWriteLine(db.workerScreen, "fuel: "..data.fuelLevel)
		ScreenWriteLine(db.workerScreen, "label: "..(data.label or "unknown"))
	end

    -- update shit
    UpdateMonitors()
end

local function UpdateStatus(statusData)

    -- make sure the status data is valid
    if type(statusData) == "table" then
        -- test input, replace with default if needed
        if not statusData.me						then return end
        if type(statusData.kind)	  ~= "string"	then statusData.kind	    = "unknown kind" end
        if type(statusData.fuelLevel) ~= "number"	then statusData.fuelLevel	= 0 end
        if type(statusData.group)	  ~= "string"	then statusData.group		= "" end
        if type(statusData.message)	  ~= "string"	then statusData.message		= "" end
        if type(statusData.subline)	  ~= "string"	then statusData.subline		= "" end
        if type(statusData.details)	  ~= "string"	then statusData.details		= "" end

        -- store the info in our var
        if type(db.statusInfo[statusData.me]) ~= "table" then db.statusInfo[statusData.me] = {} end
        db.statusInfo[statusData.me].kind				= statusData.kind
        db.statusInfo[statusData.me].fuelLevel			= statusData.fuelLevel
        db.statusInfo[statusData.me].heartbeat			= os.clock()
        db.statusInfo[statusData.me][statusData.group]	= statusData
    end

    -- time to update the screen
    UpdateStatusScreen()
end

local function UpdateScreens(screenId)
    local screenDef = db.screenDefinitions[screenId]

    -- get the data from the dht
    local allData = coredht.GetData(table.unpack(screenDef.dhtDataKeys))
    if type(allData) ~= "table" then return end

    -- sort the keys?
    local allKeys = {}
    for id, _ in pairs(allData) do table.insert(allKeys, id) end
    table.sort(allKeys)

    -- setup the screen
    ClearScreen(db[screenDef.screenId])

    -- handy when screen is empty
    ScreenWriteLine(db[screenDef.screenId], screenDef.intro)

    -- loop the table
    for _, key in ipairs(allKeys) do

        -- da project
        local data = allData[ key ]

        -- loop the lines
        for _, lineDef in ipairs(screenDef.lines) do

            -- get the values
            local valueList = {}
            for _, varDef in ipairs(lineDef.varList) do

                -- walk through the data by keys
                local dataRef   = data
                for _, varDefItem in ipairs(varDef) do

                    -- next step
                    if type(dataRef) == "table" then dataRef = dataRef[varDefItem] end
                end

                -- add the value
                if type(dataRef) ~= "table" then table.insert(valueList, dataRef) end
            end

            -- print the line
            ScreenWriteLine(db[screenDef.screenId], string.format(lineDef.formatString, table.unpack(valueList)))
        end
    end

    -- show us!
    UpdateMonitors()
end

local function UpdateProjects()
    local screenDef = {
        screenName      = "Projects",
        screenId        = "projectScreen",
        dhtDataKeys     = {"enterprise_projects"},
        intro           = ">>> Hieronder alle projecten <<<",
        lines           = {
            {
                formatString    = "",
                varList         = {},
            },
            {
                formatString    = "%s: %s",
                varList         = {{"projectId"}, {"projectMeta", "title"}},
            },
            {
                formatString    = "%s",
                varList         = {{"projectMeta", "description"}},
            },
            {
                formatString    = "currentStep: %s",
                varList         = {{"currentStep"}},
            },
        }
    }

    local allData = coredht.GetData(table.unpack(screenDef.dhtDataKeys))
    if type(allData) ~= "table" then return end

    -- sort the keys?
    local allKeys = {}
    for id, _ in pairs(allData) do table.insert(allKeys, id) end
    table.sort(allKeys)

    -- setup the screen
    ClearScreen(db[screenDef.screenId])

    -- handy when screen is empty
    ScreenWriteLine(db[screenDef.screenId], screenDef.intro)

    -- loop the table
    for _, key in ipairs(allKeys) do

        -- da project
        local data = allData[ key ]

        -- loop the lines
        for _, lineDef in ipairs(screenDef.lines) do

            -- get the values
            local valueList = {}
            for _, varDef in ipairs(lineDef.varList) do

                -- walk through the data by keys
                local dataRef   = data
                for _, varDefItem in ipairs(varDef) do

                    -- next step
                    if type(dataRef) == "table" then dataRef = dataRef[varDefItem] end
                end

                -- add the value
                if type(dataRef) ~= "table" then table.insert(valueList, dataRef) end
            end

            -- print the line
            ScreenWriteLine(db[screenDef.screenId], string.format(lineDef.formatString, table.unpack(valueList)))
        end
    end

    -- show us!
    UpdateMonitors()
end

local function UpdateAssignment()
    -- get the data
    local assignmentList = coredht.GetData("enterprise_assignmentboard", "assignmentList")
    if type(assignmentList) ~= "table" then return end

    -- sort the keys?
    local allKeys = {}
    for id, _ in pairs(assignmentList) do table.insert(allKeys, id) end
    table.sort(allKeys)

    -- setup the screen
    ClearScreen(db.assignmentScreen)

    -- handy when screen is empty
    ScreenWriteLine(db.assignmentScreen, ">>> Hieronder alle assignments <<<")

    -- loop the table
    for _, assignmentId in ipairs(allKeys) do

        -- da assignment
        local assignment = assignmentList[ assignmentId ]

		ScreenWriteLine(db.assignmentScreen, "")
		ScreenWriteLine(db.assignmentScreen, assignmentId..": "..assignment.status)
		ScreenWriteLine(db.assignmentScreen, assignment.taskCall._moduleName..".")
		ScreenWriteLine(db.assignmentScreen, assignment.taskCall._methodName.."()")
    end

    -- show us!
    UpdateMonitors()
end

local function UpdateInventory()
    local chests = coredht.GetData("enterprise_storage", "objects", "class=Chest")
    if type(chests) ~= "table" then return end

    -- loop the table
    local inventory = {}
    for _, chest in pairs(chests) do

        -- loop the inventory
        for _, item in pairs(chest._inventory._slotTable) do inventory[ item.name ] = (inventory[ item.name ] or 0) + item.count end
    end

    -- sort the keys?
    local allKeys = {}
    for itemName, _ in pairs(inventory) do table.insert(allKeys, itemName) end
    table.sort(allKeys)

    -- setup the screen
    ClearScreen(db.inventoryScreen)

    -- handy when screen is empty
    ScreenWriteLine(db.inventoryScreen, ">>> Hieronder alle inventory <<<")

    -- loop the table
    for _, itemName in ipairs(allKeys) do

        -- da project
        local itemCount = inventory[ itemName ]

        -- to the screen
		ScreenWriteLine(db.inventoryScreen, itemName..": "..itemCount)
    end

    -- show us!
    UpdateMonitors()
end

local function dhtTrigger(screenId)
    -- just do the update
    UpdateScreens(screenId)
end

local function ProjectsTrigger()
    -- simple, pass through
    UpdateProjects()
end

local function AssignmentboardTrigger()
    -- simple, pass through
    UpdateAssignment()
end

local function InventoryTrigger()
    -- simple, pass through
    UpdateInventory()
end

local function SetMonitorPurpose(side, purpose)
    -- get purpose as text also
    local purposeText = "logging"
    if purpose == db.workerScreen       then purposeText = "worker"     end
    if purpose == db.projectScreen      then purposeText = "project"    UpdateProjects()    end
    if purpose == db.assignmentScreen   then purposeText = "assignment" UpdateAssignment()  end
    if purpose == db.inventoryScreen    then purposeText = "inventory"  end
    if purpose == db.mobjScreen         then purposeText = "mobj"       end

    -- left side?
    if side == "left"  then
        -- set the value
        db.leftMonitorScreen  = purpose

        -- update the monitor
        ScreenToMonitor(db.leftMonitorScreen,  db.monitorLeft)

        -- set setting (test)
        settings.set(db.protocol..':'..'left', purposeText)
        settings.save()
    end

    -- right side?
    if side == "right" then
        -- set the value
        db.rightMonitorScreen = purpose

        -- update the monitor
        ScreenToMonitor(db.rightMonitorScreen, db.monitorRight)

        -- set setting (test)
        settings.set(db.protocol..':'..'right', purposeText)
        settings.save()
    end
end

local function SetDhtTriggers()

    -- loop all definitions
    for _, screenDef in ipairs(db.screenDefinitions) do

        -- add the trigger
        coredht.RegisterTrigger(dhtTrigger, db.protocol, screenDef.screenId, table.unpack(screenDef.dhtDataKeys))
    end
end

--                _     _ _
--               | |   | (_)
--    _ __  _   _| |__ | |_  ___
--   | '_ \| | | | '_ \| | |/ __|
--   | |_) | |_| | |_) | | | (__
--   | .__/ \__,_|_.__/|_|_|\___|
--   | |
--   |_|

function DisplayStation.LoggerLine(line)
	-- write the message on the monitor
    ScreenWriteLine(db.loggingScreen, line)

    -- new info means we need to update both monitors
    UpdateMonitors()
end

function DisplayStation.SetStatus(group, message, subline, details)
	-- what kind are we?
	local kind = "computer"	-- default type
	if turtle   then kind = "turtle" end
	if pocket   then kind = "pocket" end
	if commands then kind = "command computer" end

	-- get our fuel level
	local fuelLevel = 0
	if turtle then fuelLevel = turtle.getFuelLevel() end

	-- all relevant information for the status update together
	local statusUpdate = {
		me			= os.getComputerID(),
		kind		= kind,
		fuelLevel	= fuelLevel,
		group		= group,
		message		= message,
		subline		= subline,
		details		= details
	}

    -- update function right aways if we are a dispay station
	if db.iAmDisplayStation then UpdateStatus(statusUpdate) end

	-- send the info by messasge to every display station around the world
	coreevent.SendMessage({
		channel		= db.loggerChannel,
		protocol	= db.protocol,
		subject		= "status update",
		message		= statusUpdate})
end

function DisplayStation.AddScreenDefinition(screenDefinition)

    -- create unique id
    local screenId = coreutils.NewId
    screenDefinition.screenId = screenId

    -- store the data registeredScreens
    db.screenDefinitions[screenId] = screenDefinition

    -- create the screen holder, start empty
    db.registeredScreens[screenId] = {
        screenName  = screenDefinition.screenName,
        screenId    = screenId,
        screen      = {},
    }

    -- are we the one?
    if db.iAmDisplayStation then SetDhtTriggers() end

    -- done
    return "Thank you, I'll take it from here"
end

--                         _
--                        | |
--     _____   _____ _ __ | |_ ___
--    / _ \ \ / / _ \ '_ \| __/ __|
--   |  __/\ V /  __/ | | | |_\__ \
--    \___| \_/ \___|_| |_|\__|___/
--
--

local function DoEventWriteToLog(subject, envelope)
    -- pass through function
    DisplayStation.LoggerLine(envelope.from ..":".. (envelope.message.text or "no text?!?"))
end

local function DoEventStatusUpdate(subject, envelope)
	-- do the status update
	UpdateStatus(envelope.message)
end

local function DoEventAssignmentUpdate(subject, envelope)
	-- do the status update
	UpdateAssignment()
end

local function DoEventHeartbeatTimer()
    -- pass request to coreassignemnt
    coreassignment.SendHearbeatRequests()

	-- do this event again in 5
	coreevent.CreateTimeEvent(db.heartbeatTimer, db.protocol, "heartbeat timer")

	-- update the status (weird here)
	UpdateStatus()
end

local function ProcessLoggingCallback(message)
   	-- ToDo: update log when I am a display station
    -- send a message to who ever is the display station
	coreevent.SendMessage({
		channel		= db.loggerChannel,
		protocol	= db.protocol,
		subject		= "write to log",
		message		= {text = message}
    })
end

-- setup logger hook
coreevent.EventReadyFunction(function () corelog.SetLoggerFunction(ProcessLoggingCallback) end)

local function ProcessReceiveHeartbeat(subject, envelope)
	-- remember this one is alive
	if type(db.statusInfo[envelope.from]) ~= "table" then db.statusInfo[envelope.from] = {} end
	db.statusInfo[envelope.from].heartbeat  = os.clock()
	db.statusInfo[envelope.from].fuelLevel  = envelope.message.fuelLevel
	db.statusInfo[envelope.from].label      = envelope.message.label

    -- time to update the screen
    UpdateStatusScreen()
end

--    _______          __        _
--   |_   _\ \        / /       | |
--     | |  \ \  /\  / /__  _ __| | _____ _ __
--     | |   \ \/  \/ / _ \| '__| |/ / _ \ '__|
--    _| |_   \  /\  / (_) | |  |   <  __/ |
--   |_____|   \/  \/ \___/|_|  |_|\_\___|_|

function DisplayStation:getWorkerId()
    --[[
        Get the DisplayStation workerId.

        Return value:
                                - (number) the DisplayStation workerId
    ]]

    -- end
    return self._workerId
end

local subject = "input Chest timer"

-- ToDo: here you could add timers for this specific DisplayStation if you thick that is a good idea (e.g. to ping other Workers to log them in Worker overview)
-- ToDo: note: commented code is how it is currently done in the UserStation
-- ToDo: note: alternative is to implement it using reocurring assignment
function DisplayStation:activate()
    -- check current Worker
    if self:getWorkerId() ~= os.getComputerID() then
        corelog.Warning("DisplayStation:activate() not supported on DisplayStation(="..self:getWorkerId()..") from other computer(="..os.getComputerID()..") => not adding event")
    else
		-- get monitor handles
		db.monitorLeft		= peripheral.wrap("left")
		db.monitorRight     = peripheral.wrap("right")

		-- fresh start
		db.monitorLeft.clear()
		db.monitorRight.clear()

		-- no blinking!
		db.monitorLeft.setCursorBlink(false)
		db.monitorRight.setCursorBlink(false)

        -- create lookup table
        local lookupTab     = {
            logging     = db.loggingScreen,
            worker      = db.workerScreen,
            project     = db.projectScreen,
            assignment  = db.assignmentScreen,
            inventory   = db.inventoryScreen,
            mobj        = db.mobjScreen,
        }

        -- set the monitor purpose from settings
        db.leftMonitorScreen  = lookupTab[ settings.get(db.protocol..':'..'left',  "logging") ]
        db.rightMonitorScreen = lookupTab[ settings.get(db.protocol..':'..'right', "worker")  ]

        -- just update, not sure if need but who cares
        UpdateProjects()
        UpdateAssignment()
        UpdateInventory()

		-- listen to the logger port
		coreevent.OpenChannel(db.loggerChannel, db.protocol)

		-- listen to our events
		coreevent.AddEventListener(DoEventWriteToLog,       db.protocol, "write to log")
		coreevent.AddEventListener(DoEventStatusUpdate,     db.protocol, "status update")
		coreevent.AddEventListener(DoEventAssignmentUpdate, db.protocol, "assignment update")
		coreevent.AddEventListener(DoEventHeartbeatTimer,   db.protocol, "heartbeat timer")

        -- setup heartbeat hook
        coreassignment.SetHeartbeatFunction(ProcessReceiveHeartbeat)

        -- setup heartbeat timer
	    coreevent.CreateTimeEvent(db.heartbeatTimer,        db.protocol, "heartbeat timer")

        -- setup dht trigger
        coredht.RegisterTrigger(ProjectsTrigger,        db.protocol, "dummy", "enterprise_projects")
        coredht.RegisterTrigger(AssignmentboardTrigger, db.protocol, "dummy", "enterprise_assignmentboard", "assignmentList")
        coredht.RegisterTrigger(InventoryTrigger,       db.protocol, "dummy", "enterprise_storage", "objects", "class=Chest")

		-- show who's boss!
        db.iAmDisplayStation = true
		corelog.WriteToLog("--- starting up as display station ---")
--		DisplayStation.SetStatus("project", "I am the display station", "Just ignore me", "Have a nice day")
    end

    -- set active
    self._isActive = true

    -- end
    return self:isActive()
end

-- function DisplayStation.DoEventInputChestTimer(_, outputLocator)
--     -- add the work, the real stuff
--     coretask.AddWork(role_conservator.CheckOutputChest, outputLocator, "role_conservator.CheckOutputChest()")

--     -- create new event
--     coreevent.CreateTimeEvent(20 * 15, "mobj_user_station", subject, outputLocator)
-- end

function DisplayStation:deactivate()
    -- check current Worker
    if self:getWorkerId() ~= os.getComputerID() then
        corelog.Warning("DisplayStation:deactivate() not supported on DisplayStation(="..self:getWorkerId()..") from other computer(="..os.getComputerID()..") => not removing event")
    else
        -- remove timer
        -- coreevent.RemoveEventListener("mobj_user_station", subject)
    end

    -- set deactive
    self._isActive = false

    -- end
    return not self:isActive()
end

function DisplayStation:isActive()
    return self._isActive == true
end

function DisplayStation:reset()
    -- reset fields
    -- nothing to do for now

    -- save
    -- enterprise_employment = enterprise_employment or require "enterprise_employment"
    -- local objLocator = enterprise_employment:saveObj(self)
    -- if not objLocator then corelog.Error("DisplayStation:reset: Failed saving DisplayStation") return nil end
end

function DisplayStation:getWorkerLocation()
    return self:getBaseLocation():getRelativeLocation(3, 3, 2) -- note: location of DisplayStation computer relative to this DisplayStation baseLocation
end

function DisplayStation:getWorkerResume()
    --[[
        Get DisplayStation resume for selecting Assignment's.

        The resume gives information on the DisplayStation and is used to determine if the DisplayStation is (best) suitable to take an Assignment.
            This is can e.g. be used to indicate location, fuel level and equiped items.

        Return value:
            resume              - (table) DisplayStation "resume" to consider in selecting Assignment's
    --]]

    -- end
    return {
        workerId        = self:getWorkerId(),
        location        = self:getWorkerLocation(),
    }
end

-- used in the menu
local function MenuSetPurpose(tab) SetMonitorPurpose(tab.side, tab.purpose) end

-- ToDo: this is the hook to put the menu of the DisplayStation
function DisplayStation:getMainUIMenu()
    --[[
        Get the main (start) UI menu of the DisplayStation.

        This menu can be used in conjuction with coredisplay.MainMenu.

        Return value:
                                - (table)
                clear           - (boolean) whether or not to clear the display,
                func	        - (function) menu function to call
                param	        - (table, {}) parameter to pass to menu function
                intro           - (string) intro to print
                question        - (string, nil) final question to print
    ]]

    -- da main menu
    return {
        clear   = true,
        intro   = "Choose what you want to see on the screens!",
        option  = {
            {key = "w", desc = "Logging",          	    func = MenuSetPurpose,	    param = {side="left",  purpose=db.loggingScreen     }},
            {key = "e", desc = "Worker overview",       func = MenuSetPurpose,	    param = {side="left",  purpose=db.workerScreen      }},
            {key = "r", desc = "Projects",              func = MenuSetPurpose,	    param = {side="left",  purpose=db.projectScreen     }},
            {key = "t", desc = "Assignments",          	func = MenuSetPurpose,	    param = {side="left",  purpose=db.assignmentScreen  }},
            {key = "y", desc = "Inventory on stock",    func = MenuSetPurpose,	    param = {side="left",  purpose=db.inventoryScreen   }},
            {key = "u", desc = "mobj's overview",       func = MenuSetPurpose,	    param = {side="left",  purpose=db.mobjScreen        }},
            {key = "i", desc = "blank",                 func = MenuSetPurpose,	    param = {side="left",  purpose={}                   }},
            {key = "q", desc = "Quit",                  func = coresystem.DoQuit,	param = {}},
            {key = "s", desc = "Logging",          	    func = MenuSetPurpose,	    param = {side="right", purpose=db.loggingScreen     }},
            {key = "d", desc = "Worker overview",       func = MenuSetPurpose,	    param = {side="right", purpose=db.workerScreen      }},
            {key = "f", desc = "Projects",              func = MenuSetPurpose,	    param = {side="right", purpose=db.projectScreen     }},
            {key = "g", desc = "Assignments",          	func = MenuSetPurpose,	    param = {side="right", purpose=db.assignmentScreen  }},
            {key = "h", desc = "Inventory on stock",    func = MenuSetPurpose,	    param = {side="right", purpose=db.inventoryScreen   }},
            {key = "j", desc = "mobj's overview",       func = MenuSetPurpose,	    param = {side="right", purpose=db.mobjScreen        }},
            {key = "k", desc = "blank",                 func = MenuSetPurpose,	    param = {side="right", purpose={}                   }},
--            {key = "l", desc = "Quit",                  func = coresystem.DoQuit,	  param = {}},
        },
        question	= "Make your choice",
    }
end

-- ToDo: consider adding assigment filter criteria if you want the DisplayStation to only take specific assignments.
function DisplayStation:getAssignmentFilter()
    --[[
        Get assignment filter for finding the next best Assignment for the DisplayStation.

        The assignment filter is used to indicate to only accept assignments that satisfy certain conditions. This can e.g. be used
            to only accept assignments that are ment for this DisplayStation (i..e workerId) or only those with high priority.

        Return value:
            assignmentFilter    - (table) filter to apply in finding an Assignment
    --]]

    -- end
    return {
    }
end

return DisplayStation
