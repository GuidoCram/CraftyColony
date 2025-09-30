-- define module
local coredht = {}

-- ToDo: add proper module description
--[[
    This module ...
--]]

local coreevent = require "coreevent"
local corelog   = require "corelog"
local coreutils = require "coreutils"
local coretask  = require "coretask"

local InputChecker

local db                = { _version = 0 }
local dbHistory         = { _next = 1, _max = 30}
local dbTriggers        = {}
local dhtReady          = false
local dhtReadyFunctions = {}
local writeToFileQueued = false
local filename          = "/db/dht.lua"
local fileTime          = 0                 -- for automatic detection of file change by user editing
local logfile           = "/log/dht.txt"
local protocol          = "core:dht"

-- initializes the dht
function coredht.Init()
    InputChecker = InputChecker or require "input_checker"

	-- read database from disk
	db = coreutils.ReadTableFromFile(filename)

	-- in case we start for the first time, set a _version
    if type(db) ~= "table"  then db = {}            end
    if db._version == nil   then db._version = 0    end
end

local function CoreDHTEventReadySetup()
	-- startup, read from disk or get data from peers? Why not both!
	coreevent.SendMessage({protocol=protocol, subject="get all data"})

    -- timer instellen voor het geval dat we geen reactie krijgen
    coreevent.CreateTimeEvent(5, protocol, "all data timer")
end

local function SaveDBToFile()
    -- no longer in the queue since we are doing it now
    writeToFileQueued = false

    -- check for repetitions
--    local duplicatTablesArray = coreutils.CheckForRepetitions(db)
--    for i, duplicateTable in ipairs(duplicatTablesArray) do
--        corelog.Warning("coredht.SaveDBToFile(): duplicate table found:"..textutils.serialise(duplicateTable))
--    end

    -- save the db table to a file (this may take some time with larger dht's)
    coreutils.WriteToFileNow(filename, db, "overwrite")
    local fileAttributes = fs.attributes(filename)
    fileTime = fileAttributes.modified

    -- create seperate files for each key (if the key is a table)
    for key, value in pairs(db) do

        -- is it a table?
        if type(value) == "table" then
            local fileName = "/debug/dht_"..key..".lua"
            coreutils.WriteToFile(fileName, "-- for manual reading only, changes to this file will be ignored", "overwrite")
            coreutils.WriteToFile(fileName, "local "..key.." =")
            coreutils.WriteToFile(fileName, value)
        end
    end
end

local function ResetHistory()
    -- just reset it
    dbHistory         = { _next = 1, _max = 30}
end

local function CheckPossibleConflict(listOfNodes, version)

    -- check all known history
    for i=0, dbHistory[ "_max" ] do

        -- if a slot is not set yet, we are done!
        if dbHistory[ i ] == nil then return false end

        -- don't check against older versions, not really conflicts, just updates
        if version <= dbHistory[ i ].version then

            -- check if the keys are the same (keep in mind both arrays are most likely of different size)
            local goingStrong = true
            for j = 1, math.min(#listOfNodes, #dbHistory[i].listOfNodes) do goingStrong = goingStrong and (listOfNodes[j] == dbHistory[i].listOfNodes[j]) end

            -- were are here, shit going on!
            if goingStrong then return true end
        end
    end

    -- all fine
    return false
end

local function SaveDataToDB(data, ...)
    -- actually saves the data to the db
    local ldb = db
    local listOfNodes = {}

    -- make a list of the nodes so we know which is the last one
    for i, node in ipairs(arg) do
        listOfNodes[#listOfNodes + 1] = node
    end

    -- history bijwerken
    dbHistory[ dbHistory["_next"] ] = { listOfNodes = listOfNodes, version = db._version }
    dbHistory[ "_next" ]            = dbHistory[ "_next" ] % dbHistory[ "_max" ] + 1

    -- check for all data
    if #listOfNodes == 0 then
        -- wow, overwriting the root is dangerous!
        if type(data) ~= "table" then corelog.WriteToLog("cvoredht.SaveDataToDB: not allowed to overwrite the dht root with something else then a table. Traceback: "..debug.traceback()) return data end

        -- no keys, full database
        db = data
    else
        -- search the nodes in the data
        for i=1,#listOfNodes-1 do
            local node = listOfNodes[i]

            -- create table if nothing is present
            if ldb[node] == nil then ldb[node] = {} end

            -- move to the next node
---@diagnostic disable-next-line: cast-local-type
            ldb = ldb[node]
        end

        -- ensure a copy of the data (to prevent possible table repetitions in db)
        local dataCopy = textutils.unserialise(textutils.serialise(data))

        -- store the data in the last given node
        ldb[listOfNodes[#listOfNodes]] = dataCopy
    end

    -- save the db table to a file
    if not writeToFileQueued then
        -- now it is in the queue
        writeToFileQueued = true

        -- add to the work queue
        coretask.AddWork(SaveDBToFile, nil, "coredht.SaveDBToFile()")
    end

    -- check the triggers
    for _, trigger in ipairs(dbTriggers) do

        -- check if the keys are the same (keep in mind both arrays are most likely of different size)
        local goingStrong = true
        for i = 1, math.min(#listOfNodes, #trigger.path) do goingStrong = goingStrong and (listOfNodes[i] == trigger.path[i]) end

        -- were are here, let's kick the trigger function if we are still going strong
        if goingStrong then trigger.func(trigger.data) end
    end

    -- return the data itself
    return data
end

local function DoDHTReady()
    -- we zijn blijkbaar klaar
    dhtReady = true

    -- check input box for the first time!
    if fs.exists(filename) then
        local fileAttributes = fs.attributes(filename)
        fileTime = fileAttributes.modified
    else
        fileTime = 0
    end

	-- seems we are ready, run requested functions
	for i, func in ipairs(dhtReadyFunctions) do func() end

    -- all functions executed, forget about them
	dhtReadyFunctions = {}

    -- fresh start
    ResetHistory()
end

local function DoEventGetAllData(subject, envelope)
    -- send all data back
    coreevent.ReplyToMessage(envelope, "all data", {data = db})
end

local function DoEventAllData(subject, envelope)
    -- alleen als de dht nog niet ready is (en ook als we geen table ontvangen hebben)
    if dhtReady or type(envelope.message) ~= "table" then return end

	-- just save the data to the root
	SaveDataToDB(envelope.message.data)

    -- we zijn er klaar voor
    DoDHTReady()
end

local function DoEventAllDataTimer(subject, envelope)
    -- alleen als de dht nog niet ready is
    if not dhtReady then
        -- niet zo best, we hebben geen data gekregen!
        corelog.WriteToLog("coredht: all data timer verlopen zonder iets ontvangen te hebben")

        -- we zetten nu de dht op ready, terwijl we weten dat het niet zo is...
        DoDHTReady()

        -- save the db table to a file, dan maar iets leegs
        coreutils.WriteToFile(filename, db, "overwrite")
    end
end

local function DoEventSaveData(subject, envelope)
    -- check, force a number
    if type(db._version) ~= "number" then db._version = 0 end

    -- check for version differences
    if db._version ~= 0 and db._version + 1 ~= envelope.message.version and CheckPossibleConflict(envelope.message.arg, envelope.message.version) then
        corelog.WriteToLog("DHT WARNING: Saving data from "..envelope.from.." with version "..envelope.message.version..". Current version is "..db._version)
        corelog.WriteToLog("  args are: "..textutils.serialize(envelope.message.arg))
    end

    -- versie bijwerken
    if db._version < envelope.message.version then db._version = envelope.message.version end

	-- just save the data like a normal request from this computer
	SaveDataToDB(envelope.message.data, table.unpack(envelope.message.arg))
end

local function DoEventDHTFileTimer(subject, envelope)
    -- local var
    local thisTime = 0

    -- laatste wijzigings datum opzoeken
    if fs.exists(filename) then
        local fileAttributes = fs.attributes(filename)
        thisTime = fileAttributes.modified
    end

    -- unknown time?
    if fileTime ~= thisTime then

        -- go for it!
        corelog.WriteToLog("coredht DoEventDHTFileTimer: About to reset the dht based on what's found on disk!!")

        -- this is our new time
        fileTime = thisTime

        -- alles van disk inlezen
        db = coreutils.ReadTableFromFile(filename)

        -- de rest van de wereld laten weten dat we dit hebben
        coredht.SaveData(db)
    end

    -- klaar, volgende keer over 1 seconde
    coreevent.CreateTimeEvent(20 * 1, protocol, "time to check file change")
end

function coredht.Setup()
    -- set up stuff when other apis are loading

    -- add handlers to protocol messages
	coreevent.AddEventListener(DoEventGetAllData,    protocol, "get all data")
	coreevent.AddEventListener(DoEventAllData,       protocol, "all data")
	coreevent.AddEventListener(DoEventAllDataTimer,  protocol, "all data timer")
	coreevent.AddEventListener(DoEventSaveData,      protocol, "save data")

    coreevent.AddEventListener(DoEventDHTFileTimer,  protocol, "time to check file change")

	-- start sending messages when we are ready to receive them too
	coreevent.EventReadyFunction(CoreDHTEventReadySetup)
    coredht.DHTReadyFunction(DoEventDHTFileTimer)
end

function coredht.DHTReadyFunction(func)
    if coredht.IsReady() then
        -- can be executed right away!
        func()
    else
        -- just add function to the list
        dhtReadyFunctions[#dhtReadyFunctions + 1] = func
    end
end

function coredht.IsReady()
    -- is the dht ready?
    return dhtReady
end

-- get data from the dht
function coredht.GetData(...)
    local ldb = db

    -- follow the nodes
    for i, node in ipairs(arg) do
---@diagnostic disable-next-line: cast-local-type
        if type(ldb) == "table" and ldb[node] ~= nil    then ldb = ldb[node]
                                                        else return nil
        end
    end

    -- return the data
    return ldb
end

-- save data to the table db
function coredht.SaveData(data, ...)
    -- safety
    if not dhtReady then corelog.WriteToLog("coredht.SaveData called before dht is ready. Traceback info: "..debug.traceback()) end

    -- for debugging dht issues
    if false then
        coreutils.WriteToFile(logfile, "", "a")
        coreutils.WriteToFile(logfile, "*** Saving data ***", "a")
        coreutils.WriteToFile(logfile, "data =", "a")
        coreutils.WriteToFile(logfile, data, "a")
        coreutils.WriteToFile(logfile, "arg =", "a")
        coreutils.WriteToFile(logfile, arg, "a")
    end

    -- we should have a version readable
    if type(db) ~= "table" or db._version == nil then corelog.WriteToLog("coredht.SaveData db var not ok. Traceback info: "..debug.traceback()) end

    -- update the version
    db._version = (db._version or 0) + 1

    -- send other what we are about to write (if event is ready ofcourse)
    coreevent.SendMessage({
	    protocol    = protocol,
	    subject     = "save data",
	    message     = {
	        data        = data,
	        arg         = arg,
	        version     = db._version
	    }
    })

    -- save the node in the data
    return SaveDataToDB(data, table.unpack(arg))
end

function coredht.RegisterTrigger(func, prot, data,  ...)
    -- check for double insert
    for _, triggerDef in ipairs(dbTriggers) do

        -- known trigger? just don't add this one then
        if triggerDef.func == func and triggerDef.prot == prot and triggerDef.data == data then return end
    end

    -- just insert it into the list of triggers
    table.insert(dbTriggers, {
        func = func,
        prot = prot,
        data = data,
        path = {table.unpack(arg)}
    })
end


--        _ _           _
--       | (_)         | |
--     __| |_ ___ _ __ | | __ _ _   _
--    / _` | / __| '_ \| |/ _` | | | |
--   | (_| | \__ \ |_) | | (_| | |_| |
--    \__,_|_|___/ .__/|_|\__,_|\__, |
--               | |             __/ |
--               |_|            |___/


function coredht.EditDHTDisplay(t, userInput)
    -- import display
    local coredisplay = require "coredisplay"

    -- did we get user input?
    if t.editValue and userInput ~= "e" then

        -- process the new value
        local f, err = load("return "..userInput)
        if f ~= nil and not err then coredht.SaveData(f(), unpack(t.keyList)) end

        -- back to usefull screen
        t.editValue = false
    end

    -- usefull
    local keyList   = t.keyList or {}
    local subRoot   = db

    -- add a new key if present
    if t.newKey ~= nil  then table.insert(keyList, t.newKey) end
    if t.removeKey      then if #keyList == 0 then return true else table.remove(keyList) end end

    -- find the subRoot
    for i, key in ipairs(keyList) do

        -- check and change subroot if oke
        if subRoot[key] ~= nil then subRoot = subRoot[key] else corelog.WriteToLog("coredht.EditDHTDisplay(): Invalid key: "..tostring(key)) end
    end

    -- which keys are present in the subroot?
    local intro     = "Available keys in the dht"
    local options   = {{key = "x", desc = "back", func = coredht.EditDHTDisplay, param = {keyList=keyList, removeKey=true}}}
    local question  = "Make your choice"

    -- loop subroot (if it's a table)
    local lastChar = 97
    if type(subRoot) == "table" then
        for key, _ in pairs(subRoot) do

            -- insert option
            table.insert(options, {key = string.char(lastChar), desc = key, func = coredht.EditDHTDisplay, param = {keyList = keyList, newKey = key }})

            -- update
            lastChar = lastChar + 1
        end
    else

        -- single value, show option for editing?
        if not t.editValue then
            -- different intro and allow editing
            intro = "The value : '"..tostring(subRoot).."'"
            table.insert(options, {key = "e", desc = "edit value", func = coredht.EditDHTDisplay, param = {keyList = keyList, editValue = true }})
        else
            -- we are editing, show screen for user input
            if userInput == "e" then
                -- start the screen to edit the value
                intro    = "Type the new value of this key. Use quotes for strings!!"
                options  = nil
---@diagnostic disable-next-line: cast-local-type
                question = nil
            end
        end
    end

    -- create the next screen
    coredisplay.NextScreen({
        clear = true,
        intro = intro,
        option = options,
        question = question,

        -- only for edit value screen
        func = coredht.EditDHTDisplay,
        param = t
    })

    -- done!
    return true
end

return coredht
