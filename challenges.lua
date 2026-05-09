--- task is just a textual definition/config
-- challenge is a combination of stateless renderer and solver function
require("config")
require("tasks")
require("helpers")
require("os")
require("debugfunc")

challenges_queue_size = MAX_SLOTS
challenges = {}

challenge_initial_state = {
  x = -1,
  y = 0,
  phase = 0,
  score = 0,
  launched = -1,
  solved = -1,
  expired = -1,
  cleared = -1,
  solved_y = -1,
  state = "loaded",
}

function challenges_init()
  tasks_init()
  for i = 1, #TASKS do
    local t = TASKS[i]
    local c = {
      task = t,
      widget = widget_with_dynamic_position(t.widget),
      w = t.widget.geometry[1],
      h = t.widget.geometry[2],
    }
    partial_reset(c, challenge_initial_state)
    challenges[i] = c
  end
end

function challenges_reset(qs)
  queue_size = math.min((qs or MAX_SLOTS), #challenges)
  shuffle(challenges)
  for i = 1, #challenges do
    local c = challenges[i]
    partial_reset(c, challenge_initial_state)
  end
  for i = 1, queue_size do
    challenges[i].state = "pending"
  end
end

function get_launch_position(c, t)
  math.randomseed(t + c.w + c.h)
  return math.random(FIELD_WIDTH - c.w)
end

function challenge_maybe_launch(c, t, i, callback)
  local launch_due = (i - 1) * LAUNCH_DELAY < t
  if launch_due then
    c.launched = t
    c.x = get_launch_position(c, t)
    c.score = c.task.score
    c.state = "active"
    callback("launched", c.task.score)
    Log.debug("LAUNCHED: "..c.task.q)
    --inspect(fmt("challenge[%s]",i), c)
    --inspect(fmt("challenge[%s].task",i), c.task)
  end
end

function challenge_descend(c, t, i, callback)
  local elapsed = t - c.launched
  c.y = elapsed * c.task.descend_speed
  --c.score = math.ceil(1 - elapsed * c.task.devalue_speed)
  c.score = math.ceil(elapsed * c.task.devalue_speed)
  if c.y > c.task.runway then
    c.expired = t
    c.state = "expired"
    callback("expired")
  end
end

function challenge_validate(c, text, t, i, callback)
  Log.debug(fmt("VALIDATING:\n\tq=%s\n\ta=%s\n\te=%s\n", c.task.q, text, c.task.a))
  if c.task.validator(text) then
    c.solved = t
    c.solved_y = c.y
    c.state = "solved"
    callback("solved", c.score, i)
  end
end

function challenge_ascend(c, t, i, callback)
  local elapsed = t - c.solved
  local float_time = math.max(0, elapsed - ANIMATION_TIME)

  c.phase = elapsed / ANIMATION_TIME
  c.y = c.solved_y - float_time * ASCEND_SPEED
  if c.y <= 0 then
    c.cleared = t
    c.state = "cleared"
    callback("cleared")
  end
end

function challenge_draw(c)
  c.widget.draw(c.x, c.y, c.score, c.phase)
end

on_challenge_update = action_map({
  pending = challenge_maybe_launch,
  active = challenge_descend,
  solved = challenge_ascend,
})

function challenges_update(time, callback)
  for i = 1, queue_size do
    local c = challenges[i]
    on_challenge_update[c.state](c, time, i, callback)
  end
end

function challenges_validate(text, time, callback)
  for i = 1, queue_size do
    local c = challenges[i]
    if c.state == "active" then
      challenge_validate(c, text, time, i, callback)
    end
  end
end

function challenges_draw()
  for i = 1, queue_size do
    local c = challenges[i]
    if c.state == "actve" or c.state == "solved" then
      challenge_draw(c)
    end
  end
end

challenges_init()
