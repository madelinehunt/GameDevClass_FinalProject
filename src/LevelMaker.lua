--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    if gStateMachine.current.keyVals == nil then
        gStateMachine.current.keyVals = {
            ['obtained'] = false,
            ['color'] = math.random(4),
            ['unlocked'] = false
        }
    end

    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND

    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    local keySpawned = false
    local lockSpawned = false

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        jumpBlockHere = false

        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        --[[ ADDED: only has a chance to spawn chasm if AFTER first 4 columns,
        and makes sure that final two columns are solid (for flag)
        ]]

        if math.random(7) == 1 and x > 4 and x < width-2 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 and x < width-2 then
                blockHeight = 2

                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,

                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end

                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil

            -- chance to generate bushes
            elseif math.random(8) == 1 and x < width-2 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            -- chance to spawn a block
            if math.random(10) == 1 and x < width-2 then
                jumpBlockHere = true
                table.insert(objects,
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }

                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            end

            -- spawning the lock
            if lockSpawned == false and x > (width*.4) and x < (width*.6) and not jumpBlockHere then
                lockSpawned = true
                newLock = GameObject {
                    texture = 'locks',
                    x = (x - 1) * TILE_SIZE,
                    y = (blockHeight - 1) * TILE_SIZE,
                    width = 16,
                    height = 16,
                    frame = gStateMachine.current.keyVals.color,
                    collidable = true,
                    hit = false,
                    solid = true,
                    onCollide = function(obj)
                        if gStateMachine.current.keyVals['obtained'] then
                            gSounds['powerup-reveal']:play()
                            gStateMachine.current.keyVals['unlocked'] = true
                            for k,v in pairs(objects) do
                                if v.texture == 'locks' then
                                    table.remove(objects, k)
                                end
                            end

                            for i=1,3 do
                                flagFrame = gStateMachine.current.keyVals.color + ((i-1)*N_OF_FLAGS)
                                local flagpole = GameObject {
                                    texture = 'flagpoles',
                                    x = (gStateMachine.current.levelWidth-2)*TILE_SIZE,
                                    y = ((2+i)*TILE_SIZE),
                                    width = 16,
                                    height = 16,
                                    frame = flagFrame,
                                    collidable = true,
                                    consumable = false,
                                    solid = false,
                                }
                                if i == 2 then
                                    flagpole.consumable = true
                                    flagpole.onConsume = function(player, object)
                                        gStateMachine:change('play', {
                                            ['levelNum'] = gStateMachine.current.levelNum + 1,
                                            ['score'] = gStateMachine.current.player.score,
                                            ['levelWidth'] = gStateMachine.current.levelWidth + 20,
                                        })
                                    end
                                end
                                table.insert(objects, flagpole)
                            end
                            local flagBanner = GameObject {
                                texture = 'flagbanners',
                                x = (gStateMachine.current.levelWidth-1)*TILE_SIZE-8,
                                y = (3*TILE_SIZE),
                                width = 16,
                                height = 16,
                                frame = gStateMachine.current.keyVals.color*2,
                                collidable = true,
                                consumable = false,
                                solid = false,
                            }
                            table.insert(objects, flagBanner)

                        else
                            gSounds['empty-block']:play()
                        end

                    end,
                }
                newLock.deletePos = #objects
                table.insert(objects,newLock)
            end

            -- spawning the key
            if keySpawned == false and x > (width*.65) and x < (width*.85) and not jumpBlockHere then
                keySpawned = true
                newKey = GameObject {
                    texture = 'keys',
                    x = (x - 1) * TILE_SIZE,
                    y = (blockHeight - 1) * TILE_SIZE,
                    width = 16,
                    height = 16,
                    frame = gStateMachine.current.keyVals.color,
                    -- collidable = true,
                    hit = false,
                    solid = false,
                    consumable = true,
                    onConsume = function(player, object)
                        gSounds['pickup']:play()
                        player.score = player.score + 200
                        gStateMachine.current.keyVals['obtained'] = true
                    end
                }
                table.insert(objects,newKey)
            end
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles

    return GameLevel(entities, objects, map)
end
