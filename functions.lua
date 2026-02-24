function count(iterator)
  local c = 0 
  for _ in iterator() do
    c = c + 1
  end
  return c
end

function sum(iterator)
  local s = 0
  for x in iterator() do  
    s = s + x
  end
  return s
end

function values(t) 
  local i, iterator = 0, nil
  function iterator()
    i = i + 1
    if i>#t then
      return nil
    end
    if t[i] ~= nil then
        return t[i]
    end
    return iterator()
  end 
  return iterator
end

function for_each(scope, callback) 
  for item in scope do
    callback(item)
  end
end

function shuffle(list)
  math.randomseed(os.time())
  for i = #list, 2, -1 do
    local j = math.random(i)
    list[i], list[j] = list[j], list[i]
  end
end
