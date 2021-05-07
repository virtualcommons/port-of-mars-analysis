round_end_survey_load <- function() {
  headers <- colnames(readr::read_csv("input/raw/2021-03/surveys/round-1_2021-04-11.csv", n_max=0))
  data <- readr::read_csv("input/raw/2021-03/surveys/round-1_2021-04-11.csv", skip = 2)
  colnames(data) <- headers
  data
}

cultural_survey_load <- function() {
  headers <- colnames(readr::read_csv("input/raw/2021-03/surveys/round-1-cultural-survey_2021-04-11.csv", n_max=0))
  data <- readr::read_csv("input/raw/2021-03/surveys/round-1-cultural-survey_2021-04-11.csv", skip = 2)
  colnames(data) <- headers
  data
}
