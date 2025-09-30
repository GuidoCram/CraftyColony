-- define class
local Class = require "class"
local LObjTest = require "test.lobj_test"
local IItemStorage = require "i_item_storage"
local ItemStorageFake = Class.NewClass(LObjTest, IItemStorage)

--[[
    This module implements the class ItemStorageFake, a fake implementation of a ItemStorage intended for testing ItemStorage related functionality.

    It usage an ItemTable to track items.
--]]

local corelog = require "corelog"
local coreutils = require "coreutils"

local InputChecker = require "input_checker"

local Callback = require "obj_callback"

local ItemTable = require "obj_item_table"
local ObjHost = require "obj_host"

local IItemSupplier = require "i_item_supplier"
local IItemDepot = require "i_item_depot"
local LObjLocator = require "lobj_locator"

local role_energizer = require "role_energizer"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function ItemStorageFake:_init(...)
    -- get & check input from description
    local checkSuccess, id, baseLocation, field1, inventory, nSlots = InputChecker.Check([[
        Initialise a ItemStorageFake.

        Parameters:
            id                      + (string) id of the ItemStorageFake
            baseLocation            + (Location) base location of the ItemStorageFake
            field1                  + (string) field 1
            inventory               + (ItemTable) with fake inventory
            nSlots                  + (number) with # of slots
    ]], ...)
    if not checkSuccess then corelog.Error("ItemStorageFake:_init: Invalid input") return nil end

    -- initialisation
    LObjTest._init(self, id, field1)
    self._baseLocation  = baseLocation
    self._inventory = inventory
    self._nSlots = nSlots
end

-- ToDo: should be renamed to newFromTable at some point
function ItemStorageFake:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a ItemStorageFake.

        Parameters:
            o                           + (table, {}) with object fields
                _id                     - (string) id of the ItemStorageFake
                _field1                 - (string) field
                _baseLocation           - (Location) base location of the ItemStorageFake
                _inventory              - (ItemTable) with fake inventory
                _nSlots                 - (number) with # of slots
    ]], ...)
    if not checkSuccess then corelog.Error("ItemStorageFake:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function ItemStorageFake:getClassName()
    return "ItemStorageFake"
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function ItemStorageFake:construct(...)
    -- get & check input from description
    local checkSuccess, baseLocation, field1Value, nSlots = InputChecker.Check([[
        This method constructs a ItemStorageFake instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        It also ensures all child MObj's the ItemStorageFake spawns are hosted on the appropriate MObjHost (by calling hostLObj_SSrv).

        The constructed ItemStorageFake is not yet saved in the LObjHost.

        Return value:
                                        - (ItemStorageFake) the constructed ItemStorageFake

        Parameters:
            constructParameters         - (table) parameters for constructing the MObj
                baseLocation            + (Location) base location of the Chest
                field1Value             + (string) value to set field1 to
                nSlots                  + (number) with # of slots
    ]], ...)
    if not checkSuccess then corelog.Error("ItemStorageFake:construct: Invalid input") return nil end

    -- determine ItemStorageFake fields
    local id = coreutils.NewId()
    local inventory = ItemTable:newInstance()

    -- construct new ItemStorageFake
    local obj = self:newInstance(id, baseLocation, field1Value, inventory, nSlots)

    -- end
    return obj
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function ItemStorageFake:getBaseLocation()
    return self._baseLocation
end

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

local defaultHostName = "enterprise_test"

function ItemStorageFake:provideItemsTo_AOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems, itemDepotLocator, callback = InputChecker.Check([[
        This async public ItemSupplier service provides specific items to an ItemDepot.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed correctly
                destinationItemsLocator         - (ObjLocator) locating the final ItemDepot and the items that where transferred to it
                                                    (upon service succes the "host" component of this ObjLocator should be equal to itemDepotLocator, and
                                                    the "query" should be equal to orderItems)

        Parameters:
            serviceData                         - (table) data for the service
                provideItems                    + (ItemTable) with one or more items to provide
                itemDepotLocator                + (ObjLocator) locating the ItemDepot where the items need to be provided to
                assignmentsPriorityKey          - (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                            + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("ItemStorageFake:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- check can provide requested items
    local canProvideResult = self:can_ProvideItems_QOSrv({ provideItems = provideItems, })
    if not canProvideResult or not canProvideResult.success then corelog.Error("ItemStorageFake:provideItemsTo_AOSrv: the ItemStorageFake can not provide (all) items from "..textutils.serialise(provideItems, {compact = true})) return Callback.ErrorCall(callback) end

    -- get destination ItemDepot
    local destinationItemDepot = ObjHost.GetObj(itemDepotLocator)
    if not destinationItemDepot or not Class.IsInstanceOf(destinationItemDepot, ItemStorageFake) then corelog.Error("ItemStorageFake:provideItemsTo_AOSrv: Failed obtaining an ItemStorageFake from itemDepotLocator "..itemDepotLocator:getURI()) return Callback.ErrorCall(callback) end

    -- do fake transfer of items between Inventory's
    destinationItemDepot._inventory = ItemTable.combine(destinationItemDepot._inventory, provideItems)
    self._inventory, _, _ = ItemTable.compare(self._inventory, provideItems)

    -- determine result
    local destinationItemsLocator = itemDepotLocator:copy()
    destinationItemsLocator:setQuery(provideItems)

    -- end
    local taskResult = {
        success                 = true,
        destinationItemsLocator = destinationItemsLocator,
    }
    return callback:call(taskResult)
end

function ItemStorageFake:can_ProvideItems_QOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems = InputChecker.Check([[
        This sync public query service answers the question whether the ItemSupplier can provide specific items.

        Return value:
                                    - (table)
                success             - (boolean) whether the answer to the question is true

        Parameters:
            serviceData             - (table) data to the query
                provideItems        + (ItemTable) with one or more items to provide
    --]], ...)
    if not checkSuccess then corelog.Error("ItemStorageFake:can_ProvideItems_QOSrv: Invalid input") return {success = false} end

    -- check items in inventory
    local _, _, notFoundItems = ItemTable.compare(self._inventory, provideItems)
    if not notFoundItems then corelog.Error("ItemStorageFake:can_ProvideItems_QOSrv: Unexpected notFoundItems==nil") return {success = false} end
    local hasItems = notFoundItems:hasNoItems()

    -- end
    return {
        success = hasItems,
    }
end

function ItemStorageFake:needsTo_ProvideItemsTo_SOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems, destinationItemDepotLocator = InputChecker.Check([[
        This sync public service returns the needs for the ItemSupplier to provide specific items to an ItemDepot.

        Return value:
                                                - (table)
                success                         - (boolean) whether the service executed correctly
                fuelNeed                        - (number) amount of fuel needed to provide items
                ingredientsNeed                 - (table) ingredients needed to provide items

        Parameters:
            serviceData                         - (table) data to the query
                provideItems                    + (ItemTable) with one or more items to provide
                itemDepotLocator                + (ObjLocator) locating the ItemDepot where the items need to be provided to
                ingredientsItemSupplierLocator  - (ObjLocator, nil) locating where ingredients can be retrieved
    --]], ...)
    if not checkSuccess then corelog.Error("ItemStorageFake:needsTo_ProvideItemsTo_SOSrv: Invalid input") return {success = false} end

    -- get ItemDepot
    local destinationItemDepot = ObjHost.GetObj(destinationItemDepotLocator)
    if not destinationItemDepot or not Class.IsInstanceOf(destinationItemDepot, IItemDepot) then corelog.Error("ItemStorageFake:needsTo_ProvideItemsTo_SOSrv: Failed obtaining an IItemDepot from destinationItemDepotLocator "..destinationItemDepotLocator:getURI()) return {success = false} end

    -- get locations
    local localLocation = self:getItemDepotLocation()
    local destinationLocation = destinationItemDepot:getItemDepotLocation()

    -- fuelNeed from ItemStorageFake to ItemDepot
    local fuelNeed_FromItemStorageFakeToItemDepot = role_energizer.NeededFuelToFrom(destinationLocation, localLocation)

    -- loop on items
    local fuelNeed = fuelNeed_FromItemStorageFakeToItemDepot -- note: assume one Turtle trip is sufficient

    -- end
    local ingredientsNeed = {}
    return {
        success         = true,
        fuelNeed        = fuelNeed,
        ingredientsNeed = ingredientsNeed,
    }
end

--    _____ _____ _                 _____                   _
--   |_   _|_   _| |               |  __ \                 | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__|
--                                             | |
--                                             |_|

function ItemStorageFake:storeItemsFrom_AOSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator, callback = InputChecker.Check([[
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
                assignmentsPriorityKey  - (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                    + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("ItemStorageFake:storeItemsFrom_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    --
    local itemTable = ItemTable:newInstance(itemsLocator:getQuery())

    -- check can store items
    local canStoreResult = self:can_StoreItems_QOSrv({ storeItems = itemTable, })
    if not canStoreResult or not canStoreResult.success then corelog.Error("ItemStorageFake:storeItemsFrom_AOSrv: the ItemStorageFake can not store (all) items from "..itemsLocator:getURI()) return Callback.ErrorCall(callback) end

    -- get source ItemSupplier
    local sourceItemSupplier = ObjHost.GetObj(itemsLocator)
    if not sourceItemSupplier or not Class.IsInstanceOf(sourceItemSupplier, ItemStorageFake) then corelog.Error("ItemStorageFake:storeItemsFrom_AOSrv: Failed obtaining an ItemStorageFake from itemsLocator "..itemsLocator:getURI()) return Callback.ErrorCall(callback) end

    -- do fake transfer of items between Inventory's
    self._inventory = ItemTable.combine(self._inventory, itemTable)
    sourceItemSupplier._inventory, _, _ = ItemTable.compare(sourceItemSupplier._inventory, itemTable)

    -- determine result
    local destinationItemsLocator = LObjLocator:newInstance(defaultHostName, self, itemTable:copy())

    -- end
    local taskResult = {
        success                 = true,
        destinationItemsLocator = destinationItemsLocator,
    }
    return callback:call(taskResult)
end

function ItemStorageFake:can_StoreItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("ItemStorageFake:can_StoreItems_QOSrv: Invalid input") return {success = false} end

    --
    local slotsNeeded = storeItems:nSlotsNeeded()
    local freeSlots = self:nFreeSlots()

    -- end
    return {
        success = slotsNeeded <= freeSlots,
    }
end

function ItemStorageFake:needsTo_StoreItemsFrom_SOSrv(...)
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
    if not checkSuccess then corelog.Error("ItemStorageFake:needsTo_StoreItemsFrom_SOSrv: Invalid input") return {success = false} end

    -- get source ItemSupplier
    local sourceItemSupplier = ObjHost.GetObj(itemsLocator)
    if not sourceItemSupplier or not Class.IsInstanceOf(sourceItemSupplier, IItemSupplier) then corelog.Error("ItemStorageFake:needsTo_StoreItemsFrom_SOSrv: Failed obtaining an ItemStorageFake from itemsLocator "..itemsLocator:getURI()) return {success = false}  end

    -- get locations
    local localLocation = self:getItemDepotLocation()
    local sourceLocation = sourceItemSupplier:getItemDepotLocation()

    -- fuelNeed from ItemStorageFake to ItemDepot
    local fuelNeed_FromItemStorageFakeToItemDepot = role_energizer.NeededFuelToFrom(sourceLocation, localLocation)

    -- loop on items
    local fuelNeed = fuelNeed_FromItemStorageFakeToItemDepot -- note: assume one Turtle trip is sufficient

    -- end
    return {
        success         = true,
        fuelNeed        = fuelNeed,
    }
end

function ItemStorageFake:getItemDepotLocation()
    return self:getBaseLocation()
end

--    _____ _____ _                  _____ _
--   |_   _|_   _| |                / ____| |
--     | |   | | | |_ ___ _ __ ___ | (___ | |_ ___  _ __ __ _  __ _  ___
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| __/ _ \| '__/ _` |/ _` |/ _ \
--    _| |_ _| |_| ||  __/ | | | | |____) | || (_) | | | (_| | (_| |  __/
--   |_____|_____|\__\___|_| |_| |_|_____/ \__\___/|_|  \__,_|\__, |\___|
--                                                             __/ |
--                                                            |___/

function ItemStorageFake:getItemInventory()
    -- end
    return self._inventory
end

function ItemStorageFake:nSlots()
    -- end
    return self._nSlots
end

function ItemStorageFake:nFreeSlots()
    -- end
    return self._nSlots - self._inventory:nSlotsNeeded()
end

return ItemStorageFake
