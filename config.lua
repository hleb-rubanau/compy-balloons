ANSWER_TIMEOUT = 10

LAUNCH_DELAY = 2.5
DEFAULT_BONUS = ANSWER_TIMEOUT
DEVALUE_INTERVAL = 1
DEVALUE_BY = 1
WIN_DELAY = 3

WELCOME_MESSAGE = "Click to start"
RESULTS_MESSAGE = "Your score: %s (%s/%s)\nClick to restart"
STARTING_PROMPT = "Type and press <Enter>"
GAME_PROMPT = "Your answer: <%s>"

SCREEN_VPAD = 0.1
BALLOON_RADIUS = 24

COLORS = { }
COLORS.bg = Color[Color.blue]
COLORS.question_bg = Color[Color.white]
COLORS.question_fg = Color[Color.black]
COLORS.answer_ok = Color[Color.green]
COLORS.answer_fail = Color[Color.red]
COLORS.time = Color[Color.yellow]
COLORS.counters = Color[Color.yellow]
COLORS.splash = Color[Color.yellow]
COLORS.score = Color[Color.blue]
COLORS.score_bg = Color[Color.white]
COLORS.results_bg = {
  0.5,
  0.5,
  0.5
}
COLORS.results_ok = Color[Color.green]
COLORS.results_fail = {
  1,
  0.25,
  0
}
COLORS.results_wait = Color[Color.yellow]
COLORS.results_border = Color[Color.blue]
COLORS.results_score = Color[Color.white]

FONTS = {
  question = 20,
  answer = 22,
  time = 32,
  counters = 32,
  splash = 64,
  score = 32,
  results_score = 24,
  hint = 16
}
