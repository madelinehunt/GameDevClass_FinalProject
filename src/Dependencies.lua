--[[
    GD50
    Super Mario Bros. Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    -- Dependencies --

    A file to organize all of the global dependencies for our project, as
    well as the assets for our game, rather than pollute our main.lua file.
]]

--
-- libraries
--
Class = require 'lib/class'
push = require 'lib/push'
Timer = require 'lib/knife.timer'

--
-- our own code
--

-- utility
require 'src/constants'
require 'src/StateMachine'
require 'src/Util'

-- game states
require 'src/states/BaseState'
require 'src/states/game/PlayState'
require 'src/states/game/StartState'

-- entity states
require 'src/states/entity/PlayerFallingState'
require 'src/states/entity/PlayerIdleState'
require 'src/states/entity/PlayerJumpState'
require 'src/states/entity/PlayerWalkingState'

require 'src/states/entity/snail/SnailChasingState'
require 'src/states/entity/snail/SnailIdleState'
require 'src/states/entity/snail/SnailMovingState'
require 'src/states/entity/fly/FlyMovingState'

-- general
require 'src/Animation'
require 'src/Entity'
require 'src/GameObject'
require 'src/GameLevel'
require 'src/LevelMaker'
require 'src/Player'
require 'src/Snail'
require 'src/Fly'
require 'src/Tile'
require 'src/TileMap'
require 'src/chunkFuncs'

require 'src/testing'

gSounds = {
    ['jump'] = love.audio.newSource('sounds/jump.wav'),
    ['death'] = love.audio.newSource('sounds/death.wav'),
    ['music'] = love.audio.newSource('sounds/music.wav'),
    ['powerup-reveal'] = love.audio.newSource('sounds/powerup-reveal.wav'),
    ['pickup'] = love.audio.newSource('sounds/pickup.wav'),
    ['empty-block'] = love.audio.newSource('sounds/empty-block.wav'),
    ['kill'] = love.audio.newSource('sounds/kill.wav'),
    ['kill2'] = love.audio.newSource('sounds/kill2.wav')
}

gTextures = {
    ['tiles'] = love.graphics.newImage('graphics/tiles.png'),
    ['toppers'] = love.graphics.newImage('graphics/tile_tops.png'),
    ['bushes'] = love.graphics.newImage('graphics/bushes_and_cacti.png'),
    ['jump-blocks'] = love.graphics.newImage('graphics/jump_blocks.png'),
    ['gems'] = love.graphics.newImage('graphics/gems.png'),
    ['backgrounds'] = love.graphics.newImage('graphics/backgrounds.png'),
    ['pink-alien'] = love.graphics.newImage('graphics/pink_alien_slim2.png'),
    ['creatures'] = love.graphics.newImage('graphics/creatures.png'),
    ['keys'] = love.graphics.newImage('graphics/keys_and_locks.png'),
    ['locks'] = love.graphics.newImage('graphics/keys_and_locks.png'),
    ['flagpoles'] = love.graphics.newImage('graphics/flagpoles.png'),
    ['flagbanners'] = love.graphics.newImage('graphics/flag_banners.png'),
}

-- workaround because APPARENTLY lua doesn't support indexing by range
keysAndLocks = GenerateQuads(gTextures['keys'], 16, 16)
keys = {}
locks = {}
for ix=1,#keysAndLocks/2 do
    keys[ix] = keysAndLocks[ix]
    locks[ix] = keysAndLocks[ix+(#keysAndLocks/2)]
end

gFrames = {
    ['tiles'] = GenerateQuads(gTextures['tiles'], TILE_SIZE, TILE_SIZE),
    ['toppers'] = GenerateQuads(gTextures['toppers'], TILE_SIZE, TILE_SIZE),
    ['bushes'] = GenerateQuads(gTextures['bushes'], 16, 16),
    ['jump-blocks'] = GenerateQuads(gTextures['jump-blocks'], 16, 16),
    ['gems'] = GenerateQuads(gTextures['gems'], 16, 16),
    ['backgrounds'] = GenerateQuads(gTextures['backgrounds'], 256, 128),
    ['pink-alien'] = GenerateQuads(gTextures['pink-alien'], 12, 20),
    ['creatures'] = GenerateQuads(gTextures['creatures'], 16, 16),
    ['keys'] = keys,
    ['locks'] = locks,
    ['flagpoles'] = GenerateQuads(gTextures['flagpoles'], 16, 16),
    ['flagbanners'] = GenerateQuads(gTextures['flagbanners'], 16, 16),
}


-- these need to be added after gFrames is initialized because they refer to gFrames from within
gFrames['tilesets'] = GenerateTileSets(gFrames['tiles'],
    TILE_SETS_WIDE, TILE_SETS_TALL, TILE_SET_WIDTH, TILE_SET_HEIGHT)

gFrames['toppersets'] = GenerateTileSets(gFrames['toppers'],
    TOPPER_SETS_WIDE, TOPPER_SETS_TALL, TILE_SET_WIDTH, TILE_SET_HEIGHT)

gFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32),
    ['title'] = love.graphics.newFont('fonts/ArcadeAlternate.ttf', 32)
}

-- define the filenames of chunk files
chunkFilenames = {
    'chunks/pyramid.txt',
    'chunks/endFlag.txt',
    'chunks/pillars.txt',
    'chunks/dip.txt',
    'chunks/hill.txt',
    'chunks/fingers.txt',
}
