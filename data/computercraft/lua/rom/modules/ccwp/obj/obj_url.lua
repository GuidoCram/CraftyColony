-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local URL = Class.NewClass(ObjBase)

--[[
    This module implements the class URL.

    A URL object represents an CCWorldPlatform URL. See https://github.com/REReal8/CCWorldPlatform/wiki/Uniform-Resource-Locators for more on URL's.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function URL:_init(...)
    -- get & check input from description
    local checkSuccess, host, path, query, port = InputChecker.Check([[
        Initialise a URL.

        Parameters:
            host                    + (string, "") depicting the host sub-component of the URL (e.g. "turtle", "world" or "item-depot")
            path                    + (string, "") defining the path sub-component of the URL (e.g. "/forests/oak/id=50:23012")
            query                   + (table, {}) of key-value pairs with (item) query segments (e.g. {"minecraft:torch"=5, "minecraft:birch_log"=3} indicating two minecraft items with it's amount)
            port                    + (number, nil) defining the port sub-component of the URL (e.g. the id of a turtle, i.e. "30")
    ]], ...)
    if not checkSuccess then corelog.Error("URL:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._host  = host
    self._port  = port
    self._path  = path
    self._query = query
end

-- ToDo: should be renamed to newFromTable at some point
function URL:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Constructs an URL object.

        Parameters:
            o                       + (table, {}) table with object fields
                _host               - (string, "") depicting the host sub-component of the URL (e.g. "turtle", "world" or "item-depot")
                _port               - (number, nil) defining the port sub-component of the URL (e.g. the id of a turtle, i.e. "30")
                _path               - (string, "") defining the path sub-component of the URL (e.g. "/forests/oak/id=50:23012")
                _query              - (table, {}) of key-value pairs with (item) query segments (e.g. {"minecraft:torch"=5, "minecraft:birch_log"=3} indicating two minecraft items with it's amount)
    --]], ...)
    if not checkSuccess then corelog.Error("URL:new: Invalid input") return {} end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function URL:newFromURI(uri, suppressError)
    local aNewURL = URL:newInstance()

    aNewURL:setURI(uri, suppressError)

    return aNewURL
end

function URL:getScheme()
    return "ccwprp" -- always the same
end

function URL:getSchemeURI()
    return self:getScheme().."://"
end

function URL:getHost()
    return self._host
end

function URL:getHostURI()
    return self:getHost()
end

function URL:setHost(h)
    -- check input
    if type(h) ~= "string" then corelog.Error("URL:setHost: invalid host type: "..type(h)) return end

    self._host = h
end

local hostPattern = "[%a%_]+"
-- aUrl.setHostURI("item-depot")
function URL:setHostURI(hURI)
    -- check input
    if type(hURI) ~= "string" then corelog.Error("URL:setHost: invalid host URI type: "..type(hURI)) return end

    self:setHost(string.match(hURI, hostPattern)) -- in effect this should be the same as setHost(hURI)
end

function URL:getPort()
    return self._port
end

function URL:getPortURI()
    local port = self:getPort()
    local portURI = ""
    if port ~= nil then
        portURI = ":"..port
    end
    return portURI
end

function URL:setPort(p)
    -- check input
    if type(p) ~= "number" then corelog.Error("URL:setPort: invalid port type: "..type(p)) return end

    self._port = p
end

-- aUrl.setPortURI(":1")
local portPattern = ":%d+"
function URL:setPortURI(pURI)
    -- check input
    if type(pURI) ~= "string" then corelog.Error("URL:setPortURI: invalid port URI type: "..type(pURI)) return end

    if pURI ~= "" then
        local i, j = string.find(pURI, portPattern)
        if i ~= nil then
            local p = tonumber(string.sub(pURI, i+1, j))
            self:setPort(p)
        else
            corelog.Warning("URL:setPortURI: invalid port URI value: "..pURI)
        end
    else
--            corelog.WriteToLog("URL:setPortURI: port URI value empty: "..pURI)
    end
end

function URL:getAuthorityURI()
    return self:getHostURI()..self:getPortURI()
end

function URL:getPath()
    return self._path
end

function URL:getPathURI()
    return self:getPath()
end

function URL:setPath(p)
    -- check input
    if type(p) ~= "string" then corelog.Error("URL:setPath: invalid path type: "..type(p)) return end

    self._path = p
end

local pathURIPattern = "^([%/%w%=%:]*)"
-- aUrl.setPathURI("/forests/oak/id=50:23012")
function URL:setPathURI(pURI)
    -- check input
    if type(pURI) ~= "string" then corelog.Error("URL:setPathURI: invalid host URI type: "..type(pURI)) return end

    self:setPath(string.match(pURI, pathURIPattern)) -- in effect this should be the same as setPath(pURI)
end

local pathSegmentsPattern = "%/([%w%=%:]+)"
function URL:pathSegments_iter()
    --[[
        Factory for iterator over path segments
    --]]

    return self:getPath():gmatch(pathSegmentsPattern)
end

function URL:pathSegments()
    --[[
        Table with path segments
    --]]

    local segments = {}
    for pathSegment in self:pathSegments_iter() do
        table.insert(segments, pathSegment)
    end

    return segments
end

function URL:getQuery()
    return self._query
end

function URL:getQueryURI()
    local queryURI = ""
    local delimiter = "?"
    for key, value in pairs(self:getQuery()) do
        queryURI = queryURI..delimiter..key.."="..value
        delimiter = "&"
    end
    return queryURI
end

function URL:setQuery(q)
    -- check input
    if type(q) ~= "table" then corelog.Error("URL:setQuery: invalid query type: "..type(q)) return end

    self._query = q
end

-- aUrl.setQueryURI("?minecraft:birch_log=3&minecraft:torch=5")
function URL:setQueryURI(qURI)
    -- check input
    if type(qURI) ~= "string" then corelog.Error("URL:setQueryURI: invalid query URI type: "..type(qURI)) return end

    if qURI ~= "" then
        -- loop on query segments
        local q = {}
        local querySegmentPattern = "[%?%&]([_%:%a]+)%=(%d+)" -- [_%:%a] to allow for optional _ and : in e.g. "minecraft:birch_log"
        for key, value in string.gmatch(qURI, querySegmentPattern) do
            q[key] = tonumber(value)
        end
        self:setQuery(q)
    else
--            corelog.WriteToLog("URL:setQueryURI: query URI value empty: "..qURI)
    end
end

function URL:getURI()
    return self:getSchemeURI()..self:getAuthorityURI()..self:getPathURI()..self:getQueryURI()
end

function URL:setURI(fullURI, suppressError)
    suppressError = suppressError or false

    -- get & set host
    local remainingURL = fullURI
    local hostURIPattern = "^"..self:getSchemeURI().."("..hostPattern..")"
    local hostURI = string.match(remainingURL, hostURIPattern)
    if type(hostURI) ~= "string" then if not suppressError then corelog.Error("URL:setURI: could not find mandatory host in URI: "..fullURI) end return end
--        corelog.WriteToLog("hostURI="..(hostURI or "<nil>"))
    self:setHostURI(hostURI)

    remainingURL = string.gsub(remainingURL, hostURIPattern, "", 1) -- remove for easier next match
--        corelog.WriteToLog("URL:setURI: remainingURL="..remainingURL)

    -- get  & set optional port
    local portURIPattern = "^("..portPattern..")"
    local portURI = string.match(remainingURL, portURIPattern) or ""
--        corelog.WriteToLog("portURI="..(portURI or "<nil>"))
    self:setPortURI(portURI)

    remainingURL = string.gsub(remainingURL, portURIPattern, "", 1) -- remove for easier next match
--        corelog.WriteToLog("URL:setURI: remainingURL="..remainingURL)

    -- get  & set optional path
    local pathURIPattern = "^([%/%w%=%:]+)"
    local pathURI = string.match(remainingURL, pathURIPattern) or ""
--        corelog.WriteToLog("pathURI="..(pathURI or "<nil>"))
    self:setPathURI(pathURI)

    remainingURL = string.gsub(remainingURL, pathURIPattern, "", 1) -- remove for easier next match
--        corelog.WriteToLog("URL:setURI: remainingURL="..remainingURL)

    -- get  & set optional query
    local queryURIPattern = "^([%?][%&_%:%=%w]+)"
    local queryURI = string.match(remainingURL, queryURIPattern) or ""
--        corelog.WriteToLog("queryURI="..(queryURI or "<nil>"))

    remainingURL = string.gsub(remainingURL, queryURIPattern, "", 1)
    if remainingURL ~= "" then corelog.Warning("URL:setURI: remainingURL not empty at end of matching patterns: "..remainingURL) end

--        corelog.WriteToLog("URL:setURI: remainingURL="..remainingURL) -- should be empty!

    self:setQueryURI(queryURI)
end

function URL:getBaseURI()
    return self:getSchemeURI()..self:getAuthorityURI()..self:getPathURI()
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function URL:getClassName()
    return "URL"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function URL:sameHost(url)
    return self:getHostURI() == url:getHostURI()
end

function URL:sameAuthority(url)
    return self:getAuthorityURI() == url:getAuthorityURI()
end

function URL:samePath(url)
    return self:getPathURI() == url:getPathURI()
end

function URL:sameBase(url)
    return self:sameAuthority(url) and self:samePath(url)
end

function URL:sameQuery(url)
    -- check same elements as in A
    local sizeA = 0
    local queryB = url:getQuery()
    for keyA, valueA in pairs(self:getQuery()) do
        sizeA = sizeA + 1
        -- check same
        local valueB = queryB[keyA]
        if valueA ~= valueB then return false end
    end

    -- check no other elements in B
    local sizeB = 0
    for keyB, valueB in pairs(queryB) do
        sizeB = sizeB + 1
    end
    if sizeA ~= sizeB then return false end

    -- end
    return true
end

function URL:baseCopy()
    local uri = self:getBaseURI()

    return URL:newFromURI(uri)
end

return URL
