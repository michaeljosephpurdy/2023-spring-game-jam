local ui_elements = {}

UI = {}

UI.load = function()
  local texture = Sprite.texture
  local draw = function(self)
    love.graphics.setColor(1, 1, 1)
    if self.disabled then
      love.graphics.draw(texture, self.disabled_sprite, self.x, self.y)
    else
      love.graphics.draw(texture, self.sprite, self.x, self.y)
    end
  end
  local play_button = {
    sprite = Sprite.newQuad(5, 0),
    disabled_sprite = Sprite.newQuad(8, 0),
    click = function(self)
      if self.disabled then return end
      print('ui - play clicked')
      SimState.set_running()
      Domino.resume()
      Puncher.resume()
    end,
    update = function(self)
      self.disabled = not SimState.is_build()
    end,
    draw = draw,
    pos = 0,
  }
  local stop_button = {
    sprite = Sprite.newQuad(6, 0),
    disabled_sprite = Sprite.newQuad(9, 0),
    click = function(self)
      if self.disabled then return end
      print('ui - stop clicked')
      SimState.set_buildling()
      Domino.reset_all()
      Domino.pause()
      Puncher.pause()
    end,
    update = function(self)
      self.disabled = not SimState.is_running()
    end,
    draw = draw,
    pos = 1,
  }
  local restart_button = {
    sprite = Sprite.newQuad(7, 0),
    disabled_sprite = Sprite.newQuad(10, 0),
    click = function(self)
      if self.disabled then return end
      print('ui - restart clicked')
      SimState.set_buildling()
      Domino.remove_all()
      Puncher.remove_all()
      EndButton.remove_all()
      ldtk:goTo(GameState.get_level())
    end,
    update = function(self)
      self.disabled = not SimState.is_build()
    end,
    draw = draw,
    pos = 2,
  }
  local next_button = {
    sprite = Sprite.newQuad(8, 1),
    disabled_sprite = Sprite.newQuad(9, 1),
    click = function(self)
      if self.disabled then return end
      GameState.next_level()
      print('load next level')
    end,
    update = function(self)
      self.disabled = not SimState.is_successful()
    end,
    draw = draw,
    pos = 3,
  }
  table.insert(ui_elements, play_button)
  table.insert(ui_elements, stop_button)
  table.insert(ui_elements, restart_button)
  table.insert(ui_elements, next_button)

  local x, y, spacing = 164, 8, 24
  for _, button in pairs(ui_elements) do
    button.x = x + (button.pos * spacing)
    button.y = y
    button.width, button.height = 16, 16
  end

  local new_domino_button = {
    add_sprite = Sprite.newQuad(5, 1),
    disabled_add_sprite = Sprite.newQuad(7, 1),
    x = 40,
    y = 40,
    width = 16,
    height = 16,
    click = function(self)
      if self.disabled then return end
      Domino.new()
    end,
    update = function(self)
      self.disabled = not Domino.can_spawn()
    end,
    draw = function(self)
      love.graphics.setColor(1, 1, 1)
      local current_count = tostring(Domino.get_count() - Domino.get_unspawned_count())
      local max_count = tostring(Domino.get_count())
      local label = string.format('domino (%s/%s)', current_count, max_count)
      love.graphics.print(label, self.x + 20, self.y)
      if self.disabled then
        love.graphics.draw(Sprite.texture, self.disabled_add_sprite, self.x, self.y)
      else
        love.graphics.draw(Sprite.texture, self.add_sprite, self.x, self.y)
      end
    end,
  }
  table.insert(ui_elements, new_domino_button)
end

UI.update = function()
  for_each(ui_elements, function(btn)
    btn:update()
  end)
end

UI.draw = function()
  for_each(ui_elements, function(btn)
    btn:draw()
  end)
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