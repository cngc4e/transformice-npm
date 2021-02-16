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
                local p = options.playerClass:new(self, pn)
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
            self:onCrucial("newPlayer", function(player)
                if options.fastPlayerFacing then
                    env.system.bindKeyboard(player.name, 0, true)  -- left
                    env.system.bindKeyboard(player.name, 2, true)  -- right

                    player:onCrucial("keyboard", function(key, down)
                        if down then
                            if key == 0 then player.isFacingRight = false
                            elseif key == 2 then player.isFacingRight = true
                            end
                        end
                    end)
                end
            end)
        end

        Api.addBonus = env.tfm.exec.addBonus
        Api.addConjuration = env.tfm.exec.addConjuration
        Api.addImage = env.tfm.exec.addImage
        Api.addJoint = env.tfm.exec.addJoint
        Api.addPhysicObject = env.tfm.exec.addPhysicObject
        Api.addShamanObject = env.tfm.exec.addShamanObject
        Api.bindKeyboard = env.tfm.exec.bindKeyboard
        Api.changePlayerSize = env.tfm.exec.changePlayerSize
        Api.chatMessage = env.tfm.exec.chatMessage
        Api.disableAfkDeath = env.tfm.exec.disableAfkDeath
        Api.disableAllShamanSkills = env.tfm.exec.disableAllShamanSkills
        Api.disableAutoNewGame = env.tfm.exec.disableAutoNewGame
        Api.disableAutoScore = env.tfm.exec.disableAutoScore
        Api.disableAutoShaman = env.tfm.exec.disableAutoShaman
        Api.disableAutoTimeLeft = env.tfm.exec.disableAutoTimeLeft
        Api.disableDebugCommand = env.tfm.exec.disableDebugCommand
        Api.disableMinimalistMode = env.tfm.exec.disableMinimalistMode
        Api.disableMortCommand = env.tfm.exec.disableMortCommand
        Api.disablePhysicalConsumables = env.tfm.exec.disablePhysicalConsumables
        Api.disablePrespawnPreview = env.tfm.exec.disablePrespawnPreview
        Api.disableWatchCommand = env.tfm.exec.disableWatchCommand
        Api.displayParticle = env.tfm.exec.displayParticle
        Api.explosion = env.tfm.exec.explosion
        Api.freezePlayer = env.tfm.exec.freezePlayer
        Api.giveCheese = env.tfm.exec.giveCheese
        Api.giveConsumables = env.tfm.exec.giveConsumables
        Api.giveMeep = env.tfm.exec.giveMeep
        Api.giveTransformations = env.tfm.exec.giveTransformations
        Api.killPlayer = env.tfm.exec.killPlayer
        Api.linkMice = env.tfm.exec.linkMice
        Api.lowerSyncDelay = env.tfm.exec.lowerSyncDelay
        Api.moveObject = env.tfm.exec.moveObject
        Api.movePlayer = env.tfm.exec.movePlayer
        Api.newGame = env.tfm.exec.newGame
        Api.playEmote = env.tfm.exec.playEmote
        Api.playerVictory = env.tfm.exec.playerVictory
        Api.removeBonus = env.tfm.exec.removeBonus
        Api.removeCheese = env.tfm.exec.removeCheese
        Api.removeImage = env.tfm.exec.removeImage
        Api.removeJoint = env.tfm.exec.removeJoint
        Api.removeObject = env.tfm.exec.removeObject
        Api.removePhysicObject = env.tfm.exec.removePhysicObject
        Api.respawnPlayer = env.tfm.exec.respawnPlayer
        Api.setAutoMapFlipMode = env.tfm.exec.setAutoMapFlipMode
        Api.setGameTime = env.tfm.exec.setGameTime
        Api.setNameColor = env.tfm.exec.setNameColor
        Api.setPlayerScore = env.tfm.exec.setPlayerScore
        Api.setRoomMaxPlayers = env.tfm.exec.setRoomMaxPlayers
        Api.setRoomPassword = env.tfm.exec.setRoomPassword
        Api.setShaman = env.tfm.exec.setShaman
        Api.setShamanMode = env.tfm.exec.setShamanMode
        Api.setUIMapName = env.tfm.exec.setUIMapName
        Api.setUIShamanName = env.tfm.exec.setUIShamanName
        Api.setVampirePlayer = env.tfm.exec.setVampirePlayer
        Api.setWorldGravity = env.tfm.exec.setWorldGravity
        Api.snow = env.tfm.exec.snow

        Api.bindKeyboard = env.system.bindKeyboard
        Api.bindMouse = env.system.bindMouse
        Api.disableChatCommandDisplay = env.system.disableChatCommandDisplay
        Api.exit = env.system.exit
        Api.giveEventGift = env.system.giveEventGift
        Api.loadFile = env.system.loadFile
        Api.loadPlayerData = env.system.loadPlayerData
        Api.newTimer = env.system.newTimer
        Api.removeTimer = env.system.removeTimer
        Api.saveFile = env.system.saveFile
        Api.savePlayerData = env.system.savePlayerData

        Api.addPopup = env.ui.addPopup
        Api.addTextArea = env.ui.addTextArea
        Api.removeTextArea = env.ui.removeTextArea
        Api.setMapName = env.ui.setMapName
        Api.setShamanName = env.ui.setShamanName
        Api.showColorPicker = env.ui.showColorPicker
        Api.updateTextArea = env.ui.updateTextArea

        Api.emitExistingPlayers = function(self)
            for name, rp in pairs(env.tfm.get.room.playerList) do
                local p = options.playerClass:new(self, name)
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
