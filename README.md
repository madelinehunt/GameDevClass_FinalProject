Super Mario Bros., The Final Class Project

by Nathan Hunt

## Objectives ##

+ *Fix collision detection for the player avatar.*

    I accomplished this by shrinking the width of the player sprite. I actually prefer the less wide version, and it fixes a lot of the collision issues.

+ *Overhaul the levels to support chunk-based generation.*

    I was inspired by something that the professor said about data-driven game design—that you should work to free up your designers to create content for the game without having to manually code it. To that end, I decided to allow for predefined chunks in the level-generation. There are a number of txt files in the `chunks` directory, which allow for visually designing a 10x10 cube of tiles that are then randomly interleaved into the level in `LevelMaker.generate()`.

+ *Add in features for extra lives and the ability to retry a level.*

    Player now defaults to having three lives, and thus three chances to complete a level. To do this, I implemented a new method, `PlayState:DoOver()`, which uses a deeep-copied table backup of entities, objects, and the `level` to restore initial level state. This method also resets player position to 0,0.

+ *Add in some extra animation features, such as blocks bouncing when they get hit.*

    I added a few little touches like this. When hit, blocks are immediately shifted upwards, and then tweened back down to their initial positions. I also give the player a little extra hop when they land on an enemy, which is inspired by Super Mario Bros.

+ *Add in at least one more enemy (possibly the flying enemy from the sprite sheet).*

    Fly is added in, using the `Fly` class. It only has one state, `MovingState`, because that's all it does. It flies back and forth above the ground, changing direction based on a timer. That has the effect of bounding the fly, and giving it a defined territory that it moves back and forth over (which was also inspired by enemies in Super Mario Bros.).

### Other changes ###

+ As always, I added a `testing` file to handle argvs. Available options are:

    + `nosound`—sets Love volume to 0.
    + `run`—an experimental feature to increase player speed while the shift key is held down. This doesn't play vey well with the collision detection, so I didn't add it to the main game mode, but it is useful for testing.
    + `extraLives`—gives the player 10 lives to start out with.



Thanks for teaching this course! I had a lot of fun and learned a lot.
