--- task is just a textual definition/config
-- challenge is a combination of stateless renderer and solver function
require('tasks')
require("functions")
require("helpers")

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
  c.y = nil
  c.phase = 0
  c.score = nil -- this is current score? or max?
  c.task = t
  c.widget = t.widget
  c.validator = t.validator
  c.init_score = t.score
end

function challenges_reset()
  reset_queue()
  for i in 1, #challenges do
    local c = challenges[i]
    local t = TASKS[ queue[i] ]
    challenge_reset(c, t)
  end
end


function is_launchable(i,t)
  if challenges[i].launched = false then
    return (i - 1) * LAUNCH_DELAY < t
  end
end

challenges_init()
