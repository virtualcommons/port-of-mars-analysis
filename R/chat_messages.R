chat_messages_tournament_load <- function(tournament_dir) {
  base_dir <- fs::path("input/raw", tournament_dir, "games")
  tournament_rounds <- as.integer(fs::path_file(fs::dir_ls(base_dir)))
  dplyr::bind_rows(purrr::map(
    tournament_rounds,
    function(tournament_round) {
      readr::read_csv(fs::path(base_dir, tournament_round, "processed/chatMessages.csv")) %>%
        dplyr::mutate(tournament = tournament_dir, tournament_round = tournament_round) %>%
        dplyr::relocate(tournament, tournament_round)
    }
  ))
}

chat_messages_tournament_save <- function(chat_messages_tournament, tournament_dir) {
  path <- fs::path("output", tournament_dir, "chat_messages.csv")
  readr::write_csv(chat_messages_tournament, path)
}

