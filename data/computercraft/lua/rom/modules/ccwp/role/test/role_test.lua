local role_test = {}

function role_test.Func1_Task(taskData)
    return {
        success = true,
        input   = taskData.arg1
    }
end

function role_test.Func2_Task(taskData)
    -- end
    return {
        success = true,
        input   = taskData.input,
        selfObj = taskData.selfObj,
    }
end

return role_test
