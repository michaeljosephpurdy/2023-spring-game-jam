json = require 'plugins/json'
ldtk = require 'plugins/ldtk'

SCALE = 2
DEBUG = false

require 'utils'
require 'sprite'
require 'boundary'
require 'ui'
require 'physics'
require 'domino'
require 'state'
require 'end-button'
require 'puncher'

function tprint(tbl, id)
  print(id)
  for k,v in pairs(tbl) do
    print(k .. ': ' .. tostring(v))
  end
end

objects = {}
bodies = {}
placeables = {}

ENT_DATA = {
  End = {
    color = { 0, 1, 0 },
    width = 16,
    height = 16,
  },
  RightFacingPuncher = {
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

  Sprite.load()
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
    local world = Physics.get_world()
    if (entity.id == 'End') then
      EndButton.new(entity.x, entity.y, world)
    elseif (entity.id == 'RightFacingPuncher') then
      Puncher.new(entity.x, entity.y, world)
    elseif (entity.id == 'Boundary') then
      Boundary.new(entity.x, entity.y, world)
    elseif (entity.id == 'SpawnPoint') then
      Domino.set_spawn_point(entity.x, entity.y)
    end
  end

  function ldtk.onLayer(layer)
    tprint(layer, 'layer')
    if layer.id == 'Collisions' then
      --love.physics.newBody(physics_world, layer.x, layer.y, 'static')
    end
    if layer.id == 'Boundaries' then
      --love.physics.newBody(physics_world, layer.x, layer.y, 'static')
    end
    table.insert(objects, layer)
  end

  function ldtk.onLevelLoaded(level)
    world = Physics.get_world()
    love.graphics.setBackgroundColor(level.backgroundColor)
    tprint(level, '\n\nlevelLoaded')
    SimState.set_buildling()
    -- Current level is about to be changed.
  end

  function ldtk.onLevelCreated(level)
    tprint(level, '\n\nlevelCreated')
    Domino.set_count(level.props.domino_count)
    --Here we use a string defined in LDtk as a function
    if level.props.createFunction then
      load(level.props.createFunction)()
    end
    SimState.set_buildling()
  end

  ldtk:goTo(GameState.get_level())

  UI.load()
end

function love.mousepressed( x, y, button, istouch, presses )
  UI.handleClick(x, y, button, istouch, presses)
  if SimState.is_build() then
    Domino.handlePress(x, y, button, istouch, presses)
  end
end

function love.mousereleased( x, y, button, istouch, presses )
  if SimState.is_build() then
    Domino.handleRelease(x, y, button, istouch, presses)
  end
end

function love.mousemoved( x, y, dx, dy, istouch )
  if SimState.is_build() then
    Domino.handleMove(x, y, dx, dy, istouch)
  end
end

function love.update(dt)
  UI.update()
  Puncher.update_all(dt) -- puncher needs dt for countdown
  EndButton.update_all()
  --if SimState.is_build() then
    --dt = 0
  --end
  Physics.get_world():update(dt)
  for _, obj in pairs(objects) do
    if obj.update then
      obj:update()
    end
  end
end

function love.draw()
    love.graphics.scale(SCALE)
    love.graphics.setColor(1, 0, 0)
    Domino.draw_all()
    Boundary.draw_all()
    EndButton.draw_all()
    Puncher.draw_all()
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
