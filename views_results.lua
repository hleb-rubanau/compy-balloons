require("config")
require("constants")

local M = {}

local function card(n, color)
  local ry = field_height - result_height * n
  local px, pw = panel_x, panel_width
  gfx.setColor(color)
  gfx.rectangle("fill", px, ry, pw, result_height)
  gfx.setColor(COLORS.results_border)
  gfx.rectangle("line", px, ry, pw, result_height)
end

function M.draw_pending(n)
  card(n, COLORS.results_bg)
end

function M.draw_waiting(n)
  card(n, COLORS.results_wait)
end

function M.draw_failed(n)
  card(n, COLORS.results_fail)
end

function M.draw_successful(n, bonus)
  card(n, COLORS.results_ok)
  local f = fonts.results_score
  local fh = f:getHeight()
  local px, pw, rh = panel_x, panel_width, result_height
  local ry = (field_height - rh * (n - 0.5)) - fh / 2
  gfx.setFont(f)
  gfx.setColor(COLORS.results_score)
  gfx.printf(bonus, px, ry, pw, "center")
end

return M