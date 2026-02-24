require("functions")
require("config")

time = 0
queue = { }

events = {
  starts = { },
  wins = { },
  losses = { },
  vanishes = { },
  devalues = {}
}

scores = {
  pending = { },
  earned = { }
}

--- initializations ---

function reset_queue()
  for i = 1, #CHALLENGES do
    queue[i]=i
  end
  shuffle(queue)
end

function reset_events(i)
  events.starts[i]=nil
  events.wins[i]=nil
  events.losses[i]=nil
  events.vanishes[i]=nil
  events.devalues[i]=nil
end

function reset_scores(i)
  scores.pending[i]=nil
  scores.earned[i]=nil
end

function reset_state()
  reset_queue()
  for i = 1, #queue do
    reset_events(i)
    reset_scores(i)
  end
  time = 0
end

--- game stats ---

function get_total_score()
  return sum( values( scores.earned ) )
end

function get_game_results()
  local wins_count = count( values(events.wins) )
  local scores = get_total_score()
  return score, wins_count, #queue
end

function game_is_over()
  local finishes = count(events.wins)+count(events.losses)
  return finishes == #queue 
end

--- events handlers ---

function register_launch(i)
  scores.pending[i]=starting_score(i)
  events.starts[i]=time
end

function register_devalue(i, tweak)
  event.devalues[i]=time
  tweak = tweak or DEVALUE_BY
  local new_score = math.ceil(scores.pending[i]-tweak) 
  scores.pending[i]=math.max(0, new_score)
  return scores.pending[i]
end

function register_win(i)
  events.wins[i]=time
  scores.earned[i] = scores.pending[i]
  scores.pending[i]=nil
end

function register_expire(i)
  events.losses[i]=time
  scores.pending[i] = nil
end

function register_vanish(i)
  events.vanishes[i]=time
end

--- challenge attribution ---

function starting_score()
  return DEFAULT_BONUS
end 


function get_question(i)
  return CHALLENGES[ queue[i] ].question
end

function get_answer(i)
  return CHALLENGES[ queue[i] ].answer
end

function get_question_answer(i)
  local q = get_question(i)
  local a = get_answer(i) 
  return q, a
end

function validator(txt)
  return function(i)
    return txt == get_answer(i)
  end
end

function get_pending_bonus(i)
  return scores.pending[i]
end
function get_earned_bonus(i)
  return scores.pending[i]
end

function time_in_flight(i)
  if not event.starts[i] then
    return 0
  end
  local eol = events.wins[i] or events.losses[i]
  if eol then
    return eol - events.starts[i]
  end
  return time - events.starts[i]
end 

function current_progress(i)
  return time_in_flight(i) / ANSWER_TIMEOUT
end

function time_since_devalue(i)
  local ts = events.devalues[i] or events.starts[i]
  if ts then
    return time - ts
  end
  return 0
end

function is_launched(i)
  return events.starts[i] ~= nil
end

function is_launchable(i)
  if not(events.starts[i]) then
    return time > (i-1)*LAUNCH_DELAY
  end
end

function is_answerable(i)
  if is_launched(i) then
    local is_not_won = not(events.wins[i])
    local is_not_lost = not(events.losses[i])
    return is_not_won and is_not_lost
  end
end

function is_devaluable(i)
  if is_answerable(i) then
    return time_since_devalue(i)>DEVALUE_INTERVAL
  end
end

function is_expirable(i) 
  if is_answerable(i) then
    return time_in_flight(i) > ANSWER_TIMEOUT
  end
end

function is_vanishable(i)
  local win_time = events.wins[i]
  if win_time then
    if (time > win_time + WIN_DELAY) then
      return not(events.vanishes[i])
    end
  end
end

--- scope iterators ---

function queued_challenges()
  local idx = 0
  return function()
    i = i + 1
    if i > #queue then
      return nil
    end
    return i
  end
end

function challenges_where(condition)
  return each_where( queued_challenges(), condition )
end


--- dynamic scopes ---
function launchable()
  return challenges_where(is_launchable)
end

function devaluable()
  return challenges_where(is_devaluable)
end

function answerable()
  return challenges_where(is_answerable)
end

function expirable()
  return challenges_where(is_expirable)
end

function vanishable()
  return challenges_where(is_vanishable)
end

function new_matches(txt)
  return each_where(answerable(), validator(txt))
end

