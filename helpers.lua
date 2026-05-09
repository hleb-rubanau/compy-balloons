require("debugfunc")
fmt = string.format

function noop()
  -- literally does nothing
end

function action_map(t, fallback)
  fallback = fallback or noop
  return setmetatable(t, {
    __index = function()
      return fallback
    end,
  })
end

function shallow_merge(a, b)
  local out = {}
  for k, v in pairs(a) do
    out[k] = v
  end
  if b then
    for k, v in pairs(b) do
      out[k] = v
    end
  end
  return out
end

function partial_reset(target, src)
  for k, v in pairs(src) do
    target[k] = v
  end
end

function map(src, fn)
  local result = {}
  for k, v in pairs(src) do
    result[k] = fn(v)
  end
  return result
end

function shuffle(list)
  math.randomseed(os.time())
  inspect("shuffle before", list)
  for i = #list, 2, -1 do
    local j = math.random(i)
    list[i], list[j] = list[j], list[i]
  end
  inspect("shuffle after", list)
end
