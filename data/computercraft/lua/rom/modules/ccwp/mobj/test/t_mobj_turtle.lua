local T_Turtle = {}

local corelog = require "corelog"
local coreutils = require "coreutils"

local IItemSupplier = require "i_item_supplier"
local IItemDepot = require "i_item_depot"
local IObj = require "i_obj"
local ObjBase = require "obj_base"
local Location = require "obj_location"
local ObjLocator = require "obj_locator"

local Turtle = require "mobj_turtle"

local enterprise_employment = require "enterprise_employment"
local enterprise_storage = require "enterprise_storage"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"
local IsBlueprintTest = require "test.is_blueprint_test"

local T_Class = require "test.t_class"
local T_IInterface = require "test.t_i_interface"
local T_IObj = require "test.t_i_obj"
local T_ILObj = require "test.t_i_lobj"
local T_IMObj = require "test.t_i_mobj"
local T_IWorker = require "test.t_i_worker"
local T_IItemSupplier = require "test.t_i_item_supplier"
local T_IItemDepot = require "test.t_i_item_depot"

local T_Chest = require "test.t_mobj_chest"
local T_Settlement = require "test.t_settlement"

local t_employment = require "test.t_employment"

function T_Turtle.T_All()
    -- initialisation
    T_Turtle.T__init()
    T_Turtle.T_new()
    T_Turtle.T_Getters()

    -- IObj
    T_Turtle.T_IObj_All()

    -- ILObj
    T_Turtle.T_ILObj_All()

    -- IMObj
    T_Turtle.T_IMObj_All()

    -- IWorker
    T_Turtle.T_IWorker_All()

    -- IItemSupplier
    T_Turtle.T_IItemSupplier_All()

    -- IItemDepot
    T_Turtle.T_IItemDepot_All()
end

function T_Turtle.T_AllPhysical()
    -- IItemSupplier
    T_Turtle.T_storeItemsFrom_AOSrv_FromTurtle()
    T_Turtle.T_provideItemsTo_AOSrv_ToTurtle()
    T_Turtle.T_storeItemsFrom_AOSrv_FromChest()
    T_Turtle.T_provideItemsTo_AOSrv_ToChest()
end

local testClassName = "Turtle"
local testObjName = "turtle"
local testHost = enterprise_employment

local logOk = false

local workerId0 = 111111
local isActive_false = false
local settlementLocator0 = ObjLocator:newInstance("enterprise_colonization", "Settlement")
local baseLocation0  = Location:newInstance(1, -1, 3, 0, 1)
local baseLocationChest  = Location:newInstance(-6, 0, 1, 0, 1):getRelativeLocation(2, 5, 0)
local workerLocation0  = baseLocation0:copy()
local fuelPriorityKey0 = ""
local fuelPriorityKey1 = "99:111"

local constructParameters0 = {
    workerId            = workerId0,
    settlementLocator   = settlementLocator0,
    baseLocation        = baseLocation0,
    workerLocation      = workerLocation0,
}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_Turtle.CreateTestObj(id, workerId, isActive, settlementLocator, baselocation, workerLocation, fuelPriorityKey)
    -- check input
    id = id or coreutils.NewId()
    workerId = workerId or workerId0
    isActive = isActive or isActive_false
    settlementLocator = settlementLocator or settlementLocator0
    baselocation = baselocation or baseLocation0
    workerLocation = workerLocation or workerLocation0
    fuelPriorityKey = fuelPriorityKey or fuelPriorityKey0

    -- create Turtle object
    local turtleObj = Turtle:newInstance(id, workerId, isActive, settlementLocator, baselocation, workerLocation, fuelPriorityKey)

    -- end
    return turtleObj
end

function T_Turtle.CreateInitialisedTest(id, workerId, isActive, settlementLocator, baselocation, workerLocation, fuelPriorityKey)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string") -- note: allow for testing only the type (instead of also the value)
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_workerId", workerId),
        FieldValueEqualTest:newInstance("_isActive", isActive),
        FieldValueEqualTest:newInstance("_settlementLocator", settlementLocator),
        FieldValueEqualTest:newInstance("_baseLocation", baselocation),
        FieldValueEqualTest:newInstance("_location", workerLocation),
        FieldValueEqualTest:newInstance("_fuelPriorityKey", fuelPriorityKey)
    )

    -- end
    return test
end

function T_Turtle.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_Turtle.CreateTestObj(id, workerId0, isActive_false, settlementLocator0, baseLocation0, workerLocation0, fuelPriorityKey0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_Turtle.CreateInitialisedTest(id, workerId0, isActive_false, settlementLocator0, baseLocation0, workerLocation0, fuelPriorityKey0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_Turtle.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = Turtle:new({
        _id                     = id,
        _workerId               = workerId0,
        _isActive               = isActive_false,
        _settlementLocator      = settlementLocator0,
        _baseLocation           = baseLocation0,
        _location               = workerLocation0,

        _fuelPriorityKey        = fuelPriorityKey0,
    })
    local test = T_Turtle.CreateInitialisedTest(id, workerId0, isActive_false, settlementLocator0, baseLocation0, workerLocation0, fuelPriorityKey0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_Turtle.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." getter tests")
    local obj = T_Turtle.CreateTestObj(nil, workerId0, isActive_false, settlementLocator0, baseLocation0, workerLocation0, fuelPriorityKey1) assert(obj, "Failed obtaining "..testClassName)

    -- test
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getFuelPriorityKey", fuelPriorityKey1)
    )
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function T_Turtle.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_Turtle.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_Turtle.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function T_Turtle.T_ILObj_All()
    -- prepare test
    local destructFieldsTest = TestArrayTest:newInstance()

    local constructFieldsTest = T_Turtle.CreateInitialisedTest(nil, workerId0, isActive_false, settlementLocator0, baseLocation0, workerLocation0, fuelPriorityKey0)

    -- test cases
    T_ILObj.pt_all(testClassName, Turtle, {
        {
            objName             = testObjName,
            constructParameters = constructParameters0,
            constructFieldsTest = constructFieldsTest,
            destructFieldsTest  = destructFieldsTest,
        },
    }, logOk)
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function T_Turtle.T_IMObj_All()
    -- prepare test
    local isBlueprintTest = IsBlueprintTest:newInstance(baseLocation0)

    -- test cases
    T_IMObj.pt_all(testClassName, Turtle, {
        {
            objName                 = testObjName,
            constructParameters     = constructParameters0,
            constructBlueprintTest  = isBlueprintTest,
            expectedBaseLocation    = baseLocation0:copy(),
            dismantleBlueprintTest  = isBlueprintTest,
        },
    }, logOk)
end

--    _______          __        _
--   |_   _\ \        / /       | |
--     | |  \ \  /\  / /__  _ __| | _____ _ __
--     | |   \ \/  \/ / _ \| '__| |/ / _ \ '__|
--    _| |_   \  /\  / (_) | |  |   <  __/ |
--   |_____|   \/  \/ \___/|_|  |_|\_\___|_|

function T_Turtle.T_IWorker_All()
    -- prepare test
    local obj = T_Turtle.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local workerResumeTest = TestArrayTest:newInstance(
        FieldValueTypeTest:newInstance("workerId", "number"),
        FieldValueTypeTest:newInstance("location", "Location"),
        FieldValueTypeTest:newInstance("fuelLevel", "number"),
        FieldValueTypeTest:newInstance("axePresent", "boolean"),
        FieldValueTypeTest:newInstance("inventoryItems", "table"),
        FieldValueTypeTest:newInstance("leftEquiped", "string"),
        FieldValueTypeTest:newInstance("rightEquiped", "string")
    )
    local isMainUIMenuTest = TestArrayTest:newInstance(
        FieldValueTypeTest:newInstance("clear", "boolean"),
        FieldValueTypeTest:newInstance("intro", "string"),
        FieldValueTypeTest:newInstance("option", "table"),
        FieldValueTypeTest:newInstance("question", "string")
    )
    local assignmentFilterTest = TestArrayTest:newInstance(
        FieldValueTypeTest:newInstance("priorityKeyNeeded", "string")
    )

    -- test
    local expectedWorkerLocation = workerLocation0:copy()
    T_IWorker.pt_all(testClassName, obj, testObjName, expectedWorkerLocation, workerResumeTest, isMainUIMenuTest, assignmentFilterTest, logOk)
end

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

function T_Turtle.T_IItemSupplier_All()
    -- prepare test
    local obj = T_Turtle.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test type
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemSupplier", IItemSupplier)
    T_IInterface.pt_ImplementsInterface("IItemSupplier", IItemSupplier, testClassName, obj)

    -- test
    T_Turtle.T_needsTo_ProvideItemsTo_SOSrv()
    T_Turtle.T_can_ProvideItems_QOSrv()
end

function T_Turtle.T_provideItemsTo_AOSrv_ToTurtle()
    -- prepare test
    t_employment = t_employment or require "test.t_employment"
    local objLocator = t_employment.GetCurrentTurtleLocator() assert(objLocator, "Failed obtaining objLocator")

    local provideItems = { ["minecraft:birch_log"] = 5, }

    local itemDepotLocator = t_employment.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")
    local ingredientsItemSupplierLocator = t_employment.GetCurrentTurtleLocator() assert(ingredientsItemSupplierLocator, "Failed obtaining ingredientsItemSupplierLocator")
    local wasteItemDepotLocator = ingredientsItemSupplierLocator:copy()

    -- test
    T_IItemSupplier.pt_provideItemsTo_AOSrv(testClassName, objLocator, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, logOk)

    -- cleanup test
end

function T_Turtle.T_provideItemsTo_AOSrv_ToChest()
    -- prepare test
    t_employment = t_employment or require "test.t_employment"
    local objLocator = t_employment.GetCurrentTurtleLocator() assert(objLocator, "Failed obtaining objLocator")

    local provideItems = { ["minecraft:birch_log"] = 5, }

    local obj2 = T_Chest.CreateTestObj(nil, baseLocationChest) assert(obj2, "Failed obtaining "..testClassName.." 2")
    local itemDepotLocator = enterprise_storage:saveObj(obj2)
    local ingredientsItemSupplierLocator = t_employment.GetCurrentTurtleLocator() assert(ingredientsItemSupplierLocator, "Failed obtaining ingredientsItemSupplierLocator")
    local wasteItemDepotLocator = ingredientsItemSupplierLocator:copy()

    -- test
    T_IItemSupplier.pt_provideItemsTo_AOSrv(testClassName, objLocator, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, logOk)

    -- cleanup test
    enterprise_storage:deleteResource(itemDepotLocator)
end

function T_Turtle.T_needsTo_ProvideItemsTo_SOSrv()
    -- prepare test
    t_employment = t_employment or require "test.t_employment"
    local objLocator = t_employment.GetCurrentTurtleLocator() assert(objLocator, "Failed obtaining objLocator")
    local obj = testHost:getObj(objLocator) assert(obj, "Failed obtaining obj")
    local itemTable = obj:getInventoryAsItemTable()

    local itemDepotLocator = t_employment.GetCurrentTurtleLocator()
    local ingredientsItemSupplierLocator = t_employment.GetCurrentTurtleLocator()

    -- tests
    for itemName, itemCount in pairs(itemTable) do
        T_IItemSupplier.pt_needsTo_ProvideItemsTo_SOSrv(testClassName, obj, testObjName, { [itemName] = itemCount, }, itemDepotLocator, ingredientsItemSupplierLocator, {
            success         = true,
            fuelNeed        = 0,
            ingredientsNeed = { },
        }, logOk)
    end
    T_IItemSupplier.pt_needsTo_ProvideItemsTo_SOSrv(testClassName, obj, testObjName, { ["anUnknownItem"] = 1, }, itemDepotLocator, ingredientsItemSupplierLocator, {
        success         = false,
    }, logOk)

    -- cleanup test
end

function T_Turtle.T_can_ProvideItems_QOSrv()
    -- prepare test
    t_employment = t_employment or require "test.t_employment"
    local objLocator = t_employment.GetCurrentTurtleLocator() assert(objLocator, "Failed obtaining objLocator")
    local obj = testHost:getObj(objLocator) assert(obj, "Failed obtaining obj")
    local itemTable = obj:getInventoryAsItemTable()

    -- tests
    for itemName, itemCount in pairs(itemTable) do
        T_IItemSupplier.pt_can_ProvideItems_QOSrv(testClassName, obj, testObjName, { [itemName] = itemCount, }, true, logOk)
    end
    T_IItemSupplier.pt_can_ProvideItems_QOSrv(testClassName, obj, testObjName, { ["anUnknownItem"] = 1, }, false, logOk)

    -- cleanup test
end

--    _____ _____ _                 _____                   _
--   |_   _|_   _| |               |  __ \                 | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__|
--                                             | |
--                                             |_|

function T_Turtle.T_IItemDepot_All()
    -- prepare test
    local obj = T_Turtle.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemDepot", IItemDepot)
    T_IInterface.pt_ImplementsInterface("IItemDepot", IItemDepot, testClassName, obj)
end

function T_Turtle.T_storeItemsFrom_AOSrv_FromTurtle()
    -- prepare test
    t_employment = t_employment or require "test.t_employment"
    local objLocator = t_employment.GetCurrentTurtleLocator() assert(objLocator, "Failed obtaining objLocator")

    local itemSupplierLocator = t_employment.GetCurrentTurtleLocator() assert(itemSupplierLocator, "Failed obtaining itemSupplierLocator")

    local storeItems = { ["minecraft:birch_log"] = 5, }

    -- test
    T_IItemDepot.pt_storeItemsFrom_AOSrv(testClassName, objLocator, itemSupplierLocator, storeItems, logOk)

    -- cleanup test
end

function T_Turtle.T_storeItemsFrom_AOSrv_FromChest()
    -- prepare test
    t_employment = t_employment or require "test.t_employment"
    local objLocator = t_employment.GetCurrentTurtleLocator() assert(objLocator, "Failed obtaining objLocator")

    local itemSupplierConstructParameters = { baseLocation = baseLocationChest:copy(), accessDirection = "top", }
    local itemSupplierLocator = enterprise_storage:hostLObj_SSrv({ className = "Chest", constructParameters = itemSupplierConstructParameters }).mobjLocator assert(objLocator, "failed hosting "..testClassName.." on "..testHost:getHostName())

    local storeItems = { ["minecraft:birch_log"] = 5, }

    -- test
    T_IItemDepot.pt_storeItemsFrom_AOSrv(testClassName, objLocator, itemSupplierLocator, storeItems, logOk)

    -- cleanup test
    testHost:releaseLObj_SSrv({ mobjLocator = itemSupplierLocator})
end

return T_Turtle
