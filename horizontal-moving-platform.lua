local platforms = {}

HorizontalMovingPlatform = {}

HorizontalMovingPlatform.new = function(x, y, path_width, world)
  local platform = {
    width = 32,
    height = 16,
    density = 1000,
    speed = 4,
    spawn_location = { x + 8, y + 8 },
  }
  platform.body = love.physics.newBody(world or Physics.get_world(), x + path_width / 2, y + 8, 'dynamic')
  platform.body:setGravityScale(0)
  platform.shape = love.physics.newRectangleShape(platform.width, platform.height)
  platform.fixture = love.physics.newFixture(platform.body, platform.shape, platform.density)
  --platform.left_anchor = love.physics.newBody(world or Physics.get_world(), x + (platform.width / 2), y + 8, 'static')
  platform.left_anchor = love.physics.newBody(world or Physics.get_world(), 10, y + 8, 'static')
  --platform.right_anchor = love.physics.newBody(world or Physics.get_world(), x + path_width - (platform.width / 2), y + 8, 'static')
  platform.right_anchor = love.physics.newBody(world or Physics.get_world(), 1000, y + 8, 'static')
  platform.left_joint = love.physics.newDistanceJoint(platform.body, platform.left_anchor,
    platform.body:getX(), platform.body:getY(), platform.left_anchor:getX(), platform.left_anchor:getY())
  platform.right_joint = love.physics.newDistanceJoint(platform.body, platform.right_anchor,
    platform.body:getX(), platform.body:getY(), platform.right_anchor:getX(), platform.right_anchor:getY())
  platform.direction = 'left'
  table.insert(platforms, platform)
  return platform
end

local function move_left(p, amt)
  p.left_joint:setLength(p.left_joint:getLength() - amt)
  p.right_joint:setLength(p.right_joint:getLength() + amt)
end
local function move_right(p, amt)
  p.left_joint:setLength(p.left_joint:getLength() + amt)
  p.right_joint:setLength(p.right_joint:getLength() - amt)
end

HorizontalMovingPlatform.update_all = function()
  for_each(platforms, function(platform)
    print('direction: ' .. platform.direction .. ' left: ' .. platform.left_joint:getLength() .. ' right: ' .. platform.right_joint:getLength())
    if platform.direction == 'left' then
      move_left(platform, .5)
      if platform.left_joint:getLength() <= 0 then
        move_right(platform, .5)
        platform.direction = 'right'
      end
    else
      move_right(platform, .5)
      if platform.right_joint:getLength() <= 0 then
        move_left(platform, .5)
        platform.direction = 'left'
      end
    end
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
