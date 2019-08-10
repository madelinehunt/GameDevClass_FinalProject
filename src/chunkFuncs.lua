-- function to parse the text files I use to visually design chunks for the levels
function parseChunk(filename)
    -- symbol mapping
    symbolKey = {
        ['.'] = "empty",
        ['#'] = "tile",
        -- ['@'] = "key",
        -- ['%'] = "block",
    }

    -- reads from file, mapping symbols to descriptions
    lines = {}
    chunk = io.open(filename, "r")
    for line in chunk:lines() do
        row = {}
        for i=1, #line do
            char = line:sub(i,i)
            table.insert(row, symbolKey[char])
        end
        table.insert(lines, row)
    end
    chunk:close()
    return lines
end

function genTileMeta(pChunk)
    tileMeta = {}
    transposed = matrixTranspose(pChunk)
    local len = 0
    for i,v in ipairs(pChunk[1]) do
        len = len + 1
    end

    for i=1, len do
        yMeta = {
            ['empty'] = false,
            ['groundHeight'] = 0,
            ['pillar'] = false,
        }

        -- finds first non-empty tile
        for k, v in pairs(transposed[i]) do
            if  v == 'tile' then
                yMeta['groundHeight'] = k
                break
            end
        end
        table.insert(tileMeta, yMeta)
    end
    -- check for pillars
    local pillarHeuristic = 2
    for i=2, #tileMeta-1 do
        local height = tileMeta[i].groundHeight
        local deltaLeft = tileMeta[i-1].groundHeight - height
        local deltaRight = tileMeta[i+1].groundHeight - height
        if deltaLeft >= pillarHeuristic and deltaRight >= pillarHeuristic then
            tileMeta[i].pillar = true
        end

    end

    return tileMeta
end

function genChunk(parsedChunk, tileset, topperset)
    returnChunk = {}
    chunkOfTiles = {}

    for x,v in pairs(parsedChunk) do
        row = {}
        for y, v2 in pairs(v) do
            if v2 == 'empty' then
                table.insert(row, Tile(y, x, TILE_ID_EMPTY, nil, tileset, topperset))
            elseif v2 == 'tile' then
                -- make it a topper if the x,y above is empty
                if #chunkOfTiles > 1 and parsedChunk[x-1][y] == 'empty' then
                    topperBool = true
                else
                    topperBool = nil
                end
                table.insert(row, Tile(y, x, TILE_ID_GROUND, topperBool, tileset, topperset))
            end
        end
        table.insert(chunkOfTiles, row)
    end

    returnChunk['tiles'] = chunkOfTiles
    -- print_r(chunkOfTiles)
    returnChunk['tileMeta'] = genTileMeta(parsedChunk)
    return returnChunk
end
