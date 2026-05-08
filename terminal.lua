require('helpers')

terminal = user_input()

function terminal_read(callback)
  local t = terminal
  callback = callback or noop
  if not t.inp:is_empty() then
    local msg = t.inp()
    t.msg = msg
    callback(msg)
    return msg
  end
end

function terminal_write(msg)
  input_text(msg, nil)
end

function terminal_init()
  return { 
    write = terminal_write,
    read = terminal_read
  }
end
