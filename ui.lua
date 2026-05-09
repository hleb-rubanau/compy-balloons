require("config")

require("challenges")
require("stats")

require("graphics")
require("terminal")

require("helpers")
require("debugfunc")

ui = {
  terminal = terminal_init(),
  field = widget_field(),
  splash_welcome = widget_splash_welcome(),
  splash_restart = widget_splash_game_over(),
  challenges = {
    draw = challenges_draw,
  },
}

ui_messages = {
  hint = SPLASH_HINT_START,
  status = nil,
  result = nil,
}

function ui_results_message()
  local w = stats.wins
  local n = stats.total
  local s = stats.score
  local t = stats.time
  return fmt(STATS_TEMPLATE, w, n, s, t)
end

function ui_status_message()
  local w = stats.wins
  local p = stats.pending
  local n = stats.total - p
  local s = stats.score
  local t = stats.time
  return fmt(STATUS_TEMPLATE, w, n, p, s, t)
end

function ui_set_hint(txt)
  ui_messages.hint = txt
end

function ui_status_update()
  ui_messages.status = ui_status_message()
  logdebug("HINT: " .. tostring(ui_messages.hint))
  logdebug("STATUS: " .. tostring(ui_messages.status))
end

function ui_status_finalize()
  ui_messages.hint = SPLASH_HINT_RESTART
  ui_messages.results = ui_results_message()
  logdebug("HINT: " .. ui_messages.hint)
  logdebug("RESULTS: " .. ui_messages.results)
end

function ui_status_reset()
  ui_messages.hint = STARTING_PROMPT
  ui_messages.status = nil
  ui_messages.results = nil
end

function ui_draw_status()
  local hint = ui_messages.hint or "    "
  local status = ui_messages.results or ui_messages.status
  local statusline = hint .. "   " .. status
  --logdebug("STATUS: " .. statusline)
  ui.terminal.write(statusline)
end

-- alias
ui_read_input = terminal_read

ui_renderers = action_map({
  loaded = ui.splash_welcome.draw,
  active = function()
    ui.field.draw()
    ui.challenges.draw()
    ui_draw_status()
  end,
  finished = function()
    ui.splash_restart.draw(game.msg_stats_final)
  end,
})
