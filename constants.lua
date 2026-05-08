require("config")
require("helpers")
--require("challenges")

fmt = string.format
gfx = love.graphics
sfx = compy.audio
sw, sh = gfx.getDimensions()

FONTS = map(FONT_SIZES, gfx.newFont)
setmetatable(FONTS, { __index = FONTS.default })

--function calc_panel_width()
--  local f = fonts.score
--  local max_score = #CHALLENGES * ANSWER_TIMEOUT
--  return f:getWidth(tostring(max_score)) * 1.5
--end

SCREEN_WIDTH = sw
--PANEL_WIDTH = calc_panel_width()
--FIELD_WIDTH = SCREEN_WIDTH - PANEL_WIDTH

FIELD_WIDTH = SCREEN_WIDTH 
FIELD_HEIGHT = sh * (1 - SCREEN_VPAD)
ASCEND_SPEED = FIELD_HEIGHT / MAX_ASCEND_TIME

--panel_x = FIELD_WIDTH
--score_y = (panel_width - fonts.score:getHeight()) / 2
--result_height = (field_height - panel_width) / #CHALLENGES
