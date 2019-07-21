-- argv conditions to allow for testing various things
if #arg > 1 then
  for i=1, #arg do

    if arg[i] == 'nosound' then
      love.audio.setVolume(0.0)
    end

    if arg[i] == 'cheats' then
      gCheats = true
    end

  end
end
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end
