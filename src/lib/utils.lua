-- utils.lua
-- Common utility functions for CraftyColony

local utils = {}

-- Logging utilities
function utils.log(level, message)
    local timestamp = os.date("%H:%M:%S")
    print(string.format("[%s] [%s] %s", timestamp, level, message))
end

function utils.info(message)
    utils.log("INFO", message)
end

function utils.warn(message)
    utils.log("WARN", message)
end

function utils.error(message)
    utils.log("ERROR", message)
end

-- Table utilities
function utils.tableLength(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

function utils.tableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- String utilities
function utils.split(str, delimiter)
    local result = {}
    local pattern = "(.-)" .. delimiter
    local lastEnd = 1
    local s, e, cap = str:find(pattern, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(result, cap)
        end
        lastEnd = e + 1
        s, e, cap = str:find(pattern, lastEnd)
    end
    if lastEnd <= #str then
        cap = str:sub(lastEnd)
        table.insert(result, cap)
    end
    return result
end

-- Math utilities
function utils.distance(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
end

-- Wait with timeout
function utils.waitWithTimeout(condition, timeout)
    local start = os.clock()
    while not condition() and (os.clock() - start) < timeout do
        os.sleep(0.1)
    end
    return condition()
end

return utils