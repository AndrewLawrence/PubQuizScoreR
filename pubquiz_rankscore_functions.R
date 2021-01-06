# Functions to use in the project:#


# A 'quiz' is a data.frame of
#   it contains per-round scores (columns) for each participant (rows)
#   additionally it has a config attribute telling whether larger is
#   better (for the round). This is set from the first row of the input.
#
# The input should be a CSV (with headers) using NA for any missed rounds,
#   the first column should be called 'player' and contain participant names.
#   remaining columns contain the results of quiz rounds and the column
#   header will be used to label the round.

read_quiz <- function(f, config = -1) {
  # f is a path to a file
  # config is a vector which is castable to the number of rounds
  #   the sign of each element of config determines whether smaller scores
  #   are better (1), or larger scores are better (-1)
  df <- read.csv(f, stringsAsFactors = FALSE, check.names = FALSE)
  #cfg <- df[1,]
  plab <- df[,1]
  df <- df[,-1]
  # preserve orignal names:
  rlab <- colnames(df)
  # make syntactically valid names:
  colnames(df) <- paste0("round", 1:ncol(df))
  # fixrownames:
  rownames <- 1:NROW(df)

  attr(df, "config") <- rep(config, length = NCOL(df))
  attr(df, "pptlabels") <- plab
  attr(df, "roundlabels") <- rlab
  return(df)
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

totalize <- function(x) {
  x$FinalAverageRank <- apply(x, 1, mean, na.rm = T)
  attr(x, "roundlabels") <- c(attr(x, "roundlabels"), "Final Average Rank")
  return(x)
}

cummean_noNA <- function(x) {
  # without NAs we would run cumsum(x) / seq.along(x)
  # however NAs must be specially coded to not increment cumsum(x), or #
  #   or seq.along(x)
  # cumsum(c(1,NA,3)) = c(1, 1, 4)
  # seq.along(c(1,NA,3)) = c(1, 1, 2)
  vals <- x <- as.numeric(x)
  vals[is.na(vals)] <- 0
  divs <- cumsum(as.numeric(!is.na(x))) # increments 0 if NA and 1 otherwise.
  divs[divs == 0] <- NA
  return(cumsum(vals) / divs)
}

cumulate_rankscores <- function(x) {
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
  if ( ! ranked_y ) ylab <- "Score"

  pp <- p %>% filter(!is.na(y)) %>%
    ggplot(aes(y = y, x = Round, colour = Player, group = Player)) +
    geom_line(aes()) +
    geom_point() +
    scale_colour_brewer(palette = "Paired") +
    ylab(ylab) +
    theme_classic() +
    theme(panel.background = element_rect(fill = "grey90")) +
    theme(axis.text.x = element_text(angle = 45, vjust = 0.5))

  if ( ranked_y ) {
    pp <- pp +
      scale_y_reverse(breaks = seq(nrow(x)))
  }

  return(pp)
}
