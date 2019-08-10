--[[
    GD50
    Super Mario Bros. Remake

    -- StartState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Helper functions for writing Match-3.
]]

--[[
    Given an "atlas" (a texture with multiple sprites), as well as a
    width and a height for the tiles therein, split the texture into
    all of the quads by simply dividing it evenly.
]]
function GenerateQuads(atlas, tilewidth, tileheight)
    local sheetWidth = atlas:getWidth() / tilewidth
    local sheetHeight = atlas:getHeight() / tileheight

    local sheetCounter = 1
    local spritesheet = {}

    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            spritesheet[sheetCounter] =
                love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth,
                tileheight, atlas:getDimensions())
            sheetCounter = sheetCounter + 1
        end
    end

    return spritesheet
end

--[[
    Divides quads we've generated via slicing our tile sheet into separate tile sets.
]]
function GenerateTileSets(quads, setsX, setsY, sizeX, sizeY)
    local tilesets = {}
    local tableCounter = 0
    local sheetWidth = setsX * sizeX
    local sheetHeight = setsY * sizeY

    -- for each tile set on the X and Y
    for tilesetY = 1, setsY do
        for tilesetX = 1, setsX do

            -- tileset table
            table.insert(tilesets, {})
            tableCounter = tableCounter + 1

            for y = sizeY * (tilesetY - 1) + 1, sizeY * (tilesetY - 1) + 1 + sizeY do
                for x = sizeX * (tilesetX - 1) + 1, sizeX * (tilesetX - 1) + 1 + sizeX do
                    table.insert(tilesets[tableCounter], quads[sheetWidth * (y - 1) + x])
                end
            end
        end
    end

    return tilesets
end

--[[
    Recursive table printing function.
    https://coronalabs.com/blog/2014/09/02/tutorial-printing-table-contents/
]]
function print_r ( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

--[[
    I cannot believe Lua has no built-in way to copy tables.
    Here's one from https://gist.github.com/tylerneylon/81333721109155b2d244#file-copy-lua-L80
]]--
function deepcopy(obj, seen)
  -- Handle non-tables and previously-seen tables.
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end

  -- New table; mark it as seen an copy recursively.
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[deepcopy(k, s)] = deepcopy(v, s) end
  return res
end



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

--[[
    Wow, lua also doesn't have a string split function.
    Here's one from https://helloacm.com/split-a-string-in-lua/
]]
function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

-- function to transpose a 2d array (matrix)
-- assumes all x-axis arrays are the same length
function matrixTranspose(matrix)
    local ylen = 0
    for i,v in ipairs(matrix) do
        ylen = ylen + 1
    end

    local xlen = 0
    for i,v in ipairs(matrix[1]) do
        xlen = xlen + 1
    end

    matrixToReturn = {}
    for y = 1, xlen do
        newRow = {}
        for x,v in ipairs(matrix) do
            table.insert(newRow, matrix[x][y])
        end
        table.insert(matrixToReturn, newRow)
    end

    return matrixToReturn
end
