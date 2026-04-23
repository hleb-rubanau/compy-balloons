require("config")
require("constants")
--require("views_helpers")

class = require("util.class")

BoxView = class.create( function(question, answer)
  return {
    q = question,
    a = answer
  }
end)

function BoxView:calculate_geometry()
  self.qw = fonts.question:getWidth(self.question)
  self.qh = fonts.question:getHeight()
  self.aw = fonts.answer:getWidth(self.answer)
  self.ah = fonts.answer:getHeight()
  
  self.th = math.max(self.qh, self.ah)
  self.p = self.th / 2 
  self.h = 2 * self.th
  self.w = 3 * self.p + self.qw + self.aw 
end

function BoxView:geometry()
  if (! self.w ) then
    self:calculate_geometry()
  end
  return self.w, self.h
end

function BoxView:draw_canvas(with_answer)
  local text_w = self.qw
  if with_answer then
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

function BoxView:draw_question()
  local text_x = self.p
  local text_y = (self.h - self.qh) / 2
  gfx.push()
  gfx.setColor(COLORS.question_fg)
  gfx.setFont(fonts.question)
  gfx.printf(self.q, text_x, text_y, self.qw, self.qh)
  gfx.pop()
end

function BoxView:draw_answer()
  local text_x = self.p + self.qw + self.p
  local text_y = (self.h - self.ah) / 2
  gfx.push()
  gfx.setColor(COLORS.answer_ok)
  gfx.setFont(fonts.answer)
  gfx.printf(self.q, text_x, text_y, self.aw, self.ah)
  gfx.pop()
end

function BoxView:draw(with_answer)
  gfx.push()
  self:draw_canvas(with_answer)
  self:draw_question()
  if with_answer then
    self:draw_answer()
  end
  gfx.pop()
end

