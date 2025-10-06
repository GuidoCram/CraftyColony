-- coredisk.lua
local coredisk = {}

-- imports


--[[
      _                     _       _   _
     | |                   (_)     | | (_)
   __| | ___  ___  ___ _ __ _ _ __ | |_ _  ___  _ __
  / _` |/ _ \/ __|/ __| '__| | '_ \| __| |/ _ \| '_ \
 | (_| |  __/\__ \ (__| |  | | |_) | |_| | (_) | | | |
  \__,_|\___||___/\___|_|  |_| .__/ \__|_|\___/|_| |_|
                             | |
                             |_|


    This modules handles disk io, like reading and writing files.

--]]

--[[
      _       _
     | |     | |
   __| | __ _| |_ __ _
  / _` |/ _` | __/ _` |
 | (_| | (_| | || (_| |
  \__,_|\__,_|\__\__,_|

--]]

local db	    = {
    -- queue for disk operations
    operationQueue      = {},           -- writing has no harm in queueing

    -- local status of shutting down
	shuttingDown	= false,
}

--[[
  _                 _
 | |               | |
 | | ___   ___ __ _| |
 | |/ _ \ / __/ _` | |
 | | (_) | (_| (_| | |
 |_|\___/ \___\__,_|_|

--]]

local function GetNextOperation()
    -- something to write?
    if #db.operationQueue > 0 then return table.remove(db.operationQueue, 1) end

    -- still here, no operation
    return nil
end

-- for writing files asynchronously
local function writeFileAsync(path, mode, data)

    -- check the mode. Anything else then write mode will be handled as append
    if mode ~= "w" then mode = "a" end

    -- now open the file
    local file = fs.open(path, mode)

    -- only when we could open the file
    if file then
        file.write(data)
        file.close()
    end
end

-- for deleting files asynchronously
local function deleteFileAsync(path)

    -- check if the file exists first
    if fs.exists(path) then

        -- delete it!
        fs.delete(path)
    end
end

--[[
              _     _ _
             | |   | (_)
  _ __  _   _| |__ | |_  ___
 | '_ \| | | | '_ \| | |/ __|
 | |_) | |_| | |_) | | | (__
 | .__/ \__,_|_.__/|_|_|\___|
 | |
 |_|

--]]

function coredisk.Init()
	-- nothing to initialize at the moment
end

function coredisk.Setup()
	-- nothing to setup at the moment
end

function coredisk.Run()

    -- run until we are shutting down
    while not db.shuttingDown do

        -- get the next operation
        local operation = GetNextOperation()

        -- something to do?
        if operation then

            -- what kind of operation?
            if operation.operation == "delete" then

                -- let's delete!
                deleteFileAsync(operation.path)

            elseif operation.operation == "write" then

                -- let's write!
                writeFileAsync(operation.path, operation.mode, operation.data)
            end
        else

            -- currently nothing to do, just sleep a bit
            os.sleep(0.1)
        end
    end
end

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

    -- handle later
    table.insert(db.operationQueue, {operation="write", path=path, mode="w", data=data})
end

-- Appends data to a file on disk
function coredisk.appendFile(path, data)

    -- handle later
    table.insert(db.operationQueue, {operation="write", path=path, mode="a", data=data})
end

-- Checks if a file exists
function coredisk.exists(path)
    return fs.exists(path)
end

-- Deletes a file
function coredisk.delete(path)

    -- handle later
    table.insert(db.operationQueue, {operation="delete", path=path})
end

return coredisk