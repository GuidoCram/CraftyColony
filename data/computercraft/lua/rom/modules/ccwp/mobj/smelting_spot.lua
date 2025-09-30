-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ILObj = require "i_lobj"
local SmeltingSpot = Class.NewClass(ObjBase, ILObj)

--[[
    The SmeltingSpot mobj represents a production spot in the minecraft world using the smelting technique.

    The smelting technique uses a furnace to produce an output item from an input item (ingredient).
--]]

local corelog = require "corelog"
local coreutils = require "coreutils"

local InputChecker = require "input_checker"

local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"

local role_alchemist = require "role_alchemist"

local enterprise_projects = require "enterprise_projects"
local enterprise_employment = require "enterprise_employment"
local enterprise_energy = require "enterprise_energy"
local enterprise_manufacturing

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function SmeltingSpot:_init(...)
    -- get & check input from description
    local checkSuccess, id, baseLocation = InputChecker.Check([[
        Initialise a SmeltingSpot.

        Parameters:
            id                      + (string) id of the SmeltingSpot
            baseLocation            + (Location) base location of the SmeltingSpot
    ]], ...)
    if not checkSuccess then corelog.Error("SmeltingSpot:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id                = id
    self._baseLocation      = baseLocation
end

-- ToDo: should be renamed to newFromTable at some point
function SmeltingSpot:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a SmeltingSpot.

        Parameters:
            o                       + (table, {}) with object fields
                _id                 - (string) id of the SmeltingSpot
                _baseLocation       - (Location) base location of the SmeltingSpot
    ]], ...)
    if not checkSuccess then corelog.Error("SmeltingSpot:new: Invalid input") return {} end

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

function SmeltingSpot:getClassName()
    return "SmeltingSpot"
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function SmeltingSpot:construct(...)
    -- get & check input from description
    local checkSuccess, baseLocation = InputChecker.Check([[
        This method constructs a SmeltingSpot instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        The constructed SmeltingSpot is not yet saved in the LObjHost.

        Return value:
                                        - (SmeltingSpot) the constructed SmeltingSpot

        Parameters:
            constructParameters         - (table) parameters for constructing the SmeltingSpot
                baseLocation            + (Location) base location of the SmeltingSpot
    ]], ...)
    if not checkSuccess then corelog.Error("SmeltingSpot:construct: Invalid input") return nil end

    -- determine SmeltingSpot fields
    local id = coreutils.NewId()

    -- construct new SmeltingSpot
    local obj = SmeltingSpot:newInstance(id, baseLocation:copy())

    -- end
    return obj
end

function SmeltingSpot:destruct()
    --[[
        This method destructs a SmeltingSpot instance.

        The SmeltingSpot is not yet deleted from the LObjHost.

        Return value:
                                        - (boolean) whether the SmeltingSpot was succesfully destructed.

        Parameters:
    ]]

    -- end
    local destructSuccess = true
    return destructSuccess
end

function SmeltingSpot:getId()
    return self._id
end

function SmeltingSpot:getWIPId()
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

function SmeltingSpot:getBaseLocation()
    return self._baseLocation
end

-- ToDo: make SmeltingSpot a full IMObj (i.e. inherit + add other methods)

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

function SmeltingSpot:provideItemsTo_AOSrv(...)
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
    if not checkSuccess then corelog.Error("SmeltingSpot:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- check provideItems for 1 item type
    local nEntries = provideItems:nEntries()
    if nEntries ~= 1 then corelog.Error("SmeltingSpot:provideItemsTo_AOSrv: Not supported for "..tostring(nEntries).." provideItems entries") return Callback.ErrorCall(callback) end

    -- select recipe to produce item
    enterprise_manufacturing = enterprise_manufacturing or require "enterprise_manufacturing"
    local productItemName, v = next(provideItems)
    local recipe = enterprise_manufacturing.GetRecipes()[ productItemName ]
    if type(recipe) ~= "table" then corelog.Error("SmeltingSpot:provideItemsTo_AOSrv: No recipe for item "..productItemName) return Callback.ErrorCall(callback) end

    -- determine turtleInputLocator
    local turtleInputLocator = enterprise_employment.GetAnyTurtleLocator()

    -- create project data
    local fuelItemName  = "minecraft:birch_planks"
    local k, fuelItemCount = next(provideItems)
        -- ToDo: do this more efficient/ different (determine beste type, calculate etc)
    local smeltData = {
        provideItems    = provideItems:copy(),
        recipe          = recipe.smelting,

        workingLocation = self:getBaseLocation():copy(),

        fuelItemName    = fuelItemName,
        fuelItemCount   = fuelItemCount,

        priorityKey     = assignmentsPriorityKey,
    }
    local pickupData = {
        provideItems    = provideItems:copy(),

        workingLocation = self:getBaseLocation():copy(),

        priorityKey     = assignmentsPriorityKey,
    }
    local projectData = {
        smeltMetaData                   = role_alchemist.Smelt_MetaData(smeltData),
        smeltTaskCall                   = TaskCall:newInstance("role_alchemist", "Smelt_Task", smeltData),

        itemDepotLocator                = itemDepotLocator,
        ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
        wasteItemDepotLocator           = wasteItemDepotLocator,
        assignmentsPriorityKey          = assignmentsPriorityKey,

        turtleInputLocator              = turtleInputLocator,

        pickupMetaData                  = role_alchemist.Pickup_MetaData(pickupData),
        pickupTaskCall                  = TaskCall:newInstance("role_alchemist", "Pickup_Task", pickupData),
    }

    -- create project definition
    local projectDef = {
        steps = {
            -- get items into Turtle
            -- ToDo: consider using provideItemsTo_AOSrv here...
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "turtleInputLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"               , sourceStep = 0, sourceKeyDef = "ingredientsItemSupplierLocator" },
                { keyDef = "assignmentsPriorityKey"     , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }, description = "Getting items "..ingredientsItemSupplierLocator:getURI().." (local Factory input) into Turtle"},
            -- obtain workerId
            { stepType = "LSOMtd", stepTypeDef = { methodName = "getWorkerId", locatorStep = 1, locatorKeyDef = "destinationItemsLocator" }, stepDataDef = {
            }},
            -- smelt items
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"                   , sourceStep = 0, sourceKeyDef = "smeltMetaData" },
                { keyDef = "metaData.needWorkerId"      , sourceStep = 2, sourceKeyDef = "methodResults" },
                { keyDef = "taskCall"                   , sourceStep = 0, sourceKeyDef = "smeltTaskCall" },
            }, description = "Smelting "..textutils.serialise(provideItems, {compact = true})},
            -- pickup items
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"                   , sourceStep = 0, sourceKeyDef = "pickupMetaData" },
                { keyDef = "metaData.startTime"         , sourceStep = 3, sourceKeyDef = "smeltReadyTime" },
                { keyDef = "taskCall"                   , sourceStep = 0, sourceKeyDef = "pickupTaskCall" },
            }, description = "Pickup "..textutils.serialise(provideItems, {compact = true})},
            -- store produced items
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "itemDepotLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"               , sourceStep = 4, sourceKeyDef = "turtleOutputItemsLocator" },
                { keyDef = "assignmentsPriorityKey"     , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }, description = "Storing items into "..itemDepotLocator:getURI().." (local Factory output)" },
            -- store gathered waste
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "wasteItemDepotLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"               , sourceStep = 4, sourceKeyDef = "turtleWasteItemsLocator" },
                { keyDef = "assignmentsPriorityKey"     , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
        },
        returnData  = {
            { keyDef = "destinationItemsLocator"    , sourceStep = 5, sourceKeyDef = "destinationItemsLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "SmeltingSpot:provideItemsTo_AOSrv", description = "Time to make "..textutils.serialise(provideItems, {compact = true}), wipId = self:getWIPId()},
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

-- ToDo: make SmeltingSpot a full IItemSupplier (i.e. inherit + add other methods)

--     _____                _ _   _              _____             _
--    / ____|              | | | (_)            / ____|           | |
--   | (___  _ __ ___   ___| | |_ _ _ __   __ _| (___  _ __   ___ | |_
--    \___ \| '_ ` _ \ / _ \ | __| | '_ \ / _` |\___ \| '_ \ / _ \| __|
--    ____) | | | | | |  __/ | |_| | | | | (_| |____) | |_) | (_) | |_
--   |_____/|_| |_| |_|\___|_|\__|_|_| |_|\__, |_____/| .__/ \___/ \__|
--                                         __/ |      | |
--                                        |___/       |_|

function SmeltingSpot:getFuelNeed_Production_Att(...)
    -- get & check input from description
    local checkSuccess, items = InputChecker.Check([[
        SmeltingSpot attribute for the current fuelNeed for producing items.

        It returns the fuelNeed for producing the items assuming the ingredients (incl possible production fuel) are available (in a Turtle located) at the SmeltingSpot baseLocation
        and the results are to be delivered to that Location. In other worths we ignore fuel needs to and from the SmeltingSpot.

        Return value:
            fuelNeed        - (number) amount of fuel needed to produce items

        Parameters:
            items           + (table) items to produce
    --]], ...)
    if not checkSuccess then corelog.Error("SmeltingSpot:getFuelNeed_Production_Att: Invalid input") return enterprise_energy.GetLargeFuelAmount_Att() end

    -- fuelNeed for production of items
    local fuelNeed_Production = 0
    for _, _ in pairs(items) do
        fuelNeed_Production = fuelNeed_Production + 4 + 4 -- smelt + pickup
    end

    -- end
    return fuelNeed_Production
end

function SmeltingSpot:produceIngredientsNeeded(...)
    -- get & check input from description
    local checkSuccess, productionRecipe, productItemCount = InputChecker.Check([[
        This method determines the ingredients needed to produce 'productItemCount' items with the 'productionRecipe'.

        Return value:
            ingredientsNeeded           - (table) ingredientsNeeded to produce items
            productSurplus              - (number) number of surplus requested products

        Parameters:
            productionRecipe            + (table) production recipe
            productItemCount            + (number) amount of items to produce
    ]], ...)
    if not checkSuccess then corelog.Error("SmeltingSpot:itemsNeeded: Invalid input") return nil end

    -- determine production fuel
    -- ToDo: do this differently
    local fuelItemName  = "minecraft:birch_planks"
    local fuelItemCount = productItemCount

    -- determine ingredientsNeeded
    local ingredientsNeeded, productSurplus = role_alchemist.Smelt_ItemsNeeded(productionRecipe, productItemCount, fuelItemName, fuelItemCount)
    ingredientsNeeded = coreutils.DeepCopy(ingredientsNeeded)

    -- end
    return ingredientsNeeded, productSurplus
end

return SmeltingSpot
