require("config")
require("constants")
require("views_helpers")

require("views_baloon")
require("views_box")


class = require("util.class")
ChallengeView = class.create( function(q, a, s)
  local result = {
    box = BoxView(q, a),  
    baloon = BaloonView(s)
  }
  return result
end)

function ChallengeView:calculate_geometry()
  local box_w, box_h = self.box:geometry()
  local bal_w, bal_h = self.baloon:geometry()
  local baloon_handle_offset = self.baloon:handle()

  self.w = math.max(box_w, bal_w),
  self.baloon_x = ( self.w - bal_w ) / 2
  self.box_x = ( self.w - box_w ) / 2 ,
  
  self.baloon_y = 0
  self.box_y = self.baloon_y + baloon_handle
  self.h = self.box_y + box_h
end

function ChallengeView:geometry()
  if (! self.w ) then
    self:calculate_geometry()
  end
  return self.w, self.h
end

function ChallengeView:draw(score, answer, color)
  gfx.push()
  gfx.translate(self.baloon_x, self.baloon_y)
  self.baloon:draw(score, color)
  gfx.pop()

  gfx.push()
  gfx.translate(self.box_x, self.box_y)
  self.box:draw(answer, color)
  gfx.pop()
end

function ChallengeView:renderer(score, answer, color)
  return function(x,y)
    gfx.push()
    gfx.translate(x,y)
    self:draw(score, answer, color)
    gfx.pop()
  end
end

--- we need following draw modes:
-- 1. question only (unanswered)
-- 2. q+a (animation)
-- 3. baloon only (answered past animation)
