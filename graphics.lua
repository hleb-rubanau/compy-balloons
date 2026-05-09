require("config")
require("helpers")

gfx = love.graphics
default_opacity = 1.0
-- allows using predefined colors with dynamic opacity
function setColor(c, a)
  gfx.setColor(c[1], c[2], c[3], (a or default_opacity))
end

-- Every function returns { geometry={w,h}, draw=fn }
-- All drawing assumes local (0,0). Callers handle translate/push/pop.

-------------------------------------------------------------------------------
-- Presets
-------------------------------------------------------------------------------

STYLES = {
  field_background = {
    color = COLORS.silver,
  },
  status_bar = {
    color = COLORS.denim,
    font = FONTS.default,
    padding = 10,
    align = "right",
  },
  splash_background = {
    color = COLORS.denim,
  },
  splash_header = {
    font = FONTS.h1,
    color = COLORS.yellow,
  },
  splash_subheader = {
    font = FONTS.h3,
    color = COLORS.yellow,
  },
  splash_hint = {
    font = FONTS.h5,
    color = COLORS.white,
  },
  question = {
    font = FONTS.h5,
    color = COLORS.yellow,
  },
  answer = {
    font = FONTS.h4,
    color = COLORS.green
  },
  box = {
    bg_color = COLORS.obsidian, -- 0.90
    border_color = COLORS.metallic,
    border_width = 2,
    corner_radius = 6,
    padding = nil, -- nil → auto (0.35 × inner height)
  },
  balloon_label = {
    font = FONTS.h3,
    color = COLORS.black
  },
  card_highlight = {
    bg_color = COLORS.mocha, -- 0.92
    border_color = COLORS.gold, --{0.90, 0.70, 0.10, 1.00},
    border_width = 3,
    corner_radius = 8,
    padding = nil,
  },
  splash = {
    bg_color = COLORS.blue,
    font_color = COLORS.yellow,
  },
  splash_welcome_header = {
    font = FONTS.h2,
    color = COLORS.yellow,
  },
  splash_welcome_subheader = {
    font = FONTS.h3,
    color = COLORS.yellow,
  },
  splash_welcome_hint = {
    font = FONTS.h5,
    color = COLORS.white,
  },
  splash_gameover_header = {
    font = FONTS.h3,
    color = COLORS.white,
  },
  splash_gameover_stats = {
    font = FONTS.h3,
    color = COLORS.yellow,
  },
  splash_gameover_hint = {
    font = FONTS.h5,
    color = COLORS.white,
  },
}
  
BALLOON_STYLES = { 
  red = {
    fill_color = COLORS.crimson,
    line_color = COLORS.ruby,
    size = 1,
  },
  blue = {
    fill_color = COLORS.azure,
    line_color = COLORS.denim,
    size = 1,
  }
}

STYLE_ACTIONGS = {
  font = gfx.setFont,
  color = setColor, -- not gfx.setColor!
}

function apply_style(style)
  for k, v in pairs(style) do
    fn = STYLE_ACTIONGS[k] or noop
    fn(v)
  end
end

-------------------------------------------------------------------------------
-- widget_text_label
-- Single string with a font, color, and uniform padding on all sides.
-- style fields: font, color, padding (default: 0)
-- Returns { geometry={w,h}, draw=fn }
-------------------------------------------------------------------------------
function widget_text_label(text, style)
  local font = style.font or gfx.getFont()
  local padding = style.padding or 0

  local tw = font:getWidth(text)
  local th = font:getHeight()

  return {
    geometry = { tw + padding * 2, th + padding * 2 },
    draw = function(msg)
      -- we can alter the text withot changing geometry
      msg = msg or text
      gfx.push("all")
      apply_style(style)
      gfx.print(msg, padding, padding)
      gfx.pop()
    end,
  }
end

function widget_text_line(text, style, align, width)
  style = style or {}
  align = align or style.align or "center"
  local font = style.font or gfx.getFont()
  local padding = style.padding or 0

  local th = font:getHeight()
  local tw = (width or SCREEN_WIDTH) - padding * 2
  local wh = th + padding * 2
  return {
    geometry = { tw, th + padding * 2 },
    draw = function(msg)
      msg = msg or text
      gfx.push("all")
      apply_style(style)
      gfx.translate(0, -wh)
      gfx.printf(msg, padding, padding, tw, align)
      gfx.pop()
    end,
  }
end

function widget_text_multiline(text, ...)
  local styles = { ... }
  local widgets = {}
  local max_w, max_h = 0, 0
  for i, t in ipairs(text.split("\n")) do
    widgets[i] = widget_text_label(t, (styles[i] or styles[1]))
    local w, h = unpack(widgets[i].geometry)
    max_w = math.max(max_w, w)
    max_h = math.max(max_h, h)
  end

  return {
    geometry = { max_w, max_h },
    draw = function()
      local this_y = 0
      for i, w in pairs(widgets) do
        local this_x = (max_w - w.geometry[1]) / 2
        draw_at(this_x, this_y, w.draw)
        this_y = this_y + w.geometry[2]
      end
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
  local pad = style.padding or (math.min(inner_w, inner_h) * 0.25)
  local w = inner_w + pad * 2
  local h = inner_h + pad * 2
  local r = style.corner_radius or 0
  local b = style.border_width or 2

  return {
    geometry = { w, h },
    inner_pos = { pad, pad },
    draw = function()
      gfx.push("all")
      setColor(style.bg_color)
      gfx.rectangle("fill", 0, 0, w, h, r)
      setColor(style.border_color)
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
  local gap = style.gap or 12

  local inner_w = qw + gap + aw
  local inner_h = math.max(qh, ah)
  local box = widget_box(inner_w, inner_h, style)
  local ix, iy = unpack(box.inner_pos)

  return {
    geometry = box.geometry,
    draw = function()
      gfx.push("all")
      box.draw()
      gfx.translate(ix, iy)
      -- question: vertically centred
      gfx.push()
      gfx.translate(0, (inner_h - qh) / 2)
      question_label.draw()
      gfx.pop()
      -- answer: vertically centred, offset to the right
      gfx.push()
      gfx.translate(qw + gap, (inner_h - ah) / 2)
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
function widget_balloon(style, scale)
  local scale = scale or 1 -- need to pick from task

  local rx, ry = 40 * scale, 40 * scale
  local nubW = 10 * scale
  local nubH = 16 * scale
  local strL = 40 * scale

  local fill = style.fill_color or { 0.90, 0.22, 0.27, 1 }
  local line = style.line_color or { 0.76, 0.07, 0.12, 1 }
  local nub_c = style.nub_color or line
  local str_c = style.str_color or { 0.6, 0.6, 0.6, 1 }
  local hi_c = style.hi_color or { 1, 1, 1, 0.4 }
  --local text = style.text
  local tc =   STYLES.balloon_label.color
  local font = STYLES.balloon_label.font

  local cx, cy = rx, ry

  return {
    geometry = { rx * 2, ry * 2 + nubH + strL },
    draw = function(text)
      Log.debug(fmt("Draw text %s" , text))
      gfx.push("all")

      gfx.setColor(fill)
      gfx.ellipse("fill", cx, cy, rx, ry)
      gfx.setColor(line)
      gfx.setLineWidth(2 * scale)
      gfx.ellipse("line", cx, cy, rx, ry)

      local nubTop = cy + ry
      gfx.setColor(nub_c)
      gfx.polygon("fill", cx - nubW, nubTop, cx + nubW, nubTop, cx, nubTop + nubH)

      gfx.setColor(str_c)
      gfx.setLineWidth(1)
      gfx.line(
        cx,
        nubTop + nubH,
        cx + 5,
        nubTop + nubH + strL * 0.4,
        cx - 4,
        nubTop + nubH + strL * 0.7,
        cx,
        nubTop + nubH + strL
      )

      gfx.setColor(hi_c)
      gfx.push("all")
      gfx.translate(cx - 18 * scale, cy - 13 * scale)
      gfx.rotate(-math.pi / 5)
      gfx.ellipse("fill", 0, 0, rx * 0.22, ry * 0.14)
      gfx.pop()

      if text then
        gfx.setFont(font)
        local tw, th = font:getWidth(text), font:getHeight()
        --gfx.setColor(1, 1, 1, 1)
        --gfx.ellipse("fill", cx, cy, tw * 0.75, th * 0.75)
        gfx.setColor(tc)
        gfx.print(text, cx - tw / 2, cy - th / 2)
      end

      gfx.pop()
    end,
  }
end

-------------------------------------------------------------------------------
-- widget_animation / widget_animation_loop / widget_noop
-------------------------------------------------------------------------------

function widget_animation(...)
  local frames = { ... }
  local N = #frames
  assert(N >= 1, "widget_animation: need at least one frame")

  local max_w, max_h = 0, 0
  for _, f in ipairs(frames) do
    if f.geometry[1] > max_w then
      max_w = f.geometry[1]
    end
    if f.geometry[2] > max_h then
      max_h = f.geometry[2]
    end
  end

  return {
    geometry = { max_w, max_h },
    length = N,
    draw = function(phase)
      phase = math.max(0, math.min(1, phase or 0))
      local n = math.max(1, math.min(N, math.floor(phase * (N - 1) + 0.5) + 1))
      local f = frames[n]
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
    end,
  }
end

function widget_animation_loop(...)
  local anim = widget_animation(...)
  return {
    geometry = anim.geometry,
    length = anim.length,
    draw = function(phase, ...)
      anim.draw(phase % 1, ...)
    end,
  }
end

function widget_noop()
  return { geometry = { 0, 0 }, draw = function() end }
end

function widget_invisible(orig)
  return {
    geometry = orig.geometry,
    draw = function() end,
  }
end

function draw_at(x, y, fn, ...)
  gfx.push()
  gfx.translate(x, y)
  fn(...)
  gfx.pop()
end

function widget_with_dynamic_position(orig)
  return {
    geometry = orig.geometry,
    draw = function(x, y, ...)
      draw_at(x, y, orig.draw, ...)
    end,
  }
end

function widget_with_static_position(x, y, orig)
  return {
    geometry = orig.geometry,
    draw = function(...)
      draw_at(x, y, orig.draw, ...)
    end,
  }
end

-- syntactic sugar
renderer_at = widget_with_static_position

function widget_stack(...)
  local widgets = { ... }
  return {
    geometry = widgets[1].geometry,
    draw = function(...)
      for i, w in ipairs(widgets) do
        w.draw(...)
      end
    end,
  }
end

function widget_choice(maptable, default_key)
  if not default_key then
    default_key = "default"
  end
  return {
    geometry = maptable[default_key].geometry,
    draw = function(k, ...)
      if maptable[k] ~= nil and default_key then
        maptable[default_key].draw(...)
      else
        maptable[k].draw(...)
      end
    end,
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
function widget_challenge(question, answer, balloon_style, balloon_size)

  balloon_style = BALLOON_STYLES[balloon_style] or BALLOON_STYLES.red
  box_style = STYLES.card
  label_styles = { question = STYLES.question, answer = STYLES.answer }

  local q_label = widget_text_label(question, STYLES.question)
  local a_label = widget_text_label(answer, STYLES.answer) 

  local qa_box = widget_answered_box(q_label, a_label, STYLES.box)
  local q_box = widget_answered_box(q_label, widget_invisible(a_label), STYLES.box)

  local textbox_anim = widget_animation(q_box, qa_box, widget_invisible(qa_box))

  local w_balloon = widget_balloon(balloon_style, balloon_size)
  local bw, bh = unpack(w_balloon.geometry)
  local tw, th = unpack(textbox_anim.geometry)
  local overlap = 5
  local balloon_x = (math.max(bw, tw) - bw) / 2
  local box_x = (math.max(bw, tw) - tw) / 2
  local box_y = bh - overlap


  return {
    geometry = { math.max(bw, tw), bh + th - overlap },
    draw = function(score, phase)
      phase = phase or 0
      gfx.push("all")
      draw_at(balloon_x, 0, w_balloon.draw, score )

      default_opacity = 1.0 - math.min(1, phase)
      draw_at(box_x, box_y, textbox_anim.draw, (phase or 0))
      default_opacity = 1.0

      gfx.pop()
    end,
  }
end

function draw_background(color, x, y, w, h)
  gfx.push("all")
  gfx.setColor(color)
  gfx.rectangle("fill", x, y, w, h)
  gfx.pop()
end

-- enforces 'widget' format
function widget(w, h, draw, opts)
  local result = {
    geometry = { w, h },
    draw = draw,
  }
  return result
end

function widget_field()
  local w, h = FIELD_WIDTH, FIELD_HEIGHT
  local bgcolor = STYLES.field_background.color
  local draw = function()
    draw_background(bgcolor, 0, 0, w, h)
  end
  return widget(w, h, draw)
end

function widget_splash(m1, m2, m3, s1, s2, s3)
  local s1 = s1 or STYLES.splash_header
  local s2 = s2 or STYLES.splash_subheader
  local s3 = s3 or STYLES.splash_hint

  local t = widget_text_line
  local w1, w2, w3 = t(m1, s1), t(m2, s2), t(m3, s3)

  local wh = FIELD_HEIGHT
  local y1, y2, y3 = 0.3 * wh, 0.5 * wh, 0.8 * wh

  local draw = function(t1, t2, t3)
    gfx.push("all")
    apply_style(STYLES.splash_background)
    gfx.rectangle("fill", 0, 0, SCREEN_WIDTH, wh)
    draw_at(0, y1, w1.draw, t1)
    draw_at(0, y2, w2.draw, t2)
    draw_at(0, y3, w3.draw, t3)
    gfx.pop()
  end

  return widget(SCREEN_WIDTH, SCREEN_HEIGHT, draw)
end

function widget_splash_welcome()
  local header = WELCOME_MESSAGE
  local subheader = WELCOME_SUBHEADER
  local hint = SPLASH_HINT_START

  return widget_splash(header, subheader, hint)
end

function widget_splash_game_over()
  local header = GAME_OVER_HEADER
  local hint = SPLASH_HINT_RESTART
  local splash = widget_splash(header, nil, hint)

  return {
    geometry = splash.geometry,
    draw = function(stats)
      splash.draw(nil, stats, nil)
    end,
  }
end

function widget_status_bar()
  return widget_text_line("", STYLES.status_bar)
end
