--[[
    GD50
    Super Mario Bros. Remake

    -- PlayState Class --
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.camX = 0
    self.camY = 0
end

function PlayState:update(dt)
    Timer.update(dt)

    -- remove any nils from pickups, etc.
    self.level:clear()

    -- update player and level
    self.player:update(dt)
    self.level:update(dt)
    self:updateCamera()

    -- constrain player X no matter which state
    if self.player.x <= 0 then
        self.player.x = 0
    elseif self.player.x > TILE_SIZE * self.tileMap.width - self.player.width then
        self.player.x = TILE_SIZE * self.tileMap.width - self.player.width
    end
end

function PlayState:render()
    love.graphics.push()
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)

    -- translate the entire view of the scene to emulate a camera
    love.graphics.translate(-math.floor(self.camX), -math.floor(self.camY))

    self.level:render()

    self.player:render()
    love.graphics.pop()

    -- render score
    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.print(tostring(self.player.score), 5, 5)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(tostring(self.player.score), 4, 4)

    -- displays level number
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.print("Level "..tostring(self.levelNum), VIRTUAL_WIDTH-40, 10)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print("Level "..tostring(self.levelNum), VIRTUAL_WIDTH-39.5, 9.5)
    love.graphics.setFont(gFonts['medium'])

    -- displays extra lives count
    love.graphics.draw(
        gTextures['pink-alien'], gFrames['pink-alien'][1],
        -- x and y
        (VIRTUAL_WIDTH/2) - 6, 6,
        0, 0.5
    )
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.print(" x "..tostring(self.player.lives), (VIRTUAL_WIDTH/2), 10)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(" x "..tostring(self.player.lives), (VIRTUAL_WIDTH/2) - 0.5, 9.5)
    love.graphics.setFont(gFonts['medium'])



    if self.keyVals.obtained and not self.keyVals.unlocked then
        -- draw key icon in upper right corner
        love.graphics.draw(
            -- textures indexed by key color number
            gTextures['keys'], gFrames['keys'][self.keyVals.color],
            -- x and y
            (VIRTUAL_WIDTH -TILE_SIZE)-2, 2,
            -- rotation and scale
            0, 0.5
        )
    else if self.keyVals.unlocked then
        -- draw flag icon in upper right corner
        love.graphics.draw(
            -- textures indexed by key color number
            gTextures['flagbanners'], gFrames['flagbanners'][self.keyVals.color*2],
            -- x and y
            (VIRTUAL_WIDTH -TILE_SIZE)-2, 2,
            -- rotation and scale
            0, 0.5
        )
    end
    end

end

function PlayState:updateCamera()
    -- clamp movement of the camera's X between 0 and the map bounds - virtual width,
    -- setting it half the screen to the left of the player so they are in the center
    self.camX = math.max(0,
        math.min(TILE_SIZE * self.tileMap.width - VIRTUAL_WIDTH,
        self.player.x - (VIRTUAL_WIDTH / 2 - 8)))

    -- adjust background X to move a third the rate of the camera for parallax
    self.backgroundX = (self.camX / 3) % 256
end

--[[
    Adds a series of enemies to the level randomly.
]]
function PlayState:spawnEnemies()
    -- spawn snails in the level
    for x = 1, self.tileMap.width do

        -- flag for whether there's ground on this column of the level
        local groundFound = false

        for y = 1, self.tileMap.height do
            if not groundFound then
                if self.tileMap.tiles[y][x].id == TILE_ID_GROUND then
                    groundFound = true

                    -- random chance, 1 in 20
                    if math.random(20) == 1 then

                        -- instantiate snail, declaring in advance so we can pass it into state machine
                        local snail
                        snail = Snail {
                            texture = 'creatures',
                            x = (x - 1) * TILE_SIZE,
                            y = (y - 2) * TILE_SIZE + 2,
                            width = 16,
                            height = 16,
                            stateMachine = StateMachine {
                                ['idle'] = function() return SnailIdleState(self.tileMap, self.player, snail) end,
                                ['moving'] = function() return SnailMovingState(self.tileMap, self.player, snail) end,
                                ['chasing'] = function() return SnailChasingState(self.tileMap, self.player, snail) end
                            }
                        }
                        snail:changeState('idle', {
                            wait = math.random(5)
                        })

                        table.insert(self.level.entities, snail)
                    end
                end
            end
        end
    end
end

function PlayState:enter(params)
    -- set defaults
    if params == nil then
        params = {
            ['levelNum'] = 1,
            ['score'] = 0,
            ['levelWidth'] = 100,
        }
    end
    -- always init to the same values
    self.keyVals = {
        ['obtained'] = false,
        ['color'] = math.random(4),
        ['unlocked'] = false
    }

    self.levelNum = params.levelNum
    self.levelWidth = params.levelWidth

    self.level = LevelMaker.generate(self.levelWidth, 10)
    self.tileMap = self.level.tileMap
    self.background = math.random(3)
    self.backgroundX = 0

    self.gravityOn = true
    self.gravityAmount = 6

    self.player = Player({
        x = 0, y = 0,
        width = 12, height = 20,
        texture = 'pink-alien',
        stateMachine = StateMachine {
            ['idle'] = function() return PlayerIdleState(self.player) end,
            ['walking'] = function() return PlayerWalkingState(self.player) end,
            ['jump'] = function() return PlayerJumpState(self.player, self.gravityAmount) end,
            ['falling'] = function() return PlayerFallingState(self.player, self.gravityAmount) end
        },
        map = self.tileMap,
        level = self.level,
    })
    self.player.score = params.score

    if params.lives == nil then
        self.player.lives = 3
    else
        self.player.lives = params.lives
    end


    self:spawnEnemies()

    self.levelDoOver = {
        ['levelObj'] = deepcopy(self.level),
        ['tileMap'] = deepcopy(self.level.tileMap),
        ['entities'] = deepcopy(self.level.entities),
        ['objects'] = deepcopy(self.level.objects),
    }
    self.player:changeState('falling')
end


function PlayState:DoOver(params)
    -- self.level = self.levelDoOver.levelObj
    -- self.player.level = self.levelDoOver.levelObj


    self.tileMap = self.levelDoOver.tileMap
    self.level.entities = self.levelDoOver.entities
    self.level.objects = self.levelDoOver.objects
    self.keyVals['obtained'] = false
    self.keyVals['unlocked'] = false

    self.player.x = 0
    self.player.y = 0

    -- reset enemies
    for k, v in pairs(self.level.entities) do
        v.stateMachine = StateMachine {
            ['idle'] = function() return SnailIdleState(self.tileMap, self.player, v) end,
            ['moving'] = function() return SnailMovingState(self.tileMap, self.player, v) end,
            ['chasing'] = function() return SnailChasingState(self.tileMap, self.player, v) end
        }
        v:changeState('idle', {
            wait = math.random(5)
        })
    end


end
