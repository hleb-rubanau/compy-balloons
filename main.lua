require("config")
require("challenges")
require("graphics")
require("stats")
require("terminal")

game = {
  state = "loaded",
  total_count = MAX_SLOTS,
  msg_user_hint = SPLASH_HINT_START,
  msg_stats_final = nil,
  msg_stats_current = nil,
}

ui = {
  terminal = terminal_init(),
  field = widget_field(),
  splash_welcome = widget_splash_welcome(),
  splash_restart = widget_splash_gameover(),
  challenges = {
    draw = challenges_draw,
  },
}

function game_start()
  local n = game.total_count
  stats_reset(n)
  challenges_reset(n)

  game.msg_user_hint = STARTING_PROMPT
  game.msg_stats_current = nil
  game.msg_stats_final = nil

  game.state = "started"
  -- should be part of draw?
  ui_refresh_status()
end

function game_over()
  game.msg_user_hint = nil
  game.msg_stats_final = stats_message()
  game.msg_stats_current = nil
  game.state = "finished" -- stops updates, activates splash
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
  local hint = game.msg_user_hint or "    "
  local status = game.msg_stats_final or game.msg_stats_current
  local statusline = hint .. "   " .. status
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
  local t_new = stats_add("time", dt)
  local new_second = math.floor(t_old) < math.floor(t_new)

  stats.changes = 0
  challenges_update(t_new, stats_change_handler)

  if new_second or stats.changes > 0 then
    game_status_update()
  end
end

function game_validate_input(txt)
  challenges_validate(txt, stats.time, stats_change_handler)
  game.user_hint = fmt(GAME_PROMPT, txt)
  game_status_update()
end

on_click = action_map({
  loaded = game_start,
  finished = game_start,
})

on_tick = action_map({
  active = game_update,
})

on_input = action_map({
  active = game_validate_input,
  loaded = on_text_match("start", game_start),
  finished = on_text_match("start", game_start),
})

on_draw = action_map({
  loaded = ui.splash_welcome.draw,
  active = function()
    ui.field.draw()
    ui.challenges.draw()
  end,
  finished = function() 
    ui.splash_restart.draw(game.msg_stats_final)
  end
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
