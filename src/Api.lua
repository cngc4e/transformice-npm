--- Main API initializer for Transformice.
--- @class Api:EventEmitter

local Player = require("Player")

local _main = function(v_env, opts)
    -- Private vars
    local options
    local playerClass
    local baseApiVersion
    local transformiceVersion
    local env
    local players = {}

    local defaultOpts = {
        playerClass = Player,  -- The instance type to create for each player. Must either be Player or a superclass of Player.
        fastPlayerFacing = true,  -- If true, uses the keyboard events to determine isFacingRight (faster). If false, relies on room sync.
        --logAbsentPlayers = false,  -- Whether to log when an event is triggered against a Player that is absent from the room.
    }

    -- Init
    env = v_env or _G
    opts = opts or {}

    if type(opts) ~= "table" then error("options: Expected table, got " .. type(opts)) end
    if type(env) ~= "table" then error("env: Expected table, got " .. type(env)) end

    local Api = require("EventEmitter"):extend("Api")
    do
        Api.VERSION = "0.1.0"

        Api._init = function(self)
            Api._parent._init(self)
        
            -- Options table, unspecified options will fallback to defaultOpts.
            options = setmetatable(opts, { __index = defaultOpts })

            -- Verify options
            local playerClass = options.playerClass
            if type(playerClass) ~= "table"
                    or not playerClass.isSubClass
                    or not playerClass:isSubClass(Player) then
                error("options.playerClass: Expected subclass of Player for class " .. playerClass.className or "nil")
            end

            baseApiVersion = env.tfm.get.misc.apiVersion
            transformiceVersion = env.tfm.get.misc.transformiceVersion
            self.baseApiVersion = baseApiVersion
            self.transformiceVersion = transformiceVersion

            players = {}

            self:hookEnvEvents()
            self:hookEvents()
        end

        Api.hookEnvEvents = function(self)
            env["eventNewPlayer"] = function(pn)
                local p = options.playerClass:new(pn)
                players[pn] = p

                self:emit("newPlayer", p)
            end

            env["eventPlayerLeft"] = function(pn)
                local p = players[pn]
                if not p then return end

                p:emit("left")

                players[pn] = nil
            end

            env["eventKeyboard"] = function(pn, k, down, xPos, yPos)
                local p = players[pn]
                if not p then return end

                p:emit("keyboard", k, down, xPos, yPos)
            end
        end

        Api.hookEvents = function(self)
            self:on("newPlayer", function(player)
                if options.fastPlayerFacing then
                    env.system.bindKeyboard(player.name, 0, true)  -- left
                    env.system.bindKeyboard(player.name, 2, true)  -- right

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

        Api.chatMessage = env.tfm.exec.chatMessage
        Api.bindKeyboard = env.system.bindKeyboard
        Api.addShamanObject = env.tfm.exec.addShamanObject

        Api.emitExistingPlayers = function(self)
            for name, rp in pairs(env.tfm.get.room.playerList) do
                local p = options.playerClass:new(name)
                players[name] = p

                self:emit("newPlayer", p)
            end
        end

        Api.start = function(self)
            self:emitExistingPlayers()
            self:emit("ready")
        end
    end

    return Api:new()
end

return _main
