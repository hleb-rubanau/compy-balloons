require("config")
require("constants")
require("debugfunc")

local function maxStringWidth(strings, font)
  local maxWidth = 0
  for _, s in ipairs(strings) do
      local w = font:getWidth(s)
      if w > maxWidth then
          maxWidth = w
      end
  end
  return maxWidth
end

function drawBackground() 
  gfx.setColor(COLORS.bg)
  gfx.rectangle("fill", 0,0, sw, field_height)
end

function drawFieldBackground() 
  gfx.setColor(COLORS.bg)
  gfx.rectangle("fill", 0,0, field_width, field_height)
end

function drawSplash(txt)  
  local lines = string.split(txt,"\n")
  local f = fonts.splash
  local fh = f:getHeight()
  local box_height = #lines * fh + (#lines - 1) * 0.5 *fh
  local box_y = (field_height - box_height)/2
  local box_width = maxStringWidth(lines, fonts.splash)
  local box_x = (screen_width - box_width)/2
  drawBackground()
  gfx.setColor(COLORS.splash)
  gfx.setFont(f)
  for i,t in ipairs(lines) do
    local ty = box_y + (i-1)*fh*1.5
    gfx.printf(t, box_x, ty, box_width, center)
  end
end

function calc_text_geometry(font, txt)
  return font:getWidth(txt), font:getHeight()
end

function text_background_geometry(qw, qh, aw, ah)
  local th = math.max(qh, ah)
  local full_height = 2*th
  local full_width = qh/2 + qw + th/2 + aw + ah/2
  return full_width, full_height
end

function question_text_position(bh, qh)
  local question_x = qh/2
  local question_y = bh/2 - qh/2
  return question_x, question_y 
end

function answer_text_position(bh, ah, qh, qw)
  local th = math.max(qh,ah)
  local answer_x = qh/2 + qw + th/2
  local answer_y = bh/2 - ah/2
  return answer_x, answer_y
end

function drawQuestionObject(question, answer, answer_color)
  local x,y = current_x, current_y
  --logdebug("Drawing object at (%s,%s)", x, y)
  local qw, qh = calc_text_geometry(fonts.question, question)
  local aw, ah = calc_text_geometry(fonts.answer, ANSWER_STUB)
  if answer then
    aw, ah = calc_text_geometry(fonts.answer, answer)
  end 
  local bw, bh = text_background_geometry(qw, qh, aw, ah)

  -- prevent off-screen
  local dx = x + bw - field_width
  if dx > 0 then
    x = x - 2*dx
  end
  --logdebug("qw=%s, qh=%s, aw=%s, ah=%s, bw=%s, bh=%s", qw,qh,aw,ah,bw,bh)
  gfx.setColor(COLORS.question_bg)
  gfx.rectangle("fill", x, y, bw, bh)

  local qx, qy = question_text_position(bh, qh)
  gfx.setColor(COLORS.question_fg)
  gfx.setFont(fonts.question)
  gfx.printf(question, x+qx, y+qy, qw, "left")

  if answer then
    local ax, ay = answer_text_position(bh, ah, qh, qw)
    gfx.setColor(answer_color)
    gfx.setFont(fonts.answer)
    gfx.printf(answer, x+ax, y+ay, aw, "left")
  end
end

function get_random_x()
  math.randomseed(os.time())
  return math.random(sw*0.6)
end

function drawScore(score)
  gfx.setColor(COLORS.score_bg)
  gfx.rectangle("fill", panel_x, 0, screen_width, panel_width)
  gfx.setColor(COLORS.score)
  gfx.setFont(fonts.score)
  gfx.printf(score, panel_x, score_y, panel_width, "center")
end

function renderResultCard(n, color)
  local rx = panel_x
  local ry = field_height - result_height*n
  gfx.setColor(color)
  gfx.rectangle("fill", panel_x, ry, panel_width, result_height)
  gfx.setColor(COLORS.results_border)
  gfx.rectangle("line", panel_x, ry, panel_width, result_height)
end

function drawPendingResults()
  for i, _ in ipairs(CHALLENGES) do
    renderResultCard(i, COLORS.results_bg)
  end
end

function drawSuccessfulResult(n, bonus)
  renderResultCard(n, COLORS.results_ok)
  gfx.setFont(fonts.results_score)
  gfx.setColor(COLORS.results_score)
  local fh = fonts.results_score:getHeight()
  local ry = field_height - result_height * (n-0.5) - fh/2
  gfx.printf(bonus, panel_x, ry, panel_width, "center")
end

function drawWaitingResult(n)
  renderResultCard(n, COLORS.results_wait)
end

function drawFailedResult(n)
  renderResultCard(n, COLORS.results_fail)
end

function drawQuestion(question, answer, is_valid) 
  local color = COLORS.answer_fail
  if is_valid then
    color = COLORS.answer_ok
  end
  --inspect("COLOR",color)
  drawQuestionObject(question, answer, color)
end
