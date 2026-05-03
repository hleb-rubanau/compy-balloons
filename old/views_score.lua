local M = {}

local function draw(score)
  local px, sw, pw = panel_x, screen_width, panel_width
  local hint_vpad = fonts.hint:getHeight() / 2
  gfx.setColor(COLORS.score_bg)
  gfx.rectangle("fill", px, 0, sw, pw)
  gfx.setColor(COLORS.score)
  gfx.setFont(fonts.hint)
  gfx.printf("SCORE", px, hint_vpad, pw, "center")
  gfx.setFont(fonts.score)
  gfx.printf(score, px, score_y, pw, "center")
end

function M.renderer(score)
  return function()
    draw(score)
  end
end

return M
