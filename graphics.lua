require("config")
require("constants")
require("debugfunc")

function drawBackground() 
  gfx.setColor(COLORS.bg)
  gfx.rectangle("fill", 0,0, sw, sh*(1-SCREEN_VPAD))
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
  logdebug("Drawing object at (%s,%s)", x, y)
  local qw, qh = calc_text_geometry(fonts.question, question)
  local aw, ah = calc_text_geometry(fonts.answer, ANSWER_STUB)
  if answer then
    aw, ah = calc_text_geometry(fonts.answer, answer)
  end 
  local bw, bh = text_background_geometry(qw, qh, aw, ah)
  logdebug("qw=%s, qh=%s, aw=%s, ah=%s, bw=%s, bh=%s", qw,qh,aw,ah,bw,bh)
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

function drawTime(t)
  local th = fonts.time:getHeight()
  local tw = fonts.time:getWidth(ANSWER_STUB)
  local tx = th/2
  local ty = sh*(1-SCREEN_VPAD)-th
  gfx.setColor(COLORS.bg)
  gfx.rectangle("fill", tx, ty, tx+tw, ty+th)
  gfx.setColor(COLORS.time)
  gfx.printf(tostring(t), tx, ty, tw, "left")
end

function drawQuestion(question, answer, is_valid) 
  local color = COLORS.answer_fail
  if is_valid then
    color = COLORS.answer_ok
  end
  drawQuestionObject(question, txt, color)
end
