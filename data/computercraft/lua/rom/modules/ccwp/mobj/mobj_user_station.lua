-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ILObj = require "i_lobj"
local IMObj = require "i_mobj"
local IWorker = require "i_worker"
local UserStation = Class.NewClass(ObjBase, ILObj, IMObj, IWorker)

--[[
    The UserStation Worker represents a station in the minecraft world and provides (production) services for developers to operate on that UserStation.

    A UserStation allows for the the retrieval and dumping of items for the developer.
        -   What items to retrieve is handled by the main menu of the UserStation. The retrieved items will eventually end up in the input (left) Chest.
        -   Items can be dumped by placing them in the output (right) Chest.
--]]

local coreevent = require "coreevent"
local coretask = require "coretask"
local coredht = require "coredht"
local coredisplay = require "coredisplay"
local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local ObjTable = require "obj_table"
local ObjHost = require "obj_host"
local Block = require "obj_block"
local Location = require "obj_location"
local CodeMap = require "obj_code_map"
local LayerRectangle = require "obj_layer_rectangle"

local role_conservator = require "role_conservator"

local enterprise_storage = require "enterprise_storage"
local enterprise_employment

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function UserStation:_init(...)
    -- get & check input from description
    local checkSuccess, workerId, isActive, settlementLocator, baseLocation, inputLocator, outputLocator = InputChecker.Check([[
        Initialise a UserStation.

        Parameters:
            workerId                + (number) workerId of the UserStation
            isActive                + (boolean) whether the UserStation is active
            settlementLocator       + (ObjLocator) locating Settlement of the UserStation
            baseLocation            + (Location) base location of the UserStation
            inputLocator            + (ObjLocator) input Chest of the UserStation (where items will be picked up from)
            outputLocator           + (ObjLocator) output Chest of the UserStation (where items will be delivered)
    ]], ...)
    if not checkSuccess then corelog.Error("UserStation:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._workerId          = workerId
    self._isActive          = isActive
    self._settlementLocator = settlementLocator
    self._baseLocation      = baseLocation
    self._inputLocator      = inputLocator
    self._outputLocator     = outputLocator
end

-- ToDo: should be renamed to newFromTable at some point
function UserStation:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a UserStation.

        Parameters:
            o                           + (table, {}) with object fields
                _workerId               - (number) workerId of the UserStation
                _isActive               - (boolean, false) whether the UserStation is active
                _settlementLocator      - (ObjLocator) locating Settlement of the UserStation
                _baseLocation           - (Location) location of the UserStation
                _inputLocator           - (ObjLocator) input Chest of the UserStation
                _outputLocator          - (ObjLocator) output Chest of the UserStation
    ]], ...)
    if not checkSuccess then corelog.Error("UserStation:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function UserStation:getInputLocator()  return self._inputLocator   end
function UserStation:getOutputLocator() return self._outputLocator  end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function UserStation:getClassName()
    return "UserStation"
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function UserStation:construct(...)
    -- get & check input from description
    local checkSuccess, workerId, settlementLocator, baseLocation = InputChecker.Check([[
        This method constructs a UserStation instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        It also ensures all child MObj's the UserStation spawns are hosted on the appropriate MObjHost (by calling hostLObj_SSrv).

        The constructed UserStation is not yet saved in the LObjHost.

        Return value:
                                        - (UserStation) the constructed UserStation

        Parameters:
            constructParameters         - (table) parameters for constructing the UserStation
                workerId                + (number) workerId of the UserStation
                settlementLocator       + (ObjLocator) locating Settlement of the Turtle
                baseLocation            + (Location) base location of the UserStation
    ]], ...)
    if not checkSuccess then corelog.Error("UserStation:construct: Invalid input") return nil end

    -- determine UserStation fields
    local inputLocator = enterprise_storage:hostLObj_SSrv({className = "Chest", constructParameters = {
        baseLocation    = baseLocation:getRelativeLocation(4, 3, 0),
        accessDirection = "top",
    }}).mobjLocator
    local outputLocator = enterprise_storage:hostLObj_SSrv({className = "Chest", constructParameters = {
        baseLocation    = baseLocation:getRelativeLocation(2, 3, 0),
        accessDirection = "top",
    }}).mobjLocator

    -- construct new UserStation
    local obj = UserStation:newInstance(workerId, false, settlementLocator, baseLocation:copy(), inputLocator, outputLocator)

    -- end
    return obj
end

function UserStation:destruct()
    --[[
        This method destructs a UserStation instance.

        It also ensures all child MObj's the UserStation is the parent of are released from the appropriate MObjHost (by calling releaseLObj_SSrv).

        The UserStation is not yet deleted from the LObjHost.

        Return value:
                                        - (boolean) whether the UserStation was succesfully destructed.

        Parameters:
    ]]

    -- release input/output locators
    local destructSuccess = true

    -- input locator
    if self._inputLocator:getHost() == enterprise_storage:getHostName() then
        local releaseResult = enterprise_storage:releaseLObj_SSrv({ mobjLocator = self._inputLocator })
        if not releaseResult or not releaseResult.success then corelog.Warning("UserStation:destruct(): failed releasing input locator "..self._inputLocator:getURI()) destructSuccess = false end
    end
    self._inputLocator = nil

    -- output locator
    if self._outputLocator:getHost() == enterprise_storage:getHostName() then
        local releaseResult = enterprise_storage:releaseLObj_SSrv({ mobjLocator = self._outputLocator })
        if not releaseResult or not releaseResult.success then corelog.Warning("UserStation:destruct(): failed releasing output locator "..self._outputLocator:getURI()) destructSuccess = false end
    end
    self._outputLocator = nil

    -- end
    return destructSuccess
end

function UserStation:getId()
    return tostring(self._workerId)
end

function UserStation:getWIPId()
    --[[
        Returns the unique Id of the UserStation used for administering WIP.
    ]]

    return self:getClassName().." "..self:getId()
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function UserStation:getSettlementLocator()
    return self._settlementLocator
end

function UserStation:getBaseLocation() return self._baseLocation end

local function Chest_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["C"]   = Block:newInstance("minecraft:chest", 0, -1),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
        }),
        CodeMap:newInstance({
            [1] = "C?C",
        })
    )
end

local function ChestDismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
        }),
        CodeMap:newInstance({
            [1] = " ? ",
        })
    )
end

local function Computer_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["C"]   = Block:newInstance("computercraft:computer_normal", 0, -1),
        }),
        CodeMap:newInstance({
            [1] = "C",
        })
    )
end

local function ComputerDismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [1] = " ",
        })
    )
end

local function Modem_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["M"]   = Block:newInstance("computercraft:wireless_modem_normal"),
        }),
        CodeMap:newInstance({
            [1] = "M",
        })
    )
end

local function ModemDismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [1] = " ",
        })
    )
end

function UserStation.GetBuildBlueprint(...)
    -- get & check input from description
    local checkSuccess, baseLocation = InputChecker.Check([[
        This method returns a blueprint for building a UserStation in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            constructParameters         - (table) parameters for constructing the UserStation
                baseLocation            + (Location) base location of the UserStation
    ]], ...)
    if not checkSuccess then corelog.Error("UserStation.GetBuildBlueprint: Invalid input") return nil, nil end

    -- layer list
    local layerList = {
        { startpoint = Location:newInstance(2, 3, 0), buildDirection = "Down", layer = Chest_layer()},
        { startpoint = Location:newInstance(3, 3, 0), buildDirection = "Down", layer = Computer_layer()},
    }
    table.insert(layerList, { startpoint = Location:newInstance(3, 2, 0), buildDirection = "Front", layer = Modem_layer()})

    -- escapeSequence
    local escapeSequence = {}

    -- blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence,
    }

    -- buildLocation
    local buildLocation = baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

function UserStation:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the UserStation in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- layerList
    local layerList = {
        { startpoint = Location:newInstance(3, 2, 0), buildDirection = "Down", layer = ModemDismantle_layer()},
        { startpoint = Location:newInstance(3, 3, 0), buildDirection = "Down", layer = ComputerDismantle_layer()},
        { startpoint = Location:newInstance(2, 3, 0), buildDirection = "Down", layer = ChestDismantle_layer()},
    }

    -- escapeSequence
    local escapeSequence = {}

    -- blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence
    }

    -- buildLocation
    local buildLocation = self._baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

--    _______          __        _
--   |_   _\ \        / /       | |
--     | |  \ \  /\  / /__  _ __| | _____ _ __
--     | |   \ \/  \/ / _ \| '__| |/ / _ \ '__|
--    _| |_   \  /\  / (_) | |  |   <  __/ |
--   |_____|   \/  \/ \___/|_|  |_|\_\___|_|

function UserStation:getWorkerId()
    --[[
        Get the UserStation workerId.

        Return value:
                                - (number) the UserStation workerId
    ]]

    -- end
    return self._workerId
end

local subject = "input Chest timer"

function UserStation:activate()
    -- check current Worker
    if self:getWorkerId() ~= os.getComputerID() then
        corelog.Warning("UserStation:activate() not supported on UserStation(="..self:getWorkerId()..") from other computer(="..os.getComputerID()..") => not adding event")
    else
        -- ToDo: figure out if this is how we want to do this... or do we want to use an assignment here?

        -- setup timer for input Chest checking
        coreevent.AddEventListener(UserStation.DoEventInputChestTimer, "mobj_user_station", subject)

        -- check input box for the first time!
        UserStation.DoEventInputChestTimer(subject, self:getOutputLocator())
    end

    -- set active
    self._isActive = true

    -- end
    return self:isActive()
end

function UserStation.DoEventInputChestTimer(_, outputLocator)
    -- add the work, the real stuff
    coretask.AddWork(role_conservator.CheckOutputChest, outputLocator, "role_conservator.CheckOutputChest()")

    -- create new event
    coreevent.CreateTimeEvent(20 * 15, "mobj_user_station", subject, outputLocator)
end

function UserStation:deactivate()
    -- check current Worker
    if self:getWorkerId() ~= os.getComputerID() then
        corelog.Warning("UserStation:deactivate() not supported on UserStation(="..self:getWorkerId()..") from other computer(="..os.getComputerID()..") => not removing event")
    else
        -- remove timer
        coreevent.RemoveEventListener("mobj_user_station", subject)
    end

    -- set deactive
    self._isActive = false

    -- end
    return not self:isActive()
end

function UserStation:isActive()
    return self._isActive == true
end

function UserStation:reset()
    -- reset fields
    -- nothing to do for now

    -- save UserStation
    -- local objLocator = enterprise_employment:saveObj(self) if not objLocator then corelog.Error("UserStation:reset: Failed saving UserStation") return nil end

    -- check input Chest (still) exist
    local inputLocator = self:getInputLocator()
    local inputChest = ObjHost.GetObj(inputLocator)
    if type(inputChest) ~= "table" then
        corelog.Warning("UserStation:reset: inputChest "..inputLocator:getURI().." not found.")
    end

    -- check output Chest (still) exist
    local outputLocator = self:getOutputLocator()
    local outputChest = ObjHost.GetObj(outputLocator)
    if type(outputChest) ~= "table" then
        corelog.Warning("UserStation:reset: outputChest "..outputLocator:getURI().." not found.")
    end

    -- recover if needed
    if type(inputChest) ~= "table" or type(outputChest) ~= "table" then
        -- re host UserStation
        local constructParameters = {
            workerId        = self:getWorkerId(),
            baseLocation    = self:getBaseLocation()
        }
        corelog.Warning("UserStation:reset: => recovering UserStation "..self:getId().." by rehosting it")
        enterprise_employment = enterprise_employment or require "enterprise_employment"
        enterprise_employment:hostLObj_SSrv({
            className           = self:getClassName(),
            constructParameters = constructParameters,
        })
    end
end

function UserStation:getWorkerLocation()
    return self:getBaseLocation():getRelativeLocation(3, 3, 0) -- note: location of UserStation computer relative to this UserStation baseLocation
end

function UserStation:getWorkerResume()
    --[[
        Get UserStation resume for selecting Assignment's.

        The resume gives information on the UserStation and is used to determine if the UserStation is (best) suitable to take an Assignment.
            This is can e.g. be used to indicate location, fuel level and equiped items.

        Return value:
            resume              - (table) UserStation "resume" to consider in selecting Assignment's
    --]]

    -- end
    return {
        workerId        = self:getWorkerId(),
        location        = self:getWorkerLocation(),
    }
end

local function UserStationMenuOrder(t, amount)
    -- check the amount
    local _, _, count, stack = string.find(amount, "(%d+)(s?)")
    count = tonumber(count)
    if type(count) == "number" and count > 0 then
        -- Yahoo, we can do something for master

        -- determine some variables
        local itemName = t.item

        local userStation = t.userStation
        if not userStation then coredisplay.UpdateToDisplay("No UserStation self!", 2) return false end

        if stack == "s" then stack = " stack" else stack = "" end

        -- get Settlement
        local settlementLocator = userStation:getSettlementLocator() if not settlementLocator then corelog.Error("UserStation.UserStationMenuOrder: Failed obtaining settlementLocator") return false end
        local enterprise_colonization = require "enterprise_colonization"
        local settlementObj = enterprise_colonization:getObj(settlementLocator) if not settlementObj then corelog.Error("enterprise_colonization.RecoverNewWorld_SSrv: Failed obtaining Settlement "..settlementLocator:getURI()) return false end

        -- get Shop
        local shopLocator = settlementObj:getMainShopLocator()
        local shop = enterprise_colonization:getObj(shopLocator)
        if not shop then coredisplay.UpdateToDisplay("No Shop!", 2) return false end

        -- make master happy
        local provideItems = {
            [itemName]  = count,
        }
        local itemDepotLocator = userStation:getInputLocator()
        local ingredientsItemSupplierLocator = shopLocator
        enterprise_employment = enterprise_employment or require "enterprise_employment"
        local wasteItemDepotLocator = enterprise_employment.GetAnyTurtleLocator() -- ToDo: introduce and use proper WasteDump + somehow get this passed into UserStation
        local scheduleResult = shop:provideItemsTo_AOSrv({
            provideItems                    = provideItems,
            itemDepotLocator                = itemDepotLocator,
            ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
            wasteItemDepotLocator           = wasteItemDepotLocator,
        }, Callback.GetNewDummyCallBack())
        if not scheduleResult then coredisplay.UpdateToDisplay("Failed scheduling delivering of "..count..stack.." "..itemName.."'s", 2) return false end

        -- end
        coredisplay.UpdateToDisplay("Scheduled delivering of "..count..stack.." "..itemName .."'s", 2)
        return true
    else
        -- not good!
        coredisplay.UpdateToDisplay("Not a number ('"..amount.."')", 2)
        return false
    end
end

local function UserStationMenuAmount(t)
    coredisplay.NextScreen({
        clear       = true,
        func	    = UserStationMenuOrder,
        intro       = "How many items of "..t.item.."?",
        param       = t,
        question    = nil
    })
    return true
end

local function UserStationMenuSearch(t, searchString)
    -- get all items
    local allItems      = coredht.GetData("allItems")
    local options       = {}
    local lastNumber    = 0

    -- security check
    if type(allItems) ~= "table" then return false end

    -- loop all items
    for k, v in pairs(allItems) do
        -- if the search string for matches, add found items to the options!
        local findStart, findEnd = string.find(k, searchString)
        if type(findStart) =="number" and type(findEnd) == "number" then
            lastNumber = lastNumber + 1
            table.insert(options, {key = tostring(lastNumber), desc = k, func = UserStationMenuAmount, param = { userStation = t.userStation, item = k}})
        end
    end

    -- do we have found anything?
    if lastNumber == 0 then
        -- not good!
        coredisplay.UpdateToDisplay("No items found :-(", 2)
    elseif lastNumber > 10 then
        -- Too much
        coredisplay.UpdateToDisplay(lastNumber.." items found, specify your search", 2)
    else
        -- add exit option
        table.insert(options, {key = "x", desc = "Back to main menu", func = function () return true end })

        -- do the screen
        coredisplay.NextScreen({
			clear       = true,
			intro       = "Choose an item",
			option      = options,
			question    = "Make your choice",
		})

        -- screeen complete (fake)
        return true
    end
end

function UserStation:getMainUIMenu()
    --[[
        Get the main (start) UI menu of the UserStation.

        This menu can be used in conjuction with coredisplay.MainMenu.

        Return value:
                                - (table)
                clear           - (boolean) whether or not to clear the display,
                func	        - (function) menu function to call
                param	        - (table, {}) parameter to pass to menu function
                intro           - (string) intro to print
                question        - (string, nil) final question to print
    ]]

    -- end
    return {
        clear       = true,
        func	    = UserStationMenuSearch,
        intro       = "Please type a part of an itemname to order\n",
        param	    = { userStation = self },
        question    = nil
    }
end

function UserStation:getAssignmentFilter()
    --[[
        Get assignment filter for finding the next best Assignment for the UserStation.

        The assignment filter is used to indicate to only accept assignments that satisfy certain conditions. This can e.g. be used
            to only accept assignments with high priority.

        Return value:
            assignmentFilter    - (table) filter to apply in finding an Assignment
    --]]

    -- end
    return {
    }
end

return UserStation
