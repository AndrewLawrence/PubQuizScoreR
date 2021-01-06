# scoring system for quiz:

library(tidyverse)
source("pubquiz_rankscore_functions.R")


# Make example data -------------------------------------------------------

set.seed(42)

example.Players <- c("Rudolph", "Dasher", "Prancer", "Vixen",
                     "Comet", "Cupid", "Donner", "Blitzen")

example.Rounds <- paste0("r", 1:5, ":", c(
  "carrots", "parsnips", "kale", "turnips", "bananas"
))

# playerskill is an error probability:
example.PlayerSkill <- runif(n = length(example.Players), 0.2, 0.4)
# rounds can have different numbers of items:
example.RoundTotal <- sample(c(5, 10, 20, 100),
                             size = length(example.Rounds),
                             replace = TRUE)

example.RoundScore <- expand.grid(Players = example.Players,
                                  Rounds = example.Rounds,
                                  stringsAsFactors = FALSE)

example.RoundScore$Total <-
  example.RoundTotal[match(example.RoundScore$Rounds,
                           example.Rounds)]
example.RoundScore$Skill <-
  example.PlayerSkill[match(example.RoundScore$Players,
                            example.Players)]

# realise the scores:
example.RoundScore$Score <- mapply(
  function(total, errprob) {
    total - rbinom(1, size = total, prob = errprob)
  },
  total = example.RoundScore$Total,
  errprob = example.RoundScore$Skill)

# reshape the data:
example.data <- pivot_wider(example.RoundScore,
                            id_cols = Players,
                            names_from = Rounds,
                            values_from = Score)

# add NAs for missed rounds (e.g. Player set that round):
example.data[2, 3] <- example.data[3, 4] <-
  example.data[4, 2] <- example.data[5, 5] <- NA

# Add a final 'spoiler' round, this is a maliciously constructed round
#   done by Rudolph (in retaliation for being left out of the reindeer games)
#   The total possible score is 10,000 - but it's incredibly difficult,
#   and most participants will score between 5 and 10 depending on their skill.

example.data$`r6:Dragon Fruit` <-
  c(NA,
    sapply(2:length(example.Players),
           function(i) {
             10 - rbinom(1,
                         size = 10,
                         prob = example.PlayerSkill[i])
             }
    ))
example.RoundTotal <- c(example.RoundTotal, 1e4)

# write out example data:
write.csv(example.data, file = "example.csv", row.names = FALSE)


# Demonstrate average rank scoring ----------------------------------------

rawscores <- read_quiz("example.csv",
                       RoundTotals = example.RoundTotal)


propscores <- propscore_quiz(rawscores)

rankscores <- rankscore_quiz(rawscores)

the_path_to_rawscore_victory <- cumulate_scores(rawscores)
the_path_to_propscore_victory <- cumulate_scores(propscores)
the_path_to_rankscore_victory <- cumulate_scores(rankscores)

# Plots
plot_scores(totalize(rawscores),
            ranked_y = FALSE) +
  ggtitle("Raw Scores per Round")
plot_scores(totalize(propscores),
            ranked_y = FALSE) +
  ggtitle("Proportion Scores per Round")
plot_scores(totalize(rankscores)) +
  ggtitle("Rank Scores per Round")

plot_scores(the_path_to_rawscore_victory,
            ranked_y = FALSE) +
  ggtitle("Progression Of Average Raw Score")
plot_scores(the_path_to_propscore_victory,
            ranked_y = FALSE) +
  ggtitle("Progression Of Average Proportion Score")
plot_scores(the_path_to_rankscore_victory) +
  ggtitle("Progression Of Average Rank Score")
