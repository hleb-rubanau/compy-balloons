require("config")
require("constants")
require("challenges")
require('graphics')


game = {
  state = 'loaded',
  welcome_message = WELCOME_MESSAGE,
  status_message = "",
  total_count = MAX_SLOTS,
  prompt = SPLASH_HINT_START
}

function game_start()
  stats_reset( game.total_count )
  challenges_reset()
  game.status_msg = stats_status_message()
  game.state = "started"
  ui.terminal.write(game.status_msg)
end

function game_over()
  game.stats_msg = stats_message()
  game.state = "finished" -- stops updates, activates splash
end

function challenges_update(t, callback)
  for i in 1, game.total_count do
  end
end

function game_status_update()
  game.status_msg = game_status_message()
  if stats_settled() then
    game_over()
  end
end

function game_update(dt)
  local t_old = stats.time 
  local t_new = stats_add('time', dt)
  local new_second = math.floor(t_old) < math.floor(t_new)

  stats.changes = 0
  challenges_update(t_new, stats_change_handler)

  if new_second or stats.changes > 0 then
    game_status_update()
  end
end


-- this one contains function references
ui = { }

draw_splash_welcome = widget_splash(WELCOME_MESSAGE).draw
draw_splash_restart = function()
  ui.splash.draw( game.stats_message )
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
  'loaded' = draw_splash_welcome,
  'active'  = draw_game,
  'finished' = draw_splash_restart
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

function ui_init()
  ui.terminal =  game_terminal_init()
  ui.splash = widget_splash_restart()
end

function game_handlers_init(terminal)
  local state_updater = game_event_handler(on_update)
  love.update = function(...)
    terminal.read() 
    state_updater(...)
  end
  compy.singleclick = game_event_handler(on_click)
  love.draw = game_event_handler(on_draw)
end

function game_init()
  --game_state_init()
  challenges_init(game.total_count) -- these are stateless challenges/visuals
  -- but when we will build challenges logic, we also need to pass events handler somehow
  ui_init()
  game_handlers_init(ui.terminal)
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
