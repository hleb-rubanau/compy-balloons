require("config")
require("challenges")
require("constants")
require("graphics")
require("variables")

function current_bonus()
  return ANSWER_TIMEOUT - math.floor(time)
end

function reset_counters()
  counters.win = 0
  counters.loss = 0
  counters.score = 0
  current_result_number = 0
end

function reset_challenge()
  current_question = current_challenge.question
  current_answer = nil
  current_answer_valid = false
  current_x = get_random_x()
  current_y = 0
  time = 0
  current_result_number = current_result_number + 1
  drawWaitingResult(current_result_number)
  draw_waiting()
end

function gameOver()
  on_update = nil
  local tmpl = "Your score: %s (%s/%s)\nClick to restart"
  local c = counters
  local msg = fmt(tmpl, c.score, c.win, c.win + c.loss)
  drawSplash(msg)
  on_click = startGame
end

function startChallenge()
  current_challenge = next_challenge()
  if not current_challenge then
    return gameOver()
  end
  reset_challenge()
  on_update = wait_for_input
end

function startGame()
  on_click = nil
  next_challenge = challenges()
  reset_counters()
  drawBackground()
  drawScore(0)
  drawPendingResults()
  startChallenge()
end

function on_valid_answer()
  counters.win = counters.win + 1
  local bonus = current_bonus()
  counters.score = counters.score + bonus
  drawScore(counters.score)
  drawSuccessfulResult(current_result_number, bonus)
  drawFieldBackground()
  drawProperAnswer(current_question, current_answer, bonus)
  sfx.wow()
  wait_time = 0
  on_update = wait_before_next
end

function on_input(txt)
  if current_challenge then
    if current_answer_valid then
      return 
    end
    current_answer = txt
    current_answer_valid = (txt == current_challenge.answer)
    if current_answer_valid then
      return on_valid_answer()
    end
  end
end

function draw_waiting()
  next_redraw = time + (1 / FPS)
  drawFieldBackground()
  local bonus = current_bonus()
  local q = current_question
  if not current_answer then
    return drawQuestion(q, bonus)
  end
  drawWrongAnswer(q, current_answer, bonus)
end

function wait_before_next(dt)
  wait_time = wait_time + dt
  if WIN_DELAY < wait_time then
    startChallenge()
  end
end

function on_timeout()
  counters.loss = counters.loss + 1
  drawFailedResult(current_result_number)
  sfx.boom()
  startChallenge()
end

function wait_for_input(dt)
  time = time + dt
  if ANSWER_TIMEOUT < time then
    return on_timeout()
  end
  if next_redraw < time then
    current_y = field_height * (time / ANSWER_TIMEOUT)
    draw_waiting()
  end
  check_input()
end

function check_input()
  if userinp:is_empty() then
    input_text()
  else
    on_input(userinp())
  end
end

function love.update(dt)
  if on_update then
    on_update(dt)
  end
end

function love.singleclick()
  if on_click then
    on_click()
  end
end

function init()
  userinp = user_input()
  drawSplash("Click to start")
  on_click = startGame
end

init()
