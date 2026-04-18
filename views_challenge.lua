require("config")
require("constants")
require("views_helpers")
local Bonus = require("views_baloon")
local Label = require("views_box")

local M = {}

-- The single seam for layout change (bonus left vs top).
-- Returns offsets relative to challenge origin (x, y):
-- (bonus_ox, bonus_oy, label_ox, label_oy)
local function layout(lw, lh)
  local br = BALLOON_RADIUS
  return -br, lh / 2, 0, 0
end

local function clamp_x(x, lw)
  local br = BALLOON_RADIUS
  return adjust_x(x, 2 * br, (field_width - lw) - 2 * br)
end

function M.renderer(question, answer, score, color)
  local lw, lh = Label.size(question, answer)
  local box, boy, lox, loy = layout(lw, lh)
  return function(x, y)
    x = clamp_x(x, lw)
    Bonus.draw(x + box, y + boy, score, color)
    Label.draw(x + lox, y + loy, question, answer, color)
  end
end

function M.unanswered(question, score)
  return M.renderer(question, " ", score, COLORS.results_wait)
end

function M.mistaken(question, answer, score)
  return M.renderer(question, answer, score, COLORS.answer_fail)
end

function M.solved(question, answer, score)
  return M.renderer(question, answer, score, COLORS.answer_ok)
end

return M
