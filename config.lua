require("parameters")
require("colors")
require("helpers")

gfx = love.graphics
sfx = compy.audio
sw, sh = gfx.getDimensions()

FONTS = map(FONT_SIZES, gfx.newFont)
setmetatable(FONTS, { __index = FONTS.default })


SCREEN_WIDTH, SCREEN_HEIGHT = sw, sh
FIELD_WIDTH = SCREEN_WIDTH 
FIELD_HEIGHT = sh * (1 - SCREEN_VPAD)
ASCEND_SPEED = FIELD_HEIGHT / MAX_ASCEND_TIME

