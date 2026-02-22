require("config")
require("constants")
require("graphics")
require("debug")

function init()
  -- activate user input
  time = 0
  userinp=user_input()
  drawBackground()
end


function on_input(txt)
  print( fmt("INPUT: %s", txt) )
end

function do_it()
  if userinp:is_empty() then
    input_text()
  else
    on_input( userinp() )
  end
end

function love.update(dt)
  do_it()
  safe_exec( do_it )
end
