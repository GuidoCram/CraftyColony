-- define class
local Class = require "class"
local CallDef = require "obj_call_def"
local TaskCall = Class.NewClass(CallDef)

--[[
    This module implements the class TaskCall.

    A TaskCall defines the call to a task function including the taskData.

    A task function should take one argument
        taskData                - (table) data to supply to task function to be able to perform the task
    and return
        taskResult              - (table) return data of the task function
--]]

local MethodExecutor = require "method_executor"

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function TaskCall:call()
    --[[
        This method executes the task with predefined task data.

        Return value:
                                    - (table) return data of task function

        Parameters:
    ]]

    -- call method
    return MethodExecutor.CallModuleMethod(self._moduleName, self._methodName, { self._data })
end

return TaskCall
