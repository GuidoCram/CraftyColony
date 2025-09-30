local T_IInterface = {}

local corelog = require "corelog"

function T_IInterface.pt_ImplementsInterface(interfaceName, interface, className, classOrInstance)
    --[[
        This function checks if a(n) (instance of) class inplements an interface.

        To check if the class implements the interface it is checked if all functions in the interface are
        implemented in the class.

        A functions is assumed to be implemented if the functions in the interface is not identical (i.e. an identical
        address) to the functions with the same key in the class.
    ]]

    -- prepare test
    assert(type(interfaceName) == "string", "no  valid interfaceName provided")
    assert(type(interface) == "table", "no valid interface provided")
    assert(type(className) == "string", "no valid className provided")
    assert(type(classOrInstance) == "table", "no valid class or instance provided")
    corelog.WriteToLog("* "..className.." implements "..interfaceName.." interface test")

    -- test all functions in the interface
    for key, interface_func in pairs(interface) do
        -- check interface_func is a function
        assert(type(interface_func) == "function", "key "..key.." of interface "..interfaceName.." not a function (type="..type(interface_func)..")")

        -- check interface_func is present in class
        local classFunc = classOrInstance[key]
        assert(classFunc, "key "..key.." of interface "..interfaceName.." not present in class "..className)

        -- check classFunc is a function
        assert(type(classFunc) == "function", "key "..key.." of class "..className.." not a function (type="..type(classFunc)..")")

        -- check functions are not identical (as that implies classFunc is not overridden in class)
        assert(classFunc ~= interface_func, "key "..key.." of interface "..interfaceName.." not implemented in class "..className)
    end

    -- cleanup test
end

return T_IInterface
