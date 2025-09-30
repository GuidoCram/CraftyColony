-- define class
local Class = require "class"
local MObjHost = require "mobj_host"
local IRegistry = require "i_registry"
local enterprise_employment = Class.NewClass(MObjHost, IRegistry)

--[[
    The enterprise_employment is a MObjHost. It hosts Worker's that can perform work (i.e. assignments).
--]]

local coresystem = require "coresystem"
local coreutils = require "coreutils"
local corelog = require "corelog"
local coredisplay = require "coredisplay"
local coremove = require "coremove"

local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local InputChecker = require "input_checker"
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()
local ObjLocator = require "obj_locator"
local ObjHost = require "obj_host"
local Location  = require "obj_location"

local LObjLocator = require "lobj_locator"

local IMObj = require "i_mobj"
local IWorker = require "i_worker"
local Settlement = require "settlement"
local Turtle = require "mobj_turtle"
local UserStation = require "mobj_user_station"
local DisplayStation = require "mobj_display_station"

local role_interactor = require "role_interactor"

local enterprise_assignmentboard = require "enterprise_assignmentboard"
local enterprise_energy = require "enterprise_energy"
local enterprise_projects = require "enterprise_projects"
local enterprise_colonization

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

-- note: currently enterprise is treated like a singleton, but by directly using the name of the module
-- ToDo: consider making changes to enterprise to
--          - explicitly make it a singleton (by construction with :newInstance(hostName) and using the singleton pattern)
--          - properly initialise it (by adding and implementing the _init method)
--          - adopt other classes to these changes
enterprise_employment._hostName   = "enterprise_employment"

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function enterprise_employment:getClassName()
    return "enterprise_employment"
end

--     ____  _     _ _    _           _
--    / __ \| |   (_) |  | |         | |
--   | |  | | |__  _| |__| | ___  ___| |_
--   | |  | | '_ \| |  __  |/ _ \/ __| __|
--   | |__| | |_) | | |  | | (_) \__ \ |_
--    \____/|_.__/| |_|  |_|\___/|___/\__|
--               _/ |
--              |__/

-- ToDo: investigate if we can do this differently. Now we force to a specific Turtle here. But we do not take into account if the Turtle is actually available to take on Work.
--       Could we somehow have anyTurtle resolved in assignments?
local function GetATurtle(employmentHost)
    -- get all Turtles
    local turtles = enterprise_employment:getObjects(Turtle:getClassName())
    if not turtles then corelog.Error("enterprise_employment:GetATurtle: Failed obtaining Turtle's") return nil end

    -- try find a Turtle
    local turtleObj = nil
    -- are we (the Worker running this code) a Turtle?
    if turtle then
        -- get currentTurtleLocator
        local workerId = os.getComputerID()
        local currentTurtleLocator = employmentHost:getRegistered(workerId)
        if not currentTurtleLocator then corelog.Warning("enterprise_employment.GetATurtle: workerLocator for (current) Turtle "..workerId.." not found") return nil end

        -- get turtleObj
        turtleObj = ObjHost.getObj(employmentHost, currentTurtleLocator) -- note base class ObjHost provides the object
    else
        -- select first Turtle
        local _, turtleObjTable = next(turtles) -- first Turtle
        if not turtleObjTable then corelog.Error("enterprise_employment.GetATurtle: Failed obtaining a Turtle") return nil end
        turtleObj = objectFactory:create(Turtle:getClassName(), turtleObjTable) if not turtleObj then corelog.Error("enterprise_employment:GetATurtle: failed converting Turtle objTable to Turtle") return nil end
    end

    -- end
    return turtleObj
end

function enterprise_employment:getObj(...)
    -- get & check input from description
    local checkSuccess, objLocator = InputChecker.Check([[
        This method retrieves an Obj from the ObjHost using a ObjLocator.

        Return value:
            obj                     - (Obj) Obj obtained from the ObjHost

        Parameters:
            objectLocator           + (ObjLocator) locator of the Obj within the ObjHost
    ]], ...)
    if not checkSuccess then corelog.Error("enterprise_employment:getObj: Invalid input") return nil end

    -- check for "any turtle"
    if objLocator:sameBase(enterprise_employment.GetAnyTurtleLocator()) then
        -- ToDo: consider adjusting calling code/ project logic to select a specific Turtle as late as possible, as we probably now fix a Turtle to specific work

        -- get a Turtle
        local turtleObj = GetATurtle(enterprise_employment)

        -- return Turtle
        -- corelog.WriteToLog("Selected Turtle "..turtleObj:getWorkerId().." as 'any Turtle'")
        return turtleObj
    end

    -- have base class ObjHost provide the object
    return ObjHost.getObj(self, objLocator)
end

--   __          __        _
--   \ \        / /       | |
--    \ \  /\  / /__  _ __| | _____ _ __
--     \ \/  \/ / _ \| '__| |/ / _ \ '__|
--      \  /\  / (_) | |  |   <  __/ |
--       \/  \/ \___/|_|  |_|\_\___|_|

local function GetContainer(employmentHost, containerClassName, refName)
    -- get containerLocator
    local containerLocator = ObjLocator:newInstance(employmentHost:getClassName(), containerClassName, refName)
    if not containerLocator then corelog.Error("enterprise_employment.GetContainer: Failed obtaining containerLocator") return nil end

    -- get container
    local containerTable = employmentHost:getResource(containerLocator)
    if not containerTable then
        corelog.WriteToLog("enterprise_employment.GetContainer: Creating new "..containerClassName.." "..refName)

        -- get containerClass
        local containerClass = objectFactory:getClass(containerClassName)
        if not containerClass then corelog.Error("enterprise_employment.GetContainer: Class "..containerClassName.." not found in objectFactory") return nil end

        -- (re)set container
        local container = containerClass:newInstance(ObjLocator:getClassName())
        employmentHost:saveObj(container, refName)

        -- retrieve again
        containerTable = employmentHost:getResource(containerLocator)
        if not containerTable then corelog.Error("enterprise_employment.GetContainer: Failed (re)setting container") return nil end
    end

    -- convert to container
    local container = objectFactory:create(containerClassName, containerTable)
    if not container then corelog.Error("enterprise_employment.GetContainer: failed converting containerTable(="..textutils.serialise(containerTable)..") to "..containerClassName.." object for containerLocator="..containerLocator:getURI()) return nil end

    -- end
    return container
end

function enterprise_employment:getRegistered(...)
    -- get & check input from description
    local checkSuccess, workerId = InputChecker.Check([[
        This method provides the locator of a Worker 'workerId'.

        Return value:
            workerLocator       - (ObjLocator) locating the Worker

        Parameters:
            workerId            + (number) workerId of the Worker
    --]], ...)
    if not checkSuccess then corelog.Error("enterprise_employment:getRegistered: Invalid input") return nil end

    -- get workerLocators
    local workerLocators = GetContainer(self, "ObjTable", "workerLocators")
    if not workerLocators then corelog.Error("enterprise_employment:getRegistered: Failed obtaining workerLocators") return nil end

    -- get workerLocator
    for workerKey, aWorkerLocator in workerLocators:objs() do
        if workerKey == workerId then
            return aWorkerLocator
        end
    end

    -- end
    corelog.Warning("enterprise_employment:getRegistered: Worker "..workerId.." not (yet) registered")
    return nil
end

function enterprise_employment:register(...)
    -- get & check input from description
    local checkSuccess, workerId, theWorkerLocator = InputChecker.Check([[
        This method registers the locator of a Worker 'workerId' in enterprise_employment.

        Note that the Worker itself should already be available in the world/ hosted by enterprise_employment.

        Return value:
                                    - (boolean) whether the method executed successfully

        Parameters:
            workerId                + (number) workerId of the Worker
            workerLocator           + (ObjLocator) locating the Worker
    --]], ...)
    if not checkSuccess then corelog.Error("enterprise_employment:register: Invalid input") return false end

    -- get workerLocators
    local workerLocators = GetContainer(self, "ObjTable", "workerLocators")
    if not workerLocators then corelog.Error("enterprise_employment:register: Failed obtaining workerLocators") return false end

    -- register the Worker
    corelog.WriteToLog(">Registering Worker (workerId="..workerId..", workerLocator="..theWorkerLocator:getURI()..")")
    workerLocators[workerId] = theWorkerLocator

    -- save workerLocators
    local workerLocatorsLocator = self:saveObj(workerLocators, "workerLocators")
    if not workerLocatorsLocator then corelog.Error("enterprise_employment:register: Failed saving workerLocators") return false end

    -- end
    return true
end

function enterprise_employment:isRegistered(...)
    -- get & check input from description
    local checkSuccess, workerId = InputChecker.Check([[
        This method returns if a locator of a Worker 'workerId' is registered enterprise_employment.

        Return value:
                                    - (boolean) whether a locator is registered by 'workerId'

        Parameters:
            workerId                + (number) workerId of the Worker
    ]], ...)
    if not checkSuccess then corelog.Error("enterprise_employment:isRegistered: Invalid input") return false end

    -- get workerLocators
    local workerLocators = GetContainer(self, "ObjTable", "workerLocators")
    if not workerLocators then corelog.Error("enterprise_employment:isRegistered: Failed obtaining workerLocators") return false end

    -- check if registered
    local isRegistered = workerLocators[workerId] ~= nil

    -- end
    return isRegistered
end

function enterprise_employment:delist(...)
    -- get & check input from description
    local checkSuccess, workerId = InputChecker.Check([[
        This method delists the locator of a Worker 'workerId' from enterprise_employment.

        Note that the Worker is not removed from the world/ released from enterprise_employment.

        Return value:
                                    - (boolean) whether the method executed successfully

        Parameters:
            workerId                + (number) workerId of the Worker
    ]], ...)
    if not checkSuccess then corelog.Error("enterprise_employment:delist: Invalid input") return false end

    -- get workerLocators
    local workerLocators = GetContainer(self, "ObjTable", "workerLocators")
    if not workerLocators then corelog.Error("enterprise_employment:delist: Failed obtaining workerLocators") return false end

    -- get Workers
    for registeredWorkedId, _ in pairs(workerLocators) do
        -- check we found it
        if registeredWorkedId == workerId then
            -- remove from list
            corelog.WriteToLog(">Delisting Worker "..registeredWorkedId.." from enterprise_employment")
            workerLocators[registeredWorkedId] = nil

            -- save workerLocators
            local workerLocatorsLocator = self:saveObj(workerLocators, "workerLocators")
            if not workerLocatorsLocator then corelog.Error("enterprise_employment:delist: Failed saving workerLocators") return false end

            -- found and delisted it!
            return true
        end
    end

    -- end
    return false -- did not find it!
end

function enterprise_employment:getCurrentWorkerLocator()
    --[[
        This method provides the locator of the current Worker (in enterprise_employment).

        Return value:
            workerLocator       - (ObjLocator) locating the current Worker

        Parameters:
    --]]

    -- get current workerLocator
    local workerId = os.getComputerID()
    local currentWorkerLocator = self:getRegistered(workerId)
    if not currentWorkerLocator then
        -- get direction
        local direction = "top" -- note: maybe we do not want to have this fixed in the future

        -- determine birth information
        local className = nil
        local constructParameters = nil
        local workerName = "<unknown>"
        local father = peripheral.wrap(direction) -- note: we access low level computer functionality directly
        -- ToDo: consider if this low level functionality should be either moved into core OR into a role, as an enterprise is not supposed to access this
        if father and father.getID then -- is there a father present?
            -- get father id
            local fatherId = father.getID()

            -- get birthCertificate
            local birthCertificate = self:getAndRemoveBirthCertificate(fatherId)
            if not birthCertificate then corelog.Error("enterprise_employment:getCurrentWorkerLocator: Failed getting birthCertificate from fatherId "..fatherId) return false end

            -- determine hosting information
            className = birthCertificate.className
            constructParameters = birthCertificate.constructParameters
            constructParameters.workerId = workerId

            -- determine workerName
            workerName = className..""..tostring(workerId).." from Turtle"..tostring(fatherId)
        elseif self:getNumberOfObjects(Turtle:getClassName()) == 0 and turtle then -- are we the first Turtle?
            corelog.WriteToLog("This seems to be the first Turtle, we will make an exception and host and register it")
            -- note:    in all other cases we want the programmic logic that created the Worker to also host and register it in enterprise_employment,
            --          however for the first one this is a bit hard. Hence we do it here as an exception in this special case.

            -- no settlement should exists as well: create it
            enterprise_colonization = enterprise_colonization or require "enterprise_colonization"
            local settlementLocator = enterprise_colonization:hostLObj_SSrv({ className = Settlement:getClassName(), constructParameters = { }}).mobjLocator
            if not settlementLocator then corelog.Error("enterprise_employment:getCurrentWorkerLocator: Failed creating Settlement") return false end

            -- determine hosting information
            className = Turtle:getClassName()
            local baseLocation = Location:newInstance(0, -1, 3, 0, 1)
            local workerLocation = Location:newInstance(3, 2, 1, 0, 1)
            constructParameters = {
                workerId            = workerId,
                settlementLocator   = settlementLocator,
                baseLocation        = baseLocation,
                workerLocation      = workerLocation,
            }

            -- determine workerName
            workerName = className.." "..tostring(workerId).." from the Creator"
        else
            -- did we register our own birthCertificate? (e.g. via a Menu)
            local birthCertificate = self:getAndRemoveBirthCertificate(workerId)
            if birthCertificate then
                -- determine hosting information
                className = birthCertificate.className
                constructParameters = birthCertificate.constructParameters
                constructParameters.workerId = workerId

                -- determine workerName
                workerName = className..""..tostring(workerId).." SelfMade"
            else
                -- forgotten (not in dht) or abandonded (by father)
                corelog.Error("enterprise_employment:getCurrentWorkerLocator: Worker "..workerId.." seems to have been forgotten or abandoned. => bailing out")
                return nil
            end
        end

        -- host Worker
        local workerLocator = self:hostLObj_SSrv({ className = className, constructParameters = constructParameters }).mobjLocator
        if not workerLocator then corelog.Error("enterprise_employment:getCurrentWorkerLocator: Failed hosting new Worker "..workerId) return nil end

        -- set location
        -- ToDo: consider removing/ doing differently?
        coremove.SetLocation(constructParameters.workerLocation)

        -- register Worker
        local registered = self:register(workerId, workerLocator)
        if not registered then corelog.Error("enterprise_employment:getCurrentWorkerLocator: Failed registering new Worker "..workerId) return nil end

        -- set label
        os.setComputerLabel(workerName)

        -- define this as new workerLocator
        currentWorkerLocator = workerLocator
    end
    if not currentWorkerLocator then corelog.Warning("enterprise_employment:getCurrentWorkerLocator: workerLocator for (current) Worker "..workerId.." not found") return nil end

    -- end
    return currentWorkerLocator:copy()
end

function enterprise_employment:getAndRemoveBirthCertificate(fatherId)
    --[[
        This method provides the birthCertificate of Worker created by other Worker 'fatherId'.

        Return value:
            workerLocator       - (ObjLocator) locating the current Worker

        Parameters:
            fatherId            + (number) workerId of the father
    --]]

    -- get birthCertificates
    local birthCertificates = GetContainer(self, "ObjArray", "birthCertificates")
    if not birthCertificates then corelog.Error("enterprise_employment:getAndRemoveBirthCertificate: Failed obtaining birthCertificates") return nil end

    -- get birthCertificate
    for iCerticate, birthCertificate in ipairs(birthCertificates) do
        if type(birthCertificate) == "table" and birthCertificate.fatherId == fatherId then
            -- remove certificate
            table.remove(birthCertificates, iCerticate)

            -- save birthCertificates
            local newWorkerLocatorsLocator = self:saveObj(birthCertificates, "birthCertificates")
            if not newWorkerLocatorsLocator then corelog.Error("enterprise_employment:getAndRemoveBirthCertificate: Failed saving birthCertificates") return false end

            -- end
            return birthCertificate
        end
    end

    -- end
    corelog.Warning("enterprise_employment:getAndRemoveBirthCertificate: birthCertificate from father "..fatherId.." not found")
    return nil
end

function enterprise_employment:registerBirthCertificate_SOSrv(...)
    -- get & check input from description
    local checkSuccess, className, constructParameters = InputChecker.Check([[
        This public service registers birth information. The new born baby Worker should host itself in enterprise_employment using this birth information.

        Return value:
            task result                         - (table)
                success                         - (boolean) whether the assignment was scheduled successfully
                fatherId                        - (number) workerId of the Worker registering the birth information

        Parameters:
            serviceData                         - (table) data about this service
                className                       + (string, "") with the name of the class of the Worker
                constructParameters             + (table) parameters for constructing the Worker
    ]], ...)
    if not checkSuccess then corelog.Error("enterprise_employment:registerBirthCertificate_SOSrv: Invalid input") return {success = false} end

    -- get birthCertificates
    local birthCertificates = GetContainer(self, "ObjArray", "birthCertificates")
    if not birthCertificates then corelog.Error("enterprise_employment:registerBirthCertificate_SOSrv: Failed obtaining birthCertificates") return {success = false} end

    -- add birthCertificate
    local fatherId = os.getComputerID()
    local birthCertificate = {
        fatherId            = fatherId,
        className           = className,
        constructParameters = constructParameters,
    }
    table.insert(birthCertificates, birthCertificate)

    -- save birthCertificates
    local newWorkerLocatorsLocator = self:saveObj(birthCertificates, "birthCertificates")
    if not newWorkerLocatorsLocator then corelog.Error("enterprise_employment:registerBirthCertificate_SOSrv: Failed saving birthCertificates") return {success = false} end

    -- end
    return {
        success     = true,
        fatherId    = fatherId,
    }
end

function enterprise_employment:deleteWorkers()
    -- get registered workerLocators
    local workerLocators = GetContainer(self, "ObjTable", "workerLocators")
    if not workerLocators then corelog.Error("enterprise_employment:deleteWorkers: Failed obtaining workerLocators") return nil end

    -- release Worker and remove locator
    for workerKey, workerLocator in workerLocators:objs() do
        -- release Worker
        enterprise_employment:releaseLObj_SSrv({ mobjLocator = workerLocator})

        -- remove locator
        workerLocators[workerKey] = nil
    end
    -- save workerLocators
    local workerLocatorsLocator = self:saveObj(workerLocators, "workerLocators")
    if not workerLocatorsLocator then corelog.Error("enterprise_employment:deleteWorkers: Failed saving workerLocators") return false end

    -- release remaining Worker's that where apparently not registered
    self:releaseLObjs_SSrv({ className = Turtle:getClassName() })
    self:releaseLObjs_SSrv({ className = UserStation:getClassName() })
    self:releaseLObjs_SSrv({ className = DisplayStation:getClassName() })
end

local function resetWorkerOfType(employmentHost, className)
    -- get Worker's
    local workers = employmentHost:getObjects(className)
    if not workers then corelog.Error("enterprise_employment:resetWorkerOfType: Failed obtaining "..className.."'s") return nil end

    -- check/ reset all Worker's
    for id, objTable in pairs(workers) do
        -- convert to Worker
        local obj = objectFactory:create(className, objTable) if not obj then corelog.Error("enterprise_employment:resetWorkerOfType: Failed converting "..className.." "..id.." objTable to "..className.."") return nil end

        -- check registered
        local workerId = obj:getWorkerId()
        local isRegistered = employmentHost:isRegistered(workerId)
        if isRegistered then
            -- reset Worker
            obj:reset()
        else
            corelog.Warning("enterprise_employment:resetWorkerOfType: "..className.." "..workerId.." not registered => removing it")
            local lobjLocator = LObjLocator:newInstance(employmentHost:getHostName(), obj)
            employmentHost:deleteResource(lobjLocator)
        end
    end
end

function enterprise_employment:resetWorkers()
    -- check/ reset/ recover all Worker's
    resetWorkerOfType(enterprise_employment, Turtle:getClassName())
    resetWorkerOfType(enterprise_employment, UserStation:getClassName())
    resetWorkerOfType(enterprise_employment, DisplayStation:getClassName())
end

local function GetASettlementLocator()
    -- attempt to retrieve settlementLocator
    local settlementLocator = nil
    enterprise_colonization = enterprise_colonization or require "enterprise_colonization"
    local settlements = enterprise_colonization:getObjects(Settlement:getClassName())
    if not settlements then corelog.Error("enterprise_employment.GetASettlementLocator: Failed obtaining Settlement's") return nil end
    for k, objTable in pairs(settlements) do
        local obj = Settlement:new(objTable)
        settlementLocator = LObjLocator:newInstance("enterprise_colonization", obj)
    end

    -- end
    return settlementLocator
end

local function DummyWorkerMenu(t)
    if type(t) =="table" and type(t.workerClassName) =="string" then
        local className = t.workerClassName
        if className == "UserStation" then
            -- register birthCertificate
            local settlementLocator = GetASettlementLocator() -- note: we are not sure this works
            if not settlementLocator then corelog.Error("enterprise_employment.DummyWorkerMenu: Failed obtaining settlementLocator") return false end
            corelog.Warning("enterprise_employment.DummyWorkerMenu: Note assuming settlementLocator: "..settlementLocator:getURI())
            local baseLocation = Location:newInstance(-6, -12, 1, 0, 1) -- note: we don't know this
            corelog.Warning("enterprise_employment.DummyWorkerMenu: Note assuming baseLocation: "..textutils.serialise(baseLocation))
            -- ToDo: see if there is a smarter way to retrieve baseLocation (e.g. from coremove.GetLocation())
            local workerId = os.getComputerID()
            local reconstructParameters = {
                workerId            = workerId,
                settlementLocator   = settlementLocator,
                baseLocation        = baseLocation,
                workerLocation      = baseLocation:getRelativeLocation(3, 3, 0),
            }
            local serviceResults = enterprise_employment:registerBirthCertificate_SOSrv({
                className           = className,
                constructParameters = reconstructParameters,
            })
            if not serviceResults.success then corelog.Error("enterprise_employment.DummyWorkerMenu: Registering birthCertificate failed") return false end

            -- reboot
            corelog.WriteToLog("enterprise_employment.DummyWorkerMenu: Registering my own birthCertificate:")
            os.sleep(5.0)
            corelog.WriteToLog("rebooting...")
            os.reboot()
        elseif className == "DisplayStation" then
            -- register birthCertificate
            local baseLocation = Location:newInstance(-6, -12, 1, 0, 1) -- note: we don't know this
            corelog.Warning("enterprise_employment.DummyWorkerMenu: Note assuming baseLocation: "..textutils.serialise(baseLocation))
            -- ToDo: see if there is a smarter way to retrieve baseLocation (e.g. from coremove.GetLocation())
            local workerId = os.getComputerID()
            local reconstructParameters = {
                workerId        = workerId,
                baseLocation    = baseLocation,
                workerLocation  = baseLocation:getRelativeLocation(3, 3, 2),
            }
            local serviceResults = enterprise_employment:registerBirthCertificate_SOSrv({
                className           = className,
                constructParameters = reconstructParameters,
            })
            if not serviceResults.success then corelog.Error("enterprise_employment.DummyWorkerMenu: Registering birthCertificate failed") return false end

            -- reboot
            corelog.WriteToLog("enterprise_employment.DummyWorkerMenu: Registering my own birthCertificate:")
            os.sleep(5.0)
            corelog.WriteToLog("rebooting...")
            os.reboot()
        else
            local message1 = "Don't know (how to set as) "..className.." (yet)"
            local message2 = " => ask developer to add it!"
            corelog.Error("enterprise_employment.DummyWorkerMenu: "..message1..message2)
            coredisplay.UpdateToDisplay(message2, 5)
            coredisplay.UpdateToDisplay(message1, 5)
            return false
        end

        -- we are done here, go back
        return true
    else
        return {
            clear   = true,
            intro   = "I am not a properly registered Worker!\nHence I do not know what to display.\nChoose your action",
            option  = {
                {key = "u", desc = "Set as UserStation",    func = DummyWorkerMenu,     param = {workerClassName = "UserStation"}},
                {key = "d", desc = "Set as DisplayStation", func = DummyWorkerMenu,     param = {workerClassName = "DisplayStation"}},
                {key = "q", desc = "Quit",          	    func = coresystem.DoQuit,	param = {}},
            },
            question = "Can you tell me who I am?",
        }
    end
end

function enterprise_employment:getDummyWorkerMenu()
    return DummyWorkerMenu()
end

--    __  __  ____  _     _ _    _           _
--   |  \/  |/ __ \| |   (_) |  | |         | |
--   | \  / | |  | | |__  _| |__| | ___  ___| |_
--   | |\/| | |  | | '_ \| |  __  |/ _ \/ __| __|
--   | |  | | |__| | |_) | | |  | | (_) \__ \ |_
--   |_|  |_|\____/|_.__/| |_|  |_|\___/|___/\__|
--                      _/ |
--                     |__/

function enterprise_employment:buildAndHostMObj_ASrv(...)
    -- get & check input from description
    local checkSuccess, className, constructParameters, materialsItemSupplierLocator, wasteItemDepotLocator, callback = InputChecker.Check([[
        This async public service builds, hosts, registers and boots a new Worker.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully
                mobjLocator                     - (ObjLocator) locating the build and hosted Worker

        Parameters:
            serviceData                         - (table) data about this service
                className                       + (string, "") with the name of the class of the Worker
                constructParameters             + (table) parameters for constructing the Worker
                materialsItemSupplierLocator    + (ObjLocator) locating the host for building materials
                wasteItemDepotLocator           + (ObjLocator) locating where waste material can be delivered
            callback                            + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("enterprise_employment:buildAndHostMObj_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- get class
    local class = objectFactory:getClass(className)
    if not class then corelog.Error("enterprise_employment:buildAndHostMObj_ASrv: Class "..className.." not found in objectFactory") return Callback.ErrorCall(callback) end
    if not Class.IsInstanceOf(class, IMObj) then corelog.Error("enterprise_employment:buildAndHostMObj_ASrv: Class "..className.." is not an IMObj") return Callback.ErrorCall(callback) end

    -- check (not) IWorker
    if not Class.IsInstanceOf(class, IWorker) then
        -- have base class MObjHost handle the service
        corelog.WriteToLog()
        return MObjHost.buildAndHostMObj_ASrv(self, ...)
    end

    -- get blueprint
    local buildLocation, blueprint = class.GetBuildBlueprint(constructParameters)
    if not buildLocation or not blueprint then corelog.Error("enterprise_employment:buildAndHostMObj_ASrv: Failed obtaining build blueprint for a new "..className..".") return Callback.ErrorCall(callback) end

    -- create project definition
    local workerLocation = constructParameters.workerLocation:copy()
    local accessDirection = "top"
    local taskData = {
        turtleId        = -1,
        workerLocation  = workerLocation,
        accessDirection = accessDirection,
    }
    local projectData = {
        buildLocation               = buildLocation,
        blueprint                   = blueprint,
        materialsItemSupplierLocator= materialsItemSupplierLocator,
        wasteItemDepotLocator       = wasteItemDepotLocator,

        className                   = className,
        constructParameters         = constructParameters,

        hostLocator                 = self:getHostLocator(),

        metaData                    = role_interactor.TurnOnWorker_MetaData(taskData),
        taskCall                    = TaskCall:newInstance("role_interactor", "TurnOnWorker_Task", taskData),
    }
    local projectDef = {
        steps   = {
            -- build MObj in the world
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_construction", serviceName = "BuildBlueprint_ASrv" }, stepDataDef = {
                { keyDef = "blueprintStartpoint"            , sourceStep = 0, sourceKeyDef = "buildLocation" },
                { keyDef = "blueprint"                      , sourceStep = 0, sourceKeyDef = "blueprint" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Building "..className},
            -- register new born Worker
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "registerBirthCertificate_SOSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "className"                      , sourceStep = 0, sourceKeyDef = "className" },
                { keyDef = "constructParameters"            , sourceStep = 0, sourceKeyDef = "constructParameters" },
            }, description = "Register new "..className},
            -- boot new Worker
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"                       , sourceStep = 0, sourceKeyDef = "metaData" },
                { keyDef = "metaData.needWorkerId"          , sourceStep = 2, sourceKeyDef = "fatherId" },
                { keyDef = "taskCall"                       , sourceStep = 0, sourceKeyDef = "taskCall" },
            }, description = "Turn on new "..className},
        },
        returnData  = {
            { keyDef = "mobjLocator"                        , sourceStep = 3, sourceKeyDef = "workerLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Adding a new Worker", description = "Just wondering which one, aren't you?" },
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

--    ______       _                       _          ______                 _                                  _
--   |  ____|     | |                     (_)        |  ____|               | |                                | |
--   | |__   _ __ | |_ ___ _ __ _ __  _ __ _ ___  ___| |__   _ __ ___  _ __ | | ___  _   _ _ __ ___   ___ _ __ | |_
--   |  __| | '_ \| __/ _ \ '__| '_ \| '__| / __|/ _ \  __| | '_ ` _ \| '_ \| |/ _ \| | | | '_ ` _ \ / _ \ '_ \| __|
--   | |____| | | | ||  __/ |  | |_) | |  | \__ \  __/ |____| | | | | | |_) | | (_) | |_| | | | | | |  __/ | | | |_
--   |______|_| |_|\__\___|_|  | .__/|_|  |_|___/\___|______|_| |_| |_| .__/|_|\___/ \__, |_| |_| |_|\___|_| |_|\__|
--                             | |                                    | |             __/ |
--                             |_|                                    |_|            |___/

function enterprise_employment.GetAnyTurtleLocator()
    --[[
        This method provides a locator for any turtle (in the enterprise). The locator provided will be subsituted to the current
        turtle once it is to be used.

        Return value:
            turtleLocator       - (ObjLocator) locating any turtle

        Parameters:
    --]]

    local objLocator = ObjLocator:newInstance(enterprise_employment:getHostName(), Turtle:getClassName(), "any")

    -- end
    return objLocator
end

function enterprise_employment:triggerTurtleRefuelIfNeeded(turtleObj)
    -- get fuelLevels
    local turtleFuelLevel = turtle.getFuelLevel()
    local fuelLevels = self.GetFuelLevels_Att()

    -- check fuelLevels
    local fuelLevel_Assignment = fuelLevels.fuelLevel_Assignment
    if turtleFuelLevel < fuelLevel_Assignment and turtleObj:getFuelPriorityKey() == "" then
        -- ensure this turtle now only starts taking new assignments with the priority key
        local priorityKey = coreutils.NewId()
        turtleObj:setFuelPriorityKey(priorityKey)
        local turtleLocator = self:saveObj(turtleObj) if not turtleLocator then corelog.Error("enterprise_employment:triggerTurtleRefuelIfNeeded: failed saving turtle") return end

        -- get Settlement from currentTurtleObj
        local settlementLocator = turtleObj:getSettlementLocator() if not settlementLocator then corelog.Error("enterprise_employment:triggerTurtleRefuelIfNeeded: Failed obtaining settlementLocator") return end
        enterprise_colonization = enterprise_colonization or require "enterprise_colonization"
        local settlementObj = enterprise_colonization:getObj(settlementLocator) if not settlementObj then corelog.Error("enterprise_employment:triggerTurtleRefuelIfNeeded: Failed obtaining Settlement "..settlementLocator:getURI()) return end

        -- prepare service call
        local refuelAmount = enterprise_energy.GetRefuelAmount_Att()
        if refuelAmount == 0 then corelog.Error("enterprise_employment:triggerTurtleRefuelIfNeeded: refuelAmount = 0 while turtleFuelLevel(="..turtleFuelLevel..") < fuelLevel_Assignment(="..fuelLevel_Assignment.."). Apparently enterprise_energy enterpriseLevel = 0. This should not happen here! => skip asking for this and fix this!") return end
        local wasteItemDepotLocator = enterprise_employment.GetAnyTurtleLocator() -- ToDo: introduce and use proper WasteDump + somehow get this passed into enterprise_employment
        local ingredientsItemSupplierLocator = settlementObj:getMainShopLocator()
        local serviceData = {
            turtleLocator                   = turtleLocator,
            fuelAmount                      = refuelAmount,
            ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
            wasteItemDepotLocator           = wasteItemDepotLocator,

            assignmentsPriorityKey          = priorityKey,
        }
        local callback = Callback:newInstance("enterprise_employment", "Fuel_Callback", { turtleLocator = turtleLocator, })

        -- call service
        enterprise_energy.ProvideFuelTo_ASrv(serviceData, callback)
    end
end

function enterprise_employment.Fuel_Callback(...)
    -- get & check input from description
    local checkSuccess, turtleLocator, serviceResults = InputChecker.Check([[
        This callback should cleanup after enterprise_energy.ProvideFuelTo_ASrv is finished

        Return value:
                                    - (table)
                success             - (boolean) whether the callback executed successfully

        Parameters:
            callbackData            - (table) callbackData
                turtleLocator       + (ObjLocator) locator of the turtle
            serviceResults          + (table) result of service that calls back
    --]], ...)
    if not checkSuccess then corelog.Error("enterprise_employment.Fuel_Callback: Invalid input") return {success = false} end

    -- check refuel was a success
    if serviceResults.success == false then corelog.Error("enterprise_employment.Fuel_Callback: Refuel of turtle "..turtleLocator:getURI().." failed") return {success = false} end

    -- get Turtle
    local turtleObj = enterprise_employment:getObj(turtleLocator) if not turtleObj then corelog.Error("enterprise_employment.Fuel_Callback: Failed obtaining Turtle from turtleLocator="..turtleLocator:getURI()) return {success = false} end

    -- release priority key condition
    turtleObj:setFuelPriorityKey("")
    turtleLocator = enterprise_employment:saveObj(turtleObj) if not turtleLocator then corelog.Error("enterprise_employment.Fuel_Callback: failed saving turtle") return {success = false} end

    -- end
    return {success = true}
end

function enterprise_employment.GetFuelLevels_Att()
    -- determine fuelLevel_Priority
    local fuelNeed_Refuel = enterprise_energy.GetFuelNeed_Refuel_Att()
    local assignmentStatistics = enterprise_assignmentboard.GetStatistics_Att()
    local maxFuelNeed_Travel = assignmentStatistics.maxFuelNeed_Travel
    local fuelLevel_Priority = fuelNeed_Refuel + maxFuelNeed_Travel

    -- determine fuelLevel_Assignment
    local maxFuelNeed_Assignment = assignmentStatistics.maxFuelNeed_Assignment
    local fuelLevel_Assignment = fuelLevel_Priority + maxFuelNeed_Assignment

    -- end
    local fuelLevels = {
        fuelLevel_Priority      = fuelLevel_Priority,
        fuelLevel_Assignment    = fuelLevel_Assignment,
    }
    return fuelLevels
end

return enterprise_employment
