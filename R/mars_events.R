me_tournament_load <- function(tournament) {
  tournament_dir <- fs::path("input/raw", tournament, "games")
  tournament_rounds <- as.integer(fs::path_file(fs::dir_ls(tournament_dir)))
  mars_events <- purrr::map(tournament_rounds, ~ me_tournament_round_load(
    tournament_dir = tournament_dir,
    tournament = tournament,
    tournament_round = .))
  dplyr::bind_rows(mars_events)
}

me_augment_role <- function(name, description, roles) {
  ooc <- name == 'Out of Commission'
  for (role in roles) {
    inds <- which(ooc & stringr::str_detect(description, role))
    name[inds] <- glue::glue("Out of Commission ({role})")
  }
  name
}

me_augment_role_to_out_of_commission_events <- function(me) {
  roles <- c('Curator', 'Entrepreneur', 'Pioneer', 'Politician', 'Researcher')

  me %>%
    dplyr::mutate(name = me_augment_role(name=name, description=description, roles=roles))
}

me_tournament_round_load <- function(tournament_dir, tournament, tournament_round) {
  path <- fs::path(tournament_dir, tournament_round, "processed/marsEvent.csv")
  readr::read_csv(path) %>%
    dplyr::mutate(tournament = tournament, tournament_round = tournament_round) %>%
    dplyr::rename(game_id = gameId) %>%
    me_augment_role_to_out_of_commission_events()
}

me_count_by_game_round_get <- function(me) {
  me %>%
    dplyr::distinct(tournament, tournament_round, game_id, round, name, index) %>%
    dplyr::mutate(n = 1) %>%
    dplyr::group_by(tournament, tournament_round, game_id, round, name) %>%
    dplyr::summarize(n = sum(n)) %>%
    tidyr::pivot_wider(names_from = name, values_from = n, values_fill = 0, names_sort = TRUE)
}

me_write <- function(tournament) {
  me <- me_tournament_load(tournament)
  me_count_by_game_round <- me_count_by_game_round_get(me)
  readr::write_csv(me_count_by_game_round, fs::path("output", tournament, "mars_events_count_by_game_round.csv")
)
}