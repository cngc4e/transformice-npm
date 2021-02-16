--- @class Class A skeleton class template that can be inherited from.
--- @field public className string String representation of the class' name
--- @field protected _class Class<Class> This Class.

local Class = {}
do
    Class.className = "Class"
    Class._class = Class

    --- @virtual
    --- @function Class:_init
    --- Defines the constructor to be called by ``Class:new``.
    --- Note: To call the parent constructor, you may use the ``_parent`` field.
    --- @vararg any The supplied arguments to the constructor
    --- @usage
    --- function SubClass:_init()
    ---     self._parent._init(self)  -- pass in the context of this class, not the parent!
    --- end
    Class._init = function(self)
    end

    --- @function Class:new
    --- Calls the constructor to create a new instance of the Class.
    --- @vararg any The supplied arguments to the constructor
    --- @treturn Class The instance of the Class
    Class.new = function(super, ...)
        local init = super._init
        if not init then error("Not a valid Class.") end
        if super._isInstance then error("Expected Class, got Instance.") end

        local instance = setmetatable({ _isInstance = true }, super)
        init(instance, ...)

        return instance
    end

    --- @function Class:extend
    --- Extend a class with a given name and returns it.
    --- @tparam[opt=""] string name The name of the extended class. The default is an empty string
    --- @treturn Class<Class> The extended Class
    Class.extend = function(base, name)
        if base._isInstance then error("Expected Class, got Instance.") end
        local super = setmetatable({ className = name, _parent = base }, base)
        super._class = super
        super.__index = super
        return super
    end

    --- @function Class:isSubClass
    --- Check if the given Class is a subclass of this.
    --- @tparam Class<Class> class The given Class
    --- @treturn bool The result
    Class.isSubClass = function(self, class)
        -- Check if it's a valid Class
        if type(class) ~= "table" or not class._init then return false end

        local c = self._class
        while c do
            if c == class then return true end
            c = c._parent
        end

        return false
    end

    Class.__index = Class
    Class.__call = Class.new
end

return Class
