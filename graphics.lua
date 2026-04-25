require("config")
require("constants")

gfx = love.graphics

-- Core principle: every function returns { geometry={w,h}, draw=fn }
-- All drawing assumes (0,0). Callers handle gfx.translate / push / pop.

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local function get_opt(opts, key, default)
  if opts and opts[key] ~= nil then return opts[key] end
  return default
end

local function resolve_font(key)
  if FONTS and FONTS[key]     then return FONTS[key] end
  if FONTS and FONTS.default  then return FONTS.default end
  return gfx.getFont()
end

local function resolve_color(key)
  if COLORS and COLORS[key]   then return COLORS[key] end
  if COLORS and COLORS.default then return COLORS.default end
  return {1, 1, 1, 1}
end


-------------------------------------------------------------------------------
-- widget_box
-- Draws a rounded-rectangle frame around an area of (inner_w × inner_h).
-- Padding is added automatically.
-- Returns { geometry={w,h}, draw=fn, label_pos={x,y} }
-- label_pos is the top-left corner of the inner area in local coordinates.
-------------------------------------------------------------------------------
function widget_box(inner_w, inner_h, opts)
  opts = opts or {}
  local border_color  = get_opt(opts, "border_color", resolve_color("border"))
  local bg_color      = get_opt(opts, "bg_color",     resolve_color("bg"))
  local border_width  = get_opt(opts, "border_width",  2)
  local corner_radius = get_opt(opts, "corner_radius", 6)
  local pad           = math.max(
                          get_opt(opts, "padding", inner_h * 0.35),
                          inner_h * 0.25)

  local w = inner_w + pad * 2
  local h = inner_h + pad * 2

  local function draw()
    gfx.push("all")
    gfx.setColor(bg_color)
    gfx.rectangle("fill", 0, 0, w, h, corner_radius)
    gfx.setColor(border_color)
    gfx.setLineWidth(border_width)
    gfx.rectangle("line", 0, 0, w, h, corner_radius)
    gfx.pop()
  end

  return {
    geometry  = {w, h},
    draw      = draw,
    label_pos = {pad, pad},
  }
end


-------------------------------------------------------------------------------
-- widget_htext
-- Lays out N text strings side by side (left-to-right), vertically centred.
-- Uses font "font1".."fontN" and color "color1".."colorN" from FONTS / COLORS,
-- with a half-line-height gap between pieces.
-- Returns { geometry={w,h}, draw=fn }
-------------------------------------------------------------------------------
function widget_htext(...)
  local texts = {...}
  assert(#texts >= 1, "widget_htext: need at least one string")

  local fonts, colors, ws, hs = {}, {}, {}, {}
  local max_h = 0
  for i, txt in ipairs(texts) do
    fonts[i]  = resolve_font("font"..i)
    colors[i] = resolve_color("color"..i)
    ws[i]     = fonts[i]:getWidth(txt)
    hs[i]     = fonts[i]:getHeight()
    if hs[i] > max_h then max_h = hs[i] end
  end

  local gap   = max_h * 0.5
  local total_w = -gap
  for _, w in ipairs(ws) do total_w = total_w + w + gap end
  local total_h = max_h * 2   -- comfortable line height × 2 for vertical room

  local function draw()
    gfx.push("all")
    local x = 0
    for i, txt in ipairs(texts) do
      gfx.setFont(fonts[i])
      gfx.setColor(colors[i])
      local ty = (total_h - hs[i]) / 2
      gfx.print(txt, x, ty)
      x = x + ws[i] + gap
    end
    gfx.pop()
  end

  return { geometry = {total_w, total_h}, draw = draw }
end


-------------------------------------------------------------------------------
-- widget_vtext
-- Stacks N text strings top-to-bottom, centred horizontally.
-- Same font/color resolution as widget_htext.
-- Returns { geometry={w,h}, draw=fn }
-------------------------------------------------------------------------------
function widget_vtext(...)
  local texts = {...}
  assert(#texts >= 1, "widget_vtext: need at least one string")

  local fonts, colors, ws, hs = {}, {}, {}, {}
  local max_w, max_h = 0, 0
  for i, txt in ipairs(texts) do
    fonts[i]  = resolve_font("font"..i)
    colors[i] = resolve_color("color"..i)
    ws[i]     = fonts[i]:getWidth(txt)
    hs[i]     = fonts[i]:getHeight()
    if ws[i] > max_w then max_w = ws[i] end
    if hs[i] > max_h then max_h = hs[i] end
  end

  local gap     = max_h * 0.5
  local total_h = gap / 2
  for _, h in ipairs(hs) do total_h = total_h + h + gap end

  local function draw()
    gfx.push("all")
    local y = gap / 2
    for i, txt in ipairs(texts) do
      gfx.setFont(fonts[i])
      gfx.setColor(colors[i])
      gfx.print(txt, (max_w - ws[i]) / 2, y)
      y = y + hs[i] + gap
    end
    gfx.pop()
  end

  return { geometry = {max_w, total_h}, draw = draw }
end


-------------------------------------------------------------------------------
-- widget_htextbox  /  widget_vtextbox
-- Combo: wrap a horizontal / vertical text widget in a box.
-- opts forwarded to widget_box.
-- Returns { geometry={w,h}, draw=fn }
-------------------------------------------------------------------------------
local function textbox_from(text_widget, opts)
  local tw, th = unpack(text_widget.geometry)
  local box     = widget_box(tw, th, opts)
  local lx, ly  = unpack(box.label_pos)

  local function draw()
    gfx.push("all")
    box.draw()
    gfx.translate(lx, ly)
    text_widget.draw()
    gfx.pop()
  end

  return { geometry = box.geometry, draw = draw }
end

function widget_htextbox(opts, ...)
  return textbox_from(widget_htext(...), opts)
end

function widget_vtextbox(opts, ...)
  return textbox_from(widget_vtext(...), opts)
end


-------------------------------------------------------------------------------
-- widget_balloon
-- Draws an ellipse body with nub, string, highlight, and optional label.
-- opts:
--   size        = 1|2|3 (scale multiplier, default 1)
--   fill_color, line_color, nub_color, str_color, hi_color
--   text, text_color, font
-- Returns { geometry={w,h}, draw=fn }
-------------------------------------------------------------------------------
function widget_balloon(opts)
  opts = opts or {}

  local scales = {[1]=1.0, [2]=1.5, [3]=2.0}
  local scale  = scales[get_opt(opts, "size", 1)] or 1.0

  local rx   = 80  * scale
  local ry   = 80  * scale
  local nubW = 10  * scale
  local nubH = 16  * scale
  local strL = 40  * scale

  local fill_color = get_opt(opts, "fill_color", {0.90, 0.22, 0.27, 1})
  local line_color = get_opt(opts, "line_color", {0.76, 0.07, 0.12, 1})
  local nub_color  = get_opt(opts, "nub_color",  line_color)
  local str_color  = get_opt(opts, "str_color",  {0.6, 0.6, 0.6, 1})
  local hi_color   = get_opt(opts, "hi_color",   {1, 1, 1, 0.4})

  local text       = get_opt(opts, "text", nil)
  local text_color = get_opt(opts, "text_color", {1, 1, 1, 1})
  local font       = get_opt(opts, "font", nil) or resolve_font("balloon")

  local cx = rx
  local cy = ry

  local function draw()
    gfx.push("all")

    gfx.setColor(fill_color)
    gfx.ellipse("fill", cx, cy, rx, ry)

    gfx.setColor(line_color)
    gfx.setLineWidth(2 * scale)
    gfx.ellipse("line", cx, cy, rx, ry)

    local nubTop = cy + ry
    gfx.setColor(nub_color)
    gfx.polygon("fill", cx - nubW, nubTop, cx + nubW, nubTop, cx, nubTop + nubH)

    gfx.setColor(str_color)
    gfx.setLineWidth(1)
    gfx.line(cx, nubTop + nubH,
             cx + 5, nubTop + nubH + strL * 0.4,
             cx - 4, nubTop + nubH + strL * 0.7,
             cx,     nubTop + nubH + strL)

    gfx.setColor(hi_color)
    gfx.push("all")
    gfx.translate(cx - 18 * scale, cy - 13 * scale)
    gfx.rotate(-math.pi / 5)
    gfx.ellipse("fill", 0, 0, rx * 0.22, ry * 0.14)
    gfx.pop()

    if text then
      gfx.setFont(font)
      local tw = font:getWidth(text)
      local th = font:getHeight()
      gfx.setColor(1, 1, 1, 1)
      gfx.ellipse("fill", cx, cy, tw * 0.75, th * 0.75)
      gfx.setColor(text_color)
      gfx.print(text, cx - tw / 2, cy - th / 2)
    end

    gfx.pop()
  end

  return {
    geometry = {rx * 2, ry * 2 + nubH + strL},
    draw     = draw,
  }
end


-------------------------------------------------------------------------------
-- widget_animation
-- Takes N pre-built widget tables. draw(phase) maps phase∈[0,1] to a frame.
-- Returns { geometry={w,h}, length=N, draw=fn }
-------------------------------------------------------------------------------
function widget_animation(...)
  local frames = {...}
  local N = #frames
  assert(N >= 1, "widget_animation: need at least one frame")

  local max_w, max_h = 0, 0
  for _, f in ipairs(frames) do
    if f.geometry[1] > max_w then max_w = f.geometry[1] end
    if f.geometry[2] > max_h then max_h = f.geometry[2] end
  end

  local function draw(phase)
    phase   = math.max(0, math.min(1, phase or 0))
    local n = math.max(1, math.min(N, math.floor(phase * (N - 1) + 0.5) + 1))
    local f  = frames[n]
    local ox = math.floor((max_w - f.geometry[1]) / 2)
    local oy = math.floor((max_h - f.geometry[2]) / 2)
    if ox ~= 0 or oy ~= 0 then
      gfx.push()
      gfx.translate(ox, oy)
      f.draw()
      gfx.pop()
    else
      f.draw()
    end
  end

  return { geometry = {max_w, max_h}, length = N, draw = draw }
end

function widget_animation_loop(...)
  local anim = widget_animation(...)
  return {
    geometry = anim.geometry,
    length   = anim.length,
    draw     = function(phase, ...) anim.draw(phase % 1, ...) end,
  }
end


-------------------------------------------------------------------------------
-- widget_noop
-- Invisible placeholder with zero size. Useful as a blank animation frame.
-------------------------------------------------------------------------------
function widget_noop()
  return { geometry = {0, 0}, draw = function() end }
end


-------------------------------------------------------------------------------
-- widget_challenge
-- Balloon (score) above a vtextbox (question / answer).
-- The textbox animates through three states via widget_animation:
--   phase 0 → question only
--   phase 0.5 → question + answer
--   phase 1 → invisible (noop)
-- draw(score_text, phase)
-- Returns { geometry={w,h}, draw=fn }
-------------------------------------------------------------------------------
function widget_challenge(question, answer, opts)
  opts = opts or {}

  local balloon = widget_balloon({
    size       = get_opt(opts, "size", 1),
    fill_color = get_opt(opts, "fill_color", nil),
    line_color = get_opt(opts, "line_color", nil),
  })

  local box_opts = {
    border_color = get_opt(opts, "border_color", {0.3, 0.3, 0.3, 1}),
    bg_color     = get_opt(opts, "bg_color",     {0.1, 0.1, 0.1, 0.85}),
  }

  local textbox_anim = widget_animation(
    widget_vtextbox(box_opts, question),
    widget_vtextbox(box_opts, question, answer),
    widget_noop()
  )

  local bw, bh = unpack(balloon.geometry)
  local tw, th = unpack(textbox_anim.geometry)
  local overlap = 5

  local total_w = math.max(bw, tw)
  local total_h = bh + th - overlap
  local balloon_x  = (total_w - bw) / 2
  local textbox_x  = (total_w - tw) / 2
  local textbox_y  = bh - overlap

  local function draw(score_text, phase)
    phase = phase or 0

    gfx.push("all")
    gfx.translate(balloon_x, 0)
    balloon.draw(score_text)
    gfx.pop()

    gfx.push("all")
    gfx.translate(textbox_x, textbox_y)
    textbox_anim.draw(phase)
    gfx.pop()
  end

  return { geometry = {total_w, total_h}, draw = draw }
end
