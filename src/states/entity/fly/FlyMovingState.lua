
FlyMovingState = Class{__includes = BaseState}

function FlyMovingState:init(tilemap, player, fly)
    self.tilemap = tilemap
    self.player = player
    self.fly = fly
    self.animation = Animation {
        frames = {36, 37},
        interval = 0.5
    }
    self.fly.currentAnimation = self.animation

    self.movingDirection = math.random(2) == 1 and 'left' or 'right'
    self.fly.direction = self.movingDirection
    self.movingDuration = math.random(4)
    self.movingTimer = 0
end

function FlyMovingState:update(dt)
    self.movingTimer = self.movingTimer + dt
    self.fly.currentAnimation:update(dt)

    -- reverse movement direction and timer if timer is above duration
    if self.movingTimer > self.movingDuration then
        self.movingDirection = self.fly.direction == 'left' and 'right' or 'left'
        self.fly.direction = self.movingDirection
        self.movingTimer = 0
    elseif self.fly.direction == 'left' then
        self.fly.x = self.fly.x - FLY_MOVE_SPEED * dt

        local tileLeft = self.tilemap:pointToTile(self.fly.x, self.fly.y)
        -- local tileBottomLeft = self.tilemap:pointToTile(self.fly.x, self.fly.y + self.fly.height)

        if (tileLeft) and (tileLeft:collidable()) then
            self.fly.x = self.fly.x + FLY_MOVE_SPEED * dt

            -- reset direction if we hit a wall
            self.movingDirection = 'right'
            self.fly.direction = self.movingDirection
            self.movingTimer = 0
        end

        -- local tileLeft = self.tilemap:pointToTile(self.fly.x, self.fly.y)
        -- local tileBottomLeft = self.tilemap:pointToTile(self.fly.x, self.fly.y + self.fly.height)
        --
        -- if (tileLeft and tileBottomLeft) and (tileLeft:collidable() or not tileBottomLeft:collidable()) then
        --     self.fly.x = self.fly.x + FLY_MOVE_SPEED * dt
        --
        --     -- reset direction if we hit a wall
        --     self.movingDirection = 'right'
        --     self.fly.direction = self.movingDirection
        --     self.movingDuration = math.random(5)
        --     self.movingTimer = 0
        -- end

    else
        self.fly.direction = 'right'
        self.fly.x = self.fly.x + FLY_MOVE_SPEED * dt

        local tileRight = self.tilemap:pointToTile(self.fly.x + self.fly.width, self.fly.y)
        -- local tileBottomRight = self.tilemap:pointToTile(self.fly.x + self.fly.width, self.fly.y + self.fly.height)

        if (tileRight) and (tileRight:collidable()) then
            self.fly.x = self.fly.x - FLY_MOVE_SPEED * dt

            -- reset direction if we hit a wall
            self.movingDirection = 'left'
            self.fly.direction = self.movingDirection
            self.movingTimer = 0
        end

        -- local tileRight = self.tilemap:pointToTile(self.fly.x + self.fly.width, self.fly.y)
        -- local tileBottomRight = self.tilemap:pointToTile(self.fly.x + self.fly.width, self.fly.y + self.fly.height)

        -- if (tileRight and tileBottomRight) and (tileRight:collidable() or not tileBottomRight:collidable()) then
        --     self.fly.x = self.fly.x - FLY_MOVE_SPEED * dt
        --
        --     -- reset direction if we hit a wall
        --     self.movingDirection = 'left'
        --     self.fly.direction = self.movingDirection
        --     self.movingDuration = math.random(5)
        --     self.movingTimer = 0
        -- end
    end


end
