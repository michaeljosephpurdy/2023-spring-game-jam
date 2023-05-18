Sprite = {}

Sprite.load = function()
  Sprite.texture = love.graphics.newImage('data/assets/tiles.png')
end

Sprite.newQuad = function(x, y, width, height)
  local w = width or 16
  local h = height or 16
  return love.graphics.newQuad(x * 16, y * 16, w, h, Sprite.texture)
end

