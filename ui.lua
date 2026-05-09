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
  status_bar = renderer_at(0, FIELD_HEIGHT, widget_status_bar()),
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
  local f = stats.losses
  local p = stats.pending
  local a = stats.total - p - w - f
  --local n = stats.total - p
  local s = stats.score
  local t = stats.time
  return fmt(STATUS_TEMPLATE, w, f, a, p, s, t)
end

function ui_set_hint(txt)
  ui_messages.hint = txt
  ui_draw_hint()
end

function ui_status_update()
  ui_messages.status = ui_status_message()
  logdebug("HINT: " .. tostring(ui_messages.hint))
  logdebug("STATUS: " .. tostring(ui_messages.status))
end

function ui_status_finalize()
  ui_set_hint(SPLASH_HINT_BASE)
  ui_messages.results = ui_results_message()
end

function ui_status_reset()
  ui_messages.status = nil
  ui_messages.results = nil
  ui_set_hint(STARTING_PROMPT)
end

function ui_draw_hint()
  local hint = ui_messages.hint or "         "
  ui.terminal.read(noop)
  ui.terminal.write(hint)
end

function ui_draw_status()
  local status = ui_messages.results or ui_messages.status
  --local statusline = hint .. "   " .. status
  --logdebug("STATUS: " .. statusline)
  --ui.terminal.write(statusline)
  ui.status_bar.draw(status)
end

function ui_init()
  ui_set_hint(SPLASH_HINT_BASE)
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
