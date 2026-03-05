# Balloons 

## Gameplay

User observes 'balloons' with questions (further named challenges) that flow through game field, being launched at predefined intervals.

When user types answer, and it matches the correct answer for some of currently flowing challenges, relevant challenge is 'won', and bonus scores are recorded.

Challenges which do not get proper answer while flowing, expire and disappear when they reach the bottom of the game field.

Progress bar is used to represent overall set of challenges and their state (pending, active, won, lost).

When all challenges are either 'won' or expired, game ends, total score becomes final result, final splash screen is displayed.


## Architecture

### Challenge lifecycle

Each challenge in the game passes through the different lifecycle phases

* 'pending' (original state, challenge is not drawn on the screen but reflected as grey card in progress bar)
* 'start/launch' (challenge appears on the screen, card in progress bar becomes yellow)
* 'devalue' (incremental decrease of challenge bonus/price)
* 'win' (when question is answered correctly, bonus is recorded, rendering slightly changes, progress bar card changes to green and draws the bonus earned)
* 'loss' (challenge is timed out, no more rendered, no more answearable, card marked red in progress bar)
* 'vanish' (only happens after 'win' -- challenge stops rendering after few seconds delay)

### Referencing challenges

Inside game, there's no mutable 'challenge' object that changes its state. 

Instead we have: 
1) an immutable 'queue' (fixed-length list initialized once per game, referencing subset of items from CHALLENGES in challenges.lua, in randomized order)
2) few mutable lists of the same shape as queue, used for tracking various data associted with specific challenges: times of specific events, scores, renderer functions

Indeces of the queue become universal identifier of challenge in the context of particular game.

I.e. for N-th challenge in the queue we use N to also reference:
1) an N-th renderer function in renderers list
2) an N-th card in progress bar
3) an N-th record in lists of pending/earned scores
4) an N-th record in the lists of events of particular type (e.g. N-th item in the list of 'starts', in the list of 'wins' etc.)

## Model (model.lua)

Model represents game state. It encapsulates queue list, supporting data structures (per-challenge lists of scores or various events). Model is resposible for tracking events, timeouts, bonuses, and for game state transitions.

Model exposes methods to initialize game state, register specific 'events', and to get the subset of queue indeces corresponding to specific condition (e.g. referencing all 'answerable' or all 'launchable' challenges)

## View (graphics.lua)

Screen is organized into three parts (beyond terminal)
* Main field (where challenge visualizations are flowing)
* Score label (which displays overall score)
* Progress bar (which displays a 'card' for each challenge in the queue, changing color and view as challenge is started, won, or loss)

View functions are expected to be isolated from game state tracking. They are invoked with all required parameters (e.g. they know how to draw a challenge object with proper answer, but they do not bother qhere question and answer come from, or how proper answer was detected, or how desired  coordinates were calculated).

View layer also actively uses parameterized functions generation. I.e. when specific challenge changes state (e.g. is devalued), controller (described below) invokes a factory function that accepts question text and new bonus value, to generate the renderer function that draws this specific combination of question+bonus in predefined style (e.g. unanswered) while accepting coordinates as dynamic parameters. This allows to use returned renderer with changing coordinates, but without controller being further concerned about what exactly and how exactly is being drawn by the renderer.

## Controller (main.lua)

Controller ties model and view together.

It itself maintans two tables:

1) positions (tracking random horizontal offset of each challenge, calculated at challenge launch)
2) renderers -- a collection of functions responsible for drawing the various visual elements: specific challenge in game field, specific card in progress bar, score label, or splash screen.

Whenever game changes state (typically due to changes in challenge statuses), controller updates particular renderers with new dynamically generated functions, reflecting the desired changes in visualization (progress card decoration, displayed total score, flowing challenge representation)

### Controller's loops

Controller runs two loops and one callback:

1) `update` loop queries the model and validates the terminal input to see if state of any challenges or state of the overall game has to be changed. This is typically done by invocation of "action functions" (described below) such as `expire`, `launch` etc. which are responsible for registering changes (new events) with the model, updating renderers functions to change visualization, and emitting sound effects.

2) `draw` loop redraws the game field, invoking all non-nil renderers in the renderers collection (which would draw the score label, cards in progress bar, challenge objects for every active challenge)

### Controller's "action functions"

Controller includes the set of functions responsible for managing game state transitions, such as `expire`, `win`, etc.. Typically they invoke the model method to register state changes, trigger sound effects, and update one or more renderers in the collection to change visualizations. Functions such as `game_start` or `game_load` also switch the whole set of framework callbacks to ensure transitions between active game mode and clickable splash screen (displayed in between games).

### Examples: 
* when specific N-th challenge is eligible for lauch, the `launch` function registers the launch event via model, updates the N-th progress bar card renderer to the function drawing yellow card, and updates N-th challenge renderer from nil to the function drawing balloon for unanswered challenge with specific question; 
* when win happens for N-th challenge and total score is updated from X to Y, function `win` replaces scoreboard renderer from one which draws X to one which draws Y, and alters visualizations of N-th in-field challenge and N-th progress bar card; 
* when N-th challenge is timed out, function `expire` sets N-th challenge renderer to nil, and updates N-th progress bar card renderer to the function displaying red card

