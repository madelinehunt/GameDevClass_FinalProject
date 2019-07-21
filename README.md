Super Mario Bros., The Key and Lock Update

by Nathan Hunt

## Objectives ##

+ *Program it such that when the player is dropped into the level, they’re always done so above solid ground.* 

   Done by simply not allowing chasms to appear in the first 4 columns of the level (accomplished in `LevelMaker.generate()` with an added conditional to the logic that creates the chasms).
   
+ *In LevelMaker.lua, generate a random-colored key and lock block (taken from keys_and_locks.png in the graphics folder of the distro).*

    Completed in `LevelMaker.generate()` after the chasms, pillars, and blocks spawn. As suggested, I used a boolean flag, `jumpBlockHere` to make sure that locks and keys don't spawn in the same place as item blocks. I also only spawn keys and locks in specific sections of the level (defined as percentages), and the keys appear later in the level than the locks do. This adds some interest to the game, whereby the player has to backtrack for a portion of the level—navigating obstacles in reverse.

+ *Once the lock has disappeared, trigger a goal post to spawn at the end of the level.* 

    As suggested, I did this in the `onCollide` callback of the lock object. Each section of the flag pole, and the banner, are their own object, but they are arranged visually as if they were one big object. 

+ *When the player touches this goal post, we should regenerate the level, spawn the player at the beginning of it again (this can all be done via just reloading PlayState), and make it a little longer than it was before.* 

    Done—touching the flagpole takes the player to the next level, which is 20 columns wider than the previous one. Player score is preserved, but key state is reset, and the level counter is incremented.

### Other changes ###

+ As always, I added a `testing` file to handle argvs. This time, the only arg I found useful was `nosound`, which sets all LÖVE volume to 0.
+ I changed the player sprite to the pink alien. The green alien is really hard to see against the green background.
+ For convenience, I ended up cutting up the `flags.png` spritesheet into separate files for the flagpole, and the flag itself. 
+ Small interface touches in the upper right corner, including display of level number and key status (i.e., displaying the key icon when the player has the key, and displaying the flag icon when the player has unlocked the lock). 
+ I refactored player states so that any death condition calls the `die()` method of the `Player` class, which is much clearer and allows easier changing of behavior. 
+ This is outside the scope of the assignment, but if I had had more time, I would've fixed the collision detection on the player avatar. It's fairly buggy—the player can get trapped by the right edge of item boxes and can't jump past them, and the player can simply walk over chasms that are only one tile wide. 