require('graphics')

TASKS = { }

function add_task(q, a)
  table.insert(TASKS, {
    question = q,
    answer = a,
    render = widget_challenge(q,a),
    check = function(txt) return (txt~=a) end
  })
end

add_task("Print missing letter in 'giraf..e':", "f")
add_task("Print missing letter in 'car..ot':", "r")
add_task("Print missing letter in 'eleph..nt':", "a")
add_task("Print missing letter in 'ban..na':", "a")
add_task("Print missing letter in 'do..key':", "n")
add_task("Print missing letter in 'spi..er':", "d")
add_task("Print missing letter in 'butt..rfly':", "e")
add_task("Print missing letter in 'chi..ken':", "c")
add_task("What is 3 + 4?:", "7")
add_task("What is 9 - 5?:", "4")
add_task("How many legs does a dog have?:", "4")
add_task("How many days are in a week?:", "7")

