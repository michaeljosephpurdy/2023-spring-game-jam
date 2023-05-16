local buttons = {} 

EndButton = {}

EndButton.draw_all = function()
  for_each(buttons, function(btn)
    btn:draw()
  end)
end

EndButton.new = function(x, y, world)
  local button = {
    x = x,
    y = y,
    sprite = Sprite.newQuad(11, 0),
    activated_sprite = Sprite.newQuad(12, 0),
    width = 16,
    height = 16,
    visible = true,
    activated = false,
    type = type,
  }
  button.draw = function (self)
    love.graphics.setColor(1,1,1)
    if (self.activated) then
      love.graphics.draw(Sprite.texture, self.activated_sprite, self.x, self.y)
    else
      love.graphics.draw(Sprite.texture, self.sprite, self.x, self.y)
    end
  end
  table.insert(buttons, button)
  return button
end

EndButton.remove_all = function()
  buttons = {}
end