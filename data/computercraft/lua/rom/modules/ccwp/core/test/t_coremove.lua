local t_coremove = {}

local corelog = require "corelog"
local coremove = require "coremove"

function t_coremove.T_GoHome()
    coremove.GoTo({
        _x	= 0,
        _y	= 0,
        _z	= 1,
        _dx	= 0,
        _dy	= 1,
    })
end

function t_coremove.T_GoBase()
    -- get current Turtle
    local enterprise_employment = require "enterprise_employment"
    local t_employment = require "test.t_employment"
    local currentTurtleLocator = t_employment.GetCurrentTurtleLocator()
    local currentTurtle = enterprise_employment:getObj(currentTurtleLocator) assert(currentTurtle, "Failed obtaining currentTurtle")

    -- move to baseLocation
    local baseLocation = currentTurtle:getBaseLocation()
    coremove.GoTo(baseLocation)
end

function t_coremove.T_GoToLeftHome()
    coremove.GoTo({
        _x  = -24,
        _y	= 0,
        _z	= 1,
        _dx	= 0,
        _dy	= 1,
    })
end

function t_coremove.T_GoToRightHome()
    coremove.GoTo({
        _x	= 24,
        _y	= 0,
        _z	= 1,
        _dx	= 0,
        _dy	= 1,
    })
end

function t_coremove.T_GoStart()
    coremove.GoTo({_x= 3, _y= 2, _z= 1, _dx=0, _dy=1})
end

function t_coremove.T_GoDeep()
    coremove.Down(500, true)
end

function t_coremove.T_Status()
    coremove.Status()
end

function t_coremove.T_Reset()
    coremove.SetLocation({
        _x	= 0,
        _y	= 0,
        _z	= 1,
        _dx	= 0,
        _dy	= 1,
    })
end

function t_coremove.T_DeFuel()
    while turtle.getFuelLevel() > 2*24 do
        t_coremove.T_GoToLeftHome()

        t_coremove.T_GoHome()

        corelog.WriteToLog(" deFueled to "..turtle.getFuelLevel())
    end

    while turtle.getFuelLevel() > 2*5 do
        t_coremove.T_GoStart()

        t_coremove.T_GoHome()

        corelog.WriteToLog(" deFueled to "..turtle.getFuelLevel())
    end
end

return t_coremove
