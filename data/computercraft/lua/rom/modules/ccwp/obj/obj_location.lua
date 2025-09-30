-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local Location = Class.NewClass(ObjBase)

--[[
    This module implements the class Location.

    A Location is a position and a direction in the minecraft world.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function Location:_init(...)
    -- get & check input from description
    local checkSuccess, x, y, z, dx, dy = InputChecker.Check([[
        Initialise a Location.

        Parameters:
            x                       + (number, 0) x coordinate
            y                       + (number, 0) y coordinate
            z                       + (number, 0) z coordinate
            dx                      + (number, 0) x direction (either -1,0,1)
            dy                      + (number, 1) y direction (either -1,0,1)
    ]], ...)
    if not checkSuccess then corelog.Error("Location:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._x     = x
    self._y     = y
    self._z     = z
    self._dx    = dx
    self._dy    = dy
end

-- ToDo: should be renamed to newFromTable at some point
function Location:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a Location from table.

        Parameters:
            o                       + (table, {}) table with object fields
                _x                  - (number, 0) x coordinate
                _y                  - (number, 0) y coordinate
                _z                  - (number, 0) z coordinate
                _dx                 - (number, 0) x direction (either -1,0,1)
                _dy                 - (number, 1) y direction (either -1,0,1)
    ]], ...)
    if not checkSuccess then corelog.Error("Location:new: Invalid input") return {} end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function Location:getX()
    return self._x
end

function Location:setX(x)
    self._x = x
end

function Location:getY()
    return self._y
end

function Location:setY(y)
    self._y = y
end

function Location:getZ()
    return self._z
end

function Location:setZ(z)
    self._z = z
end

function Location:getDX()
    return self._dx
end

-- todo: controle of dx en dy samen een logisch geheel zijn
function Location:setDX(dx)
    self._dx = dx
end

function Location:getDY()
    return self._dy
end

-- todo: controle of dx en dy samen een logisch geheel zijn
function Location:setDY(dy)
    self._dy = dy
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function Location:getClassName()
    return "Location"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function Location:reset()
    self._x = 0
    self._y = 0
    self._z	= 0
    self._dx = 0
    self._dy = 1
end

function Location:getLocationFront( c )
    c = c or 1
    return Location:newInstance(
        self._x + c * self._dx,
        self._y + c * self._dy,
        self._z,
        self._dx,
        self._dy
    )
end

function Location:getLocationUp( c )
    c = c or 1
    return Location:newInstance(
        self._x,
        self._y,
        self._z + c,
        self._dx,
        self._dy
    )
end

function Location:getLocationDown( c )
    c = c or 1
    return Location:newInstance(
        self._x,
        self._y,
        self._z - c,
        self._dx,
        self._dy
    )
end

function Location:minLocation(o)
    return Location:newInstance(
        math.min(self._x, o._x),
        math.min(self._y, o._y),
        math.min(self._z, o._z),
        math.min(self._dx, o._dx),
        math.min(self._dy, o._dy)
    )
end

function Location:maxLocation(o)
    return Location:newInstance(
        math.max(self._x, o._x),
        math.max(self._y, o._y),
        math.max(self._z, o._z),
        math.max(self._dx, o._dx),
        math.max(self._dy, o._dy)
    )
end

function Location:getDivergentDirection(dx, dy)
    return Location:newInstance(
        self._x,
        self._y,
        self._z,
        dx,
        dy
    )
end

function Location:getRelativeLocation(addX, addY, addZ)
    return Location:newInstance(
        self._x + addX,
        self._y + addY,
        self._z + addZ,
        self._dx,
        self._dy
    )
end

function Location:getRelativeLocationFront(steps)
    -- default
    steps	= steps or 1

    -- done before we started :-)
    return Location:newInstance(
        self._x + steps * self._dx,
        self._y + steps * self._dy,
        self._z,
        self._dx,
        self._dy
    )
end

function Location:getRelativeLocationUp(steps)
    -- default
    steps	= steps or 1

    -- done before we started :-)
    return Location:newInstance(
        self._x,
        self._y,
        self._z + steps,
        self._dx,
        self._dy
    )
end

function Location:getRelativeLocationDown(steps)
    -- default
    steps	= steps or 1

    -- done before we started :-)
    return Location:newInstance(
        self._x,
        self._y,
        self._z - steps,
        self._dx,
        self._dy
    )
end

function Location:getRelativeLocationLeft(steps)
    -- default
    steps	= steps or 1
    steps	= math.fmod(steps, 4)

    -- make a deep copy of the location
    local newLocation = self:copy()

    -- do as requested
    for turn=1, steps do
        -- don't forget those
        local oldX		= newLocation._dx
        local oldY		= newLocation._dy

        -- new direction
        newLocation._dx	= -1 * oldY
        newLocation._dy	= oldX
    end

    -- this is where we ended
    return newLocation
end

function Location:getRelativeLocationRight(steps)
    -- default
    steps	= steps or 1
    steps	= math.fmod(steps, 4)

    -- make a deep copy of the location
    local newLocation = self:copy()

    -- do as requested
    for turn=1, steps do
        -- don't forget those
        local oldX		= newLocation._dx
        local oldY		= newLocation._dy

        -- new direction
        newLocation._dx	= oldY
        newLocation._dy	= -1 * oldX
    end

    -- this is where we ended
    return newLocation
end

function Location:getWorkingLocation(...)
    -- get & check input from description
    local checkSuccess, accessDirection = InputChecker.Check([[
        This function returns the working location (including orientation) to access an MObj from an 'accessDirection'.

        Return value:
                            - (table) working location

        Parameters:
            accessDirection + (string) whether to access MObj from "bottom", "top", "left", "right", "front" or "back" (relative to location)
    ]], ...)
    if not checkSuccess then corelog.Error("Location:getWorkingLocation: Invalid input") return nil end

    -- determine workingLocation from accessDirection, i.e. "bottom", "top", "left", "right", "front" or "back"
    local workingDirection = self:copy()
    if accessDirection == "bottom" then
        workingDirection = workingDirection:getRelativeLocationDown()
    elseif accessDirection == "top" then
        workingDirection = workingDirection:getRelativeLocationUp()
    elseif accessDirection == "left" then
        workingDirection = workingDirection:getRelativeLocationRight()
        workingDirection = workingDirection:getRelativeLocationFront(- 1) -- back
    elseif accessDirection == "right" then
        workingDirection = workingDirection:getRelativeLocationLeft()
        workingDirection = workingDirection:getRelativeLocationFront(- 1) -- back
    elseif accessDirection == "front" then
        workingDirection = workingDirection:getRelativeLocationFront()
        workingDirection = workingDirection:getRelativeLocationLeft(2) -- ensure facing back to location
    elseif accessDirection == "back" then
        workingDirection = workingDirection:getRelativeLocationFront(- 1) -- back
    else corelog.Error("Location:getWorkingLocation: Unsupported accessDirection="..accessDirection) return nil end

    -- end
    return workingDirection
end

function Location:blockDistanceTo(o)
    -- check input
    if not Class.IsInstanceOf(o, Location) then corelog.Warning("Location:blockDistanceTo: object not a Location (type="..type(o)..")") return Location.FarX() + Location.FarY() + Location.FarZ() end

    return math.abs(o._x - self._x) + math.abs(o._y - self._y) + math.abs(o._z - self._z)
end

--        _        _   _                       _   _               _
--       | |      | | (_)                     | | | |             | |
--    ___| |_ __ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| __/ _` | __| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ || (_| | |_| | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\__\__,_|\__|_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function Location.FarX()
    return 99999
end

function Location.FarY()
    return 99999
end

function Location.FarZ()
    return 99999
end

function Location.FarLocation()
    return Location:newInstance(Location.FarX(), Location.FarY(), Location.FarZ())
end

-- ToDo: find a better module for this code
function Location.ConvertAccessDirectionToPeripheralName(...)
    -- get & check input from description
    local checkSuccess, accessDirection = InputChecker.Check([[
        Converts an accessDirection to a MObj to the peripheralName for the Worker standing next to the MObj.

        Parameters:
            accessDirection         + (string) whether to access a MObj from "bottom", "top", "left", "right", "front" or "back"
    ]], ...)
    if not checkSuccess then corelog.Error("Location.ConvertAccessDirectionToPeripheralName: Invalid input") return nil end

    -- determine peripheralName from accessDirection
    local peripheralName = accessDirection
    if accessDirection == "bottom" then
        peripheralName = "top"
    elseif accessDirection == "top" then
        peripheralName = "bottom"
    elseif accessDirection == "front" then
        peripheralName = "front"
    elseif accessDirection == "back" then
        peripheralName = "front"
    elseif accessDirection == "left" then
        peripheralName = "front"
    elseif accessDirection == "right" then
        peripheralName = "front"
    else
        corelog.Error("Location.ConvertAccessDirectionToPeripheralName: Don't know how to handle accessDirection "..accessDirection..".") return nil
    end

    -- end
    return peripheralName
end

return Location
