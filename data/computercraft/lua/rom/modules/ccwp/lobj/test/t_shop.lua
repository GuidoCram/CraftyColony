local T_Shop = {}
local corelog = require "corelog"
local coreutils = require "coreutils"

local Callback = require "obj_callback"

local IObj = require "i_obj"
local IItemSupplier = require "i_item_supplier"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local ObjBase = require "obj_base"
local ObjArray = require "obj_array"
local ObjLocator = require "obj_locator"
local Location = require "obj_location"

local LObjLocator = require "lobj_locator"
local Shop = require "shop"

local role_forester = require "role_forester"

local enterprise_storage = require "enterprise_storage"
local enterprise_forestry = require "enterprise_forestry"
local enterprise_colonization = require "enterprise_colonization"

local ObjTest = require "test.obj_test"

local T_Class = require "test.t_class"
local T_IInterface = require "test.t_i_interface"
local T_IObj = require "test.t_i_obj"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"

local T_ILObj = require "test.t_i_lobj"
local T_IItemSupplier = require "test.t_i_item_supplier"

local T_Chest = require "test.t_mobj_chest"
local T_BirchForest = require "test.t_mobj_birchforest"
local T_ObjHost = require "test.t_obj_host"
local t_employment = require "test.t_employment"

function T_Shop.T_All()
    -- initialisation
    T_Shop.T__init()
    T_Shop.T_new()
    T_Shop.T_Getters()

    -- IObj
    T_Shop.T_IObj_All()

    -- ILObj
    T_Shop.T_ILObj_All()

    -- IItemSupplier
    T_Shop.T_IItemSupplier_All()

    -- Shop
    T_Shop.T_registerItemSupplier_SOSrv()
    T_Shop.T_delistItemSupplier_SOSrv()
    T_Shop.T_delistAllItemSuppliers()
    T_Shop.T_bestItemSupplier()
end

function T_Shop.T_AllPhysical()
    -- IItemSupplier
    T_Shop.T_provideItemsTo_AOSrv_MultipleItems_ToTurtle()
    T_Shop.T_provideItemsTo_AOSrv_Charcoal_ToTurtle()
    T_Shop.T_provideItemsTo_AOSrv_Torch_ToTurtle()
end

local testClassName = "Shop"
local testObjName = "shop"
local testHostName = "enterprise_colonization"

local logOk = false

local itemSuppliersLocators0 = ObjArray:newInstance(ObjLocator:getClassName())

local constructParameters0 = {
}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_Shop.CreateTestObj(id, itemSuppliersLocators)
    -- check input
    id = id or coreutils.NewId()
    itemSuppliersLocators = itemSuppliersLocators or itemSuppliersLocators0

    -- create testObj
    local testObj = Shop:newInstance(id, itemSuppliersLocators:copy())

    -- end
    return testObj
end

function T_Shop.CreateInitialisedTest(id, itemSuppliersLocators)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string") -- note: allow for testing only the type (instead of also the value)
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_itemSuppliersLocators", itemSuppliersLocators)
    )

    -- end
    return test
end

function T_Shop.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_Shop.CreateTestObj(id, itemSuppliersLocators0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_Shop.CreateInitialisedTest(id, itemSuppliersLocators0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_Shop.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = Shop:new({
        _id                     = id,

        _itemSuppliersLocators  = itemSuppliersLocators0:copy(),
    })
    local test = T_Shop.CreateInitialisedTest(id, itemSuppliersLocators0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_Shop.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." getter tests")
    local id = coreutils.NewId()
    local obj = T_Shop.CreateTestObj(id, itemSuppliersLocators0) if not obj then corelog.Error("Failed obtaining "..testClassName) return end

    -- test
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getItemSuppliersLocators", itemSuppliersLocators0)
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

function T_Shop.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_Shop.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_Shop.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

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

function T_Shop.T_ILObj_All()
    -- prepare test
    local destructFieldsTest = TestArrayTest:newInstance()

    local fieldsTest1 = T_Shop.CreateInitialisedTest(nil, itemSuppliersLocators0)

    -- test cases
    T_ILObj.pt_all(testClassName, Shop, {
        {
            objName             = testObjName,
            constructParameters = constructParameters0,
            constructFieldsTest = fieldsTest1,
            destructFieldsTest  = destructFieldsTest,
        },
    }, logOk)
end

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

function T_Shop.T_IItemSupplier_All()
    -- prepare test
    local obj = T_Shop.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test type
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemSupplier", IItemSupplier)
    T_IInterface.pt_ImplementsInterface("IItemSupplier", IItemSupplier, testClassName, obj)

    -- test
    T_Shop.T_can_ProvideItems_QOSrv()
    T_Shop.T_needsTo_ProvideItemsTo_SOSrv()
end

function T_Shop.T_provideItemsTo_AOSrv_MultipleItems_ToTurtle()
    -- prepare test
    local objLocator = enterprise_colonization.GetShopLocator()
--    testHost:hostLObj_SSrv({ className = testClassName, constructParameters = constructParameters_L2T4 }).mobjLocator assert(objLocator, "failed hosting "..testClassName.." on "..testHost:getHostName())
    local provideItems = {
        ["minecraft:furnace"]   = 1,
        ["minecraft:charcoal"]  = 1, -- ToDo: test if furnace get produced once charcoal is being smelted (as soon as projects support parallel steps)
    }

    t_employment = t_employment or require "test.t_employment"
    local itemDepotLocator = t_employment.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")
    local ingredientsItemSupplierLocator = t_employment.GetCurrentTurtleLocator() assert(ingredientsItemSupplierLocator, "Failed obtaining ingredientsItemSupplierLocator")
    local wasteItemDepotLocator = ingredientsItemSupplierLocator:copy()

    -- test
    T_IItemSupplier.pt_provideItemsTo_AOSrv(testClassName, objLocator, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, logOk)

    -- cleanup test
--    testHost:releaseLObj_SSrv({ mobjLocator = objLocator})
end

function T_Shop.T_provideItemsTo_AOSrv_Charcoal_ToTurtle()
    -- prepare test
    local objLocator = enterprise_colonization.GetShopLocator()
    local provideItems = {
        ["minecraft:charcoal"]  = 3,
    }

    t_employment = t_employment or require "test.t_employment"
    local itemDepotLocator = t_employment.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")
    local ingredientsItemSupplierLocator = t_employment.GetCurrentTurtleLocator() assert(ingredientsItemSupplierLocator, "Failed obtaining ingredientsItemSupplierLocator")
    local wasteItemDepotLocator = ingredientsItemSupplierLocator:copy()

    -- test
    T_IItemSupplier.pt_provideItemsTo_AOSrv(testClassName, objLocator, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, logOk)

    -- cleanup test
end

function T_Shop.T_provideItemsTo_AOSrv_Torch_ToTurtle()
    -- prepare test
    local objLocator = enterprise_colonization.GetShopLocator()
    local provideItems = {
        ["minecraft:torch"]  = 4,
    }

    t_employment = t_employment or require "test.t_employment"
    local itemDepotLocator = t_employment.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")
    local ingredientsItemSupplierLocator = t_employment.GetCurrentTurtleLocator() assert(ingredientsItemSupplierLocator, "Failed obtaining ingredientsItemSupplierLocator")
    local wasteItemDepotLocator = ingredientsItemSupplierLocator:copy()

    -- test
    T_IItemSupplier.pt_provideItemsTo_AOSrv(testClassName, objLocator, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, logOk)

    -- cleanup test
end

function T_Shop.T_needsTo_ProvideItemsTo_SOSrv()
    -- prepare test
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining obj") return end
    local lobjLocator = LObjLocator:newInstance(testHostName, obj)
    local ingredientsItemSupplierLocator = lobjLocator
    local nTrees = 1
    local forest = T_BirchForest.CreateTestObj() assert(forest, "Failed obtaining BirchForest")
    local forestLocator = enterprise_forestry:saveObj(forest)
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = forestLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")

    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }

    local itemDepotLocator = t_employment.GetCurrentTurtleLocator()

    -- test
    local storeFuelPerRound = 1 + 1
    local expectedFuelNeed = role_forester.FuelNeededPerRound(nTrees) + storeFuelPerRound
    T_IItemSupplier.pt_needsTo_ProvideItemsTo_SOSrv(testClassName, obj, testObjName, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, {
        success         = true,
        fuelNeed        = expectedFuelNeed,
        ingredientsNeed = {},
    }, logOk)

    -- cleanup test
    enterprise_colonization:deleteResource(lobjLocator)
    enterprise_forestry:deleteResource(forestLocator)
end

function T_Shop.T_can_ProvideItems_QOSrv()
    -- prepare test
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining obj") return end
    local lobjLocator = LObjLocator:newInstance(testHostName, obj)
    local forest = T_BirchForest.CreateTestObj() assert(forest, "Failed obtaining BirchForest")
    local forestLocator = enterprise_forestry:saveObj(forest)
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = forestLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")

    -- tests
    T_IItemSupplier.pt_can_ProvideItems_QOSrv(testClassName, obj, testObjName, { ["minecraft:birch_log"] = 20}, true, logOk)
    T_IItemSupplier.pt_can_ProvideItems_QOSrv(testClassName, obj, testObjName, { ["minecraft:birch_sapling"] = 2}, true, logOk)
    T_IItemSupplier.pt_can_ProvideItems_QOSrv(testClassName, obj, testObjName, { ["minecraft:dirt"] = 10}, false, logOk)

    -- cleanup test
    enterprise_colonization:deleteResource(lobjLocator)
    enterprise_forestry:deleteResource(forestLocator)
end

--     _____ _
--    / ____| |
--   | (___ | |__   ___  _ __
--    \___ \| '_ \ / _ \| '_ \
--    ____) | | | | (_) | |_) |
--   |_____/|_| |_|\___/| .__/
--                      | |
--                      |_|

function T_Shop.T_registerItemSupplier_SOSrv()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":registerItemSupplier_SOSrv() tests")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining Shop") return end
    local lobjLocator = LObjLocator:newInstance(testHostName, obj)
    local nItemSuppliers = #obj:getItemSuppliersLocators() assert(nItemSuppliers == 0, "Shop "..obj:getId().." not empty at start")
    local itemSupplierLocator = t_employment.GetCurrentTurtleLocator()

    local testObject = ObjTest:newInstance("field1", 4)
    local testObjHost = T_ObjHost.CreateTestObj()
    moduleRegistry:register(testObjHost:getHostName(), testObjHost)
    local nonItemSupplierLocator = testObjHost:saveObj(testObject)

    -- test IItemSupplier
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = itemSupplierLocator })
    assert(result.success == true, "registerItemSupplier_SOSrv services failed")
    nItemSuppliers = #obj:getItemSuppliersLocators()
    local expectedNItemSuppliers = 1
    assert(nItemSuppliers == expectedNItemSuppliers, "gotten nItemSuppliers(="..nItemSuppliers..") not the same as expected(="..expectedNItemSuppliers..")")

    -- test non IItemSupplier
    result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = nonItemSupplierLocator, suppressWarning = true })
    assert(result.success == false, "registerItemSupplier_SOSrv services should fail with a non IItemSupplier")

    -- cleanup test
    enterprise_colonization:deleteResource(lobjLocator) -- note: registerItemSupplier_SOSrv saved the test Shop
    moduleRegistry:delist(testObjHost:getHostName())
    testObjHost:deleteResource(nonItemSupplierLocator)
end

function T_Shop.T_delistItemSupplier_SOSrv()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":delistItemSupplier_SOSrv() tests")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining Shop") return end
    local lobjLocator = LObjLocator:newInstance(testHostName, obj)
    local nItemSuppliers = #obj:getItemSuppliersLocators() assert(nItemSuppliers == 0, "Shop "..obj:getId().." not empty at start")
    local itemSupplierLocator = t_employment.GetCurrentTurtleLocator()
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = itemSupplierLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")

    -- test
    result = obj:delistItemSupplier_SOSrv({ itemSupplierLocator = itemSupplierLocator})
    assert(result.success == true, "delistItemSupplier_SOSrv services failed")
    nItemSuppliers = #obj:getItemSuppliersLocators()
    local expectedNItemSuppliers = 0
    assert(nItemSuppliers == expectedNItemSuppliers, "gotten nItemSuppliers(="..nItemSuppliers..") not the same as expected(="..expectedNItemSuppliers..")")

    -- cleanup test
    enterprise_colonization:deleteResource(lobjLocator) -- note: delistItemSupplier_SOSrv saved the test Shop
end

function T_Shop.T_delistAllItemSuppliers()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":delistAllItemSuppliers() tests")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining Shop") return end
    local lobjLocator = LObjLocator:newInstance(testHostName, obj)
    local nItemSuppliers = #obj:getItemSuppliersLocators() assert(nItemSuppliers == 0, "Shop "..obj:getId().." not empty at start")
    local itemSupplierLocator = t_employment.GetCurrentTurtleLocator()
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = itemSupplierLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")
    local location1 = Location:newInstance(10, 0, 1, 0, 1)

    local chest = T_Chest.CreateTestObj(nil, location1) assert(chest, "Failed obtaining Chest")
    local chestLocator = enterprise_storage:saveObj(chest)
    result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = chestLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")

    nItemSuppliers = #obj:getItemSuppliersLocators() assert(nItemSuppliers == 2, "Shop "..obj:getId().." does not have 2 ItemSupplier's")

    -- test
    obj:delistAllItemSuppliers()
    nItemSuppliers = #obj:getItemSuppliersLocators()
    local expectedNItemSuppliers = 0
    assert(nItemSuppliers == expectedNItemSuppliers, "gotten # ItemSuppliers(="..nItemSuppliers..") not the same as expected(="..expectedNItemSuppliers..")")

    -- cleanup test
    enterprise_colonization:deleteResource(lobjLocator) -- note: delistAllItemSuppliers saved the test Shop
    enterprise_storage:deleteResource(chestLocator)
end

function T_Shop.T_bestItemSupplier()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":bestItemSupplier() tests")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining Shop") return end
    local lobjLocator = LObjLocator:newInstance(testHostName, obj)
    local item = {
        ["minecraft:birch_log"]  = 5,
    }
    local ingredientsItemSupplierLocator = lobjLocator
    local location1 = Location:newInstance(10, 0, 1, 0, 1)
    local chest = T_Chest.CreateTestObj(nil, location1) assert(chest, "Failed obtaining Chest")
    local itemDepotLocator = enterprise_storage:saveObj(chest)

    -- test lowest fuelNeed
    local closeLocation = location1:getRelativeLocation(1, 1, 0)
    chest = T_Chest.CreateTestObj(nil, closeLocation) assert(chest, "Failed obtaining Chest")
    local closeItemSupplierLocator = enterprise_storage:saveObj(chest)
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = closeItemSupplierLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")

    local farLocation = location1:getRelativeLocation(Location.FarX(), 1, 0)
    chest = T_Chest.CreateTestObj(nil, farLocation) assert(chest, "Failed obtaining Chest")
    local farItemSupplierLocator = enterprise_storage:saveObj(chest)
    result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = farItemSupplierLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")

    local bestItemSupplierLocator = obj:bestItemSupplier(item, itemDepotLocator, ingredientsItemSupplierLocator, farItemSupplierLocator, closeItemSupplierLocator)
    local expectedItemSupplierLocator = closeItemSupplierLocator
    assert(bestItemSupplierLocator:isEqual(expectedItemSupplierLocator), "gotten bestItemSupplier(="..textutils.serialize(bestItemSupplierLocator, compact)..") not the same as expected(="..textutils.serialize(expectedItemSupplierLocator, compact)..")")

    -- cleanup test
    enterprise_colonization:deleteResource(lobjLocator)
    enterprise_storage:deleteResource(itemDepotLocator)
    enterprise_storage:deleteResource(closeItemSupplierLocator)
    enterprise_storage:deleteResource(farItemSupplierLocator)
end

return T_Shop
