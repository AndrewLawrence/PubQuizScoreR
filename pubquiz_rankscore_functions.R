# Functions to use in the project:#

# A 'quiz' is a data.frame with custom attributes
#   it contains per-round scores (columns) for each participant (rows)
#   additionally it has a config attribute telling whether larger is
#   better (for the round).
#
# The input should be a CSV (with headers) using NA for any missed rounds,
#   the first column should be called 'player' and contain participant names.
#   remaining columns contain the results of quiz rounds and the column
#   header will be used to label the round.

read_quiz <- function(f, ScoreDirection = -1, RoundTotals = NA) {
  # f is a path to a file
  # config is a vector which is castable to the number of rounds
  #   the sign of each element of config determines whether smaller scores
  #   are better (1), or larger scores are better (-1)
  df <- read.csv(f, stringsAsFactors = FALSE, check.names = FALSE)
  plab <- df[, 1]
  df <- df[, -1]
  # preserve orignal names:
  rlab <- colnames(df)
  # make syntactically valid names:
  colnames(df) <- paste0("round", seq_along(df))

  # add attributes:
  attr(df, "config") <- rep(ScoreDirection, length = NCOL(df))
  attr(df, "roundtotals") <- rep(RoundTotals, length = NCOL(df))
  attr(df, "pptlabels") <- plab
  attr(df, "roundlabels") <- rlab
  return(df)
}

propscore_quiz <- function(q) {
  has_roundtotals <- any(is.na(attr(q, "roundtotals")))
  if (has_roundtotals) {
    stop("Check provided roundtotals: see read_quiz()")
  }
  res <- sweep(q, 2, attr(q, "roundtotals"), "/")
  attributes(res) <- attributes(q)
  return(res)
}

rankscore_quiz <- function(q) {
  sdf <- sweep(q,
               MARGIN = 2,
               STATS = attr(q, "config"),
               FUN = `*`)
  scores <- data.frame(lapply(sdf, rank, ties.method = "min", na.last = "keep"))
  attributes(scores) <- attributes(q)
  return(scores)
}

add_quizmean <- function(x) {
  x$FinalAverageRank <- apply(x, 1, mean, na.rm = T)
  attr(x, "roundlabels") <- c(attr(x, "roundlabels"), "Final Average")
  return(x)
}

cummean_noNA <- function(x) {
  # without NAs we would run cumsum(x) / seq.along(x)
  # however NAs must be specially coded to not increment cumsum(x), or #
  #   or seq.along(x)
  #
  # So if x = 1, NA, 3 we want cumsum to give 1, 1, 4
  # And seq.along to give 1, 1, 2
  num <- x <- as.numeric(x)
  num[is.na(num)] <- 0
  denom <- cumsum(as.numeric(!is.na(x))) # increments 0 if NA and 1 otherwise.
  denom[denom == 0] <- NA
  return(cumsum(num) / denom)
}

cumulate_scores <- function(x) {
  res <- data.frame(t(apply(x, 1, cummean_noNA)))
  attributes(res) <- attributes(x)
  return(res)
}

tidy_quizobject <- function(x) {
  res <- x
  colnames(res) <- attr(x, "roundlabels")

  res <- data.frame(Player = attr(x, "pptlabels"), res, check.names = FALSE)
  res <- pivot_longer(res, cols = !Player, values_to = "y", names_to = "Round")

  res$Player <- factor(res$Player, levels = attr(x, "pptlabels"))
  res$Round <- factor(res$Round, levels = attr(x, "roundlabels"))
  return(res)
}

plot_scores <- function(x, ranked_y = TRUE) {
  p <- tidy_quizobject(x)

  ylab <- "Rank"
  if (!ranked_y) ylab <- "Score"

  pp <- p %>%
    filter(!is.na(y)) %>%
    ggplot(aes(y = y, x = Round, colour = Player, group = Player)) +
    geom_line(aes()) +
    geom_point() +
    scale_colour_brewer(palette = "Paired") +
    ylab(ylab) +
    theme_classic() +
    theme(panel.background = element_rect(fill = "grey90")) +
    theme(axis.text.x = element_text(angle = 45, vjust = 0.5))

  if (ranked_y) {
    pp <- pp +
      scale_y_reverse(breaks = seq(nrow(x)))
  }

  return(pp)
}
