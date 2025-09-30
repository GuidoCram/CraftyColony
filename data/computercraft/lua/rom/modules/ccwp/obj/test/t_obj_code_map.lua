local T_CodeMap = {}
local corelog = require "corelog"

local Class = require "class"
local IObj = require "i_obj"
local ObjBase = require "obj_base"
local CodeMap = require "obj_code_map"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_CodeMap.T_All()
    -- initialisation
    T_CodeMap.T__init()
    T_CodeMap.T_new()

    -- IObj
    T_CodeMap.T_IObj_All()

    -- specific
    T_CodeMap.T_getCode()
    T_CodeMap.T_transformToMap()
    T_CodeMap.T_removeRow()
    T_CodeMap.T_removeColumn()
    T_CodeMap.T_getCodeCol()
    T_CodeMap.T_removeBoundariesWithOnly()
end

local testClassName = "CodeMap"
local logOk = false
local codeRowArray1 = {
    [6] = "CD   ?",
    [5] = "      ",
    [4] = "T  S  ",
    [3] = "  ?   ",
    [2] = "   K  ",
    [1] = "   T  ",
}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_CodeMap.CreateTestObj(codeMap)
    -- check input
    codeMap = codeMap or {
        [6] = "CD   ?",
        [5] = "      ",
        [4] = "T  S  ",
        [3] = "  ?   ",
        [2] = "   K  ",
        [1] = "   T  ",
    }

    -- create testObj
    local testObj = CodeMap:newInstance(codeMap)

    -- end
    return testObj
end

function T_CodeMap.CreateInitialisedTest(codeRowArray)
    -- check input

    -- create test
    local test = TestArrayTest:newInstance(
    )
    for i, codeRow in ipairs(codeRowArray) do
        table.insert(test._tests, FieldValueEqualTest:newInstance(i, codeRow))
    end

    -- end
    return test
end

function T_CodeMap.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")

    -- test
    local obj = T_CodeMap.CreateTestObj(codeRowArray1) assert(obj, "Failed obtaining "..testClassName)
    local test = T_CodeMap.CreateInitialisedTest(codeRowArray1)
    test:test(obj, "codeMap", "", logOk)
    local expectedNColumns = 6
    assert(obj:getNColumns() == expectedNColumns, "gotten getNColumns(="..obj:getNColumns()..") not the same as expected(="..expectedNColumns..")")
    local expectedNRows = 6
    assert(obj:getNRows() == expectedNRows, "gotten getNRows(="..obj:getNRows()..") not the same as expected(="..expectedNRows..")")

    -- test default
    obj = CodeMap:newInstance()
    test = T_CodeMap.CreateInitialisedTest({})
    test:test(obj, "codeMap", "", logOk)
    expectedNColumns = 0
    assert(obj:getNColumns() == expectedNColumns, "gotten getNColumns(="..obj:getNColumns()..") not the same as expected(="..expectedNColumns..")")
    expectedNRows = 0
    assert(obj:getNRows() == expectedNRows, "gotten getNRows(="..obj:getNRows()..") not the same as expected(="..expectedNRows..")")

    -- cleanup test
end

function T_CodeMap.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test full
    local obj = CodeMap:new(codeRowArray1) assert(obj, "Failed obtaining CodeMap")
    local test = T_CodeMap.CreateInitialisedTest(codeRowArray1)
    test:test(obj, "codeMap", "", logOk)

    -- cleanup test
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function T_CodeMap.T_IObj_All()
    -- prepare test
    local obj = T_CodeMap.CreateTestObj() assert(obj, "failed obtaining "..testClassName)
    local otherObj = T_CodeMap.CreateTestObj() assert(obj, "failed obtaining "..testClassName) assert(otherObj, "failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function T_CodeMap.T_getCode()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getCode() tests")
    local obj = CodeMap:newInstance(codeRowArray1) assert(obj, "Failed obtaining CodeMap")

    -- test
    local code = obj:getCode(4, 1)
    local expectedCode = "T"
    assert(code == expectedCode, "gotten code(="..code..") not the same as expected(="..expectedCode..")")
    code = obj:getCode(1, 4)
    assert(code == expectedCode, "gotten code(="..code..") not the same as expected(="..expectedCode..")")
    code = obj:getCode(4, 4)
    expectedCode = "S"
    assert(code == expectedCode, "gotten code(="..code..") not the same as expected(="..expectedCode..")")

    -- cleanup test
end

function T_CodeMap.T_transformToMap()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":transformToMap() tests")
    local anyBlockCode = "?"
    local fromMap = CodeMap:newInstance({
        [6] = "   S  ",
        [5] = "      ",
        [4] = "   S  ",
        [3] = "   ?  ",
        [2] = "   ?  ",
        [1] = "   ?  ",
    }) assert(fromMap, "Failed obtaining CodeMap")
    local toMap = CodeMap:newInstance({
        [6] = "   ?  ",
        [5] = "      ",
        [4] = "T  S  ",
        [3] = "      ",
        [2] = "   ?  ",
        [1] = "   T  ",
    }) assert(toMap, "Failed obtaining CodeMap")

    -- test
    local transformLayer = fromMap:transformToMap(toMap, anyBlockCode)
    local isInstanceOf = Class.IsInstanceOf(transformLayer, CodeMap)
    local expectedIsInstanceOf = true
    assert(isInstanceOf, "gotten isInstanceOf(="..tostring(isInstanceOf)..") not the same as expected(="..tostring(expectedIsInstanceOf)..")")
    local expectedMap = CodeMap:newInstance({
        [6] = "??????",
        [5] = "??????",
        [4] = "T?????",
        [3] = "??? ??",
        [2] = "??????",
        [1] = "???T??",
    })
    assert(transformLayer:isEqual(expectedMap), "gotten transformToMap(="..textutils.serialize(transformLayer, compact)..") not the same as expected(="..textutils.serialize(expectedMap, compact)..")")

    -- test anyBlock added to _codeTable
    toMap = CodeMap:newInstance({
        [6] = "      ",
        [5] = "      ",
        [4] = "T  S  ",
        [3] = "      ",
        [2] = "      ",
        [1] = "   T  ",
    })
    transformLayer = fromMap:transformToMap(toMap, anyBlockCode)
    isInstanceOf = Class.IsInstanceOf(transformLayer, CodeMap)
    expectedIsInstanceOf = true
    assert(isInstanceOf, "gotten isInstanceOf(="..tostring(isInstanceOf)..") not the same as expected(="..tostring(expectedIsInstanceOf)..")")
    expectedMap = CodeMap:newInstance({
        [6] = "??? ??",
        [5] = "??????",
        [4] = "T?????",
        [3] = "??? ??",
        [2] = "??? ??",
        [1] = "???T??",
    })
    assert(transformLayer:isEqual(expectedMap), "gotten transformToMap(="..textutils.serialize(transformLayer, compact)..") not the same as expected(="..textutils.serialize(expectedMap, compact)..")")

    -- cleanup test
end

function T_CodeMap.T_removeRow()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":removeRow() tests")

    -- test top
    local obj = T_CodeMap.CreateTestObj()
    obj:removeRow(6)
    local expectedMap = CodeMap:newInstance({
        [5] = "      ",
        [4] = "T  S  ",
        [3] = "  ?   ",
        [2] = "   K  ",
        [1] = "   T  ",
    })
    assert(obj:isEqual(expectedMap), "result obj(="..textutils.serialize(obj, compact)..") not the same as expected(="..textutils.serialize(expectedMap, compact)..")")

    -- test a mid
    obj = T_CodeMap.CreateTestObj()
    obj:removeRow(4)
    expectedMap = CodeMap:newInstance({
        [5] = "CD   ?",
        [4] = "      ",
        [3] = "  ?   ",
        [2] = "   K  ",
        [1] = "   T  ",
    })
    assert(obj:isEqual(expectedMap), "result obj(="..textutils.serialize(obj, compact)..") not the same as expected(="..textutils.serialize(expectedMap, compact)..")")

    -- test bottom
    obj = T_CodeMap.CreateTestObj()
    obj:removeRow(1)
    expectedMap = CodeMap:newInstance({
        [5] = "CD   ?",
        [4] = "      ",
        [3] = "T  S  ",
        [2] = "  ?   ",
        [1] = "   K  ",
    })
    assert(obj:isEqual(expectedMap), "result obj(="..textutils.serialize(obj, compact)..") not the same as expected(="..textutils.serialize(expectedMap, compact)..")")

    -- cleanup test
end

function T_CodeMap.T_getCodeCol()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getCodeCol() tests")
    local obj = T_CodeMap.CreateTestObj()

    -- test
    local column = obj:getCodeCol(4)
    local expectedColumn = "TK S  "
    assert(column == expectedColumn, "gotten column(="..column..") not the same as expected(="..expectedColumn..")")

    -- cleanup test
end

function T_CodeMap.T_removeColumn()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":removeColumn() tests")

    -- test right
    local obj = T_CodeMap.CreateTestObj()
    obj:removeColumn(6)
    local expectedMap = CodeMap:newInstance({
        [6] = "CD   ",
        [5] = "     ",
        [4] = "T  S ",
        [3] = "  ?  ",
        [2] = "   K ",
        [1] = "   T ",
    })
    assert(obj:isEqual(expectedMap), "result obj(="..textutils.serialize(obj, compact)..") not the same as expected(="..textutils.serialize(expectedMap, compact)..")")

    -- test mid
    obj = T_CodeMap.CreateTestObj()
    obj:removeColumn(4)
    expectedMap = CodeMap:newInstance({
        [6] = "CD  ?",
        [5] = "     ",
        [4] = "T    ",
        [3] = "  ?  ",
        [2] = "     ",
        [1] = "     ",
    })
    assert(obj:isEqual(expectedMap), "result obj(="..textutils.serialize(obj, compact)..") not the same as expected(="..textutils.serialize(expectedMap, compact)..")")

    -- test left
    obj = T_CodeMap.CreateTestObj()
    obj:removeColumn(1)
    expectedMap = CodeMap:newInstance({
        [6] = "D   ?",
        [5] = "     ",
        [4] = "  S  ",
        [3] = " ?   ",
        [2] = "  K  ",
        [1] = "  T  ",
    })
    assert(obj:isEqual(expectedMap), "result obj(="..textutils.serialize(obj, compact)..") not the same as expected(="..textutils.serialize(expectedMap, compact)..")")

    -- cleanup test
end

function T_CodeMap.T_removeBoundariesWithOnly()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":removeBoundariesWithOnly() tests")

    -- test right
    local obj = CodeMap:newInstance({
        [6] = "??????",
        [5] = "??????",
        [4] = "??TC ?",
        [3] = "?? C??",
        [2] = "??? T?",
        [1] = "??????",
    }) assert(obj, "Failed obtaining CodeMap")
    local code = "?"
    local colOffset, rowOffset = obj:removeBoundariesWithOnly(code)
    local expectedOffset = 1
    assert(rowOffset == expectedOffset, "gotten rowOffset(="..tostring(colOffset)..") for code "..code.." not the same as expected(="..tostring(expectedOffset)..")")
    expectedOffset = 2
    assert(colOffset == expectedOffset, "gotten colOffset(="..tostring(colOffset)..") for code "..code.." not the same as expected(="..tostring(expectedOffset)..")")
    local expectedMap = CodeMap:newInstance({
        [3] = "TC ",
        [2] = " C?",
        [1] = "? T",
    })
    assert(obj:isEqual(expectedMap), "result obj(="..textutils.serialize(obj, compact)..") for code "..code.." not the same as expected(="..textutils.serialize(expectedMap, compact)..")")

    -- cleanup test
end

return T_CodeMap
