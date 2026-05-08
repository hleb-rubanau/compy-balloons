--- task is just a textual definition/config
-- challenge is a combination of stateless renderer and solver function
require("config")
require("constants")
require("tasks")
require("functions")
require("helpers")
require("os")

queue = { }
challenges = { }

function reset_queue()
  for i = 1, #TASKS do
    queue[i] = i
  end
  shuffle(queue)
end

function challenges_init(n)
  n = n or MAX_SLOTS
  tasks_init()
  for i in 1, n do
    challenges[i] = { }
  end
end

function challenge_reset(c,t)
  c.launched = nil
  c.solved = nil
  c.expired = nil
  c.vanished = nil
  c.x = nil
  c.y = 0
  c.phase = 0
  c.score = nil -- this is current score? or max?
  c.task = t
  c.widget = t.widget
  c.w, c.h = unpack(t.widget.geometry)
  c.validator = t.validator
  c.init_score = t.score
end

function challenges_reset()
  reset_queue()
  for i in 1, #challenges do
    local c = challenges[i]
    local T = TASKS[ queue[i] ]
    challenge_reset(c, T)
  end
end

function get_launch_position(c,t)
  math.randomseed(t+c.w+c.h)
  return math.random( FIELD_WIDTH  - c.w )
end

function challenge_maybe_launch(c, t, i, callback)
  local launch_due = (i - 1) * LAUNCH_DELAY < t
  if launch_due then
    c.launched = t
    c.x = get_launch_position(c, t)
    c.score = c.init_score
    c.state = 'active'
    callback('launched', c.score)
  end
end

function challenge_descend(c, t, i, callback)
  local elapsed = t - c.launched
  c.y = elapsed * c.task.descend_speed 
  c.score = math.ceil( 1 - elapsed * c.task.devalue_speed )
  if c.y > c.task.runway then
    c.expired = t
    c.state = 'expired'
    callback('expired')
  end
end

function challenge_ascend(c, t, i, callback) 

end

on_challenge_update = action_map({
  'waiting' = challenge_maybe_launch,
  'active' = challenge_descend,
  'solved' = challenge_ascend,
})

function challenges_update(time, callback)
  for i in 1, #challenges do
    local c = challenges[i]
    on_challenge_update[ c.state ](c, t, i, callback) 
  end
end


function is_launchable(i,t)
  if challenges[i].launched = false then
    return (i - 1) * LAUNCH_DELAY < t
  end
end

challenge_updaters = action_map({

})

challenges_init()
