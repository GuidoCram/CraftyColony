-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ILObj = require "i_lobj"
local IMObj = require "i_mobj"
local IItemSupplier = require "i_item_supplier"
local MineShaft = Class.NewClass(ObjBase, ILObj, IMObj, IItemSupplier)

--[[
    This module implements a MineShaft.

    A MineShaft is a vertical opening through mine strata used for ventilation or drainage and/or for hoisting of personnel or materials;
        connects the surface with underground workings [http://www.mergerminescorp.com/mining-terms.html].
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
local enterprise_gathering

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function MineShaft:_init(...)
    -- get & check input from description
    local checkSuccess, id, baseLocation, currentDepth, maxDepth = InputChecker.Check([[
        Initialise a MineShaft.

        Parameters:
            id                      + (string) id of the MineShaft
            baseLocation            + (Location) base location of the MineShaft
            currentDepth            + (number) with current depth of the MineShaft
            maxDepth                + (number) with maximum depth of the MineShaft
    ]], ...)
    if not checkSuccess then corelog.Error("MineShaft:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id                    = id
    self._baseLocation          = baseLocation
    self._currentDepth          = currentDepth
    self._maxDepth              = maxDepth
end

-- ToDo: should be renamed to newFromTable at some point
function MineShaft:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a MineShaft.

        Parameters:
            o                           + (table, {}) with object fields
                _id                     - (string) id of the MineShaft
                _baseLocation           - (Location) base location of the MineShaft
                _currentDepth           - (number) with current depth of the MineShaft
                _maxDepth               - (number) with maximum depth of the MineShaft
    ]], ...)
    if not checkSuccess then corelog.Error("MineShaft:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function MineShaft:getCurrentDepth()
    return self._currentDepth
end

function MineShaft:getMaxDepth()
    return self._maxDepth
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function MineShaft:getClassName()
    return "MineShaft"
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function MineShaft:construct(...)
    -- get & check input from description
    local checkSuccess, baseLocation, maxDepth = InputChecker.Check([[
        This method constructs a MineShaft instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        The constructed MineShaft is not yet saved in the LObjHost.

        Return value:
                                        - (MineShaft) the constructed MineShaft

        Parameters:
            constructParameters         - (table) parameters for constructing the MineShaft
                baseLocation            + (Location) base location of the MineShaft
                maxDepth                + (number) with maximum depth of the MineShaft
    ]], ...)
    if not checkSuccess then corelog.Error("MineShaft:construct: Invalid input") return nil end

    -- maxDepth
    if maxDepth > 128 then corelog.Error("MineShaft:construct: depth of "..maxDepth.." not supported") return nil end

    -- construct new MineShaft
    local id = coreutils.NewId()
    local obj = MineShaft:newInstance(id, baseLocation:copy(), 0, maxDepth)

    -- end
    return obj
end

function MineShaft:upgrade(...)
    -- get & check input from description
    local checkSuccess, upgradedMaxDepth = InputChecker.Check([[
        This method upgrades a MineShaft instance from a table of parameters.

        The upgraded MineShaft is not yet saved in the LObjHost.

        Return value:
                                        - (boolean) whether the MineShaft was succesfully upgraded.

        Parameters:
            upgradeParameters           - (table) parameters for upgrading the MineShaft
                maxDepth                + (number) with maximum depth of the MineShaft
    ]], ...)
    if not checkSuccess then corelog.Error("MineShaft:upgrade: Invalid input") return false end

    -- maxDepth
    local maxDepth = self:getMaxDepth()
    if maxDepth > upgradedMaxDepth then corelog.Error("MineShaft:upgrade: Downgradging maxDepth (from "..maxDepth.." to "..upgradedMaxDepth..") not supported") return false end
    if maxDepth < upgradedMaxDepth then
        if upgradedMaxDepth > 128 then corelog.Error("MineShaft:upgrade: Upgrading to depth of "..upgradedMaxDepth.." not supported") return false end
        self._maxDepth = upgradedMaxDepth
    end

    -- end
    return true
end

function MineShaft:destruct()
    --[[
        This method destructs a MineShaft instance.

        The MineShaft is not yet deleted from the LObjHost.

        Return value:
                                        - (boolean) whether the MineShaft was succesfully destructed.

        Parameters:
    ]]

    -- end
    return true
end

function MineShaft:getId()
    return self._id
end

function MineShaft:getWIPId()
    --[[
        Returns the unique Id of the MineShaft used for administering WIP.
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

function MineShaft:getBaseLocation()
    return self._baseLocation
end

local function EntryExit_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
        }),
        CodeMap:newInstance({
            [1] = " ? ",
        })
    )
end

function MineShaft.GetBuildBlueprint(...)
    -- get & check input from description
    local checkSuccess, baseLocation, maxDepth = InputChecker.Check([[
        This method returns a blueprint for building a MineShaft in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            constructParameters         - (table) parameters for constructing the MineShaft
                baseLocation            + (Location) base location of the MineShaft
                maxDepth                + (number) with maximum depth of the MineShaft
    ]], ...)
    if not checkSuccess then corelog.Error("MineShaft.GetBuildBlueprint: Invalid input") return nil, nil end

    -- maxDepth
    if maxDepth > 128 then corelog.Error("MineShaft:GetBuildBlueprint: depth of "..maxDepth.." not supported") return nil end

    -- buildLocation
    local buildLocation = baseLocation:copy()

    -- layerList
    local layerList = {}
    local buildLayerLocation = Location:newInstance(-1, 0, -1)
    table.insert(layerList, { startpoint = buildLayerLocation, buildDirection = "Down", layer = EntryExit_layer()})

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

function MineShaft:getExtendBlueprint(...)
    -- get & check input from description
    local checkSuccess, upgradedMaxDepth = InputChecker.Check([[
        This method returns a blueprint for extending the MineShaft in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            upgradeParameters           - (table) parameters for upgrading the current MineShaft
                maxDepth                + (number) with maximum depth of the MineShaft
    ]], ...)
    if not checkSuccess then corelog.Error("MineShaft:getExtendBlueprint: Invalid input") return nil end

    -- maxDepth
    local maxDepth = self:getMaxDepth()
    if maxDepth > upgradedMaxDepth then corelog.Error("MineShaft:upgrade: Downgradging maxDepth (from "..maxDepth.." to "..upgradedMaxDepth..") not supported") return false end
    if maxDepth < upgradedMaxDepth then
        if upgradedMaxDepth > 128 then corelog.Error("MineShaft:upgrade: Upgrading to depth of "..upgradedMaxDepth.." not supported") return false end
    end

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
    local buildLocation = baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

local function MidPos_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
        }),
        CodeMap:newInstance({
            [1] = "?",
        })
    )
end

local function RowDismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["C"]   = Block:newInstance("minecraft:cobblestone"),
        }),
        CodeMap:newInstance({
            [1] = "CCC",
        })
    )
end

local function ColumnDismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["C"]   = Block:newInstance("minecraft:cobblestone"),
        }),
        CodeMap:newInstance({
            [3] = "C",
            [2] = "C",
            [1] = "C",
        })
    )
end

local function EntryExitDismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["D"]   = Block:newInstance("minecraft:dirt"),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
        }),
        CodeMap:newInstance({
            [1] = "D?D",
        })
    )
end

function MineShaft:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the MineShaft in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    local fillMine = true -- ToDo: consider parameterising this

    -- layerList: fill MineShaft?
    local layerList = {}
    if fillMine then
        -- entry to actualMineStart (by tricking builder)
        local actualMineStart = -3
        local dismantleLayerLocation = Location:newInstance(1, 0, -1)
        table.insert(layerList, { startpoint = dismantleLayerLocation, buildDirection = "Down", layer = MidPos_layer()})
        dismantleLayerLocation = Location:newInstance(1, 0, actualMineStart)
        table.insert(layerList, { startpoint = dismantleLayerLocation, buildDirection = "Down", layer = MidPos_layer()})
        dismantleLayerLocation = Location:newInstance(0, 0, actualMineStart)
        table.insert(layerList, { startpoint = dismantleLayerLocation, buildDirection = "Down", layer = MidPos_layer()})

        -- fill loop
        local currentDepth = self:getCurrentDepth()
        for depth=-currentDepth, 0, 1 do
            dismantleLayerLocation = Location:newInstance(0, 0, actualMineStart + depth)
            table.insert(layerList, { startpoint = dismantleLayerLocation, buildDirection = "Down", layer = MidPos_layer()})
            dismantleLayerLocation = Location:newInstance(-1, 0, actualMineStart + depth)
            table.insert(layerList, { startpoint = dismantleLayerLocation, buildDirection = "Down", layer = RowDismantle_layer()})
            dismantleLayerLocation = Location:newInstance(0, 0, actualMineStart + depth)
            table.insert(layerList, { startpoint = dismantleLayerLocation, buildDirection = "Down", layer = MidPos_layer()}) -- note: prevent remove corner
            dismantleLayerLocation = Location:newInstance(0, -1, actualMineStart + depth)
            table.insert(layerList, { startpoint = dismantleLayerLocation, buildDirection = "Down", layer = ColumnDismantle_layer()})
        end

        -- exit (by tricking builder)
        dismantleLayerLocation = Location:newInstance(0, 0, actualMineStart)
        table.insert(layerList, { startpoint = dismantleLayerLocation, buildDirection = "Down", layer = MidPos_layer()})
        dismantleLayerLocation = Location:newInstance(-1, 0, actualMineStart)
        table.insert(layerList, { startpoint = dismantleLayerLocation, buildDirection = "Down", layer = MidPos_layer()})
    end
    -- layerList: entry/exit layers
    local dismantleLayerLocation = Location:newInstance(-1, 0, -1)
    table.insert(layerList, { startpoint = dismantleLayerLocation, buildDirection = "Down", layer = EntryExitDismantle_layer()})

    -- escapeSequence
    local escapeSequence = {}

    -- blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence
    }

    -- buildLocation
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

local defaultHostName = "enterprise_gathering"

function MineShaft:provideItemsTo_AOSrv(...)
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
    if not checkSuccess then corelog.Error("MineShaft:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- check MineShaft can "in principal" provide the requested items
    local canProvideResult = self:can_ProvideItems_QOSrv({ provideItems = provideItems, })
    if not canProvideResult or not canProvideResult.success then
        corelog.Error("MineShaft:provideItemsTo_AOSrv: the MineShaft can not provide (all) items from "..textutils.serialise(provideItems, {compact = true}))
        return Callback.ErrorCall(callback)
    end

    -- create project data
    local taskData = {
        baseLocation        = self:getBaseLocation(),
        startDepth          = self:getCurrentDepth(),
        maxDepth            = self:getMaxDepth(),

        provideItems        = ItemTable:newInstance(provideItems),
        escape              = true,

        priorityKey         = assignmentsPriorityKey,
    }
    local lobjLocator = LObjLocator:newInstance(defaultHostName, self)
    local projectData = {
        hostLocator                     = URL:newInstance(defaultHostName),
        lobjLocator                     = lobjLocator,

        wasteItemDepotLocator           = wasteItemDepotLocator:copy(),
        itemDepotLocator                = itemDepotLocator:copy(),

        mineShaftMetaData               = role_miner.MineShaft_MetaData(taskData),
        mineShaftTaskCall               = TaskCall:newInstance("role_miner", "MineShaft_Task", taskData),

        assignmentsPriorityKey          = assignmentsPriorityKey,
    }
    -- create project definition
    local projectDef = {
        steps = {
            -- mine MineShaft
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"                       , sourceStep = 0, sourceKeyDef = "mineShaftMetaData" },
                { keyDef = "taskCall"                       , sourceStep = 0, sourceKeyDef = "mineShaftTaskCall" },
            }, description = "Mining "..textutils.serialise(provideItems, {compact = true}).." from MineShaft task"},

            -- get MineShaft
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "getObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "objLocator"                     , sourceStep = 0, sourceKeyDef = "lobjLocator" },
            }},
            -- save MineShaft
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "saveObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "obj"                            , sourceStep = 2, sourceKeyDef = "obj" },
                { keyDef = "obj._currentDepth"              , sourceStep = 1, sourceKeyDef = "endDepth" },
            }},
            -- deliver mined items
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "itemDepotLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"                   , sourceStep = 1, sourceKeyDef = "turtleOutputItemsLocator" },
                { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
            -- store waste items
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "wasteItemDepotLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"                   , sourceStep = 1, sourceKeyDef = "turtleWasteItemsLocator" },
                { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
        },
        returnData  = {
            { keyDef = "destinationItemsLocator"            , sourceStep = 4, sourceKeyDef = "destinationItemsLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Mining MineShaft", description = "Mining! What this game is made for!", wipId = self:getWIPId() },
    }

    -- start project
    local scheduleResult = enterprise_projects.StartProject_ASrv(projectServiceData, callback)

    -- end
    return scheduleResult
end

function MineShaft:can_ProvideItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("MineShaft:can_ProvideItems_QOSrv: Invalid input") return {success = false} end

    enterprise_gathering = enterprise_gathering or require "enterprise_gathering"
    local minableItems = enterprise_gathering.GetMinableItems()

    -- check if there is still materials left in the MineShaft
    if self:getCurrentDepth() >= self:getMaxDepth() then
        return {success = false}
    end

    -- loop on items
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("MineShaft:can_ProvideItems_QOSrv: itemName of wrong type = "..type(itemName)..".") return {success = false} end

        -- check it's a mineable item
        local isMineableItem = false
        for _, mineItemName in ipairs(minableItems) do
            if itemName == mineItemName then
                isMineableItem = true
            end
        end
        if not isMineableItem then return {success = false} end
    end
    -- note: the MineShaft ItemSupplier implementation returns if "in principle" the items could be provided. In reality we of course only know once we start mining.

    -- end
    return {
        success = true,
    }
end

function MineShaft:needsTo_ProvideItemsTo_SOSrv(...)
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
    if not checkSuccess then corelog.Error("MineShaft:needsTo_ProvideItemsTo_SOSrv: Invalid input") return {success = false} end

    -- fuelNeed_Mining
    local fuelNeed_Mining = self:getMaxDepth() -- note: we return the maximum fuelNeed for mining this MineShaft, it could be less (and it could also be we don't find the items)

    -- get destinationItemDepot
    local destinationItemDepot = ObjHost.GetObj(destinationItemDepotLocator)
    if not destinationItemDepot or not Class.IsInstanceOf(destinationItemDepot, IItemDepot) then corelog.Error("MineShaft:needsTo_ProvideItemsTo_SOSrv: Failed obtaining an IItemDepot from destinationItemDepotLocator "..destinationItemDepotLocator:getURI()) return {success = false} end

    -- get locations
    local destinationLocation = destinationItemDepot:getItemDepotLocation()
    local localLocation = self:getBaseLocation()

    -- fuelNeed output transfer
    local fuelNeed_Transfer = role_energizer.NeededFuelToFrom(destinationLocation, localLocation)

    --
    local fuelNeedEntry = 4 -- from base to move just undersurface
    local fuelNeedExit = fuelNeed_Mining + 4 -- to go back up + moving back to base
    local fuelNeed = fuelNeedEntry + fuelNeed_Mining + fuelNeedExit + fuelNeed_Transfer
    local ingredientsNeed = {}

    -- end
    return {
        success         = true,
        fuelNeed        = fuelNeed,
        ingredientsNeed = ingredientsNeed,
    }
end

return MineShaft
