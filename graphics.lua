require("config")
require("constants")

function drawBackground() 
  gfx.setColor(COLORS.bg)
  gfx.draw("fill", 0,0, sw, sh*(1-SCREEN_VPAD))
end
