local ui_elements = {}
local play_pause_button

UI = {}


UI.load = function(onPause, onPlay)
  local texture = love.graphics.newImage('data/assets/tiles.png')
  play_pause_button = {
    paused = false,
    pausedSprite = love.graphics.newQuad(6 * 16, 0, 16, 16, texture),
    playSprite = love.graphics.newQuad(5 * 16, 0, 16, 16, texture),
    x = 224,
    y = 224,
    width = 16,
    height = 16,
  }
  play_pause_button.click = function(self)
    self.paused = not self.paused
    if (self.paused) then
      -- onPause()
    else
      -- onPlay()
    end
  end
  play_pause_button.draw = function(self)
    if (self.paused) then
      love.graphics.draw(texture, self.playSprite, self.x, self.y)
    else
      love.graphics.draw(texture, self.pausedSprite, self.x, self.y)
    end
    if (DEBUG) then
      love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    end
  end
  table.insert(ui_elements, play_pause_button)
end

UI.paused = function()
  return play_pause_button.paused
end

UI.update = function()
end

UI.handleClick = function(x, y, button, istouch, presses)
  local mx, my = x / SCALE, y / SCALE
  for _, element in pairs(ui_elements) do
    if (mx >= element.x and mx <= element.x + element.width and
        my >= element.y and my <= element.y + element.height ) then
      element:click()
    end
  end
end

UI.draw = function()
  for _, element in pairs(ui_elements) do
    element:draw()
  end
end