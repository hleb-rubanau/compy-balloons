require("helpers")
require("debugfunc")

terminal = nil -- not initialied by default

function terminal_read(callback)
  callback = callback or noop
  if not terminal:is_empty() then
    local msg = terminal()
    callback(msg)
    return msg
  end
end

function terminal_write(msg, flushed)
  input_text(msg, nil)
end

function terminal_init()
  terminal = user_input()
  return {
    write = terminal_write,
    read = terminal_read,
  }
end
