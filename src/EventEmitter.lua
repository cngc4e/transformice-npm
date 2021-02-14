--- Event emitter.
--- @class EventEmitter:Class
local EventEmitter = require("Class"):extend("EventEmitter")

do
    --- @function EventEmitter:new
    --- Creates a new event emitter.
    --- @treturn EventEmitter The instance of the EventEmitter
    EventEmitter._init = function(self)
        self._listeners = { _sz = 0 }
        self._crucialListeners = { _sz = 0 }
    end

    --- @function EventEmitter:on
    --- Adds the listener function to the end of the listeners array for the event named eventName.
    --- No checks are made to see if the listener has already been added.
    --- @tparam eventName The name of the event
    --- @tparam eventName The callback function
    --- @tparam table options
    --- @return EventEmitter
    EventEmitter.on = function(self, eventName, listener, options)
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

    EventEmitter.addListener = EventEmitter.on

    EventEmitter.addCrucialListener = function(self, eventName, listener, options)
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

    EventEmitter.once = function(self, eventName, listener, options)
        options = options or {}
        options.once = true
        return self:on(eventName, listener, options)
    end

    EventEmitter.off = function(self, eventName, listener)
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

    EventEmitter.removeListener = EventEmitter.off

    EventEmitter.emit = function(self, eventName, ...)
        local listeners = self._listeners[eventName]
        if not listeners then return end
        
        local listenersIndexToRemove = { _sz = 0 }

        for i = 1, listeners._sz do
            local listener, options = listeners[i][1], listeners[i][2]
            listener(...)
            if options and options.once then
                listenersIndexToRemove._sz = listenersIndexToRemove._sz + 1
                listenersIndexToRemove[listenersIndexToRemove._sz] = i
            end
        end

        -- TODO: probably less expensive to create a new table as the size of the list grows
        for i = 1, listenersIndexToRemove._sz do
            table.remove(listeners, listenersIndexToRemove[i])
            listeners._sz = listeners._sz - 1
        end

        return self
    end
end

return EventEmitter
