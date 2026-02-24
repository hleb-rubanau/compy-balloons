require("config")
require("challenges")
require("constants")
require("model")
require("graphics")
require("debugfunc")

positions = { }
render = {
  score = nil,
  progress = { },
  challenges = { }
}

callbacks = {
  click = nil,
  update = nil,
  draw = nil
}

terminal = user_input()

function callback(name)
  return function(...)
    if callbacks[name] then
      if love.DEBUG then 
        local c = callbacks[name]
        local args = { ... }
        safe_exec(c, unpack(args))
      else
        callbacks[name](...)
      end
    end
  end
end

function game_load()
  callbacks.click = game_start
  callbacks.update = nil
  callbacks.draw = splash(WELCOME_MESSAGE)
  
  love.draw = callback('draw')
  love.update = callback('update')
  love.singleclick = callback('click')
end

function game_over()
  callbacks.click = game_start
  callbacks.update = nil
  local score, wins, total = get_game_results()
  callbacks.draw = splashResults(score, wins, total)
end

function game_start()
  reset_state()
  reset_render()
  ui_update_score()
  callbacks.click = nil
  callbacks.update = update_game
  callbacks.draw = draw_game
end

--- rendering ---

function reset_terminal(txt)
  input_text(txt, nil)
end

function reset_render()
  for i in queued_challenges() do
    positions[i]=get_random_x()
    render.progress[i]=draw_pending_result
    render.challenges[i]=nil
  end
  reset_terminal(STARTING_PROMPT)
end

function set_waiting_renderer(i)
  local q = get_question(i)
  local b = get_pending_bonus(i)
  local r = unanswered_challenge_renderer(q, b)
  render.challenges[i]=r
end

function set_solved_renderer(i)
  local q, a = get_question_answer(i)
  local b = get_earned_bonus(i)
  local r = solved_challenge_renderer(q, a, b)
  render.challenges[i]=r
end

function mark_as_launched(i)  
  render.progress[i]=draw_waiting_result
end

function mark_as_failed(i)
  render.progress[i]=draw_failed_result
end

function mark_as_solved(i)
  local b = get_earned_bonus(i)
  render.progress[i]=successful_result_renderer(b)
end

function ui_update_score()
  render.score = score_renderer( get_total_score() )
end

function display_answer(txt)
  local msg = fmt(GAME_PROMPT, txt)
  reset_terminal(msg)
end


--- rules ---

function expire(i)
  sfx.boom()
  register_expire(i)  
  render.challenges[i]=nil
  mark_as_failed(i)
end

function launch(i)
  register_launch(i)
  set_waiting_renderer(i)
  sfx.ping()
  mark_as_launched(i)
end

function vanish(i) 
  register_vanish(i)
  render.challenges[i]=nil
end

function devalue(i)
  register_devalue(i)
  set_waiting_renderer(i)
end

function win(i)
  register_win(i)
  sfx.wow()
  set_solved_renderer(i)
  mark_as_solved(i)
  ui_update_score()
end

--- terminal ---

function check_input()
  if not terminal:is_empty() then
    local txt = terminal()
    display_answer(txt)
    for_each(new_matches(txt), win)
  end
end

--- animation ---

function render_challenge(i)
  local renderer = render.challenges[i]
  if not renderer then
    return
  end
  local x = positions[i]
  local y = field_height * current_progress(i)
  renderer(x,y)
end

--- main loops ---

function update_game(dt)
  time = time+dt
  for_each(expirable(), expire)
  for_each(vanishable(), vanish)
  for_each(launchable(), launch)
  for_each(devaluable(), devalue)
  check_input()
  if game_is_over() then
    if 0 == count(vanishable()) then  
      game_over()
    end
  end
end

function draw_game()
  render.score()
  for i, result_card in ipairs(render.progress) do
    result_card(i)
  end
  drawFieldBackground()
  for_each(queued_challenges(), render_challenge)
end

game_load()
