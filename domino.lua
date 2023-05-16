local dominos = {}

Domino = {}

Domino.draw = function(self)
  local x, y, width, height = self.body:getWorldPoints(self.shape:getPoints())
  love.graphics.setColor(0.20, 0.20, 0.20)
  love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
  if self.picked_up then
    love.graphics.print('picked up', x, y)
  end
end

Domino.new = function(x, y, world)
  local domino = {
    width = 10,
    height = 50,
  }
  domino.body = love.physics.newBody(world, x, y, 'dynamic')
  domino.shape = love.physics.newRectangleShape(0, 0, domino.width, domino.height)
  domino.fixture = love.physics.newFixture(domino.body, domino.shape, 5) -- A higher density gives it more mass.
  table.insert(dominos, domino)
  table.insert(objects, domino)
  table.insert(bodies, domino.body)
  table.insert(placeables, domino)
  domino.draw = Domino.draw
  return domino
end

Domino.handleRelease = function(_x, _y, button, istouch, presses)
  for _, domino in pairs(dominos) do
    domino.picked_up = false
  end
end

Domino.handlePress = function(_x, _y, button, istouch, presses)
  local mx, my = _x / SCALE, _y / SCALE
  for _, domino in pairs(dominos) do
    local x, y = domino.body:getWorldPoints(domino.shape:getPoints())
    local width, height = domino.width, domino.height
    if (mx >= x and mx <= x + width and
        my >= y and my <= y + height ) then
      domino.picked_up = true
    end
  end
end

Domino.handleMove = function(x, y, dx, dy, istouch)
  for _, domino in pairs(dominos) do
    if domino.picked_up then
      domino.body:setPosition(x / SCALE, y / SCALE)
    end
  end
end