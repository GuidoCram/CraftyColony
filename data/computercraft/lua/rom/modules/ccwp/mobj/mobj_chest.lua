-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ILObj = require "i_lobj"
local IMObj = require "i_mobj"
local IItemSupplier = require "i_item_supplier"
local IItemDepot = require "i_item_depot"
local Chest = Class.NewClass(ObjBase, ILObj, IMObj, IItemSupplier, IItemDepot)

--[[
    The Chest mobj represents a Chest in the minecraft world and provides services to operate on that Chest.

    The following design decisions are made
        - The actual Chest's should never be accessed directly but only via the services of this mobj.
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local URL = require "obj_url"
local ObjHost = require "obj_host"
local ObjTable = require "obj_table"
local Location = require "obj_location"
local Inventory = require "obj_inventory"
local Block = require "obj_block"
local CodeMap = require "obj_code_map"
local LayerRectangle = require "obj_layer_rectangle"
local ItemTable = require "obj_item_table"

local LObjLocator = require "lobj_locator"

local Turtle = require "mobj_turtle"

local role_energizer = require "role_energizer"
local role_conservator = require "role_conservator"

local enterprise_projects = require "enterprise_projects"
local enterprise_employment

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function Chest:_init(...)
    -- get & check input from description
    local checkSuccess, id, baseLocation, accessDirection, inventory = InputChecker.Check([[
        Initialise a Chest.

        Parameters:
            id                      + (string) id of the Chest
            baseLocation            + (Location) base location of the Chest
            accessDirection         + (string) whether to access Chest from "bottom", "top", "left", "right", "front" or "back" (relative to location)
            inventory               + (Inventory) inventory of Chest
    ]], ...)
    if not checkSuccess then corelog.Error("Chest:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id                = id
    self._baseLocation      = baseLocation
    self._accessDirection   = accessDirection
    self._inventory         = inventory
end

-- ToDo: should be renamed to newFromTable at some point
function Chest:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a Chest.

        Parameters:
            o                           + (table, {}) with object fields
                _id                     - (string) id of the Chest
                _baseLocation           - (Location) base location of the Chest
                _accessDirection        - (string) whether to access Chest from "bottom", "top", "left", "right", "front" or "back" (relative to location)
                _inventory              - (Inventory) inventory of Chest
    ]], ...)
    if not checkSuccess then corelog.Error("Chest:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function Chest:getAccessDirection()
    return self._accessDirection
end

function Chest:getInventory()
    return self._inventory
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function Chest:getClassName()
    return "Chest"
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function Chest:construct(...)
    -- get & check input from description
    local checkSuccess, baseLocation, accessDirection = InputChecker.Check([[
        This method constructs a Chest instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        The constructed Chest is not yet saved in the LObjHost.

        Return value:
                                        - (Chest) the constructed Chest

        Parameters:
            constructParameters         - (table) parameters for constructing the Chest
                baseLocation            + (Location) base location of the Chest
                accessDirection         + (string, "top") whether to access Chest from "bottom", "top", "left", "right", "front" or "back" (relative to location)
    ]], ...)
    if not checkSuccess then corelog.Error("Chest:construct: Invalid input") return nil end

    -- determine Chest fields
    local id = coreutils.NewId()
    local inventory = Inventory:newInstance() -- assumed to be empty

    -- construct new Chest
    local obj = Chest:newInstance(id, baseLocation:copy(), accessDirection, inventory)

    -- end
    return obj
end

function Chest:destruct()
    --[[
        This method destructs a Chest instance.

        The Chest is not yet deleted from the LObjHost.

        Return value:
                                        - (boolean) whether the Chest was succesfully destructed.

        Parameters:
    ]]

    -- end
    return true
end

function Chest:getId()
    --[[
        Return the unique Id of the Chest.
    ]]

    return self._id
end

function Chest:getWIPId()
    --[[
        Returns the unique Id of the Chest used for administering WIP.
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

function Chest:getBaseLocation()
    return self._baseLocation
end

local function Chest_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["C"]   = Block:newInstance("minecraft:chest"),
        }),
        CodeMap:newInstance({
            [1] = "C",
        })
    )
end

function Chest.GetBuildBlueprint(...)
    -- get & check input from description
    local checkSuccess, baseLocation = InputChecker.Check([[
        This method returns a blueprint for building a Chest in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            constructParameters         - (table) parameters for constructing the Chest
                baseLocation            + (Location) base location of the Chest
                accessDirection         - (string, "top") whether to access Chest from "bottom", "top", "left", "right", "front" or "back" (relative to location)
    ]], ...)
    if not checkSuccess then corelog.Error("Chest.GetBuildBlueprint: Invalid input") return nil, nil end

    -- construct layer list
    local layerList = {
        { startpoint = Location:newInstance(0, 0, 0), buildDirection = "Down", layer = Chest_layer()},
    }

    -- construct blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = {
        }
    }

    -- determine buildLocation
    local buildLocation = baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

local function ChestDismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [1] = " ",
        })
    )
end

function Chest:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the Chest in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- construct layer list
    local layerList = {
        { startpoint = Location:newInstance(0, 0, 0), buildDirection = "Down", layer = ChestDismantle_layer()},
    }

    -- construct blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = {
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

function Chest:provideItemsTo_AOSrv(...)
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
    if not checkSuccess then corelog.Error("Chest:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- check if ItemDepot is a Turtle
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local depotTurtleId = -1
    if itemDepotLocator:getObjClassName() == Turtle:getClassName() and not itemDepotLocator:sameBase(enterprise_employment.GetAnyTurtleLocator()) then
        local turtleObj = ObjHost.GetObj(itemDepotLocator) if not turtleObj then corelog.Error("Chest:provideItemsTo_AOSrv: Failed obtaining Turtle "..itemDepotLocator:getURI()) return Callback.ErrorCall(callback) end
        depotTurtleId = turtleObj:getWorkerId()
    end

    -- create project data
    local taskData = {
        location        = self:getBaseLocation():copy(),
        accessDirection = self:getAccessDirection(),
        itemsQuery      = provideItems,

        turtleId        = depotTurtleId,
        priorityKey     = assignmentsPriorityKey,
    }
    local lobjLocator = LObjLocator:newInstance(defaultHostName, self)
    local projectData = {
        hostLocator             = URL:newInstance(defaultHostName),
        lobjLocator             = lobjLocator,

        metaData                = role_conservator.FetchItemsFromChestIntoTurtle_MetaData(taskData),
        taskCall                = TaskCall:newInstance("role_conservator", "FetchItemsFromChestIntoTurtle_Task", taskData),

        itemDepotLocator        = itemDepotLocator,
        assignmentsPriorityKey  = assignmentsPriorityKey,
    }
    -- create project definition
    local projectDef = {
        steps   = {
            -- put items from Chest
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"               , sourceStep = 0, sourceKeyDef = "metaData" },
                { keyDef = "taskCall"               , sourceStep = 0, sourceKeyDef = "taskCall" },
            }},
            -- get Chest
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "getObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "objLocator"             , sourceStep = 0, sourceKeyDef = "lobjLocator" },
            }},
            -- save Chest
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "saveObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "obj"                    , sourceStep = 2, sourceKeyDef = "obj" },
                { keyDef = "obj._inventory"         , sourceStep = 1, sourceKeyDef = "inventory" },
            }},
            -- store items to ItemDepot
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "itemDepotLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"           , sourceStep = 1, sourceKeyDef = "turtleOutputItemsLocator" },
                { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
        },
        returnData  = {
            { keyDef = "destinationItemsLocator"    , sourceStep = 4, sourceKeyDef = "destinationItemsLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Providing items from "..self:getWIPId(), description = "The items will be deliverd", wipId = self:getWIPId() },
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function Chest:can_ProvideItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("Chest:can_ProvideItems_QOSrv: Invalid input") return {success = false} end

    -- check items in inventory
    local hasItems = self:getInventory():hasItems(provideItems)

    -- end
    return {
        success = hasItems,
    }
end

function Chest:needsTo_ProvideItemsTo_SOSrv(...)
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
    if not checkSuccess then corelog.Error("Chest:needsTo_ProvideItemsTo_SOSrv: Invalid input") return {success = false} end

    -- get ItemDepot
    local destinationItemDepot = ObjHost.GetObj(destinationItemDepotLocator)
    if not destinationItemDepot or not Class.IsInstanceOf(destinationItemDepot, IItemDepot) then corelog.Error("Chest:needsTo_ProvideItemsTo_SOSrv: Failed obtaining an IItemDepot from destinationItemDepotLocator "..destinationItemDepotLocator:getURI()) return {success = false} end

    -- get locations
    local localLocation = self:getBaseLocation()
    local destinationLocation = destinationItemDepot:getItemDepotLocation()

    -- fuelNeed from Chest to ItemDepot
    local fuelNeed_FromChestToItemDepot = role_energizer.NeededFuelToFrom(destinationLocation, localLocation)

    -- loop on items
    local fuelNeed = 0
    for _itemName, _itemCount in pairs(provideItems) do
        -- add fuelNeed
        fuelNeed = fuelNeed + fuelNeed_FromChestToItemDepot
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

function Chest:storeItemsFrom_AOSrv(...)
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
    if not checkSuccess then corelog.Error("Chest:storeItemsFrom_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- create project data
    local itemTable = ItemTable:newInstance(itemsLocator:getQuery())
    local taskData = {
        turtleId        = -1,
        itemsQuery      = itemTable:copy(),
        location        = self:getBaseLocation():copy(),
        accessDirection = self:getAccessDirection(),

        priorityKey     = assignmentsPriorityKey,
    }
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local lobjLocator = LObjLocator:newInstance(defaultHostName, self)
    local destinationItemsLocator = LObjLocator:newInstance(defaultHostName, self, itemTable:copy())
    local projectData = {
        hostLocator             = URL:newInstance(defaultHostName),
        lobjLocator             = lobjLocator,

        metaData                = role_conservator.PutItemsFromTurtleIntoChest_MetaData(taskData),
        taskCall                = TaskCall:newInstance("role_conservator", "PutItemsFromTurtleIntoChest_Task", taskData),

        itemsLocator            = itemsLocator,
        turtleLocator           = enterprise_employment.GetAnyTurtleLocator(),

        destinationItemsLocator = destinationItemsLocator,

        assignmentsPriorityKey  = assignmentsPriorityKey,
    }
    -- create project definition
    local projectDef = {
        steps   = {
            -- get items into a turtle
            -- ToDo: consider using provideItemsTo_AOSrv here
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "turtleLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"           , sourceStep = 0, sourceKeyDef = "itemsLocator" },
                { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
            -- obtain workerId
            { stepType = "LSOMtd", stepTypeDef = { methodName = "getWorkerId", locatorStep = 1, locatorKeyDef = "destinationItemsLocator" }, stepDataDef = {
            }},
            -- put items into Chest
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"               , sourceStep = 0, sourceKeyDef = "metaData" },
                { keyDef = "metaData.needWorkerId"  , sourceStep = 2, sourceKeyDef = "methodResults" },
                { keyDef = "taskCall"               , sourceStep = 0, sourceKeyDef = "taskCall" },
                { keyDef = "taskCall._data.turtleId", sourceStep = 2, sourceKeyDef = "methodResults" },
            }},
            -- get Chest
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "getObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "objLocator"             , sourceStep = 0, sourceKeyDef = "lobjLocator" },
            }},
            -- save Chest
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "saveObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "obj"                    , sourceStep = 4, sourceKeyDef = "obj" },
                { keyDef = "obj._inventory"         , sourceStep = 3, sourceKeyDef = "inventory" },
            }},
        },
        returnData  = {
            { keyDef = "destinationItemsLocator"    , sourceStep = 0, sourceKeyDef = "destinationItemsLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Storing items to "..self:getWIPId(), description = "Getting stuff off your hands", wipId = self:getWIPId() },
    }

    -- start project
    corelog.WriteToLog(">Store "..itemsLocator:getURI().." into Chest "..self:getId())
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function Chest:can_StoreItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("Chest:can_StoreItems_QOSrv: Invalid input") return {success = false} end

    -- ToDo: implement
    corelog.Warning("Chest:can_StoreItems_QOSrv: not yet implemented")
    return {success = false}
end

function Chest:needsTo_StoreItemsFrom_SOSrv(...)
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
    if not checkSuccess then corelog.Error("Chest:needsTo_StoreItemsFrom_SOSrv: Invalid input") return {success = false} end

    -- ToDo: implement
    corelog.Warning("Chest:needsTo_StoreItemsFrom_SOSrv: not yet implemented")
    return {success = false}
end

function Chest:getItemDepotLocation()
    return self:getBaseLocation()
end

--     _____ _               _
--    / ____| |             | |
--   | |    | |__   ___  ___| |_
--   | |    | '_ \ / _ \/ __| __|
--   | |____| | | |  __/\__ \ |_
--    \_____|_| |_|\___||___/\__|


function Chest:updateChestRecord_AOSrv(...)
    -- get & check input from description
    local checkSuccess, callback = InputChecker.Check([[
        This async service brings the records of the Chest up-to-date by fetching information and (re)setting the Chest records.

        Using this method should normally not be needed as the records should be kept up-to-date by the various enterprise services. It could
        typically be used for development purposes or, if for some reason (e.g. after a turtle crash), the Chest records could have been corrupted.

        Return value:
                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                - (table)
                success         - (boolean) whether the service executed successfully
                chest           - (table) the Chest

        Parameters:
            serviceData         - (table) data about the service
            callback            + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("Chest:updateChestRecord_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- create project data
    local taskData = {
        location = self:getBaseLocation():copy(),
        accessDirection = self:getAccessDirection(),
    }
    local lobjLocator = LObjLocator:newInstance(defaultHostName, self)
    local projectData = {
        hostLocator     = URL:newInstance(defaultHostName),
        lobjLocator     = lobjLocator,

        metaData        = role_conservator.FetchChestSlotsInventory_MetaData(taskData),
        taskCall        = TaskCall:newInstance("role_conservator", "FetchChestSlotsInventory_Task", taskData),
    }
    -- create project definition
    local projectDef = {
        steps   = {
            -- fetch inventory from Chest
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"               , sourceStep = 0, sourceKeyDef = "metaData" },
                { keyDef = "taskCall"               , sourceStep = 0, sourceKeyDef = "taskCall" },
            }, description = "Fetching Chest "..self:getId().." inventory"},
            -- get Chest
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "getObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "objLocator"             , sourceStep = 0, sourceKeyDef = "lobjLocator" },
            }},
            -- save Chest
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "saveObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "obj"                    , sourceStep = 2, sourceKeyDef = "obj" },
                { keyDef = "obj._inventory"         , sourceStep = 1, sourceKeyDef = "inventory" },
            }, description = "Saving Chest "..self:getId()},
        },
        returnData  = {
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Updating record "..self:getWIPId(), description = "Sit back and relax", wipId = self:getWIPId() },
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

return Chest
