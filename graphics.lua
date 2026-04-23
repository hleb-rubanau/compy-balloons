require("config")
require("constants")

gfx = love.graphics

-- principle -- every function returns a table with two fields:
-- {
--    'geometry' = {w, h} -- calculated width, height
--    'draw' -- function that uses gfx primitives to actually draw requested widget when invoked
-- }
--
-- all drawing must assume coordinates (0,0) (calling code takes care of gfx.translate()/.push()/.pop() if needed)

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local function get_opt(opts, key, default)
  if opts and opts[key] ~= nil then return opts[key] end
  return default
end

-- Resolve a font from opts or FONTS table.
-- key examples: "font", "font1", "font2"
local function resolve_font(opts, key)
  if opts and opts[key] then return opts[key] end
  if FONTS and FONTS[key] then return FONTS[key] end
  if FONTS and FONTS.default then return FONTS.default end
  return gfx.getFont()
end

-- Resolve a color from opts or COLORS table.
local function resolve_color(opts, key)
  if opts and opts[key] then return opts[key] end
  if COLORS and COLORS[key] then return COLORS[key] end
  if COLORS and COLORS.default then return COLORS.default end
  return {1, 1, 1, 1}
end

-------------------------------------------------------------------------------
-- widget_box
-- Draws a rounded rectangle 'box' with a colored border and label background.
-- The box encloses a label area of (label_w x label_h).
-- Padding is added around the label area.
-- Returns {geometry={w,h}, draw=fn}
-------------------------------------------------------------------------------
function widget_box(label_w, label_h, opts)
  local border_color   = resolve_color(opts, "border_color")
  local bg_color       = resolve_color(opts, "bg_color")
  local label_color    = resolve_color(opts, "label_color")
  local border_width   = get_opt(opts, "border_width", 2)
  local corner_radius  = get_opt(opts, "corner_radius", 6)

  -- padding: at least 0.25 * label_h
  local pad = math.max(get_opt(opts, "padding", label_h * 0.35), label_h * 0.25)

  local total_w = label_w + pad * 2
  local total_h = label_h + pad * 2

  local function draw()
    gfx.push()
    -- Background fill
    gfx.setColor(bg_color)
    gfx.rectangle("fill", 0, 0, total_w, total_h, corner_radius, corner_radius)

    -- Border
    gfx.setColor(border_color)
    gfx.setLineWidth(border_width)
    gfx.rectangle("line", 0, 0, total_w, total_h, corner_radius, corner_radius)

    -- Label
    gfx.setColor(label_color)
    gfx.rectangle("fill", pad, pad, label_w, label_h)
    
    -- Reset
    gfx.pop()
  end

  return {
    geometry = {total_w, total_h},
    draw     = draw,
    content_pos = { pad, pad }
  }
end

-------------------------------------------------------------------------------
-- widget_textbox
-- Draws a box with one or more text strings inside it.
-- config fields:
--   config.direction  = "horizontal" | "vertical" (default "vertical")
--   config.align      = "left" | "center" | "right" (default "center")
--   config.fonts      = { font1, font2, ... }  (or single font)
--   config.colors     = { color1, color2, ... } (or single color)
--   ... plus all widget_box opts (border_color, bg_color, etc.)
-- ...texts  = sequence of strings
-------------------------------------------------------------------------------
function widget_textbox(config, ...)
  local texts = {...}
  local n = #texts
  assert(n >= 1, "widget_textbox: at least one text required")

  local direction = get_opt(config, "direction", "vertical")
  local align     = get_opt(config, "align", "center")

  -- Resolve per-text fonts and colors
  local fonts  = {}
  local colors = {}
  for i = 1, n do
    fonts[i]  = resolve_font(config.fonts, i)
    colors[i] = resolve_color(config.colors, i)
  end

  -- Measure each text
  local text_ws = {}
  local text_hs = {}
  for i, txt in ipairs(texts) do
    local f = fonts[i]
    text_ws[i] = f:getWidth(txt)
    text_hs[i] = f:getHeight()
  end

  -- Calculate label area
  local label_w, label_h
  local h_pad_factor = 0.5  -- half line-height horizontal padding
  local v_pad_factor = 0.5  -- half line-height vertical padding

  if direction == "horizontal" then
    -- Height = max text height * 2
    local max_h = 0
    for _, h in ipairs(text_hs) do max_h = math.max(max_h, h) end
    label_h = max_h * 2

    -- Width = sum of text widths + (n-1) gaps of half-line-height + outer h-pads
    local gap = max_h * h_pad_factor
    local sum_w = 0
    for _, w in ipairs(text_ws) do sum_w = sum_w + w end
    label_w = sum_w + (n - 1) * gap
  else
    -- Vertical stacking
    -- Height = sum of heights + (n+1) * half-line-height gaps
    local sum_h = 0
    local max_h = 0
    for _, h in ipairs(text_hs) do
      sum_h = sum_h + h
      max_h = math.max(max_h, h)
    end
    label_h = sum_h + n * (max_h * v_pad_factor)

    -- Width = max text width (outer padding added by widget_box)
    local max_w = 0
    for _, w in ipairs(text_ws) do max_w = math.max(max_w, w) end
    label_w = max_w
  end

  -- Build the box
  local box = widget_box(label_w, label_h, config)

  local function draw()
    gfx.push("all")
    -- Draw the box background/border
    box.draw()

    -- Now draw text(s) inside, offset by padding
    gfx.translate(unpack(box.content_pos))

    if direction == "horizontal" then
      local max_h = 0
      for _, h in ipairs(text_hs) do max_h = math.max(max_h, h) end
      local gap = max_h * h_pad_factor

      local x_cursor = 0
      for i, txt in ipairs(texts) do
        local f = fonts[i]
        local c = colors[i]
        gfx.setFont(f)
        gfx.setColor(c)
        -- Vertically center each text within label_h
        local ty = (label_h - text_hs[i]) / 2
        gfx.print(txt, x_cursor, ty)
        x_cursor = x_cursor + text_ws[i] + gap
      end
    else
      -- Vertical stacking
      local max_h = 0
      for _, h in ipairs(text_hs) do max_h = math.max(max_h, h) end
      local v_gap = max_h * v_pad_factor

      local y_cursor = v_gap / 2
      for i, txt in ipairs(texts) do
        local f = fonts[i]
        local c = colors[i]
        gfx.setFont(f)
        gfx.setColor(c)

        local tx
        if align == "center" then
          tx = (label_w - text_ws[i]) / 2
        elseif align == "right" then
          tx = label_w - text_ws[i]
        else
          tx = 0
        end
        gfx.print(txt, tx, y_cursor)
        y_cursor = y_cursor + text_hs[i] + v_gap
      end
    end

    gfx.pop()
  end

  return {
    geometry = box.geometry,
    draw     = draw,
  }
end

-------------------------------------------------------------------------------
-- widget_baloon
-- Draws a balloon (ellipse body, nub, string, highlight).
-- opts fields:
--   opts.size        = 1|2|3 -> scale factor multiplier (default 1)
--   opts.fill_color  = {r,g,b,a}
--   opts.line_color  = {r,g,b,a}
--   opts.nub_color   = {r,g,b,a}  (defaults to line_color)
--   opts.text        = string (optional label on balloon)
--   opts.text_color  = {r,g,b,a}
--   opts.font        = love font
-- Returns {geometry={w,h}, draw=fn}
-------------------------------------------------------------------------------
function widget_baloon(opts)
  opts = opts or {}

  -- Size -> scale
  local size_scales = {[1]=1.0, [2]=1.5, [3]=2.0}
  local size  = get_opt(opts, "size", 1)
  local scale = size_scales[size] or 1.0

  -- Base balloon dimensions (matching the prototype)
  local base_rx  = 80
  local base_ry  = 80
  local base_nubW = 10
  local base_nubH = 16
  local base_strL = 40

  local rx   = base_rx   * scale
  local ry   = base_ry   * scale
  local nubW = base_nubW * scale
  local nubH = base_nubH * scale
  local strL = base_strL * scale

  -- Colors
  local fill_color = get_opt(opts, "fill_color", {0.90, 0.22, 0.27, 1})
  local line_color = get_opt(opts, "line_color", {0.76, 0.07, 0.12, 1})
  local nub_color  = get_opt(opts, "nub_color",  line_color)
  local str_color  = get_opt(opts, "str_color",  {0.6, 0.6, 0.6, 1})
  local hi_color   = get_opt(opts, "hi_color",   {1, 1, 1, 0.4})

  -- Optional text
  local text       = get_opt(opts, "text", nil)
  local text_color = get_opt(opts, "text_color", {1, 1, 1, 1})
  local font       = get_opt(opts, "font", nil) or (FONTS and FONTS.balloon) or gfx.getFont()

  -- Total geometry: the balloon sits with its center at (rx, ry) from top-left
  -- so total width = 2*rx, total height = 2*ry + nubH + strL
  local total_w = rx * 2
  local total_h = ry * 2 + nubH + strL

  -- Center of ellipse in local coords
  local cx = rx
  local cy = ry

  local function draw()
    gfx.push("all")
    -- Body fill
    gfx.setColor(fill_color)
    gfx.ellipse("fill", cx, cy, rx, ry)

    -- Body outline
    gfx.setColor(line_color)
    gfx.setLineWidth(2 * scale)
    gfx.ellipse("line", cx, cy, rx, ry)

    -- Nub
    local nubTop = cy + ry
    gfx.setColor(nub_color)
    gfx.polygon("fill",
      cx - nubW, nubTop,
      cx + nubW, nubTop,
      cx,        nubTop + nubH
    )

    -- String
    gfx.setColor(str_color)
    gfx.setLineWidth(1)
    gfx.line(
      cx,     nubTop + nubH,
      cx + 5, nubTop + nubH + strL * 0.4,
      cx - 4, nubTop + nubH + strL * 0.7,
      cx,     nubTop + nubH + strL
    )

    -- Highlight
    gfx.setColor(hi_color)
    gfx.push("all")
    gfx.translate(cx - 18 * scale, cy - 13 * scale)
    gfx.rotate(-math.pi / 5)
    gfx.ellipse("fill", 0, 0, rx * 0.22, ry * 0.14)
    gfx.pop()

    -- Optional text on the balloon body (centered)
    if text then
      gfx.setFont(font)
      local tw = font:getWidth(text)
      local th = font:getHeight()
      gfx.setColor(1,1,1,1)
      gfx.ellipse("fill", cx, cy, tw*0.75, th*0.75)
      gfx.setColor(text_color)
      gfx.print(text, cx - tw / 2, cy - th / 2)
    end

    gfx.pop()
  end

  return {
    geometry = {total_w, total_h},
    draw     = draw,
  }
end


-------------------------------------------------------------------------------
-- widget_animation
-- Takes N pre-built widget tables (each with .geometry and .draw).
-- Returns a widget-like table with:
--   .geometry    = {w, h}  -- bounding box of all frames
--   .length      = N       -- number of frames (animation "steps")
--   .draw(phase) = fn      -- phase in [0..1], selects and draws the right frame
--
-- Frame selection: n = clamp(round(phase * (N-1)) + 1, 1, N)
-------------------------------------------------------------------------------
function widget_animation(...)
  local frames = {...}
  local N = #frames
  assert(N >= 1, "widget_animation: at least one frame required")

  -- Bounding geometry: max width and max height across all frames
  local max_w, max_h = 0, 0
  for _, frame in ipairs(frames) do
    local fw = frame.geometry[1]
    local fh = frame.geometry[2]
    if fw > max_w then max_w = fw end
    if fh > max_h then max_h = fh end
  end

  local function draw(phase)
    -- Clamp phase to [0, 1]
    phase = math.max(0, math.min(1, phase or 0))  -- clamps: 1.7 -> 1.0

    -- Map phase -> 1-based frame index
    local n = math.floor(phase * (N - 1) + 0.5) + 1
    n = math.max(1, math.min(N, n))

    return frames[n].draw()
    -- local frame = frames[n]

    -- Center the frame within the bounding box if it's smaller
    local fw = frame.geometry[1]
    local fh = frame.geometry[2]
    local ox = math.floor((max_w - fw) / 2)
    local oy = math.floor((max_h - fh) / 2)

    if ox ~= 0 or oy ~= 0 then
      gfx.push()
      gfx.translate(ox, oy)
      frame.draw()
      gfx.pop()
    else
      frame.draw()
    end
  end

  return {
    geometry = {max_w, max_h},
    length   = N,
    draw     = draw,
  }
end

function widget_animation_loop(...)
  local single_animation = widget_animation(...)
  local result = { }
  for k,v in ipairs(single_animation) do
      result[k] = v
  end
  result.draw = function(phase,...) 
    phase = phase % 1  -- wraps: 1.7 -> 0.7, 3.0 -> 0.0
    single_animation.draw(phase, ...)
  end 
  return result
end

-------------------------------------------------------------------------------
-- widget_challenge
-- Displays a balloon (with score) above a textbox (question + answer).
-- opts fields:
--   question, answer, score  = strings
--   size   = 1|2|3  (balloon size)
--   color  = fill_color for balloon (shorthand)
--   ... any other opts forwarded to widget_baloon and widget_textbox
-------------------------------------------------------------------------------
function widget_challenge(opts)
  opts = opts or {}

  local question = get_opt(opts, "question", "?")
  local answer   = get_opt(opts, "answer",   "")
  local score    = tostring(get_opt(opts, "score", 0))
  local size     = get_opt(opts, "size", 1)

  -- Allow shorthand 'color' to set balloon fill
  local balloon_opts = {
    size       = size,
    fill_color = get_opt(opts, "color", get_opt(opts, "fill_color", nil)),
    line_color = get_opt(opts, "line_color", nil),
    text       = score,
    text_color = get_opt(opts, "score_color", {1, 1, 1, 1}),
    font       = get_opt(opts, "score_font", nil),
  }

  -- Textbox config inherits relevant opts
  local textbox_config = {
    direction    = "vertical",
    align        = "center",
    border_color = get_opt(opts, "box_border_color", get_opt(opts, "color", {0.3, 0.3, 0.3, 1})),
    bg_color     = get_opt(opts, "box_bg_color",     {0.1, 0.1, 0.1, 0.85}),
    fonts        = { get_opt(opts, "question_font",    nil),
                     get_opt(opts, "answer_font",      nil),
                   },
    colors       = {
                    get_opt(opts, "question_color",   {1, 1, 1, 1}),
                    get_opt(opts, "answer_color",     {0.8, 0.9, 0.5, 1})
                   }
  }

  local balloon_widget  = widget_baloon(balloon_opts)
  local textbox_widget_qa  = widget_textbox(textbox_config, question, answer)
  local textbox_widget_q  = widget_textbox(textbox_config, question)
  local noop_widget = { geometry: {0,0}, draw: function() end }

  local bw, bh = balloon_widget.geometry[1], balloon_widget.geometry[2]
  local tw, th = textbox_widget_qa.geometry[1], textbox_widget_qa.geometry[2]
  local overlap = 5

  -- TODO: in fact I want three variants of display (maybe more)
  --       initial: baloon + question
  --       interim: baloon + answer
  --       final: baloon only
  -- and maybe (maybe-maybe), there will be some animation across widgets between 2 and 3
  -- and we intentinally use them in a single widget because
  --    a) baloon is the same
  --    b) external geometry is the same (hitbox of biggest widget)
  local frames = {
    textbox_widget_q,
    textbox_widget_qa,
    noop_widget
  }

  -- Layout: balloon centered above textbox
  local total_w = math.max(bw, tw)
  local total_h = bh + th - overlap

  local balloon_x = (total_w - bw) / 2
  local balloon_y = 0

  local textbox_x = (total_w - tw) / 2
  local textbox_y = (bh - overlap)

  local function draw(score, phase)
    if phase=~nil then
      phase = 0
    end
    -- Draw balloon
    gfx.push("all")
    gfx.translate(balloon_x, baloon_y)
    balloon_widget.draw(score)
    gfx.pop()

    -- Draw textbox below balloon
    gfx.push("all")
    gfx.translate(textbox_x, textbox_y)
    textbox_widget.draw()
    gfx.pop()
  end

  return {
    geometry = {total_w, total_h},
    draw     = draw,
  }
end


