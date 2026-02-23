require("config")
require("constants")

function get_random_x()
  math.randomseed(os.time())
  return math.random(field_width * 0.9)
end

function calc_text_geometry(font, txt)
  return font:getWidth(txt), font:getHeight()
end

function font_h(name)
  return fonts[name]:getHeight()
end

function maxStringWidth(strings, font)
  local maxWidth = 0
  for _, s in ipairs(strings) do
    local w = font:getWidth(s)
    if maxWidth < w then
      maxWidth = w
    end
  end
  return maxWidth
end

function drawBackground()
  gfx.setColor(COLORS.bg)
  gfx.rectangle("fill", 0, 0, sw, field_height)
end

function drawFieldBackground()
  gfx.setColor(COLORS.bg)
  gfx.rectangle("fill", 0, 0, field_width, field_height)
end

function calc_splashbox_geometry(lines, font)
  local fh = font:getHeight()
  local box_width = maxStringWidth(lines, font)
  local box_x = (screen_width - box_width) / 2
  local box_height = #lines * fh + (#lines - 1) * 0.5 * fh
  local box_y = (field_height - box_height) / 2
  return box_x, box_y, box_width, box_height
end

function drawSplash(txt)
  local lines = string.split(txt, "\n")
  local f = fonts.splash
  local fh = f:getHeight()
  local bx, by, bw, bh = calc_splashbox_geometry(lines, f)
  drawBackground()
  gfx.setColor(COLORS.splash)
  gfx.setFont(f)
  for i, t in ipairs(lines) do
    local ty = by + (i - 1) * fh * 1.5
    gfx.printf(t, bx, ty, bw, center)
  end
end

function text_background_geometry(qw, qh, aw, ah)
  local th = math.max(qh, ah)
  local full_height = 2 * th
  local full_width = qh / 2 + qw + th / 2 + aw + ah / 2
  return full_width, full_height
end

function question_text_position(bh, qh)
  local question_x = qh / 2
  local question_y = bh / 2 - qh / 2
  return question_x, question_y
end

function answer_text_position(bh, ah, qh, qw)
  local th = math.max(qh, ah)
  local answer_x = qh / 2 + qw + th / 2
  local answer_y = bh / 2 - ah / 2
  return answer_x, answer_y
end

function drawPendingBonus(x, y, score, color)
  local bonus = ANSWER_TIMEOUT - math.floor(time)
  local tw = fonts.score:getWidth(tostring(bonus))
  local th = fonts.score:getHeight()
  gfx.setColor(color)
  gfx.circle("fill", x, y, BALLOON_RADIUS)
  gfx.setColor(COLORS.score)
  gfx.circle("line", x, y, BALLOON_RADIUS)
  gfx.setFont(fonts.score)
  gfx.printf(bonus, x - tw / 2, y - th / 2, tw, "center")
end

function adjust_x(x, leftmost, rightmost)
  local dx = x - rightmost
  if 0 < dx then
    x = x - 2 * dx
  end
  if x < leftmost then
    x = x + leftmost
  end
  return x
end

function drawQuestionCanvas(x, y, bw, bh)
  gfx.setColor(COLORS.question_bg)
  gfx.rectangle("fill", x, y, bw, bh)
end

function drawQuestionLabel(question, x, y)
  local f = fonts.question
  local qw = f:getWidth(question)
  gfx.setColor(COLORS.question_fg)
  gfx.setFont(f)
  gfx.printf(question, x, y, qw, "left")
end

function drawAnswerLabel(answer, x, y, color)
  local f = fonts.answer
  local aw = f:getWidth(answer)
  gfx.setFont(f)
  gfx.setColor(color)
  gfx.printf(answer, x, y, aw, "left")
end

function drawQuestionObject(question, answer, score, color)
  local qw, qh = calc_text_geometry(fonts.question, question)
  local aw, ah = calc_text_geometry(fonts.answer, answer)
  local bw, bh = text_background_geometry(qw, qh, aw, ah)
  local fw, br = field_width, BALLOON_RADIUS
  local qx, qy = question_text_position(bh, qh)
  local ax, ay = answer_text_position(bh, ah, qh, qw)
  x = adjust_x(current_x, 2 * br, (fw - bw) - 2 * br)
  drawPendingBonus(x - br, current_y + bh / 2, score, color)
  drawQuestionCanvas(x, current_y, bw, bh)
  drawQuestionLabel(question, x + qx, current_y + qy)
  drawAnswerLabel(answer, x + ax, current_y + ay, color)
end

function drawScore(score)
  local px, sw, pw = panel_x, screen_width, panel_width
  local hint_vpad = fonts.hint:getHeight() / 2
  gfx.setColor(COLORS.score_bg)
  gfx.rectangle("fill", px, 0, sw, pw)
  gfx.setColor(COLORS.score)
  gfx.setFont(fonts.hint)
  gfx.printf("SCORE", px, hint_vpad, pw, "center")
  gfx.setFont(fonts.score)
  gfx.printf(score, px, score_y, pw, "center")
end

function renderResultCard(n, color)
  local ry = field_height - result_height * n
  local px, pw = panel_x, panel_width
  gfx.setColor(color)
  gfx.rectangle("fill", px, ry, pw, result_height)
  gfx.setColor(COLORS.results_border)
  gfx.rectangle("line", px, ry, pw, result_height)
end

function drawPendingResults()
  for i, _ in ipairs(CHALLENGES) do
    renderResultCard(i, COLORS.results_bg)
  end
end

function drawSuccessfulResult(n, bonus)
  renderResultCard(n, COLORS.results_ok)
  local f = fonts.results_score
  local c = COLORS.results_score
  gfx.setFont(f)
  gfx.setColor(c)
  local fh = f:getHeight()
  local ry = (field_height - result_height * (n - 0.5)) - fh / 2
  gfx.printf(bonus, panel_x, ry, panel_width, "center")
end

function drawWaitingResult(n)
  renderResultCard(n, COLORS.results_wait)
end

function drawFailedResult(n)
  renderResultCard(n, COLORS.results_fail)
end

function drawQuestion(q, score)
  drawQuestionObject(q, " ", score, COLORS.results_wait)
end

function drawWrongAnswer(q, answer, score)
  drawQuestionObject(q, answer, score, COLORS.answer_fail)
end

function drawProperAnswer(q, answer, score)
  drawQuestionObject(q, answer, score, COLORS.answer_ok)
end
