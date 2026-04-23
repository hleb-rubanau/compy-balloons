require("config")
require("constants")

class = require("util.class")

BaloonView = class.create( function(size)
  size = size or 1
  -- 1, 2, 3 -> 1, 1.5, 2.0
  local scale = 1 + (size - 1)/2 ,
  return {
    size = size,
    scale = scale,
    radius = BALOON_RADIUS*scale
    th = fonts.score:getHeight(),
  }
end)

function BaloonView:geometry()
  return self.radius, self.radius
end

function BaloonView:handle()
  return (self.radius * 2) + 5
end

function BaloonView:draw(bonus, color)
  local tw = fonts.score:getWidth(tostring(bonus))
  local r = self.radius
  local text_x = -0.5 * tw
  local text_y = -0.5 * self.th
  gfx.push()
  gfx.translate(r/2, r/2) 
  gfx.setColor(color)
  gfx.circle("fill", 0, 0, r)
  gfx.setColor(COLORS.score)
  gfx.circle("line", 0, 0, r)
  gfx.setFont(fonts.score)
  gfx.printf(bonus, text_x, text_y, tw, self.th, "center")
  gfx.pop()
end
