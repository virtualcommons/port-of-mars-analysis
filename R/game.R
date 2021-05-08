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
GAME_EVENTS_IDS <- tidyr::crossing(game_events %>% dplyr::distinct(gameId, roundFinal) %>% dplyr::rename(round = "roundFinal"), tibble::tibble(role = ROLES))

# Chat?
game_count_chat_events_by_round_get <- function(game_events) {
  game_events %>%
    dplyr::filter(type == "sent-chat-message") %>%
    dplyr::filter(role != "Server") %>%
    dplyr::select(id, gameId, role)
    dplyr::group_by(gameId, roundFinal, role) %>%
    dplyr::summarise(chat_message_count = dplyr::n()) %>%
    tidyr::complete(gameId, role, fill = list(chat_message_count = 0))
}

game_count_chat_events_by_round <- game_count_chat_events_by_round_get(game_events)

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
game_player_used_screw_cards_get <- function(game_events) {
  get_purchases <- function(payload) {
    purchase_event <- jsonlite::fromJSON(payload)
    sh <- purchase_event$accomplishment$systemHealth
    sh <- ifelse(is.null(sh), 0, sh)
    list(
      small_screw_card = sh == -6,
      large_screw_card = sh == -13
    )
  }
  purchases <- game_events %>%
    dplyr::filter(type == "purchased-accomplishment")
  purchases <- purchases %>%
    dplyr::bind_cols(purrr::map_df(purchases$payload, get_purchases)) %>%
    dplyr::group_by(gameId, role, roundFinal) %>%
    dplyr::summarise(
      small_screw_card = as.logical(max(small_screw_card)),
      large_screw_card = as.logical(max(large_screw_card)))
  GAME_EVENTS_IDS %>%
    dplyr::left_join(purchases, by = c("gameId" = "gameId", "round" = "roundFinal", "role" = "role")) %>%
    tidyr::replace_na(replace = list(small_screw_card = FALSE, large_screw_card = FALSE))
}
