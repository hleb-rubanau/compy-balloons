--- challenge is just a textual definition/config
-- task is a combination of stateless renderer and solver function
require('tasks')
require("functions")

queue = { }
challenges = { }

function reset_queue()
  for i = 1, #TASKS do
    queue[i] = i
  end
  shuffle(queue)
end

function init_challenges()
  for i in 1, MAX_SLOTS do
    challenges[i] = { }
  end
end

function reset_challenges()
  reset_queue()
  for i in 1, MAX_SLOTS do
    challenges[i].task = TASKS[ queue[i] ]
    challenges[i].launched = nil
    challenges[i].solved = nil
    challenges[i].expired = nil
    challenges[i].vanished = nil
    challenges[i].x = nil
    challenges[i].y = nil
    challenges[i].phase = 0
    challengse[i].score = nil
  end
end

init_challenges()
