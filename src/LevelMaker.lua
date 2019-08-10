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
    local tileMeta = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND

    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    local keySpawned = false
    local lockSpawned = false

    -- create blank rows
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        yMeta = {
            ['empty'] = false,
            ['groundHeight'] = 0,
            ['pillar'] = false,
        }
        local tileID = TILE_ID_EMPTY

        -- lay out the empty space
        for y = 1, 6 do
            newTile = Tile(x, y, tileID, nil, tileset, topperset)
            table.insert(tiles[y], newTile)
        end

        -- chance to just be emptiness
        --[[ ADDED: only has a chance to spawn chasm if AFTER first 4 columns
          ]]

        if math.random(7) == 1 and x > 4 and x < width-2 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
            yMeta['empty'] = true
            yMeta['groundHeight'] = 0
            table.insert(tileMeta, yMeta)
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            yMeta['groundHeight'] = 7
            -- chance to generate a pillar
            if math.random(8) == 1 and x < width-2 then
                blockHeight = 2
                yMeta['pillar'] = true

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
                yMeta['groundHeight'] = 5
            end
            table.insert(tileMeta, yMeta)
        end
    end
    -- print_r(tileMeta)


    -- substitute chunks into the tile map
    tiles = matrixTranspose(tiles)

    local chunks = {}
    for k,v in pairs(chunkFilenames) do
        name = split(v, '/')[2]
        name = split(name, '.txt')[1]
        chunks[name] = genChunk(parseChunk(v), tileset, topperset)
    end
    specials = {
        'endFlag'
    }
    specialChunks = {}
    for i,v in pairs(specials) do
        if chunks[v] ~= nil then
            specialChunks[v] = chunks[v]
            chunks[v] = nil
        end
    end
    local chunkKeys = {}
    for k,v in pairs(chunks) do
        table.insert(chunkKeys, k)
    end

    n_of_chunks = math.random(math.floor(width/30))
    lowerBound = 10
    upperBound = width -10 -CHUNK_LENGTH -- taking off another 10 for flag chunk

    yPos = math.min(math.floor(lowerBound + math.random(width/n_of_chunks)), upperBound)

    for n=1, n_of_chunks do
        key = chunkKeys[math.random(#chunkKeys)]
        sampled_chunk = chunks[key]

        newTiles = matrixTranspose(sampled_chunk['tiles'])
        newTileMeta = sampled_chunk['tileMeta']
        for col=1, CHUNK_LENGTH do
            local columnTiles = newTiles[col]
            local tilesToReplace = tiles[yPos+col]
            -- print("----")
            for i,v in ipairs(columnTiles) do
                columnTiles[i].x = tilesToReplace[i].x
                tilesToReplace[i] = columnTiles[i]
            end
            -- print_r(tiles[yPos+col])
            -- print_r(tileMeta[yPos+col])
            -- print("::")
            -- print_r(columnTiles)
            -- print_r(newTileMeta[col])
            -- print("----")
            tileMeta[yPos+col] = newTileMeta[col]
        end
        yPos = math.min(math.floor(yPos + math.random(width/n_of_chunks)), upperBound)
    end

    -- swap out end for mario-style ramp to flag

    yPos = width - CHUNK_LENGTH
    sampled_chunk = specialChunks['endFlag']
    newTiles = matrixTranspose(sampled_chunk['tiles'])
    newTileMeta = sampled_chunk['tileMeta']
    for col=1, CHUNK_LENGTH do
        local columnTiles = newTiles[col]
        for k,v in pairs(columnTiles) do
            v.x = v.x + yPos
        end
        tiles[yPos+col] = columnTiles
        tileMeta[yPos+col] = newTileMeta[col]
    end

    tiles = matrixTranspose(tiles)

    -- spawn objects and some more decorations
    for x = 1, width do
        local jumpBlockHere = false
        local yMeta = tileMeta[x]
        -- chance to spawn a block
        -- local non_empties = {}
        -- for y = 1, height do
        --     if not tiles[y][x].empty then
        --         table.insert(non_empties, y)
        --     end
        -- end
        -- if #non_empties > 1 then
        --     groundHeight = math.min(unpack(non_empties))
        --     blockHeight = math.min(unpack(non_empties)) - 3
        -- else
        --     blockHeight = 4
        -- end
        groundHeight = yMeta['groundHeight']
        blockHeight = groundHeight - 3

        if not yMeta['empty'] and not tileMeta[math.max(x-1, 1)]['pillar'] and not tileMeta[math.min(x+1, width)]['pillar'] then
            spawnable = true
        else
            spawnable = false
        end

        if math.random(8) == 1 and x < width-2 and groundHeight > 1 then
            table.insert(objects,
                GameObject {
                    texture = 'bushes',
                    x = (x - 1) * TILE_SIZE,
                    y = (groundHeight-2) * TILE_SIZE,
                    width = 16,
                    height = 16,
                    frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                    collidable = false
                }
            )
        end

        if math.random(8) == 1 and x < width-12 and spawnable then
            jumpBlockHere = true
            -- table.insert(objects,
            newBlock = GameObject {
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
                        if obj.hasGem then

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

                            table.insert(gStateMachine.current.level.objects, gem)
                        end

                        obj.hit = true
                        local oldHeight = obj['y']
                        obj.y = obj['y']-4
                        Timer.tween(0.1, {
                            [obj] = {y = oldHeight}
                        })
                    end
                    local oldHeight = obj['y']
                    obj.y = obj['y']-2
                    Timer.tween(0.1, {
                        [obj] = {y = oldHeight}
                    })
                    gSounds['empty-block']:play()
                end
            }
            -- )
            newBlock.hasGem = math.random(5) == 1

            table.insert(objects, newBlock)
        end

        -- spawning the lock
        if not lockSpawned and x > (width*.3) and x < (width*.6) and not jumpBlockHere and spawnable then
            -- print("conditions met!")
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
                    gStateMachine.current.player.y = gStateMachine.current.player.y + 2
                    if gStateMachine.current.keyVals['obtained'] then
                        gSounds['powerup-reveal']:play()
                        gStateMachine.current.keyVals['unlocked'] = true
                        for k,v in pairs(gStateMachine.current.level.objects) do
                            if v.texture == 'locks' then
                                table.remove(gStateMachine.current.level.objects, k)
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
                                    gSounds['pickup']:play()
                                    gStateMachine:change('play', {
                                        ['levelNum'] = gStateMachine.current.levelNum + 1,
                                        ['score'] = gStateMachine.current.player.score,
                                        ['levelWidth'] = gStateMachine.current.levelWidth + 20,
                                        ['lives'] = gStateMachine.current.player.lives
                                    })
                                end
                            end
                            table.insert(gStateMachine.current.level.objects, flagpole)
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
                        table.insert(gStateMachine.current.level.objects, flagBanner)

                    else
                        gSounds['empty-block']:play()
                    end

                end,
            }
            table.insert(objects,newLock)
        end

        -- spawning the key
        if keySpawned == false and x > (width*.55) and x < (width*.85) and not jumpBlockHere and spawnable then
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

    local map = TileMap(width, height)
    map.tiles = tiles

    return GameLevel(entities, objects, map)
end
