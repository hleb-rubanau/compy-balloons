require('graphics')

views = { }

function init_views()
  views.splash = widget_splash()
  views.score  = widget_score()
  views.challenges = { }
  views.results = { }
end
