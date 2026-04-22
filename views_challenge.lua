require("config")
require("constants")
require("views_helpers")

require("views_baloon")
require("views_box")


class = require("util.class")
ChallengeView = class.create( function(q, a, s)
  local result = {
    box = Box(q, a),  
    baloon = Baloon(s)
  }
  local box_w, box_h = result.box:geometry()
  local bal_w, bal_h = result.baloon:geometry()
  local baloon_handle = result.baloon:handle()

  result.w = math.max(box_w, bal_w),
  result.baloon_x = ( result.w - bal_w ) / 2
  result.box_x = ( result.w - box_w ) / 2 ,
  
  result.baloon_y = 0
  result.box_y = result.baloon_y + baloon_handle
  result.h = result.box_y + box_h

  return result
end)

function ChallengeView:geometry()
  return self.w, self.h
end

function ChallengeView:draw(score, answer, acolor)
  gfx.push()
  gfx.translate(self.baloon_x, self.baloon_y)
  self.baloon:draw(score, color)
  gfx.pop()

  gfx.push()
  gfx.translate(self.box_x, self.box_y)
  self.box:draw(score, color)
  gfx.pop()
end

--- we need following draw modes:
-- 1. question only (unanswered)
-- 2. q+a (animation)
-- 3. baloon only (answered past animation)



-- The single seam for layout change (bonus left vs top).
-- Returns offsets relative to challenge origin (x, y):
-- (bonus_ox, bonus_oy, label_ox, label_oy)
local function layout(lw, lh)
  local br = BALLOON_RADIUS
  -- return -br, lh / 2, 0, 0
  return lw / 2, -br, 0, 0
end

local function clamp_x(x, lw)
  local br = BALLOON_RADIUS
  return adjust_x(x, 2 * br, (field_width - lw) - 2 * br)
end

function M.renderer(question, answer, score, color)
  local lw, lh = Box.size(question, answer)
  local box, boy, lox, loy = layout(lw, lh)
  return function(x, y)
    x = clamp_x(x, lw)
    Baloon.draw(x + box, y + boy, score, color)
    Box.draw(x + lox, y + loy, question, answer, color)
  end
end

function M.unanswered(question, score)
  return M.renderer(question, " ", score, COLORS.results_wait)
end

function M.mistaken(question, answer, score)
  return M.renderer(question, answer, score, COLORS.answer_fail)
end

-- solved triggers animation on Box, therefore may need timer/framecount!
function M.solved(question, answer, score)
  return M.renderer(question, answer, score, COLORS.answer_ok)
end

return M
