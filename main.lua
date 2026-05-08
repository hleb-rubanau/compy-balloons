require("config")
require("challenges")
require('graphics')
require("stats")

game = {
  state = 'loaded',
  current_status_msg = "",
  final_status_msg = "",
  last_input = nil,
  total_count = MAX_SLOTS,
  prompt = SPLASH_HINT_START
}

ui = { 
  terminal = terminal_init(),
  field = widget_field(),
  splash_welcome = widget_splash_welcome(),
  splash_restart = widget_splash_gameover(),
  challenges = {
    draw = challenges_draw
  }
}

function game_start()
  local n = game.total_count
  stats_reset(n)
  challenges_reset(n)
  game.last_input = nil
  game.current_status_msg = ""
  game.state = "started"
  -- should be part of draw?
  ui_refresh_status()
end

function game_over()
  game.stats_msg = stats_message()
  game.state = "finished" -- stops updates, activates splash
  game.last_input = nil
  game.current_status_message = game.stats_msg
  ui_refresh_status()
end

function game_status_message()
  local prompt = game.last_input 
end

function ui_status_prompt()
  local inp = game.last_input
  return inp and fmt(GAME_PROMPT, inp) or STARTING_PROMPT
end

function ui_refresh_status()
  local prompt = ui_status_prompt()
  local status = game.current_status_message
  local statusline = prompt .."   "... status 
  ui.terminal.write(statusline)
end

function game_status_update()
  game.current_status_msg = game_status_message()
  ui_refresh_status()
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
  game.last_input = txt
  challenges_validate(txt, stats.time, stats_change_handler)
  game_status_update()
end

function game_draw_field()
  ui.field.draw()
  challenges_draw() 
end

splash_draw_welcome = widget_splash(WELCOME_MESSAGE).draw
splash_draw_restart = function()
  ui.splash_restart.draw( game.stats_message )
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
  'loaded' = ui.splash_welcome.draw,
  'active'  = game_draw_field,
  'finished' = splash_draw_restart
})

on_tick = action_map({
  'active' = game_update
})

function game_event_handler(map)
  return function(...)
    map[game.state](...)
  end
end

function game_init()
  challenges_init() 

  local state_updater = game_event_handler(on_tick)
  local input_handler = game_event_handler(on_input)
  love.update = function(...)
    terminal_read(input_handler) 
    state_updater(...)
  end
  compy.singleclick = game_event_handler(on_click)
  love.draw = game_event_handler(on_draw)
end

game_init()
