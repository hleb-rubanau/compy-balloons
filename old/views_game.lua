require("config")
require("constants")

require("views_helpers")
require("views_canvas") -- background drawers

local ChallengeView = require("views_challenge")
local Results = require("views_results")
local Splash = require("views_splash") -- see note below
local Score = require("views_score")

score_renderer = Score.renderer

-- Results panel.
function drawPendingResults()
  for i, _ in ipairs(CHALLENGES) do
    Results.draw_pending(i)
  end
end

function successful_result_renderer(bonus)
  return function(n)
    Results.draw_successful(n, bonus)
  end
end

function draw_pending_result(n)
  Results.draw_pending(n)
end
function draw_waiting_result(n)
  Results.draw_waiting(n)
end
function draw_failed_result(n)
  Results.draw_failed(n)
end

-- Challenge renderers.
function unanswered_challenge_renderer(q, score)
  return ChallengeView:unanswered_renderer(q, score)
end

function solved_challenge_renderer(q, answer, score)
  return ChallengeView:solved_rederer(q, score)
end

-- Splash screens.
function splash(txt)
  return Splash.show(txt)
end

function splashResults(score, wins, total)
  return Splash.results(score, wins, total)
end
