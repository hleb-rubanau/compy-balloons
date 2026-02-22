require("config")
require("constants")
require("graphics")
require("debugfunc")

function init()
  -- activate user input
  time = 0
  userinp=user_input()
  love.update = check_input
  drawBackground()

  local qx = get_random_x()
  local qy = get_random_x() / 10

  logdebug("qx=%s, qy=%s", qx, qy)
  drawQuestionObject(qx, qy, "Giraf..e: ")
end

function on_input(txt)
  print( fmt("INPUT: %s", txt) )
end

function check_input()
  if userinp:is_empty() then
    input_text()
  else
    on_input( userinp() )
  end
end

init()
