require('challenges')

state = {
  queue_size = nil,
  wins = 0,
  scores = 0,
  status = 'ready'
}


local noop = function() end
local noop_mt = {
    __index = function(_, _) return noop end,
}

local Game = setmetatable({ }, noop)

Game.start = function()
  local qs = MAX_SLOTS
  state.queue_size = qs
  state.wins = 0
  state.losses = 0
  state.in_flight = 0
  state.score = 0
  state.time = 0
  reset_challenges(qs) 
  state.status = 'active'
end




function start_game()
end

function

function on_tick(dt)
  state.time = state.time + dt

  for_each(
  -- now we do various processings
  for i, v in challenges() do
    if is_launchable(i, t) then
      launch(i, t)
    end
    if is_launched(i) then
      if is_devaluable(i, t) then
        devalue(i, t)
      end
      if is_expired(i, t) then
        expire(i,t)
      end
      if is_unsolved(i) then
        advance(i,t)
      end
      if is_solved(i) then
        post_solve
      end
    end
    -- launch not launched
    -- devalue those devaluable
    -- de-flight those beyond Y limits
    -- expire those expired
  end

  -- check game over (in-flight=0, pending=0)

  -- check input and trigger

end
