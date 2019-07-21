--[[ Your goals this assignment:
TODO When the player touches this goal post, we should regenerate the level, spawn the player at the beginning of it again (this can all be done via just reloading PlayState), and make it a little longer than it was before. You’ll need to introduce params to the PlayState:enter function that keeps track of the current level and persists the player’s score for this to work properly. The easiest way to do this is to just add an onConsume callback to each flag piece when we instantiate them in the last goal; this onConsume method should then just restart our PlayState, only now we’ll need to ensure we pass in our score and width of our game map so that we can generate a map larger than the one before it. For this, you’ll need to implement a PlayState:enter method accordingly; see prior assignments for plenty of examples on how we can achieve this! And don’t forget to edit the default gStateMachine:change('play') call to take in some default score and level width!

]]
--[[
    GD50
    Super Mario Bros. Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A classic platformer in the style of Super Mario Bros., using a free
    art pack. Super Mario Bros. was instrumental in the resurgence of video
    games in the mid-80s, following the infamous crash shortly after the
    Atari age of the late 70s. The goal is to navigate various levels from
    a side perspective, where jumping onto enemies inflicts damage and
    jumping up into blocks typically breaks them or reveals a powerup.

    Art pack:
    https://opengameart.org/content/kenney-16x16

    Music:
    https://freesound.org/people/Sirkoto51/sounds/393818/
]]

love.graphics.setDefaultFilter('nearest', 'nearest')
require 'src/Dependencies'

function love.load()
    love.graphics.setFont(gFonts['medium'])
    love.window.setTitle('Super 50 Bros.')

    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true,
        canvas = false
    })

    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end
    }
    gStateMachine:change('start')

    gSounds['music']:setLooping(true)
    gSounds['music']:setVolume(0.5)
    gSounds['music']:play()

    --[[ declaring this--regrettably--as a global variable, mostly to get around
        scope issues caused by LevelMaker not being a class (and by onCollide not
        getting player passed as a paremeter)
    ]]
    gKeyVals = {
        ['obtained'] = false,
        ['color'] = math.random(4),
        ['unlocked'] = false
    }
    -- initialize level width at 100 at first
    gLevelWidth = 100
    gPlayerScore = 0
    gNewLevel = false
    gLevelNumber = 1

    love.keyboard.keysPressed = {}

end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    gStateMachine:render()
    push:finish()
end
