local dominos = {}
local built_dominos_locations = {}
local domino_count = 0
local spawn_point
local DENSITY = 5
local for_each_domino = function(fn)
  for _, domino in pairs(dominos) do
    fn(domino)
  end
end

Domino = {}

Domino.draw = function(self)
  local x, y, width, height = self.body:getWorldPoints(self.shape:getPoints())
  love.graphics.setColor(PicoColors.LIGHT_BLUE)
  if self.picked_up then
    love.graphics.setColor(PicoColors.PINK)
  end
  love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

Domino.new = function(x, y)
  if not Domino.can_spawn() then
    print('tried spawning more dominos than allowed')
    return
  end
  local world = Physics.get_world()
  local domino = {
    width = 10,
    height = 50,
  }
  domino.body = love.physics.newBody(world, x or spawn_point.x, y or spawn_point.y, 'dynamic')
  domino.body:setActive(false)
  domino.shape = love.physics.newRectangleShape(0, 0, domino.width, domino.height)
  domino.fixture = love.physics.newFixture(domino.body, domino.shape, DENSITY) -- A higher density gives it more mass.
  table.insert(dominos, domino)
  domino.draw = Domino.draw
  return domino
end

Domino.handleRelease = function(_x, _y, button, istouch, presses)
  for_each_domino(function(domino) domino.picked_up = false end)
end

Domino.handlePress = function(_x, _y, button, istouch, presses)
  local mx, my = _x / SCALE, _y / SCALE
  for _, domino in pairs(dominos) do
    local x, y = domino.body:getWorldPoints(domino.shape:getPoints())
    local width, height = domino.width, domino.height
    if (mx >= x and mx <= x + width and
        my >= y and my <= y + height ) then
      domino.picked_up = true
      return
    end
  end
end

Domino.handleMove = function(x, y, dx, dy, istouch)
  for_each_domino(function(domino)
    if domino.picked_up then
      domino.body:setPosition(x / SCALE, y / SCALE)
    end
  end)
end

Domino.pause = function()
  for_each_domino(function(domino)
    domino.body:setActive(false)
  end)
end

Domino.resume = function()
  for_each_domino(function(domino)
    table.insert(built_dominos_locations, { domino.body:getX(), domino.body:getY() })
    domino.body:setActive(true)
  end)
end

Domino.draw_all = function()
  for_each_domino(function(domino)
    domino:draw()
  end)
end

Domino.reset_all = function()
  old_count = domino_count
  Domino:remove_all()
  domino_count = old_count
  for _, position in pairs(built_dominos_locations) do
    Domino.new(position[1], position[2])
  end
  built_dominos_locations = {}
end

Domino.remove_all = function()
  for_each_domino(function(domino)
    domino.body:destroy()
  end)
  dominos = {}
  domino_count = 0
end

Domino.set_count = function(_domino_count)
  domino_count = _domino_count
end

Domino.get_count = function()
  return domino_count
end

Domino.can_spawn = function()
  local current_count = Domino.get_count() - Domino.get_unspawned_count()
  local max_count = Domino.get_count()
  return current_count - max_count < 0
end

Domino.get_unspawned_count = function()
  return domino_count - #dominos
end

Domino.set_spawn_point = function(x, y)
  spawn_point = { x = x, y = y }
end
