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

  game_state = "active"
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
    --safe_exec(game_status_update)
  end
end

function game_validate_input(txt)
  challenges_validate(txt, stats.time, stats_event_registrator)
  ui_set_hint(fmt(GAME_PROMPT, txt), true)
  --Log.debug("INPUT VALIDATED")
  --stats_debug()
  game_status_update()
  --Log.debug(fmt("GAME STATE=%s", game_state))
end

game_commands = action_map({
  start = game_start,
  restart = game_start,
}, ui_show_command_prompt)
function game_command(txt)
  game_commands[txt]()
end

on_tick = action_map({
  active = game_update,
})

on_input = action_map({
  active = game_validate_input,
  loaded = game_command,
  finished = game_command,
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
  local input_handler = game_state_router(on_input)
  hooks.update = function(...)
    ui_read_input(input_handler)
    state_updater(...)
  end
  hooks.draw = game_state_router(ui_renderers)

  ui_show_command_prompt()
  love.draw = hooks["draw"]
  love.update = hook("update")
end

--love.update = hook("update")
--compy.singleclick = hook("click")
--love.draw = hook("draw")

game_init()
