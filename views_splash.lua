local M = {}

local function max_width(lines, font)
  local w = 0
  for _, s in ipairs(lines) do
    local lw = font:getWidth(s)
    if lw > w then w = lw end
  end
  return w
end

local function box_geometry(lines, font)
  local fh = font:getHeight()
  local bw = max_width(lines, font)
  local bx = (screen_width - bw) / 2
  local bh = #lines * fh + (#lines-1) * 0.5 * fh
  local by = (field_height - bh) / 2
  return bx, by, bw, bh
end

function M.show(txt)
  local lines = string.split(txt, "\n")
  local f, fh = fonts.splash, fonts.splash:getHeight()
  local bx, by, bw = box_geometry(lines, f)
  return function()
    drawBackground()
    gfx.setColor(COLORS.splash)
    gfx.setFont(f)
    for i, t in ipairs(lines) do
      gfx.printf(t, bx, by+(i-1)*fh*1.5, bw, center)
    end
  end
end

function M.results(score, wins, total)
  return M.show(fmt(RESULTS_MESSAGE, score, wins, total))
end

return M