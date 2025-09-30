local t_projects = {}

local corelog = require "corelog"

local Class = require "class"
local Callback = require "obj_callback"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()

local Host = require "host"

local ObjTest = require "test.obj_test"

local enterprise_projects = require "enterprise_projects"
local enterprise_administration = require "enterprise_administration"

local enterprise_test = require "test.enterprise_test"

function t_projects.T_All()
--    t_projects.T_AreAllTrue_QSrv()
    t_projects.T_DeleteProjects()
    t_projects.T_StartProject_ASrv()
    t_projects.T_StartProject_ASrv_registersWIP()
end

function t_projects.T_AreAllTrue_QSrv()
    -- prepare test
    corelog.WriteToLog("* enterprise_projects.AreAllTrue_QSrv() tests")
    local serviceData = {
        booleanArg1 = true,
        booleanArg2 = true,
        booleanArg3 = true,
        booleanArg4 = true,
    }

    -- test all boolean true
    local result = enterprise_projects.AreAllTrue_QSrv(serviceData)
    local expectedSuccess = true
    assert(result.success, "gotten AreAllTrue_QSrv(="..tostring(result.success)..") not the same as expected(="..tostring(expectedSuccess)..")")

    -- test ignore none boolean arguments
    serviceData.noneBooleanArg1 = "none boolean Arg1"
    serviceData.noneBooleanArg2 = "none boolean Arg2"
    result = enterprise_projects.AreAllTrue_QSrv(serviceData)
    expectedSuccess = true
    assert(result.success, "gotten AreAllTrue_QSrv(="..tostring(result.success)..") not the same as expected(="..tostring(expectedSuccess)..")")

    -- test one boolean false
    serviceData.booleanArg3 = false
    result = enterprise_projects.AreAllTrue_QSrv(serviceData)
    expectedSuccess = false
    assert(not result.success, "gotten AreAllTrue_QSrv(="..tostring(result.success)..") not the same as expected(="..tostring(expectedSuccess)..")")
    serviceData.booleanArg3 = true

    -- cleanup test
end

local callbackTestValue = "some callback data"
local testArgValue20 = 20
local testArgValue222 = 222
local testArgValue44 = 44
local testObj = ObjTest:newInstance("field1", 4)

local compact = { compact = true }

function t_projects.T_StartProject_ASrv()
    -- prepare test
    corelog.WriteToLog("* enterprise_projects.StartProject_ASrv() tests")
    local objLocator = enterprise_test:saveObj(testObj)

    local projectDef = {
        steps   = {
            -- test SSrv
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_test", serviceName = "Test_SSrv" }, stepDataDef = {
                { keyDef = "testArg"        , sourceStep = 0, sourceKeyDef = "testArgSource" },
            }},
            -- test ASrv
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_test", serviceName = "Test_ASrv" }, stepDataDef = {
                { keyDef = "testArg"        , sourceStep = 0, sourceKeyDef = "testArgSource" },
            }, description = "test ASrv"},
            -- test indexed source KeyDef
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_test", serviceName = "Test_SSrv" }, stepDataDef = {
                { keyDef = "testArg"        , sourceStep = 0, sourceKeyDef = "testTableSource.key3.nKey2" },
            }},
            -- test indexed output and source KeyDef
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_test", serviceName = "Test_SSrv" }, stepDataDef = {
                { keyDef = "testArg"        , sourceStep = 0, sourceKeyDef = "testTable4" },
                { keyDef = "testArg.field4" , sourceStep = 0, sourceKeyDef = "testTableSource2.key4" },
            }},
            -- test SOSrv
            { stepType = "SOSrv", stepTypeDef = { className = "ObjTest", serviceName = "test_SOSrv", objStep = 0, objKeyDef = "testObj" }, stepDataDef = {
                { keyDef = "testArg"        , sourceStep = 0, sourceKeyDef = "testArgSource" },
            }},
            -- test AOSrv
            { stepType = "AOSrv", stepTypeDef = { className = "ObjTest", serviceName = "test_AOSrv", objStep = 0, objKeyDef = "testObj" }, stepDataDef = {
                { keyDef = "testArg"        , sourceStep = 0, sourceKeyDef = "testArgSource" },
            }, description = "test AOSrv"},
            -- test located SOSrv
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "test_SOSrv", locatorStep = 0, locatorKeyDef = "objLocator" }, stepDataDef = {
                { keyDef = "testArg"        , sourceStep = 0, sourceKeyDef = "testArgSource" },
            }},
            -- test located AOSrv
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "test_AOSrv", locatorStep = 0, locatorKeyDef = "objLocator" }, stepDataDef = {
                { keyDef = "testArg"        , sourceStep = 0, sourceKeyDef = "testArgSource" },
            }, description = "test located AOSrv"},
            -- test located SMtd
            { stepType = "LSOMtd", stepTypeDef = { methodName = "getTestArg", locatorStep = 0, locatorKeyDef = "objLocator" }, stepDataDef = {
                { keyDef = "testArg"        , sourceStep = 0, sourceKeyDef = "testArgSource" },
            }, description = "test located Sync Obj method"},
        },
        returnData  = {
            { keyDef = "testBArg0"              , sourceStep = 0, sourceKeyDef = "testArgSource" },
            { keyDef = "test_SSrv_BArg"         , sourceStep = 1, sourceKeyDef = "input" },
            { keyDef = "test_ASrv_BArg"         , sourceStep = 2, sourceKeyDef = "input" },
            { keyDef = "test_IndexedSource_BArg", sourceStep = 3, sourceKeyDef = "input" },
            { keyDef = "test_IndexedOutput_BArg", sourceStep = 4, sourceKeyDef = "input" },
            { keyDef = "test_SOSrv_BArg"        , sourceStep = 5, sourceKeyDef = "input" },
            { keyDef = "test_SOSrv_SelfObj"     , sourceStep = 5, sourceKeyDef = "selfObj" },
            { keyDef = "test_AOSrv_BArg"        , sourceStep = 6, sourceKeyDef = "input" },
            { keyDef = "test_AOSrv_SelfObj"     , sourceStep = 6, sourceKeyDef = "selfObj" },
            { keyDef = "test_LSOSrv_BArg"       , sourceStep = 7, sourceKeyDef = "input" },
            { keyDef = "test_LSOSrv_SelfObj"    , sourceStep = 7, sourceKeyDef = "selfObj" },
            { keyDef = "test_LAOSrv_BArg"       , sourceStep = 8, sourceKeyDef = "input" },
            { keyDef = "test_LAOSrv_SelfObj"    , sourceStep = 8, sourceKeyDef = "selfObj" },
        }
    }
    local projectData = {
        testArgSource = testArgValue20,
        testTableSource = {
            key1 = 11,
            key2 = 22,
            key3 = {
                nKey1 = 111,
                nKey2 = testArgValue222,
                nKey3 = 333,
            }
        },
        testTableSource2 = {
            key4 = testArgValue44,
            key5 = 55,
        },
        testTable4 = { },
        testObj = testObj,
        objLocator = objLocator,
    }
    local callback = Callback:newInstance("t_projects", "StartProject_ASrv_Callback", {
        [0]             = callbackTestValue,
        ["hostName"]    = "enterprise_test",
        ["objLocator"]  = objLocator,
    })
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Testing", description = "Start project" },
    }

    -- test
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function t_projects.StartProject_ASrv_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")
    local callbackValue = callbackData[0]
    local expectedCallbackValue = callbackTestValue
    assert(callbackValue == expectedCallbackValue, "gotten callbackValue(="..(callbackValue or "nil")..") not the same as expected(="..expectedCallbackValue..")")

    -- test input projectData is returned
    local testBArg = serviceResults.testBArg0
    local expectedTestBArg = testArgValue20
    assert(testBArg == expectedTestBArg, "gotten testBArg(="..testBArg..") not the same as expected(="..expectedTestBArg..")")

    -- test SSrv (results)
    testBArg = serviceResults.test_SSrv_BArg
    expectedTestBArg = testArgValue20
    assert(testBArg == expectedTestBArg, "gotten testBArg(="..testBArg..") not the same as expected(="..expectedTestBArg..")")

    -- test ASrv (results)
    testBArg = serviceResults.test_ASrv_BArg
    expectedTestBArg = testArgValue20
    assert(testBArg == expectedTestBArg, "gotten testBArg(="..testBArg..") not the same as expected(="..expectedTestBArg..")")

    -- test indexed sourceKey Def (results)
    testBArg = serviceResults.test_IndexedSource_BArg
    expectedTestBArg = testArgValue222
    assert(testBArg == expectedTestBArg, "gotten testBArg(="..testBArg..") not the same as expected(="..expectedTestBArg..")")

    -- test indexed output and source KeyDef (results)
    testBArg = serviceResults.test_IndexedOutput_BArg.field4
    expectedTestBArg = testArgValue44
    assert(testBArg == expectedTestBArg, "gotten testBArg(="..testBArg..") not the same as expected(="..expectedTestBArg..")")

    -- test SOSrv (results)
    testBArg = serviceResults.test_SOSrv_BArg
    expectedTestBArg = testArgValue20
    assert(testBArg == expectedTestBArg, "gotten testBArg(="..testBArg..") not the same as expected(="..expectedTestBArg..")")
    local testObjSelf = serviceResults.test_SOSrv_SelfObj
    testObjSelf = ObjTest:new(testObjSelf)
    assert(Class.IsInstanceOf(testObjSelf, ObjTest), "gotten testObjSelf(="..textutils.serialise(testObjSelf, compact )..") not of type ObjTest")
    assert(testObjSelf:isEqual(testObj), "gotten testObjSelf(="..textutils.serialise(testObjSelf, compact )..") not the same as expected(="..textutils.serialise(testObj, compact )..")")

    -- test AOSrv (results)
    testBArg = serviceResults.test_AOSrv_BArg
    expectedTestBArg = testArgValue20
    assert(testBArg == expectedTestBArg, "gotten testBArg(="..testBArg..") not the same as expected(="..expectedTestBArg..")")
    testObjSelf = serviceResults.test_AOSrv_SelfObj
    testObjSelf = ObjTest:new(testObjSelf)
    assert(Class.IsInstanceOf(testObjSelf, ObjTest), "gotten testObjSelf(="..textutils.serialise(testObjSelf, compact )..") not of type ObjTest")
    assert(testObjSelf:isEqual(testObj), "gotten testObjSelf(="..textutils.serialise(testObjSelf, compact )..") not the same as expected(="..textutils.serialise(testObj, compact )..")")

    -- test located SOSrv (results)
    testBArg = serviceResults.test_LSOSrv_BArg
    expectedTestBArg = testArgValue20
    assert(testBArg == expectedTestBArg, "gotten testBArg(="..testBArg..") not the same as expected(="..expectedTestBArg..")")
    testObjSelf = serviceResults.test_LSOSrv_SelfObj
    testObjSelf = ObjTest:new(testObjSelf)
    assert(Class.IsInstanceOf(testObjSelf, ObjTest), "gotten testObjSelf(="..textutils.serialise(testObjSelf, compact )..") not of type ObjTest")
    assert(testObjSelf:isEqual(testObj), "gotten testObjSelf(="..textutils.serialise(testObjSelf, compact )..") not the same as expected(="..textutils.serialise(testObj, compact )..")")

    -- test located AOSrv (results)
    testBArg = serviceResults.test_LAOSrv_BArg
    expectedTestBArg = testArgValue20
    assert(testBArg == expectedTestBArg, "gotten testBArg(="..testBArg..") not the same as expected(="..expectedTestBArg..")")
    testObjSelf = serviceResults.test_LAOSrv_SelfObj
    testObjSelf = ObjTest:new(testObjSelf)
    assert(Class.IsInstanceOf(testObjSelf, ObjTest), "gotten testObjSelf(="..textutils.serialise(testObjSelf, compact )..") not of type ObjTest")
    assert(testObjSelf:isEqual(testObj), "gotten testObjSelf(="..textutils.serialise(testObjSelf, compact )..") not the same as expected(="..textutils.serialise(testObj, compact )..")")

    -- cleanup test
    local objLocator = callbackData["objLocator"]
    local hostName = callbackData["hostName"]
    local host = Host.GetHost(hostName) if not host then corelog.Error("host not found") return end
    host:deleteResource(objLocator)
end

function t_projects.T_StartProject_ASrv_registersWIP()
    -- prepare test
    corelog.WriteToLog("* enterprise_projects.StartProject_ASrv() registers WIP tests")
    local projectDef = {
        steps   = {
            -- test ASrv
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_test", serviceName = "Test_ASrv" }, stepDataDef = {
                { keyDef = "testArg"        , sourceStep = 0, sourceKeyDef = "testArgSource" },
            }, description = "test wipped ASrv"},
        },
        returnData  = {
        }
    }
    local projectData = {
        testArgSource = testArgValue20,
    }
    local wipId = "myWIPId"
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Testing", description = "Start project registers WIP", wipId = wipId},
    }

    -- test schedule
    local scheduleSuccess = enterprise_projects.StartProject_ASrv(projectServiceData, Callback:GetNewDummyCallBack())
    assert(scheduleSuccess, "failed scheduling async service")

    -- test wipId queue created
    -- note: we rely here on the fact that the async test in the project is picked up with a delay, hence the project has not yet completed, hence the queue is not yet removed
    local wipAdministrator = enterprise_administration:getWIPAdministrator() assert(wipAdministrator)
    local queue = wipAdministrator._wipQueues[wipId]
    assert(queue, "no wipId queue created")

    -- end
    return true
end

function t_projects.T_DeleteProjects()
    -- prepare test
    corelog.WriteToLog("* enterprise_projects.DeleteProjects() test")

    -- test
    enterprise_projects.DeleteProjects()
    local nProjects = enterprise_projects.GetNumberOfProjects_Att()
    local expectedNProjects = 0
    assert(nProjects == expectedNProjects, "gotten nProjects(="..nProjects..") not the same as expected(="..expectedNProjects..")")

    -- cleanup test
end

return t_projects
