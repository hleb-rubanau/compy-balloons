require("config")
require("constants")
--require("views_helpers")

class = require("util.class")

Box = class.create( function(question, answer)
  local params = {
    q = question,
    a = answer,
    qw = fonts.question:getWidth(question),
    qh = fonts.question:getHeight(),
    aw = fonts.answer:getWidth(answer),
    ah = fonts.answer:getHeight()
  }
  params.th = math.max(params.qh, params.ah)
  params.p = params.th / 2 
  params.h = 2 * params.th
  params.w = 3 * params.p + params.qw + params.aw 
  return params
end)

function Box:geometry()
  return self.w, self.h
end

function Box:draw_canvas(acolor)
  local text_w = self.qw
  if acolor then
    text_w = self.qw + self.p + self.aw
  end
  local box_w = text_w + 2 * self.p 
  local border_color = acolor or COLORS.question_fg
  gfx.push()
  gfx.setColor(COLORS.question_fg)
  gfx.rectangle("fill", 0, 0, box_w, self.h)
  gfx.setColor(COLORS.question_bg)
  gfx.rectangle("fill", 0, 0, text_w, self.th)
  gfx.pop()
end

function Box:draw_question()
  local text_x = self.p
  local text_y = (self.h - self.qh) / 2
  gfx.push()
  gfx.setColor(COLORS.question_fg)
  gfx.setFont(fonts.question)
  gfx.printf(self.q, text_x, text_y, self.qw, self.qh)
  gfx.pop()
end

function Box:draw_answer(acolor)
  local text_x = self.p + self.qw + self.p
  local text_y = (self.h - self.ah) / 2
  gfx.push()
  gfx.setColor(acolor)
  gfx.setFont(fonts.answer)
  gfx.printf(self.q, text_x, text_y, self.aw, self.ah)
  gfx.pop()
end

function Box:draw(acolor)
  gfx.push()
  self:draw_canvas(acolor)
  self:draw_question()
  if acolor then
    self:draw_answer()
  end
  gfx.pop()
end

