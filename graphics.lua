require("config")
require("constants")

gfx = love.graphics


-- principle -- every function returns a table with two fields:
-- {
--    'geometry' = {w, h} -- calculated width, height
--    'draw' -- function that uses gfx primitives to actually draw requested widget when invoked
--   }

-- all drawing must assume coordinates (0,0) (calling code takes care of gfx.translate()/.push()/.pop() if needed)
-- if function does complex drawing in itw working area, invoking other widgets, it may also use push/translate/pop around the invocation





-- draws a 'box' leaving on it a space for label of desired geometry
-- uses colors from opts table to determine border and label background colors
-- padding should be not less than 0.25 of label height
function widget_box(label_w, label_h, opts)
end

-- draws widget box and a sequence of texts inside it (could be one text)
--  obviously it needs to calculate a space required for texts prior to invokig 'widget_box'
-- fonts are taken from opts or default FONTS table
-- colors are taken from opts or default FONTS table
--  (how to map fonts/colors in case of 'texts' sequence... maybe as table-lists)
-- in case of horizontal texts stacking:
--  label height is calculated as a max of texts heights, multiplied by 2
--  label width is calculated as sum of two texts, padding being a half of text height
--  positions for printf to be calculated appropriately
-- in case of vertical texts stacking:
--  label height is calculated as sum of texts heights plus some vertical padding (half-line-height?)
--  label width is max of text widths plus 2*horizontal padding (half-line-height?)
function widget_textbox(config, ...texts)
end


-- draws a baloon -- we even have some code for it (see baloon prototype code below)
-- baloon can have a 'size' (1,2,3) which is translated to scale factor
-- also can have customizable color(s)
-- can take optional text to be displayed on baloon -- in which case 'textbox' logic applies, except text is expected to be short (generally, always a number from 0 to 10) so could be put on top of circle label
function widget_baloon

end

-- accepts: question, answer, score, size, color
-- displays: baloon with score, and a textbox with question+answer under it
function widget_challenge
end


-- this function is used for reference only as an example of code that draws actual baloon (without text label) -- in fact it should take all hardcoded values from config or opts
function baloon_prototype_draw(x, y, scaleX, scaleY)
  local rx = 80 * scaleX
  local ry = 80 * scaleY
  local nubW = 10 * scaleX
  local nubH = 16 * scaleY
  local strL = 40 * scaleY

  -- Body (ellipse)
  gfx.setColor(0.90, 0.22, 0.27, 1)  -- red fill
  gfx.ellipse("fill", x, y, rx, ry)

  gfx.setColor(0.76, 0.07, 0.12, 1)  -- darker outline
  gfx.setLineWidth(2)
  gfx.ellipse("line", x, y, rx, ry)

  -- Nub (tie-off triangle at bottom)
  local nubTop = y + ry
  gfx.setColor(0.76, 0.07, 0.12, 1)
  gfx.polygon("fill",
    x - nubW, nubTop,
    x + nubW, nubTop,
    x,        nubTop + nubH
  )

  -- String (simple line; replace with a curve via gfx.line points)
  gfx.setColor(0.6, 0.6, 0.6, 1)
  gfx.setLineWidth(1)
  gfx.line(
    x, nubTop + nubH,
    x + 5, nubTop + nubH + strL * 0.4,
    x - 4, nubTop + nubH + strL * 0.7,
    x, nubTop + nubH + strL
  )

  -- Highlight (small rotated ellipse)
  gfx.setColor(1, 1, 1, 0.4)
  gfx.push()
  gfx.translate(x - 18, y - 13)
  gfx.rotate(-math.pi / 5)
  gfx.ellipse("fill", 0, 0,
    rx * 0.22, ry * 0.14)
  gfx.pop()

  -- Reset color
  gfx.setColor(1, 1, 1, 1)
end
