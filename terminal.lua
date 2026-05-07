require('helpers')

terminal = {
  inp = nil ,
  msg = nil,
  read = nil,
  write = nil,
  on_read = nil
}

function terminal_init(on_read)
  terminal.inp = user_input()
  terminal.write = terminal_write
  terminal.read = terminal_read
  terminal.on_read = on_read or noop
  return terminal 
end

function terminal_read()
  local t = terminal
  if not t.inp:is_empty() then
    local msg = t.inp()
    t.msg = msg
    t.on_read(msg)
    return msg
  end
end

function terminal_write(msg)
  input_text(msg, nil)
end
