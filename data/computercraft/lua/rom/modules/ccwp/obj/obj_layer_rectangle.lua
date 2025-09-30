-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local LayerRectangle = Class.NewClass(ObjBase)

--[[
    This module implements the class LayerRectangle.

    A LayerRectangle object represents a rectangular layer in the minecraft world.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"
local ObjTable = require "obj_table"
local Block = require "obj_block"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function LayerRectangle:_init(...)
    -- get & check input from description
    local checkSuccess, codeTable, codeMap = InputChecker.Check([[
        Initialise a LayerRectangle.

        Parameters:
            codeTable               + (ObjTable) with mapping CodeMap codes (characters) to Block's
            codeMap                 + (CodeMap) with map of codes of Block's within the layer
    ]], ...)
    if not checkSuccess then corelog.Error("Location:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._codeTable = codeTable
    self._codeMap   = codeMap
end

function LayerRectangle:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a LayerRectangle.

        Parameters:
            o                           + (table, {}) table with object fields
                _codeTable              - (ObjTable) with mapping CodeMap codes (characters) to Block's
                _codeMap                - (CodeMap) with map of codes of Block's within the layer
    ]], ...)
    if not checkSuccess then corelog.Error("LayerRectangle:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- check CodeMap validity
    if not LayerRectangle.CodeMapValid(o._codeTable, o._codeMap, true) then corelog.Error("LayerRectangle:new: Invalid CodeMap") return nil end

    -- end
    return o
end

function LayerRectangle:getBlock(iColumn, iRow)
    -- get code
    local code = self._codeMap:getCode(iColumn, iRow)
    if code:len() ~= 1 then corelog.Error("LayerRectangle:getBlock: code of incorrect length(="..code:len()..")") return nil end

    -- get block
    local block = self._codeTable[code]

    -- end
    return block
end

function LayerRectangle:getNColumns()
    return self._codeMap:getNColumns()
end

function LayerRectangle:getNRows()
    return self._codeMap:getNRows()
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function LayerRectangle:getClassName()
    return "LayerRectangle"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function LayerRectangle:itemsNeeded()
    -- get code list
    local codeList = self._codeMap:codesNeeded()

    -- determine item list
    local itemList = {}
    for code, codeCount in pairs(codeList) do
        -- get block
        local block = self._codeTable[code]

        -- check is an actual item
        if block:isMinecraftItem() or block:isComputercraftItem() then
            -- set counter
            itemList[block:getName()] = (itemList[block:getName()] or 0) + codeCount
        end
    end

    -- end
    return itemList
end

function LayerRectangle:transformToLayer(...)
    -- get & check input from description
    local checkSuccess, toLayer = InputChecker.Check([[
        This method returns the layer that is needed to transform this layer into toLayer.

        Parameters:
            toLayer                     + (LayerRectangle) table with
    ]], ...)
    if not checkSuccess then corelog.Error("LayerRectangle:transformToLayer: Invalid input") return nil end

    -- construct transformCodeMap
    local toMap = toLayer._codeMap
    local anyBlockCode = "?"
    local transformCodeMap, anyBlockInserted = self._codeMap:transformToMap(toMap, anyBlockCode)

    -- construct transformCodeTable
    local transformCodeTable = ObjTable:newInstance(Block:getClassName())
    for code, codeCount in pairs(toMap:codesNeeded()) do
        transformCodeTable[code] = toLayer._codeTable[code]:copy()
    end
    if anyBlockInserted and not transformCodeTable[anyBlockCode] then
        transformCodeTable[anyBlockCode] = Block:newInstance(Block.AnyBlockName())
    end

    -- end
    local transformLayer = LayerRectangle:newInstance(transformCodeTable, transformCodeMap)
    return transformLayer
end

function LayerRectangle:cleanCodeTable()
    --[[
        Remove code's from codeTable that are not (anymore) in CodeMap
    ]]

    -- get codeList
    local codeList = self._codeMap:codesNeeded()

    -- check for unused codes
    for code, block in self._codeTable:objs() do
        if not codeList[code] then
            -- remove code
            self._codeTable[code] = nil
        end
    end
end

function LayerRectangle:buildData()
    --[[
        Obtain data to build this LayerRectangle.

        The build data is a LayerRectangle with no AnyBlock's at the boundaries and the column and row offsets relative to this LayerRectangle.

        Return value:
            col_offset                  - (number) column offset relative to original LayerRectangle
            row_offset                  - (number) row offset relative to original LayerRectangle
            buildLayer                  - (LayerRectangle) with layer to build
    ]]

    -- get AnyBlock code
    local anyBlockCode = "?" -- default, but allowed to be different
    for code, block in self._codeTable:objs() do
        if block:isAnyBlock() then
            anyBlockCode = code
            break
        end
    end

    -- get build data
    local buildLayer = self:copy()
---@diagnostic disable-next-line: need-check-nil
    local col_offset, row_offset = buildLayer._codeMap:removeBoundariesWithOnly(anyBlockCode)

    -- clean codeTable
    buildLayer:cleanCodeTable()

    -- end
    return col_offset, row_offset, buildLayer
end

--    _          _                    __                  _   _
--   | |        | |                  / _|                | | (_)
--   | |__   ___| |_ __   ___ _ __  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | '_ \ / _ \ | '_ \ / _ \ '__| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | | |  __/ | |_) |  __/ |    | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_| |_|\___|_| .__/ \___|_|    |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--                | |
--                |_|

function LayerRectangle.CodeMapValid(codeTable, codeMap, warn)
    -- check CodeMap validity
    local size_x = 0
    for iY, codeRow in ipairs(codeMap) do
        -- check row is string
        if type(codeRow) ~= "string" then if warn then corelog.Warning("LayerRectangle.CodeMapValid: Invalid codeRow (type="..type(codeRow)..")") end return false end

        -- check row length
        local rowLen = codeRow:len()
        if iY == 1 then
            size_x = rowLen
        else
            if rowLen ~= size_x then if warn then corelog.Warning("LayerRectangle.CodeMapValid: Invalid length(="..rowLen..") different from size_x(="..size_x..")") end return false end
        end

        -- check row elements
        for iX = 1, codeRow:len() do
            -- check code validity
            local code = codeRow:sub(iX, iX)
            if not codeTable[code] then if warn then corelog.Warning("LayerRectangle.CodeMapValid: code(="..code..") at ("..iX..","..iY..") not in codeTable") end return false end
        end
    end

    -- end
    return true
end

return LayerRectangle
