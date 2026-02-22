require("config")

fmt = string.format
gfx = love.graphics
sfx = compy.audio
sw, sh = gfx.getDimensions()

fonts = { }
for name, font_size in pairs(FONTS) do
  fonts[name] = gfx.newFont(font_size)
end 

field_height = sh*(1-SCREEN_VPAD)
field_width = sw
