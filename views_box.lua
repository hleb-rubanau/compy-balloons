require("config")
require("constants")
require("views_helpers")

local M = {}

local function draw_canvas(x, y, bw, bh)
  gfx.setColor(COLORS.question_bg)
  gfx.rectangle("fill", x, y, bw, bh)
end

local function draw_question(x, y, question)
  local f = fonts.question
  gfx.setColor(COLORS.question_fg)
  gfx.setFont(f)
  gfx.printf(question, x, y, f:getWidth(question), "left")
end

local function draw_answer(x, y, answer, color)
  local f = fonts.answer
  gfx.setFont(f)
  gfx.setColor(color)
  gfx.printf(answer, x, y, f:getWidth(answer), "left")
end

-- Returns bw, bh — caller needs size for layout.
function M.size(question, answer)
  local qw, qh, aw, ah = label_text_geometries(question, answer)
  local bw, bh = text_background_geometry(qw, qh, aw, ah)
  return bw, bh, qw, qh, aw, ah
end

function M.draw(x, y, question, answer, color)
  local bw, bh, qw, qh, aw, ah = M.size(question, answer)
  local qx, qy, ax, ay = label_text_positions(bh, qh, qw, ah)
  draw_canvas(x, y, bw, bh)
  draw_question(x + qx, y + qy, question)
  draw_answer(x + ax, y + ay, answer, color)
  return bw, bh
end

return M