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
  current_question = current_challenge.question
  current_answer = nil
  current_answer_valid = false
  current_x = get_random_x()
  current_y = 0
  time = 0
  redraw()
end

function reset_counters()
  counters.win=0
  counters.loss=0
  counters.bonus=0
end

function startGame()
  next_challenge = challenges()
  reset_counters()
  --drawBackground()
  --drawCounters()
  startChallenge()
  on_click = nil
  on_update = on_tick
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

function love.update(dt)
  if on_tick then
  end
end

function love.singleclick()
  if on_click then
    on_click()
  end
end

function init()
  userinp=user_input()
  drawSplash('Click to start')
  on_click = startGame
end

safe_exec(init)
