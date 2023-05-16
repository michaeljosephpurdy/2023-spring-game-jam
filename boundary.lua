local boundaries = {}
Boundary = {}

Boundary.draw = function(self)
  if not DEBUG then return end
  love.graphics.setColor(1, 0, 0)
  love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates
end

Boundary.new = function(x, y, world)
  local collider = {}
  collider.draw = Boundary.draw
  collider.body = love.physics.newBody(world, x + 8, y + 8) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
  collider.shape = love.physics.newRectangleShape(16, 16) --make a rectangle with a width of 650 and a height of 50
  collider.fixture = love.physics.newFixture(collider.body, collider.shape) --attach shape to body
  table.insert(boundaries, collider)
  return collider
end

Boundary.draw_all = function()
  for_each(boundaries, function(boundary)
    boundary:draw()
  end)
end

Boundary.remove_all = function()
  for_each(boundaries, function(boundary)
    boundary.body:destroy()
  end)
  boundaries = {}
end