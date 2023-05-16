Sprite = {}

Sprite.load = function()
  Sprite.texture = love.graphics.newImage('data/assets/tiles.png')
end

Sprite.newQuad = function(x, y)
  return love.graphics.newQuad(x * 16, y * 16, 16, 16, Sprite.texture)
end

