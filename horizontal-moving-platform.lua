local platforms = {}

HorizontalMovingPlatform = {}

HorizontalMovingPlatform.new = function(x, y, world)
  local platform = {
    width = 32,
    height = 16,
    density = 1,
    speed = 4,
    spawn_location = { x + 8, y + 8 },
  }
  platform.body = love.physics.newBody(world or Physics.get_world(), x + 8, y + 8, 'kinematic')
  platform.body:setGravityScale(0)
  platform.shape = love.physics.newRectangleShape(platform.width, platform.height)
  platform.fixture = love.physics.newFixture(platform.body, platform.shape, platform.density)
  table.insert(platforms, platform)
  return platform
end

HorizontalMovingPlatform.update_all = function()
  for_each(platforms, function(platform)
    if not platform.body:isActive() then return end
    local dx = platform.body:getLinearVelocity()
    if (dx <= 0) then
      platform.speed = -platform.speed
    end
    platform.body:applyLinearImpulse(platform.speed, 0)
    love.graphics.setColor(PicoColors.DARK_PURPLE)
    love.graphics.polygon("fill", platform.body:getWorldPoints(platform.shape:getPoints()))
  end)
end

HorizontalMovingPlatform.pause = function()
  for_each(platforms, function(platform)
    platform.body:setActive(false)
  end)
end

HorizontalMovingPlatform.resume = function()
  for_each(platforms, function(platform)
    platform.body:setActive(true)
  end)
end

HorizontalMovingPlatform.draw_all = function()
  for_each(platforms, function(platform)
    love.graphics.setColor(PicoColors.DARK_PURPLE)
    love.graphics.polygon("fill", platform.body:getWorldPoints(platform.shape:getPoints()))
  end)
end

HorizontalMovingPlatform.remove_all = function()
  for_each(platforms, function(platform)
    platform.body:destroy()
  end)
  platforms = {}
end
