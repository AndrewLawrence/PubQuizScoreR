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

#### What is a pub quiz?

[It's a quiz - in a pub](https://en.wikipedia.org/wiki/Pub_quiz).
Questions are organised into themed rounds, 
you get points for getting the answers correct
(or for making the most artistic balloon animal, it depends on the quiz/round).
At the end of the quiz the team (or person) with the most points wins a prize.

#### What is a "Bring Your Own Pub Quiz"?

It's an ad-hoc quiz without a central organiser acting as quizmaster - instead 
everyone gets to play (and set questions)!

Each player (or team) prepares a round and acts as quizmaster for their round.
For obvious reasons a player can't be scored fairly on their own round, so: 
how should the quiz be scored to determine an overall winner?

#### Why does this need special treatment for scoring?

If each participant completes all rounds of a quiz, then the competition is
fair when points are simply totalled up. However, if rounds differ in: the 
number of points available, the difficulty, or discriminability, 
then missing one or more rounds becomes an important factor
(Note: even without missed rounds, this would make for an unbalanced pub quiz 
where some rounds are more important than others).

One approach would be to make sure all rounds award a similar number of points, 
and none are too difficult. In practice this is difficult to coordinate with
all the quizmasters, makes the process of coming up with a round less fun, 
and it only limits rather than removes ways to game the system.

#### What do you mean by trying to game the system?

Consider the following scoring systems:

1. missing rounds earn the player 0 points, winner is person with most points
2. missing rounds earn the player their average points of all other rounds, winner is person with most points
3. all rounds are scored as a percentage of the possible point total, winner is person with highest average percentage score (excluding their round).
  
In each case setting a particularly difficult round will help you on your path
to victory. If everyone scores 0 points on your 
"Doncaster Rovers '89-'90" round you will do relatively better than participants
who set less niche questions.

There are other incentives with other scoring systems, potentially requiring
collusion. For example, one way to adjust for difficulty is to scale scores 
by the standard deviation of all the entrants. 
Say the scoring is now z-score standardised, so the 
mean for each round is score 0, and points relative to the mean are 
converted to standard deviations. To game the system, you can write a targeted 
round that suits a collaborator's knowledge
(perhaps Billy Bremner, the Doncaster Rovers manager, has 
agreed to share the prize with you), their score for the round you set 
will be an extreme outlier in terms of z-scores and so strongly improve their 
overall standing.

#### How does the rank score work?

Each round, whichever scoring system the quizmaster wants to use is applied,
then the scores are put in rank order (omitting the quizmaster) and participants
are assigned their rank. The best score gets 1, the second best 2, and so on. 
Importantly, any ties are assigned the lowest (best) rank. So if
second place is tied the ranks are: 1, 2, 2, 4, 5, ...

At the end the winner is the person with the lowest mean-average rank.

#### How does the rank score help?

* It means the distribution of scores matters less, you can't benefit extremely
from one round.

* It incentivises producing rounds that discriminate well between players. This 
is because ties are assigned the best rank, and so benefit non-quizmaster 
players. 

A bad actor now cannot simply make their round too hard, there will be more ties.
There is still an incentive to make rounds more random, or harder in a manner 
targetted against known high skill players (while also being discriminable 
enough to avoid ties), but this is cannot add much noise to the scores because 
ranks do not allow for extreme values.

#### Does this work for players who want to skip rounds / go to the bathroom?

If a player can stop whenever, this gives an incentive for those who did well in
early rounds to stop playing to keep their average high. 
It should be fine for a sporadic missed round or two.

#### Can you miss any number of rounds?

If the number of missed rounds varies substantially between the 
participants it can lead to undesirable results.
Imagine there are 20 players and 20 rounds, one is the quizmaster for 19 rounds,
another player provides a final round. If the quizmaster is placed first in the
last round, then they have won overall. Even a player with 19 wins would be dragged to 
an average rank score below that of the quizmaster.

#### Isn't there a better way of doing this?

Probably! I'm not too hot on order based statistics. Also, 
maybe something like [Bayesian ELO](https://www.remi-coulom.fr/Bayesian-Elo/),
or more generally attempting to infer a latent performance factor with uncertainty
would be better.

However, this ranking method was developed for pen and paper and can be scored 
in this manner while modestly drunk.

