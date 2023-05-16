local buttons = {}
local THRESHOLD = 15
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
  button.untouched_button = love.physics.newBody(world, x + 8, y + 8, 'dynamic') --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
  button.untouched_shape = love.physics.newRectangleShape(4, 4)
  button.untouched_fixture = love.physics.newFixture(button.untouched_button, button.untouched_shape, 0.5) --attach shape to body
  button.touched_button = love.physics.newBody(world, x + 8, y + 10, 'static') --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
  button.touched_shape = love.physics.newRectangleShape(4, 2)
  button.touched_fixture = love.physics.newFixture(button.touched_button, button.touched_shape, 10) --attach shape to body
  button.untouched_button:setActive(true)
  button.touched_button:setActive(false)
  button.update = function(self)
    if self.activated then return end
    local vx, vy = self.untouched_button:getLinearVelocity()
    if math.abs(vx) > THRESHOLD or math.abs(vy) > THRESHOLD then
      self.activated = true
      SimState.set_successful()
    end
  end
  button.draw = function (self)
    love.graphics.setColor(1,1,1)
    if (self.activated) then
      love.graphics.draw(Sprite.texture, self.activated_sprite, self.x, self.y)
    else
      love.graphics.draw(Sprite.texture, self.sprite, self.x, self.y)
    end
    if (DEBUG) then
      love.graphics.setColor(0, 0, 1, .5)
      love.graphics.polygon("fill", self.untouched_button:getWorldPoints(self.untouched_shape:getPoints()))
    end
  end
  table.insert(buttons, button)
  return button
end

EndButton.remove_all = function()
  buttons = {}
end

EndButton.update_all = function()
  for_each(buttons, function(button) button:update() end)
end