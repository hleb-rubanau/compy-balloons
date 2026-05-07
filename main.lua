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

game_start_state = {
  wins_count = 0,
  loss_count = 0,
  active_count = 0,
  visible_count = 0,
  changes = 0,
  score = 0,
  time = 0,
  state = 'started',
  prompt = STARTING_PROMPT,
  status_msg = fmt(STATUS_TEMPLATE, 0, 0, 0, 0, 0)
}

function game_start()
  game.pending_count = game.total_count
  partial_reset(game, game_start_state)
  game.status_msg = game_status_message()
  game.state = "started"
  game_interfaces.terminal.write(game.status_msg)
end

function game_over()
  game.stats_msg = game_stats_message()
  game.state = "finished"
end

function game_stats_message()
  local w = game.wins_count
  local n = game.total_count
  local s = game.score
  local t = game.time
  return fmt(STATS_TEMPLATE, w, n, s, t)
end

function game_status_message()
  local w = game.wins_count
  local p = game.pending_count
  local n = game.total_count - p
  local s = game.score
  local t = game.time
  return fmt(STATUS_TEMPLATE, w, n, p, s, t)
end

function game_is_over()
  local active_count = game.pending_count + game.visible_count
  return (active_count == 0)
end

function game_counter(name, step)
  step = step  or 1
  game[name] = game[name] + step
end 

function game_counter_changer(name, step)
  return function()
    game_counter(name, step)
  end
end

function challenges_event_handler(state,...)
  game.changes = game.changes + 1
  on_event[state](...)
end

function challenges_update(t)
  for i in 1, game.total_count do
    local c = challenges[i]
    c_handlers[ c.state ](c,t,i)  -- trick... it should use action handler to inform about state changes
  end
end

function game_update(dt)
  local time_before = game_time 

  game.changes = 0
  game.time = game.time + dt

  challenges_update(game.time)

  if math.floor(time.before) < math.floor(game.time) then
    game.status_msg = game_status_message()    
  end

  if game_is_over() then
    game_over()
  end
end


-- this one contains function references
game_interfaces = { }

draw_splash_welcome = widget_splash(WELCOME_MESSAGE).draw
draw_splash_restart = function()
  game_interfaces.splash.draw( game.stats_message )
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

on_event = action_map({
  'launched' = function() 
    game_counter('pending_count',-1)
    game_counter('visible_count')
  end,
  'solved' = function(score)
    game_counter('wins_count')
    game_counter('score', score)
  end,
  'expired' = function() 
    game_counter('loss_count')
    game_counter('visible_count', -1)
  end,
  'cleared' = function()  -- win after animation
    game_counter('visible_count', -1)
  end
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
  game_interfaces.splash = widget_splash_restart()
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
  challenges_init(game.total_count) -- these are stateless challenges/visuals
  -- but when we will build challenges logic, we also need to pass events handler somehow
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
