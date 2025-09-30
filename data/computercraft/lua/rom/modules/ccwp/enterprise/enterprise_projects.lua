-- define module
local enterprise_projects = {}

--[[
    The projects enterprise offers services to group together multiple enterprise services based on a predefined project definition.

    Currently the project definition can contain a sequence of project steps (each being a service of an enterprise) that need to be executed in sequence.

    ToDo: extend to be able to handle parallel project steps (see also ToDo to test in t_shop.T_OrderItems())

    For another description of this enterprise and it's usage see https://github.com/REReal8/CCWorldPlatform/wiki/enterprise_projects
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"
local coredht = require "coredht"

local InputChecker = require "input_checker"
local MethodExecutor = require "method_executor"
local Callback = require "obj_callback"
local ObjHost = require "obj_host"

local DisplayStation

local enterprise_administration = require "enterprise_administration"

local db = {
    dhtRoot     = "enterprise_projects",
}

--                _     _ _         __                  _   _
--               | |   | (_)       / _|                | | (_)
--    _ __  _   _| |__ | |_  ___  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | '_ \| | | | '_ \| | |/ __| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | |_) | |_| | |_) | | | (__  | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   | .__/ \__,_|_.__/|_|_|\___| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--   | |
--   |_|

function enterprise_projects.StartProject_ASrv(...)
    -- get & check input from description
    local checkSuccess, projectDef, projectData, projectMeta, callback = InputChecker.Check([[
        This async public service starts a project.

        Return value:
                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                - (table)
                success         - (boolean) whether the project was successfully executed
                <other results> - (?) as defined in the project definition

        Parameters:
            serviceData         - (table) data for this service
                projectDef      + (table) definition of the project
                projectData     + (table) input data to the project
                projectMeta     + (table, {}) stuff like title and description, and other meta information
            callback            + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("enterprise_projects.StartProject_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- set metaData defaults  ToDo: consider doing with CheckInput
    if type(projectDef.returnData)  ~= "table" then projectDef.returnData   = {} end

    -- data of the project
    local project   = {
        projectDef          = projectDef,
        projectMeta         = projectMeta,
        callback            = callback,

        projectId           = coreutils.NewId(),

        currentStep         = 0,
        allTrue             = true,                                         -- keeps track weather all steps returned true
        outputs             = {},

        callerFunction      = corelog.FindCaller("enterprise_projects"),    -- for debugging
    }

    -- check if meta data is present
    if not projectMeta.title        then projectMeta.title       = "Untitled"             corelog.WriteToLog("Project has no title!! (project created at "..project.callerFunction..")") end
    if not projectMeta.description  then projectMeta.description = "" end

    -- logging
    corelog.WriteToProjectsLog("Add new", project.projectId)
    corelog.WriteToProjectsLog("project title: ", projectMeta.title)

    -- save
    coredht.SaveData(project, db.dhtRoot, project.projectId)

    -- possibly inform WIPAdministrator
    if type(projectMeta.wipId) == "string" then
        -- get WIPAdministrator
        local wipAdministrator = enterprise_administration:getWIPAdministrator()
        if not wipAdministrator then corelog.Error("enterprise_projects:StartProject_ASrv: Failed obtaining WIPAdministrator") return Callback.ErrorCall(callback) end

        -- administer work started
        wipAdministrator:administerWorkStarted(projectMeta.wipId, "Project "..project.projectId)
    end

    -- let's start
    return enterprise_projects.NextProjectStep({projectId = project.projectId}, projectData) -- the input projectData is interpreted as the result of virtual step 0
end

function enterprise_projects.AreAllTrue_QSrv(serviceData)
    --[[
        This sync public query service returns if all supplied boolean arguments are true.

        It can typically be used as the last step of a sequence of steps in a project description to combine the success results of all steps into one.

        Return value:
                                    - (table)
                success             - (boolean) whether all supplied boolean arguments are true.

        Parameters:
            serviceData             - (table) data of this service
                <boolean argument1> - (boolean) a boolean argument
                <boolean argument2> - (boolean) another boolean argument
                <boolean argumentN> - (boolean) and another boolean argument
                <other argument1>    - (not boolean) a none boolean argument
                <other argumentN>    - (not boolean) another none boolean argument
    ]]

    -- check input
    if type(serviceData) ~= "table" then corelog.Error("enterprise_projects.AreAllTrue_QSrv: Invalid input") return {success = false} end

    corelog.Error("enterprise_projects.AreAllTrue_QSrv: Who is still using this query service?!?")

    -- use remaining input
    local allTrue = true
    for key, serviceArgument in pairs(serviceData) do
        -- check if it's boolean
        if type(serviceArgument) == "boolean" then
            allTrue = allTrue and serviceArgument
        end
    end

    -- end
    return {success = allTrue}
end

local function ResetProjects()
    return coredht.SaveData({}, db.dhtRoot)
end

local function GetProjects()
    -- get items
    local projects = coredht.GetData(db.dhtRoot)
    if not projects or type(projects) ~= "table" then projects = ResetProjects() end

    -- end
    return projects
end

function enterprise_projects.GetNumberOfProjects_Att()
    --[[
        Enterprise attribute: number of projects administered by the enterprise.
    --]]

    -- get projects
    local projects = GetProjects()

    -- loop on items
    local count = 0
    for k, site in pairs(projects) do
        count = count + 1
    end

    return count
end

--    _                 _    __                  _   _
--   | |               | |  / _|                | | (_)
--   | | ___   ___ __ _| | | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | |/ _ \ / __/ _` | | |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | (_) | (_| (_| | | | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_|\___/ \___\__,_|_| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/

function enterprise_projects.DeleteProjects()
    -- get projects
    local projects = GetProjects()

    -- remove all projects
    corelog.WriteToProjectsLog("All projects are being deleted!")
    for projectId, project in pairs(projects) do
        -- remove project
        corelog.WriteToProjectsLog("Deleted", projectId)
        coredht.SaveData(nil, db.dhtRoot, projectId)
    end
end

local function GetFieldValueFromDataUsingKeyDef(data, keyDef)
    -- check input
    local fieldValue = data

    -- loop on indexing
    local indexingPattern = "([%_%w]+)[%.]?"
    for keyName in string.gmatch(keyDef, indexingPattern) do
        if type(keyName) ~= "string" then corelog.Error("enterprise_projects.GetFieldValueFromDataUsingKeyDef: Invalid (type="..type(keyName)..") keyName") return nil end
        if type(fieldValue) ~= "table" then corelog.Error("enterprise_projects.GetFieldValueFromDataUsingKeyDef: Can't index further into fieldValue="..fieldValue.." (type="..type(fieldValue)..")") return nil end
        fieldValue = fieldValue[keyName]
        if type(fieldValue) == "nil" and keyDef ~= "assignmentsPriorityKey" then corelog.Warning("enterprise_projects.GetFieldValueFromDataUsingKeyDef: FieldValue for key "..keyName.." = nil") return nil end
    end

    -- end
    return fieldValue
end

local function SetDataFieldUsingKeyDef(data, keyDef, value)
    --[[
        The intend of this method is to assign value to data indexed by the (keyName) compoments in keyDef, i.e.

        with
            keyDef = "keyName1.keyName2 ... .keyNameN"
        do
            data.keyName1.keyName2 ... .keyNameN = value
        or (equivalently):
            data["keyName1"]["keyName2"] ... ["keyNameN"] = value
    ]]

    -- check input
    if type(data) ~= "table" then corelog.Error("enterprise_projects.SetDataFieldUsingKeyDef: Invalid data") return false end
    if type(keyDef) ~= "string" and keyDef ~= "" then corelog.Error("enterprise_projects.SetDataFieldUsingKeyDef: Invalid keyDef") return false end
    if type(value) == "nil" then corelog.Error("enterprise_projects.SetDataFieldUsingKeyDef: Invalid value (nil)") return false end

--    corelog.WriteToProjectsLog("   stepData = "..textutils.serialize(stepData).."")
--    corelog.WriteToProjectsLog("   keyDef = "..keyDef.."")
--    corelog.WriteToProjectsLog("   fieldValue = "..textutils.serialize(fieldValue).."")

    -- init
    local remainingKeyDef = keyDef
    local lastField = nil
    local lastKeyName = nil
    local indexingPatternB = "^([%_%w]+)[%.]?"

    -- handle (nested) keys
    while remainingKeyDef ~= "" do
        if lastField == nil then
            -- no nested keys =>
            lastField = data
        else
            if type(lastField) ~= "table" then corelog.Error("enterprise_projects.SetDataFieldUsingKeyDef: Invalid lastField (type="..type(lastField)..")") return false end
            lastField = lastField[lastKeyName]
        end

        lastKeyName = string.match(remainingKeyDef, indexingPatternB)
        if type(lastKeyName) ~= "string" then corelog.Error("enterprise_projects.SetDataFieldUsingKeyDef: Invalid lastKeyName (type="..type(lastKeyName)..")") return false end
        remainingKeyDef = string.gsub(remainingKeyDef, indexingPatternB, "", 1)
    end

    -- set value
    if type(lastField) == "nil" then corelog.Error("enterprise_projects.SetDataFieldUsingKeyDef: Invalid lastField (nil)") return false end
    if type(lastKeyName) ~= "string" then corelog.Error("enterprise_projects.SetDataFieldUsingKeyDef: Invalid lastKeyName (type="..type(lastKeyName)..")") return false end
    lastField[lastKeyName] = value

    -- end
--    corelog.WriteToProjectsLog("   stepData = "..textutils.serialize(stepData).." (final)")
    return true
end

local function EndProject(internalProjectData)
    -- get the project informatino
    local project   = coredht.GetData(db.dhtRoot, internalProjectData.projectId)
    if type(project) ~= "table" then corelog.Error("enterprise_projects:EndProject: Failed obtaining project") return false end
    local projectId = internalProjectData.projectId
    local projectMeta = project.projectMeta
    local projectResults = {}
    local projectDef = project.projectDef

    -- create the projectResult
    for iField, fieldDef in ipairs(projectDef.returnData) do
        -- get sourceStepData
        local sourceStep = fieldDef.sourceStep
        local sourceStepData = project.outputs[ sourceStep ]
        if type(sourceStepData) ~= "table" then corelog.Warning("enterprise_projects.EndProject: Invalid sourceStepData for field "..fieldDef.keyDef.." of project"..projectId) break end

        -- get fieldValue
        local fieldValue = GetFieldValueFromDataUsingKeyDef(sourceStepData, fieldDef.sourceKeyDef)
        if type(fieldValue) == "nil" then corelog.Error("enterprise_projects.EndProject: Invalid fieldValue field "..fieldDef.keyDef.." of project"..projectId) break end

        -- add the requested field
        local setSuccess = SetDataFieldUsingKeyDef(projectResults, fieldDef.keyDef, fieldValue)
        if not setSuccess then corelog.Error("enterprise_projects.EndProject: Failed setting resultData field "..fieldDef.keyDef.." of project"..projectId) break end
    end

    -- default success settings
    if projectResults.success == nil then projectResults.success = project.allTrue end

    -- usefull logging
    corelog.WriteToProjectsLog("Project results: "..textutils.serialize(projectResults), project.projectId)

    -- possibly inform WIPAdministrator
    if type(projectMeta.wipId) == "string" then
        -- get WIPAdministrator
        local wipHandler = enterprise_administration:getWIPAdministrator()
        if not wipHandler then corelog.Error("enterprise_projects:EndProject: Failed obtaining WIPAdministrator") return false end

        -- administer work completed
        wipHandler:administerWorkCompleted(projectMeta.wipId, "Project "..projectId)
    end

    -- we are done, do the callback
    corelog.WriteToProjectsLog("Calling callback function", project.projectId)
    local callback = Callback:new(project.callback)
    if not callback then corelog.Error("enterprise_projects.EndProject: Invalid callback for project "..projectId) return false end
    local projectEndCallBackResult = callback:call(projectResults)

    -- forget about this project
    corelog.WriteToProjectsLog("Ended", project.projectId)
    coredht.SaveData(nil, db.dhtRoot, internalProjectData.projectId)

    -- end
    return projectEndCallBackResult
end

local function TerminateProject(internalProjectData)
    local project   = coredht.GetData(db.dhtRoot, internalProjectData.projectId)
    if type(project) ~= "table" then corelog.Error("enterprise_projects.TerminateProject: Invalid/ no project retrieved from "..internalProjectData.projectId) return nil end

    corelog.WriteToProjectsLog("Warning!: Early Termination", project.projectId)
    corelog.Error("Early Termination of project "..project.projectId)
    corelog.Error("   internalProjectData="..textutils.serialize(project))

    return EndProject(internalProjectData)
end

local function GetStepData(project, stepDataDef)
    local projectId = project.projectId
    local stepData = {}
    for iField, fieldDef in ipairs(stepDataDef) do
        -- get sourceStepData
        local sourceStep = fieldDef.sourceStep
        local sourceStepData = project.outputs[ sourceStep ]
        if type(sourceStepData) ~= "table" then corelog.Error("enterprise_projects.GetStepData: Invalid sourceStepData ("..type(sourceStepData)..") for field "..fieldDef.keyDef.." of project"..projectId) return nil end

        -- get fieldValue
        local fieldValue = GetFieldValueFromDataUsingKeyDef(sourceStepData, fieldDef.sourceKeyDef)
        if type(fieldValue) == "nil" then
            if fieldDef.keyDef ~= "assignmentsPriorityKey" then corelog.Warning("enterprise_projects.GetStepData: FieldValue for field "..fieldDef.keyDef.." = nil of project"..projectId) end
        else
            -- add field
            local setSuccess = SetDataFieldUsingKeyDef(stepData, fieldDef.keyDef, fieldValue)
            if not setSuccess then corelog.Error("enterprise_projects.GetStepData: Failed setting stepData for field "..fieldDef.keyDef.." of project"..projectId) return nil end
        end
    end

    -- end
    return stepData
end

function enterprise_projects.NextProjectStep(internalProjectData, stepResults)
    --[[
        This method performs a project step.

        Return value:
                                - (boolean) whether the project step was scheduled successfully

        Parameters:
            internalProjectData - (table) <properly describe>
            stepResults         - (table) <properly describe>
    ]]

    -- get the project information
    local projectId = internalProjectData.projectId
    local project   = coredht.GetData(db.dhtRoot, projectId)
    if type(project) ~= "table" then corelog.Error("enterprise_projects.NextProjectStep: Invalid/ no project retrieved from "..projectId) TerminateProject(internalProjectData) return false end

    -- check results of the previous step
    local previousStep = project.currentStep
    if type(stepResults) ~= "table" then corelog.Warning("enterprise_projects.NextProjectStep: no stepResults from step "..previousStep.." of project"..projectId) stepResults = {} end
    if previousStep > 0 and not stepResults.success then corelog.Warning("enterprise_projects.NextProjectStep: step "..previousStep.." of project"..projectId.." did not return success! This project was created by "..(project.callerFunction or "unknown")) end
    -- ToDo: consider TerminateProject in both of above cases

    -- update all true
    if previousStep > 0 then project.allTrue = project.allTrue and stepResults.success end

    -- save the results of the previous step
--    corelog.WriteToProjectsLog("Save results step "..previousStep..": "..textutils.serialize(stepResults), projectId)
    corelog.WriteToProjectsLog("Save results step "..previousStep, projectId)
    project.outputs[ previousStep ] = stepResults

    -- was this the last step?
    if #project.projectDef.steps == previousStep then
        DisplayStation = DisplayStation or require "mobj_display_station"
        DisplayStation.SetStatus("project", project.projectMeta.title, "Project completed") return EndProject(internalProjectData)
    end

    -- next step
    project.currentStep = previousStep + 1
    local currentStep = project.currentStep

    -- save to dht
    coredht.SaveData(project, db.dhtRoot, projectId)

    -- get new step
    local step = project.projectDef.steps[ currentStep ]

    -- get stepType & stepTypeDef
    local stepType = step.stepType
    if type(stepType) ~= "string" then corelog.Error("enterprise_projects.NextProjectStep: Invalid stepType "..type(stepType).." for step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false end
    local stepTypeDef = step.stepTypeDef
    if type(stepTypeDef) ~= "table" then corelog.Error("enterprise_projects.NextProjectStep: Invalid stepTypeDef "..type(stepTypeDef).." for step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false end

    -- prepare stepData
    local stepData = GetStepData(project, step.stepDataDef)
    if not stepData then corelog.Error("enterprise_projects.NextProjectStep: Failed obtaining stepData for step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false end

    -- update status before doing the step
    local stepDesc  = "Stepname: (todo)"
    if type(step.description) == "string" then
        -- set the stepname for the status update
        stepDesc = step.description

        -- write to project log file
        corelog.WriteToProjectsLog("Starting step with description '"..stepDesc.."'", projectId)
        corelog.WriteToLog("Starting step '"..step.description.."' (project "..projectId..")")
    end

    -- update the status
    DisplayStation = DisplayStation or require "mobj_display_station"
    DisplayStation.SetStatus("project", project.projectMeta.title, "Doing step "..project.currentStep.." of "..#project.projectDef.steps, stepDesc)

    -- select and do stepType
    if stepType == "ASrv" then
        -- get & check input from description
        local checkSuccess, moduleName, serviceName = InputChecker.Check([[
            Parameters:
                stepTypeDef             - (table)
                    moduleName          + (string)
                    serviceName         + (string)
        --]], stepTypeDef)
        if not checkSuccess then corelog.Error("enterprise_projects.NextProjectStep: Failed obtaining ASrv stepTypeDef fields for step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false end

        --
        local callback = Callback:newInstance("enterprise_projects", "NextProjectStep", internalProjectData)

        -- do service
        corelog.WriteToProjectsLog("Start step "..currentStep.." async module service", projectId)
        local scheduledCorrectly = MethodExecutor.DoASyncService(moduleName, serviceName, stepData, callback)
        if scheduledCorrectly ~= true then corelog.Error("enterprise_projects.NextProjectStep: Failed scheduling ("..type(scheduledCorrectly)..") ASrv service "..moduleName.."."..serviceName.." for step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false end
        return scheduledCorrectly
    elseif stepType == "SSrv" then
        -- get & check input from description
        local checkSuccess, moduleName, serviceName = InputChecker.Check([[
            Parameters:
                stepTypeDef             - (table)
                    moduleName          + (string)
                    serviceName         + (string)
        --]], stepTypeDef)
        if not checkSuccess then corelog.Error("enterprise_projects.NextProjectStep: Failed obtaining SSrv stepTypeDef fields for step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false end

        -- do service, keep the results
        corelog.WriteToProjectsLog("Start step "..currentStep.." sync module service", projectId)
        local results = MethodExecutor.DoSyncService(moduleName, serviceName, stepData)

        -- next step
        return enterprise_projects.NextProjectStep(internalProjectData, results)
    elseif stepType == "AOSrv" then
        -- get & check input from description
        local checkSuccess, className, serviceName, objStep, objKeyDef = InputChecker.Check([[
            Parameters:
                stepTypeDef             - (table)
                    className           + (string)
                    serviceName         + (string)
                    objStep             + (number)
                    objKeyDef           + (string)
        --]], stepTypeDef)
        if not checkSuccess then corelog.Error("enterprise_projects.NextProjectStep: Failed obtaining AOSrv stepTypeDef fields for step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false end

        -- get sourceStepData
        local sourceStepData = project.outputs[ objStep ]
        if type(sourceStepData) ~= "table" then corelog.Error("enterprise_projects.NextProjectStep: Invalid sourceStepData for obj of step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false end

        -- get objData
        local objData = GetFieldValueFromDataUsingKeyDef(sourceStepData, objKeyDef)
        if type(objData) ~= "table" then corelog.Error("enterprise_projects.NextProjectStep: Invalid objData field "..objKeyDef.." of project"..projectId) TerminateProject(internalProjectData) return false end

        --
        local callback = Callback:newInstance("enterprise_projects", "NextProjectStep", internalProjectData)

        -- do service
        corelog.WriteToProjectsLog("Start step "..currentStep.." async Obj service", projectId)
        local scheduledCorrectly = MethodExecutor.DoASyncObjService(className, objData, serviceName, stepData, callback)
        if scheduledCorrectly ~= true then corelog.Error("enterprise_projects.NextProjectStep: Failed scheduling ("..type(scheduledCorrectly)..") AOSrv service "..className..":"..serviceName.." for step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false end
        return scheduledCorrectly
    elseif stepType == "LAOSrv" then
        -- get & check input from description
        local checkSuccess, serviceName, locatorStep, locatorKeyDef = InputChecker.Check([[
            Parameters:
                stepTypeDef             - (table)
                    serviceName         + (string)
                    locatorStep         + (number)
                    locatorKeyDef       + (string)
        --]], stepTypeDef)
        if not checkSuccess then corelog.Error("enterprise_projects.NextProjectStep: Failed obtaining LAOSrv stepTypeDef fields for step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false end

        -- get sourceStepData
        local sourceStepData = project.outputs[ locatorStep ]
        if type(sourceStepData) ~= "table" then corelog.Error("enterprise_projects.NextProjectStep: Invalid sourceStepData for obj of step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false end

        -- get objLocator
        local objLocator = GetFieldValueFromDataUsingKeyDef(sourceStepData, locatorKeyDef)
        if type(objLocator) ~= "table" then corelog.Error("enterprise_projects.NextProjectStep: Invalid objLocator field "..locatorKeyDef.." of project"..projectId) TerminateProject(internalProjectData) return false end

        -- get Obj
        local obj = ObjHost.GetObj(objLocator)
        if type(obj) ~= "table" then corelog.Error("enterprise_projects.NextProjectStep: Obj "..objLocator:getURI().." not found.") TerminateProject(internalProjectData) return false end

        --
        local callback = Callback:newInstance("enterprise_projects", "NextProjectStep", internalProjectData)

        -- do service
        corelog.WriteToProjectsLog("Start step "..currentStep.." located async Obj service", projectId)
        local scheduledCorrectly = MethodExecutor.CallInstanceMethod(obj, serviceName, { stepData, callback })
        local className = obj:getClassName()
        if scheduledCorrectly ~= true then corelog.Error("enterprise_projects.NextProjectStep: Failed scheduling ("..type(scheduledCorrectly)..") LAOSrv service "..className..":"..serviceName.." for step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false end
        return scheduledCorrectly
    elseif stepType == "SOSrv" then
        -- get & check input from description
        local checkSuccess, className, serviceName, objStep, objKeyDef = InputChecker.Check([[
            Parameters:
                stepTypeDef             - (table)
                    className           + (string)
                    serviceName         + (string)
                    objStep             + (number)
                    objKeyDef           + (string)
        --]], stepTypeDef)
        if not checkSuccess then corelog.Error("enterprise_projects.NextProjectStep: Failed obtaining SOSrv stepTypeDef fields for step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false end

        -- get sourceStepData
        local sourceStepData = project.outputs[ objStep ]
        if type(sourceStepData) ~= "table" then corelog.Error("enterprise_projects.NextProjectStep: Invalid sourceStepData for obj of step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false end

        -- get objData
        local objData = GetFieldValueFromDataUsingKeyDef(sourceStepData, objKeyDef)
        if type(objData) ~= "table" then corelog.Error("enterprise_projects.NextProjectStep: Invalid objData field "..objKeyDef.." of project"..projectId) TerminateProject(internalProjectData) return false end

        -- do service, keep the results
        corelog.WriteToProjectsLog("Start step "..currentStep.." sync Obj service", projectId)
        local results = MethodExecutor.DoSyncObjService(className, objData, serviceName, stepData)

        -- next step
        return enterprise_projects.NextProjectStep(internalProjectData, results)
    elseif stepType == "LSOSrv" then
        -- get & check input from description
        local checkSuccess, serviceName, locatorStep, locatorKeyDef = InputChecker.Check([[
            Parameters:
                stepTypeDef             - (table)
                    serviceName         + (string)
                    locatorStep         + (number)
                    locatorKeyDef       + (string)
        --]], stepTypeDef)
        if not checkSuccess then corelog.Error("enterprise_projects.NextProjectStep: Failed obtaining LSOSrv stepTypeDef fields for step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false end

        -- get sourceStepData
        local sourceStepData = project.outputs[ locatorStep ]
        if type(sourceStepData) ~= "table" then corelog.Error("enterprise_projects.NextProjectStep: Invalid sourceStepData for obj of step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false end

        -- get objLocator
        local objLocator = GetFieldValueFromDataUsingKeyDef(sourceStepData, locatorKeyDef)
        if type(objLocator) ~= "table" then corelog.Error("enterprise_projects.NextProjectStep: Invalid objLocator field "..locatorKeyDef.." of project"..projectId) TerminateProject(internalProjectData) return false end

        -- get Obj
        local obj = ObjHost.GetObj(objLocator)
        if type(obj) ~= "table" then corelog.Error("enterprise_projects.NextProjectStep: Obj "..objLocator:getURI().." not found.") TerminateProject(internalProjectData) return false end

        -- do service, keep the results
        corelog.WriteToProjectsLog("Start step "..currentStep.." located sync Obj service", projectId)
        local results = MethodExecutor.CallInstanceMethod(obj, serviceName, { stepData })

        -- next step
        return enterprise_projects.NextProjectStep(internalProjectData, results)
    elseif stepType == "LSOMtd" then
        -- get & check input from description
        local checkSuccess, methodName, locatorStep, locatorKeyDef = InputChecker.Check([[
            Parameters:
                stepTypeDef             - (table)
                    methodName          + (string)
                    locatorStep         + (number)
                    locatorKeyDef       + (string)
        --]], stepTypeDef)
        if not checkSuccess then corelog.Error("enterprise_projects.NextProjectStep: Failed obtaining stepTypeDef fields for LSOMtd step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false end

        -- get sourceStepData
        local sourceStepData = project.outputs[ locatorStep ]
        if type(sourceStepData) ~= "table" then corelog.Error("enterprise_projects.NextProjectStep: Invalid sourceStepData for locator of LSOMtd step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false end

        -- get objLocator
        local objLocator = GetFieldValueFromDataUsingKeyDef(sourceStepData, locatorKeyDef)
        if type(objLocator) ~= "table" then corelog.Error("enterprise_projects.NextProjectStep: Invalid objLocator field "..locatorKeyDef.." of project"..projectId) TerminateProject(internalProjectData) return false end

        -- get Obj
        local obj = ObjHost.GetObj(objLocator)
        if type(obj) ~= "table" then corelog.Error("enterprise_projects.NextProjectStep: Obj "..objLocator:getURI().." not found.") TerminateProject(internalProjectData) return false end

        -- get method
        local method = obj[methodName]
        if not method then corelog.Warning("enterprise_projects.NextProjectStep: Method "..methodName.." not found in Obj "..textutils.serialise(obj, {compact = true})) TerminateProject(internalProjectData) return false end

        -- do method
        corelog.WriteToProjectsLog("Start step "..currentStep.." located sync Obj method", projectId)
        local methodResults = method(obj, stepData)

        -- wrap results to make it act as a service
        local results = {
            success         = type(methodResults) ~= "nil",
            methodResults   = methodResults,
        }

        -- next step
        return enterprise_projects.NextProjectStep(internalProjectData, results)
    else
        corelog.Error("enterprise_projects.NextProjectStep: Unkown stepType "..stepType.." for step "..currentStep.." of project"..projectId) TerminateProject(internalProjectData) return false
    end
end

return enterprise_projects
