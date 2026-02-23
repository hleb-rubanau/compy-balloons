require("config")
require("challenges")

fmt = string.format
gfx = love.graphics
sfx = compy.audio
sw, sh = gfx.getDimensions()

fonts = { }
for name, font_size in pairs(FONTS) do
  fonts[name] = gfx.newFont(font_size)
end

function calc_panel_width()
  local f = fonts.score
  local max_score = #CHALLENGES * ANSWER_TIMEOUT
  return f:getWidth(tostring(max_score)) * 1.5
end

screen_width = sw
panel_width = calc_panel_width()
field_height = sh * (1 - SCREEN_VPAD)
field_width = sw - panel_width
panel_x = field_width
score_y = (panel_width - fonts.score:getHeight()) / 2
result_height = (field_height - panel_width) / #CHALLENGES
