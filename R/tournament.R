tournament_load <- function(tournament_dir, max_game_rounds) {
  game_tournament <- game_tournament_load(tournament_dir = tournament_dir, max_game_rounds = max_game_rounds)
  survey_tournament <- survey_tournament_load(
    tournament_dir = tournament_dir,
    game_tournament_keys = game_tournament %>% 
      dplyr::select(tournament, tournament_round, participant_id, invite_id))
  
  assertthat::assert_that(nrow(game_tournament) == nrow(survey_tournament))
  
  game_tournament %>%
    dplyr::inner_join(survey_tournament, by = c("tournament", "tournament_round", "participant_id", "invite_id"))
}

tournament_write <- function(tournament_dir, tournament) {
  path <- fs::path("output", tournament_dir)
  fs::dir_create(path, recurse = TRUE)
  readr::write_csv(tournament, fs::path(path, "tournament.csv"), na="")
}

tournament_codebook_create <- function(max_game_rounds) {
  game_metadata <- game_metadata_expand(max_game_rounds = max_game_rounds)
  survey_metadata <- dplyr::bind_rows(
    survey_cultural_renames,
    survey_round_begin_renames,
    survey_round_end_renames
  ) %>% dplyr::filter(!(dest %in% c("participant_id", "invite_id")))
  dplyr::bind_rows(
    game_metadata,
    survey_metadata
  ) %>%
    dplyr::relocate(origin)
}

tournament_codebook_write <- function(tournament_dir, tournament_codebook) {
  path <- fs::path("output", tournament_dir)
  fs::dir_create(path, recurse = TRUE)
  readr::write_csv(tournament_codebook, fs::path(path, "tournament_codebook.csv"), na="")  
}
