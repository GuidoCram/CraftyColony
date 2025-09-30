-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local CodeMap = Class.NewClass(ObjBase)

--[[
    This module implements the class CodeMap.

    A CodeMap object represents a matrix of codes (of Block's).
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function CodeMap:_init(...)
    -- get & check input from description
    local checkSuccess, codeRowArray = InputChecker.Check([[
        Initialise a CodeMap.

        Parameters:
            codeRowArray                + (table, {}) with rows of Block codes
    ]], ...)
    if not checkSuccess then corelog.Error("CodeMap:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    for i, codeRow in ipairs(codeRowArray) do
        self[i] = codeRow
    end
end

-- ToDo: should be renamed to newFromTable at some point
function CodeMap:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a CodeMap.

        Parameters:
            o                           + (table, {}) map of codes of Block's
    ]], ...)
    if not checkSuccess then corelog.Error("CodeMap:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function CodeMap:getClassName()
    return "CodeMap"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function CodeMap:getNColumns()
    -- check not empty
    if self:getNRows() == 0 then return 0 end

    -- end
    return self:getCodeRow(1):len()
end

function CodeMap:getNRows()
    return #self
end

function CodeMap:getCode(iColumn, iRow)
    -- check
    if iColumn < 1 or iColumn > self:getNColumns() then corelog.Error("CodeMap:getCode: iColumn(="..iColumn..") not within range i.e. between 1 and "..self:getNColumns()) return "" end

    -- end
    return self:getCodeRow(iRow):sub(iColumn, iColumn)
end

function CodeMap:codesNeeded()
    -- determine code list
    local codeList = {}

    -- loop on rows
    local nCol = self:getNColumns()
    for iRow, row in ipairs(self) do
        -- loop on columns
        for iCol = 1, nCol do
            -- get code
            local code = row:sub(iCol, iCol)

            -- increment counter
            codeList[code] = (codeList[code] or 0) + 1
        end
    end

    -- end
    return codeList
end

function CodeMap:transformToMap(...)
    -- get & check input from description
    local checkSuccess, toMap, anyBlockCode = InputChecker.Check([[
        This method returns the CodeMap that is needed to transform this CodeMap into toMap.

        Return value:
            transformCodeMap        - (CodeMap) with transformCodeMap
            anyBlockInserted        - (boolean) whether an anyBlockCode was inserted

        Parameters:
            toMap                   + (CodeMap) table with
            anyBlockCode            + (string) block code to use for new any blocks
    ]], ...)
    if not checkSuccess then corelog.Error("CodeMap:transformToMap: Invalid input") return nil end

    -- check size
    local fromMap = self
    if fromMap:getNRows() ~= toMap:getNRows() then corelog.Error("CodeMap:transformToMap: # rows in fromMap(="..fromMap:getNRows()..") not equal to that in toMap(="..toMap:getNRows()..")") return nil end
    if fromMap:getNColumns() ~= toMap:getNColumns() then corelog.Error("CodeMap:transformToMap: # columns in fromMap(="..fromMap:getNColumns()..") not equal to that in toMap(="..toMap:getNColumns()..")") return nil end

    -- construct transformCodeMap
    local transformCodeMap = CodeMap:newInstance()
    local nCol = fromMap:getNColumns()

    -- loop on rows
    local anyBlockInserted = false
    for iRow, fromRow in ipairs(fromMap) do
        -- construct transformRow
        local transformRow = ""

        -- loop on columns
        for iCol = 1, nCol do
            -- get code's
            local fromCode = fromRow:sub(iCol, iCol)
            local toCode = toMap:getCode(iCol, iRow)

            -- check code's
            if fromCode == toCode then
                transformRow = transformRow..anyBlockCode
                anyBlockInserted = true
            else
                transformRow = transformRow..toCode
            end
        end

        -- save row
        transformCodeMap[iRow] = transformRow
    end

    -- end
    return transformCodeMap, anyBlockInserted
end

function CodeMap:removeRow(...)
    -- get & check input from description
    local checkSuccess, iRow = InputChecker.Check([[
        Remove a row from the CodeMap.

        Parameters:
            iRow                        + (number) index of row to remove
    ]], ...)
    if not checkSuccess then corelog.Error("CodeMap:removeRow: Invalid input") return nil end

    -- check range
    if iRow < 1 or iRow > self:getNRows() then corelog.Error("CodeMap:removeRow: iRow(="..iRow..") not within range i.e. between 1 and "..self:getNRows()) return end

    -- remove row
    table.remove(self, iRow)
end

function CodeMap:removeColumn(...)
    -- get & check input from description
    local checkSuccess, iCol = InputChecker.Check([[
        Remove a column from the CodeMap.

        Parameters:
            iCol                        + (number) index of column to remove
    ]], ...)
    if not checkSuccess then corelog.Error("CodeMap:removeColumn: Invalid input") return nil end

    -- check range
    local nCol = self:getNColumns()
    if iCol < 1 or iCol > nCol then corelog.Error("CodeMap:removeColumn: iCol(="..iCol..") not within range i.e. between 1 and "..nCol) return end

    -- loop on rows
    for iRow, row in ipairs(self) do
        -- remove column
        self[iRow] = row:sub(1, iCol - 1)..row:sub(iCol + 1, nCol)
    end
end

function CodeMap:removeBoundariesWithOnly(...)
    -- get & check input from description
    local checkSuccess, code = InputChecker.Check([[
        Remove boundary rows and columns that only contain a given code.

        Return value:
            col_offset                  - (number) column offset relative to original CodeMap
            row_offset                  - (number) row offset relative to original CodeMap

        Parameters:
            code                        + (string) off which rows and columns should be removed
    ]], ...)
    if not checkSuccess then corelog.Error("CodeMap:removeBoundariesWithOnly: Invalid input") return nil end

    --
    local col_offset = 0
    local row_offset = 0

    -- ...
    local nCol = self:getNColumns()

    -- loop from top row
    for iRow = self:getNRows(), 1, -1 do
        -- check only code's
        local row = self[iRow]
        local _, nBlocks = row:gsub(code, "")
        if nBlocks == nCol then
            -- remove row
            self:removeRow(iRow)
        else
            break
        end
    end

    -- loop from bottom row
    local iRow = 1
    while iRow < self:getNRows() do
        -- check only code's
        local row = self[iRow]
        local _, nBlocks = row:gsub(code, "")
        if nBlocks == nCol then
            -- remove row
            self:removeRow(iRow)
            row_offset = row_offset + 1
        else
            break
        end
    end
    nCol = self:getNColumns() -- just in case we have no rows left it should be updated to 0

    -- loop from right column
    local nRow = self:getNRows()
    for iCol = nCol, 1, -1 do
        -- check only code's
        local col = self:getCodeCol(iCol)
        local _, nBlocks = col:gsub(code, "")
        if nBlocks == nRow then
            -- remove row
            self:removeColumn(iCol)
        else
            break
        end
    end

    -- loop from left column
    local iCol = 1
    while iCol < self:getNColumns() do
        -- check only code's
        local col = self:getCodeCol(iCol)
        local _, nBlocks = col:gsub(code, "")
        if nBlocks == nRow then
            -- remove row
            self:removeColumn(iCol)
            col_offset = col_offset + 1
        else
            break
        end
    end

    -- end
    return col_offset, row_offset
end

--    _          _                    __                  _   _
--   | |        | |                  / _|                | | (_)
--   | |__   ___| |_ __   ___ _ __  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | '_ \ / _ \ | '_ \ / _ \ '__| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | | |  __/ | |_) |  __/ |    | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_| |_|\___|_| .__/ \___|_|    |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--                | |
--                |_|

function CodeMap:getCodeRow(iRow)
    -- check
    if iRow < 1 or iRow > self:getNRows() then corelog.Error("CodeMap:getCodeRow: iRow(="..iRow..") not within range i.e. between 1 and "..self:getNRows()) return "" end

    -- end
    return self[iRow]
end

function CodeMap:getCodeCol(iColumn)
    -- check
    local nCol = self:getNColumns()
    if iColumn < 1 or iColumn > nCol then corelog.Error("CodeMap:getCodeCol: iColumn(="..iColumn..") not within range i.e. between 1 and "..nCol) return "" end

    -- construct column
    local column = ""
    for iRow = 1, self:getNRows() do
        column = column..self:getCodeRow(iRow):sub(iColumn, iColumn)
    end

    -- end
    return column
end

return CodeMap
