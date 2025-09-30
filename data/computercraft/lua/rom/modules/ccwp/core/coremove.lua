-- define module
local coremove = {}

-- ToDo: add proper module description
--[[
    This module ...
--]]

local coreinventory = require "coreinventory"
local coreutils = require "coreutils"
local corelog = require "corelog"
local coretask = require "coretask"

-- the table that stores the data
local db = {
    x  = 0,
    y  = 0,
    z  = 0,
    dx = 0,
    dy = 1,
}

-- for writing db to file
local filename			= "/db/move.lua"
local writeToFileQueued	= false
local queueWriteToFile	= false

-- moving forward, up, down and turning all need 8 ticks (0.40 sec) to complete
-- turtle.select takes 1 tick (0.05 second)

local function Reset()
    db = {
        x	= 0,
        y	= 0,
        z	= 0,
        dx	= 0,
        dy	= 1,
    }
end

function coremove.Init()
    -- read last known location from file
    db = coreutils.ReadTableFromFile(filename)

    -- reset if the location from file was not valid
    if not db or db.x == nil then Reset() end
end

function coremove.Setup()
    -- Status()
end

function coremove.Status()
    if turtle then
        print( "Location:" )
        print( "x: " .. db.x )
        print( "y: " .. db.y )
        print( "z: " .. db.z )
        print( "Direction:" )
        print( "x: " .. db.dx )
        print( "y: " .. db.dy )
        print( "Fuel:" )
        print( turtle.getFuelLevel() )
    end
end

local function SaveDBToFile()
    -- debug
    --corelog.WriteToLog("coremove-> SaveDBToFile(): starting, writeToFileQueued = "..tostring(writeToFileQueued)..", z="..tostring(db.z))

    -- no longer in the queue since we are doing it now
    writeToFileQueued = false

    -- save the db table to a file (this may take some time with larger dht's)
    coreutils.WriteToFile(filename, db, "overwrite")
end

local function SaveDB()
    -- debug
    --corelog.WriteToLog("coremove-> SaveDB(): starting, writeToFileQueued = "..tostring(writeToFileQueued)..", z="..tostring(db.z))

    -- save the db table to a file
    if not writeToFileQueued then

        -- now it is in the queue
        writeToFileQueued = true

        -- add to the work queue
        if queueWriteToFile then
            coretask.AddWork(SaveDBToFile, nil, "coremove.SaveDBToFile()")
        else
            SaveDBToFile()
        end
    end
end

function coremove.Left(c)
    -- init parameter
    c = c or 1
    c = math.floor(c + 0.5) or 1

    -- loop
    for n=1,c do
        -- remember direction
        local ox = db.dx
        local oy = db.dy

        -- do the turn!
        turtle.turnLeft()

        -- new direction
        db.dx = -1 * oy
        db.dy = ox

        -- save new direction right away
        SaveDB()
    end
end

function coremove.Right(c)
    -- init parameter
    c = c or 1
    c = math.floor(c + 0.5)

    -- loop
    for n=1,c do

        -- remember direction
        local ox = db.dx
        local oy = db.dy

        -- do the turn!
        turtle.turnRight()

        -- new direction
        db.dx = oy
        db.dy = -1 * ox

        -- save new direction right away
        SaveDB()
    end
end

function coremove.Forward(c, force, callback)
    -- callback will be called when turtle cannot move (goes before using force)
    -- coremove.Forward() expects the callback to return the turtle to the position it was when running the callback!


    -- init parameter
    c = c or 1
    c = math.floor(c + 0.5)

    -- loop the movement
    for i=1,c do

        -- keep trying
        local tries		= 0
        local success	= turtle.forward()

        -- not moved but a callback has been given	-- ToDo: Check for location change, not allowed for the callback
        if not success and type(callback) == "function" then success = callback() end

        -- if it did not work, attack the space in front of us
        if not success and force then

            -- dimond pickaxe gebruiken
            if coreinventory.CanEquip("minecraft:diamond_pickaxe") or coreinventory.CanEquip("minecraft:diamond_sword") then

                -- net zo lang proberen totdat het wel lukt
                while not success do

                    -- do our magic
                    coreinventory.Equip("minecraft:diamond_pickaxe")
                    turtle.dig()
--					coreinventory.Equip("minecraft:diamond_sword")
                    turtle.attack()
                    sleep(0.1)

                    -- update how often we tried so far
                    tries = tries + 1
                    if tries > 50 then print("Error: can't move forward.") return false end

                    -- retry
                    success = turtle.forward()
                end
            end
        end

        -- did we move?
        if success then

            -- update db
            db.x = db.x + db.dx
            db.y = db.y + db.dy

            -- save db
            SaveDB()
        end
    end

    -- done successfully
    return true
end

function coremove.Backward(c, force, callback)
    -- callback will be called when turtle cannot move (goes before using force)
    -- coremove.Backward() expects the callback to return the turtle to the position it was when running the callback!

    -- init parameter
    c = c or 1
    c = math.floor(c + 0.5)

    -- loop
    for i=1,c do

        -- can we move backward?
        local success = turtle.back()

        -- not moved but a callback has been given?	-- ToDo: Check for location change, not allowed for the callback
        if not success and type(callback) == "function" then success = callback() end

        -- still not moved?
        if success then

            -- update db
            db.x = db.x - db.dx
            db.y = db.y - db.dy

            -- save db
            SaveDB()

        -- force might be the solution!
        else if force then

            -- turn around to attack the block
            coremove.Left(2)
            success = coremove.Forward(1, force)
            coremove.Right(2)

            -- did it work?
            if not success then return false end
        else
            -- we are not using force, but we cannot move backwards
            return false
        end end
    end

    -- still here means we were successfull (ofcourse)
    return true
end

function coremove.Up(c, force, callback)
    -- callback will be called when turtle cannot move (goes before using force)
    -- coremove.Up() expects the callback to return the turtle to the position it was when running the callback!

    -- init parameter
    c = c or 1
    c = math.floor(c + 0.5)

    -- loop
    for i=1,c do
        local tries = 0
        local success = turtle.up()

        -- not moved but a callback has been given	-- ToDo: Check for location change, not allowed for the callback
        if not success and type(callback) == "function" then success = callback() end

        -- did we move up?
        while not success and force do

            -- use force
            turtle.digUp()
            turtle.attackUp()
            sleep(0.1)

            -- update how ofter we tried
            tries = tries + 1
            if tries>50 then print("Error: can't move up.") return false end

            -- give it another try
            success = turtle.up()
        end

        -- successfull?
        if success then

            -- update location
            db.z = db.z + 1

            -- dave location
            SaveDB()
        end
    end

    -- we did it!
    return true
end

function coremove.Down(c, force, callback)
    -- callback will be called when turtle cannot move (goes before using force)
    -- coremove.Down() expects the callback to return the turtle to the position it was when running the callback!

    -- init parameter
    c = c or 1
    c = math.floor(c + 0.5)

    -- loop
    for i=1,c do
        local tries = 0
        local success = turtle.down()

        -- not moved but a callback has been given	-- ToDo: Check for location change, not allowed for the callback
        if not success and type(callback) == "function" then success = callback() end

        -- did we go down?
        while not success and force do

            -- let's use force
            turtle.digDown()
            turtle.attackDown()
            sleep(0.2)

            -- update how often we tried
            tries = tries + 1
            if tries>50 then print("Error: can't move down.") return false end

            -- try again
            success = turtle.down()
        end

        -- did we managed to go down?
        if success then

            -- update location
            db.z = db.z - 1

            -- save location
            SaveDB()
        end
    end

    -- we went down
    return true
end

function ToBottom()
    -- simple loop going down, without force
      while turtle.down() do

        -- keep track of our location
        db.z = db.z - 1

        -- save our location
        SaveDB()
    end

    -- will always work, might have done zero steps down though
      return true
end
--[[
function NeedTorch()
  local x = db.x
  local y = db.y
  local z = db.z

  if y/6 == math.floor(y/6) and z/4 == math.floor(z/4) then
    local bonus
    if y/12 == math.floor(y/12) then
      bonus = 0
    else
      bonus = 3
    end
    return ((x+bonus)/6) == math.floor((x+bonus)/6)
  else
    return false
  end
end
function NeedSappling()
  local x = db.x
  local y = db.y + 3
  local z = db.z

  if y/6 == math.floor(y/6) and z/4 == math.floor(z/4) then
    local bonus
    if y/12 == math.floor(y/12) then
      bonus = 0
    else
      bonus = 3
    end
    return ((x+bonus)/6) == math.floor((x+bonus)/6)
  else
    return false
  end
end
--]]
function coremove.GetLocation()
    -- returns current location as a new table ToDo: return a location object
    return {
        _x = db.x,
        _y = db.y,
        _z = db.z,
        _dx = db.dx,
        _dy = db.dy,
    }
end

function coremove.GetLocationAsString()
    return "Location: ("..db.x..", "..db.y..", "..db.z..")"
end

function coremove.GetDirectionAsString()
    return "Direction: ("..db.dx..", "..db.dy..")"
end

function GetLocationFront( c )
    c = c or 1
    return {
        x = db.x + c * db.dx,
        y = db.y + c * db.dy,
        z = db.z,
        dx = db.dx,
        dy = db.dy,
    }
end

function GetLocationUp( c )
    c = c or 1
    return {
        x = db.x,
        y = db.y,
        z = db.z + c,
        dx = db.dx,
        dy = db.dy,
    }
end

function GetLocationDown( c )
    c = c or 1
    return {
        x = db.x,
        y = db.y,
        z = db.z - c,
        dx = db.dx,
        dy = db.dy,
    }
end

function coremove.SetLocation(location)
    -- set to memory
    db = {
        x	= location._x,
        y	= location._y,
        z	= location._z,
        dx	= location._dx,
        dy	= location._dy
    }

    -- save to file
    SaveDB()
end

function GetDepth()
    return db.z
end

function Above( t )
    return {
        x = t.x,
        y = t.y,
        z = t.z + 1,
        dx = t.xy,
        dy = t.dy,
    }
end

function Nextto( target, pref )
    local temp = target
    pref = pref or "x"

    -- maybe the y axis is preffered
    if pref == "y" and db.y ~= target.y then
        if db.y < target.y	then temp.y = temp.y - 1
                            else temp.y = temp.y + 1
        end
    -- maybe the x axis is usable
    elseif db.x ~= target.x then
        if db.x < target.x	then temp.x = temp.x - 1
                            else temp.x = temp.x + 1
        end
    -- maybe the y axis anyways
    elseif db.x ~= target.x then
        if db.y < target.y	then temp.y = temp.y - 1
                            else temp.y = temp.y + 1
        end
    else
        print("Cannot move next to, already same x and same y")
    end

    return temp -- BUG? is temp meant here???
end

function Below( t )
    return {
        x = t.x,
        y = t.y,
        z = t.z - 1,
        dx = t.xy,
        dy = t.dy,
    }
end

local function SimpleMoveTo(l, force, callback)
    -- local function, checking parameter no longer done, you take care of that yourself!

    -- might be a difficult route, try more times
    for i=1,3 do
        -- first, get to the right z
        if l._z > db.z	then coremove.Up(l._z - db.z, force, callback) end

        -- next is the right y
        if l._y > db.y then coremove.TurnTo({ _dx = 0, _dy =  1 })
        elseif l._y < db.y then coremove.TurnTo({ _dx = 0, _dy = -1 })
        end
        coremove.Forward( math.abs( l._y - db.y ), force, callback)

        -- next is the right x
                if l._x > db.x then coremove.TurnTo({ _dx =  1, _dy = 0 })
        elseif l._x < db.x then coremove.TurnTo({ _dx = -1, _dy = 0 })
        end
        coremove.Forward( math.abs( l._x - db.x ), force, callback)

        -- now go down
        if l._z < db.z then coremove.Down(db.z - l._z, force, callback) end
    end
end

function coremove.MoveTo(l, force, callback)
    if l == nil then
        print("Cannot move to nil location")
        corelog.WriteToLog("function coremove.MoveTo: Cannot move to nil location")
        corelog.WriteToLog(debug.traceback())
        return false
    end

    -- might be partly given coordinates, enricht with the current coordinates
    l._x  = l._x  or db.x
    l._y  = l._y  or db.y
    l._z  = l._z  or db.z
    l._dx = l._dx or db.dx
    l._dy = l._dy or db.dy

    -- do the movement
    SimpleMoveTo(l, force, callback)

    -- did we get there?
    if l._x ~= db.x or l._y ~= db.y or l._z ~= db.z then

        -- we are clearly stuck, might be good to move upwards and try again
        local targetZ	= l._z
        l._z			= 2

        -- try again
        SimpleMoveTo(l, force, callback)

        -- and now to the requested location
        l._z			= targetZ
        SimpleMoveTo(l, force, callback)
    end
end

function coremove.TurnTo( t )
    if t == nil then
        print("Cannot turn to nil location")
        corelog.WriteToLog("function coremove.TurnTo: Cannot turn to nil location")
        corelog.WriteToLog(debug.traceback())
        return false
    end

    -- check input
    if t._dx * t._dy ~= 0 or math.abs( t._dx + t._dy ) ~= 1 then
        print("coremove.TurnTo( "..t._dx..", "..t._dy.."): Invalid direction")
        return false
    end

    -- make a left turn?
    if t._dx == -1 * db.dy and t._dy == db.dx then
        coremove.Left(1)
    else
        -- make the turn right
        while t._dx ~= db.dx or t._dy ~= db.dy do
            coremove.Right(1)
        end
    end
end

function coremove.GoTo(l, force, callback)
    coremove.MoveTo(l, force, callback)
    coremove.TurnTo(l)
end

return coremove
