--- Player class.
--- @class Player:EventEmitter
local Player = require("EventEmitter"):extend("Player")

--- @function Player
--- @tparam Api api The `Api` that the player is associated with
--- @tparam string name The name of the player
--- @treturn Player The instance of the Class
Player._init = function(self, api, name)
    Player._parent._init(self)

    self.api = api
    self.name = name
end

--- @function Player:freeze
--- @tparam bool freeze Whether the player should be frozen
Player.freeze = function(self, freeze)
    return self.api.freezePlayer(self.name, freeze)
end

return Player
