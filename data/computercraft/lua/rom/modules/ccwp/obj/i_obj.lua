-- define interface
local IObj = {
}

--[[
    This module specifies the IObj interface.

    It defines a set of methods that classes adhering to this interface must implement.

    Objects adhering to this interface are referred to as Obj's.
--]]

local IInterface = require "i_interface"

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function IObj:getClassName()
    --[[
        Method that returns the concrete className of an Obj.
    ]]

    IInterface.UnimplementedMethodError("IObj", "getClassName")

    -- end
    return "???"
end

function IObj:isEqual(otherObj)
    --[[
        Method that returns if the Obj is equal to another Obj.
    ]]

    IInterface.UnimplementedMethodError("IObj", "isEqual")

    -- end
    return false
end

function IObj:copy()
    --[[
        Method that returns a copy of the Obj.
    ]]

    IInterface.UnimplementedMethodError("IObj", "copy")

    -- end
    return nil
end

return IObj
