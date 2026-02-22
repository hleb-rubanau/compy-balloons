require("config")
require("constants")
require("graphics")
require("challenges")
require("variables")
require("debugfunc")

function startChallenge()
  current_challenge = next_challenge()  
  current_question = current_challenge.question
  current_answer = nil
  current_answer_valid = false
  current_x = get_random_x()
  current_y = 0
  if not current_challenge then
    return startGame()
  end
  redraw()
end

function startGame()
  next_challenge = challenges()
  current_challenge = nil
  time = 0
  counters.win=0
  counters.loss=0
  counters.bonus=0
  drawBackground()
  drawCounters()
  startChallenge()
end

function init()
  startGame()
  -- activate user input
  userinp=user_input()
  love.update = on_tick
end

function on_valid_answer()
  counters.win = counters.win + 1
  counters.bonus = counters.bonus + (ANSWER_TIMEOUT - math.floor(time))
  drawCounters()
  sfx.wow()
  wait_time = 0
  redraw()
end

function on_input(txt)
  if current_challenge then
    if current_answer_valid then
      return 
    end
    curret_answer = txt
    current_answer_valid = (txt==current_challenge.answer)
    if current_answer_valid then
      return on_valid_answer()
    end
  end
end

function redraw()
  next_redraw = time + (1/FPS)
  drawBackground()
  drawQuestion( current_question, current_answer, current_answer_valid )
  drawTime(math.floor(time))
  drawCounters()
end

function wait_before_next(dt) 
  wait_time = wait_time+dt
  if wait_time > WIN_DELAY then
    startChallenge()
  end
end

function on_timeout()
  counters.loss = counters.loss + 1
  sfx.boom()
  drawCounters()
  startChallenge()
end

function on_tick(dt)
  if current_challenge then
    if current_answer_valid then
      return wait_before_next(dt)
    end
    time = time+dt
    if time > ANSWER_TIMEOUT then
      return on_timeout()
    end 
    if time > next_redraw then
      current_y = field_height * (time / ANSWER_TIMEOUT)
      redraw()
    end
    check_input()
  end
end

function check_input()
  if userinp:is_empty() then
    input_text()
  else
    on_input( userinp() )
  end
end

safe_exec(init)
