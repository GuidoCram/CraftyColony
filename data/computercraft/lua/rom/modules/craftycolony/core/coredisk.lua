-- CoreDisk.lua
local CoreDisk = {}

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

local db = {
    -- queue for disk operations
    readQueue       = {},           -- reading has priority over writing
    writeQueue      = {},           -- writing has no harm in queueing

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

local function getNextOperation()
    -- something to read or write?
        if #db.readQueue  > 0 then return table.remove(db.readQueue, 1)
    elseif #db.writeQueue > 0 then return table.remove(db.writeQueue, 1)
    end

    -- still here, no operation
    return nil
end

-- for reading files asynchronously
local function readFile(path, callback, toTable)

    -- try to open the file
    local file = fs.open(path, "r")
    local data = nil

    -- only when we could open the file
    if file then

        -- read all contents
        data = file.readAll()
        file.close()
    end

	-- if requested, deserialize into a table
	if callback and data and toTable then data = textutils.unserialize(data) end

    -- call the callback function with the contents (if any)
    if callback then callback(data) end
end

-- for writing files asynchronously
local function writeFile(path, mode, data)

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
local function deleteFile(path)

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

function CoreDisk.init()
	-- nothing to initialize at the moment
end

function CoreDisk.setup()
	-- nothing to setup at the moment
end

function CoreDisk.run()

    -- run until we are shutting down
    while not db.shuttingDown do

        -- get the next operation
        local operation = getNextOperation()

        -- something to do?
        if operation then

            -- what kind of operation?
            if operation.operation == "read" then

                -- yeah, reading a file is fun!
                readFile(operation.path, operation.callback, operation.table)

            elseif operation.operation == "write" then

                -- let's write!
                writeFile(operation.path, operation.mode, operation.data)

            elseif operation.operation == "delete" then

                -- let's delete!
                deleteFile(operation.path)
            end
        else
            -- currently nothing to do, just sleep a bit
            os.sleep(0.1)
        end
    end
end

-- Reads the entire contents of a file from disk async, will call the callback with the data (or nil)
function CoreDisk.readFile(path, callback)

    -- handle later
    table.insert(db.operationQueue, {operation="read", path=path, callback=callback, table=false})
end

function CoreDisk.readFileIntoTable(path, callback)

    -- handle later
    table.insert(db.operationQueue, {operation="read", path=path, callback=callback, table=true})
end

-- Writes data to a file on disk async (overwrites existing)
function CoreDisk.writeFile(path, data)

	-- check input
	if type(data) ~= "string" and type(data) ~= "number" then error("Invalid data: expected string or number") end

    -- handle later
    table.insert(db.operationQueue, {operation="write", path=path, mode="w", data=data})
end

-- writes table to a file on disk async (overwrites existing)
function CoreDisk.writeTableToFile(path, data)

	-- check input
	if type(data) ~= "table" then error("Invalid data: expected table")	end

    -- handle later using serialization and other function
    CoreDisk.writeFile(path, textutils.serialize(data))
end

-- Appends data to a file on disk async
function CoreDisk.appendFile(path, data)

    -- handle later
    table.insert(db.operationQueue, {operation="write", path=path, mode="a", data=data})
end

-- Appends table to a file on disk async
function CoreDisk.appendTableToFile(path, data)

	-- check input
	if type(data) ~= "table" then error("Invalid data: expected table")	end

	-- handle later
    CoreDisk.appendFile(path, textutils.serialize(data))
end

-- Checks if a file exists
function CoreDisk.exists(path)
    return fs.exists(path)
end

-- Deletes a file
function CoreDisk.delete(path)

    -- handle later
    table.insert(db.operationQueue, {operation="delete", path=path})
end

function CoreDisk.shutdown()
    -- set the flag to stop running
    db.shuttingDown = true
end

--[[
           _
          | |
  _ __ ___| |_ _   _ _ __ _ __
 | '__/ _ \ __| | | | '__| '_ \
 | | |  __/ |_| |_| | |  | | | |
 |_|  \___|\__|\__,_|_|  |_| |_|


--]]

return CoreDisk
