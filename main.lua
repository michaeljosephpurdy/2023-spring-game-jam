json = require 'plugins/json'
ldtk = require 'plugins/ldtk'

SCALE = 2
DEBUG = false

require 'utils'
require 'sprite'
require 'timed-function'
require 'pico-colors'
---
require 'state'
require 'boundary'
require 'ui'
require 'physics'
require 'horizontal-moving-platform'
require 'domino'
require 'end-button'
require 'puncher'
require 'intro'

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
    elseif (entity.id == 'MovingPlatform_Horizontal') then
      HorizontalMovingPlatform.new(entity.x, entity.y, world)
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
    Domino.remove_all()
    EndButton.remove_all()
    Puncher.remove_all()
    Boundary.remove_all()
    objects = {}
    world = Physics.get_world()
    love.graphics.setBackgroundColor(level.backgroundColor)
    tprint(level, '\n\nlevelLoaded')
    -- Current level is about to be changed.
  end

  function ldtk.onTileCreated(identifier, tile)
    if identifier == 'Collisions' then
      Boundary.new(tile.px[1], tile.px[2], Physics.get_world())
    end
  end

  function ldtk.onLevelCreated(level)
    Domino.set_count(level.props.domino_count)
    --Here we use a string defined in LDtk as a function
    --if level.props.createFunction then
      --load(level.props.createFunction)()
    --end
    SimState.set_buildling()
  end


  Intro.load()
  UI.load()
  ldtk:goTo(GameState.get_level())
end

function love.keyreleased(key, scancode)
  if key == 'n' then
    GameState.next_level()
  end
end

function love.mousepressed( x, y, button, istouch, presses )
  if GameState.is_title() then
    Intro.handlePress(x, y, button, istouch, presses)
    return
  end
  UI.handleClick(x, y, button, istouch, presses)
  if SimState.is_build() then
    Domino.handlePress(x, y, button, istouch, presses)
  end
end

function love.mousereleased( x, y, button, istouch, presses )
  if GameState.is_title() then return end
  if SimState.is_build() then
    Domino.handleRelease(x, y, button, istouch, presses)
  end
end

function love.mousemoved( x, y, dx, dy, istouch )
  if GameState.is_title() then return end
  if SimState.is_build() then
    Domino.handleMove(x, y, dx, dy, istouch)
  end
end

function love.update(dt)
  if GameState.is_title() then
    Intro.update(dt)
  end
  if GameState.is_simulation() then
    TimedFunction.update_all(dt)
    UI.update()
    Puncher.update_all(dt) -- puncher needs dt for countdown
    EndButton.enable(Puncher.is_fired())
    EndButton.update_all()
    HorizontalMovingPlatform.update_all()
    Physics.get_world():update(dt)
    for _, obj in pairs(objects) do
      if obj.update then
        obj:update()
      end
    end
  end
end

function love.draw()
  love.graphics.scale(SCALE)
  if GameState.is_title() then
    Intro.draw()
  end
  if GameState.is_simulation() then
    Domino.draw_all()
    Boundary.draw_all()
    EndButton.draw_all()
    Puncher.draw_all()
    HorizontalMovingPlatform.draw_all()
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
  end

  if DEBUG then
    love.graphics.setColor(0.5, 0.7, 0.2)
    for i, msg in ipairs({
      love.timer.getFPS(),
      'x: ' .. tostring(love.mouse.getX() / SCALE) .. 'y: ' .. tostring(love.mouse.getY() / SCALE),
    }) do
      love.graphics.print(msg, 0, (i - 1)* 16)
    end
  end
end
