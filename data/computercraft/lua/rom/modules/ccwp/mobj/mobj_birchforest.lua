-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ILObj = require "i_lobj"
local IMObj = require "i_mobj"
local IItemSupplier = require "i_item_supplier"
local BirchForest = Class.NewClass(ObjBase, ILObj, IMObj, IItemSupplier)

--[[
    This module implements BirchForest.
--]]

local corelog = require "corelog"
local coreutils = require "coreutils"

local InputChecker = require "input_checker"

local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"

local ObjTable = require "obj_table"
local ObjLocator = require "obj_locator"
local ObjHost = require "obj_host"
local Location = require "obj_location"
local Block = require "obj_block"
local CodeMap = require "obj_code_map"
local LayerRectangle = require "obj_layer_rectangle"

local IItemDepot = require "i_item_depot"
local LObjLocator = require "lobj_locator"

local role_forester = require "role_forester"
local role_energizer = require "role_energizer"

local enterprise_projects = require "enterprise_projects"
local enterprise_storage = require "enterprise_storage"
local enterprise_employment


--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function BirchForest:_init(...)
    -- get & check input from description
    local checkSuccess, id, level, baseLocation, nTrees, localLogsLocator, localSaplingsLocator = InputChecker.Check([[
        Initialise a BirchForest.

        Parameters:
            id                      + (string) id of the BirchForest
            level                   + (number) level of the BirchForest
            baseLocation            + (Location) base location of the BirchForest
            nTrees                  + (number) # trees in the BirchForest
            localLogsLocator        + (ObjLocator) locating the local ItemSupplier of logs (e.g. a Chest)
            localSaplingsLocator    + (ObjLocator) locating the local ItemSupplier of saplings (e.g. a Chest)
    ]], ...)
    if not checkSuccess then corelog.Error("BirchForest:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id                    = id
    self._level                 = level
    self._baseLocation          = baseLocation
    self._nTrees                = nTrees
    self._localLogsLocator      = localLogsLocator
    self._localSaplingsLocator  = localSaplingsLocator
end

-- ToDo: should be renamed to newFromTable at some point
function BirchForest:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a BirchForest.

        Parameters:
            o                           + (table, {}) with object fields
                _id                     - (string) id of the BirchForest
                _level                  - (number) level of the BirchForest
                _baseLocation           - (Location) base location of the BirchForest
                _nTrees                 - (number) # trees in the BirchForest
                _localLogsLocator       - (ObjLocator) locating the local ItemSupplier of logs (e.g. a Chest)
                _localSaplingsLocator   - (ObjLocator) locating the local ItemSupplier of saplings (e.g. a Chest)
    ]], ...)
    if not checkSuccess then corelog.Error("BirchForest:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function BirchForest:getLevel()
    return self._level
end

function BirchForest:setLevel(level)
    -- check input
    if type(level) ~= "number" then corelog.Error("BirchForest:setLevel: invalid level: "..type(level)) return end

    self._level = level
end

function BirchForest:getNTrees()
    return self._nTrees
end

function BirchForest:setNTrees(nTrees)
    -- check input
    if type(nTrees) ~= "number" then corelog.Error("BirchForest:setNTrees: invalid # trees: "..type(nTrees)) return end

    self._nTrees = nTrees
end

function BirchForest:getLocalLogsLocator()
    return self._localLogsLocator
end

function BirchForest:setLocalLogsLocator(localLocator)
    -- check input
    if not Class.IsInstanceOf(localLocator, ObjLocator) then corelog.Error("BirchForest:setLocalLogsLocator: Invalid localLocator "..type(localLocator)) return end

    self._localLogsLocator = localLocator
end

function BirchForest:getLocalSaplingsLocator()
    return self._localSaplingsLocator
end

function BirchForest:setLocalSaplingsLocator(localLocator)
    -- check input
    if not Class.IsInstanceOf(localLocator, ObjLocator) then corelog.Error("BirchForest:setLocalSaplingsLocator: Invalid localLocator "..type(localLocator)) return end

    self._localSaplingsLocator = localLocator
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function BirchForest:getClassName()
    return "BirchForest"
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function BirchForest:construct(...)
    -- get & check input from description
    local checkSuccess, level, baseLocation, nTrees = InputChecker.Check([[
        This method constructs a BirchForest instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        It also ensures all child MObj's the BirchForest spawns are hosted on the appropriate MObjHost (by calling hostLObj_SSrv).

        The constructed BirchForest is not yet saved in the LObjHost.

        Return value:
                                        - (BirchForest) the constructed BirchForest

        Parameters:
            constructParameters         - (table) parameters for constructing the BirchForest
                level                   + (number) with BirchForest level
                baseLocation            + (Location) base location of the BirchForest
                nTrees                  + (number) number of trees
    ]], ...)
    if not checkSuccess then corelog.Error("BirchForest:construct: Invalid input") return nil end

    -- nTrees
    if nTrees > 6 then corelog.Error("BirchForest:construct: "..nTrees.." trees not (yet) supported") return nil end

    -- level
    if level < -1 or level > 2 then corelog.Error("BirchForest:construct: Don't know how to construct a BirchForest of level "..level) return nil end

    -- local storage
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local localLogsLocator = nil
    local localSaplingsLocator = nil
    if level == -1 or level == 0 or level == 1 then
        -- localLogsLocator
        localLogsLocator = enterprise_employment.GetAnyTurtleLocator()

        -- localSaplingsLocator
        localSaplingsLocator = enterprise_employment.GetAnyTurtleLocator()
    elseif level == 2 then
        -- localLogsLocator
        localLogsLocator = enterprise_storage:hostLObj_SSrv({ className = "Chest", constructParameters = {
            baseLocation    = baseLocation:getRelativeLocation(2, 1, 0):getRelativeLocationRight(),
            accessDirection = "front",
        }}).mobjLocator

        -- localSaplingsLocator
        localSaplingsLocator = enterprise_storage:hostLObj_SSrv({ className = "Chest", constructParameters = {
            baseLocation    = baseLocation:getRelativeLocation(4, 1, 0):getRelativeLocationLeft(),
            accessDirection = "front",
        }}).mobjLocator
    end
    if not localLogsLocator then corelog.Error("BirchForest:construct: Failed obtaining localLogsLocator for level "..level) return nil end
    if not localSaplingsLocator then corelog.Error("BirchForest:construct: Failed obtaining localSaplingsLocator for level "..level) return nil end

    -- construct new BirchForest
    local id = coreutils.NewId()
    local obj = BirchForest:newInstance(id, level, baseLocation:copy(), nTrees, localLogsLocator:copy(), localSaplingsLocator:copy())

    -- end
    return obj
end

function BirchForest:upgrade(...)
    -- get & check input from description
    local checkSuccess, upgradedLevel, upgradedNTrees = InputChecker.Check([[
        This method upgrades a BirchForest instance from a table of parameters.

        The upgraded BirchForest is not yet saved in the LObjHost.

        Return value:
                                        - (boolean) whether the BirchForest was succesfully upgraded.

        Parameters:
            upgradeParameters           - (table) parameters for upgrading the BirchForest
                level                   + (number) with BirchForest level to upgrade to
                nTrees                  + (number) number of trees
    ]], ...)
    if not checkSuccess then corelog.Error("BirchForest:upgrade: Invalid input") return false end

    -- nTrees
    local nTrees = self:getNTrees()
    if nTrees > upgradedNTrees then corelog.Error("BirchForest:upgrade: Downgradging # trees (from "..nTrees.." to "..upgradedNTrees..") not supported") return false end
    if nTrees < upgradedNTrees then
        if upgradedNTrees > 6 then corelog.Error("BirchForest:upgrade: Upgrading to "..upgradedNTrees.." trees not (yet) supported") return false end
        self._nTrees = upgradedNTrees
    end

    -- level
    local level = self:getLevel()
    if level < -1 or level > 2 or upgradedLevel < -1 or upgradedLevel > 2 then corelog.Error("BirchForest:upgrade: Don't know how to upgrade a BirchForest from level "..level.." to "..upgradedLevel) return nil end
    self._level = upgradedLevel

    -- local storage
    local baseLocation = self:getBaseLocation()
    if level < 2 and upgradedLevel == 2 then
        -- localLogsLocator
        local localLogsLocator = enterprise_storage:hostLObj_SSrv({ className = "Chest", constructParameters = {
            baseLocation    = baseLocation:getRelativeLocation(2, 1, 0):getRelativeLocationRight(),
            accessDirection = "front",
        }}).mobjLocator
        if not localLogsLocator then corelog.Error("BirchForest:upgrade: Failed obtaining localLogsLocator for level "..upgradedLevel) return false end
        self._localLogsLocator = localLogsLocator

        -- localSaplingsLocator
        local localSaplingsLocator = enterprise_storage:hostLObj_SSrv({ className = "Chest", constructParameters = {
            baseLocation    = baseLocation:getRelativeLocation(4, 1, 0):getRelativeLocationLeft(),
            accessDirection = "front",
        }}).mobjLocator
        if not localSaplingsLocator then corelog.Error("BirchForest:upgrade: Failed obtaining localSaplingsLocator for level "..upgradedLevel) return false end
        self._localSaplingsLocator = localSaplingsLocator
    end

    -- end
    return true
end

function BirchForest:destruct()
    --[[
        This method destructs a BirchForest instance.

        It also ensures all child MObj's the BirchForest is the parent of are released from the appropriate MObjHost (by calling releaseLObj_SSrv).

        The BirchForest is not yet deleted from the LObjHost.

        Return value:
                                        - (boolean) whether the BirchForest was succesfully destructed.

        Parameters:
    ]]

    -- release localLogsLocator
    local destructSuccess = true
    local localLogsLocator = self:getLocalLogsLocator()
    local hostName = localLogsLocator:getHost()
    if hostName == enterprise_storage:getHostName() then
        local releaseResult = enterprise_storage:releaseLObj_SSrv({ mobjLocator = localLogsLocator })
        if not releaseResult or not releaseResult.success then corelog.Warning("BirchForest:destruct(): failed releasing localLogsLocator "..localLogsLocator:getURI()) destructSuccess = false end
    end

    -- release localSaplingsLocator
    local localSaplingsLocator = self:getLocalSaplingsLocator()
    hostName = localSaplingsLocator:getHost()
    if hostName == enterprise_storage:getHostName() then
        local releaseResult = enterprise_storage:releaseLObj_SSrv({ mobjLocator = localSaplingsLocator })
        if not releaseResult or not releaseResult.success then corelog.Warning("BirchForest:destruct(): failed releasing localSaplingsLocator "..localSaplingsLocator:getURI()) destructSuccess = false end
    end

    -- end
    return destructSuccess
end

function BirchForest:getId()
    return self._id
end

function BirchForest:getWIPId()
    --[[
        Returns the unique Id of the BirchForest used for administering WIP.
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

function BirchForest:getBaseLocation()
    return self._baseLocation
end

local function Inline_Tree_layerLm1()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["S"]   = Block:newInstance("minecraft:birch_sapling"),
        }),
        CodeMap:newInstance({
            [1] = "S",
        })
    )
end

local function Tree_layerLm1()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["S"]   = Block:newInstance("minecraft:birch_sapling"),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
        }),
        CodeMap:newInstance({
            [6] = "??????",
            [5] = "??????",
            [4] = "???S??",
            [3] = "??????",
            [2] = "??????",
            [1] = "??????",
        })
    )
end

local function Tree_layerL0()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["S"]   = Block:newInstance("minecraft:birch_sapling"),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [6] = "      ",
            [5] = "      ",
            [4] = "   S  ",
            [3] = "      ",
            [2] = "      ",
            [1] = "      ",
        })
    )
end

local function Tree_layerL1()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["S"]   = Block:newInstance("minecraft:birch_sapling"),
            ["T"]   = Block:newInstance("minecraft:torch"),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [6] = "      ",
            [5] = "      ",
            [4] = "T  S  ",
            [3] = "      ",
            [2] = "      ",
            [1] = "   T  ",
        })
    )
end

local function Base_layerL2()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["S"]   = Block:newInstance("minecraft:birch_sapling"),
            ["T"]   = Block:newInstance("minecraft:torch"),
            ["C"]   = Block:newInstance("minecraft:chest", -1, 0),
            ["D"]   = Block:newInstance("minecraft:chest", 1, 0),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [6] = "      ",
            [5] = "      ",
            [4] = "T  S  ",
            [3] = "     D",
            [2] = "  C D ",
            [1] = "   T  ",
        })
    )
end

local function Base_layer(level)
    if level == -1 then     return Tree_layerLm1()
    elseif level == 0 then  return Tree_layerL0()
    elseif level == 1 then  return Tree_layerL1()
    elseif level == 2 then  return Base_layerL2()
    else                    corelog.Error("Base_layer: Don't know layer for level "..level) return nil end
end

local function Tree_layer(level)
    if level == -1 then     return Tree_layerLm1()
    elseif level == 0 then  return Tree_layerL0()
    elseif level == 1 then  return Tree_layerL1()
    elseif level == 2 then  return Tree_layerL1() -- same as L1
    else                    corelog.Error("Tree_layer: Don't know layer for level "..level) return nil end
end

function BirchForest.GetBuildBlueprint(...)
    -- get & check input from description
    local checkSuccess, level, baseLocation, nTrees = InputChecker.Check([[
        This method returns a blueprint for building a BirchForest in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            constructParameters         - (table) parameters for constructing the BirchForest
                level                   + (number) with BirchForest level
                baseLocation            + (Location) base location of the BirchForest
                nTrees                  + (number) number of trees
    ]], ...)
    if not checkSuccess then corelog.Error("BirchForest.GetBuildBlueprint: Invalid input") return nil, nil end

    -- nTrees
    if nTrees > 6 then corelog.Error("BirchForest.GetBuildBlueprint: "..nTrees.." trees not (yet) supported") return nil end

    -- level
    if level < -1 or level > 2 then corelog.Error("BirchForest.GetBuildBlueprint: Don't know how to build a BirchForest of level "..level) return nil end

    -- buildLocation
    local buildLocation = baseLocation:copy()

    -- layerList
    local layerList = {}
    local buildDirection = "Down"
    local baseLayer = Base_layer(level)
    local treeLayer = Tree_layer(level)
    local yOffset = 0
    if level == -1 then
        if nTrees ~= 1 then corelog.Error("BirchForest.GetBuildBlueprint: "..nTrees.." trees not supported for level -1") return nil end

        -- specific values for -1 level
        buildDirection = "Front"
        buildLocation = buildLocation:getRelativeLocation(3, 2, 0)
        yOffset = 1
        baseLayer = Inline_Tree_layerLm1()
    end
    for iTree=1, nTrees  do
        local buildLayerLocation = Location:newInstance(0, yOffset + 6 * (iTree - 1), 0)
        if iTree == 1 then
            table.insert(layerList, { startpoint = buildLayerLocation, buildDirection = buildDirection, layer = baseLayer})
        else
            table.insert(layerList, { startpoint = buildLayerLocation, buildDirection = buildDirection, layer = treeLayer})
        end
    end

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

function BirchForest:getExtendBlueprint(...)
    -- get & check input from description
    local checkSuccess, upgradedLevel, upgradedNTrees = InputChecker.Check([[
        This method returns a blueprint for extending the BirchForest in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            upgradeParameters           - (table) parameters for upgrading the current BirchForest
                level                   + (number) with BirchForest level to upgrade to
                nTrees                  + (number) number of trees
    ]], ...)
    if not checkSuccess then corelog.Error("BirchForest:getExtendBlueprint: Invalid input") return nil end

    -- nTrees
    local nTrees = self:getNTrees()
    if nTrees > 6 then corelog.Error("BirchForest:getExtendBlueprint: "..nTrees.." trees not (yet) supported") return nil end
    if nTrees > upgradedNTrees then corelog.Error("BirchForest:getExtendBlueprint: Downgradging # trees (from "..nTrees.." to "..upgradedNTrees..") not supported") return nil end

    -- level
    local level = self:getLevel()
    if level < -1 or level > 2 or upgradedLevel < -1 or upgradedLevel > 2 then corelog.Error("BirchForest:getExtendBlueprint: Don't know how to extend a BirchForest from level "..level.." to "..upgradedLevel) return nil end

    -- upgraded layer data
    local upgradedTreeLayer = Tree_layer(upgradedLevel)
    if not upgradedTreeLayer then corelog.Error("BirchForest:getExtendBlueprint: Failed obtaining treeLayer for level "..upgradedLevel) return nil end
    local upgradedBaseLayer = Base_layer(upgradedLevel)
    if not upgradedBaseLayer then corelog.Error("BirchForest:getExtendBlueprint: Failed obtaining baseLayer for level "..upgradedLevel) return nil end

    -- existing trees
    local buildLayersData = {}
    local minBuildLocation = Location.FarLocation()
    if level < 2 and upgradedLevel ~= level then
        -- current layer data
        local baseLayer = Base_layer(level)
        if not baseLayer then corelog.Error("BirchForest:getExtendBlueprint: Failed obtaining baseLayer for level "..level) return nil end
        local treeLayer = Tree_layer(level)
        if not treeLayer then corelog.Error("BirchForest:getExtendBlueprint: Failed obtaining treeLayer for level "..level) return nil end

        -- extend data
        local transformLayer = treeLayer:transformToLayer(upgradedTreeLayer)
        if not transformLayer then corelog.Error("BirchForest:getExtendBlueprint: No tree transformLayer") return nil end
        local treeColOffset, treeRowOffset, treeBuildLayer = transformLayer:buildData()
        transformLayer = baseLayer:transformToLayer(upgradedBaseLayer)
        if not transformLayer then corelog.Error("BirchForest:getExtendBlueprint: No base transformLayer") return nil end
        local baseColOffset, baseRowOffset, baseBuildLayer = transformLayer:buildData()

        -- layers for existing trees
        for iTree=1, nTrees do
            -- determine layer extend data
            local buildLayer = treeBuildLayer
            local colOffset = treeColOffset
            local rowOffset = treeRowOffset
            if iTree == 1 then
                buildLayer = baseBuildLayer
                colOffset = baseColOffset
                rowOffset = baseRowOffset
            end

            -- check layer needs to be extended
            if buildLayer:getNRows() > 0 then
                -- add layer
                local buildLayerLocation = Location:newInstance(colOffset + 0, rowOffset + 6 * (iTree - 1), 0)
                minBuildLocation = minBuildLocation:minLocation(buildLayerLocation)
                table.insert(buildLayersData, { location = buildLayerLocation, layer = buildLayer:copy()})
            end
        end
    end

    -- new trees
    if nTrees < upgradedNTrees then
        for iTree = nTrees + 1, upgradedNTrees do
            -- determine layer build data
            local buildLayer = upgradedTreeLayer
            if iTree == 1 then
                buildLayer = upgradedBaseLayer
            end

            -- add layer
            local buildLayerLocation = Location:newInstance(0, 6 * (iTree - 1), 0)
            minBuildLocation = minBuildLocation:minLocation(buildLayerLocation)
            table.insert(buildLayersData, { location = buildLayerLocation, layer = buildLayer:copy()})
        end
    end

    -- layerList
    local layerList = {}
    local xOffset = minBuildLocation:getX()
    local yOffset = minBuildLocation:getY()
    local zOffset = minBuildLocation:getZ()
    for i, buildLayerData in ipairs(buildLayersData) do
        local buildLayerLocation = buildLayerData.location:getRelativeLocation(-xOffset, -yOffset, -zOffset)

        -- add layer
        table.insert(layerList, { startpoint = buildLayerLocation, buildDirection = "Down", layer = buildLayerData.layer})
    end

    -- escapeSequence
    local escapeSequence = {}

    -- blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence,
    }

    -- buildLocation
    local baseLocation = self:getBaseLocation()
    local buildLocation = baseLocation:getRelativeLocation(xOffset, yOffset, zOffset)

    -- end
    return buildLocation, blueprint
end

local function BlockDismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [1] = " ",
        })
    )
end

function BirchForest:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the BirchForest in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- nTrees
    local nTrees = self:getNTrees()
    if nTrees > 6 then corelog.Error("BirchForest:getDismantleBlueprint: "..nTrees.." trees not (yet) supported") return nil end

    -- level
    local level = self:getLevel()
    if level < -1 or level > 2 then corelog.Error("BirchForest:getDismantleBlueprint: Don't know how to dismantle a BirchForest of level "..level) return nil end

    -- layerList
    local layerList = {}
    for iTree=1, nTrees  do
        -- torch1
        local dismantleLayerLocation = Location:newInstance(0, 6 * (iTree - 1), 0)
        if level > 0 then
            table.insert(layerList, { startpoint = dismantleLayerLocation:getRelativeLocation(3, 0, 0), buildDirection = "Down", layer = BlockDismantle_layer()})
        end

        -- chests
        if iTree == 1 and level == 2 then
            table.insert(layerList, { startpoint = dismantleLayerLocation:getRelativeLocation(2, 1, 0), buildDirection = "Down", layer = BlockDismantle_layer()})
            table.insert(layerList, { startpoint = dismantleLayerLocation:getRelativeLocation(4, 1, 0), buildDirection = "Down", layer = BlockDismantle_layer()})
            table.insert(layerList, { startpoint = dismantleLayerLocation:getRelativeLocation(5, 2, 0), buildDirection = "Down", layer = BlockDismantle_layer()})
        end

        -- tree
        for iLog=1, 7 do
            table.insert(layerList, { startpoint = dismantleLayerLocation:getRelativeLocation(3, 3, iLog - 1), buildDirection = "Down", layer = BlockDismantle_layer()})
        end

        -- torch2
        if level > 0 then
            table.insert(layerList, { startpoint = dismantleLayerLocation:getRelativeLocation(0, 3, 0), buildDirection = "Down", layer = BlockDismantle_layer()})
        end
    end

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

local defaultHostName = "enterprise_forestry"

function BirchForest:provideItemsTo_AOSrv(...)
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
    if not checkSuccess then corelog.Error("BirchForest:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- loop on items
    local scheduleResult = true
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("BirchForest:provideItemsTo_AOSrv: Invalid itemName (type="..type(itemName)..")") return Callback.ErrorCall(callback) end
        if type(itemCount) ~= "number" then corelog.Error("BirchForest:provideItemsTo_AOSrv: Invalid itemCount (type="..type(itemCount)..")") return Callback.ErrorCall(callback) end

        -- check for birchlog or sapling
        local localItemLocator = nil
        local localLogsLocator = self:getLocalLogsLocator()
        local localSaplingsLocator = self:getLocalSaplingsLocator()
        if itemName == "minecraft:birch_log" then
            localItemLocator = localLogsLocator
        elseif itemName == "minecraft:birch_sapling" then
            localItemLocator = localSaplingsLocator
        else
            corelog.Error("BirchForest:provideItemsTo_AOSrv: This is not a producer for item "..itemName) return Callback.ErrorCall(callback)
        end
        if not localItemLocator then corelog.Error("BirchForest:provideItemsTo_AOSrv: Invalid localItemLocator (type="..type(localItemLocator)..")") return Callback.ErrorCall(callback) end

        -- get localItemSupplier
        local localItemSupplier = ObjHost.GetObj(localItemLocator)
        -- ToDo: investigate this odd situation that we use the knowledge here that we know that the localItemLocator is both an ItemDepot and an ItemSupplier...
        if not localItemSupplier or not Class.IsInstanceOf(localItemSupplier, IItemSupplier) then corelog.Error("BirchForest:provideItemsTo_AOSrv: Failed obtaining an IItemSupplier from localItemLocator "..localItemLocator:getURI()) return Callback.ErrorCall(callback) end

        -- check items already available in localItemSupplier
        local item = { [itemName] = itemCount }
        if localItemSupplier:can_ProvideItems_QOSrv({ provideItems = item }).success then
            -- provide items from localItemSupplier to requested ItemDepot
            scheduleResult = scheduleResult and localItemSupplier:provideItemsTo_AOSrv({
                provideItems                    = provideItems,
                itemDepotLocator                = itemDepotLocator,
                ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
                wasteItemDepotLocator           = wasteItemDepotLocator,
                assignmentsPriorityKey          = assignmentsPriorityKey,
            }, callback)
        else
            -- get # available input (i.e. available from norm) saplings
            local normSaplings = self:getSaplingHarvestNorm_Att()
            local localSaplingsSupplier = ObjHost.GetObj(localSaplingsLocator)
            if type(localSaplingsSupplier) ~= "table" then corelog.Error("BirchForest:provideItemsTo_AOSrv: localSaplingsSupplier "..localSaplingsLocator:getURI().." not found.") return Callback.ErrorCall(callback) end
            local inputSaplings = { ["minecraft:birch_sapling"] = normSaplings }
            if not localSaplingsSupplier:can_ProvideItems_QOSrv({ provideItems = inputSaplings }).success then
                -- ToDo: consider using the number of saplings that ARE available once IItemSupplier is improved with a method that returns what IS available
                normSaplings = 0
                inputSaplings = { ["minecraft:birch_sapling"] = 0 }
            end

            -- create project data
            local harvestForestTaskData = {
                forestLevel         = self:getLevel(),
                firstTreeLocation   = self:getFirstTreeLocation(),
                nTrees              = self:getNTrees(),
                waitForFirstTree    = true,

                priorityKey         = assignmentsPriorityKey,
            }
            local lobjLocator = LObjLocator:newInstance(defaultHostName, self)
            enterprise_employment = enterprise_employment or require "enterprise_employment"
            local projectData = {
                inputSaplings                   = inputSaplings,
                anyTurtleLocator                = enterprise_employment.GetAnyTurtleLocator(),

                lobjLocator                     = lobjLocator,
                item                            = item, -- ToDo: consider lower count with possible # items already present in localItemLocator
                ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator:copy(),
                wasteItemDepotLocator           = wasteItemDepotLocator:copy(),
                itemDepotLocator                = itemDepotLocator:copy(),

                localLogsLocator                = localLogsLocator,
                localSaplingsLocator            = localSaplingsLocator,
                harvestForestMetaData           = role_forester.HarvestForest_MetaData(harvestForestTaskData),
                harvestForestTaskCall           = TaskCall:newInstance("role_forester", "HarvestForest_Task", harvestForestTaskData),

                assignmentsPriorityKey          = assignmentsPriorityKey,
            }
            -- create project definition
            local projectDef = {
                steps = {
                    -- get input saplings from localSaplingsLocator into a Turtle
                    { stepType = "LAOSrv", stepTypeDef = { serviceName = "provideItemsTo_AOSrv", locatorStep = 0, locatorKeyDef = "localSaplingsLocator" }, stepDataDef = {
                        { keyDef = "provideItems"                   , sourceStep = 0, sourceKeyDef = "inputSaplings" },
                        { keyDef = "itemDepotLocator"               , sourceStep = 0, sourceKeyDef = "anyTurtleLocator" },
                        { keyDef = "ingredientsItemSupplierLocator" , sourceStep = 0, sourceKeyDef = "ingredientsItemSupplierLocator" },
                        { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
                        { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
                    }, description = "Gathering "..normSaplings.." input sapling(s)"},
                    -- obtain workerId (of Turtle)
                    { stepType = "LSOMtd", stepTypeDef = { methodName = "getWorkerId", locatorStep = 1, locatorKeyDef = "destinationItemsLocator" }, stepDataDef = {
                    }},
                    -- harvest BirchForest
                    { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                        { keyDef = "metaData"                       , sourceStep = 0, sourceKeyDef = "harvestForestMetaData" },
                        { keyDef = "metaData.needWorkerId"          , sourceStep = 2, sourceKeyDef = "methodResults" },
                        { keyDef = "taskCall"                       , sourceStep = 0, sourceKeyDef = "harvestForestTaskCall" },
                    }, description = "Harvesting "..textutils.serialise(item, {compact = true}).." task"},
                    -- store harvested logs to localLogsLocator
                    { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "localLogsLocator" }, stepDataDef = {
                        { keyDef = "itemsLocator"           , sourceStep = 3, sourceKeyDef = "turtleOutputLogsLocator" },
                        { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
                    }},
                    -- store harvested saplings to localSaplingsLocator
                    { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "localSaplingsLocator" }, stepDataDef = {
                        { keyDef = "itemsLocator"           , sourceStep = 3, sourceKeyDef = "turtleOutputSaplingsLocator" },
                        { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
                    }},
                    -- store input saplings to localSaplingsLocator
                    { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "localSaplingsLocator" }, stepDataDef = {
                        { keyDef = "itemsLocator"           , sourceStep = 1, sourceKeyDef = "destinationItemsLocator" },
                        { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
                    }},
                    -- store gathered waste (e.g. sticks) to wasteItemDepotLocator
                    { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "wasteItemDepotLocator" }, stepDataDef = {
                        { keyDef = "itemsLocator"           , sourceStep = 3, sourceKeyDef = "turtleWasteItemsLocator" },
                        { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
                    }},
                    -- recursive call to provide (remaining) items
                    { stepType = "LAOSrv", stepTypeDef = { serviceName = "provideItemsTo_AOSrv", locatorStep = 0, locatorKeyDef = "lobjLocator" }, stepDataDef = {
                        { keyDef = "provideItems"                   , sourceStep = 0, sourceKeyDef = "item" },
                        { keyDef = "itemDepotLocator"               , sourceStep = 0, sourceKeyDef = "itemDepotLocator" },
                        { keyDef = "ingredientsItemSupplierLocator" , sourceStep = 0, sourceKeyDef = "ingredientsItemSupplierLocator" },
                        { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
                        { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
                    }, description = "Providing "..textutils.serialise(item, {compact = true}).." recursively"},
                },
                returnData  = {
                    { keyDef = "destinationItemsLocator"            , sourceStep = 8, sourceKeyDef = "destinationItemsLocator" },
                }
            }
            local projectServiceData = {
                projectDef  = projectDef,
                projectData = projectData,
                projectMeta = { title = "Harvesting BirchForest. The most usefull task in the world.", description = "We provide "..itemCount.." "..itemName.."'s", wipId = self:getWIPId() },
            }

            -- start project
--            corelog.WriteToLog(">Harvesting "..itemCount.." "..itemName.."'s from Forest")
            scheduleResult = scheduleResult and enterprise_projects.StartProject_ASrv(projectServiceData, callback)
        end
    end

    -- end
    return scheduleResult
end

function BirchForest:can_ProvideItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("BirchForest:can_ProvideItems_QOSrv: Invalid input") return {success = false} end

    -- loop on items
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("BirchForest:can_ProvideItems_QOSrv: itemName of wrong type = "..type(itemName)..".") return {success = false} end

        -- check for birchlog or sapling
        if itemName == "minecraft:birch_log" then
        elseif itemName == "minecraft:birch_sapling" then
        else
            return {success = false}
        end
    end

    -- end
    return {
        success = true,
    }
end

function BirchForest:needsTo_ProvideItemsTo_SOSrv(...)
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
    if not checkSuccess then corelog.Error("BirchForest:needsTo_ProvideItemsTo_SOSrv: Invalid input") return {success = false} end

    -- get destinationItemDepot
    local destinationItemDepot = ObjHost.GetObj(destinationItemDepotLocator)
    if not destinationItemDepot or not Class.IsInstanceOf(destinationItemDepot, IItemDepot) then corelog.Error("Chest:needsTo_ProvideItemsTo_SOSrv: Failed obtaining an IItemDepot from destinationItemDepotLocator "..destinationItemDepotLocator:getURI()) return {success = false} end

    -- get location
    local destinationLocation = destinationItemDepot:getItemDepotLocation()

    -- loop on items
    local fuelNeed = 0
    local ingredientsNeed = {} -- ToDo ? should we add saplings for a harvest round here?
    local nTrees = self:getNTrees()
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("BirchForest:needsTo_ProvideItemsTo_SOSrv: Invalid itemName (type="..type(itemName)..")") return {success = false} end
        if type(itemCount) ~= "number" then corelog.Error("BirchForest:needsTo_ProvideItemsTo_SOSrv: Invalid itemCount (type="..type(itemCount)..")") return {success = false} end

        -- check for birchlog or sapling
        local itemPerRound = 1
        local localLogsLocator = self:getLocalLogsLocator()
        local localSaplingsLocator = self:getLocalSaplingsLocator()
        local localItemLocator = nil
        if itemName == "minecraft:birch_log" then
            itemPerRound = 5 * nTrees -- using minimum birch_log per tree (based on data in birchgrow.xlsx)
            localItemLocator = localLogsLocator
        elseif itemName == "minecraft:birch_sapling" then
            itemPerRound = 1.4 * nTrees -- using average birch_sapling per tree (based on data in birchgrow.xlsx)
            -- ToDo: consider some safety margin for small forests as average ~= minimum (minimum = -1 in 9% of the cases)
            localItemLocator = localSaplingsLocator
        else
            corelog.Error("BirchForest:needsTo_ProvideItemsTo_SOSrv: Provider does not provide "..itemName.."'s") return {success = false}
        end
        if not localItemLocator then corelog.Error("BirchForest:needsTo_ProvideItemsTo_SOSrv: Invalid localItemLocator (type="..type(localItemLocator)..")") return {success = false} end

        -- fuelNeed per round
        local storeFuelPerRound = 1 + 1 -- first tree to front localLogsLocator/ localSaplingsLocator + back to first tree (note: hardcoded distances + ignored that <L2 will use turtle inventory)
        local harvestFuelPerRound = role_forester.FuelNeededPerRound(nTrees)
        local fuelPerRound = harvestFuelPerRound + storeFuelPerRound
        local nRounds = math.ceil(itemCount / itemPerRound)
        local fuelNeed_Rounds = nRounds * fuelPerRound

        -- get localItemDepot
        local localItemDepot = ObjHost.GetObj(localItemLocator)
        if not localItemDepot or not Class.IsInstanceOf(localItemDepot, IItemDepot) then corelog.Error("BirchForest:needsTo_ProvideItemsTo_SOSrv: Failed obtaining an IItemDepot from localItemLocator "..localItemLocator:getURI()) return {success = false} end

        -- get location
        local localLocation = localItemDepot:getItemDepotLocation()

        -- fuelNeed transfer
        local fuelNeed_Transfer = role_energizer.NeededFuelToFrom(destinationLocation, localLocation)

        -- ToDo: add fuelNeed for waste handling

        -- add fuelNeed
--        corelog.WriteToLog("C  fuelNeed_Rounds="..fuelNeed_Rounds.." (nRounds="..nRounds..", fuelPerRound="..fuelPerRound.."), fuelNeed_Transfer="..fuelNeed_Transfer)
        fuelNeed = fuelNeed + fuelNeed_Rounds + fuelNeed_Transfer
    end

    -- end
    return {
        success         = true,
        fuelNeed        = fuelNeed,
        ingredientsNeed = ingredientsNeed,
    }
end

--    ____  _          _     ______                  _
--   |  _ \(_)        | |   |  ____|                | |
--   | |_) |_ _ __ ___| |__ | |__ ___  _ __ ___  ___| |_
--   |  _ <| | '__/ __| '_ \|  __/ _ \| '__/ _ \/ __| __|
--   | |_) | | | | (__| | | | | | (_) | | |  __/\__ \ |_
--   |____/|_|_|  \___|_| |_|_|  \___/|_|  \___||___/\__|

function BirchForest:getFuelNeed_Harvest_Att()
    --[[
        Forest attribute with the current fuelNeed to do one harvesting round.
    --]]

    -- determine fuelNeed
    local nTrees = self:getNTrees()
    local fuelNeed = role_forester.FuelNeededPerRound(nTrees)

    -- end
    return fuelNeed
end

function BirchForest:getFuelNeedExtraTree_Att()
    --[[
        Forest attribute with the fuelNeed for harvesting one extra tree.
        (i.e. it return the difference between the current getFuelNeed_Harvest_Att and the getFuelNeed_Harvest_Att if there would be 1 extra tree)
    --]]

    -- determine fuelNeed
    local nTrees = self:getNTrees()
    local fuelNeed_Current = role_forester.FuelNeededPerRound(nTrees)
    local fuelNeed_OneTreeExtra = role_forester.FuelNeededPerRound(nTrees + 1)

    -- end
    return fuelNeed_OneTreeExtra - fuelNeed_Current
end

function BirchForest:getSaplingHarvestNorm_Att()
    --[[
        Attribute with the norm for the number of saplings to start a harvesting round with.
    --]]

    -- determine norm saplings
    local nNormSaplings = 0
    if self:getLevel() >= 1 then
        nNormSaplings = 1
    end

    -- end
    return nNormSaplings
end

function BirchForest:getFirstTreeLocation()
    return self:getBaseLocation():getRelativeLocation(3, 2, 0)
end

return BirchForest
