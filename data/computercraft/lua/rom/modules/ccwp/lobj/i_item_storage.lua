-- define interface
local Class = require "class"
local IItemSupplier = require "i_item_supplier"
local IItemDepot = require "i_item_depot"
local IItemStorage = Class.NewClass(IItemSupplier, IItemDepot)

--[[
    This module specifies the interface IItemStorage.

    The IItemStorage interface defines methods for storing items. The interface is an extension of IItemSupplier and IItemDepot.

    Objects of a class implementing the interface are called ItemStorage's.
--]]

local IInterface = require "i_interface"

--    _____ _____ _                  _____ _
--   |_   _|_   _| |                / ____| |
--     | |   | | | |_ ___ _ __ ___ | (___ | |_ ___  _ __ __ _  __ _  ___
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| __/ _ \| '__/ _` |/ _` |/ _ \
--    _| |_ _| |_| ||  __/ | | | | |____) | || (_) | | | (_| | (_| |  __/
--   |_____|_____|\__\___|_| |_| |_|_____/ \__\___/|_|  \__,_|\__, |\___|
--                                                             __/ |
--                                                            |___/

function IItemStorage:getItemInventory()
    --[[
        Return value:
                            - (ItemTable) with the item inventory of the ItemStorage.
    ]]

    IInterface.UnimplementedMethodError("IItemStorage", "getItemInventory")

    -- end
    return nil
end

function IItemStorage:nSlots()
    --[[
        Return value:
                            - (number) with the total number of slots in the ItemStorage.
    ]]

    IInterface.UnimplementedMethodError("IItemStorage", "nSlots")

    -- end
    return -1
end

function IItemStorage:nFreeSlots()
    --[[
        Return value:
                            - (number) with the number of free slots in the ItemStorage.
    ]]

    IInterface.UnimplementedMethodError("IItemStorage", "nFreeSlots")

    -- end
    return -1
end

return IItemStorage
