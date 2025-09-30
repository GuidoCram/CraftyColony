local t_assignmentboard = {}

local corelog = require "corelog"
local coreutils = require "coreutils"
local coredht = require "coredht"

local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local Location = require "obj_location"

local enterprise_assignmentboard = require "enterprise_assignmentboard"

function t_assignmentboard.T_All()
    t_assignmentboard.T_MetaDataConditionsMet()
    t_assignmentboard.T_BestCandidate()
--    t_assignmentboard.T_GetStatistics_Att() -- ToDo: fix side-effects of this test (now all currently present (test) assignments are deleted)
    t_assignmentboard.T_DoAssignment_ASrv()
    t_assignmentboard.T_De_ScheduleTrigger_SSrv()
end

local logOk = false
local testClassName = "enterprise_assignmentboard"

local compact = { compact = true }

function t_assignmentboard.End(assignmentId)
    enterprise_assignmentboard.EndAssignment(assignmentId)
end

function t_assignmentboard.T_EndAssignments()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..".EndAssignments() tests")

    -- test
    enterprise_assignmentboard.EndAssignments()

    -- cleanup test
end

function t_assignmentboard.T_MetaDataConditionsMet()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..".MetaDataConditionsMet() tests")
    local now = coreutils.UniversalTime()
    local workerId = os.getComputerID()
    local metaData = {
        startTime = now,
        needTurtle = false,
        needWorkerId = workerId,
        needTool = false,
        fuelNeeded = 0,
        itemsNeeded = {},
        location = nil,
    }
    local assignmentFilter = {
        priorityKeyNeeded   = "",
    }
    local workerResume = {
        workerId = workerId
    }

    -- test startTime
    corelog.WriteToLog("  # Test startTime condition")
    metaData.startTime = now + 1000
    local conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    local expectedconditionsMet = false
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.startTime = now

    -- test priorityKeyNeeded
    corelog.WriteToLog("  # Test priorityKeyNeeded (nil)")
    assignmentFilter.priorityKeyNeeded = nil
    local priorityKey = coreutils.NewId()
    metaData.priorityKey = priorityKey
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    expectedconditionsMet = true
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.priorityKey = ""

    corelog.WriteToLog("  # Test priorityKeyNeeded (not set)")
    priorityKey = coreutils.NewId()
    metaData.priorityKey = priorityKey
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    expectedconditionsMet = true
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.priorityKey = ""

    corelog.WriteToLog("  # Test priorityKeyNeeded (set, no key)")
    assignmentFilter.priorityKeyNeeded = priorityKey
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    expectedconditionsMet = false
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.priorityKey = ""

    corelog.WriteToLog("  # Test priorityKeyNeeded (set, same key)")
    metaData.priorityKey = priorityKey
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    expectedconditionsMet = true
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.priorityKey = ""

    corelog.WriteToLog("  # Test priorityKeyNeeded (set, other key)")
    local otherPriorityKey = coreutils.NewId()
    metaData.priorityKey = otherPriorityKey
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    expectedconditionsMet = false
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.priorityKey = ""
    assignmentFilter.priorityKeyNeeded = ""

    -- test needWorkerId
    corelog.WriteToLog("  # Test needWorkerId (other workerId)")
    metaData.needWorkerId = workerId + 1000
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    expectedconditionsMet = false
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.needWorkerId = workerId

    corelog.WriteToLog("  # Test needWorkerId (current workerId)")
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    expectedconditionsMet = true
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.needWorkerId = nil

    -- test needTurtle
    corelog.WriteToLog("  # Test needTurtle (is not a Turtle)")
    metaData.needTurtle = true
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    expectedconditionsMet = false
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")

    corelog.WriteToLog("  # Test needTurtle (is Turtle)")
    workerResume.isTurtle = true
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    expectedconditionsMet = true
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")

    -- test fuelNeeded
    -- ToDo: consider also testing with workerResume.location
    corelog.WriteToLog("  # Test fuelNeeded (not enough)")
    workerResume.fuelLevel = 100
    metaData.fuelNeeded = 10000
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    expectedconditionsMet = false
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")

    corelog.WriteToLog("  # Test fuelNeeded (enough)")
    metaData.fuelNeeded = workerResume.fuelLevel - 10
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    expectedconditionsMet = true
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")

    -- test need pickaxe
    corelog.WriteToLog("  # Test need pickaxe (not needed)")
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    expectedconditionsMet = true
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")

    corelog.WriteToLog("  # Test need pickaxe (not present)")
    workerResume.axePresent = false
    metaData.needTool = true
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    expectedconditionsMet = false
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")

    corelog.WriteToLog("  # Test need pickaxe (present)")
    workerResume.axePresent = true
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    expectedconditionsMet = true
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.needTool = false

    -- test itemsNeeded
    corelog.WriteToLog("  # Test itemsNeeded (empty inventory)")
    workerResume.inventoryItems = {}
    local itemsNeeded = {
        ["minecraft:torch"] = 10,
        ["minecraft:chest"] = 1,
    }
    metaData.itemsNeeded = itemsNeeded
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    expectedconditionsMet = false
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")

    corelog.WriteToLog("  # Test itemsNeeded (some in inventory)")
    workerResume.inventoryItems = {
        ["minecraft:torch"] = 20,
    }
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    expectedconditionsMet = false
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")

    corelog.WriteToLog("  # Test itemsNeeded (all in inventory)")
    workerResume.inventoryItems = {
        ["minecraft:torch"] = 20,
        ["minecraft:chest"] = 2,
    }
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    expectedconditionsMet = true
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.itemsNeeded = {}

    -- test other conditions
    corelog.WriteToLog("  # Test Other conditions")
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    if not conditionsMet then
        corelog.WriteToLog("    condition not met: "..skipReason)
    else
        corelog.WriteToLog("    conditions met")
    end

    -- cleanup test
end

function t_assignmentboard.T_BestCandidate()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..".BestCandidate() tests")
    -- init candidate 1
    local now = coreutils.UniversalTime()
    local metaData1 = {
        startTime = now,
        needTurtle = true,
        needWorkerId = nil,
        needTool = true,
        fuelNeeded = 0,
        itemsNeeded = {},
        location = nil,
    }
    local assignmentId1  = coreutils.NewId()
    local candidateData1 = {
        id = assignmentId1,
        metaData = metaData1,
    }

    -- init candidate 2
    local metaData2 = {
        startTime = now,
        needTurtle = true,
        needWorkerId = nil,
        needTool = true,
        fuelNeeded = 0,
        itemsNeeded = {},
        location = nil,
    }
    local assignmentId2  = coreutils.NewId()
    local candidateData2 = {
        id = assignmentId2,
        metaData = metaData2,
    }

    -- test needWorkerId
    corelog.WriteToLog("  # Test needWorkerId is the preferred candidate")
    local currentWorkerId = os.getComputerID()
    candidateData2.metaData.needWorkerId = currentWorkerId
    local bestCandidate = enterprise_assignmentboard.BestCandidate(candidateData1, candidateData2)
    assert(bestCandidate == candidateData2, "gotten BestCandidate(="..textutils.serialize(bestCandidate, compact)..") not the same as expected(="..textutils.serialize(candidateData2, compact)..")")
    candidateData2.metaData.needWorkerId = nil

    -- test startTime
    corelog.WriteToLog("  # Test oldest startTime is the preferred candidate")
    candidateData1.metaData.startTime = now + 10
    bestCandidate = enterprise_assignmentboard.BestCandidate(candidateData1, candidateData2)
    assert(bestCandidate == candidateData2, "gotten BestCandidate(="..textutils.serialize(bestCandidate, compact)..") not the same as expected(="..textutils.serialize(candidateData2, compact)..")")
    candidateData1.metaData.startTime = now

    candidateData2.metaData.startTime = now + 10
    bestCandidate = enterprise_assignmentboard.BestCandidate(candidateData1, candidateData2)
    assert(bestCandidate == candidateData1, "gotten BestCandidate(="..textutils.serialize(bestCandidate, compact)..") not the same as expected(="..textutils.serialize(candidateData1, compact)..")")
    candidateData2.metaData.startTime = now

    -- cleanup test
end

function t_assignmentboard.T_GetStatistics_Att()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..".GetStatistics_Att() test")
    enterprise_assignmentboard.Reset()

    -- test
    local statistics = enterprise_assignmentboard.GetStatistics_Att()
    local maxFuelNeed_Assignment = statistics.maxFuelNeed_Assignment
    local expectedFuelNeed = 0
--    corelog.WriteToLog("   "..maxFuelNeed_Assignment.." maxFuelNeed_Assignment")
    assert(maxFuelNeed_Assignment == expectedFuelNeed, "gotten maxFuelNeed_Assignment(="..maxFuelNeed_Assignment..") not the same as expected(="..expectedFuelNeed..")")
    local maxFuelNeed_Travel = statistics.maxFuelNeed_Travel
    expectedFuelNeed = 0
--    corelog.WriteToLog("   "..maxFuelNeed_Travel.." maxFuelNeed_Travel")
    assert(maxFuelNeed_Travel == expectedFuelNeed, "gotten maxFuelNeed_Travel(="..maxFuelNeed_Travel..") not the same as expected(="..expectedFuelNeed..")")

    -- cleanup test
end

local testValue = 20
local callbackTestValue = "some callback data"

function t_assignmentboard.T_DoAssignment_ASrv()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..".DoAssignment_ASrv() tests")

    -- create assignment arguments
    local taskData = {
        arg1 = testValue
    }
    local metaData = {
        startTime = coreutils.UniversalTime(),
        location = Location:newInstance(0, 0, 1, 0, 1),
        needTool = false,
        needTurtle = false,
        fuelNeeded = 0
    }
    local taskCall = TaskCall:newInstance("role_test", "Func1_Task", taskData)
    local callback = Callback:newInstance("t_assignmentboard", "DoAssignment_ASrv_Callback", { [0] = callbackTestValue })
    local assignmentServiceData = {
        metaData    = metaData,
        taskCall    = taskCall,
    }

    -- test
    corelog.WriteToLog(">starting task "..textutils.serialize(taskCall, { compact = true }))
    local result = enterprise_assignmentboard.DoAssignment_ASrv(assignmentServiceData, callback)
    assert(result == true, "failed scheduling assignment")

    -- cleanup test
end

local triggerIdDHTName = "test t_assignmentboard.T_De_ScheduleTrigger_SSrv triggerId"
local triggerCountDHTName = "test t_assignmentboard.T_De_ScheduleTrigger_SSrv triggerCount"

function t_assignmentboard.IncreaseTriggerCount()
    local triggerId = coredht.GetData(triggerIdDHTName)
    local triggerCount = coredht.GetData(triggerCountDHTName)

    triggerCount = triggerCount + 1
    corelog.WriteToLog("t_assignmentboard.IncreaseTriggerCount: workerId="..os.getComputerID()..", triggerId="..triggerId..", time="..coreutils.UniversalTime()..", triggerCount="..triggerCount)

    coredht.SaveData(triggerCount, triggerCountDHTName)

    -- add this if we want to simulate a tooooo long trigger
    -- os.sleep(0.20)

    -- end
    return {
        success = true,
    }
end

function t_assignmentboard.T_De_ScheduleTrigger_SSrv()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..".ScheduleTrigger_SSrv() + DescheduleTrigger tests")
    coredht.SaveData("", triggerIdDHTName)
    coredht.SaveData(0, triggerCountDHTName)
    local periodTime = 3 -- seconds (should be bigger than maxApplyRoundtripTime)
    local maxApplyRoundtripTime = 2 -- seconds
    local triggerCountMin = 2
    -- corelog.WriteToLog("triggerCountMin="..triggerCountMin)
    local metaData = {
        periodTime = periodTime,
    }
    local taskCall = TaskCall:newInstance("t_assignmentboard", "IncreaseTriggerCount", {} )

    -- test schedule
    local result = enterprise_assignmentboard.ScheduleTrigger_SSrv({
        metaData    = metaData,
        taskCall    = taskCall,
    })
    assert(result.success == true, "Failed scheduling trigger")
    local triggerId = result.triggerId
    assert(type(result.triggerId) == "string", "triggerId (type="..type(result.triggerId)..") not a string")
    coredht.SaveData(triggerId, triggerIdDHTName)

    -- wait a bit
    local waitAfterSchedule = (maxApplyRoundtripTime + periodTime)*triggerCountMin -- seconds
    -- corelog.WriteToLog("sleep "..waitAfterSchedule.."sec")
    os.sleep(waitAfterSchedule)

    -- check: enough times called
    local triggerCount = coredht.GetData(triggerCountDHTName)
    assert(triggerCount >= triggerCountMin, "Trigger "..triggerId.." was only called "..triggerCount.." times")

    -- test deschedule
    enterprise_assignmentboard.DescheduleTrigger(triggerId)
    coredht.SaveData(0, triggerCountDHTName)

    -- wait a bit more
    local waitAfterDeschedule = maxApplyRoundtripTime -- seconds
    -- corelog.WriteToLog("sleep "..waitAfterDeschedule.."sec")
    os.sleep(waitAfterDeschedule)

    -- check: not anymore called
    triggerCount = coredht.GetData(triggerCountDHTName)
    assert(triggerCount == 0, "Trigger "..triggerId.." was called "..triggerCount.." times (while we expected 0)")

    -- cleanup test
    if logOk then corelog.WriteToLog(" ok") end
    coredht.SaveData(nil, triggerIdDHTName)
    coredht.SaveData(nil, triggerCountDHTName)
end

function t_assignmentboard.DoAssignment_ASrv_Callback(callbackData, taskResults)
    -- test (cont)
    assert(taskResults.success, "failed executing async service")
    local arg1 = taskResults.input
    local expectedArg1 = testValue
    assert(arg1 == expectedArg1, "gotten arg1(="..arg1..") not the same as expected(="..expectedArg1..")")
    local callbackValue = callbackData[0]
    local expectedCallbackValue = callbackTestValue
    assert(callbackValue == expectedCallbackValue, "gotten callbackValue(="..(callbackValue or "nil")..") not the same as expected(="..expectedCallbackValue..")")

    -- cleanup test
end

return t_assignmentboard
