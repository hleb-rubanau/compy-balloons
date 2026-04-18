require("config")
require("constants")

local M = {}

function M.draw(x, y, bonus, color)
  local tw = fonts.score:getWidth(tostring(bonus))
  local th = fonts.score:getHeight()
  gfx.setColor(color)
  gfx.circle("fill", x, y, BALLOON_RADIUS)
  gfx.setColor(COLORS.score)
  gfx.circle("line", x, y, BALLOON_RADIUS)
  gfx.setFont(fonts.score)
  gfx.printf(bonus, x - tw / 2, y - th / 2, tw, "center")
end

return M
