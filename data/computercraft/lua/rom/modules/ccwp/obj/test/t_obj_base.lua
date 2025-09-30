local T_ObjBase = {}

local corelog = require "corelog"

local IObj = require "i_obj"
local ObjBase = require "obj_base"

local FieldValueTypeTest = require "field_value_type_test"

local T_IInterface = require "test.t_i_interface"
local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_ObjBase.T_All()
    -- initialisation
    T_ObjBase.T_init()

    -- IObj
    T_ObjBase.T_IObj_All()
end

local testClassName = "ObjBase"
local logOk = false

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_ObjBase.CreateTestObj()
    local testObj = ObjBase:newInstance()

    return testObj
end

function T_ObjBase.CreateInitialisedTest()
    -- check input

    -- create test
    local initialisedTest = FieldValueTypeTest:newInstance("_init", "function")
    -- note: as ObjBase had not fields we check the existence of method ObjBase._init, normal classes should check the fields

    -- end
    return initialisedTest
end

function T_ObjBase.T_init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":init() tests")

    -- test
    local obj = T_ObjBase.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local initialisedTest = T_ObjBase.CreateInitialisedTest()
    initialisedTest:test(obj, "objBase", "", logOk)

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

function T_ObjBase.T_IObj_All()
    -- prepare test
    local obj = T_ObjBase.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    obj._aStr = "a string"
    obj._aNumber = 10
    obj._aBoolean = true
    obj._anIObj = T_ObjBase.CreateTestObj()
    obj._anIObj._aSubStr = "another string"
    obj._aNormalTable = {
        _aSubStr = "a sub string",
        _aSubNumber = 100,
        _aSubBoolean = true,
        _aSubIObj = T_ObjBase.CreateTestObj(),
    }
    obj._aNormalTable._aSubIObj._aSubStr = "another sub string"

    local otherObj = T_ObjBase.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)
    otherObj._aNil = obj._aNil
    otherObj._aStr = obj._aStr
    otherObj._aNumber = obj._aNumber
    otherObj._aBoolean = obj._aBoolean
    otherObj._anIObj = T_ObjBase.CreateTestObj()
    otherObj._anIObj._aSubStr = obj._anIObj._aSubStr
    otherObj._aNormalTable = {
        _aSubStr = "a sub string",
        _aSubNumber = 100,
        _aSubBoolean = true,
        _aSubIObj = T_ObjBase.CreateTestObj(),
    }
    otherObj._aNormalTable._aSubIObj._aSubStr = "another sub string"

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_IInterface.pt_ImplementsInterface("IObj", IObj, testClassName, obj)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

return T_ObjBase
