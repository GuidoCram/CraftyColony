-- communication.lua
-- Turtle communication protocols and networking utilities

local utils = require("lib.utils")

local communication = {}

-- Communication settings
communication.config = {
    networkProtocol = "craftycolony",
    broadcastChannel = 1000,
    responseTimeout = 5,
    maxRetries = 3
}

-- Message types
communication.MESSAGE_TYPES = {
    PING = "ping",
    PONG = "pong",
    STATUS_REQUEST = "status_request",
    STATUS_RESPONSE = "status_response",
    TASK_ASSIGNMENT = "task_assignment",
    TASK_COMPLETE = "task_complete",
    RESOURCE_REQUEST = "resource_request",
    RESOURCE_OFFER = "resource_offer",
    EMERGENCY = "emergency",
    SHUTDOWN = "shutdown"
}

-- Initialize communication
function communication.init(turtleId)
    if not rednet then
        utils.error("Rednet not available - ensure wireless modem is attached")
        return false
    end
    
    -- Find and open modem
    local sides = {"top", "bottom", "left", "right", "front", "back"}
    local modemFound = false
    
    for _, side in ipairs(sides) do
        if peripheral.getType(side) == "modem" then
            rednet.open(side)
            modemFound = true
            utils.info("Opened modem on " .. side)
            break
        end
    end
    
    if not modemFound then
        utils.error("No wireless modem found")
        return false
    end
    
    -- Set up hostname
    if turtleId then
        rednet.host(communication.config.networkProtocol, turtleId)
        utils.info("Communication initialized for turtle: " .. turtleId)
    else
        utils.info("Communication initialized (no turtle ID set)")
    end
    
    return true
end

-- Send a message to a specific turtle
function communication.sendMessage(targetId, messageType, data)
    local message = {
        type = messageType,
        sender = os.getComputerID(),
        timestamp = os.epoch("utc"),
        data = data or {}
    }
    
    if targetId then
        rednet.send(targetId, message, communication.config.networkProtocol)
        utils.info(string.format("Sent %s message to %s", messageType, targetId))
    else
        utils.error("No target ID specified")
        return false
    end
    
    return true
end

-- Broadcast a message to all turtles
function communication.broadcast(messageType, data)
    local message = {
        type = messageType,
        sender = os.getComputerID(),
        timestamp = os.epoch("utc"),
        data = data or {}
    }
    
    rednet.broadcast(message, communication.config.networkProtocol)
    utils.info(string.format("Broadcasted %s message", messageType))
    return true
end

-- Listen for messages (non-blocking)
function communication.receiveMessage(timeout)
    timeout = timeout or 0.1
    local senderId, message, protocol = rednet.receive(communication.config.networkProtocol, timeout)
    
    if senderId and message then
        utils.info(string.format("Received %s message from %d", message.type or "unknown", senderId))
        return senderId, message
    end
    
    return nil, nil
end

-- Listen for messages with a specific type
function communication.waitForMessage(messageType, timeout)
    timeout = timeout or communication.config.responseTimeout
    local startTime = os.epoch("utc")
    
    while (os.epoch("utc") - startTime) < (timeout * 1000) do
        local senderId, message = communication.receiveMessage(0.1)
        if message and message.type == messageType then
            return senderId, message
        end
    end
    
    return nil, nil
end

-- Send a ping and wait for pong
function communication.ping(targetId)
    communication.sendMessage(targetId, communication.MESSAGE_TYPES.PING, {})
    local senderId, message = communication.waitForMessage(communication.MESSAGE_TYPES.PONG, 2)
    
    if senderId == targetId then
        utils.info("Ping successful to " .. targetId)
        return true
    else
        utils.warn("Ping failed to " .. targetId)
        return false
    end
end

-- Respond to a ping with a pong
function communication.handlePing(senderId)
    communication.sendMessage(senderId, communication.MESSAGE_TYPES.PONG, {})
end

-- Request status from another turtle
function communication.requestStatus(targetId)
    communication.sendMessage(targetId, communication.MESSAGE_TYPES.STATUS_REQUEST, {})
    local senderId, message = communication.waitForMessage(communication.MESSAGE_TYPES.STATUS_RESPONSE, 5)
    
    if senderId == targetId and message then
        return message.data
    end
    
    return nil
end

-- Send status response
function communication.sendStatus(targetId, status)
    communication.sendMessage(targetId, communication.MESSAGE_TYPES.STATUS_RESPONSE, status)
end

-- Discover nearby turtles
function communication.discoverTurtles()
    utils.info("Discovering nearby turtles...")
    communication.broadcast(communication.MESSAGE_TYPES.PING, {})
    
    local turtles = {}
    local startTime = os.epoch("utc")
    
    -- Listen for responses for 3 seconds
    while (os.epoch("utc") - startTime) < 3000 do
        local senderId, message = communication.receiveMessage(0.1)
        if message and message.type == communication.MESSAGE_TYPES.PONG then
            if not utils.tableContains(turtles, senderId) then
                table.insert(turtles, senderId)
                utils.info("Discovered turtle: " .. senderId)
            end
        end
    end
    
    utils.info(string.format("Discovery complete. Found %d turtles", #turtles))
    return turtles
end

-- Emergency broadcast
function communication.emergency(emergencyType, location, description)
    local emergencyData = {
        emergencyType = emergencyType,
        location = location or {x = 0, y = 0, z = 0},
        description = description or "Emergency situation",
        timestamp = os.epoch("utc")
    }
    
    communication.broadcast(communication.MESSAGE_TYPES.EMERGENCY, emergencyData)
    utils.error("EMERGENCY BROADCAST: " .. emergencyType)
end

-- Request resources from other turtles
function communication.requestResource(resourceType, quantity, urgency)
    urgency = urgency or "normal" -- low, normal, high, critical
    
    local requestData = {
        resourceType = resourceType,
        quantity = quantity,
        urgency = urgency,
        requester = os.getComputerID()
    }
    
    communication.broadcast(communication.MESSAGE_TYPES.RESOURCE_REQUEST, requestData)
    utils.info(string.format("Requested %d %s (urgency: %s)", quantity, resourceType, urgency))
end

-- Offer resources to other turtles
function communication.offerResource(resourceType, quantity, location)
    local offerData = {
        resourceType = resourceType,
        quantity = quantity,
        location = location or {x = 0, y = 0, z = 0},
        provider = os.getComputerID()
    }
    
    communication.broadcast(communication.MESSAGE_TYPES.RESOURCE_OFFER, offerData)
    utils.info(string.format("Offered %d %s", quantity, resourceType))
end

-- Close communication
function communication.close()
    rednet.close()
    utils.info("Communication closed")
end

return communication