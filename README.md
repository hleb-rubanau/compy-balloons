# Balloons 

## Gameplay

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

I.e. for N-th event we use N to reference:
1) an N-th renderer in renderers list
2) an N-th card in progress bar
3) an N-th record in pending/eaarned scores lists
4) an N-th record in the lists of events of particular type (e.g. N-th record in the list of 'starts', in the llist of 'wins' etc.)

## Model (model.lua)

Model encapsulates queue object, supporting data object (events/scores), and all logic of tracking events, timeouts, bonuses.

Model exposes methods to initialize game state, register specific 'events', and to get the subset of queue corresponding to specific condition (e.g. all 'answerable' or all 'launchable' challenges)

## View (graphics.lua)

Screen is organized into three parts (beyond terminal)
* Main field (where challenge visualizations are flowing)
* Score table (which displays overall score)
* Progress bar (which displays a 'card' for each challenge in the queue, changing color and view as challenge is started, won, or loss)

View functions are expected to be isolated from game state tracking. They are invoked with all required parameters (e.g. they know how to draw a challenge object with proper answer, but they do not bother qhere question and answer come from, or how proper answer was detected, or how desired  coordinates were calculated).

## Controller (main.lua)

Controller ties model and view together.

It itself maintans two tables:

1) positions (tracking random horizontal offset of each challenge )
2) renderers -- a structure of functions responsible for drawing the challenge in game field, cards in progress bar, scoreboard


And it runs two loops:

1) Update loop queries the model to see if new events have to be registered. Also, depending on the event, it changes the renderers in table (e.g. when win happened and score was updated from X to Y, it replaces scoreboard renderer from one which draws X to one which draws Y ; or when item is launched it updates the card renderer in progress bar, and sets challenge renderer in game field; when challenge is timed out, its in-field renderer is set to nil, etc...)

2) redraw the field, invoking all non-nil renderers in the renderers table (which would draw the scoreboard, cards in progress bar, challenge objects for every active challenge)

