
function logdebug(...)
  if love.DEBUG then
    local args = {...}
    local msg = #args == 1 and args[1] or string.format(...)
    print(msg)
  end
end

function inspect(tname, t)
  logdebug("TABLE: %s", tname)
  for k,v in ipairs(t) do
    logdebug("\t%s[%s]: %s", tname, tostring(k), tostring(v))
  end 
end

function safe_exec(func, ...)
    local args = {...}
    
    local status, result = xpcall(
        function()
            return func(unpack(args))
        end,
        function(err)
            -- Capture full stack trace
            local trace = debug.traceback(tostring(err), 2)
            logdebug("Error occurred during execution:")
            logdebug(trace)
            return trace
        end
    )
    
    if not status then
        error(result, 0)  -- Re-raise with preserved stack trace
    end
    
    return result
end

function safe_exec_multi(func, ...)
    local args = {...}
    
    local results = table.pack(xpcall(
        function()
            return func(unpack(args))
        end,
        function(err)
            local trace = debug.traceback(tostring(err), 2)
            logdebug("Error occurred during execution:")
            logdebug(trace)
            return trace
        end
    ))
    
    local status = table.remove(results, 1)
    
    if not status then
        error(results[1], 0)
    end
    
    return unpack(results, 1, results.n)
end

function debug_state(event, source)
  local score, wins, total = get_game_results()
  local losses = count_losses()
  local is_over = game_is_over()
  logdebug("%s: %s (score=%s, wins=%s, losses=%s, over=%s)", event, source, score, wins, losses, is_over)
end
