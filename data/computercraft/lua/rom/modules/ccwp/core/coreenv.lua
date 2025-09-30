-- define module
local coreenv = {}

--[[
    Deze module is bedoelt voor "environment" settings, die voor het hele systeem gelden (dus niet 1 worker). Het gebruik
    is naar verwachting vooral om verschillende manieren van werken te gebruiken zonder reload / reboot. Voorbeelden:

    * event bulkMode -----> moeten berichten los of in bluk verstuurd worden
    * max forest 1x1 -----> om te zorgen dat het bos als 1x1 gezien wordt ongeacht de werkelijke afmetingen, handig bij testen dat het
                            omhakken vna het bos lekker snel gaat omdat hout al aan de worker gegeven is.
    * Sync write to disk -> of bestande direct weggeschreven moeten worden of async

    Het gaat om instellingen die niet veel wijzigen natuurlijk, niet gebruiken voor de inhoud van een kist of zo.
    Ook niet gebruiken voor instellingen van 1 specifieke worker (zoals welke monitor wat weer geeft)
--]]

-- imports
local coreevent
local corelog
local coreutils

-- local data
local db        = {
    env                 = {},
    filename            = "/db/env.lua",
    protocol            = "core:env",
    kinds               = {["number"]=true, ["string"]=true, ["boolean"]=true, ["table"]=true},
    readyToSync         = false,
}

--    _                 _
--   | |               | |
--   | | ___   ___ __ _| |
--   | |/ _ \ / __/ _` | |
--   | | (_) | (_| (_| | |
--   |_|\___/ \___\__,_|_|
--
--

local function ToNumber(value)
    -- check value
    if type(value) == "table" or type(value) == "function" then return 0 else return tonumber(value) end
end

local function ToString(value)
    -- check value
    if type(value) == "table" or type(value) == "function" then return "" else return tostring(value) end
end

local function ToBoolean(value)
    -- check for known false types
    if value == false
    or value == "false"
    or value == "False"
    or value == nil     then return false
                        else return true
    end
end

local function ToTable(value)
    -- check for table
    if type(value) ~= "table"   then return {value}
                                else return value
    end
end

local function SaveEnvToFile()
    -- save the db table to a file (this may take some time with larger dht's)
    coreutils.WriteToFile(db.filename, db.env, "overwrite")
end

local function Registered(protocol, name, kind, default)
    -- check the kind, must be a known kind
    if not db.kinds[kind] then return false end

    -- maybe registered before, then ignore
    if type(db.env[protocol]) == "table" and type(db.env[protocol][name]) == "table" then return false end

    -- safety
    if type(db.env[protocol]) ~= "table" then db.env[protocol] = {} end

    -- just overwrite current settings
    db.env[protocol][name] = {
        kind    = kind,
        default = default,
        value   = default
    }

    -- save the shit
    SaveEnvToFile()

    -- done
    return true
end

local function Set(protocol, name, value)
    -- check if tables are present
    if type(db.env[protocol]) == "table" and type(db.env[protocol][name]) == "table" then db.env[protocol][name].value = value end

    -- save the shit
    SaveEnvToFile()

    -- done
    return value
end

-- event ready function
local function DoWhenEventReady()
end

--                         _
--                        | |
--     _____   _____ _ __ | |_
--    / _ \ \ / / _ \ '_ \| __|
--   |  __/\ V /  __/ | | | |_
--    \___| \_/ \___|_| |_|\__|
--
--

local function DoEventGetAllData(subject, envelope)
    -- send all data back
    coreevent.ReplyToMessage(envelope, "all data", {data = db.env})
end

local function DoEventAllData(subject, envelope)
    -- just to be sure
    if type(envelope) ~= "table" or type(envelope.message) ~= "table" or type(envelope.message.data) ~= "table" then return end

	-- just overwrite everything
    db.env = envelope.message.data

    -- we are ready now to sync
    db.readyToSync = true

    -- save the shit
    SaveEnvToFile()
end

local function DoEventRegistered(subject, envelope)
    -- do the work
    Registered(envelope.message.protocol, envelope.message.name, envelope.message.kind, envelope.message.default)
end

local function DoEventSet(subject, envelope)
    -- do the work
    Set(envelope.message.protocol, envelope.message.name, envelope.message.value)
end

--                _     _ _
--               | |   | (_)
--    _ __  _   _| |__ | |_  ___
--   | '_ \| | | | '_ \| | |/ __|
--   | |_) | |_| | |_) | | | (__
--   | .__/ \__,_|_.__/|_|_|\___|
--   | |
--   |_|

-- initializes the dht
function coreenv.Init()

    -- do the actual import
    coreevent = coreevent   or require "coreevent"
    corelog   = corelog     or require "corelog"
    coreutils = coreutils   or require "coreutils"

	-- read database from disk
	db.env = coreutils.ReadTableFromFile(db.filename)

	-- safety
    if type(db.env) ~= "table" then db.env = {} end
end

function coreenv.Setup()
    -- add handlers to protocol messages
	coreevent.AddEventListener(DoEventGetAllData,   db.protocol, "get all data")
	coreevent.AddEventListener(DoEventAllData,      db.protocol, "all data")
	coreevent.AddEventListener(DoEventRegistered,   db.protocol, "registered")
	coreevent.AddEventListener(DoEventSet,          db.protocol, "set")

    -- send all data when event is ready
    coreevent.EventReadyFunction(DoWhenEventReady)
end

function coreenv.RegisterVariable(protocol, name, kind, default)
    -- do the registration
    local success = Registered(protocol, name, kind, default)

    -- send other what we just added (if sync ready ofcourse)
    if success and db.readyToSync then

        -- da message
        coreevent.SendMessage({
            protocol    = db.protocol,
            subject     = "registered",
            message     = {
                protocol    = protocol,
                name        = name,
                kind        = kind,
                default     = default,
            }
        })
    end
end

function coreenv.GetVariable(protocol, name)
    -- loop it up
    if type(db.env[protocol]) == "table" and type(db.env[protocol][name]) == "table" then return db.env[protocol][name].value end

    -- guess we shouldn't be here
    return nil
end

function coreenv.SetVariable(protocol, name, value)
    -- just set it in case it has been registered before
    value = Set(protocol, name, value)

    -- send other what we just added (if sync ready ofcourse)
    if db.readyToSync then

        -- da message
        coreevent.SendMessage({
            protocol    = db.protocol,
            subject     = "set",
            message     = {
                protocol    = protocol,
                name        = name,
                value       = value,
            }
        })
    end
end

--        _ _           _
--       | (_)         | |
--     __| |_ ___ _ __ | | __ _ _   _
--    / _` | / __| '_ \| |/ _` | | | |
--   | (_| | \__ \ |_) | | (_| | |_| |
--    \__,_|_|___/ .__/|_|\__,_|\__, |
--               | |             __/ |
--               |_|            |___/

function coreenv.EditEnvDisplay(t, userInput)
    -- import display
    local coredisplay = require "coredisplay"

    -- select protocol
    if not t.protocol then
        local options   = {{key = "x", desc = "back", func = function () return true end}}

        -- loop subroot (if it's a table)
        local lastChar = 97
        for protocol, _ in pairs(db.env) do

            -- insert option
            table.insert(options, {key=string.char(lastChar), desc=protocol, func=coreenv.EditEnvDisplay, param={protocol=protocol}})

            -- update
            lastChar = lastChar + 1
        end

        -- create the next screen
        coredisplay.NextScreen({
            clear       = true,
            intro       = "Choose a protocol:",
            option      = options,
            question    = "Make your choice",
        })

        -- done?
        return true
    end

    -- select a name
    if t.protocol and not t.name then
        local options   = {{key = "x", desc = "back", func = function () return true end}}

        -- loop subroot (if it's a table)
        local lastChar = 97
        for name, _ in pairs(db.env[t.protocol]) do

            -- insert option
            table.insert(options, {key=string.char(lastChar), desc=name, func=coreenv.EditEnvDisplay, param={protocol=t.protocol, name=name}})

            -- update
            lastChar = lastChar + 1
        end

        -- create the next screen
        coredisplay.NextScreen({
            clear       = true,
            intro       = "Choose a variable withing "..t.protocol..":",
            option      = options,
            question    = "Make your choice",
        })

        -- done?
        return true
    end

    -- get the env
    local daEnv = db.env[t.protocol][t.name]

    -- give value selector if protocol and name have been choosen
    if t.protocol and t.name and t.value == nil then

        -- what's the kind?
        if daEnv.kind == "boolean" then

            -- let's just assume we have a boolean, others come later
            coredisplay.NextScreen({
                clear       = true,
                intro       = t.protocol.."."..t.name.."\nCurrent value: "..tostring(daEnv.value).."\nChoose a new value: ",
                option      = {
                    {key = "t", desc = "true",  func = coreenv.EditEnvDisplay, param={protocol=t.protocol, name=t.name, value=true}},
                    {key = "f", desc = "false", func = coreenv.EditEnvDisplay, param={protocol=t.protocol, name=t.name, value=false}},
                    {key = "x", desc = "back",  func = function () return true end},
                },
                question    = "Make your choice",
            })

            -- done?
            return true
        end
    end

    -- guess we will set the value
    if t.protocol and t.name and t.value ~= nil then

        -- what's the kind?
        if daEnv.kind == "boolean" then

            -- set the value
            Set(t.protocol, t.name, t.value)

            -- feedback to the user
            coredisplay.UpdateToDisplay(t.protocol.."."..t.name.." is now "..tostring(db.env[t.protocol][t.name].value))
        end

        -- stay here
        return false
    end

    -- done!
    return true
end

-- return da class
return coreenv
