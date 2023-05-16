json = require 'plugins/json'

SCALE = 2
DEBUG = true
require 'ui'
require 'physics'
require 'domino'

function tprint(tbl, id)
  print(id)
  for k,v in pairs(tbl) do
    print(k .. ': ' .. tostring(v))
  end
end

local ldtk = require 'plugins/ldtk'


objects = {}
bodies = {}
placeables = {}

ENT_DATA = {
  End = {
    color = { 0, 1, 0 },
    width = 16,
    height = 16,
  },
  Start = {
    color = { 0, 0, 1 },
    width = 16,
    height = 16,
  },
}

Entity = {}
Entity.draw = function(self)
    if not self.visible then return end
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
Entity.new = function(x, y, type)
    local ent = {
        x = x,
        y = y,
        visible = true,
        type = type,
    }
    ent.draw = Entity.draw
    setmetatable(ent, Entity)
    ent.__index = Entity.__index
    for k, v in pairs(ENT_DATA[type]) do
        ent[k] = v
    end
    return ent
end

Collider = {}
Collider.draw = function(self)
  love.graphics.setColor(1, 0, 0)
  love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates
end
Collider.new = function(x, y, world)
  local collider = {}
  collider.draw = Collider.draw
  collider.body = love.physics.newBody(world, x, y) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
  collider.shape = love.physics.newRectangleShape(256, 16) --make a rectangle with a width of 650 and a height of 50
  collider.fixture = love.physics.newFixture(collider.body, collider.shape) --attach shape to body
  table.insert(objects, collider)
  return collider
end

Body = {}
Body.new = function()
  return {
    pause = function(self)
      self.body:setActive(false)
    end,
    resume = function(self)
      self.body:setActive(true)
    end,
  }
end


Knocker = {
}
Knocker.draw = function(self)
  love.graphics.setColor(0.80, 0, 0)
  love.graphics.polygon("fill", self.body:getWorldPoints(
                           self.shape:getPoints()))
end
Knocker.new = function(x, y)
  local knocker = Body.new()
  knocker.body = love.physics.newBody(physics_world, x, y, 'dynamic')
  knocker.shape = love.physics.newRectangleShape(0, 0, 10, 50)
  knocker.fixture = love.physics.newFixture(knocker.body, knocker.shape, 5) -- A higher density gives it more mass.
  knocker.draw = Knocker.draw
  table.insert(objects, knocker)
  table.insert(bodies, knocker.body)
end


-- Flip the loading order if needed.
-- ldtk:setFlipped(true) --false by default

-- Load a level
-- ldtk:goTo(2)        --loads the second level
-- ldtk:level('cat')   --loads the level named cat
-- ldtk:next()         --loads the next level (or the first if we are in the last)
-- ldtk:previous()     --loads the previous level (or the last if we are in the first)
-- ldtk:reload()       --reloads the current level

function love.load()
  -- setup screen
  love.window.setMode(512, 512)
  love.window.setFullscreen(false)
  love.graphics.setBackgroundColor(0, 0, 0)
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.setLineStyle('rough')

  -- setup physics world
  love.physics.setMeter(40) -- meter is 40 px/units

  -- Load the .ldtk file
  ldtk:load('data/world.ldtk')
  ldtk:setFlipped(true)

    -- Override the callbacks with your game logic.
    -- function ldtk.onEntity(entity)
        -- A new entity is created.
    -- end
  function ldtk.onEntity(entity)
    table.insert(objects, Entity.new(entity.x, entity.y, entity.id))
    tprint(entity, 'entity')
  end

  function ldtk.onLayer(layer)
    tprint(layer, 'layer')
    if layer.id == 'Collisions' then
      --love.physics.newBody(physics_world, layer.x, layer.y, 'static')
    end
    table.insert(objects, layer)
  end

  function ldtk.onLevelLoaded(level)
    world = Physics.get_world()
    love.graphics.setBackgroundColor(level.backgroundColor)
    -- Current level is about to be changed.
  end

  function ldtk.onLevelCreated(level)
    for i = 0, level.props.dominoCount do
      Domino.new(i * 10, 10, Physics.get_world())
    end
    --Here we use a string defined in LDtk as a function
    if level.props.createFunction then
        load(level.props.createFunction)()
    end
    tprint(level.props, 'props')
  end

  ldtk:goTo(1)

  Collider.new(128, 180, Physics.get_world())

  UI.load(function() -- onPause
    for _, obj in pairs(bodies) do
      obj:putToSleep()
    end
  end, function() -- onPlay
    for _, obj in pairs(bodies) do
      obj:wakeUp()
    end
  end)
end

function love.mousepressed( x, y, button, istouch, presses )
  UI.handleClick(x, y, button, istouch, presses)
  Domino.handlePress(x, y, button, istouch, presses)
end

function love.mousereleased( x, y, button, istouch, presses )
  Domino.handleRelease(x, y, button, istouch, presses)
end

function love.mousemoved( x, y, dx, dy, istouch )
  Domino.handleMove(x, y, dx, dy, istouch)
end

function love.update(dt)
  if UI.paused() then
    dt = 0
  end
  Physics.get_world():update(dt)
  for _, obj in pairs(objects) do
    if obj.update then
      obj:update()
    end
  end
  UI:update()
end

function love.draw()
    love.graphics.scale(SCALE)
    love.graphics.setColor(1, 0, 0)
    for _, obj in pairs(objects) do
      if obj.draw then
        obj:draw()
      end
      if obj.getBodyType then
        obj:getBodyType()
        love.graphics.rectangle('fill', obj:getX(), obj:getY(), 4, 4)
      end
    end
    UI:draw()

    for i, msg in ipairs({
      love.timer.getFPS(),
      'x: ' .. tostring(love.mouse.getX() / SCALE) .. 'y: ' .. tostring(love.mouse.getY() / SCALE),
    }) do
      love.graphics.print(msg, 0, (i - 1)* 16)
    end
end
