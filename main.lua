require("config")
require("constants")
require("challenges")
require('graphics')


game = {
  state = 'loaded',
  splash_message = WELCOME_MESSAGE,
  total_count = MAX_SLOTS
}

game_start_state = {
  wins_count = 0,
  loss_count = 0,
  active_count = 0,
  visible_count = 0,
  score = 0,
  time = 0,
  state = 'started'
}

function game_start()
  game.pending_count = game.total_count
  partial_reset(game, game_start_state)
  game.state = "started"
end

function game_over()
  local stats_msg
  game_interfaces.splash = widget
end


function game_is_over()
  local active_count = game.pending_count + game.visible_count
  return (active_count == 0)
end

function game_update(dt)
  game.time = game.time + dt

  if game_is_over() then
    game_over()
  end
end

function ga

function game_over()
  game.state = "finished"
end

function game_proceed

-- this one contains function references
game_interfaces = { }

function draw_splash()
  game_interfaces.splash.draw()
end



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
  'loaded' = draw_splash,
  'acive'  = draw_game,
  'finished' = draw_splash
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

function game_terminal_init()
  local input_handler = game_event_handler(on_input)
  return terminal_init(input_handler)
end

function game_interfaces_init()
  game_interfaces.terminal =  game_terminal_init()
  game_interfaces.welcome_splash = widget_splash(WELCOME_MESSAGE)
end

function game_handlers_init(terminal)
  local state_updater = game_event_handler(on_update)
  love.update = function(...)
    state_updater(...)
    terminal.read()
  end
  compy.singleclick = game_event_handler(on_click)
  love.draw = game_event_handler(on_draw)
end

function game_init()
  --game_state_init()
  challenges_init(game.total_count)
  game_interfaces_init()
  game_handlers_init(game_interfaces.terminal)
end

function game_reset()
  if game.state=='active' then
    return
  end
  -- NOTE: splash message should be generated on game end, not recalculated on each draw
  game.wins_count = 0
  game.loss_count = nil
  game.active_count = nil,
  game.visible_count = nil,
  game.state = 'active'
  game.score = 0,
  game.time = 0
end

game_init()
