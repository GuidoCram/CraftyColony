local T_ItemStorageFake = {}
local corelog = require "corelog"
local coreutils = require "coreutils"

local role_energizer = require "role_energizer"

local IObj = require "i_obj"
local IItemSupplier = require "i_item_supplier"
local IItemDepot = require "i_item_depot"
local IItemStorage = require "i_item_storage"
local LObjTest = require "test.lobj_test"
local Location = require "obj_location"
local ItemTable = require "obj_item_table"

local ItemStorageFake = require "test.item_storage_fake"

local enterprise_test = require "test.enterprise_test"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"

local T_Class = require "test.t_class"
local T_IInterface = require "test.t_i_interface"
local T_IItemSupplier = require "test.t_i_item_supplier"
local T_IItemDepot = require "test.t_i_item_depot"

local t_employment

function T_ItemStorageFake.T_All()
    -- initialisation
    T_ItemStorageFake.T__init()
    T_ItemStorageFake.T_new()

    -- Type's test
    T_ItemStorageFake.T_Type()

    -- IItemSupplier
    T_ItemStorageFake.T_IItemSupplier_All()

    -- IItemDepot
    T_ItemStorageFake.T_IItemDepot_All()

    -- IItemDepot
    T_ItemStorageFake.T_IItemStorage_All()
end

function T_ItemStorageFake.T_AllPhysical()
    -- IItemSupplier
    T_ItemStorageFake.T_provideItemsTo_AOSrv_ToItemStorageFake()
    T_ItemStorageFake.T_storeItemsFrom_AOSrv_FromItemStorageFake()
end

local testClassName = "ItemStorageFake"
local testObjName = "itemStorageFake"
local testHost = enterprise_test

local logOk = false

local testStartLocation  = Location:newInstance(-6, 0, 1, 0, 1)
local baseLocation0  = testStartLocation:getRelativeLocation(2, 5, 0)
local nSlots0 = 26
local inventory0 = ItemTable:newInstance()

local field1_0 = "field1 0"

local constructParameters0 = {
    baseLocation    = baseLocation0,
    field1Value     = field1_0,
    nSlots          = nSlots0,
}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_ItemStorageFake.CreateTestObj(id, baseLocation, field1, inventory, nSlots)
    -- check input
    id = id or coreutils.NewId()
    baseLocation = baseLocation or baseLocation0
    field1 = field1 or field1_0
    inventory = inventory or inventory0
    nSlots = nSlots or nSlots0

    -- create testObj
    local testObj = ItemStorageFake:newInstance(id, baseLocation:copy(), field1, inventory:copy(), nSlots)

    -- end
    return testObj
end

function T_ItemStorageFake.CreateInitialisedTest(id, baseLocation, field1, inventory, nSlots)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string") -- note: allow for testing only the type (instead of also the value)
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation),
        FieldValueEqualTest:newInstance("_field1", field1),
        FieldValueEqualTest:newInstance("_inventory", inventory),
        FieldValueEqualTest:newInstance("_nSlots", nSlots)
    )

    -- end
    return test
end

function T_ItemStorageFake.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_ItemStorageFake.CreateTestObj(id, baseLocation0, field1_0, inventory0, nSlots0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_ItemStorageFake.CreateInitialisedTest(id, baseLocation0, field1_0, inventory0, nSlots0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_ItemStorageFake.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = ItemStorageFake:new({
        _id                     = id,

        _baseLocation           = baseLocation0:copy(),
        _field1                 = field1_0,
        _inventory              = inventory0:copy(),
        _nSlots                 = nSlots0
    })
    local test = T_ItemStorageFake.CreateInitialisedTest(id, baseLocation0, field1_0, inventory0, nSlots0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

--    _      ____  _     _ _______        _
--   | |    / __ \| |   (_)__   __|      | |
--   | |   | |  | | |__  _   | | ___  ___| |_
--   | |   | |  | | '_ \| |  | |/ _ \/ __| __|
--   | |___| |__| | |_) | |  | |  __/\__ \ |_
--   |______\____/|_.__/| |  |_|\___||___/\__|
--                     _/ |
--                    |__/

function T_ItemStorageFake.T_Type()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_ItemStorageFake.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_ItemStorageFake.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "LObjTest", LObjTest)
end

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

function T_ItemStorageFake.T_IItemSupplier_All()
    -- prepare test
    local obj = T_ItemStorageFake.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test type
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemSupplier", IItemSupplier)
    T_IInterface.pt_ImplementsInterface("IItemSupplier", IItemSupplier, testClassName, obj)

    -- test
    T_ItemStorageFake.T_needsTo_ProvideItemsTo_SOSrv()
    T_ItemStorageFake.T_can_ProvideItems_QOSrv()
end

function T_ItemStorageFake.T_provideItemsTo_AOSrv_ToItemStorageFake()
    -- prepare test
    local inventory = ItemTable:newInstance({ ["minecraft:dirt"] = 20, })
    local obj = T_ItemStorageFake.CreateTestObj(nil, nil, nil, inventory) assert(obj, "Failed obtaining "..testClassName)
    local objLocator = enterprise_test:saveObj(obj)

    local provideItems = { ["minecraft:dirt"] = 5, }

    local obj2 = T_ItemStorageFake.CreateTestObj(nil, baseLocation0:getRelativeLocation(0, 6, 0)) assert(obj2, "Failed obtaining "..testClassName.." 2")
    local itemDepotLocator = testHost:saveObj(obj2)
    t_employment = t_employment or require "test.t_employment"
    local ingredientsItemSupplierLocator = t_employment.GetCurrentTurtleLocator() assert(ingredientsItemSupplierLocator, "Failed obtaining ingredientsItemSupplierLocator")
    local wasteItemDepotLocator = ingredientsItemSupplierLocator:copy()

    -- test
    T_IItemSupplier.pt_provideItemsTo_AOSrv(testClassName, objLocator, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, logOk)

    -- cleanup test
    testHost:releaseLObj_SSrv({ mobjLocator = objLocator})
    testHost:deleteResource(itemDepotLocator)
end

function T_ItemStorageFake.T_needsTo_ProvideItemsTo_SOSrv()
    -- prepare test
    local obj = T_ItemStorageFake.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    local obj2 = T_ItemStorageFake.CreateTestObj(nil, baseLocation0:getRelativeLocation(0, 6, 0)) assert(obj2, "Failed obtaining "..testClassName.." 2")
    local itemDepotLocator = testHost:saveObj(obj2)
    local destinationItemDepotLocation = obj2:getBaseLocation()

    -- test
    T_IItemSupplier.pt_needsTo_ProvideItemsTo_SOSrv(testClassName, obj, testObjName, { ["minecraft:birch_log"]  = 5, }, itemDepotLocator, nil, {
        success         = true,
        fuelNeed        = 1 * role_energizer.NeededFuelToFrom(destinationItemDepotLocation, obj:getBaseLocation()),
        ingredientsNeed = {},
    }, logOk)

    -- cleanup test
    testHost:deleteResource(itemDepotLocator)
end

function T_ItemStorageFake.T_can_ProvideItems_QOSrv()
    -- prepare test
    local inventory = ItemTable:newInstance({ ["minecraft:dirt"] = 20, })
    local obj = T_ItemStorageFake.CreateTestObj(nil, nil, nil, inventory) assert(obj, "Failed obtaining "..testClassName)

    -- tests
    T_IItemSupplier.pt_can_ProvideItems_QOSrv(testClassName, obj, testObjName, { ["minecraft:dirt"] = 10}, true, logOk)
    T_IItemSupplier.pt_can_ProvideItems_QOSrv(testClassName, obj, testObjName, { ["minecraft:furnace"] = 1}, false, logOk)

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

function T_ItemStorageFake.T_IItemDepot_All()
    -- prepare test
    local obj = T_ItemStorageFake.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemDepot", IItemDepot)
    T_IInterface.pt_ImplementsInterface("IItemDepot", IItemDepot, testClassName, obj)
end

function T_ItemStorageFake.T_storeItemsFrom_AOSrv_FromItemStorageFake()
    -- prepare test
    local objLocator = testHost:hostLObj_SSrv({ className = testClassName, constructParameters = constructParameters0 }).mobjLocator assert(objLocator, "failed hosting "..testClassName.." on "..testHost:getHostName())

    local itemSupplierConstructParameters = {
        baseLocation    = baseLocation0:getRelativeLocation(0, 6, 0),
        field1Value     = field1_0,
        nSlots          = nSlots0,
    }
    local itemSupplierLocator = testHost:hostLObj_SSrv({ className = testClassName, constructParameters = itemSupplierConstructParameters }).mobjLocator assert(objLocator, "failed hosting "..testClassName.." on "..testHost:getHostName())

    local storeItems = { ["minecraft:birch_log"] = 5, }

    -- test
    T_IItemDepot.pt_storeItemsFrom_AOSrv(testClassName, objLocator, itemSupplierLocator, storeItems, logOk)

    -- cleanup test
    testHost:releaseLObj_SSrv({ mobjLocator = itemSupplierLocator})
    testHost:releaseLObj_SSrv({ mobjLocator = objLocator})
end

--    _____ _____ _                  _____ _
--   |_   _|_   _| |                / ____| |
--     | |   | | | |_ ___ _ __ ___ | (___ | |_ ___  _ __ __ _  __ _  ___
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| __/ _ \| '__/ _` |/ _` |/ _ \
--    _| |_ _| |_| ||  __/ | | | | |____) | || (_) | | | (_| | (_| |  __/
--   |_____|_____|\__\___|_| |_| |_|_____/ \__\___/|_|  \__,_|\__, |\___|
--                                                             __/ |
--                                                            |___/

function T_ItemStorageFake.T_IItemStorage_All()
    -- prepare test
    local obj = T_ItemStorageFake.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test type
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemStorage", IItemStorage)
    T_IInterface.pt_ImplementsInterface("IItemStorage", IItemStorage, testClassName, obj)

    -- test
    -- T_ItemStorageFake.T_needsTo_ProvideItemsTo_SOSrv()
    -- T_ItemStorageFake.T_can_ProvideItems_QOSrv()
end

return T_ItemStorageFake
