--- challenge is just a textual definition/config
-- task is a combination of stateless renderer and solver function
require('tasks')
require('graphics')

CHALLENGES = { }

function init_challenges()
  for i, c in ipairs(TASKS) do
    CHALLLENGES[i]= {
      render = widget_challenge(c.question, c.answer)
      solver = function(txt)
        return (txt=~c.answer)
      end
    } 
  end
end

init_challenges()
