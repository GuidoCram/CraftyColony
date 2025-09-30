local T_URL = {}

local corelog = require "corelog"

local URL = require "obj_url"

local IObj = require "i_obj"
local ObjBase = require "obj_base"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_URL.T_All()
    -- initialisation
    T_URL.T__init()
    T_URL.T_new()
    T_URL.T_Getters()
    T_URL.T_GettersURI()
    T_URL.T_Setters()
    T_URL.T_SettersFromURI()
    T_URL.T_NewFromURI()

    -- IObj
    T_URL.T_IObj_All()

    -- specific
    T_URL.T_SameURLComponents()
    T_URL.T_baseCopy()
end

local testClassName = "URL"
local logOk = false
local scheme = "ccwprp"
local host1 = "enterprise_forestry"
local host2 = "enterprise_employment"
local port1 = 1
local port2 = 5
local pathSegments = {
    "forests",
    "oak",
    "id=50:23012",
    "tree=4",
}
local path1 = "/"..pathSegments[1].."/"..pathSegments[2].."/"..pathSegments[3] -- == "/forests/oak/id=50:23012"
local path2 = "/"..pathSegments[1].."/"..pathSegments[2].."/"..pathSegments[3].."/"..pathSegments[4] -- == "/forests/oak/id=50:23012/tree=4"
local itemName1 = "minecraft:torch"
local itemCount1 = 5
local itemName2 = "minecraft:birch_log"
local itemCount2 = 3
local itemName3 = "minecraft:charcoal"
local itemCount3 = 7
local query1 = {[itemName1] = itemCount1, [itemName2] = itemCount2}
local query2 = {[itemName1] = itemCount1, [itemName3] = itemCount3}

local schemeURI = "ccwprp://"
local hostURI = host1
local portURI = ":1"
local pathURI = "/"..pathSegments[1].."/"..pathSegments[2].."/"..pathSegments[3]
local queryURI = "?"..itemName2.."="..itemCount2.."&"..itemName1.."="..itemCount1
local expectedQueryURI = "?"..itemName1.."="..itemCount1.."&"..itemName2.."="..itemCount2

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_URL.CreateTestObj(host, path, query, port)
    -- check input
    host = host or host1
    path = path or path1
    query = query or {[itemName1] = itemCount1, [itemName2] = itemCount2}

    -- test
    local testObj = URL:newInstance(host, path, query, port)

    -- end
    return testObj
end

function T_URL.CreateInitialisedTest(host, path, query, port)
    -- check input

    -- create test
    local test = TestArrayTest:newInstance(
        FieldValueEqualTest:newInstance("_host", host),
        FieldValueEqualTest:newInstance("_path", path),
        FieldValueEqualTest:newInstance("_query", query)
    )
    if port then
        table.insert(test._tests, FieldValueEqualTest:newInstance("_port", port))
    else
        table.insert(test._tests, FieldValueTypeTest:newInstance("_port", "nil"))
    end

    -- end
    return test
end

function T_URL.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")

    -- test
    local obj = T_URL.CreateTestObj(host1, path1, query1, port1) assert(obj, "Failed obtaining "..testClassName)
    local test = T_URL.CreateInitialisedTest(host1, path1, query1, port1)
    test:test(obj, "url", "", logOk)

    -- test default
    obj = URL:newInstance()
    test = T_URL.CreateInitialisedTest("", "", {}, nil)
    test:test(obj, "url", "", logOk)

    -- cleanup test
end

function T_URL.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test
    local obj = URL:new({
        _host = host1,
        _path = path1,
        _query = query1,
        _port = port1,
    })
    local test = T_URL.CreateInitialisedTest(host1, path1, query1, port1)
    test:test(obj, "url", "", logOk)

    -- cleanup test
end

function T_URL.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." getter tests")
    local obj = T_URL.CreateTestObj(host1, path1, query1, port1)

    -- test
    local testResult = obj:getScheme()
    local expectedResultStr = scheme
    assert(testResult == expectedResultStr, "getScheme() return(="..testResult..") different from expected(="..expectedResultStr..")")

    testResult = obj:getHost()
    expectedResultStr = host1
    assert(testResult == expectedResultStr, "getHost() return(="..testResult..") different from expected(="..expectedResultStr..")")

    testResult = obj:getPort()
    local expectedResultNumber = port1
    assert(testResult == expectedResultNumber, "getPort() return(="..testResult..") different from expected(="..expectedResultNumber..")")

    testResult = obj:getPath()
    expectedResultStr = path1
    assert(testResult == expectedResultStr, "getPath() return(="..testResult..") different from expected(="..expectedResultStr..")")
    local iPathSegment = 1
    for pathSegment in obj:pathSegments_iter() do
        expectedResultStr = pathSegments[iPathSegment]
        assert(pathSegment == expectedResultStr, "pathSegment(="..pathSegment..") different from expected(="..expectedResultStr..")")
        iPathSegment = iPathSegment + 1
    end

    testResult = obj:getQuery()
    local expectedResultTable = query1
    assert(testResult == expectedResultTable, "getQuery() return(="..textutils.serialize(testResult)..") different from expected(="..textutils.serialize(expectedResultTable)..")")

    -- cleanup test
end

function T_URL.T_GettersURI()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." URI getter tests")
    local obj = T_URL.CreateTestObj(host1, path1, query1, port1)

    -- test
    assert(obj:getSchemeURI() == schemeURI, "getSchemeURI() return(="..obj:getSchemeURI()..") different from expected(="..schemeURI..")")
    AssertWithURIs(obj, hostURI, portURI, pathURI, queryURI)
    assert(obj:getAuthorityURI() == hostURI..portURI, "getAuthorityURI() return(="..obj:getAuthorityURI()..") different from expected(="..hostURI..portURI..")")

    -- cleanup test
end

function AssertWithURIs(obj, aHostURI, aPortURI, aNPathURI, aQueryURI)
    -- test
    assert(obj:getHostURI() == aHostURI, "getHostURI() return(="..obj:getHostURI()..") different from expected(="..aHostURI..")")
    assert(obj:getPortURI() == aPortURI, "getPortURI() return(="..obj:getPortURI()..") different from expected(="..aPortURI..")")
    assert(obj:getPathURI() == aNPathURI, "getPathURI() return(="..obj:getPathURI()..") different from expected(="..aNPathURI..")")
    assert(obj:getQueryURI() == aQueryURI, "getQueryURI() return(="..obj:getQueryURI()..") different from expected(="..aQueryURI..")")
    local expectedResultStr = schemeURI..aHostURI..aPortURI..aNPathURI..aQueryURI
    assert(obj:getURI() == expectedResultStr, "getURI() return(="..obj:getURI()..") different from expected(="..expectedResultStr..")")
end

function T_URL.T_Setters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." setter tests")
    local obj = URL:newInstance()

    -- test
    obj:setHost(host1)
    assert(obj:getHost() == host1, "setHost() result(="..obj:getHost()..") different from expected(="..host1..")")

    obj:setPort(port1)
    assert(obj:getPort() == port1, "setPort() result(="..obj:getPort()..") different from expected(="..port1..")")

    obj:setPath(path1)
    assert(obj:getPath() == path1, "setPath() result(="..textutils.serialize(obj:getPath())..") different from expected(="..textutils.serialize(path1)..")")

    obj:setQuery(query1)
    assert(obj:getQuery() == query1, "setHost() result(="..textutils.serialize(obj:getQuery())..") different from expected(="..textutils.serialize(query1)..")")

    -- cleanup test
end

function T_URL.T_SettersFromURI()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." setter from URI tests")
    local obj = URL:newInstance()

    -- test
    obj:setHostURI(hostURI)
    assert(obj:getHostURI() == hostURI, "setHostURI() result(="..obj:getHostURI()..") different from expected(="..hostURI..")")

    obj:setPortURI(portURI)
    assert(obj:getPortURI() == portURI, "setPortURI() result(="..obj:getPortURI()..") different from expected(="..portURI..")")

    obj:setPathURI(pathURI)
    assert(obj:getPathURI() == pathURI, "setPathURI() result(="..obj:getPathURI()..") different from expected(="..pathURI..")")

    obj:setQueryURI(queryURI)
    local testResult = obj:getQuery()
    assert(testResult[itemName1] == itemCount1, "testResult.itemName1 (="..testResult[itemName1]..") different from expected(="..itemCount1..")")
    assert(testResult[itemName2] == itemCount2, "testResult.itemName1 (="..testResult[itemName2]..") different from expected(="..itemCount2..")")

    -- cleanup test
end

function T_URL.T_NewFromURI()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." from URI tests (0)")

    -- test
    local newURI0=schemeURI..hostURI..portURI..pathURI..queryURI
    local obj = URL:newFromURI(newURI0)
    AssertWithURIs(obj, hostURI, portURI, pathURI, expectedQueryURI)

    corelog.WriteToLog("* URL from URI tests (1: no host1)")
    local newURI1=schemeURI..portURI..pathURI..queryURI
    obj = URL:newFromURI(newURI1, true)
    AssertWithURIs(obj, "", "", "", "") -- note: implies failure (error)

    corelog.WriteToLog("* URL from URI tests (2: no port1)")
    local newURI2=schemeURI..hostURI..pathURI..queryURI
    obj = URL:newFromURI(newURI2)
    AssertWithURIs(obj, hostURI, "", pathURI, expectedQueryURI)

    corelog.WriteToLog("* URL from URI tests (3: no path1)")
    local newURI3=schemeURI..hostURI..portURI..queryURI
    obj = URL:newFromURI(newURI3)
    AssertWithURIs(obj, hostURI, portURI, "", expectedQueryURI)

    corelog.WriteToLog("* URL from URI tests (4: no query1)")
    local newURI4=schemeURI..hostURI..portURI..pathURI
    obj = URL:newFromURI(newURI4)
    AssertWithURIs(obj, hostURI, portURI, pathURI, "")

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

function T_URL.T_IObj_All()
    -- prepare test
    local obj = T_URL.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_URL.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function T_URL.T_SameURLComponents()
    corelog.WriteToLog("* "..testClassName.." same components tests")
    -- sameHost
    local obj = URL:newInstance(host1)
    local aSameObj = URL:newInstance(host1)
    assert(obj:sameHost(aSameObj), "hosts should be the same")
    local aDifferentObj = URL:newInstance(host2)
    assert(not obj:sameHost(aDifferentObj), "hosts should not be the same")

    -- same Authority
    obj = URL:newInstance(host2, "", {}, port1)
    aSameObj = URL:newInstance(host2, "", {}, port1)
    assert(obj:sameAuthority(aSameObj), "authority should be the same")
    aDifferentObj = URL:newInstance(host2, "", {}, port2)
    assert(not obj:sameAuthority(aDifferentObj), "authority should not be the same")

    -- same path1
    obj = URL:newInstance(host1, path1)
    aSameObj = URL:newInstance(host1, path1)
    assert(obj:samePath(aSameObj), "path should be the same")
    aDifferentObj = URL:newInstance(host1, path2)
    assert(not obj:samePath(aDifferentObj), "path should not be the same")

    -- same base
    obj = URL:newInstance(host2, path1, {}, port1)
    aSameObj = URL:newInstance(host2, path1, {}, port1)
    assert(obj:samePath(aSameObj), "base should be the same")
    aDifferentObj = URL:newInstance(host2, path2, {}, port1)
    assert(not obj:samePath(aDifferentObj), "base should not be the same")

    -- same query1
    obj = URL:newInstance("", "", query1)
    aSameObj = URL:newInstance("", "", query1)
    assert(obj:sameQuery(aSameObj), "query should be the same")
    aDifferentObj = URL:newInstance("", "", query2)
    assert(not obj:sameQuery(aDifferentObj), "query should not be the same")
end

function T_URL.T_baseCopy()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":baseCopy() tests")
    local obj = T_URL.CreateTestObj(host1, path1, query1, port1)

    -- test
    local baseCopy = obj:baseCopy()
    AssertWithURIs(baseCopy, hostURI, portURI, pathURI, "")

    -- cleanup test
end

return T_URL
