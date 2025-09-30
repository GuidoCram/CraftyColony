-- define class
local Class = {}

--[[
    This module implements the meta class Class.

    Class provides this functionality:
        - A base implementation for creating new instances (objects) of a Class.
        - Functionality to create a new class by inheriting functionality from a chain of other classes.
        - Functionality to check if an object (or class) is an instance of a class.
--]]

function Class.IsInstanceOf(object, class)
    --[[
        Function that returns if a given object is an instance of a specified class (or interface).
    ]]

    local mt = getmetatable(object)
    while mt do
        -- check inheritance is mixedin
        if mt.__mixinClasses then
            -- loop on mixinClasses
            for _i, mixinClass in ipairs(mt.__mixinClasses) do
                if mixinClass == class then
                    return true
                else
                    if Class.IsInstanceOf(mixinClass, class) == true then
                        return true
                    end
                end
            end
            return false
        else -- normal inheritance
            if mt == class then
                return true
            end
            mt = getmetatable(mt)
        end
    end

    -- end
    return false
end

function Class.NewClass(...)
    --[[
        This function creates and returns a new class that inherts behaviour from the supplied classes.
    ]]

    -- create class
    local class = {}

    -- remember mixins
    local mixinClasses = {...}

    -- create metatable
    local mt = {
        -- remember mixinClasses
        __mixinClasses  = mixinClasses,

        -- define property and method inheritance behavior
        __index         = function(self, key)
            -- walk inheritance chain: return property or method of first class containing key, starting from the class itself
            if rawget(class, key) then
--                corelog.WriteToLog("    key="..key.." direct")
                return class[key]
            else
--                corelog.WriteToLog("    key="..key.." on "..#mixinClasses.." parent(s)")
                -- loop on mixinClass
                for _i, mixinClass in ipairs(mixinClasses) do
--                    if mixinClass.getClassName then corelog.WriteToLog("    mixinClass="..mixinClass:getClassName()) end
--                    corelog.WriteToLog("    _i=".._i)
                    local value = mixinClass[key]
                    if value then
                        return value
                    end
                end

                return nil -- print some warning, or do we want/ expect it to fail here?
            end
        end
    }

    -- set metatable
    setmetatable(class, mt)

    -- end
    return class
end

function Class:newInstance(...)
    --[[
        Function that creates and returns new instance from the calling class (i.e. self).

        An initialisation function _init of the calling class is called if it is present with the varargs as arguments.
    ]]

    -- create instance
    local instance = {}

    -- set instance class info
    setmetatable(instance, self)
    self.__index = self

    -- initialisation
    if instance._init then
        instance:_init(...)
    end

    -- end
    return instance
end

return Class
