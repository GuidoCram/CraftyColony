-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ILObj = require "i_lobj"
local IMObj = require "i_mobj"
local IItemSupplier = require "i_item_supplier"
local Factory = Class.NewClass(ObjBase, ILObj, IMObj, IItemSupplier)

--[[
    The Factory mobj represents a factory in the minecraft world and provides (production) services to operate on that Factory.

    There are (currently) two production techniques for producing items.
        The crafting technique uses a crafting table to produce an output item from a set of input items (ingredients).
        The smelting technique uses a furnace to produce an output item from an input item (ingredient).

    A Factory is comprised out of one or more crafting and/ or smelting spots. Furthermore a Factory specifies one or more item input and
    one or more item output "spots". These input/ output spots locally locate the input and output of items by the site.
    The most simple version of these input/ output "spots" are the inventory of a turtle. They however could in principle
    also be a full fledged local ItemDepot site.

    There are currently 3 levels of a Factory with a different composition
        - Level 0:
            - one crafting spot. Below the crafting spot is a hole in the ground as a temporary ItemDepot for items not needed
            - no smelting spot
        - Level 1:
            - one crafting spot. Below the crafting spot is a hole in the ground as a temporary ItemDepot for items not needed.
            - one smelting spot. In front of the smelting spot is a furnace that can be accessed from the front, the top and below.
        - Level 2:
            - an ingredient input Chest
            - an product output Chest
            - one crafting spot. Below the crafting spot is a Chest as a temporary ItemDepot for items not needed.
            - one smelting spot. In front of the smelting spot is a furnace that can be accessed from the front, the top and below.
--]]

local corelog = require "corelog"
local coreutils = require "coreutils"

local ObjArray = require "obj_array"
local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local ObjTable = require "obj_table"
local Location = require "obj_location"
local ObjLocator = require "obj_locator"
local Block = require "obj_block"
local CodeMap = require "obj_code_map"
local LayerRectangle = require "obj_layer_rectangle"
local ObjHost = require "obj_host"
local ItemTable = require "obj_item_table"

local LObjLocator = require "lobj_locator"
local IItemDepot = require "i_item_depot"

local CraftingSpot = require "crafting_spot"
local SmeltingSpot = require "smelting_spot"

local role_energizer = require "role_energizer"

local enterprise_projects = require "enterprise_projects"
local enterprise_isp = require "enterprise_isp"
local enterprise_employment = require "enterprise_employment"
local enterprise_storage = require "enterprise_storage"
local enterprise_energy = require "enterprise_energy"
local enterprise_manufacturing

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function Factory:_init(...)
    -- get & check input from description
    local checkSuccess, id, level, baseLocation, inputLocators, outputLocators, craftingSpotLocators, smeltingSpotLocators = InputChecker.Check([[
        Initialise a Factory.

        Parameters:
            id                      + (string) id of the Factory
            level                   + (number) with Factory level
            baseLocation            + (Location) base location of the Factory
            inputLocators           + (ObjArray) with input locators
            outputLocators          + (ObjArray) with output locators
            craftingSpotLocators    + (ObjArray) with crafting spot locators
            smeltingSpotLocators    + (ObjArray) with smelting spot locators
    ]], ...)
    if not checkSuccess then corelog.Error("Factory:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id                    = id
    self._level                 = level
    self._baseLocation          = baseLocation
    self._inputLocators         = inputLocators
    self._outputLocators        = outputLocators
    self._craftingSpotLocators  = craftingSpotLocators
    self._smeltingSpotLocators  = smeltingSpotLocators
end

-- ToDo: should be renamed to newFromTable at some point
function Factory:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a Factory.

        Parameters:
            o                           + (table, {}) with object fields
                _id                     - (string) id of the Factory
                _level                  - (number) with Factory level
                _baseLocation           - (Location) location of the Factory
                _inputLocators          - (ObjArray) with input locators
                _outputLocators         - (ObjArray) with output locators
                _craftingSpots          - (ObjArray, nil) with crafting spots
                _smeltingSpots          - (ObjArray, nil) with smelting spots
                _craftingSpotLocators   - (ObjArray, nil) with crafting spot locators
                _smeltingSpotLocators   - (ObjArray, nil) with smelting spot locators
    ]], ...)
    if not checkSuccess then corelog.Error("Factory:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function Factory:getLevel()
    return self._level
end

function Factory:getInputLocators()
    return self._inputLocators
end

function Factory:getOutputLocators()
    return self._outputLocators
end

function Factory:getCraftingSpotLocators()
    return self._craftingSpotLocators
end

function Factory:getSmeltingSpotLocators()
    return self._smeltingSpotLocators
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function Factory:getClassName()
    return "Factory"
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function Factory:construct(...)
    -- get & check input from description
    local checkSuccess, level, baseLocation = InputChecker.Check([[
        This method constructs a Factory instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        It also ensures all child MObj's the Factory spawns are hosted on the appropriate MObjHost (by calling hostLObj_SSrv).

        The constructed Factory is not yet saved in the LObjHost.

        Return value:
                                        - (Factory) the constructed Factory

        Parameters:
            constructParameters         - (table) parameters for constructing the Factory
                level                   + (number) with Factory level
                baseLocation            + (Location) base location of the Factory
    ]], ...)
    if not checkSuccess then corelog.Error("Factory:construct: Invalid input") return nil end

    -- determine Factory fields
    local id = coreutils.NewId()
    local inputLocators = ObjArray:newInstance(ObjLocator:getClassName())
    local outputLocators = ObjArray:newInstance(ObjLocator:getClassName())
    local craftingSpotLocators = ObjArray:newInstance(ObjLocator:getClassName())
    local smeltingSpotLocators = ObjArray:newInstance(ObjLocator:getClassName())

    -- make sure module is loaded
    enterprise_manufacturing = enterprise_manufacturing or require "enterprise_manufacturing"

    -- check the level
    if level == 0 then
        -- inputLocators
        table.insert(inputLocators, enterprise_employment.GetAnyTurtleLocator())

        -- outputLocators
        table.insert(outputLocators, enterprise_employment.GetAnyTurtleLocator())

        -- craftingSpots
        table.insert(craftingSpotLocators, enterprise_manufacturing:hostLObj_SSrv({className=CraftingSpot:getClassName(), constructParameters={baseLocation=baseLocation:getRelativeLocation(0, 0, 0)}}).mobjLocator)

        -- smeltingSpots
        -- note: none
    elseif level == 1 then
        -- inputLocators
        table.insert(inputLocators, enterprise_employment.GetAnyTurtleLocator())

        -- outputLocators
        table.insert(outputLocators, enterprise_employment.GetAnyTurtleLocator())

        -- craftingSpots
        table.insert(craftingSpotLocators, enterprise_manufacturing:hostLObj_SSrv({className=CraftingSpot:getClassName(), constructParameters={baseLocation=baseLocation:getRelativeLocation(3, 3, -4)}}).mobjLocator)

        -- smeltingSpots
        table.insert(smeltingSpotLocators, enterprise_manufacturing:hostLObj_SSrv({className=SmeltingSpot:getClassName(), constructParameters={baseLocation=baseLocation:getRelativeLocation(3, 3, -3)}}).mobjLocator)
    elseif level == 2 then
        -- inputLocators
        local inputChestLocator = enterprise_storage:hostLObj_SSrv({ className = "Chest", constructParameters = {
            baseLocation    = baseLocation:getRelativeLocation(2, 5, 0),
            accessDirection = "top",
        }}).mobjLocator
        table.insert(inputLocators, inputChestLocator)

        -- outputLocators
        local outputChestLocator = enterprise_storage:hostLObj_SSrv({ className = "Chest", constructParameters = {
            baseLocation    = baseLocation:getRelativeLocation(4, 5, 0),
            accessDirection = "top",
        }}).mobjLocator
        table.insert(outputLocators, outputChestLocator)

        -- craftingSpots
        table.insert(craftingSpotLocators, enterprise_manufacturing:hostLObj_SSrv({className=CraftingSpot:getClassName(), constructParameters={baseLocation=baseLocation:getRelativeLocation(3, 3, -4)}}).mobjLocator)

        -- smeltingSpots
        table.insert(smeltingSpotLocators, enterprise_manufacturing:hostLObj_SSrv({className=SmeltingSpot:getClassName(), constructParameters={baseLocation=baseLocation:getRelativeLocation(3, 3, -3)}}).mobjLocator)
    else
        corelog.Error("Factory:construct: Don't know how to construct a Factory of level "..level) return nil
    end

    -- construct new Factory
    local obj = Factory:newInstance(id, level, baseLocation:copy(), inputLocators:copy(), outputLocators:copy(), craftingSpotLocators:copy(), smeltingSpotLocators:copy())

    -- end
    return obj
end

function Factory:upgrade(...)
    -- get & check input from description
    local checkSuccess, upgradeLevel = InputChecker.Check([[
        This method upgrades a Factory instance from a table of parameters.

        The upgraded Factory is not yet saved in it's MObjHost.

        Return value:
                                        - (boolean) whether the Factory was succesfully upgraded.

        Parameters:
            upgradeParameters           - (table) parameters for upgrading the Factory
                level                   + (number) with Factory level to upgrade to
    ]], ...)
    if not checkSuccess then corelog.Error("Factory:upgrade: Invalid input") return false end

    -- upgrade if possible
    local level = self:getLevel()
    local baseLocation = self:getBaseLocation()
    local inputLocators = self:getInputLocators()
    local outputLocators = self:getOutputLocators()
    if level == 1 and upgradeLevel == 2 then
        -- inputLocators
        table.remove(inputLocators, 1) -- remove previous level
        local inputChestLocator = enterprise_storage:hostLObj_SSrv({ className = "Chest", constructParameters = {
            baseLocation    = baseLocation:getRelativeLocation(2, 5, 0),
            accessDirection = "top",
        }}).mobjLocator
        table.insert(inputLocators, inputChestLocator)

        -- outputLocators
        table.remove(outputLocators, 1) -- remove previous level
        local outputChestLocator = enterprise_storage:hostLObj_SSrv({ className = "Chest", constructParameters = {
            baseLocation    = baseLocation:getRelativeLocation(4, 5, 0),
            accessDirection = "top",
        }}).mobjLocator
        table.insert(outputLocators, outputChestLocator)

        -- craftingSpots

        -- smeltingSpots
    else
        corelog.Error("Factory:construct: Don't know how to upgrade a Factory from level "..level.." to "..upgradeLevel) return false
    end

    -- level
    self._level = upgradeLevel

    -- end
    return true
end

function Factory:destruct()
    --[[
        This method destructs a Factory instance.

        It also ensures all child MObj's the Factory is the parent of are released from the appropriate MObjHost (by calling releaseLObj_SSrv).

        The Factory is not yet deleted from the LObjHost.

        Return value:
                                        - (boolean) whether the Factory was succesfully destructed.

        Parameters:
    ]]

    -- release inputLocators
    local destructSuccess = true
    for i, inputLocator in ipairs(self._inputLocators) do
        local hostName = inputLocator:getHost()
        if hostName == enterprise_storage:getHostName() then
            local releaseResult = enterprise_storage:releaseLObj_SSrv({ mobjLocator = inputLocator })
            if not releaseResult or not releaseResult.success then corelog.Warning("Factory:destruct(): failed releasing inputLocator "..inputLocator:getURI()) destructSuccess = false end
        end
        self._inputLocators[i] = nil
    end

    -- release outputLocators
    for i, outputLocator in ipairs(self._outputLocators) do
        local hostName = outputLocator:getHost()
        if hostName == enterprise_storage:getHostName() then
            local releaseResult = enterprise_storage:releaseLObj_SSrv({ mobjLocator = outputLocator })
            if not releaseResult or not releaseResult.success then corelog.Warning("Factory:destruct(): failed releasing outputLocator "..outputLocator:getURI()) destructSuccess = false end
        end
        self._outputLocators[i] = nil
    end

    -- release craftingSpots
    for i, craftingSpotLocator in ipairs(self._craftingSpotLocators) do
        local releaseResult = enterprise_manufacturing:releaseLObj_SSrv({ mobjLocator = craftingSpotLocator })
        if not releaseResult or not releaseResult.success then corelog.Warning("Factory:destruct(): failed releasing craftingSpotLocator "..craftingSpotLocator:getURI()) destructSuccess = false end
        self._craftingSpotLocators[i] = nil
    end

    -- release smeltingSpots
    for i, smeltingSpotLocator in ipairs(self._smeltingSpotLocators) do
        local releaseResult = enterprise_manufacturing:releaseLObj_SSrv({ mobjLocator = smeltingSpotLocator })
        if not releaseResult or not releaseResult.success then corelog.Warning("Factory:destruct(): failed releasing smeltingSpotLocator "..smeltingSpotLocator:getURI()) destructSuccess = false end
        self._smeltingSpotLocators[i] = nil
    end

    -- end
    return destructSuccess
end

function Factory:getId()
    return self._id
end

function Factory:getWIPId()
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

function Factory:getBaseLocation()
    return self._baseLocation
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

local function AboveOrBelowFurnance_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [2] = " ",
            [1] = " ",
        })
    )
end

local function FurnanceDismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["D"]   = Block:newInstance("minecraft:dirt"),
        }),
        CodeMap:newInstance({
            [2] = "D",
            [1] = "D",
        })
    )
end

local function Furnance_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["F"]   = Block:newInstance("minecraft:furnace"),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [2] = "F",
            [1] = " ",
        })
    )
end

local function CraftingSpotChest_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["C"]   = Block:newInstance("minecraft:chest"),
        }),
        CodeMap:newInstance({
            [1] = "C",
        })
    )
end

local function TopL2_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["T"]   = Block:newInstance("minecraft:torch"),
            ["C"]   = Block:newInstance("minecraft:chest"),
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

local function TopL2Dismantle_layer()
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

function Factory.GetBuildBlueprint(...)
    -- get & check input from description
    local checkSuccess, level, baseLocation = InputChecker.Check([[
        This method returns a blueprint for building a Factory in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            constructParameters         - (table) parameters for constructing the Factory
                level                   + (number) with Factory level
                baseLocation            + (Location) base location of the Factory
    ]], ...)
    if not checkSuccess then corelog.Error("Factory.GetBuildBlueprint: Invalid input") return nil, nil end

    -- determine layerList
    local layerList = {}
    if level == 0 then
        table.insert(layerList, { startpoint = Location:newInstance(0, 0, -1), buildDirection = "Down", layer = Shaft_layer()})
    elseif level == 1 then
        table.insert(layerList, { startpoint = Location:newInstance(3, 3, -1), buildDirection = "Down", layer = Shaft_layer()})
        table.insert(layerList, { startpoint = Location:newInstance(3, 3, -2), buildDirection = "Up", layer = AboveOrBelowFurnance_layer()})
        table.insert(layerList, { startpoint = Location:newInstance(3, 3, -3), buildDirection = "Up", layer = Furnance_layer()})
        table.insert(layerList, { startpoint = Location:newInstance(3, 3, -5), buildDirection = "Down", layer = Shaft_layer()})
    elseif level == 2 then
        table.insert(layerList, { startpoint = Location:newInstance(0, 0, 0), buildDirection = "Down", layer = TopL2_layer()})
        table.insert(layerList, { startpoint = Location:newInstance(3, 3, -1), buildDirection = "Down", layer = Shaft_layer()})
        table.insert(layerList, { startpoint = Location:newInstance(3, 3, -2), buildDirection = "Up", layer = AboveOrBelowFurnance_layer()})
        table.insert(layerList, { startpoint = Location:newInstance(3, 3, -3), buildDirection = "Up", layer = Furnance_layer()})
        table.insert(layerList, { startpoint = Location:newInstance(3, 3, -5), buildDirection = "Down", layer = CraftingSpotChest_layer()})
    else
        corelog.Warning("Factory.GetBuildBlueprint: Don't know how to make a build blueprint for a Factory of level "..level)
    end

    -- determine escapeSequence
    local escapeSequence = {}
    if level == 1 or level == 2 then
        table.insert(escapeSequence, Location:newInstance(3, 3, 1))
    end

    -- determine blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence,
    }

    -- determine buildLocation
    local buildLocation = baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

function Factory:getExtendBlueprint(...)
    -- get & check input from description
    local checkSuccess, upgradeLevel = InputChecker.Check([[
        This method returns a blueprint for extending the Factory in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            upgradeParameters           - (table) parameters for upgrading the current Factory
                level                   + (number) with Factory level to upgrade to
    ]], ...)
    if not checkSuccess then corelog.Error("Factory:getExtendBlueprint: Invalid input") return nil end

    -- determine layerList
    local layerList = {}
    local level = self:getLevel()
    if level == 1 and upgradeLevel == 2 then
        table.insert(layerList, { startpoint = Location:newInstance(0, 0, 0), buildDirection = "Down", layer = TopL2_layer()})
        table.insert(layerList, { startpoint = Location:newInstance(3, 3, -5), buildDirection = "Down", layer = CraftingSpotChest_layer()})
    else
        corelog.Warning("Factory:getExtendBlueprint: Don't know how to make a extend blueprint for a Factory from level "..level.." to "..upgradeLevel)
    end

    -- determine escapeSequence
    local escapeSequence = {}

    -- determine blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence,
    }

    -- determine buildLocation
    local buildLocation = self._baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

function Factory:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the Factory in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- determine layerList
    local layerList = {}
    if self._level == 0 then
        table.insert(layerList, { startpoint = Location:newInstance(0, 0, -1), buildDirection = "Down", layer = ShaftDismantle_layer()})
    elseif self._level == 1 or self._level == 2 then
        table.insert(layerList, { startpoint = Location:newInstance(3, 3, -5), buildDirection = "Down", layer = ShaftDismantle_layer()})
        table.insert(layerList, { startpoint = Location:newInstance(3, 3, -4), buildDirection = "Down", layer = FurnanceDismantle_layer()})
        table.insert(layerList, { startpoint = Location:newInstance(3, 3, -3), buildDirection = "Down", layer = FurnanceDismantle_layer()})
        table.insert(layerList, { startpoint = Location:newInstance(3, 3, -2), buildDirection = "Down", layer = FurnanceDismantle_layer()})
        table.insert(layerList, { startpoint = Location:newInstance(3, 3, -1), buildDirection = "Down", layer = FurnanceDismantle_layer()})
        if self._level == 2 then
            table.insert(layerList, { startpoint = Location:newInstance(0, 0, 0), buildDirection = "Down", layer = TopL2Dismantle_layer()})
        end
    else
        corelog.Warning("Factory:getDismantleBlueprint: Don't know how to make a dismantle blueprint for a Factory of level "..self._level)
    end

    -- determine escapeSequence
    local escapeSequence = {}

    -- determine blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence
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

local defaultHostName = "enterprise_manufacturing"

function Factory:provideItemsTo_AOSrv(...)
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
    if not checkSuccess then corelog.Error("Factory:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- loop on items
    local scheduleResult = true
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("Factory:provideItemsTo_AOSrv: Invalid itemName (type="..type(itemName)..")") return Callback.ErrorCall(callback) end
        if type(itemCount) ~= "number" then corelog.Error("Factory:provideItemsTo_AOSrv: Invalid itemCount (type="..type(itemCount)..")") return Callback.ErrorCall(callback) end

        -- select recipe to produce item
        enterprise_manufacturing = enterprise_manufacturing or require "enterprise_manufacturing"
        local recipe = enterprise_manufacturing.GetRecipes()[ itemName ]
        if type(recipe) ~= "table" then corelog.Error("Factory:provideItemsTo_AOSrv: No recipe for item "..itemName) return Callback.ErrorCall(callback) end

        -- determine ingredientsNeeded
        local productionSpot, productionRecipe = self:getAvailableProductionSpot(recipe)
        if not productionSpot then corelog.Error("Factory:provideItemsTo_AOSrv: Failed obtaining available ProductionSpot to produce "..itemName) return Callback.ErrorCall(callback) end
        local ingredientsNeeded, productSurplus = productionSpot:produceIngredientsNeeded(productionRecipe, itemCount)

        -- retrieve locator's
        local localInputLocator = self:getAvailableInputLocator():copy()
        local localOutputLocator = self:getAvailableOutputLocator():copy()
        local productionSpotLocator = LObjLocator:newInstance(defaultHostName, productionSpot)

        -- mark productionSpot as unavailable
        -- ToDo: implement (not yet needed in current settle scenario where there is only one turtle)
        -- ToDo: consider to what extend this is also needed for localInputLocator and localOutputLocator

        -- create project service data
        local projectDef = {
            steps = {
                -- get ingredients
                { stepType = "LAOSrv", stepTypeDef = { serviceName = "provideItemsTo_AOSrv", locatorStep = 0, locatorKeyDef = "ingredientsItemSupplierLocator" }, stepDataDef = {
                    { keyDef = "provideItems"                   , sourceStep = 0, sourceKeyDef = "ingredientsNeeded" },
                    { keyDef = "itemDepotLocator"               , sourceStep = 0, sourceKeyDef = "localInputLocator" },
                    { keyDef = "ingredientsItemSupplierLocator" , sourceStep = 0, sourceKeyDef = "ingredientsItemSupplierLocator" },
                    { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
                    { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
                }},
                -- produce items
                { stepType = "LAOSrv", stepTypeDef = { serviceName = "provideItemsTo_AOSrv", locatorStep = 0, locatorKeyDef = "productionSpotLocator" }, stepDataDef = {
                    { keyDef = "provideItems"                   , sourceStep = 0, sourceKeyDef = "provideItems" },
                    { keyDef = "itemDepotLocator"               , sourceStep = 0, sourceKeyDef = "localOutputLocator" },
                    { keyDef = "ingredientsItemSupplierLocator" , sourceStep = 1, sourceKeyDef = "destinationItemsLocator" },
                    { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
                    { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
                }},
                -- deliver items
                { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "itemDepotLocator" }, stepDataDef = {
                    { keyDef = "itemsLocator"                   , sourceStep = 2, sourceKeyDef = "destinationItemsLocator" },
                    { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
                }},
            },
            returnData  = {
                { keyDef = "destinationItemsLocator"            , sourceStep = 3, sourceKeyDef = "destinationItemsLocator" },
            }
        }
        local projectData = {
            ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator:copy(),

            ingredientsNeeded               = ingredientsNeeded,
            itemDepotLocator                = itemDepotLocator,

            localInputLocator               = localInputLocator,
            localOutputLocator              = localOutputLocator,

            productionSpotLocator           = productionSpotLocator,

            provideItems                    = ItemTable:newInstance({ [itemName] = itemCount, }),

            wasteItemDepotLocator           = wasteItemDepotLocator,

            assignmentsPriorityKey          = assignmentsPriorityKey,
        }
        local projectServiceData = {
            projectDef  = projectDef,
            projectData = projectData,
            projectMeta = { title = "Factory:provideItemsTo", description = "We provide "..itemCount.." "..itemName.."'s", wipId = self:getWIPId() },
        }

        -- start project
--        corelog.WriteToLog(">Producing "..itemCount.." "..itemName.."'s in Factory")
        scheduleResult = scheduleResult and enterprise_projects.StartProject_ASrv(projectServiceData, callback)
    end

    -- end
    return scheduleResult
end

function Factory:can_ProvideItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("Factory:can_ProvideItems_QOSrv: Invalid input") return {success = false} end

    -- loop on items
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("Factory:can_ProvideItems_QSrv: itemName of wrong type = "..type(itemName)..".") return {success = false} end

        -- check available inputLocator
        local inputLocator = self:getAvailableInputLocator()
        if not inputLocator then return {success = false} end

        -- check for recipe to produce itemName
        enterprise_manufacturing = enterprise_manufacturing or require "enterprise_manufacturing"
        local recipe = enterprise_manufacturing.GetRecipes()[ itemName ]
        if type(recipe) ~= "table" then return {success = false} end

        -- check it can produce recipe
        local productionSpot, productionRecipe = self:getAvailableProductionSpot(recipe)
        if not productionSpot then return {success = false} end

        -- ToDo: consider how to handle production of more items than fitting a single spot

        -- check available inputLocator
        local outputLocator = self:getAvailableOutputLocator()
        if not outputLocator then return {success = false} end
    end

    -- end
    return {
        success = true,
    }
end

function Factory:needsTo_ProvideItemsTo_SOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems, destinationItemDepotLocator, ingredientsItemSupplierLocator = InputChecker.Check([[
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
                ingredientsItemSupplierLocator  + (ObjLocator, nil) locating where ingredients can be retrieved
    --]], ...)
    if not checkSuccess then corelog.Error("Factory:needsTo_ProvideItemsTo_SOSrv: Invalid input") return {success = false} end

    -- get destinationItemDepot
    local destinationItemDepot = ObjHost.GetObj(destinationItemDepotLocator)
    if not destinationItemDepot or not Class.IsInstanceOf(destinationItemDepot, IItemDepot) then corelog.Error("Factory:needsTo_ProvideItemsTo_SOSrv: Failed obtaining an IItemDepot from destinationItemDepotLocator "..destinationItemDepotLocator:getURI()) return {success = false} end

    -- get location
    local destinationLocation = destinationItemDepot:getItemDepotLocation()

    -- get ingredientsItemSupplier
    local ingredientsItemSupplier = ObjHost.GetObj(ingredientsItemSupplierLocator)
    if type(ingredientsItemSupplier) ~= "table" then corelog.Error("Factory:needsTo_ProvideItemsTo_SOSrv: ingredientsItemSupplier "..ingredientsItemSupplierLocator:getURI().." not found.") return {success = false} end

    -- loop on items
    local fuelNeed = 0
    local ingredientsNeed = {}
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("Factory:needsTo_ProvideItemsTo_SOSrv: Invalid itemName (type="..type(itemName)..")") return {success = false} end
        if type(itemCount) ~= "number" then corelog.Error("Factory:needsTo_ProvideItemsTo_SOSrv: Invalid itemCount (type="..type(itemCount)..")") return {success = false} end

        -- check for recipe to provide itemName
        enterprise_manufacturing = enterprise_manufacturing or require "enterprise_manufacturing"
        local recipe = enterprise_manufacturing.GetRecipes()[ itemName ]
        if type(recipe) ~= "table" then corelog.Warning("Factory:needsTo_ProvideItemsTo_SOSrv: Factory can not provide "..itemName.."'s") return {success = false} end

        -- add ingredientsNeed
        local productionSpot, productionRecipe = self:getAvailableProductionSpot(recipe)
        if not productionSpot then corelog.Error("Factory:needsTo_ProvideItemsTo_SOSrv: Failed obtaining available ProductionSpot to produce "..itemName) return {success = false} end
        local itemIngredientsNeed = productionSpot:produceIngredientsNeeded(productionRecipe, itemCount)
        if not enterprise_isp.AddItemsTo(ingredientsNeed, itemIngredientsNeed).success then corelog.Error("Factory:needsTo_ProvideItemsTo_SOSrv: Failed adding items "..textutils.serialise(itemIngredientsNeed).." to ingredientsNeed.") return {success = false} end

        -- fuelNeed ingredients supply
        local localInputLocator = self:getAvailableInputLocator():copy()
        local serviceResults = ingredientsItemSupplier:needsTo_ProvideItemsTo_SOSrv({
            provideItems                    = itemIngredientsNeed,
            itemDepotLocator                = localInputLocator,
            ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator:copy(),
        })
        if not serviceResults.success then corelog.Error("Factory:needsTo_ProvideItemsTo_SOSrv: Failed obtaining needs for "..textutils.serialise(itemIngredientsNeed).." ingredients") return {success = false} end
        local fuelNeed_IngredientsSupply = serviceResults.fuelNeed

        -- fuelNeed production
        local items = { [itemName] = itemCount }
        local fuelNeed_SiteProduction = self:getFuelNeed_Production_Att(items)

        -- get localItemDepot
        local localItemDepotLocator = self:getAvailableOutputLocator()
        if not localItemDepotLocator then corelog.Error("Factory:needsTo_ProvideItemsTo_SOSrv: Failed obtaining localItemDepotLocator (type="..type(localItemDepotLocator)..")") return {success = false} end
        local localItemDepot = ObjHost.GetObj(localItemDepotLocator)
        if not localItemDepot or not Class.IsInstanceOf(localItemDepot, IItemDepot) then corelog.Error("BirchForest:needsTo_ProvideItemsTo_SOSrv: Failed obtaining an IItemDepot from localItemDepotLocator "..localItemDepotLocator:getURI()) return {success = false} end

        -- get location
        local localLocation = localItemDepot:getItemDepotLocation()

        -- fuelNeed output transfer
        local fuelNeed_ProductsSupply = role_energizer.NeededFuelToFrom(destinationLocation, localLocation)

        -- add fuelNeed
        -- corelog.WriteToLog("F  fuelNeed_IngredientsSupply="..fuelNeed_IngredientsSupply..", fuelNeed_SiteProduction="..fuelNeed_SiteProduction..", fuelNeed_ProductsSupply="..fuelNeed_ProductsSupply)
        fuelNeed = fuelNeed + fuelNeed_IngredientsSupply + fuelNeed_SiteProduction + fuelNeed_ProductsSupply
    end

    -- end
    return {
        success         = true,
        fuelNeed        = fuelNeed,
        ingredientsNeed = ingredientsNeed,
    }
end

--    ______         _
--   |  ____|       | |
--   | |__ __ _  ___| |_ ___  _ __ _   _
--   |  __/ _` |/ __| __/ _ \| '__| | | |
--   | | | (_| | (__| || (_) | |  | |_| |
--   |_|  \__,_|\___|\__\___/|_|   \__, |
--                                  __/ |
--                                 |___/

function Factory:getAvailableInputLocator()
    -- find first available locator
    for i, locator in ipairs(self:getInputLocators()) do
        -- ToDo: check actual availability

        -- take first
        return locator
    end

    -- end
    return nil
end

function Factory:getAvailableOutputLocator()
    -- find first available locator
    for i, locator in ipairs(self:getOutputLocators()) do
        -- ToDo: check actual availability

        -- take first
        return locator
    end

    -- end
    return nil
end

function Factory:getAvailableCraftSpot()
    -- find first available spot
    for i, spotLocator in ipairs(self:getCraftingSpotLocators()) do
        -- get spot
        local spot = ObjHost.GetObj(spotLocator)
        if not spot or not Class.IsInstanceOf(spot, CraftingSpot) then corelog.Error("Factory:getAvailableCraftSpot: Failed obtaining a CraftingSpot from spotLocator "..spotLocator:getURI()) return nil end

        -- ToDo: check actual availability (make method of CraftingSpot?)

        -- take first
        return spot
    end

    -- end
    return nil
end

function Factory:getAvailableSmeltSpot()
    -- find first available spot
    for i, spotLocator in ipairs(self:getSmeltingSpotLocators()) do
        -- get spot
        local spot = ObjHost.GetObj(spotLocator)
        if not spot or not Class.IsInstanceOf(spot, SmeltingSpot) then corelog.Error("Factory:getAvailableCraftSpot: Failed obtaining a SmeltingSpot from spotLocator "..spotLocator:getURI()) return nil end

        -- ToDo: check actual availability (make method of SmeltingSpot?)

        -- take first
        return spot
    end

    -- end
    return nil
end

function Factory:getAvailableProductionSpot(recipe)
    --[[
        This method finds and selects a ProductionSpot for producing items from a recipe.

        Return value:
            productionSpot          - (ProductionSpot) available ProductionSpot for recipe
            productionRecipe        - (table) production recipe

        Parameters:
            recipe                  + (table) item base recipe (including possibly both a crafting as smelting recipe)
    ]]

    -- check it can craft or smelt recipe
    local productionSpot = nil
    local productionRecipe = nil
    if recipe.crafting then
        productionRecipe = recipe.crafting
        productionSpot = self:getAvailableCraftSpot()
    elseif recipe.smelting then
        productionRecipe = recipe.smelting
        productionSpot = self:getAvailableSmeltSpot()
    else
        corelog.Error("Factory:getAvailableProductionSpot: no valid production recipe provided.")
    end

    -- end
    return productionSpot, productionRecipe
end

function Factory:getFuelNeed_Production_Att(...)
    -- get & check input from description
    local checkSuccess, items = InputChecker.Check([[
        Factory attribute for the current fuelNeed for producing items.

        It returns the fuelNeed for producing the items assuming the ingredients (incl possible production fuel) are available (in a Turtle located) at the Factory baseLocation
        and the results are to be delivered to that Location. In other worths we ignore fuel needs to and from the Factory.

        Return value:
            fuelNeed        - (number) amount of fuel needed to produce items

        Parameters:
            items           + (table) items to produce
    --]], ...)
    if not checkSuccess then corelog.Error("Factory:getFuelNeed_Production_Att: Invalid input") return enterprise_energy.GetLargeFuelAmount_Att() end

    -- cache Factory fields
    local baseLocation = self:getBaseLocation()
    local level = self:getLevel()

    -- determine local inputLocation
    local inputLocation = baseLocation
    if level == 2 then
         -- get local input Chest
        local inputChestLocator = self:getAvailableInputLocator()
        local inputChest = ObjHost.GetObj(inputChestLocator)
        if not inputChest then corelog.Error("Factory:getFuelNeed_Production_Att: No inputChest available.") return enterprise_energy.GetLargeFuelAmount_Att() end
        inputLocation = inputChest:getBaseLocation()
    end

    -- determine local inputLocation
    local outputLocation = baseLocation
    if level == 2 then
        -- get local output Chest
        local outputChestLocator = self:getAvailableOutputLocator()
        local outputChest = ObjHost.GetObj(outputChestLocator)
        if not outputChest then corelog.Error("Factory:getFuelNeed_Production_Att: No outputChest available.") return enterprise_energy.GetLargeFuelAmount_Att() end
        outputLocation = outputChest:getBaseLocation()
    end

    -- loop on items
    local fuelNeed_Production = 0
    for itemName, itemCount in pairs(items) do
        -- get recipe to provide item
        enterprise_manufacturing = enterprise_manufacturing or require "enterprise_manufacturing"
        local recipe = enterprise_manufacturing.GetRecipes()[ itemName ]
        if type(recipe) ~= "table" then corelog.Error("Factory:getFuelNeed_Production_Att: Factory does not provide "..itemName.."'s") return enterprise_energy.GetLargeFuelAmount_Att() end

        -- get productionSpot
        local productionSpot = self:getAvailableProductionSpot(recipe)
        if not productionSpot then corelog.Error("Factory:getFuelNeed_Production_Att: No ProductionSpot available.") return enterprise_energy.GetLargeFuelAmount_Att() end
        local productionSpotlocation = productionSpot:getBaseLocation()

        -- fuelNeed to productionSpot
        local fuelNeed_ToProductionlocation = role_energizer.NeededFuelToFrom(inputLocation, baseLocation) + role_energizer.NeededFuelToFrom(productionSpotlocation, inputLocation)

        -- fuelNeed for productionSpot
        local item = { itemName = itemCount }
        local fuelNeed_ProductionSpot = productionSpot:getFuelNeed_Production_Att(item)

        -- fuelNeed from productionSpot
        local fuelNeed_FromProductionLocation = role_energizer.NeededFuelToFrom(productionSpotlocation, outputLocation) + role_energizer.NeededFuelToFrom(baseLocation, outputLocation)

        -- end
        -- corelog.WriteToLog("FS fuelNeed_ToProductionlocation="..fuelNeed_ToProductionlocation..", fuelNeed_ProductionSpot="..fuelNeed_ProductionSpot..", fuelNeed_FromProductionLocation="..fuelNeed_FromProductionLocation)
        fuelNeed_Production = fuelNeed_Production + fuelNeed_ToProductionlocation + fuelNeed_ProductionSpot + fuelNeed_FromProductionLocation
    end

    -- end
    return fuelNeed_Production
end

return Factory
