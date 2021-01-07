# Pubquiz Rank Scoring

This is a set of R functions and an example script for determining the winner of
a Pub Quiz.

Particularly this is aimed to be useful for a 
*Bring Your Own Pub Quiz*, in that it allows players to miss some rounds, while 
accommodating a variety of scoring mechanisms, and limiting avenues for
players to tactically set rounds that exploit the scoring system for 
their advantage.

### Instructions

The R functions are in a [standalone file](pubquiz_rankscore_functions.R).
There is an [example script](pubquiz_rankscore_example.R) which generates some
example data (including a adversarial round).

To run the example:
```
install.packages('tidyverse')
source("pubquiz_rankscore_example.R")
```

The example shows how to read in a csv of raw scores, apply the rank score
and make some plots.

### Frequently Asked Questions

#### What is a "Bring Your Own Pub Quiz"?

It's an ad-hoc [pub quiz](https://en.wikipedia.org/wiki/Pub_quiz) without a 
central organiser acting as quizmaster - instead players take turns being the
quizmaster and everyone gets to play (when it's not their turn to be quizmaster)!

So, each player (or team) prepares a round and acts as quizmaster for that round.
For obvious reasons a player can't be scored fairly against the others 
on their own round: 
how should the quiz be scored to determine an overall winner?

#### Why does this need special treatment for scoring?

If each participant completes all rounds of a quiz, then simply adding up the 
points is a fair scoring system. This is the typical pub quiz format.

However, if rounds differ in: the 
number of points available, the difficulty, or discriminability, 
then missing one or more rounds becomes an important factor
(*Note: even without missed rounds, this would make for an unbalanced pub quiz *
*where some rounds are more important than others*). More than this, because 
players set their own round they might manipulate these aspects of their round 
for their benefit.

One approach would be to make sure all rounds award a similar number of points, 
and none are too difficult or easy. In practice this is difficult to coordinate
with all the quizmasters, makes the process of coming up with a round less fun, 
and it only limits, rather than removes, ways to game the system.

#### What do you mean by trying to game the system?

Consider the following scoring systems:

1. Missing rounds earn the player 0 points, winner is person with most points
2. Missing rounds earn the player their average points of all other rounds, winner is person with most points
3. All rounds are scored as a percentage of the possible point total, winner is person with highest average percentage score (excluding their round).

We might call these systems: simple total, 
mean imputation and total score normalisation.

In all three cases setting a particularly difficult round will help you on your path
to victory: If everyone scores 0 points on your 
"Doncaster Rovers '89-'90" quiz round you will do relatively better than participants
who set less niche questions.

There are other incentives with more complex scoring systems, sometimes involving 
collusion. For example, one way to adjust for difficulty is to scale scores 
by the standard deviation of all the entrants. 
Say the scoring is now z-score standardised, so the 
mean for each round is given a score of 0, and points relative to the mean are 
converted to standard deviations (positive or negative). Now to game the system, 
you can write a targeted 
round that suits a collaborator's knowledge
(perhaps Billy Bremner, former Doncaster Rovers manager, has 
agreed to share the prize with you if they win). Say there are 50 points
available, the collaborator scores 48 and everyone else scores ~3 points with 
a SD of ~1. The z-score is +45 for the collaborator, probably enough to win
overall given a typical z-score should be 0 and a strong performance ~2.


#### How does the rank score work?

Each round, whichever scoring system that round's quizmaster wants to use is applied,
then the scores are put in rank order (omitting the quizmaster) and participants
are assigned their rank. The best score gets 1, the second best 2, and so on. 
Importantly, any ties are assigned the lowest (best) rank. So if
second place is tied the ranks are: 1, 2, 2, 4, 5, ...

At the end the winner is the person with the lowest mean-average rank (for the 
rounds they completed).

#### How does the rank score help?

* It means the distribution of scores matters less, no-one can benefit extremely
from one round.

* It incentivises producing rounds that differentiate well between players and 
so produce few ties. This is because ties are assigned their best rank. 
Rounds with many ties thus on average benefit the participants in that round and
so disadvantage whoever set the round.

This means a competitive player now cannot simply make their round too hard 
to derive an advantage. Harder rounds have the same contribution to the 
final score, and potentially have a greater contribution for the players other
than the quizmaster as there may be more ties.

There are remaining problems:

 * In the limit, if a player only completes 1 round then that is their rank.
 * For an easy round that poorly differentiates player performance there can be 
  a big penalty to final performance for only a small error. For example: 
  9 players score 5 points and 1 player scores 4 points on a round, the assigned
  ranks are 9 x 1 point and 1 x 10 points, thus the last placed player 
  is quite disadvantaged. However, this behaviour is a consequence of ensuring
  difficult rounds are not beneficial to the setter, and the average effect is 
  to benefit the non-setter players.
 * If there aren't problems with unequal points, difficulty, discriminability
 between the rounds - i.e. if the rounds are exchangeable, then the rank based
 system will be less efficient at determining the 'true' winner (assuming
 some sort of persistent latent skill at quizes).

#### Does this work for players who want to skip rounds e.g. go to the bathroom?

It should be fine for players to miss a round or two, but advantage can be 
gained by a player strategically missing rounds they know they won't be good at.
In the limit, if the first ranked player of the first game sees their ranking 
and decides to take part in no further rounds, they are then guaranteed to win
(or draw) overall, so allowing participants to stop and start strategically is
unlikely to produce a fun quiz.

#### Isn't there a better way of doing this?

Probably! I'm not too hot on order based statistics. Also, 
maybe something like [Bayesian ELO](https://www.remi-coulom.fr/Bayesian-Elo/),
or more generally attempting to infer a latent performance factor with uncertainty
would be better.

However, this ranking method was developed for pen and paper and can be scored 
in this manner while moderately drunk.

