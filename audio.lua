Audio = {}
Audio.load = function()
  Audio.bg = love.audio.newSource('data/assets/springgamejam.ogg', 'stream')
end

Audio.update = function()
  if not Audio.bg:isPlaying() then
    love.audio.play(Audio.bg)
  end
end

Audio.stop = function()
  if Audio.bg:isPlaying() then
    Audio.bg.stop()
  end
end
