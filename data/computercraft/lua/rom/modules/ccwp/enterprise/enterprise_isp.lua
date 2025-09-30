-- define module
local enterprise_isp = {}

--[[
    The Item Service Provider (ISP) is an enterprise that provides services to handle items. From the perspective of an enterprise that needs
    items to be handled across (possibly) multiple enterprises the ISP can be seen as a generic entrypoint (or hub or router) for handling
    those items.

    The ISP provides the following additional public services
        AddItemsLocators_SSrv       - adds the items of multiple itemsLocators into one itemsLocator. The itemsLocators should have the same host/ base component.
--]]

local corelog = require "corelog"

local URL = require "obj_url"

--                        _
--                       (_)
--    ___  ___ _ ____   ___  ___ ___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \
--   \__ \  __/ |   \ V /| | (_|  __/
--   |___/\___|_|    \_/ |_|\___\___|

function enterprise_isp.AddItemsLocators_SSrv(serviceData)
    --[[
        This sync public service adds the items of multiple itemsLocators into one itemsLocator. The itemsLocators should have the same host/ base component.

        Return value:
                                    - (table)
                success             - (boolean) whether the service executed successfully
                itemsLocator        - (URL) locating all items

        Parameters:
            serviceData             - (table) data about the query
                itemsLocator1       - (URL) a itemsLocator locating items
                                        (the "base" component of the URL specifies the host to query)
                                        (the "query" component of the URL specifies the items to query for)
                [itemsLocator2]     - (URL) another itemsLocator locating items
                [itemsLocatorN]     - (URL) and the final itemsLocator locating items
    --]]

    -- check input
    if type(serviceData) ~= "table" then corelog.Error("enterprise_isp.AddItemsLocators_SSrv: Invalid queryData") return {success = false} end

--    local itemsLocator = queryData.itemsLocator
--    if type(itemsLocator) ~= "table" then corelog.Error("enterprise_isp.AddItemsLocators_SSrv: Invalid itemsLocator") return {success = false} end

    -- use remaining input
    local allTrue = true
    local resultItemsLocator = nil
    for fieldKey, fieldvalue in pairs(serviceData) do
        -- check if it's a URL
        if type(fieldvalue) == "table" then
            -- wrap into URL
            local fieldItemsLocator = URL:new(fieldvalue)

            -- check if first
            if resultItemsLocator == nil then
                -- copy first
                resultItemsLocator = fieldItemsLocator:copy()
            else
                -- check if same host/ base as resultItemsLocator so far
                if not fieldItemsLocator:sameBase(resultItemsLocator) then
                    corelog.Error("enterprise_isp.AddItemsLocators_SSrv: Adding itemsLocator's (resultItemsLocator="..resultItemsLocator:getURI()..", fieldItemsLocator="..fieldItemsLocator:getURI()..") with different base not supported")
                    return {success = false}
                end

                -- add query component's
                local resultItemQuery = resultItemsLocator:getQuery()
                enterprise_isp.AddItemsTo(resultItemQuery, fieldItemsLocator:getQuery())
            end
        else
            corelog.Warning("enterprise_isp.AddItemsLocators_SSrv: Invalid fieldvalue (type="..type(fieldvalue)..")")
        end
    end
    if resultItemsLocator == nil then corelog.Error("enterprise_isp.AddItemsLocators_SSrv: Couldn't construct combined itemsLocator") return {success = false} end

    -- end
    local result = {
        success = allTrue,
        itemsLocator = resultItemsLocator
    }
    return result
end

function enterprise_isp.AddItemsTo(items, itemsToAdd)
    --[[
        This sync public function adds the items of itemsToAdd to items.

        Return value:
                                - (table)
                success         - (boolean) whether the function executed successfully

        Parameters:
            items               - (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs)
            itemsToAdd          - (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs) to add
    --]]

    -- check input
    if type(items) ~= "table" then corelog.Error("enterprise_isp.AddItemsTo: Invalid items") return {success = false} end
    if type(itemsToAdd) ~= "table" then corelog.Error("enterprise_isp.AddItemsTo: Invalid itemsToAdd") return {success = false} end

    -- add items
    for itemName, itemCount in pairs(itemsToAdd) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("enterprise_isp.AddItemsTo: Invalid itemName (type="..type(itemName)..")") return {success = false} end
        if type(itemCount) ~= "number" then corelog.Error("enterprise_isp.AddItemsTo: Invalid itemCount (type="..type(itemCount)..")") return {success = false} end

        -- add
        items[itemName] = (items[itemName] or 0) + itemCount
    end

    -- end
    return {success = true}
end

return enterprise_isp
