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

ui = {
  terminal = terminal_init(),
  splash = widget_splash_gameover(),
  initial_splash = widget_splash_welcome()
}

function game_start()
  local n = game.total_count
  stats_reset(n)
  challenges_reset(n)
  game.status_msg = stats_status_message()
  game.state = "started"
  ui.terminal.write(game.status_msg)
end

function game_over()
  game.stats_msg = stats_message()
  game.state = "finished" -- stops updates, activates splash
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

function game_validate_input(txt)
  stats.changes = 0
  challenges_validate(txt, stats.time, stats_change_handler)
  if stats.changes > 0 then
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
  'active' = game_validate_input ,
  'loaded' = on_text_match('start', game_start),
  'finished' = on_text_match('start', game_start)
})


on_draw = action_map({
  'loaded' = draw_splash_welcome,
  'active'  = game_draw_field,
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

function game_handlers_init()
  local state_updater = game_event_handler(on_tick)
  local input_handler = game_event_handler(on_input)
  love.update = function(...)
    terminal_read(input_handler) 
    state_updater(...)
  end
  compy.singleclick = game_event_handler(on_click)
  love.draw = game_event_handler(on_draw)
end

function game_init()
  challenges_init() 
  game_handlers_init(ui.terminal)
end

game_init()
