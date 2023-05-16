GameState = {}

local GAME_STATES = {
  TITLE = 1,
  GAME = 2,
}

local current_level = 1
local game_state = GAME_STATES.GAME

GameState.next_level = function()
  current_level = current_level + 1
end

GameState.get_level = function()
  return current_level
end

---

SimState = {}

local SIM_STATES = {
  RUNNING = 1,
  BUILD = 2,
}
local sim_state = SIM_STATES.BUILD

SimState.set_buildling = function()
  sim_state = SIM_STATES.BUILD
end

SimState.set_running = function()
  sim_state = SIM_STATES.RUNNING
end

SimState.is_build = function()
  return sim_state == SIM_STATES.BUILD
end

SimState.is_running = function()
  return sim_state == SIM_STATES.RUNNING
end
