require("config")
require("constants")

-- Background helpers called by controller directly.
function drawBackground()
  gfx.setColor(COLORS.bg)
  gfx.rectangle("fill", 0, 0, sw, field_height)
end

function drawFieldBackground()
  gfx.setColor(COLORS.bg)
  gfx.rectangle("fill", 0, 0, field_width, field_height)
end
