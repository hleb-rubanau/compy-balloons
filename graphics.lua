require("config")
require("constants")

gfx = love.graphics

-- Every function returns { geometry={w,h}, draw=fn }
-- All drawing assumes local (0,0). Callers handle translate/push/pop.

-------------------------------------------------------------------------------
-- Presets
-- Pass one of these tables (or any plain table with the same keys) to widgets.
-- Use shallow_merge(STYLE.card, {border_width=4}) for one-off overrides.
-------------------------------------------------------------------------------

STYLE = {
  card = {
    bg_color      = {0.10, 0.10, 0.10, 0.90},
    border_color  = {0.30, 0.30, 0.30, 1.00},
    border_width  = 2,
    corner_radius = 6,
    padding       = nil,    -- nil → auto (0.35 × inner height)
  },
  card_highlight = {
    bg_color      = {0.15, 0.12, 0.00, 0.92},
    border_color  = {0.90, 0.70, 0.10, 1.00},
    border_width  = 3,
    corner_radius = 8,
    padding       = nil,
  },
  balloon_red = {
    fill_color = {0.90, 0.22, 0.27, 1},
    line_color = {0.76, 0.07, 0.12, 1},
    size       = 1,
  },
  balloon_blue = {
    fill_color = {0.20, 0.45, 0.85, 1},
    line_color = {0.10, 0.25, 0.65, 1},
    size       = 1,
  },
}

-- Shallow-merge: keys in 'b' override keys in 'a'. Neither table is mutated.
function shallow_merge(a, b)
  local out = {}
  for k, v in pairs(a) do out[k] = v end
  if b then
    for k, v in pairs(b) do out[k] = v end
  end
  return out
end


-------------------------------------------------------------------------------
-- widget_box
-- Draws a rounded rect (bg fill + border) around an inner area (w × h).
-- style fields: bg_color, border_color, border_width, corner_radius, padding
-- Returns { geometry={w,h}, draw=fn, inner_pos={x,y} }
-------------------------------------------------------------------------------
function widget_box(inner_w, inner_h, style)
  local pad = style.padding or math.max(inner_h * 0.35, inner_h * 0.25)
  local w   = inner_w + pad * 2
  local h   = inner_h + pad * 2
  local r   = style.corner_radius or 6

  local function draw()
    gfx.push("all")
    gfx.setColor(style.bg_color)
    gfx.rectangle("fill", 0, 0, w, h, r)
    gfx.setColor(style.border_color)
    gfx.setLineWidth(style.border_width or 2)
    gfx.rectangle("line", 0, 0, w, h, r)
    gfx.pop()
  end

  return {
    geometry  = {w, h},
    draw      = draw,
    inner_pos = {pad, pad},
  }
end


-------------------------------------------------------------------------------
-- widget_htext
-- Lays out N text strings side by side, vertically centred.
-- Each string uses fonts[i] / colors[i] from the style table.
-- style fields: fonts = {f1,f2,...}, colors = {c1,c2,...}
-- Returns { geometry={w,h}, draw=fn }
-------------------------------------------------------------------------------
function widget_htext(style, ...)
  local texts = {...}
  assert(#texts >= 1, "widget_htext: need at least one string")

  local fonts, colors, ws, hs = {}, {}, {}, {}
  local max_h = 0
  for i, txt in ipairs(texts) do
    fonts[i]  = style.fonts[i]  or gfx.getFont()
    colors[i] = style.colors[i] or {1, 1, 1, 1}
    ws[i]     = fonts[i]:getWidth(txt)
    hs[i]     = fonts[i]:getHeight()
    if hs[i] > max_h then max_h = hs[i] end
  end

  local gap     = max_h * 0.5
  local total_w = -gap
  for _, w in ipairs(ws) do total_w = total_w + w + gap end
  local total_h = max_h * 2

  local function draw()
    gfx.push("all")
    local x = 0
    for i, txt in ipairs(texts) do
      gfx.setFont(fonts[i])
      gfx.setColor(colors[i])
      gfx.print(txt, x, (total_h - hs[i]) / 2)
      x = x + ws[i] + gap
    end
    gfx.pop()
  end

  return { geometry = {total_w, total_h}, draw = draw }
end


-------------------------------------------------------------------------------
-- widget_vtext
-- Stacks N text strings top-to-bottom, centred horizontally.
-- style fields: fonts = {f1,f2,...}, colors = {c1,c2,...}
-- Returns { geometry={w,h}, draw=fn }
-------------------------------------------------------------------------------
function widget_vtext(style, ...)
  local texts = {...}
  assert(#texts >= 1, "widget_vtext: need at least one string")

  local fonts, colors, ws, hs = {}, {}, {}, {}
  local max_w, max_h = 0, 0
  for i, txt in ipairs(texts) do
    fonts[i]  = style.fonts[i]  or gfx.getFont()
    colors[i] = style.colors[i] or {1, 1, 1, 1}
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
-- Wraps widget_htext / widget_vtext in a widget_box.
-- text_style  → forwarded to widget_htext / widget_vtext (fonts, colors)
-- box_style   → forwarded to widget_box (bg_color, border_color, ...)
-- Returns { geometry={w,h}, draw=fn }
-------------------------------------------------------------------------------
local function textbox_from(text_widget, box_style)
  local tw, th  = unpack(text_widget.geometry)
  local box     = widget_box(tw, th, box_style)
  local ix, iy  = unpack(box.inner_pos)

  local function draw()
    gfx.push("all")
    box.draw()
    gfx.translate(ix, iy)
    text_widget.draw()
    gfx.pop()
  end

  return { geometry = box.geometry, draw = draw }
end

function widget_htextbox(text_style, box_style, ...)
  return textbox_from(widget_htext(text_style, ...), box_style)
end

function widget_vtextbox(text_style, box_style, ...)
  return textbox_from(widget_vtext(text_style, ...), box_style)
end


-------------------------------------------------------------------------------
-- widget_balloon
-- Ellipse body + nub + string + highlight + optional centre label.
-- style fields: fill_color, line_color, nub_color, str_color, hi_color,
--               size (1|2|3), text, text_color, font
-- Returns { geometry={w,h}, draw=fn }
-------------------------------------------------------------------------------
function widget_balloon(style)
  local scales = {[1]=1.0, [2]=1.5, [3]=2.0}
  local scale  = scales[style.size or 1] or 1.0

  local rx, ry = 80*scale, 80*scale
  local nubW   = 10*scale
  local nubH   = 16*scale
  local strL   = 40*scale

  local fill  = style.fill_color or {0.90, 0.22, 0.27, 1}
  local line  = style.line_color or {0.76, 0.07, 0.12, 1}
  local nub_c = style.nub_color  or line
  local str_c = style.str_color  or {0.6, 0.6, 0.6, 1}
  local hi_c  = style.hi_color   or {1, 1, 1, 0.4}
  local text  = style.text
  local tc    = style.text_color or {1, 1, 1, 1}
  local font  = style.font or FONTS.balloon or gfx.getFont()

  local cx, cy = rx, ry

  local function draw()
    gfx.push("all")

    gfx.setColor(fill)
    gfx.ellipse("fill", cx, cy, rx, ry)

    gfx.setColor(line)
    gfx.setLineWidth(2*scale)
    gfx.ellipse("line", cx, cy, rx, ry)

    local nubTop = cy + ry
    gfx.setColor(nub_c)
    gfx.polygon("fill", cx-nubW, nubTop, cx+nubW, nubTop, cx, nubTop+nubH)

    gfx.setColor(str_c)
    gfx.setLineWidth(1)
    gfx.line(cx,   nubTop+nubH,
             cx+5, nubTop+nubH + strL*0.4,
             cx-4, nubTop+nubH + strL*0.7,
             cx,   nubTop+nubH + strL)

    gfx.setColor(hi_c)
    gfx.push("all")
    gfx.translate(cx - 18*scale, cy - 13*scale)
    gfx.rotate(-math.pi / 5)
    gfx.ellipse("fill", 0, 0, rx*0.22, ry*0.14)
    gfx.pop()

    if text then
      gfx.setFont(font)
      local tw, th = font:getWidth(text), font:getHeight()
      gfx.setColor(1, 1, 1, 1)
      gfx.ellipse("fill", cx, cy, tw*0.75, th*0.75)
      gfx.setColor(tc)
      gfx.print(text, cx - tw/2, cy - th/2)
    end

    gfx.pop()
  end

  return {
    geometry = {rx*2, ry*2 + nubH + strL},
    draw     = draw,
  }
end


-------------------------------------------------------------------------------
-- widget_animation
-- Wraps N widgets. draw(phase) where phase ∈ [0,1] selects the frame.
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
    local n = math.max(1, math.min(N, math.floor(phase*(N-1) + 0.5) + 1))
    local f  = frames[n]
    local ox = math.floor((max_w - f.geometry[1]) / 2)
    local oy = math.floor((max_h - f.geometry[2]) / 2)
    if ox ~= 0 or oy ~= 0 then
      gfx.push(); gfx.translate(ox, oy); f.draw(); gfx.pop()
    else
      f.draw()
    end
  end

  return { geometry={max_w, max_h}, length=N, draw=draw }
end

function widget_animation_loop(...)
  local anim = widget_animation(...)
  return {
    geometry = anim.geometry,
    length   = anim.length,
    draw     = function(phase, ...) anim.draw(phase % 1, ...) end,
  }
end

function widget_noop()
  return { geometry={0,0}, draw=function() end }
end


-------------------------------------------------------------------------------
-- widget_challenge
-- Balloon (score) above a vtextbox animating through three states:
--   phase 0   → question only
--   phase 0.5 → question + answer
--   phase 1   → blank (noop)
-- draw(score, phase)
-------------------------------------------------------------------------------
function widget_challenge(question, answer, balloon_style, text_style, box_style)
  balloon_style = balloon_style or STYLE.balloon_red
  box_style     = box_style     or STYLE.card
  text_style    = text_style    or {
    fonts  = { FONTS.question, FONTS.answer },
    colors = { COLORS.question, COLORS.answer },
  }

  local textbox_anim = widget_animation(
    widget_vtextbox(text_style, box_style, question),
    widget_vtextbox(text_style, box_style, question, answer),
    widget_noop()
  )

  local ref_balloon = widget_balloon(balloon_style)
  local bw, bh = unpack(ref_balloon.geometry)
  local tw, th = unpack(textbox_anim.geometry)
  local overlap = 5

  local total_w   = math.max(bw, tw)
  local total_h   = bh + th - overlap
  local balloon_x = (total_w - bw) / 2
  local box_x     = (total_w - tw) / 2
  local box_y     = bh - overlap

  local function draw(score, phase)
    local b = widget_balloon(shallow_merge(balloon_style, { text=tostring(score or "") }))

    gfx.push("all")
    gfx.translate(balloon_x, 0)
    b.draw()
    gfx.pop()

    gfx.push("all")
    gfx.translate(box_x, box_y)
    textbox_anim.draw(phase or 0)
    gfx.pop()
  end

  return { geometry={total_w, total_h}, draw=draw }
end