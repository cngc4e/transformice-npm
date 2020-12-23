local Class = {}
do
    Class._className = "Class"
    Class.__index = Class

    Class._init = function(self)
    end

    Class.new = function(super, ...)
        local init = super._init
        if not init then error("Not a valid Class.") end

        local instance = setmetatable({}, super)
        init(instance, ...)

        return instance
    end

    Class.extend = function(base, name)
        local super = setmetatable({ _className = name, _parent = base }, base)
        super.__index = super
        return super
    end
end

return Class
