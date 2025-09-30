local T_IItemSupplier = {}

local corelog = require "corelog"

local MethodExecutor = require "method_executor"

local ObjLocator = require "obj_locator"
local ObjHost = require "obj_host"

local MethodResultEqualTest = require "method_result_equal_test"

local compact = { compact = true }

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

function T_IItemSupplier.pt_provideItemsTo_AOSrv(className, objLocator, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, logOk)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(objLocator) == "table", "no  valid objLocator provided")
    assert(type(provideItems) == "table", "no valid provideItems provided")
    assert(type(itemDepotLocator) == "table", "no valid itemDepotLocator provided")
    assert(type(ingredientsItemSupplierLocator) == "table", "no valid ingredientsItemSupplierLocator provided")
    assert(type(wasteItemDepotLocator) == "table", "no valid wasteItemDepotLocator provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog("* "..className..":provideItemsTo_AOSrv() test ("..textutils.serialize(provideItems, compact).." to "..itemDepotLocator:getURI()..")")

    local obj = ObjHost.GetObj(objLocator) assert(obj, "Failed obtaining "..className.." from objLocator "..objLocator:getURI())

    local expectedDestinationItemsLocator = itemDepotLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)

    -- test
    local serviceResults = MethodExecutor.DoASyncObjService_Sync(obj, "provideItemsTo_AOSrv", {
        provideItems                    = provideItems,
        itemDepotLocator                = itemDepotLocator,
        ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
        wasteItemDepotLocator           = wasteItemDepotLocator,
    })

    -- check: service success
    assert(serviceResults, "no serviceResults returned")
    assert(serviceResults.success, "failed executing service")

    -- check: items provided to destinationItemsLocator
    local destinationItemsLocator = ObjLocator:new(serviceResults.destinationItemsLocator)
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test
    if logOk then corelog.WriteToLog(" ok") end
end

function T_IItemSupplier.pt_can_ProvideItems_QOSrv(className, obj, objName, provideItems, expectedAnswer, logOk)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(provideItems) == "table", "no valid provideItems provided")
    assert(type(expectedAnswer) == "boolean", "no valid expectedAnswer provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog("* "..className..":can_ProvideItems_QOSrv() test (provideItems="..textutils.serialize(provideItems, compact)..", expectedAnswer="..tostring(expectedAnswer)..")")

    -- test
    local test = MethodResultEqualTest:newInstance("can_ProvideItems_QOSrv", { success = expectedAnswer, }, {
        provideItems = provideItems,
    })
    test:test(obj, objName, "", logOk)
end

function T_IItemSupplier.pt_needsTo_ProvideItemsTo_SOSrv(className, obj, objName, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, expectedResult, logOk)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(obj) == "table", "no valid obj provided")
    assert(type(objName) == "string", "no valid objName provided")
    assert(type(provideItems) == "table", "no valid provideItems provided")
    assert(type(itemDepotLocator) == "table", "no valid itemDepotLocator provided")
    assert(type(ingredientsItemSupplierLocator) == "table" or type(ingredientsItemSupplierLocator) == "nil", "no valid ingredientsItemSupplierLocator provided")
    assert(type(expectedResult) == "table", "no valid expectedResult provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog("* "..className..":needsTo_ProvideItemsTo_SOSrv() test (provideItems="..textutils.serialize(provideItems, compact)..", expectedResult="..textutils.serialize(expectedResult, compact)..")")

    -- test
    local test = MethodResultEqualTest:newInstance("needsTo_ProvideItemsTo_SOSrv", expectedResult, {
        provideItems                    = provideItems,
        itemDepotLocator                = itemDepotLocator,
        ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
    })
    test:test(obj, objName, "", logOk)
end

return T_IItemSupplier
