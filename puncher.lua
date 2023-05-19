local punchers = {}
local paused = true
local COUNTDOWN = 3
local DENSITY = 2
local PUNCH_FORCE = 100
local MAX_DISTANCE = 30

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
    countdown = COUNTDOWN,
  }
  -- create the ball
  ent.body = love.physics.newBody(world, x + 8, y + 8, 'dynamic')
  ent.shape = love.physics.newCircleShape(8)
  ent.fixture = love.physics.newFixture(ent.body, ent.shape, DENSITY)

  -- create the anchor
  ent.anchor = love.physics.newBody(world, x, y + 8, 'static')

  -- link the two together
  local chain = love.physics.newRopeJoint(ent.body, ent.anchor,
      ent.body:getX(), ent.body:getY(),
      ent.anchor:getX(), ent.anchor:getY(),
      MAX_DISTANCE, false);

  ent.spawn_location = { ent.body:getX(), ent.body:getY() }
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
      love.graphics.print(tostring(math.ceil(puncher.countdown)), puncher.x + 4, puncher.y + 3)
    end
  end)
end

Puncher.remove_all = function()
  for_each(punchers, function(puncher)
    puncher.body:destroy()
  end)
  punchers = {}
  paused = true
end

Puncher.pause = function()
  paused = true
  for_each(punchers, function(puncher)
    puncher.body:setActive(false)
    puncher.fired = false
    puncher.countdown = COUNTDOWN
    puncher.body:setPosition(puncher.spawn_location[1], puncher.spawn_location[2])
  end)
end

Puncher.resume = function()
  paused = false
  for_each(punchers, function(puncher)
  end)
end

Puncher.update_all = function(dt)
  if paused then return end
  for_each(punchers, function(puncher)
    puncher.countdown = puncher.countdown - dt
    if puncher.countdown <= 0 and not puncher.fired then
      puncher.body:setActive(true)
      puncher.fired = true
      local x, y = puncher.body:getX() - 4, puncher.body:getY()
      puncher.body:applyLinearImpulse(PUNCH_FORCE, 0, x, y)
    end
  end)
end

Puncher.is_fired = function()
  for_each(punchers, function(puncher)
    if puncher.fired then
      return true
    end
  end)
  return false
end
