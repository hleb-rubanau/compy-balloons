require("config")
require("constants")
require("math")
require("os")

-- Field utility.
function get_random_x()
  math.randomseed(os.time())
  return math.random(field_width * 0.9)
end

function calc_text_geometry(font, txt)
  return font:getWidth(txt), font:getHeight()
end

function font_h(name)
  return fonts[name]:getHeight()
end

function max_string_width(strings, font)
  local max_width = 0
  for _, s in ipairs(strings) do
    local w = font:getWidth(s)
    if max_width < w then
      max_width = w
    end
  end
  return max_width
end

function calc_splashbox_geometry(lines, font)
  local fh = font:getHeight()
  local bw = max_string_width(lines, font)
  local bx = (screen_width - bw) / 2
  local bh = #lines * fh + (#lines - 1) * 0.5 * fh
  local by = (field_height - bh) / 2
  return bx, by, bw, bh
end

function text_background_geometry(qw, qh, aw, ah)
  local th = math.max(qh, ah)
  local full_height = 2 * th
  local full_width = qh / 2 + qw + th / 2 + aw + ah / 2
  return full_width, full_height
end

function question_text_position(bh, qh)
  return qh / 2, bh / 2 - qh / 2
end

function answer_text_position(bh, ah, qh, qw)
  local th = math.max(qh, ah)
  return qh / 2 + qw + th / 2, bh / 2 - ah / 2
end

function label_text_positions(bh, qh, qw, ah)
  local qx, qy = question_text_position(bh, qh)
  local ax, ay = answer_text_position(bh, ah, qh, qw)
  return qx, qy, ax, ay
end

function label_text_geometries(question, answer)
  local qw, qh = calc_text_geometry(fonts.question, question)
  local aw, ah = calc_text_geometry(fonts.answer, answer)
  return qw, qh, aw, ah
end

function adjust_x(x, leftmost, rightmost)
  local dx = x - rightmost
  if 0 < dx then
    x = x - 2 * dx
  end
  dx = leftmost - x
  if 0 < dx then
    x = x + 2 * dx
  end
  return x
end
