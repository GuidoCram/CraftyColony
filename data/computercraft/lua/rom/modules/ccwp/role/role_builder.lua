-- define role
local role_builder = {}

-- ToDo: add proper module description
--[[
    This role ...
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"
local coremove = require "coremove"
local coreinventory = require "coreinventory"

local InputChecker = require "input_checker"
local Location = require "obj_location"

local role_energizer = require "role_energizer"

--    _______        _                   __  __      _        _____        _
--   |__   __|      | |          ___    |  \/  |    | |      |  __ \      | |
--      | | __ _ ___| | _____   ( _ )   | \  / | ___| |_ __ _| |  | | __ _| |_ __ _
--      | |/ _` / __| |/ / __|  / _ \/\ | |\/| |/ _ \ __/ _` | |  | |/ _` | __/ _` |
--      | | (_| \__ \   <\__ \ | (_>  < | |  | |  __/ || (_| | |__| | (_| | || (_| |
--      |_|\__,_|___/_|\_\___/  \___/\/ |_|  |_|\___|\__\__,_|_____/ \__,_|\__\__,_|

function role_builder.BuildBlueprint_MetaData(...)
    -- get & check input from description
    local checkSuccess, blueprintStartpoint, layerList, escapeSequence = InputChecker.Check([[
        This Task builds a blueprint.

        Return value:
                                        - (table) {success = true} if the blueprint was successfully build

        Parameters:
            buildData                   - (table) data about the blueprint
                blueprintStartpoint     + (Location) top lower left coordinate to start building the blueprint
                blueprint               - (table) blueprint to build
                    layerList           + (table) layer to build
                    escapeSequence      + (table) escapeSequence of blueprint
    ]], ...)
    if not checkSuccess then corelog.Error("role_builder.BuildBlueprint_MetaData: Invalid input") return {success = false} end

    local metaData = {
        startTime = coreutils.UniversalTime(),
        location = blueprintStartpoint:copy(),
        needTool = true,
        needTurtle = true,
        fuelNeeded = 0,
        itemsNeeded = {},
    }

    -- loop on layers
    local lastLocation = blueprintStartpoint:copy()
    for i, buildLayer in ipairs(layerList) do
        -- determine buildData for this layer
        local startpoint = Location:new(buildLayer.startpoint)
        local buildDirection = buildLayer.buildDirection
        local layerBuildData = {
            startpoint              = startpoint:getRelativeLocation(blueprintStartpoint:getX(), blueprintStartpoint:getY(), blueprintStartpoint:getZ()),
            buildDirection          = buildDirection,
            replacePresentObjects   = buildLayer.replacePresentObjects,
            layer                   = buildLayer.layer,
        }

        -- get metadata for layer
        local layerMetaData = role_builder.BuildLayer_MetaData(layerBuildData)
        if not layerMetaData then corelog.Error("role_builder.BuildBlueprint_MetaData: Failed obtaining layerMetaData") return {success = false} end

        -- determine startLocation (correcting for buildDirection)
        local offsetX = 0
        local offsetY = 0
        local offsetZ = 0
        if buildDirection == "Down" then
            offsetZ = 1
        elseif buildDirection == "Up" then
            offsetZ = -1
        elseif buildDirection == "Front" then
            offsetX = -startpoint:getDX() -- note: in "Front" so -dx or -dy
            offsetY = -startpoint:getDY()
        else
            corelog.Error("role_builder.BuildBlueprint_MetaData: Don't know how to determine offsets for buildDirection '"..buildDirection.."'") return {success = false}
        end
        local startLocation = layerBuildData.startpoint:getRelativeLocation(offsetX, offsetY, offsetZ)

        -- update blueprint metadata
        metaData.fuelNeeded = metaData.fuelNeeded + role_energizer.NeededFuelToFrom(startLocation, lastLocation) + layerMetaData.fuelNeeded
        for layerItemName, layerItemCount in pairs(layerMetaData.itemsNeeded) do
            -- increment item counter
            metaData.itemsNeeded[layerItemName] = (metaData.itemsNeeded[layerItemName] or 0) + layerItemCount
        end

        -- remember last location
        local lastX = offsetX + layerBuildData.layer:getNColumns()
        local lastY = offsetY
        if buildDirection == "Down" or buildDirection == "Up" then
            lastY = lastY + layerBuildData.layer:getNRows()
        end
        local lastZ = offsetZ
        if buildDirection == "Front" then
            lastZ = lastZ + layerBuildData.layer:getNRows()
        end
        lastLocation = startpoint:getRelativeLocation(lastX, lastY, lastZ)
    end

    -- update metadata with escapeSequence (if present)
    for i, escapeLocation in ipairs(escapeSequence) do
        escapeLocation = Location:new(escapeLocation)
        metaData.fuelNeeded = metaData.fuelNeeded + role_energizer.NeededFuelToFrom(escapeLocation, lastLocation)

        lastLocation = escapeLocation
    end

    return metaData
end

function role_builder.BuildBlueprint_Task(...)
    -- get & check input from description
    local checkSuccess, blueprintStartpoint, layerList, escapeSequence = InputChecker.Check([[
        This Task builds a blueprint.

        Return value:
                                        - (table) {success = true} if the blueprint was successfully build

        Parameters:
            buildData                   - (table) data about the blueprint
                blueprintStartpoint     + (Location) top lower left coordinate to start building the blueprint
                blueprint               - (table) blueprint to build
                    layerList           + (table) layer to build
                    escapeSequence      + (table) escapeSequence of blueprint
    ]], ...)
    if not checkSuccess then corelog.Error("role_builder.BuildBlueprint_Task: Invalid input") return {success = false} end

    -- go to blueprintStartpoint
    coremove.GoTo(blueprintStartpoint, false) -- note: not forcing, to ensure we do not destroy other structures
    -- ToDo: consider using start sequence

    -- loop on layers
    for i, buildLayer in ipairs(layerList) do
        local buildDirection = buildLayer.buildDirection

        -- determine buildData for this layer
        local startpoint = Location:new(buildLayer.startpoint)
        local layerBuildData = {
            startpoint              = startpoint:getRelativeLocation(blueprintStartpoint:getX(), blueprintStartpoint:getY(), blueprintStartpoint:getZ()),
            forceToStartPoint       = true, -- note: forcing, to ensure we get to the layer startpoint directly (blueprint's should ensure this doesn't destroy anything!)
            buildDirection          = buildDirection,
            replacePresentObjects   = buildLayer.replacePresentObjects,
            layer                   = buildLayer.layer,
        }

        -- build layer using internal task
        local result = role_builder.BuildLayer_Task(layerBuildData)
        if result.success ~= true then
            corelog.Error("role_builder.BuildBlueprint_Task: Failed building layer " ..i..". Remaining layers skipped.")
            return {success = false}
        end
    end

    -- perform escape sequence
    for i, escapeLocation in ipairs(escapeSequence) do
        escapeLocation = Location:new(escapeLocation)
        coremove.GoTo(blueprintStartpoint:getRelativeLocation(escapeLocation:getX(), escapeLocation:getY(), escapeLocation:getZ()), false) -- note: not forcing, to ensure we do not destroy created structures
    end

    return {success = true}
end

function role_builder.BuildLayer_MetaData(...)
    -- get & check input from description
    local checkSuccess, startpoint, buildDirection, layer = InputChecker.Check([[
        This function returns the MetaData for BuildLayer_Task

        Return value:
                                        - (table) metadata

        Parameters:
            buildData                   - (table) data about the layer
                startpoint              + (Location) lower left coordinate to start building the layer
                buildDirection          + (string) direction to build from (Up, Down, XXX)
                replacePresentObjects   - (boolean, false) whether objects should be replaced if it is already present in the minecraft world
                layer                   + (LayerRectangle) layer to build
    ]], ...)
    if not checkSuccess then corelog.Error("role_builder.BuildLayer_MetaData: Invalid input") return nil end

    -- determine needed items
    local itemList = layer:itemsNeeded()
    local fuelNeeded = (layer:getNColumns() * layer:getNRows() - 1)

    -- determine startLocation (correcting for buildDirection)
    local offsetX = 0
    local offsetY = 0
    local offsetZ = 0
    if buildDirection == "Down" then
        offsetZ = 1
    elseif buildDirection == "Up" then
        offsetZ = -1
    elseif buildDirection == "Front" then
        offsetX = -startpoint:getDX() -- note: in "Front" so -dx or -dy
        offsetY = -startpoint:getDY()
    else
        corelog.Error("role_builder.BuildLayer_MetaData: Don't know how to determine offsets for buildDirection '"..buildDirection.."'") return nil
    end
    local startLocation = startpoint:getRelativeLocation(offsetX, offsetY, offsetZ)

    -- return metadata
    return {
        startTime = coreutils.UniversalTime(),
        location = startLocation,
        needTool = true,
        needTurtle = true,
        fuelNeeded = fuelNeeded,
        itemsNeeded = itemList
    }
end

function role_builder.BuildLayer_Task(...)
    -- get & check input from description
    local checkSuccess, startpoint, forceToStartPoint, buildDirection, replacePresentObjects, layer = InputChecker.Check([[
        This Task builds a rectangular layer in the x,y plane.

        Return value:
                                        - (table) {success = true} if the layer was successfully build

        Parameters:
            buildData                   - (table) data about the layer
                startpoint              + (Location) lower left coordinate to start building the layer
                forceToStartPoint       + (boolean, false) whether to force going to startpoint
                buildDirection          + (string) direction to build from (Up, Down, XXX)
                replacePresentObjects   + (boolean, false) whether objects should be replaced if it is already present in the minecraft world
                layer                   + (LayerRectangle) layer to build
    ]], ...)
    if not checkSuccess then corelog.Error("role_builder.BuildLayer_Task: Invalid input") return {success = false} end

    -- check mandatory pickage!
    local axePresent = coreinventory.Equip("minecraft:diamond_pickaxe")
    if not axePresent then corelog.Error("role_builder.BuildLayer_Task: No pickaxe present, we are on strike!") return {success = false} end

    -- check if inventory has what we need
    local itemList = layer:itemsNeeded()
    for itemName, itemCount in pairs(itemList) do
        -- get items in inventory
        local inventoryItemCount = coreinventory.CountItem(itemName)

        -- enough?
        if inventoryItemCount < itemCount then
            corelog.Warning("role_builder.BuildLayer_Task: Not enough(="..itemCount..") "..itemName.." (="..inventoryItemCount..") in inventory to build the layer")
        end
    end

    -- corelog.WriteToLog("startpoint: "..textutils.serialise(startpoint, {compact = true}))

    -- offsets
    local offsetX = 0
    local offsetY = 0
    local offsetZ = 0
    if buildDirection == "Down" then
        offsetZ = 1
    elseif buildDirection == "Up" then
        offsetZ = -1
    elseif buildDirection == "Front" then
        offsetX = -startpoint:getDX()
        offsetY = -startpoint:getDY()
    else
        corelog.Error("role_builder.BuildLayer_Task: Don't know how to determine offsets for buildDirection '"..buildDirection.."'") return {success = false}
    end

    -- go to starting location
    local startLocation = startpoint:getRelativeLocation(offsetX, offsetY, offsetZ)
    -- corelog.WriteToLog("startLocation: "..textutils.serialise(startLocation, {compact = true}))
    coremove.GoTo(startLocation, forceToStartPoint)

    -- walk along columns
    for col=1, layer:getNColumns() do
        -- walk along rows
        for iRow=1, layer:getNRows() do
            -- determine row value such that path is back and forth (or up and down) in rows
            local row = iRow
            if col % 2 == 0 then
                row = layer:getNRows() + 1 - iRow
            end

            -- go to location
            local x = col - 1
            if buildDirection == "Down" or buildDirection == "Up" then
                local y = row - 1
                local location = startpoint:getRelativeLocation(offsetX + x, offsetY + y, offsetZ)
                -- corelog.WriteToLog("location: "..textutils.serialise(location, {compact = true}).."  ("..col..","..row..")")
                coremove.MoveTo(location, true)
            elseif buildDirection == "Front" then
                local z = row - 1
                local location = startpoint:getRelativeLocation(offsetX + x, offsetY, offsetZ + z)
                -- corelog.WriteToLog("location: "..textutils.serialise(location, {compact = true}).."  ("..col..","..row..")")
                coremove.GoTo(location, true)
            end


            -- get block
            local block = layer:getBlock(col, row)
            if not block then corelog.Error("role_builder.BuildLayer_Task: No block at ("..col..","..row..")") return {success = false} end

            -- check block type
            if block:isMinecraftItem() or block:isComputercraftItem() then
                -- optionally turn in specific direction
                if block:hasValidDirection() then
                    if buildDirection == "Front" then
                        corelog.Warning("role_builder.BuildLayer_Task: Turning not very usefull for buildDirection '"..buildDirection.."'")
                    end
                    -- turn in the right direction
                    coremove.TurnTo({_dx = block:getDx(), _dy = block:getDy()})
                end

                -- check current block present
                local has_block, block_data
                if not replacePresentObjects then
                    if buildDirection == "Down" then
                        has_block, block_data = turtle.inspectDown()
                    elseif buildDirection == "Up" then
                        has_block, block_data = turtle.inspectUp()
                    elseif buildDirection == "Front" then
                        has_block, block_data = turtle.inspect()
                    end
                end

                -- check placing object
                local block_name = block:getName()
                if replacePresentObjects or not has_block or type(block_data) ~= "table" or block_data.name ~= block_name then
                    -- place block
                    if coreinventory.SelectItem(block_name) then
                        if buildDirection == "Down" then
                            turtle.digDown()
                            turtle.placeDown()
                        elseif buildDirection == "Up" then
                            turtle.digUp()
                            turtle.placeUp()
                        elseif buildDirection == "Front" then
                            turtle.dig()
                            turtle.place()
                        end
                    else
                        -- mandatory item not in inventory, error message and ignore
                        corelog.WriteToLog("Oops, BuildLayer_Task item not in inventory: "..block_name)
                    end
                end
            elseif block:isNoneBlock() then
                -- clear block
                if buildDirection == "Down" then
                    turtle.digDown()
                elseif buildDirection == "Up" then
                    turtle.digUp()
                elseif buildDirection == "Front" then
                    turtle.dig()
                end
            elseif block:isAnyBlock() then
                -- leave current block be
            end
        end
    end

    return {success = true}
end

return role_builder
