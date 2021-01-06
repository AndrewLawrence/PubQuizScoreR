# scoring system for quiz:

library(tidyverse)
source('pubquiz_rankscore_functions.R')


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
example.RoundTotal <- sample(c(5,10,20,40),
                             size = length(example.Rounds),
                             replace = TRUE)

example.RoundScore <- expand.grid(Players = example.Players,
                                  Rounds = example.Rounds,
                                  stringsAsFactors = FALSE)

example.RoundScore$Total <- example.RoundTotal[match(example.RoundScore$Rounds,
                                                     example.Rounds)]
example.RoundScore$Skill <- example.PlayerSkill[match(example.RoundScore$Players,
                                                     example.Players)]

# realise the scores:
example.RoundScore$Score <- mapply(
  FUN = function(total, errprob) {
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
example.data[2,3] <- example.data[3,4] <- example.data[4,2] <- example.data[5,5] <- NA

# add in a 'config' row:

example.data <- rbind(example.data, c())

# write out example data:
write.csv(example.data, file = "example.csv", row.names = FALSE)


# Demonstrate average rank scoring ----------------------------------------

rawscores <- read_quiz('example.csv')
propscores <- sweep(rawscores, 2, example.RoundTotal, "/")

rankscores <- rankscore_quiz(rawscores)
rankscores_plus_final <- totalize(rankscores)

the_path_to_victory <- cumulate_rankscores(rankscores)


plot_scores(rawscores, ranked_y = FALSE) + ggtitle("Raw Scores per Round")
plot_scores(rankscores) + ggtitle("Rank Placing per Round")
plot_scores(rankscores_plus_final) + ggtitle("Rank Placing per Round and Final Average Rank")
plot_scores(the_path_to_victory) + ggtitle("Progression Of Average Rank Score")

