require("config")

fmt = string.format
gfx = love.graphics
sw, sh = gfx.getDimensions()

fonts = {
  question = gfx.newFont(QUESTION_FONT_SIZE),
  answer = gfx.newFont(ANSWER_FONT_SIZE)
}

