require("config")
require("constants")
require("graphics")
require("debugfunc")

function drawRandomQuestion(x, y, txt, answer, valid)
  if answer then
    local answer_color = COLORS.answer_ok
    if not valid then  
      answer_color = COLORS.answer_fail
    end
    return drawQuestionObject(x, y, txt, answer, answer_color)
  end
  return drawQuestionObject(x, y, txt)
end

function drawSamples(txt, good, bad)
  local qx = get_random_x()
  local qy = get_random_x() / 10

  local qx2 = get_random_x()
  local qy2 = qy+100

  local qx3 = get_random_x()
  local qy3 = qy+200

  logdebug("(x1,y1)=(%s,%s); (x2,y2)=(%s,%s); (x3,y3)=(%s,%s)", qx, qy, qx2, qy2, qx3, qy3)
  
  drawRandomQuestion(qx, qy, txt)
  drawRandomQuestion(qx2, qy2, txt, bad, false)
  drawRandomQuestion(qx3, qy3, txt, good, true)
end

function init()
  -- activate user input
  time = 0
  userinp=user_input()
  love.update = check_input
  drawBackground()

  drawSamples("Print missing letter in 'giraf..e': ", "f", "y")
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

safe_exec(init)
