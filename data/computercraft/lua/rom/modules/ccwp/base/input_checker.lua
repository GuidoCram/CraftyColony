-- define module
local InputChecker = {}

-- ToDo: add proper description here
--[[
    The InputChecker ...
--]]

local corelog = require "corelog"

local Class = require "class"
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function InputChecker.Check(description, ...)
    -- for debugging
    local callingFunctionInfo = debug.getinfo(2)
--    corelog.WriteToLog("InputChecker.Check: callingFunctionInfo.source = "..callingFunctionInfo.source)
    local callingFunctionStr = (callingFunctionInfo.source or "?").."."..(callingFunctionInfo.name or "?")

    -- controle of description wel een string is
    local returns           = {}
    if type(description) ~= "string" then corelog.Error("CheckInput:"..callingFunctionStr..": description is not a string") return false, table.unpack(returns) end

    -- dit hebben we nodig om de tekst te lezen
    local parameterStart    = nil
    local indentSize        = 0
    local lastIndent        = 0
    local lastArgument      = 0
    local indenting         = {}

    -- regel voor regels langs lopen
    local result = true
    for stringPart in description:gmatch("[^\r\n]+") do

        -- hebben we al het woord 'parameter' gevonden?
        if parameterStart then

            -- zoeken of de parameter regel matched
            local start, parameter, needed, typeType = string.match(stringPart, "(%s+)([%_%w]+)%s*([%+%-])%s*%(([^%)]+)%)")

            -- might be a dummy line
            if start then

                -- default opgegeven?
                local defaultPresent = false
                local theType, theDefault = string.match(typeType, "^%s*([^,]+)%s*,%s*([^,]+)%s*$")
                if theType and theDefault then

                    -- default verwerken
                    typeType        = theType
                    defaultPresent  = true

                    -- default instellen
                    local theDefaultFunction = load("return " .. theDefault)
                    if theDefaultFunction then theDefault = theDefaultFunction() end
                end

                -- indent al bekend?
                if indentSize == 0 then indentSize = string.len(start) - parameterStart end

                -- huidige indenting berekenen
                local indent = math.floor((string.len(start) - parameterStart) / indentSize)

                -- controle
                if indent < 1 or indent > lastIndent + 1 then corelog.Error("CheckInput:"..callingFunctionStr..": indent error (indent = "..indent..", lastIndent = "..lastIndent..")") return false, table.unpack(returns) end

                -- argument opzoeken
                local argument
                if indent == 1 then

                    -- komt blijkbaar uit de lijst met argumenten
                    lastArgument = lastArgument + 1
                    argument = arg[ lastArgument ]
                else

                    -- komt blijkbaar uit een van de andere argumenten
                    if type(indenting[ indent - 1 ]) == "table" then argument = indenting[ indent - 1 ][ parameter ]
                                                                else corelog.Error("CheckInput:"..callingFunctionStr..": indent parent not a table") return false, table.unpack(returns)
                    end
                end

                -- wellicht default toepassen
                local argumentChanged = false
                if argument == nil and defaultPresent then
                    if theDefault ~= nil then
                        argument = theDefault
                        argumentChanged = true
                    else
                        typeType = "nil"
                    end
                end

                -- voldoet het argument aan het opgegeven type?
                local correctArgumentType = true
                if typeType ~= "?" and type(argument) ~= typeType then
                    if type(argument) ~= "table" then
                        correctArgumentType = false
                    else
                        -- check argument not yet instance of typeTypeClass
                        local typeTypeClass = objectFactory:getClass(typeType) if not typeTypeClass then corelog.Error(callingFunctionStr..": could not find "..typeType.." class of argument '"..parameter.."'") result = false end
                        if not Class.IsInstanceOf(argument, typeTypeClass) then -- note: check to allow derived types
                            local object = objectFactory:create(typeType, argument)
                            if object then
                                argument = object
                                argumentChanged = true
                            else
                                correctArgumentType = false
                            end
                        end
                    end
                end
                if not correctArgumentType then corelog.Error(callingFunctionStr..": argument '"..parameter.."' not a "..typeType.." (type="..type(argument)..")") result = false end

                -- possibly change parent field to changed argument
                if argumentChanged and (indent > 1) then
                    if type(indenting[ indent - 1 ]) == "table" then
                        indenting[ indent - 1 ][ parameter ] = argument
                    else corelog.Error("CheckInput:"..callingFunctionStr..": indent parent not a table") return false, table.unpack(returns) end
                end

                -- is deze gewenst om terug te geven?
                if needed == '+' then table.insert(returns, argument) end

                -- laatste van deze indent onthouden
                indenting[ indent ] = argument
                lastIndent          = indent
            end

        -- hmm, het woord 'parameter' nog niet eens gevonden
        else
            -- zoeken naar waar de parameters beginnen
            local start = string.find(stringPart, "[Pp]arameters:")
            if start then parameterStart = start - 1 end
        end
    end

    -- done
    return result, table.unpack(returns)
end

return InputChecker
