-- define interface
local IInterface = {
}

--[[
    This module specifies the IInterface interface.

    It defines functions other interfaces can use.
--]]

--    _____ _____       _             __
--   |_   _|_   _|     | |           / _|
--     | |   | |  _ __ | |_ ___ _ __| |_ __ _  ___ ___
--     | |   | | | '_ \| __/ _ \ '__|  _/ _` |/ __/ _ \
--    _| |_ _| |_| | | | ||  __/ |  | || (_| | (_|  __/
--   |_____|_____|_| |_|\__\___|_|  |_| \__,_|\___\___|

function IInterface.UnimplementedMethodError(interfaceName, methodName)
    error("Method "..interfaceName..":"..methodName.."(): should be implemented in concrete classes. It should not be called directly on the "..interfaceName.." interface.")
end

return IInterface
