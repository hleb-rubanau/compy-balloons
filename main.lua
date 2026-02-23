require("config")
require("challenges")
require("constants")
require("graphics")
require("variables")
require("debugfunc")

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
  results[current_result_number] = drawWaitingResult
  input_text("Your answer: ", nil)
  challenge_renderer = waiting_renderer(current_question)
end

function gameOverSplash(score, win, loss)
  local tmpl = "Your score: %s (%s/%s)\nClick to restart"
  local msg = fmt(tmpl, score, win, win + loss)
  return function()
    drawSplash(msg)
  end
end

function gameOver()
  on_update = nil
  on_draw = gameOverSplash(score, win, loss)
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

function reset_results()
  reset_counters()
  for i, _ in ipairs(CHALLENGES) do
    results[i] = drawPendingResult
  end
end

function draw_result_ok(bonus)
  return function(n)
    drawSuccessfulResult(n, bonus)
  end
end

function drawResults()
  for i, r in ipairs(results) do
    r(i)
  end
end

function startGame()
  on_click = nil
  next_challenge = challenges()
  reset_results()
  startChallenge()
  on_draw = drawGameActive
end

function wrong_renderer(q, a)
  return function(bonus)
    drawQuestion(q, a, bonus)
  end
end

function waiting_renderer(q)
  return function(bonus)
    drawQuestion(q, bonus)
  end
end

function valid_renderer(q, a, bonus_size)
  return function()
    drawProperAnswer(q, a, bonus_size)
  end
end

function drawGameActive()
  drawFieldBackground()
  drawScore(counters.score)
  drawResults()
  if challenge_renderer then
    local b = safe_exec(current_bonus)
    safe_exec(challenge_renderer, b)
    --local b = current_bonus()
    --challenge_renderer( b )
    --challenge_renderer( current_bonus() )
  end
end

function on_valid_answer()
  counters.win = counters.win + 1
  local bonus = current_bonus()
  counters.score = counters.score + bonus
  challenge_renderer = success_renderer( bonus )
  local rn = current_challenge_number 
  results[ rn ] = draw_result_ok( bonus )
  wait_time = 0
  on_update = wait_before_next
end

function on_input(txt)
  if current_challenge then
    if current_answer_valid then
      return 
    end
    safe_exec(input_text,txt)
    current_answer = txt
    current_answer_valid = (txt == current_challenge.answer)
    local q = current_question
    if current_answer_valid then
      current_challenge_renderer = valid_renderer(q, txt)
      return on_valid_answer()
    end
    current_challenge_renderer = wrong_renderer(q, txt)
  end
end

function wait_before_next(dt)
  wait_time = wait_time + dt
  if WIN_DELAY < wait_time then
    challenge_renderer = nil
    startChallenge()
  end
end

function on_timeout()
  counters.loss = counters.loss + 1
  results[current_result_number] = drawFailedResult
  sfx.boom()
  startChallenge()
end

function wait_for_input(dt)
  time = time + dt
  if ANSWER_TIMEOUT < time then
    return on_timeout()
  end
  current_y = field_height * (time / ANSWER_TIMEOUT)
  check_input()
end

function drawGameReady()
  drawSplash("Click to start")
end

function check_input()
  if not userinp:is_empty() then
    local txt = userinp()
    input_text("Your answer: "..txt, nil)
    on_input(txt)
  end
end

function love.draw()
  if on_draw then
    on_draw()
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
  --drawSplash("Click to start")
  reset_counters()
  on_draw = drawGameReady
  on_click = startGame
  on_update = nil
end

init()
