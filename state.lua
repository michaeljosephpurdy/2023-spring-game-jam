GameState = {}

local GAME_STATES = {
  TITLE = 1,
  GAME = 2,
  FINISHED = 3,
}

local current_level = 1
local game_state = GAME_STATES.TITLE

GameState.next_level = function()
  if ldtk:hasNext() then
    current_level = current_level + 1
    ldtk:goTo(current_level)
  else
    current_level = 1
    game_state = GAME_STATES.FINISHED
  end
end

GameState.get_level = function()
  return current_level
end

GameState.set_simulation = function()
  game_state = GAME_STATES.GAME
end

GameState.is_title = function()
  return game_state == GAME_STATES.TITLE
end

GameState.is_simulation = function()
  return game_state == GAME_STATES.GAME
end

GameState.is_finished = function()
  return game_state == GAME_STATES.FINISHED
end

---

SimState = {}

local SIM_STATES = {
  RUNNING = 1,
  BUILD = 2,
  SUCCESSFUL = 3,
}
local sim_state = SIM_STATES.BUILD

SimState.set_buildling = function()
  sim_state = SIM_STATES.BUILD
  print('sim_state: build')
end

SimState.set_running = function()
  sim_state = SIM_STATES.RUNNING
  print('sim_state: running')
end

SimState.set_successful = function()
  sim_state = SIM_STATES.SUCCESSFUL
  print('sim_state: successful')
end

SimState.is_build = function()
  return sim_state == SIM_STATES.BUILD
end

SimState.is_running = function()
  return sim_state == SIM_STATES.RUNNING
end

SimState.is_successful = function()
  return sim_state == SIM_STATES.SUCCESSFUL
end
