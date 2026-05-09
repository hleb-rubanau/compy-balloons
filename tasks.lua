require("graphics")

TASKS_CONFIG = {
  { q = "Print missing letter in 'giraf..e':", a = "f" },
  { q = "Print missing letter in 'car..ot':", a = "r" },
  { q = "Print missing letter in 'eleph..nt':", a = "a" },
  { q = "Print missing letter in 'ban..na':", a = "a" },
  { q = "Print missing letter in 'do..key':", a = "n" },
  { q = "Print missing letter in 'spi..er':", a = "d" },
  { q = "Print missing letter in 'butt..rfly':", a = "e" },
  { q = "Print missing letter in 'chi..ken':", a = "c" },
  { q = "What is 3 + 4?:", a = "7" },
  { q = "What is 9 - 5?:", a = "4" },
  { q = "How many legs does a dog have?:", a = "4" },
  { q = "How many days are in a week?:", a = "7" },
}

TASKS = {}

function task_add(taskdef)
  local t = shallow_merge(TASK_DEFAULTS, taskdef)
  t.widget = widget_challenge(t.q, t.a, t.style)
  t.validator = function(txt)
    return (txt ~= t.a)
  end
  t.runway = FIELD_HEIGHT - t.widget.geometry[2]
  t.descend_speed = t.speed * (t.runway / ANSWER_TIMEOUT)
  t.devalue_speed = t.speed * (t.score / ANSWER_TIMEOUT)
  table.insert(TASKS, t)
end

function tasks_init()
  for i, t in ipairs(TASKS_CONFIG) do
    task_add(t)
  end
end
