local punchers = {}
local paused = true

Puncher = {}
Puncher.new = function(x, y, world)
  local ent = {
    x = x,
    y = y,
    sprite = Sprite.newQuad(4, 0),
    color = { 0, 0, 1 },
    width = 16,
    height = 16,
    visible = true,
    fired = false,
    countdown = 3,
  }
  ent.body = love.physics.newBody(world, x + 8, y + 8, 'kinematic') --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
  ent.body:setActive(false)
  ent.anchor = love.physics.newBody(world, x + 8, y + 8, 'static')
  ent.shape = love.physics.newRectangleShape(16, 16) --make a rectangle with a width of 650 and a height of 50
  ent.fixture = love.physics.newFixture(ent.body, ent.shape, 1) --attach shape to body
  table.insert(punchers, ent)
  return ent
end

Puncher.draw_all = function()
  love.graphics.setColor(1, 1, 1)
  for_each(punchers, function(puncher)
    if not puncher.visible then return end
    local x, y = puncher.body:getWorldPoints(puncher.shape:getPoints())
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(Sprite.texture, puncher.sprite, x, y)
    love.graphics.polygon("fill", puncher.body:getWorldPoints(puncher.shape:getPoints()))
    if not paused and not puncher.fired then
      love.graphics.print(tostring(math.ceil(puncher.countdown)), puncher.x, puncher.y - 20)
    end
  end)
end

Puncher.remove_all = function()
  for_each(punchers, function(puncher)
    puncher.body:destroy()
  end)
  punchers = {}
end

Puncher.pause = function()
  paused = true 
  for_each(punchers, function(puncher)
    puncher.body:setActive(false)
    puncher.fired = false
  end)
end

Puncher.resume = function()
  paused = false
  for_each(punchers, function(puncher)
    puncher.body:setActive(true)
  end)
end

Puncher.update = function(dt)
  if paused then return end
  for_each(punchers, function(puncher)
    puncher.countdown = puncher.countdown - dt
    if puncher.countdown <= 0 then
      puncher.fired = true
      puncher.body:applyForce(1000, 0)
    end
  end)
end