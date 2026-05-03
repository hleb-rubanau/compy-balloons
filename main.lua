require("config")
require("challenges")
require("constants")
require("model")
require("views_game")
require("debugfunc")

-------------------------------------------------
-- the game view must build layout, declaratively?
-- but renderer still will travel across all queue items
-- so could they be a params?
-- 'draw' is invoked at every step. We do not have to recalculate everything on every draw tick
-- we need robust renderers to be there
-- something like:
--    'splash', ...
--    'game', ...<data for all widgets>? yes, maybe>
--      which in fact means that on 'update' the renderer is switched somehow
--      at least, its mode and payload
--    what exactly is switched on update?
--      we need some data structure, that says
--        'results'
--        'game'
--        'challenges' (queue-shaped, references real challenges)
-------------------------------------------------

-- my original implementation was too canonical in separation of model and views
-- we do not have to do it that strict. At least there are eements of the visuals which belong to model
-- model (and this info do we have!):
--    how many launched/solved/expired
--    which ones in which order
-- views:
--    N slots
--    could be nil before launch or after expire
--    slot is initialized when thing is launched (BECAUSE coordinate X may not be known yet, but its ONLY for varying speeds -- and what if instead we ignore a problem of varying speeds, just drawing them on top of each other?)
--    also it does not matter for when we solve the thing -- our concern was only for active stuff overlapping. If we draw in strict order, its not a problem
--    then... slot is initialized whenever we want.


----------------------------------------------------------
-- model: as currently
-- views: new file, utilizes graphics but also has specific instances
-- controller -- invokes view with parameters (results)a
-- now important aspect: state recalculation on every tick is useless, because state changes more rarely *except* animation phase and coordinate

-- so controller must blend the 'game state' with 'coordinate'
--    and some info is just fixed e.g. (q&a, x after launch, that shit)
-- the important lifecycle events:
--    launch: 
--      changes model
--    draw:
--      results
--  current model has mostly results recorded. Why? as they are raw data
--    but we also need precalculated, to avoid 
--
-- so, state structure is....
--      

-----------------------------------------------
-- IMMUTABLE DATA
--  challenges: config
--  solvers:  matches answer with 
--  renderers: initialized from config (solely to avoid GC abuse)
--  so, instead we build the following:
--    CHALLENGES:
--      idx
--      config (copy of config entry) -- important to calc speed and bonus
--        only config/speed/bonus
--      solver
--      renderer
-- MUTABLE DATA:
--  model:
--    slot # => 
--        challenge # 
--          (references solver, renderer, speed params)
--        lifecycle 
--          launched 
--          solved
--          expired
--        display
--          coord x
--          current y (changes every tick)
--          current phase ( now - solved / animation length)
--        state: 'pending/launched/solved/expired/vanished' (vanish happens after solved)
--        bonus:
--          pending
--          earned
--    game:
--      scores: 
--        earned
--        possible
--      challenges: 
--        solved
--        pending
--        total


-- stylua: ignore start

views = { }

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

function init_views()
  views.splash = widget_splash()
  views.score  = widget_score()
  views.challenges = { }
  views.results = { }
  for i, c in ipairs(CHALLENGES) do
    views[i] = widget_challenge(c.question, c.answer)
  end
end
-- stylua: ignore end

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
  init_views() 
  callbacks.click = game_start
  callbacks.update = nil
  callbacks.draw = splash(WELCOME_MESSAGE)
  love.draw = callback("draw")
  love.update = callback("update")
  compy.singleclick = callback("click")
end

function game_over()
  callbacks.update = nil
  callbacks.click = game_start
  reset_terminal("Click to restart")
  local score, wins, total = get_game_results()
  callbacks.draw = splashResults(score, wins, total)
end

function game_start()
  reset_state() -- changes runtime
  reset_render()  
  ui_update_score()
  callbacks.click = nil
  callbacks.update = update_game
  callbacks.draw = draw_game
end

--- rendering ---

-- TODO: only works first time and after reading from terminal
function reset_terminal(txt)
  input_text(txt, nil)
end

function reset_render()
  for i in queued_challenges() do
    render.progress[i] = draw_pending_result
    render.challenges[i] = nil
  end
  reset_terminal(STARTING_PROMPT)
end

function set_waiting_renderer(i)
  local q = get_question(i)
  local b = get_pending_bonus(i)
  local r = unanswered_challenge_renderer(q, b)
  render.challenges[i] = r
end

function set_solved_renderer(i)
  local q, a = get_question_answer(i)
  local b = get_earned_bonus(i)
  local r = solved_challenge_renderer(q, a, b)
  render.challenges[i] = r
end

function mark_as_launched(i)
  render.progress[i] = draw_waiting_result
end

function mark_as_failed(i)
  render.progress[i] = draw_failed_result
end

function mark_as_solved(i)
  local b = get_earned_bonus(i)
  render.progress[i] = successful_result_renderer(b)
end

function ui_update_score()
  render.score = score_renderer(get_total_score())
end

function display_answer(txt)
  local msg = fmt(GAME_PROMPT, txt)
  reset_terminal(msg)
end

--- rules ---

function expire(i)
  sfx.boom()
  register_expire(i)
  render.challenges[i] = nil
  mark_as_failed(i)
end

function launch(i)
  positions[i] = get_random_x()
  register_launch(i)
  set_waiting_renderer(i)
  sfx.ping()
  mark_as_launched(i)
end

function vanish(i)
  register_vanish(i)
  render.challenges[i] = nil
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
  reset_terminal(STARTING_PROMPT)
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
  renderer(x, y)
end

--- main loops ---

function update_game(dt)
  time = time + dt
  for_each(expirable(), expire)
  for_each(vanishable(), vanish)
  for_each(launchable(), launch)
  for_each(devaluable(), devalue)
  check_input()
  if game_is_over() then
    local last_flying = count(showing_off())
    if 0 == last_flying then
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
