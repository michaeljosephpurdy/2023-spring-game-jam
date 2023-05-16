Level = {}

Level.load = function()
end

Level.draw = function(self)
end

Level.reload = function(self)
  ldtk:goTo(GameState.get_level())
end