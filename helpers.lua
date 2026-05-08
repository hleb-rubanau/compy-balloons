fmt = string.format

function noop() 
  -- literally does nothing
end

function action_map(t)
  return setmetatable(t, { __index = function() return noop end })
end

function on_text_match(text, fn, ...)
  return function(txt)
    if txt==text then
      return fn(...)
    end
  end
end

function shallow_merge(a, b)
  local out = {}
  for k, v in pairs(a) do out[k] = v end
  if b then for k, v in pairs(b) do out[k] = v end end
  return out
end

function partial_reset(target, src)
  for k, v in pairs(src) do
    target[k]=v
  end
end

function map(src, fn)
  local result = { }
  for k, v in pairs(src) do
    result[k] = fn(v)
  end
  return result
end
