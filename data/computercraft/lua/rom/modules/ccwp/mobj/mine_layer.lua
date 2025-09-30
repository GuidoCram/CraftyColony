-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ILObj = require "i_lobj"
local IMObj = require "i_mobj"
local IItemSupplier = require "i_item_supplier"
local MineLayer = Class.NewClass(ObjBase, ILObj, IMObj, IItemSupplier)

--[[
    This module implements a MineLayer.

    A MineLayer is a layer for mining resources in the minecraft world.

    A MineLayer is 3 blocks high, contains a base, and gatheres the resources concentric around that base.
--]]

local corelog = require "corelog"
local coreutils = require "coreutils"

local InputChecker = require "input_checker"

local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local URL = require "obj_url"
local ObjHost = require "obj_host"
local ObjTable = require "obj_table"
local Location = require "obj_location"
local Block = require "obj_block"
local CodeMap = require "obj_code_map"
local LayerRectangle = require "obj_layer_rectangle"
local ItemTable = require "obj_item_table"

local IItemDepot = require "i_item_depot"
local LObjLocator = require "lobj_locator"

local role_miner = require "role_miner"
local role_energizer = require "role_energizer"

local enterprise_projects = require "enterprise_projects"
local enterprise_storage = require "enterprise_storage"
local enterprise_gathering

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function MineLayer:_init(...)
    -- get & check input from description
    local checkSuccess, id, baseLocation, currentHalfRib, cacheItemsLocator = InputChecker.Check([[
        Initialise a MineLayer.

        Parameters:
            id                      + (string) id of the MineLayer
            baseLocation            + (Location) base location of the MineLayer
            currentHalfRib          + (number) with current halfRib of the MineLayer
            cacheItemsLocator       + (ObjLocator) locating the cache ItemSupplier of mined items
    ]], ...)
    if not checkSuccess then corelog.Error("MineLayer:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id                    = id
    self._baseLocation          = baseLocation
    self._currentHalfRib        = currentHalfRib
    self._cacheItemsLocator     = cacheItemsLocator
end

-- ToDo: should be renamed to newFromTable at some point
function MineLayer:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a MineLayer.

        Parameters:
            o                           + (table, {}) with object fields
                _id                     - (string) id of the MineLayer
                _baseLocation           - (Location) base location of the MineLayer
                _currentHalfRib         - (number) with current halfRib of the MineLayer
                _cacheItemsLocator      - (ObjLocator) locating the cache ItemSupplier of mined items
    ]], ...)
    if not checkSuccess then corelog.Error("MineLayer:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function MineLayer:getCurrentHalfRib()
    return self._currentHalfRib
end

function MineLayer:getCacheItemsLocator()
    return self._cacheItemsLocator
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function MineLayer:getClassName()
    return "MineLayer"
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function MineLayer:construct(...)
    -- get & check input from description
    local checkSuccess, baseLocation = InputChecker.Check([[
        This method constructs a MineLayer instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        The constructed MineLayer is not yet saved in the LObjHost.

        Return value:
                                        - (MineLayer) the constructed MineLayer

        Parameters:
            constructParameters         - (table) parameters for constructing the MineLayer
                baseLocation            + (Location) base location of the MineLayer
    ]], ...)
    if not checkSuccess then corelog.Error("MineLayer:construct: Invalid input") return nil end

    -- cacheItemsLocator
    local cacheItemsLocator = enterprise_storage:hostLObj_SSrv({ className = "Chest", constructParameters = {
        baseLocation    = baseLocation:getRelativeLocation(-1, 2, 0),
        accessDirection = "back",
    }}).mobjLocator

    -- construct new MineLayer
    local id = coreutils.NewId()
    local startHalfRib = 3
    local obj = MineLayer:newInstance(id, baseLocation:copy(), startHalfRib, cacheItemsLocator)

    -- end
    return obj
end

function MineLayer:upgrade(...)
    -- get & check input from description
    local checkSuccess = InputChecker.Check([[
        This method upgrades a MineLayer instance from a table of parameters.

        The upgraded MineLayer is not yet saved in the LObjHost.

        Return value:
                                        - (boolean) whether the MineLayer was succesfully upgraded.

        Parameters:
            upgradeParameters           - (table) parameters for upgrading the MineLayer
    ]], ...)
    if not checkSuccess then corelog.Error("MineLayer:upgrade: Invalid input") return false end

    -- end
    return true
end

function MineLayer:destruct()
    --[[
        This method destructs a MineLayer instance.

        The MineLayer is not yet deleted from the LObjHost.

        Return value:
                                        - (boolean) whether the MineLayer was succesfully destructed.

        Parameters:
    ]]

    -- cacheItemsLocator
    local destructSuccess = true
    local cacheItemsLocator = self:getCacheItemsLocator()
    local releaseResult = enterprise_storage:releaseLObj_SSrv({ mobjLocator = cacheItemsLocator })
    if not releaseResult or not releaseResult.success then corelog.Warning("MineLayer:destruct(): failed releasing cacheItemsLocator "..cacheItemsLocator:getURI()) destructSuccess = false end

    -- end
    return destructSuccess
end

function MineLayer:getId()
    return self._id
end

function MineLayer:getWIPId()
    --[[
        Returns the unique Id of the MineLayer used for administering WIP.
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

function MineLayer:getBaseLocation()
    return self._baseLocation
end

local function Bottom_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["L"]   = Block:newInstance("minecraft:birch_log"),
            ["P"]   = Block:newInstance("minecraft:birch_planks"),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [7] = "LLLLLLL",
            [6] = "LPPPPPL",
            [5] = "LPPPPPL",
            [4] = "LP P PL",
            [3] = "LPPPPPL",
            [2] = "LPPPPPL",
            [1] = "LLLLLLL",
        })
    )
end

local function Mid_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["T"]   = Block:newInstance("minecraft:torch"),
            ["C"]   = Block:newInstance("minecraft:chest"),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [7] = "   T   ",
            [6] = "  C C  ",
            [5] = "       ",
            [4] = "T     T",
            [3] = "       ",
            [2] = "       ",
            [1] = "   T   ",
        })
    )
end

local function Top_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [7] = "       ",
            [6] = "       ",
            [5] = "       ",
            [4] = "       ",
            [3] = "       ",
            [2] = "       ",
            [1] = "       ",
        })
    )
end

function MineLayer.GetBuildBlueprint(...)
    -- get & check input from description
    local checkSuccess, baseLocation = InputChecker.Check([[
        This method returns a blueprint for building a MineLayer in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            constructParameters         - (table) parameters for constructing the MineLayer
                baseLocation            + (Location) base location of the MineLayer
    ]], ...)
    if not checkSuccess then corelog.Error("MineLayer.GetBuildBlueprint: Invalid input") return nil, nil end

    -- buildLocation
    local offsetX = 1
    local buildLocation = baseLocation:getRelativeLocation(offsetX, 0, 0)

    -- layerList
    local layerList = {}
    local buildLayerLocation = Location:newInstance(-3 - offsetX, -3, -1)
    table.insert(layerList, { startpoint = buildLayerLocation, buildDirection = "Down", layer = Bottom_layer()})
    buildLayerLocation = Location:newInstance(-3 - offsetX, -3, 1)
    table.insert(layerList, { startpoint = buildLayerLocation, buildDirection = "Up", layer = Top_layer()})
    buildLayerLocation = Location:newInstance(-3 - offsetX, -3, 0)
    table.insert(layerList, { startpoint = buildLayerLocation, buildDirection = "Down", layer = Mid_layer()})

    -- escapeSequence
    local escapeSequence = {}
    table.insert(escapeSequence, Location:newInstance(-1 - offsetX, 0, 0))
    table.insert(escapeSequence, Location:newInstance(-1 - offsetX, 0, -baseLocation:getZ() + 2))

    -- blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence,
    }

    -- end
    return buildLocation, blueprint
end

function MineLayer:getExtendBlueprint(...)
    -- get & check input from description
    local checkSuccess = InputChecker.Check([[
        This method returns a blueprint for extending the MineLayer in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            upgradeParameters           - (table) parameters for upgrading the current MineLayer
    ]], ...)
    if not checkSuccess then corelog.Error("MineLayer:getExtendBlueprint: Invalid input") return nil end

    -- layerList
    local layerList = {}

    -- escapeSequence
    local escapeSequence = {}

    -- blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence,
    }

    -- buildLocation
    local baseLocation = self:getBaseLocation()
    local offsetX = 1
    local buildLocation = baseLocation:getRelativeLocation(offsetX, 0, 0)

    -- end
    return buildLocation, blueprint
end

function MineLayer:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the MineLayer in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]


    -- layerList
    local layerList = {}

    -- escapeSequence
    local escapeSequence = {}

    -- blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence
    }

    -- buildLocation
    local baseLocation = self:getBaseLocation()
    local offsetX = 1
    local buildLocation = baseLocation:getRelativeLocation(offsetX, 0, 0)

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

local defaultHostName = "enterprise_gathering"

function MineLayer:provideItemsTo_AOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
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
                ingredientsItemSupplierLocator  + (ObjLocator) locating where possible ingredients needed to provide can be retrieved
                wasteItemDepotLocator           + (ObjLocator) locating where waste material can be delivered
                assignmentsPriorityKey          + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                            + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("MineLayer:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- check cacheItemsLocator (Chest) can provide the requested items
    local cacheItemsLocator = self:getCacheItemsLocator()
    local cacheItemsSupplier = ObjHost.GetObj(cacheItemsLocator)
    if not cacheItemsSupplier or not Class.IsInstanceOf(cacheItemsSupplier, IItemSupplier) then corelog.Error("MineLayer:provideItemsTo_AOSrv: Failed obtaining an IItemSupplier from cacheItemsLocator "..cacheItemsLocator:getURI()) return Callback.ErrorCall(callback) end
    if cacheItemsSupplier:can_ProvideItems_QOSrv({ provideItems = provideItems, }).success then
        -- provide items from cacheItemsSupplier to requested ItemDepot
        return cacheItemsSupplier:provideItemsTo_AOSrv({
            provideItems                    = provideItems,
            itemDepotLocator                = itemDepotLocator,
            ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
            wasteItemDepotLocator           = wasteItemDepotLocator,
            assignmentsPriorityKey          = assignmentsPriorityKey,
        }, callback)
    end

    -- check MineLayer can "in principal" provide the requested items
    local canProvideResult = self:can_ProvideItems_QOSrv({ provideItems = provideItems, })
    if not canProvideResult or not canProvideResult.success then
        corelog.Error("MineLayer:provideItemsTo_AOSrv: the MineLayer can not provide (all) items from "..textutils.serialise(provideItems, {compact = true}))
        return Callback.ErrorCall(callback)
    end

    -- create project data
    local startHalfRib = self:getCurrentHalfRib() + 1
    local taskData = {
        baseLocation        = self:getBaseLocation(),
        startHalfRib        = startHalfRib,

        provideItems        = ItemTable:newInstance(provideItems),
        escape              = true,

        priorityKey         = assignmentsPriorityKey,
    }
    local lobjLocator = LObjLocator:newInstance(defaultHostName, self)
    local projectData = {
        hostLocator                     = URL:newInstance(defaultHostName),
        lobjLocator                     = lobjLocator,

        provideItems                    = ItemTable:newInstance(provideItems),

        cacheItemsLocator               = cacheItemsLocator,
        ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator:copy(),
        wasteItemDepotLocator           = wasteItemDepotLocator:copy(),
        itemDepotLocator                = itemDepotLocator:copy(),

        mineLayerMetaData               = role_miner.MineLayer_MetaData(taskData),
        mineLayerTaskCall               = TaskCall:newInstance("role_miner", "MineLayer_Task", taskData),

        assignmentsPriorityKey          = assignmentsPriorityKey,
    }
    -- create project definition
    local projectDef = {
        steps = {
            -- mine MineLayer
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"                       , sourceStep = 0, sourceKeyDef = "mineLayerMetaData" },
                { keyDef = "taskCall"                       , sourceStep = 0, sourceKeyDef = "mineLayerTaskCall" },
            }, description = "Mining "..textutils.serialise(provideItems, {compact = true}).." from MineLayer (rectangle "..startHalfRib..") task"},
            -- get MineLayer
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "getObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "objLocator"                     , sourceStep = 0, sourceKeyDef = "lobjLocator" },
            }},
            -- save MineLayer
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "saveObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "obj"                            , sourceStep = 2, sourceKeyDef = "obj" },
                { keyDef = "obj._currentHalfRib"            , sourceStep = 1, sourceKeyDef = "endHalfRib" },
            }},
            -- store mined items in cache
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "cacheItemsLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"                   , sourceStep = 1, sourceKeyDef = "turtleOutputItemsLocator" },
                { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
            -- store waste items
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "wasteItemDepotLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"                   , sourceStep = 1, sourceKeyDef = "turtleWasteItemsLocator" },
                { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
            -- recursive call to provide items
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "provideItemsTo_AOSrv", locatorStep = 0, locatorKeyDef = "lobjLocator" }, stepDataDef = {
                { keyDef = "provideItems"                   , sourceStep = 0, sourceKeyDef = "provideItems" },
                { keyDef = "itemDepotLocator"               , sourceStep = 0, sourceKeyDef = "itemDepotLocator" },
                { keyDef = "ingredientsItemSupplierLocator" , sourceStep = 0, sourceKeyDef = "ingredientsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
                { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }, description = "Providing "..textutils.serialise(provideItems, {compact = true}).." recursively"},
        },
        returnData  = {
            { keyDef = "destinationItemsLocator"            , sourceStep = 6, sourceKeyDef = "destinationItemsLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Mining MineLayer", description = "Mining! What this game is made for!", wipId = self:getWIPId() },
    }

    -- start project
    local scheduleResult = enterprise_projects.StartProject_ASrv(projectServiceData, callback)

    -- end
    return scheduleResult
end

function MineLayer:can_ProvideItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("MineLayer:can_ProvideItems_QOSrv: Invalid input") return {success = false} end

    enterprise_gathering = enterprise_gathering or require "enterprise_gathering"
    local minableItems = enterprise_gathering.GetMinableItems()

    -- loop on items
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("MineLayer:can_ProvideItems_QOSrv: itemName of wrong type = "..type(itemName)..".") return {success = false} end

        -- check it's a mineable item
        local isMineableItem = false
        for _, mineItemName in ipairs(minableItems) do
            if itemName == mineItemName then
                isMineableItem = true
            end
        end
        if not isMineableItem then return {success = false} end
    end
    -- note: the MineLayer ItemSupplier implementation returns if "in principle" the items could be provided. In reality we of course only know once we start mining.

    -- end
    return {
        success = true,
    }
end

function MineLayer:needsTo_ProvideItemsTo_SOSrv(...)
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
    if not checkSuccess then corelog.Error("MineLayer:needsTo_ProvideItemsTo_SOSrv: Invalid input") return {success = false} end

    -- fuelNeed_Mining
    local fuelNeed_Mining = 2*4*(self:getCurrentHalfRib() + 1) -- note: we return the fuelNeed for mining the next square
    -- ToDo: take # rounds into account!

    -- get destinationItemDepot
    local destinationItemDepot = ObjHost.GetObj(destinationItemDepotLocator)
    if not destinationItemDepot or not Class.IsInstanceOf(destinationItemDepot, IItemDepot) then corelog.Error("MineLayer:needsTo_ProvideItemsTo_SOSrv: Failed obtaining an IItemDepot from destinationItemDepotLocator "..destinationItemDepotLocator:getURI()) return {success = false} end

    -- get locations
    local destinationLocation = destinationItemDepot:getItemDepotLocation()
    local localLocation = self:getBaseLocation()

    -- fuelNeed output transfer
    local fuelNeed_Transfer = role_energizer.NeededFuelToFrom(destinationLocation, localLocation)

    --
    local fuelNeedEntry = self:getCurrentHalfRib() + 1 -- to go from base to next square
    local fuelNeedExit = self:getCurrentHalfRib() + 1 -- to go back to base
    local fuelNeed = fuelNeedEntry + fuelNeed_Mining + fuelNeedExit + fuelNeed_Transfer
    local ingredientsNeed = {}

    -- end
    return {
        success         = true,
        fuelNeed        = fuelNeed,
        ingredientsNeed = ingredientsNeed,
    }
end

return MineLayer
