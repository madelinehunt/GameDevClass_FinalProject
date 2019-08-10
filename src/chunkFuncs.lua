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


function genChunk(parsedChunk, tileset, topperset)
    chunkOfTiles = {}
    for i,v in pairs(parsedChunk) do
        row = {}
        for i2,v2 in pairs(v) do
            if v2 == 'empty' then
                table.insert(row, Tile(i2, i, TILE_ID_EMPTY, nil, tileset, topperset))
            elseif v2 == 'tile' then
                -- make it a topper if the x,y above is empty
                if #chunkOfTiles > 1 and parsedChunk[i-1][i2] == 'empty' then
                    topperBool = true
                else
                    topperBool = nil
                end
                table.insert(row, Tile(i2, i, TILE_ID_GROUND, topperBool, tileset, topperset))
            end
        end
        table.insert(chunkOfTiles, row)
    end

    return chunkOfTiles
end
