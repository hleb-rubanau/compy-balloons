require("config")
require("constants")

gfx = love.graphics

-- Every function returns { geometry={w,h}, draw=fn }
-- All drawing assumes local (0,0). Callers handle translate/push/pop.

-------------------------------------------------------------------------------
-- Presets
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

function shallow_merge(a, b)
  local out = {}
  for k, v in pairs(a) do out[k] = v end
  if b then for k, v in pairs(b) do out[k] = v end end
  return out
end


-------------------------------------------------------------------------------
-- widget_text_label
-- Single string with a font, color, and uniform padding on all sides.
-- style fields: font, color, padding (default: 0)
-- Returns { geometry={w,h}, draw=fn }
-------------------------------------------------------------------------------
function widget_text_label(text, style)
  local font    = style.font    or gfx.getFont()
  local color   = style.color   or {1, 1, 1, 1}
  local padding = style.padding or 0

  local tw = font:getWidth(text)
  local th = font:getHeight()

  return {
    geometry = {tw + padding*2, th + padding*2},
    draw = function()
      gfx.push("all")
      gfx.setFont(font)
      gfx.setColor(color)
      gfx.print(text, padding, padding)
      gfx.pop()
    end,
  }
end


-------------------------------------------------------------------------------
-- widget_box
-- Rounded rect (bg + border) around an inner area (w × h).
-- style fields: bg_color, border_color, border_width, corner_radius, padding
-- Returns { geometry={w,h}, draw=fn, inner_pos={x,y} }
-------------------------------------------------------------------------------
function widget_box(inner_w, inner_h, style)
  local pad = style.padding or (math.min(inner_w, inner_h)* 0.25)
  local w   = inner_w + pad * 2
  local h   = inner_h + pad * 2
  local r   = style.corner_radius or 0
  local b   = style.border_width or 2

  return {
    geometry  = {w, h},
    inner_pos = {pad, pad},
    draw = function()
      gfx.push("all")
      gfx.setColor(style.bg_color)
      gfx.rectangle("fill", 0, 0, w, h, r)
      gfx.setColor(style.border_color)
      gfx.setLineWidth(b)
      gfx.rectangle("line", 0, 0, w, h, r)
      gfx.pop()
    end,
  }
end


-------------------------------------------------------------------------------
-- widget_answered_box
-- Two text labels (question | answer) side by side, separated by a gap,
-- wrapped in a box.
-- question_label / answer_label: pre-built widget_text_label tables.
-- style: forwarded to widget_box.
-- Returns { geometry={w,h}, draw=fn }
-------------------------------------------------------------------------------
function widget_answered_box(question_label, answer_label, style)
  local qw, qh = unpack(question_label.geometry)
  local aw, ah = unpack(answer_label.geometry)
  local gap  = style.gap or 12

  local inner_w = qw + gap + aw
  local inner_h = math.max(qh, ah)
  local box     = widget_box(inner_w, inner_h, style)
  local ix, iy  = unpack(box.inner_pos)

  return {
    geometry = box.geometry,
    draw = function()
      gfx.push("all")
      box.draw()
      gfx.translate(ix, iy)
      -- question: vertically centred
      gfx.push(); gfx.translate(0, (inner_h - qh) / 2)
      question_label.draw()
      gfx.pop()
      -- answer: vertically centred, offset to the right
      gfx.push(); gfx.translate(qw + gap, (inner_h - ah) / 2)
      answer_label.draw()
      gfx.pop()
      gfx.pop()
    end,
  }
end


-------------------------------------------------------------------------------
-- widget_balloon
-- style fields: fill_color, line_color, nub_color, str_color, hi_color,
--               size (1|2|3), text, text_color, font
-- Returns { geometry={w,h}, draw=fn }
-------------------------------------------------------------------------------
function widget_balloon(style)
  --local scales = {[1]=1.0, [2]=1.5, [3]=2.0}
  --local scale  = scales[style.size or 1] or 1.0
  local scale = 1 + (size - 1)/2  

  local rx, ry = 80*scale, 80*scale
  local nubW   = 10*scale
  local nubH   = 16*scale
  local strL   = 40*scale

  local fill  = style.fill_color or {0.90, 0.22, 0.27, 1}
  local line  = style.line_color or {0.76, 0.07, 0.12, 1}
  local nub_c = style.nub_color  or line
  local str_c = style.str_color  or {0.6, 0.6, 0.6,  1}
  local hi_c  = style.hi_color   or {1,   1,   1,   0.4}
  local text  = style.text
  local tc    = style.text_color or {1, 1, 1, 1}
  local font  = style.font or FONTS.balloon or gfx.getFont()

  local cx, cy = rx, ry

  return {
    geometry = {rx*2, ry*2 + nubH + strL},
    draw = function()
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
    end,
  }
end


-------------------------------------------------------------------------------
-- widget_animation / widget_animation_loop / widget_noop
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

  return {
    geometry = {max_w, max_h},
    length   = N,
    draw = function(phase)
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
    end,
  }
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

function widget_invisible(orig)
  return {
    geometry = orig.geometry,
    draw = function() end 
  }
end


-------------------------------------------------------------------------------
-- widget_challenge
-- Balloon (score) above an animated textbox cycling through:
--   phase 0   → question only (plain text_label in a box)
--   phase 0.5 → question + answer (answered_box)
--   phase 1   → blank (noop)
-- draw(score, phase)
-------------------------------------------------------------------------------
function widget_challenge(question, answer, balloon_style, label_styles, box_style)
  balloon_style = balloon_style or STYLE.balloon_red
  box_style     = box_style     or STYLE.card
  label_styles  = label_styles  or {
    question = { font=FONTS.question, color=COLORS.question },
    answer   = { font=FONTS.answer,   color=COLORS.answer   },
  }

  local q_label  = widget_text_label(question, label_styles.question)
  local a_label  = widget_text_label(answer, label_styles.answer) 
  
  local qa_box   = widget_answered_box(q_label, a_label, box_style)
  local q_box    = widget_answered_box(q_label, widget_invisible(a_label), box_style)

  local textbox_anim = widget_animation(q_box, 
                                        qa_box, 
                                        widget_invisible(qa_box))

  local ref_balloon = widget_balloon(balloon_style)
  local bw, bh = unpack(ref_balloon.geometry)
  local tw, th = unpack(textbox_anim.geometry)
  local overlap   = 5
  local balloon_x = (math.max(bw, tw) - bw) / 2
  local box_x     = (math.max(bw, tw) - tw) / 2
  local box_y     = bh - overlap

  return {
    geometry = {math.max(bw, tw), bh + th - overlap},
    draw = function(score, phase)
      local b = widget_balloon(shallow_merge(balloon_style, { text=tostring(score or "") }))
      gfx.push("all")
      gfx.translate(balloon_x, 0); b.draw()
      gfx.pop()
      gfx.push("all")
      gfx.translate(box_x, box_y); textbox_anim.draw(phase or 0)
      gfx.pop()
    end,
  }
end

