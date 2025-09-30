-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ILObj = require "i_lobj"
local IMObj = require "i_mobj"
local IItemSupplier = require "i_item_supplier"
local IItemDepot = require "i_item_depot"
local Silo = Class.NewClass(ObjBase, ILObj, IMObj, IItemSupplier, IItemDepot)

--[[
    The Silo mobj represents a Silo in the minecraft world and provides services to operate on that Silo.

    The following design decisions are made
        - The actual Silo's should never be accessed directly but only via the services of this mobj.
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"

local InputChecker = require "input_checker"

local Callback = require "obj_callback"
local ObjArray = require "obj_array"
local ObjTable = require "obj_table"
local ObjHost = require "obj_host"
local Location = require "obj_location"
local ObjLocator = require "obj_locator"
local Block = require "obj_block"
local CodeMap = require "obj_code_map"
local LayerRectangle = require "obj_layer_rectangle"
local ItemTable = require "obj_item_table"

local LObjLocator = require "lobj_locator"

local enterprise_projects = require "enterprise_projects"
local enterprise_employment
local enterprise_storage = require "enterprise_storage"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function Silo:_init(...)
    -- get & check input from description
    local checkSuccess, id, baseLocation, entryLocation, dropLocation, pickupLocation, topChests, storageChests = InputChecker.Check([[
        Initialise a Silo.

        Parameters:
            id                      + (string) id of the Silo
            baseLocation            + (Location) base location of the Silo
            entryLocation           + (Location) entry location of the Silo
            dropLocation            + (number) top Chest index
            pickupLocation          + (number) top Chest index
            topChests               + (ObjArray) with top Chest's
            storageChests           + (ObjArray) with storage Chest's
    ]], ...)
    if not checkSuccess then corelog.Error("Silo:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id                = id
    self._baseLocation      = baseLocation
    self._entryLocation     = entryLocation
    self._dropLocation      = dropLocation
    self._pickupLocation    = pickupLocation
    self._topChests         = topChests
    self._storageChests     = storageChests
end

-- ToDo: should be renamed to newFromTable at some point
function Silo:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a Silo.

        Parameters:
            o                           + (table, {}) with object fields
                _id                     - (string) id of the Silo
                _baseLocation           - (Location) base location of the Silo
                _entryLocation          - (Location) entry location of the Silo
                _dropLocation           - (number) top Chest index
                _pickupLocation         - (number) top Chest index
                _topChests              - (ObjArray) with top Chest's
                _storageChests          - (ObjArray) with storage Chest's
    ]], ...)
    if not checkSuccess then corelog.Error("Silo:new: Invalid input") return {} end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function Silo:Activate()
    self._operational = true
    self:update()
end

function Silo:Deactivate()
    self._operational = false
    self:update()
end

function Silo:getNTopChests()
    --[[
        Returns the # top Chest's in the Silo.
    ]]

    -- end
    return #(self._topChests)
end

function Silo:getNStorageLayers()
    --[[
        Returns the # storage layers in the Silo.
    ]]

    -- end
    return #(self._storageChests)/ 4
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function Silo:getClassName()
    return "Silo"
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function Silo:construct(...)
    -- get & check input from description
    local checkSuccess, baseLocation, nTopChests, nLayers = InputChecker.Check([[
        This method constructs a Silo instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        It also ensures all child MObj's the Silo spawns are hosted on the appropriate MObjHost (by calling hostLObj_SSrv).

        The constructed Silo is not yet saved in the LObjHost.

        Return value:
                                        - (Silo) the constructed Silo

        Parameters:
            constructParameters         - (table) parameters for constructing the Silo
                baseLocation            + (Location) base location of the Silo
                nTopChests              + (number, 2) # of top chests
                nLayers                 + (number, 2) # of layers
    ]], ...)
    if not checkSuccess then corelog.Error("Silo:construct: Invalid input") return nil end

    -- determine Silo fields
    local id = coreutils.NewId()
    -- better safe then sorry, maybe flexible one day
    baseLocation:setDX(0)
    baseLocation:setDY(1)
    local entryLocation = baseLocation:getRelativeLocation(3, 3, 0)
    local dropLocation = 0
    local pickupLocation = 0
    local topChests = ObjArray:newInstance(ObjLocator:getClassName())
    local storageChests = ObjArray:newInstance(ObjLocator:getClassName())

    -- log
--    corelog.WriteToLog(">Starting Silo at "..textutils.serialise(baseLocation, { compact = true }))

    -- add our top chests, depending how many we have
    if nTopChests >= 1 then table.insert(topChests, enterprise_storage:hostLObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(2, 5, 0), accessDirection="back"}}).mobjLocator) end
    if nTopChests >= 2 then table.insert(topChests, enterprise_storage:hostLObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(4, 5, 0), accessDirection="back"}}).mobjLocator) end
    if nTopChests >= 3 then table.insert(topChests, enterprise_storage:hostLObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(5, 4, 0), accessDirection="left"}}).mobjLocator) end
    if nTopChests >= 4 then table.insert(topChests, enterprise_storage:hostLObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(5, 2, 0), accessDirection="left"}}).mobjLocator) end
    if nTopChests >= 5 then table.insert(topChests, enterprise_storage:hostLObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(4, 1, 0), accessDirection="front"}}).mobjLocator) end
    if nTopChests >= 6 then table.insert(topChests, enterprise_storage:hostLObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(2, 1, 0), accessDirection="front"}}).mobjLocator) end
    if nTopChests >= 7 then table.insert(topChests, enterprise_storage:hostLObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(1, 2, 0), accessDirection="right"}}).mobjLocator) end
    if nTopChests >= 8 then table.insert(topChests, enterprise_storage:hostLObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(1, 4, 0), accessDirection="right"}}).mobjLocator) end

    -- set the defaults (basic setup)
    if nTopChests >= 1 then dropLocation   = 1 end
    if nTopChests >= 2 then pickupLocation = 2 end

    -- loop the layers
    for i=1, nLayers, 1 do
        -- do the floor
        local shaft = entryLocation:getRelativeLocation(0, 0, -1 - i)
        table.insert(storageChests, enterprise_storage:hostLObj_SSrv({className="Chest",constructParameters={baseLocation=shaft:getDivergentDirection( 0,  1):getLocationFront(), accessDirection="back"}}).mobjLocator)
        table.insert(storageChests, enterprise_storage:hostLObj_SSrv({className="Chest",constructParameters={baseLocation=shaft:getDivergentDirection( 1,  0):getLocationFront(), accessDirection="back"}}).mobjLocator)
        table.insert(storageChests, enterprise_storage:hostLObj_SSrv({className="Chest",constructParameters={baseLocation=shaft:getDivergentDirection( 0, -1):getLocationFront(), accessDirection="back"}}).mobjLocator)
        table.insert(storageChests, enterprise_storage:hostLObj_SSrv({className="Chest",constructParameters={baseLocation=shaft:getDivergentDirection(-1,  0):getLocationFront(), accessDirection="back"}}).mobjLocator)
    end

    -- construct new Silo
    local obj = Silo:newInstance(id, baseLocation:copy(), entryLocation, dropLocation, pickupLocation, topChests, storageChests)

    -- end
    return obj
end

function Silo:destruct()
    --[[
        This method destructs a Silo instance.

        It also ensures all child MObj's the Silo is the parent of are released from the appropriate MObjHost (by calling releaseLObj_SSrv).

        The Silo is not yet deleted from the LObjHost.

        Return value:
                                        - (boolean) whether the Silo was succesfully destructed.

        Parameters:
    ]]

    -- for debugging only
--    corelog.WriteToLog("Oh no, someone is deleting a Silo!!!")

    -- Why would you ever want to delete such a magnificent structure.
    local destructSucces = true
    for i, mobjLocator in ipairs(self._topChests) do
        local releaseResult = enterprise_storage:releaseLObj_SSrv({ mobjLocator = mobjLocator })
        if not releaseResult or not releaseResult.success then corelog.Warning("Silo:destruct(): failed releasing top Chest "..mobjLocator:getURI()) destructSucces = false end
        self._topChests[i] = nil
    end
    for i, mobjLocator in ipairs(self._storageChests) do
        local releaseResult = enterprise_storage:releaseLObj_SSrv({ mobjLocator = mobjLocator })
        if not releaseResult or not releaseResult.success then corelog.Warning("Silo:destruct(): failed releasing storage Chest "..mobjLocator:getURI()) destructSucces = false end
        self._storageChests[i] = nil
    end

    -- end
    return destructSucces
end

function Silo:getId()
    --[[
        Return the unique Id of the Silo.
    ]]

    return self._id
end

function Silo:getWIPId()
    --[[
        Returns the unique Id of the Silo used for administering WIP.
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

function Silo:getBaseLocation()
    return self._baseLocation
end

local function TopL0_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["T"]   = Block:newInstance("minecraft:torch"),
            ["C"]   = Block:newInstance("minecraft:chest", 0, 1),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [6] = "  C C ",
            [5] = "      ",
            [4] = "T     ",
            [3] = "      ",
            [2] = "      ",
            [1] = "   T  ",
        })
    )
end

local function Shaft_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [1] = " ",
        })
    )
end

local function Storage_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["C"]   = Block:newInstance("minecraft:chest", -1, 0),
            ["D"]   = Block:newInstance("minecraft:chest", 0, 1),
            ["E"]   = Block:newInstance("minecraft:chest", 0, -1),
            ["F"]   = Block:newInstance("minecraft:chest", 1, 0),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [3] = "DDF",
            [2] = "C F",
            [1] = "CEE",
        })
    )
end

function Silo.GetBuildBlueprint(...)
    -- get & check input from description
    local checkSuccess, baseLocation, nTopChests, nLayers = InputChecker.Check([[
        This method returns a blueprint for building a Silo in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            constructParameters         - (table) parameters for constructing the Silo
                baseLocation            + (Location) base location of the Silo
                nTopChests              + (number, 2) # of top chests
                nLayers                 + (number, 2) # of layers
    ]], ...)
    if not checkSuccess then corelog.Error("Silo.GetBuildBlueprint: Invalid input") return nil, nil end

    -- construct layer list
    if nTopChests ~= 2 then corelog.Warning("Silo.GetBuildBlueprint: Not yet implemented for other (="..nTopChests..") than 2 top chests") end
    local layerList = {
        { startpoint = Location:newInstance(0, 0, 0), buildDirection = "Down", layer = TopL0_layer()}, -- ToDo: use nTopChests
        { startpoint = Location:newInstance(3, 3, -1), buildDirection = "Up", layer = Shaft_layer()},
    }
    for i=1, nLayers, 1 do
        table.insert(layerList, { startpoint = Location:newInstance(2, 2, -1-i), buildDirection = "Up", layer = Storage_layer()})
    end

    -- construct blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = {
            Location:newInstance(3, 3, 1),
        }
    }

    -- determine buildLocation
    local buildLocation = baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

local function StorageDismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["D"]   = Block:newInstance("minecraft:dirt"),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
        }),
        CodeMap:newInstance({
            [3] = "DDD",
            [2] = "D?D",
            [1] = "DDD",
        })
    )
end

local function ShaftDismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["D"]   = Block:newInstance("minecraft:dirt"),
        }),
        CodeMap:newInstance({
            [1] = "D",
        })
    )
end

local function TopDismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [6] = "     ",
            [5] = "     ",
            [4] = "     ",
            [3] = "     ",
            [2] = "     ",
            [1] = "     ",
        })
    )
end

function Silo:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the Silo in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- construct layer list
    local layerList = {
        -- dismantle top layer
        { startpoint = Location:newInstance(0, 0, 0), buildDirection = "Down", layer = TopDismantle_layer()},
        -- position in shaft of first storage layer
        { startpoint = Location:newInstance(3, 3, -1), buildDirection = "Up", layer = Shaft_layer()},
    }
    local nLayers = self:getNStorageLayers()
    for i=1, nLayers, 1 do
        -- dismantle storage layer i
        table.insert(layerList, { startpoint = Location:newInstance(2, 2, -1-i), buildDirection = "Up", layer = StorageDismantle_layer()})
    end
    -- position in shaft below last storage layer
    table.insert(layerList, { startpoint = Location:newInstance(3, 3, -1-nLayers), buildDirection = "Up", layer = Shaft_layer()})
    for i=1, nLayers+1, 1 do
        -- dismantle shaft layer i
        table.insert(layerList, { startpoint = Location:newInstance(3, 3, -2-nLayers+i), buildDirection = "Down", layer = ShaftDismantle_layer()})
    end

    -- note: this dismantle blueprint does not restore the layer below the last storage layer

    -- construct blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = {
            Location:newInstance(3, 3, 1),
        }
    }

    -- determine buildLocation
    local buildLocation = self._baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

local defaultHostName = "enterprise_storage"

function Silo:provideItemsTo_AOSrv(...)
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
    if not checkSuccess then corelog.Error("Silo:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- create project definition
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local projectData = {
        provideItems            = provideItems,
        pickupLocator           = self:getPickupLocation(),

        itemDepotLocator        = itemDepotLocator,

        assignmentsPriorityKey  = assignmentsPriorityKey,
        silo                    = self:copy(),
    }
    local projectDef = {
        steps   = {
            -- roept functie aan die goederen uit de Silo naar de top Chest brengt
            { stepType = "AOSrv", stepTypeDef = { className = "Silo", serviceName = "fromSiloIntoTopchest_AOSrv", objStep = 0, objKeyDef = "silo" }, stepDataDef = {
                { keyDef = "provideItems"           , sourceStep = 0, sourceKeyDef = "provideItems" },
                { keyDef = "pickupLocator"          , sourceStep = 0, sourceKeyDef = "pickupLocator" },
                { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
            -- roept functie aan die goederen van top Chest naar destination brengt
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "itemDepotLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"                   , sourceStep = 1, sourceKeyDef = "destinationItemsLocator" },
                { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
        },
        returnData  = {
            { keyDef = "destinationItemsLocator"    , sourceStep = 2, sourceKeyDef = "destinationItemsLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Retrieving from a silo", description = "Underground magic" },
    }

    -- start project
    corelog.WriteToLog(">Retrieve "..textutils.serialise(provideItems).." from Silo")
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function Silo:can_ProvideItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("Silo:can_ProvideItems_QOSrv: Invalid input") return {success = false} end

    -- no trouble if we are not (or no longer) operational
    if not self._operational then
        -- weird
        corelog.WriteToLog("inactive silo queried (self._operational = "..tostring(self._operational)..")")

        -- ignore this for now
    --    return {success = false, message = "silo not operational"}
    end

    -- loop all storage Chest's to see if we can deliver
    -- version 0.2, only intersted if 1 Chest can fully deliver (no partial deliveries yet)
    for i, chestLocator in ipairs(self._storageChests) do
        -- get the Chest
        local chest     = ObjHost.GetObj(chestLocator)

        -- valid opbject?
        if chest then

            -- get the inventory of this Chest
            local inventory = chest:getInventory()

            -- valid object?
            if inventory then

                -- can we deliver from this one?
                if inventory:hasItems(provideItems) then

                    -- nice, we found it!
                    return {
                        success = true,
                        pickupList = {
                            {
                                chestLocator = chestLocator:copy(),
                                itemList     = provideItems,
                            },
                        },
                    }
                end
            end
        end
    end

    -- guess we did not find anything
    return {success = false, message = "items not available"}
end

function Silo:needsTo_ProvideItemsTo_SOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems, itemDepotLocator = InputChecker.Check([[
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
    if not checkSuccess then corelog.Error("Silo:needsTo_ProvideItemsTo_SOSrv: Invalid input") return {success = false} end

    -- determine fuelNeed
    corelog.Warning("Silo:needsTo_ProvideItemsTo_SOSrv: coarse estimate of fuel provided => better needed")
    -- ToDo: implement
    local fuelNeed = 10 + #self._storageChests

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

function Silo:storeItemsFrom_AOSrv(...)
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
    if not checkSuccess then corelog.Error("Silo:storeItemsFrom_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- create project data
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local itemTable = ItemTable:newInstance(itemsLocator:getQuery())
    local destinationItemsLocator = LObjLocator:newInstance(defaultHostName, self, itemTable:copy())
    local projectData = {
        itemsLocator            = itemsLocator,
        dropLocator             = self:getDropLocation(),
        assignmentsPriorityKey  = assignmentsPriorityKey,

        destinationItemsLocator = destinationItemsLocator,

        silo                    = self:copy(),
    }
    -- create project definition
    local projectDef = {
        steps   = {
            -- roept functie aan die goederen van pickup locati enaar silo topchest
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "dropLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"           , sourceStep = 0, sourceKeyDef = "itemsLocator" },
                { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
            -- roept functie aan die goederen van topchest opslaat in de silo
                -- roept functie aan die bepalen welke items naar welke chjests moeten
                    -- indien geen ruimte, eerst enterprise inschakelen voor uitbreiding
                -- per goederen type opslaan
            { stepType = "AOSrv", stepTypeDef = { className = "Silo", serviceName = "fromTopchestIntoSilo_AOSrv", objStep = 0, objKeyDef = "silo" }, stepDataDef = {
                { keyDef = "itemsLocator"           , sourceStep = 1, sourceKeyDef = "destinationItemsLocator" },
                { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
        },
        returnData  = {
            { keyDef = "destinationItemsLocator"    , sourceStep = 0, sourceKeyDef = "destinationItemsLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "The silo is for storing", description = "Free your inventory and the rest will follow" },
    }

    -- start project
    corelog.WriteToLog(">Store "..itemsLocator:getURI().." into Silo")
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function Silo:can_StoreItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("Silo:can_StoreItems_QOSrv: Invalid input") return {success = false} end

    -- ToDo: implement
    corelog.Warning("Silo:can_StoreItems_QOSrv: not yet implemented")
    return {success = self._operational} -- we can always store (at least that is what we pretent as long as we are in operation)
end

function Silo:needsTo_StoreItemsFrom_SOSrv(...)
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
    if not checkSuccess then corelog.Error("Silo:needsTo_StoreItemsFrom_SOSrv: Invalid input") return {success = false} end

    -- ToDo: implement
    corelog.Warning("Silo:needsTo_StoreItemsFrom_SOSrv: not yet implemented")
    return {success = true, fuelNeed = 10 + #self._storageChests} -- we can fix anything with that much fuel
end

function Silo:getItemDepotLocation()
    return self:getBaseLocation()
end

--     _____ _ _
--    / ____(_) |
--   | (___  _| | ___
--    \___ \| | |/ _ \
--    ____) | | | (_) |
--   |_____/|_|_|\___/

function Silo:getDropLocation()
    -- easy
    return self._topChests[self._dropLocation]
end

function Silo:getPickupLocation()
    -- easy
    return self._topChests[self._pickupLocation]
end

-- private methods

function Silo:fromSiloIntoTopchest_AOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems, pickupLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
        Todo betere omschrijving
            -- roept functie aan die bepalen welke items naar welke chjests moeten
            -- indien geen ruimte, eerst enterprise inschakelen voor uitbreiding
            -- per goederen type opslaan

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether the service executed successfully
                destinationItemsLocator - (ObjLocator) locating the final ItemDepot and the items that where transferred to it
                                            (upon service succes the "host" component of this ObjLocator should be equal to itemDepotLocator, and
                                            the "query" should be equal to orderItems)

        Parameters:
            serviceData                 - (table) data about the service
                provideItems            + (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs) to provide
                pickupLocator           + (ObjLocator) locating the pickupLocator where the items need to be provided to
                assignmentsPriorityKey  + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                    + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("Silo:fromSiloIntoTopchest_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- check if we can provide the requested items
    local answer    = self:can_ProvideItems_QOSrv({provideItems = provideItems})

    -- check if we can!
    if not answer or not answer.success then
        corelog.Error("Silo:fromSiloIntoTopchest_AOSrv(...): don't know where to get the requested items")
        corelog.WriteToLog("answer:")
        corelog.WriteToLog(answer)
        return Callback.ErrorCall(callback)
    end

    -- create the project data
    local projectData   = {
        pickupLocator           = pickupLocator,
        assignmentsPriorityKey  = assignmentsPriorityKey,
    }

    -- for the steps
    local projectSteps  = {}

    -- loop the pickup list
    for i, value in ipairs(answer.pickupList) do
        -- make the data
        local chestLocator = value.chestLocator
        chestLocator:setQuery(value.itemList)

        -- add to project data
        projectData[ "sourceChestLocator" .. i ] = chestLocator

        -- add new project step
        table.insert(projectSteps,
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "pickupLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"                   , sourceStep = 0, sourceKeyDef = "sourceChestLocator" .. i },
                { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }}
        )
    end

    -- create ObjLocator where the items are with item list
--    local chestOneItemsLocator = self._storageChests[ 1 ]:copy() -- to improve!
--    local sourceChestLocator = answer.pickupList[1].chestLocator
--    sourceChestLocator:setQuery(answer.pickupList[1].itemList)

    -- the project definition
    local projectServiceData = {
        projectData = projectData,
        projectDef  = {
            steps   = projectSteps,
--            {
                -- roept functie aan die goederen van pickup locatie naar silo topchest
            --    { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "pickupLocator" }, stepDataDef = {
            --        { keyDef = "itemsLocator"                   , sourceStep = 0, sourceKeyDef = "sourceChestLocator" },
            --        { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            --    }},
            returnData  = {
                { keyDef = "destinationItemsLocator"    , sourceStep = 1, sourceKeyDef = "destinationItemsLocator" }, -- todo: merge different URLs when items came from different chests, see enterprise_isp.AddItemsLocators_SSrv
            }
        },
        projectMeta = { title = "Internal silo project", description = "None of your business" },
    }

    -- start project
    corelog.WriteToLog(">fromSiloIntoTopchest_AOSrv(...)")
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function Silo:fromTopchestIntoSilo_AOSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
        Todo betere omschrijving
            -- roept functie aan die bepalen welke items naar welke chjests moeten
            -- indien geen ruimte, eerst enterprise inschakelen voor uitbreiding
            -- per goederen type opslaan

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether the service executed successfully

        Parameters:
            serviceData                 - (table) data about the service
                itemsLocator            + (ObjLocator) locating the items to store
                                            (the "base" component of the ObjLocator specifies the ItemSupplier that provides the items)
                                            (the "query" component of the ObjLocator specifies the items)
                assignmentsPriorityKey  + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                    + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("Silo:fromTopchestIntoSilo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    corelog.WriteToLog("fromTopchestIntoSilo_AOSrv begin")

    local projectData = {
        itemsLocator            = itemsLocator,
        chestOneLocator         = self._storageChests[ math.random( #self._storageChests ) ],
        assignmentsPriorityKey  = assignmentsPriorityKey,
    }
    local projectDef = {
        steps   = {
            -- roept functie aan die goederen van pickup locati enaar silo topchest
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "chestOneLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"           , sourceStep = 0, sourceKeyDef = "itemsLocator" },
                { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
        },
        returnData  = {
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Internal silo project", description = "None of your business" },
    }

    -- start project
    corelog.WriteToLog(">fromTopchestIntoSilo_AOSrv(...)")
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function Silo:update()
    -- one host at this time NOT WORKING
--    enterprise_storage:saveObj(self)
end

--[[
             _            _
            (_)          | |
  _ __  _ __ ___   ____ _| |_ ___
 | '_ \| '__| \ \ / / _` | __/ _ \
 | |_) | |  | |\ V / (_| | ||  __/
 | .__/|_|  |_| \_/ \__,_|\__\___|
 | |
 |_|
--]]

function Silo:integrityCheck_AOSrv(...)
    -- get & check input from description
    local checkSuccess, callback = InputChecker.Check([[
        Restore the integrity of the Silo.

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether the service executed successfully

        Parameters:
            serviceData                 - (table) data about the service
            callback                    + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("Silo:integrityCheck_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- create the project data
    local projectData   = {
    }

    -- for the steps
    local projectSteps  = {}

    -- check all top Chest's
    for i, chestLocator in ipairs(self._topChests) do
        -- add to project data
        projectData[ "topChestLocator"..i ] = chestLocator

        -- add new project step
        table.insert(projectSteps,
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "updateChestRecord_AOSrv", locatorStep = 0, locatorKeyDef = "topChestLocator"..i }, stepDataDef = {
            }}
        )
    end

    -- check all storage Chest's
    for i, chestLocator in ipairs(self._storageChests) do
        -- add to project data
        projectData[ "storageChestLocator"..i ] = chestLocator

        -- add new project step
        table.insert(projectSteps,
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "updateChestRecord_AOSrv", locatorStep = 0, locatorKeyDef = "storageChestLocator"..i }, stepDataDef = {
            }}
        )
    end

    -- the project definition
    local projectServiceData = {
        projectData = projectData,
        projectDef  = {
            steps   = projectSteps,
            returnData  = {
            }
        },
        projectMeta = { title = "Silo Integrity Check", description = "None of your business" },
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function Silo:GetChestInventory(chestLocator)
    local chest = ObjHost.GetObj(chestLocator)
    if chest then corelog.WriteToLog("Getting Chest inventory") return chest:getInventory() end
end

return Silo
