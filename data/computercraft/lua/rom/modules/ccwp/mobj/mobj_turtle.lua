-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ILObj = require "i_lobj"
local IMObj = require "i_mobj"
local IWorker = require "i_worker"
local IItemSupplier = require "i_item_supplier"
local IItemDepot = require "i_item_depot"
local Turtle = Class.NewClass(ObjBase, ILObj, IMObj, IWorker, IItemSupplier, IItemDepot)

--[[
    The Turtle mobj represents a Turtle in the minecraft world and provides services to operate on that Turtle.
--]]

local corelog = require "corelog"
local coreutils = require "coreutils"
local coreinventory = require "coreinventory"
local coremove = require "coremove"
local coredisplay = require "coredisplay"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local Location = require "obj_location"
local Inventory = require "obj_inventory"
local ObjTable = require "obj_table"
local ItemTable = require "obj_item_table"
local ObjHost = require "obj_host"
local Block = require "obj_block"
local CodeMap = require "obj_code_map"
local LayerRectangle = require "obj_layer_rectangle"

local LObjLocator = require "lobj_locator"

local role_energizer = require "role_energizer"

local enterprise_employment

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function Turtle:_init(...)
    -- get & check input from description
    local checkSuccess, id, workerId, isActive, settlementLocator, baseLocation, workerLocation, fuelPriorityKey = InputChecker.Check([[
        Initialise a Turtle.

        Parameters:
            id                      + (string) id of the Turtle
            workerId                + (number) workerId of the Turtle
            isActive                + (boolean) whether the Turtle is active
            settlementLocator       + (ObjLocator) locating Settlement of the Turtle
            baseLocation            + (Location) base location of the Turtle
            workerLocation          + (Location) location of the Turtle
            fuelPriorityKey         + (string, "") fuel priority key of the Turtle
    ]], ...)
    if not checkSuccess then corelog.Error("Turtle:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id                = id
    self._workerId          = workerId
    self._isActive          = isActive
    self._settlementLocator = settlementLocator
    self._baseLocation      = baseLocation
    self._location          = workerLocation
    self._fuelPriorityKey   = fuelPriorityKey
end

-- ToDo: should be renamed to newFromTable at some point
function Turtle:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a Turtle.

        Parameters:
            o                           + (table, {}) table with object fields
                _id                     - (string) id of the Turtle
                _workerId               - (number) workerId of the Turtle
                _isActive               - (boolean, false) whether the Turtle is active
                _settlementLocator      - (ObjLocator) locating Settlement of the Turtle
                _baseLocation           - (Location, {}) base location of the Turtle
                _location               - (Location, {}) location of the Turtle
                _fuelPriorityKey        - (string, "") fuel priority key of the Turtle
    ]], ...)
    if not checkSuccess then corelog.Error("Turtle:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function Turtle:getFuelPriorityKey()
    return self._fuelPriorityKey
end

function Turtle:setFuelPriorityKey(fuelPriorityKey)
    -- check
    if type(fuelPriorityKey) ~= "string" then corelog.Error("Turtle:setFuelPriorityKey: Invalid fuelPriorityKey(type="..type(fuelPriorityKey)..")") return end

    self._fuelPriorityKey = fuelPriorityKey
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function Turtle:getClassName()
    return "Turtle"
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function Turtle:construct(...)
    -- get & check input from description
    local checkSuccess, workerId, settlementLocator, baseLocation, workerLocation = InputChecker.Check([[
        This method constructs a Turtle instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        The constructed Turtle is not yet saved in the LObjHost.

        Return value:
                                        - (Turtle) the constructed Turtle

        Parameters:
            constructParameters         - (table) parameters for constructing the Turtle
                workerId                + (number) workerId of the Turtle
                settlementLocator       + (ObjLocator) locating Settlement of the Turtle
                baseLocation            + (Location) base location of the Turtle
                workerLocation          + (Location) location of the Turtle
    ]], ...)
    if not checkSuccess then corelog.Error("Turtle:construct: Invalid input") return nil end

    -- construct new Turtle
    local id = coreutils.NewId()
    local obj = Turtle:newInstance(id, workerId, false, settlementLocator, baseLocation, workerLocation)

    -- end
    return obj
end

function Turtle:destruct()
    --[[
        This method destructs a Turtle instance.

        The Turtle is not yet deleted from the LObjHost.

        Return value:
                                        - (boolean) whether the Turtle was succesfully destructed.

        Parameters:
    ]]

    -- end
    local destructSuccess = true
    return destructSuccess
end

function Turtle:getId()
    return self._id
end

function Turtle:getWIPId()
    --[[
        Returns the unique Id of the Turtle used for administering WIP.
    ]]

    return self:getClassName().." "..self:getId()
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

-- ToDo: consider making this mandatory for all MObj's
function Turtle:getSettlementLocator()
    return self._settlementLocator
end

function Turtle:getBaseLocation()
    return self._baseLocation
end

local function Turtle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["C"]   = Block:newInstance("computercraft:turtle_normal"),
        }),
        CodeMap:newInstance({
            [1] = "C",
        })
    )
end

function Turtle.GetBuildBlueprint(...)
    -- get & check input from description
    local checkSuccess, baseLocation = InputChecker.Check([[
        This method returns a blueprint for building a Turtle in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            constructParameters         - (table) parameters for constructing the Turtle
                baseLocation            + (Location) base location of the Turtle
    ]], ...)
    if not checkSuccess then corelog.Error("Turtle.GetBuildBlueprint: Invalid input") return nil, nil end

    -- buildLocation
    local buildLocation = baseLocation:copy()

    -- layerList
    local layerList = {
        { startpoint = Location:newInstance(0, 0, 0), buildDirection = "Down", layer = Turtle_layer()},
    }

    -- escapeSequence
    local escapeSequence = {}

    -- blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence,
    }

    -- end
    return buildLocation, blueprint
end

local function TurtleDismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [1] = " ",
        })
    )
end

function Turtle:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the Turtle in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- layerList
    local layerList = {
        { startpoint = Location:newInstance(0, 0, 0), buildDirection = "Down", layer = TurtleDismantle_layer()},
    }

    -- escapeSequence
    local escapeSequence = {}

    -- blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence
    }

    -- buildLocation
    local buildLocation = self:getWorkerLocation():copy()

    -- end
    return buildLocation, blueprint
end

--    _______          __        _
--   |_   _\ \        / /       | |
--     | |  \ \  /\  / /__  _ __| | _____ _ __
--     | |   \ \/  \/ / _ \| '__| |/ / _ \ '__|
--    _| |_   \  /\  / (_) | |  |   <  __/ |
--   |_____|   \/  \/ \___/|_|  |_|\_\___|_|

function Turtle:getWorkerId()
    --[[
        Get the Turtle workerId.

        Return value:
                                - (number) the Turtle workerId
    ]]

    -- end
    return self._workerId
end

function Turtle:activate()
    self._isActive = true
    return self:isActive()
end

function Turtle:deactivate()
    self._isActive = false
    return not self:isActive()
end

function Turtle:isActive()
    return self._isActive == true
end

function Turtle:reset()
    -- reset fields
    self:setFuelPriorityKey("")

    -- save
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local objLocator = enterprise_employment:saveObj(self)
    if not objLocator then corelog.Error("Turtle:reset: Failed saving Turtle") return nil end
end

function Turtle:getWorkerLocation()
    -- check current Turtle
    if self:getWorkerId() == os.getComputerID() then
        -- get coremove location
        local coremove_location = Location:new(coremove.GetLocation())

        -- check coremove location has changed
        if not coremove_location:isEqual(self._location) then
            -- update location in turtle object
--            corelog.WriteToLog("Turtle:getWorkerLocation(): Turtle "..self:getWorkerId().." coremove_location(="..textutils.serialise(coremove_location, {compact = true})..") different from obj_location(="..textutils.serialise(self._location, {compact = true})..") => updating obj_location.")
            -- ToDo: consider changes to prevent TurtleObj location and coremove_location going out of date (to the extreme: incorporate coremove into Turtle class)
            self._location = coremove_location

            -- save change in host
            enterprise_employment = enterprise_employment or require "enterprise_employment"
            enterprise_employment:saveObj(self)
        end
    end

    -- end
    return self._location
end

function Turtle:getWorkerResume()
    --[[
        Get Turtle resume for selecting Assignment's.

        The resume gives information on the Turtle and is used to determine if the Turtle is (best) suitable to take an Assignment.
            This is can e.g. be used to indicate location, fuel level and equiped items.

        Return value:
            resume              - (table) Turtle "resume" to consider in selecting Assignment's
    --]]

    -- end
    return {
        workerId        = self:getWorkerId(),
        location        = self:getWorkerLocation(),
        isTurtle        = true,
        fuelLevel       = turtle.getFuelLevel(),
        axePresent      = coreinventory.CanEquip("minecraft:diamond_pickaxe"),
        inventoryItems  = coreinventory.GetInventoryDetail().items,
        leftEquiped     = coreinventory.LeftEquiped(),
        rightEquiped    = coreinventory.RightEquiped(),
    }
end

function Turtle:getMainUIMenu()
    --[[
        Get the main (start) UI menu of the Turtle.

        This menu can be used in conjuction with coredisplay.MainMenu.

        Return value:
                                - (table)
                clear           - (boolean) whether or not to clear the display,
                func	        - (function) menu function to call
                param	        - (table, {}) parameter to pass to menu function
                intro           - (string) intro to print
                question        - (string, nil) final question to print
    ]]

    -- end
    return coredisplay.DefaultMainMenu()
end

function Turtle:getAssignmentFilter()
    --[[
        Get assignment filter for finding the next best Assignment for the Turtle.

        The assignment filter is used to indicate to only accept assignments that satisfy certain conditions. This can e.g. be used
            to only accept assignments with high priority.

        Return value:
            assignmentFilter    - (table) filter to apply in finding an Assignment
    --]]

    -- (re)fuel turtle if needed
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    enterprise_employment:triggerTurtleRefuelIfNeeded(self) -- note: if refuel is triggered fuelPriorityKey will get set

    -- end
    return {
        priorityKeyNeeded   = self:getFuelPriorityKey()
    }
end

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

local defaultHostName = "enterprise_employment"

function Turtle:provideItemsTo_AOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems, itemDepotLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
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
                assignmentsPriorityKey          + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                            + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("Turtle:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- check items available in inventory
    local hasItems = self:getInventory():hasItems(provideItems)
    if not hasItems then corelog.Error("Turtle:provideItemsTo_AOSrv: provideItems(="..textutils.serialise(provideItems)..") not (all) available in Turtle") return Callback.ErrorCall(callback) end

    -- create turtleItemsLocator
    local turtleItemsLocator = LObjLocator:newInstance(defaultHostName, self, provideItems)

    -- get ItemDepot
    local itemDepot = ObjHost.GetObj(itemDepotLocator)
    if type(itemDepot) ~= "table" then corelog.Error("Turtle:provideItemsTo_AOSrv: itemDepot "..itemDepotLocator:getURI().." not found.") return Callback.ErrorCall(callback) end

    -- store items from this turtle to ItemDepot
    --    corelog.WriteToLog(">Store "..turtleItemsLocator:getURI().." from Turtle")
    return itemDepot:storeItemsFrom_AOSrv({
        itemsLocator                = turtleItemsLocator,
        assignmentsPriorityKey      = assignmentsPriorityKey,
    }, callback)
end

function Turtle:can_ProvideItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("Turtle:can_ProvideItems_QOSrv: Invalid input") return {success = false} end

    -- check items in inventory
    local hasItems = self:getInventory():hasItems(provideItems)

    -- end
    return {
        success = hasItems,
    }
end

function Turtle:needsTo_ProvideItemsTo_SOSrv(...)
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
    if not checkSuccess then corelog.Error("Turtle:needsTo_ProvideItemsTo_SOSrv: Invalid input") return {success = false} end

    -- get destinationItemDepot
    local destinationItemDepot = ObjHost.GetObj(destinationItemDepotLocator)
    if not destinationItemDepot or not Class.IsInstanceOf(destinationItemDepot, IItemDepot) then corelog.Error("Turtle:needsTo_ProvideItemsTo_SOSrv: Failed obtaining an IItemDepot from itemDepotLocator "..destinationItemDepotLocator:getURI()) return {success = false} end

    -- get locations
    local localLocation = self:getWorkerLocation()
    local destinationLocation = destinationItemDepot:getItemDepotLocation()

    -- fuelNeed from Turtle to ItemDepot
    local fuelNeed_FromTurtleToItemDepot = role_energizer.NeededFuelToFrom(destinationLocation, localLocation)

    -- loop on items
    local fuelNeed = 0
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("Turtle:needsTo_ProvideItemsTo_SOSrv: Invalid itemName (type="..type(itemName)..")") return {success = false} end
        if type(itemCount) ~= "number" then corelog.Error("Turtle:needsTo_ProvideItemsTo_SOSrv: Invalid itemCount (type="..type(itemCount)..")") return {success = false} end
        local items = { [itemName] = itemCount }

        -- check items in inventory
        local hasItems = self:getInventory():hasItems(items)
        if not hasItems then corelog.Warning("Turtle:needsTo_ProvideItemsTo_SOSrv: Turtle does not have "..textutils.serialise(items, { compact = true })) return {success = false} end

        -- add fuelNeed
        fuelNeed = fuelNeed + fuelNeed_FromTurtleToItemDepot
    end

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

function Turtle:storeItemsFrom_AOSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
        This async public ItemDepot service stores items from from an ItemSupplier.

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
    if not checkSuccess then corelog.Error("Turtle:storeItemsFrom_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- get storeItems
    local storeItems = itemsLocator:getQuery()

    -- check source is a turtle
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    if enterprise_employment:isLocatorFromHost(itemsLocator) then -- source is a turtle
        -- check same turtle
        local sourceTurtleObj = ObjHost.GetObj(itemsLocator) if not sourceTurtleObj then corelog.Error("Turtle:storeItemsFrom_AOSrv: Failed obtaining turtle "..itemsLocator:getURI()) return Callback.ErrorCall(callback) end
        local sourceTurtleId = sourceTurtleObj:getWorkerId()
        local currentTurtleId = self:getWorkerId()
        if sourceTurtleId and currentTurtleId ~= sourceTurtleId then corelog.Error("Turtle:storeItemsFrom_AOSrv: Store items(="..textutils.serialise(storeItems, {compact = true})..") from one (id="..sourceTurtleId..") turtle to another (id="..currentTurtleId..") not implemented (?yet).") return Callback.ErrorCall(callback) end

        -- verify turtle has items (aleady)
        local turtleInventory = self:getInventory()
        local hasItems = turtleInventory:hasItems(storeItems)
        if not hasItems then corelog.Error("Turtle:storeItemsFrom_AOSrv: storeItems not (all="..textutils.serialise(storeItems, {compact = true})..") items available in Turtle inventory(="..textutils.serialise(turtleInventory, {compact = true})..")") return Callback.ErrorCall(callback) end

        -- determine destinationItemsLocator
        local itemTable = ItemTable:newInstance(itemsLocator:getQuery())
        local destinationItemsLocator = LObjLocator:newInstance(defaultHostName, self, itemTable)

        -- end
        local result = {
            success                     = true,
            destinationItemsLocator     = destinationItemsLocator,
        }
        return callback:call(result)
    else -- source is not a turtle
        -- ToDo: investigate if there are ways to prevent this (as below code seems a bit ackward)
        -- create turtleLocator
        local turtleLocator = LObjLocator:newInstance(defaultHostName, self)

        -- get source ItemSupplier
        local itemSupplierLocator = itemsLocator:baseCopy()
        local itemSupplier = ObjHost.GetObj(itemSupplierLocator)
        if type(itemSupplier) ~= "table" then corelog.Error("Turtle:storeItemsFrom_AOSrv:ItemDepot "..itemSupplierLocator:getURI().." not found.") return Callback.ErrorCall(callback) end

        -- have source ItemSupplier provideItemsTo Turtle
        local ingredientsItemSupplierLocator = itemsLocator:copy() -- note: this is intended as a dummy ingredientsItemSupplierLocator, it should not be needed here as we are asked to store items from and ItemSupplier so I guess it is safe to assume the ItemSupplier already has the items (otherwise why store it)
        local wasteItemDepotLocator = turtleLocator:copy() -- note: only added because provideItemsTo_AOSrv asks for it. It will/ should also not be used/ needed as storing items implies no waste.
        return itemSupplier:provideItemsTo_AOSrv({
            provideItems                = storeItems,
            itemDepotLocator            = turtleLocator,
            ingredientsItemSupplierLocator = ingredientsItemSupplierLocator,
            wasteItemDepotLocator       = wasteItemDepotLocator,
            assignmentsPriorityKey      = assignmentsPriorityKey,
        }, callback)
    end
end

function Turtle:can_StoreItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("Turtle:can_StoreItems_QOSrv: Invalid input") return {success = false} end

    -- ToDo: implement
    corelog.Warning("Turtle:can_StoreItems_QOSrv: not yet implemented")
    return {success = false}
end

function Turtle:needsTo_StoreItemsFrom_SOSrv(...)
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
    if not checkSuccess then corelog.Error("Turtle:needsTo_StoreItemsFrom_SOSrv: Invalid input") return {success = false} end

    -- ToDo: implement
    corelog.Warning("Turtle:needsTo_StoreItemsFrom_SOSrv: not yet implemented")
    return {success = false}
end

function Turtle:getItemDepotLocation()
    return self:getWorkerLocation()
end

--    _______         _   _
--   |__   __|       | | | |
--      | |_   _ _ __| |_| | ___
--      | | | | | '__| __| |/ _ \
--      | | |_| | |  | |_| |  __/
--      |_|\__,_|_|   \__|_|\___|

function Turtle:getInventory()
    -- check current Worker
    -- ToDo: implement allowing getting inventory of a Turtle from any computer (cache inventory in dht objects?)
    if self:getWorkerId() ~= os.getComputerID() then
        corelog.Warning("Turtle:getInventory() not yet supported on Turtle(="..self:getWorkerId()..") from other computer(="..os.getComputerID()..") => returning empty Inventory")
        return Inventory:newInstance()
    end

    -- get current Turtle inventory slots
    local slotTable = {}
    for slot=1,16 do
        -- get detailed information about this slot
        local itemDetail = coreinventory.GetItemDetail(slot)

        -- right item?
        if type(itemDetail) == "table" then
            -- add to slots, name and count
            slotTable[ slot ] = itemDetail
        end
    end

    -- construct Inventory object
    local inventory = Inventory:newInstance(slotTable)

    -- end
    return inventory
end

function Turtle:getInventoryAsItemTable()
    -- check current Turtle
    if self:getWorkerId() ~= os.getComputerID() then corelog.Warning("Turtle:getInventoryAsItemTable() not yet supported on other Turtle(="..self:getWorkerId()..") than current(="..os.getComputerID()..")") end

    -- why multiline when it can be done in a single line? Well, for readablilty and debugging ofcourse!
    local inventory = self:getInventory()
    local itemTable = inventory:getItemTable()

    -- return the table as an object ItemTable
    return ItemTable:newInstance(itemTable)
end

function Turtle:getOutputAndWasteItemsSince(...)
    -- get & check input from description
    local checkSuccess, lastInventory, wishedOutputItems = InputChecker.Check([[
        This function returns the ouput and other items obtained by this Turtle relative to a past snapshot of the Turtle inventory.

        Return value:
            task result                     - (table)
                success                     - (boolean) whether the task was succesfull
                outputItems                 - (ItemTable) with output items in the Turtle inventory
                otherItems                  - (ItemTable) with other items in the Turtle inventory

        Parameters:
            lastInventory                   + (ItemTable) with last Inventory
            wishedOutputItems               + (ItemTable) with one or more output items we wish to have
    ]], ...)
    if not checkSuccess then corelog.Error("Turtle:getOutputAndWasteItemsSince: Invalid input") return {success = false} end

    -- determine output & waste items
    local endTurtleItems = self:getInventoryAsItemTable()
    local uniqueEndItems, _commonItems, _uniqueBeginItems = ItemTable.compare(endTurtleItems, lastInventory)
    if not uniqueEndItems then corelog.Error("Turtle:getOutputAndWasteItemsSince: Failed obtaining uniqueEndItems") return {success = false} end
    local otherItems, outputItems, _1 = ItemTable.compare(uniqueEndItems, wishedOutputItems)
    if not outputItems then corelog.Error("Turtle:getOutputAndWasteItemsSince: Failed obtaining outputItems") return {success = false} end
    if not otherItems then corelog.Error("Turtle:getOutputAndWasteItemsSince: Failed obtaining otherItems") return {success = false} end

    -- end
    return {
        success     = true,
        outputItems = outputItems,
        otherItems  = otherItems,
    }
end

return Turtle
