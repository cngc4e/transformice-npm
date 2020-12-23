local EventEmitter = require("Class"):extend("EventEmitter")

do
    EventEmitter._init = function(self)
        self._listeners = { _sz = 0 }
    end

    EventEmitter.addListener = function(self, eventName, listener, options)
        local events = self._listeners
        if not events[eventName] then
            events[eventName] = { _sz = 0 }
            events._sz = events._sz + 1
        end

        local event = events[eventName]
        event._sz = event._sz + 1
        event[event._sz] = { listener, options }

        return self
    end

    EventEmitter.on = EventEmitter.addListener

    EventEmitter.once = function(self, eventName, listener, options)
        options = options or {}
        options.once = true
        return self:addListener(eventName, listener, options)
    end

    EventEmitter.removeListener = function(self, eventName, listener)
        local listeners = self._listeners[eventName]
        if not listeners then return end

        for i = 1, listeners._sz do
            if listeners[i][1] == listener then
                table.remove(listeners, i)
                listeners._sz = listeners._sz - 1
                break
            end
        end

        if listeners._sz <= 0 then
            self._listeners[eventName] = nil
        end

        return self
    end

    EventEmitter.off = EventEmitter.removeListener

    EventEmitter.emit = function(self, eventName, ...)
        local listeners = self._listeners[eventName]
        if not listeners then return end
        
        for i = 1, listeners._sz do
            local listener, options = listeners[i][1], listeners[i][2]
            listener(...)
            if options and options.once then
                table.remove(listeners, i)
                listeners._sz = listeners._sz - 1
            end
        end

        return self
    end
end

return EventEmitter
