-- coredisk.lua
-- Core Disk IO utilities for CraftyColony

local coredisk = {}

-- Reads the entire contents of a file from disk
function coredisk.readFile(path)
    local file = fs.open(path, "r")
    if not file then
        return nil, "File not found: " .. path
    end
    local contents = file.readAll()
    file.close()
    return contents
end

-- Writes data to a file on disk (overwrites existing)
function coredisk.writeFile(path, data)
    local file = fs.open(path, "w")
    if not file then
        return false, "Unable to open file for writing: " .. path
    end
    file.write(data)
    file.close()
    return true
end

-- Appends data to a file on disk
function coredisk.appendFile(path, data)
    local file = fs.open(path, "a")
    if not file then
        return false, "Unable to open file for appending: " .. path
    end
    file.write(data)
    file.close()
    return true
end

-- Checks if a file exists
function coredisk.exists(path)
    return fs.exists(path)
end

-- Deletes a file
function coredisk.delete(path)
    if fs.exists(path) then
        fs.delete(path)
        return true
    end
    return false, "File does not exist: " .. path
end

return coredisk