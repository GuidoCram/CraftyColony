-- navigation.lua
-- Movement and pathfinding utilities for ComputerCraft turtles

local utils = require("lib.utils")

local navigation = {}

-- Direction constants
navigation.DIRECTIONS = {
    NORTH = 0,
    EAST = 1,
    SOUTH = 2,
    WEST = 3
}

-- Current position and facing direction
navigation.position = {x = 0, y = 0, z = 0}
navigation.facing = navigation.DIRECTIONS.NORTH

-- Movement functions
function navigation.forward()
    if turtle.forward() then
        local dx, dz = navigation.getFacingDelta()
        navigation.position.x = navigation.position.x + dx
        navigation.position.z = navigation.position.z + dz
        return true
    end
    return false
end

function navigation.back()
    if turtle.back() then
        local dx, dz = navigation.getFacingDelta()
        navigation.position.x = navigation.position.x - dx
        navigation.position.z = navigation.position.z - dz
        return true
    end
    return false
end

function navigation.up()
    if turtle.up() then
        navigation.position.y = navigation.position.y + 1
        return true
    end
    return false
end

function navigation.down()
    if turtle.down() then
        navigation.position.y = navigation.position.y - 1
        return true
    end
    return false
end

-- Rotation functions
function navigation.turnLeft()
    if turtle.turnLeft() then
        navigation.facing = (navigation.facing - 1) % 4
        return true
    end
    return false
end

function navigation.turnRight()
    if turtle.turnRight() then
        navigation.facing = (navigation.facing + 1) % 4
        return true
    end
    return false
end

-- Get movement delta based on current facing direction
function navigation.getFacingDelta()
    if navigation.facing == navigation.DIRECTIONS.NORTH then
        return 0, -1
    elseif navigation.facing == navigation.DIRECTIONS.EAST then
        return 1, 0
    elseif navigation.facing == navigation.DIRECTIONS.SOUTH then
        return 0, 1
    elseif navigation.facing == navigation.DIRECTIONS.WEST then
        return -1, 0
    end
    return 0, 0
end

-- Face a specific direction
function navigation.faceDirection(targetDirection)
    while navigation.facing ~= targetDirection do
        navigation.turnRight()
    end
end

-- Go to a specific position using simple pathfinding
function navigation.goTo(targetX, targetY, targetZ)
    utils.info(string.format("Moving to position (%d, %d, %d)", targetX, targetY, targetZ))
    
    -- Move in Y direction first
    while navigation.position.y < targetY do
        if not navigation.up() then
            turtle.digUp()
            if not navigation.up() then
                utils.error("Cannot move up")
                return false
            end
        end
    end
    
    while navigation.position.y > targetY do
        if not navigation.down() then
            turtle.digDown()
            if not navigation.down() then
                utils.error("Cannot move down")
                return false
            end
        end
    end
    
    -- Move in X direction
    local deltaX = targetX - navigation.position.x
    if deltaX > 0 then
        navigation.faceDirection(navigation.DIRECTIONS.EAST)
        for i = 1, deltaX do
            if not navigation.forward() then
                turtle.dig()
                if not navigation.forward() then
                    utils.error("Cannot move forward")
                    return false
                end
            end
        end
    elseif deltaX < 0 then
        navigation.faceDirection(navigation.DIRECTIONS.WEST)
        for i = 1, math.abs(deltaX) do
            if not navigation.forward() then
                turtle.dig()
                if not navigation.forward() then
                    utils.error("Cannot move forward")
                    return false
                end
            end
        end
    end
    
    -- Move in Z direction
    local deltaZ = targetZ - navigation.position.z
    if deltaZ > 0 then
        navigation.faceDirection(navigation.DIRECTIONS.SOUTH)
        for i = 1, deltaZ do
            if not navigation.forward() then
                turtle.dig()
                if not navigation.forward() then
                    utils.error("Cannot move forward")
                    return false
                end
            end
        end
    elseif deltaZ < 0 then
        navigation.faceDirection(navigation.DIRECTIONS.NORTH)
        for i = 1, math.abs(deltaZ) do
            if not navigation.forward() then
                turtle.dig()
                if not navigation.forward() then
                    utils.error("Cannot move forward")
                    return false
                end
            end
        end
    end
    
    utils.info("Reached target position")
    return true
end

-- Return to origin
function navigation.returnToOrigin()
    return navigation.goTo(0, 0, 0)
end

-- Set current position (for GPS or manual positioning)
function navigation.setPosition(x, y, z, facing)
    navigation.position.x = x
    navigation.position.y = y
    navigation.position.z = z
    if facing then
        navigation.facing = facing
    end
    utils.info(string.format("Position set to (%d, %d, %d), facing %d", x, y, z, navigation.facing))
end

-- Get current position
function navigation.getPosition()
    return navigation.position.x, navigation.position.y, navigation.position.z, navigation.facing
end

return navigation