-- define interface
local IItemDepot = {
}

--[[
    This module specifies the interface IItemDepot.

    The IItemDepot interface defines service methods for supplying (providing) items.

    Objects of a class implementing the interface are called ItemSupplier's.
--]]

local corelog = require "corelog"

local IInterface = require "i_interface"
local InputChecker = require "input_checker"
local Callback = require "obj_callback"

--    _____ _____ _                 _____                   _
--   |_   _|_   _| |               |  __ \                 | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__|
--                                             | |
--                                             |_|

function IItemDepot:storeItemsFrom_AOSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
        This async public ItemDepot service stores items from an ItemSupplier.

        An ItemDepot should take special care the transfer from a Turtle inventory gets priority over other assignments of the Turtle.

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether the service executed successfully
                destinationItemsLocator - (ObjLocator) stating the final ItemDepot and the items that where stored
                                            (upon service succes the "base" component of this ObjLocator should be equal to itemDepotLocator
                                            and the "query" should be equal to the "query" component of the itemsLocator)

        Parameters:
            serviceData                 - (table) data about the service
                itemsLocator            + (ObjLocator) locating the items to store
                                            (the "base" component of the ObjLocator specifies the ItemSupplier that provides the items)
                                            (the "query" component of the ObjLocator specifies the items)
                assignmentsPriorityKey  + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                    + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("IItemDepot:storeItemsFrom_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    IInterface.UnimplementedMethodError("IItemDepot", "storeItemsFrom_AOSrv")

    -- end
    return Callback.ErrorCall(callback)
end

function IItemDepot:can_StoreItems_QOSrv(...)
    -- get & check input from description
    local checkSuccess, storeItems = InputChecker.Check([[
        This sync public query service answers the question whether the ItemDepot can store specific items.

        Return value:
                                    - (table)
                success             - (boolean) whether the answer to the question is true

        Parameters:
            serviceData             - (table) data to the query
                storeItems          + (ItemTable) with one or more items to be stored
    --]], ...)
    if not checkSuccess then corelog.Error("IItemDepot:can_StoreItems_QOSrv: Invalid input") return {success = false} end

    IInterface.UnimplementedMethodError("IItemDepot", "can_StoreItems_QOSrv")

    -- end
    return {success = false}
end

function IItemDepot:needsTo_StoreItemsFrom_SOSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator = InputChecker.Check([[
        This sync public service returns the needs to store specific items from an ItemSupplier.

        Return value:
                                                - (table)
                success                         - (boolean) whether the service executed correctly
                fuelNeed                        - (number) amount of fuel needed to store items

        Parameters:
            serviceData                         - (table) data to the query
                itemsLocator                    + (ObjLocator) locating the items to store
                                                    (the "base" component of the ObjLocator specifies the ItemSupplier that provides the items)
                                                    (the "query" component of the ObjLocator specifies the items)
    --]], ...)
    if not checkSuccess then corelog.Error("IItemDepot:needsTo_StoreItemsFrom_SOSrv: Invalid input") return {success = false} end

    IInterface.UnimplementedMethodError("IItemDepot", "needsTo_StoreItemsFrom_SOSrv")

    -- end
    return {success = false}
end

function IItemDepot:getItemDepotLocation()
    --[[
        This function provides the world location of an ItemDepot.

        Return value:
                location            - (Location) location of the ItemDepot

        Parameters:
    --]]
    IInterface.UnimplementedMethodError("IItemDepot", "getItemDepotLocation")

    -- end
    return nil
end

return IItemDepot
