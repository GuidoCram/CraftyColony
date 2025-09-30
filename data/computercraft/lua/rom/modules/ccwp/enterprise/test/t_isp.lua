local t_isp = {}

local corelog = require "corelog"

local enterprise_employment = require "enterprise_employment"
local enterprise_isp = require "enterprise_isp"

function t_isp.T_All()
    t_isp.T_AddItemsLocators()
end

local testClassName = "enterprise_isp"

function t_isp.T_AddItemsLocators()
    -- create testData
    corelog.WriteToLog("* "..testClassName..":AddItemsLocators_SSrv() test")
    local itemsQuery1 = {
        ["minecraft:birch_log"] = 1,
        ["minecraft:torch"]     = 5,
    }
    local itemsQuery2 = {
        ["minecraft:birch_log"] = 1,
        ["minecraft:torch"]     = 5,
    }
    local itemsQuery3 = {
        ["minecraft:birch_log"] = 1,
        ["minecraft:charcoal"]  = 100,
    }
    local turtleLocator = enterprise_employment:GetAnyTurtleLocator() assert(turtleLocator, "Failed obtaining turtleLocator")
    local itemsLocator1 = turtleLocator:copy()
    itemsLocator1:setQuery(itemsQuery1)
    local itemsLocator2 = turtleLocator:copy()
    itemsLocator2:setQuery(itemsQuery2)
    local itemsLocator3 = turtleLocator:copy()
    itemsLocator3:setQuery(itemsQuery3)

    local testData = {
        itemsLocator1 = itemsLocator1,
        itemsLocator2 = itemsLocator2,
        itemsLocator3 = itemsLocator3,
    }

    -- call test method
    local result = enterprise_isp.AddItemsLocators_SSrv(testData)
--    corelog.WriteToLog("  result="..textutils.serialize(result))

    -- check result
    local expectedItemsQuery = {
        ["minecraft:charcoal"]  = 100,
        ["minecraft:birch_log"] = 3,
        ["minecraft:torch"]     = 10,
    }
    local expectedItemsLocator = turtleLocator:copy()
    expectedItemsLocator:setQuery(expectedItemsQuery)
    assert(expectedItemsLocator:sameBase(result.itemsLocator), "result itemsLocator (="..result.itemsLocator:getURI()..") different base from expected (="..expectedItemsLocator:getURI()..")")
    assert(expectedItemsLocator:sameQuery(result.itemsLocator), "result itemsLocator (="..result.itemsLocator:getURI()..") different query from expected (="..expectedItemsLocator:getURI()..")")
end

return t_isp
