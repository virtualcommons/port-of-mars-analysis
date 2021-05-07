library(magrittr)

game_events_load <- function(roles) {
  readr::read_csv("input/raw/2021-03/games/1/processed/gameEvent.csv") %>%
    dplyr::mutate_at(dplyr::vars(role), factor)
}

players_load <- function() {
  readr::read_csv("input/raw/2021-03/games/1/processed/player.csv")
}

game_events <- game_events_load()
players <- players_load()

ROLES <- unique(players$role) 
GAME_IDS <- unique(players$gameId)
PKS <- tidyr::crossing(
  tibble::tibble(gameId = GAME_IDS),
  tibble::tibble(role = ROLES))

# Chat?
game_count_chat_events_by_round <- function(game_events) {
  
}

# SH?
game_invest_system_health_by_round_start

#
game_invest_system_health_by_round_end <- function(player_investments) {
  
}

# T?
game_count_trade_events_by_round <- function(game_events) {
  
}

# Time-{Phase}?
game_phase_duration_by_round <- function(game_events, phase) {
  
}

# points
game_end_player_points <- function(players) {
  
}

# bot, anyBotGroup
game_bot_statistics_get <- function(game_events) {
  partial_bct <- game_events %>% 
    dplyr::filter(type == "bot-control-taken") %>% 
    dplyr::select(gameId, payload) %>%
    dplyr::mutate(role = purrr::map_chr(payload, function(p) jsonlite::fromJSON(p)$role)) %>%
    dplyr::distinct(gameId, role) %>%
    dplyr::mutate(bot = TRUE) 
  bct <- PKS %>%
    dplyr::left_join(partial_bct, by = c("gameId" = "gameId", "role" = "role")) %>%
    dplyr::mutate(bot=tidyr::replace_na(bot, FALSE)) %>%
    dplyr::group_by(gameId) %>%
    dplyr::mutate(anyBot = as.logical(max(bot))) %>%
    dplyr::ungroup()
}

game_bot_statistics <- game_bot_statistics_get(game_events)

# screw card small, screw card large
game_player_used_screw_cards <- function(game_events) {
  
}