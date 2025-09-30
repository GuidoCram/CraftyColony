-- define interface
local ITest = {}

--[[
    This module specifies the ITest interface, a generic interface for tests.

    It defines the methods that classes adhering to this interface must implement.
--]]

local IInterface = require "i_interface"

function ITest:test(testTarget, testTargetName, indent, logOk)
    --[[
        This method tests a 'testTarget'.

        Parameters:
            testTarget          - (???) with the target to test
            testTargetName      - (string) with the name of the target
            indent              - (string) with an indent to apply to messages
            logOk               - (boolean) if ok should be logged
    ]]

    IInterface.UnimplementedMethodError("ITest", "test")
end

return ITest