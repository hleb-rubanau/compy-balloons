MAX_SLOTS = 12
--MAX_SLOTS = 2

ANSWER_TIMEOUT = 10

LAUNCH_DELAY = 2.5
DEFAULT_BONUS = ANSWER_TIMEOUT
DEVALUE_INTERVAL = 1
DEVALUE_BY = 1
WIN_DELAY = 3

ANIMATION_TIME = 1.5
MAX_ASCEND_TIME = 3

WELCOME_MESSAGE = "Baloons game"
WELCOME_SUBHEADER = "Type answers to release baloons"
RESULTS_MESSAGE = "Your score: %s (%s/%s)\nClick to restart"
STARTING_PROMPT = "Type answer and <Enter>"
GAME_PROMPT = "Your answer: <%s>"
STATS_TEMPLATE = "Solved: %s/%s | Score: %s | Time: %ds"
STATUS_TEMPLATE = "Solved: %s | Missed: %s | Active: %s | Pending: %s | Score: %s | Time: %ds"

GAME_OVER_HEADER = "Game Over"
SPLASH_HINT_BASE = "Type <start>"
SPLASH_HINT_START = "To start: " .. SPLASH_HINT_BASE
SPLASH_HINT_RESTART = "To restart: " .. SPLASH_HINT_BASE

SCREEN_VPAD = 0.1
BALLOON_RADIUS = 24

FONT_SIZES = {
  h1 = 64,
  h2 = 32,
  h3 = 28,
  h4 = 20,
  h5 = 16,
  h6 = 14,
  default = 12,
  small = 10,
}

TASK_DEFAULTS = {
  score = 10,
  size = 1,
  style = "blue",
  speed = 1,
}
