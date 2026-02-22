require("config")

fmt = string.format
gfx = love.graphics
sfx = compy.audio
sw, sh = gfx.getDimensions()

fonts = {
  question = gfx.newFont(QUESTION_FONT_SIZE),
  answer = gfx.newFont(ANSWER_FONT_SIZE),
  time = gfx.newFont(TIME_FONT_SIZE),
  counters = gfx.newFont(COUNTERS_FONT_SIZE)
}

field_height = sh*(1-SCREEN_VPAD)
