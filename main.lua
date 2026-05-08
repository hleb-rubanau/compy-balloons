require("config")
require("challenges")
require("stats")
require("ui")
require("helpers")
require("debugfunc")

game_state = "loaded"

function game_start()
  local n = MAX_SLOTS
  stats_reset(n)
  challenges_reset(n)

  ui_status_reset()

  game_state = "started"
  logdebug("GAME START: %s", game_state)
end

function game_over()
  ui_status_finalize()
  game_state = "finished" -- stops updates, activates splash
end

function game_status_update()
  -- stats_settled() and game_over() or ui_status_update()
  if stats_settled() then
    game_over()
  else
    ui_status_update()
  end
end

function game_update(dt)
  local t_old = stats.time
  local t_new = stats_add("time", dt)
  local new_second = math.floor(t_old) < math.floor(t_new)

  stats.changes = 0
  challenges_update(t_new, stats_event_registrator)

  if new_second or stats.changes > 0 then
    game_status_update()
  end
end

function game_validate_input(txt)
  challenges_validate(txt, stats.time, stats_event_registrator)
  game.msg_user_hint = fmt(GAME_PROMPT, txt)
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

function game_state_router(map, debugname)
  return function(...)
    if debugname then
      logdebug("DISPATCH[%s]: %s", debugname, game_state)
    end
    map[game_state](...)
  end
end

hooks = action_map({})
function hook(name)
  return function(...)
    if love.DEBUG then
      safe_exec(hooks[name], ...)
    else
      hooks[name](...)
    end
  end
end

function game_init()
  challenges_init()

  local state_updater = game_state_router(on_tick)
  local input_handler = game_state_router(on_input, "input")
  hooks.update = function(...)
    ui_read_input(input_handler)
    state_updater(...)
  end
  hooks.click = game_state_router(on_click)
  hooks.draw = game_state_router(ui_renderers)
  love.update = hooks["update"]
  compy.singleclick = hooks["click"]
  love.draw = hooks["draw"]
end

--love.update = hook("update")
--compy.singleclick = hook("click")
--love.draw = hook("draw")

game_init()
