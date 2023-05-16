local punchers = {}
local paused = true
local COUNTDOWN = 3

Puncher = {}
Puncher.new = function(x, y, world)
  local ent = {
    x = x,
    y = y,
    spawn_location = { x, y },
    sprite = Sprite.newQuad(4, 0),
    color = { 0, 0, 1 },
    width = 16,
    height = 16,
    visible = true,
    fired = false,
    countdown = COUNTDOWN,
  }
  ent.body = love.physics.newBody(world, x + 8, y + 8, 'dynamic') --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
  ent.anchor = love.physics.newBody(world, x, y + 8, 'static')
  ent.shape = love.physics.newCircleShape(6)
  ent.fixture = love.physics.newFixture(ent.body, ent.shape, 1) --attach shape to body
  ent.anchor_fixture = love.physics.newFixture(ent.anchor, ent.shape, 1)
  ent.body:setActive(false)
  table.insert(punchers, ent)
  return ent
end

Puncher.draw_all = function()
  love.graphics.setColor(1, 1, 1)
  for_each(punchers, function(puncher)
    if not puncher.visible then return end
    local x, y = puncher.body:getX(), puncher.body:getY()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(Sprite.texture, puncher.sprite, x - 8, y - 8)
    if DEBUG then
      love.graphics.circle("fill", x, y, puncher.shape:getRadius())
    end
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
    puncher.countdown = COUNTDOWN
    puncher.body:setX(puncher.spawn_location[1])
    puncher.body:setY(puncher.spawn_location[2])
  end)
end

Puncher.resume = function()
  paused = false
  for_each(punchers, function(puncher)
  end)
end

Puncher.update = function(dt)
  if paused then return end
  for_each(punchers, function(puncher)
    puncher.countdown = puncher.countdown - dt
    if puncher.countdown <= 0 and not puncher.fired then
      puncher.body:setActive(true)
      puncher.fired = true
      local x, y = puncher.body:getX() - 4, puncher.body:getY()
      puncher.body:applyLinearImpulse(50, 0, x, y)
    end
  end)
end