require("config")
require("constants")
require("challenges")
require('graphics')


game = {
  state = 'loaded',
  total_count = MAX_SLOTS,
  wins_count = nil,
  loss_count = nil,
  active_count = nil,
  visible_count = nil,
  score = 0,
  time = 0
}

game_interfaces = {
  terminal = nil,
  screen = nil
}

on_click = action_map({
  'loaded' = game_start ,
  'finished' = game_start
})

on_input = action_map({
  'active' = match_answers ,
  'loaded' = on_text_match('start', game_start),
  'finished' = on_text_match('start', game_start)
})


on_draw = action_map({
  'loaded' = draw_splash_welcome,
  'acive'  = game_draw,
  'finished' = draw_splash_results
})

on_tick = action_map({
  'active' = game_update
})

function game_event_handler(map)
  return function(...)
    map[game.state](...)
  end
end

function game_state_init()
 
end

function game_init()

  game_state_init()

  local input_handler = game_event_handler(on_input)
  local terminal = terminal_init(input_handler) 
  game_interfaces.terminal = terminal
  local state_updater = game_event_handler(on_update)
  local game_updater = function(...)
    state_updater(...)
    terminal.read()
  end

  love.update = game_updater
  love.draw = game_event_handler(on_draw)
  compy.singleclick = game_event_handler(on_click)

end

