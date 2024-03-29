# ==== INTRODUCTION ====
# assembles individual games in tournament rounds into a single "tournament"
# dataframe and provides helper functions to write that dataframe out

tournament_load <- function(tournament_dir, max_game_rounds) {
  game_tournament <- game_tournament_load(tournament_dir, max_game_rounds)
  survey_tournament <- survey_tournament_load(
    tournament_dir,
    game_tournament_keys = game_tournament %>% 
      dplyr::select(tournament, tournament_round, participant_id, invite_id))
  
  if (nrow(game_tournament) == nrow(survey_tournament)) {
    return(game_tournament %>%
      dplyr::inner_join(survey_tournament, by = c("tournament", "tournament_round", "participant_id", "invite_id"))
    )
  } else {
    warning("Game records and survey records do not match, consider checking for duplicates or missing rows")
    return(game_tournament %>%
      dplyr::left_join(survey_tournament, by = c("tournament", "tournament_round", "participant_id", "invite_id"))
    )
  }
}

tournament_write <- function(tournament_dir, tournament) {
  path <- fs::path("output", tournament_dir)
  fs::dir_create(path, recurse = TRUE)
  readr::write_csv(tournament, fs::path(path, "tournament.csv"), na="")
}

tournament_codebook_create <- function(max_game_rounds) {
  game_metadata <- game_metadata_expand(max_game_rounds)
  survey_metadata <- dplyr::bind_rows(
    survey_pre_renames,
    survey_pregame_after_round1_renames,
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
