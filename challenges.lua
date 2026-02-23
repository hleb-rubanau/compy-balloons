CHALLENGES = { }

function add_challenge(q, a)
  table.insert(CHALLENGES, {
    question = q,
    answer = a
  })
end

add_challenge("Print missing letter in 'giraf..e':", "f")
add_challenge("Print missing letter in 'car..ot':", "r")
add_challenge("Print missing letter in 'eleph..nt':", "a")
add_challenge("Print missing letter in 'ban..na':", "a")
add_challenge("Print missing letter in 'do..key':", "n")
add_challenge("Print missing letter in 'spi..er':", "d")
add_challenge("Print missing letter in 'butt..rfly':", "e")
add_challenge("Print missing letter in 'chi..ken':", "c")
add_challenge("What is 3 + 4?:", "7")
add_challenge("What is 9 - 5?:", "4")
add_challenge("How many legs does a dog have?:", "4")
add_challenge("How many days are in a week?:", "7")

function challenges()
  local idx = 0
  local iterator
  return function()
    idx = idx + 1
    if #CHALLENGES < idx then
      idx = 0
      return nil
    end
    return CHALLENGES[idx]
  end
end
