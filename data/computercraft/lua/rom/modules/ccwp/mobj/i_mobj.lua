-- define interface
local IMObj = {
}

--[[
    This module specifies the interface IMObj.

    The IMObj interface defines methods for objects representing "physical" things in the minecraft world that we would
    like to programmically interact with. Objects of a class implementing the interface are referred to as MObj's.
    MObj's are assumed to also be an LObj. MObj's are hosted by a MObjHost who interacts with the defined methods in this interface.
--]]

local IInterface = require "i_interface"

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function IMObj:getBaseLocation()
    --[[
        Get the base location of the XXXMObj.

        Return value:
            baseLocation                + (Location) base location of the XXXMObj
    ]]

    IInterface.UnimplementedMethodError("IMObj", "getBaseLocation")

    return nil
end

function IMObj.GetBuildBlueprint(...)
    --[[
        This method returns a blueprint for building a XXXMObj in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    IInterface.UnimplementedMethodError("IMObj", "GetBuildBlueprint")

    -- end
    return nil, nil
end

function IMObj:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the XXXMObj in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    IInterface.UnimplementedMethodError("IMObj", "getDismantleBlueprint")

    -- end
    return nil, nil
end

return IMObj
