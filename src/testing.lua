-- argv conditions to allow for testing various things
if #arg > 1 then
  for i=1, #arg do

    if arg[i] == 'nosound' then
      love.audio.setVolume(0.0)
    end

    if arg[i] == 'run' then
        PLAYER_RUN_SPEED = 90
    end

    if arg[i] == 'extraLives' then
        PLAYER_LIVES = 10
    end

  end
end
