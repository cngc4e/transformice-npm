local Player = require("EventEmitter"):extend("Player")
do
    Player._init = function(self, name)
        Player._parent._init(self)

        self.name = name
    end
end

return Player
