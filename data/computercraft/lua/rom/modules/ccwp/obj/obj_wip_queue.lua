-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local WIPQueue = Class.NewClass(ObjBase)

--[[
    This module implements the WIPQueue class.

    A WIPQueue stores administrative information for Work In Progress (WIP) on an entity.

    An example case is registering all the WIP for an MObj.

    It is typically used in combination with the WIPAdministrator.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function WIPQueue:_init(...)
    -- get & check input from description
    local checkSuccess, workList, callbackList = InputChecker.Check([[
        Initialise a WIPQueue.

        Parameters:
            workList                + (table) with workId's
            callbackList            + (ObjArray) with Callback's
    ]], ...)
    if not checkSuccess then corelog.Error("WIPQueue:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._workList      = workList
    self._callbackList  = callbackList
end

-- ToDo: should be renamed to newFromTable at some point
function WIPQueue:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a WIPQueue.

        Parameters:
            o                           + (table) table with object fields
                _workList               - (table) with workId's
                _callbackList           - (ObjArray) with Callback's
    ]], ...)
    if not checkSuccess then corelog.Error("WIPQueue:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function WIPQueue:addWork(...)
    -- get & check input from description
    local checkSuccess, workId = InputChecker.Check([[
        This method adds work identified by 'workId' to the queue.

        Return value:
                                                - (boolean) whether the method was called successfully

        Parameters:
            workId                              + (string) with the id of the work
    ]], ...)
    if not checkSuccess then corelog.Error("WIPQueue:addWork: Invalid input") return false end

    -- add to _workList
    table.insert(self._workList, workId)

    -- end
    return true
end

function WIPQueue:removeWork(...)
    -- get & check input from description
    local checkSuccess, workId = InputChecker.Check([[
        This method removes work identified by 'workId' from the queue.

        Return value:
                                                - (boolean) whether the method was called successfully

        Parameters:
            workId                              + (string) with the id of the work
    ]], ...)
    if not checkSuccess then corelog.Error("WIPQueue:removeWork: Invalid input") return false end

    -- remove from _workList
    for i, aWorkId in ipairs(self._workList) do
        if aWorkId == workId then
            table.remove(self._workList, i)
            return true
        end
    end

    -- end
    return false
end

function WIPQueue:noWIP()
    --[[
        This method returns if the queue administers any work in progress.

        Return value:
                                                - (boolean) whether the queue is empty

        Parameters:
    ]]

    -- check _workList empty
    local noWIP = next(self._workList) == nil

    -- end
    return noWIP
end

function WIPQueue:addCallback(...)
    -- get & check input from description
    local checkSuccess, callback = InputChecker.Check([[
        This method adds a Callback to the queue.

        Return value:
                                                - (boolean) whether the method was called successfully

        Parameters:
            callback                            + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("WIPQueue:addCallback: Invalid input") return false end

    -- add to _callbackList
    table.insert(self._callbackList, callback)

    -- end
    return true
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function WIPQueue:getClassName()
    return "WIPQueue"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function WIPQueue:callAndReleaseCallbacks()
    --[[
        This method calls all callbacks and removes them from the queue

        Return value:
                                                - (boolean) whether all callbacks where successfully called

        Parameters:
    ]]

    -- call and remove all callbacks
    local nCallbacks = #(self._callbackList)
    for i=nCallbacks, 1, -1 do
        -- get Callback
        local callback = self._callbackList[i]

        -- call Callback
        callback:call({success = true})

        -- remove from ObjArray
        table.remove(self._callbackList, i)
    end

    -- end
    return true
end

return WIPQueue
