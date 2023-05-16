Sprite = {}

Sprite.load = function()
  Sprite.texture = love.graphics.newImage('data/assets/tiles.png')
end

Sprite.newQuad = function(x, y, width, height)
  return love.graphics.newQuad(x * 16, y * 16, width or 16, height or 16, Sprite.texture)
end

