-- define interface
local ILObj = {
}

--[[
    This module specifies the interface ILObj.

    The ILObj interface defines methods for objects representing "logical" things we would
    like to programmically interact with. Objects of a class implementing the interface are referred to as LObj's.
    LObj's are assumed to also be an Obj. LObj's are hosted by a LObjHost who interacts with the defined methods in this interface.

    LObj's should make sure that any async work is registered in the WIPAdministrator with the LObj id as wipId.
    For async work via projects this can be done by setting the 'wipId' key in the projectMeta to the LObj id.
--]]

local corelog = require "corelog"

local IInterface = require "i_interface"
local InputChecker = require "input_checker"

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function ILObj:construct(...)
    -- get & check input from description
    local checkSuccess, param1, param2 = InputChecker.Check([[
        This method constructs a XXXLObj instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        It also ensures all child LObj's the XXXLObj spawns are hosted on the appropriate LObjHost (by calling hostLObj_SSrv).

        The constructed XXXLObj is not yet saved in the LObjHost.

        Return value:
                                        - (XXXLObj) the constructed XXXLObj

        Parameters:
            constructParameters         - (table) parameters for constructing the XXXLObj
                param1                  + (Location) location of XXXLObj
                param2                  + (number, 2) ...
                ...
    ]], ...)
    if not checkSuccess then corelog.Error("XXXLObj:construct: Invalid input") return nil end

    IInterface.UnimplementedMethodError("ILObj", "construct")

    -- end
    return nil
end

function ILObj:destruct()
    --[[
        This method destructs a XXXLObj instance.

        It also ensures all child LObj's the XXXLObj is the parent of are released from the appropriate LObjHost (by calling releaseLObj_SSrv).

        The XXXLObj is not yet deleted from the LObjHost.

        Return value:
                                        - (boolean) whether the XXXLObj was succesfully destructed.

        Parameters:
    ]]

    IInterface.UnimplementedMethodError("ILObj", "destruct")

    -- end
    return false
end

function ILObj:getId()
    --[[
        Return the unique Id of the XXXLObj.
    ]]

    IInterface.UnimplementedMethodError("ILObj", "getId")

    -- end
    return "???"
end

function ILObj:getWIPId()
    --[[
        Returns the unique Id of the XXXLObj used for administering WIP.
    ]]

    IInterface.UnimplementedMethodError("ILObj", "getWIPId")

    -- end
    return "???"
end

return ILObj
