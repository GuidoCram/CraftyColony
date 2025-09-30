-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ILObj = require "i_lobj"
local CraftingSpot = Class.NewClass(ObjBase, ILObj)

--[[
    The CraftingSpot mobj represents a production spot in the minecraft world using the crafting technique.

    The crafting technique uses a crafting table to produce an output item from a set of input items (ingredients).
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

function CraftingSpot:_init(...)
    -- get & check input from description
    local checkSuccess, id, baseLocation = InputChecker.Check([[
        Initialise a CraftingSpot.

        Parameters:
            id                      + (string) id of the CraftingSpot
            baseLocation            + (Location) base location of the CraftingSpot
    ]], ...)
    if not checkSuccess then corelog.Error("CraftingSpot:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id                = id
    self._baseLocation      = baseLocation
end

-- ToDo: should be renamed to newFromTable at some point
function CraftingSpot:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a CraftingSpot.

        Parameters:
            o                       + (table, {}) with object fields
                _id                 - (string) id of the CraftingSpot
                _baseLocation       - (Location) base location of the CraftingSpot
    ]], ...)
    if not checkSuccess then corelog.Error("CraftingSpot:new: Invalid input") return {} end

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

function CraftingSpot:getClassName()
    return "CraftingSpot"
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function CraftingSpot:construct(...)
    -- get & check input from description
    local checkSuccess, baseLocation = InputChecker.Check([[
        This method constructs a CraftingSpot instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        The constructed CraftingSpot is not yet saved in the LObjHost.

        Return value:
                                        - (CraftingSpot) the constructed CraftingSpot

        Parameters:
            constructParameters         - (table) parameters for constructing the CraftingSpot
                baseLocation            + (Location) base location of the CraftingSpot
    ]], ...)
    if not checkSuccess then corelog.Error("CraftingSpot:construct: Invalid input") return nil end

    -- determine CraftingSpot fields
    local id = coreutils.NewId()

    -- construct new CraftingSpot
    local obj = CraftingSpot:newInstance(id, baseLocation:copy())

    -- end
    return obj
end

function CraftingSpot:destruct()
    --[[
        This method destructs a CraftingSpot instance.

        The CraftingSpot is not yet deleted from the LObjHost.

        Return value:
                                        - (boolean) whether the CraftingSpot was succesfully destructed.

        Parameters:
    ]]

    -- end
    local destructSuccess = true
    return destructSuccess
end

function CraftingSpot:getId()
    return self._id
end

function CraftingSpot:getWIPId()
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

function CraftingSpot:getBaseLocation()
    return self._baseLocation
end

-- ToDo: make CraftingSpot a full IMObj (i.e. inherit + add other methods)

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

function CraftingSpot:provideItemsTo_AOSrv(...)
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
    if not checkSuccess then corelog.Error("CraftingSpot:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- check provideItems for 1 item type
    local nEntries = provideItems:nEntries()
    if nEntries ~= 1 then corelog.Error("CraftingSpot:provideItemsTo_AOSrv: Not supported for "..tostring(nEntries).." provideItems entries") return Callback.ErrorCall(callback) end

    -- select recipe to produce item
    enterprise_manufacturing = enterprise_manufacturing or require "enterprise_manufacturing"
    local productItemName, v = next(provideItems)
    local recipe = enterprise_manufacturing.GetRecipes()[ productItemName ]
    if type(recipe) ~= "table" then corelog.Error("CraftingSpot:provideItemsTo_AOSrv: No recipe for item "..productItemName) return Callback.ErrorCall(callback) end

    -- determine turtleInputLocator
    local turtleInputLocator = enterprise_employment.GetAnyTurtleLocator()

    -- create project data
    local craftData = {
        provideItems    = provideItems:copy(),

        recipe          = recipe.crafting,
        workingLocation = self:getBaseLocation():copy(),

        priorityKey     = assignmentsPriorityKey,
    }
    local projectData = {
        craftMetaData                   = role_alchemist.Craft_MetaData(craftData),
        craftTaskCall                   = TaskCall:newInstance("role_alchemist", "Craft_Task", craftData),

        itemDepotLocator                = itemDepotLocator,
        ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
        wasteItemDepotLocator           = wasteItemDepotLocator,
        assignmentsPriorityKey          = assignmentsPriorityKey,

        turtleInputLocator              = turtleInputLocator,
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
            -- craft items
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"                   , sourceStep = 0, sourceKeyDef = "craftMetaData" },
                { keyDef = "metaData.needWorkerId"      , sourceStep = 2, sourceKeyDef = "methodResults" },
                { keyDef = "taskCall"                   , sourceStep = 0, sourceKeyDef = "craftTaskCall" },
            }, description = "Crafting "..textutils.serialise(provideItems, {compact = true})},
            -- store produced items
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "itemDepotLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"               , sourceStep = 3, sourceKeyDef = "turtleOutputItemsLocator" },
                { keyDef = "assignmentsPriorityKey"     , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }, description = "Storing items into "..itemDepotLocator:getURI().." (local Factory output)" },
            -- store gathered waste
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "wasteItemDepotLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"               , sourceStep = 3, sourceKeyDef = "turtleWasteItemsLocator" },
                { keyDef = "assignmentsPriorityKey"     , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
        },
        returnData  = {
            { keyDef = "destinationItemsLocator"        , sourceStep = 4, sourceKeyDef = "destinationItemsLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "CraftingSpot:provideItemsTo_AOSrv", description = "Time to make "..textutils.serialise(provideItems, {compact = true}), wipId = self:getWIPId()},
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

-- ToDo: make CraftingSpot a full IItemSupplier (i.e. inherit + add other methods)

--     _____            __ _   _              _____             _
--    / ____|          / _| | (_)            / ____|           | |
--   | |     _ __ __ _| |_| |_ _ _ __   __ _| (___  _ __   ___ | |_
--   | |    | '__/ _` |  _| __| | '_ \ / _` |\___ \| '_ \ / _ \| __|
--   | |____| | | (_| | | | |_| | | | | (_| |____) | |_) | (_) | |_
--    \_____|_|  \__,_|_|  \__|_|_| |_|\__, |_____/| .__/ \___/ \__|
--                                      __/ |      | |
--                                     |___/       |_|

function CraftingSpot:getFuelNeed_Production_Att(...)
    -- get & check input from description
    local checkSuccess, items = InputChecker.Check([[
        CraftingSpot attribute for the current fuelNeed for producing items.

        It returns the fuelNeed for producing the items assuming the ingredients (incl possible production fuel) are available (in a Turtle located) at the CraftingSpot baseLocation
        and the results are to be delivered to that Location. In other worths we ignore fuel needs to and from the CraftingSpot.

        Return value:
            fuelNeed        - (number) amount of fuel needed to produce items

        Parameters:
            items           + (table) items to produce
    --]], ...)
    if not checkSuccess then corelog.Error("CraftingSpot:getFuelNeed_Production_Att: Invalid input") return enterprise_energy.GetLargeFuelAmount_Att() end

    -- fuelNeed for production of items
    local fuelNeed_Production = 0
    for _, _ in pairs(items) do
        fuelNeed_Production = fuelNeed_Production + 0
    end

    -- end
    return fuelNeed_Production
end

function CraftingSpot:produceIngredientsNeeded(...)
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
    if not checkSuccess then corelog.Error("CraftingSpot:itemsNeeded: Invalid input") return nil end

    -- determine ingredientsNeeded
    local ingredientsNeeded, productSurplus = role_alchemist.Craft_ItemsNeeded(productionRecipe, productItemCount)
    ingredientsNeeded = coreutils.DeepCopy(ingredientsNeeded)

    -- end
    return ingredientsNeeded, productSurplus
end

return CraftingSpot
