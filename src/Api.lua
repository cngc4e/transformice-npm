local Player = require("Player")

local Api = require("EventEmitter"):extend("Api")
do
    local defaultOpts = {
        playerClass = Player,  -- The instance type to create for each player. Must either be Player or a superclass of Player.
        fastPlayerFacing = true,  -- If true, uses the keyboard events to determine isFacingRight (faster). If false, relies on room sync.
        --logAbsentPlayers = false,  -- Whether to log when an event is triggered against a Player that is absent from the room.
    }

    Api._init = function(self, env, opts)
        Api._parent._init(self)

        opts = opts or {}
        env = env or _G

        if type(opts) ~= "table" then error("options: Expected table, got " .. type(opts)) end
        if type(env) ~= "table" then error("env: Expected table, got " .. type(env)) end

        self.options = setmetatable(opts, { __index = defaultOpts })
        self.env = env
        self.systemTree = env.system
        self.tfmTree = env.tfm
        self.uiTree = env.ui
        self.players = {}

        self:hookEnvEvents()
        self:hookEvents()
    end

    Api.hookEnvEvents = function(self)
        self.env["eventNewPlayer"] = function(pn)
            local p = self.options.playerClass:new(pn)
            self.players[pn] = p

            self:emit("newPlayer", p)
        end

        self.env["eventPlayerLeft"] = function(pn)
            local p = self.players[pn]
            if not p then return end

            p:emit("left")

            self.players[pn] = nil
        end

        self.env["eventKeyboard"] = function(pn, k, down, xPos, yPos)
            local p = self.players[pn]
            if not p then return end

            p:emit("keyboard", k, down, xPos, yPos)
        end
    end

    Api.hookEvents = function(self)
        self:on("newPlayer", function(player)
            if self.options.fastPlayerFacing then
                self.systemTree.bindKeyboard(player.name, 0, true)  -- left
                self.systemTree.bindKeyboard(player.name, 2, true)  -- right

                player:on("keyboard", function(key, down)
                    if down then
                        if key == 0 then player.isFacingRight = false
                        elseif key == 2 then player.isFacingRight = true
                        end
                    end
                end)
            end
        end)
    end

    Api.emitExistingPlayers = function(self)
        for name, rp in pairs(self.tfmTree.get.room.playerList) do
            local p = self.options.playerClass:new(name)
            self.players[name] = p

            self:emit("newPlayer", p)
        end
    end

    Api.setReady = function(self)
        self:emitExistingPlayers()
    end
end

return Api
