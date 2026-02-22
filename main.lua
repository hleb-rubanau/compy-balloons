require("config")
require("constants")
require("graphics")
require("challenges")
require("variables")
require("debugfunc")

function gameOver()
  local tmpl = "Your score: %s\nClick to restart"
  local msg = fmt(tmpl, counters.score)
  drawSplash(msg)
  on_click = startGame
  on_update = nil
end

function startChallenge()
  current_challenge = next_challenge()  
  if not current_challenge then
    return gameOver()
  end
  current_result_number = current_result_number + 1
  current_question = current_challenge.question
  current_answer = nil
  current_answer_valid = false
  current_x = get_random_x()
  current_y = 0
  time = 0
  drawWaitingResult(current_result_number)
  redraw()
end

function reset_counters()
  counters.win=0
  counters.loss=0
  counters.score=0
  current_result_number=0
end

function startGame()
  on_click = nil
  next_challenge = challenges()
  reset_counters()
  drawPendingResults()
  drawScore(0)
  startChallenge()
  on_update = on_tick
end


function on_valid_answer()
  counters.win = counters.win + 1
  local bonus = (ANSWER_TIMEOUT - math.floor(time))
  counters.score = counters.score + bonus
  drawScore(counters.score)
  drawSuccessfulResult(current_result_number, bonus)
  sfx.wow()
  wait_time = 0
  redraw()
end

function on_input(txt)
  logdebug("ANSWER: %s", txt)
  if current_challenge then
    if current_answer_valid then
      return 
    end
    current_answer = txt
    current_answer_valid = (txt==current_challenge.answer)
    if current_answer_valid then
      return on_valid_answer()
    end
  end
end

function redraw()
  next_redraw = time + (1/FPS)
  drawFieldBackground()
  drawQuestion( current_question, current_answer, current_answer_valid )
end

function wait_before_next(dt) 
  wait_time = wait_time+dt
  if wait_time > WIN_DELAY then
    startChallenge()
  end
end

function on_timeout()
  counters.loss = counters.loss + 1
  drawFailedResult(current_result_number)
  sfx.boom()
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

function love.update(dt)
  if on_tick then
    --on_tick(dt)
    safe_exec(on_tick,dt)
  end
end

function love.singleclick()
  if on_click then
    --on_click()
    safe_exec( on_click )
  end
end

function init()
  userinp=user_input()
  drawSplash('Click to start')
  on_click = startGame
end

safe_exec(init)
