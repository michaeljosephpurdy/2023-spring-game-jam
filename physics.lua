Physics = {}

local Y_GRAV = 80
local current_world

Physics.get_world = function()
  if current_world == nil then
    current_world = Physics.new_world()
  end
  return current_world
end

Physics.new_world = function()
  return love.physics.newWorld(0, Y_GRAV, true)
end