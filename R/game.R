library(magrittr)

game_events_load <- function() {
  readr::read_csv("input/raw/2021-03/games/1/processed/gameEvent.csv") %>%
    # first record in dump is recorded twice so remove one with improperly serialized snapshot
    dplyr::group_by(id) %>%
    dplyr::filter(stringr::str_starts(payload, "\\[", negate = TRUE)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(dateCreated = stringr::str_remove_all(dateCreated, " GMT\\+0000 \\(Coordinated Universal Time\\)")) %>%
    dplyr::mutate(timestamp = lubridate::parse_date_time(dateCreated, orders="amdYHMS"))
}

players_load <- function() {
  readr::read_csv("input/raw/2021-03/games/1/processed/player.csv")
}

player_investments_load <- function() {
  readr::read_csv("input/raw/2021-03/games/1/processed/playerInvestment.csv")
}

game_events <- game_events_load()
players <- players_load()
player_investments <- player_investments_load()

ROLES <- unique(players$role) 
GAME_IDS <- unique(players$gameId)
PKS <- tidyr::crossing(
  tibble::tibble(gameId = GAME_IDS),
  tibble::tibble(role = ROLES))
GAME_EVENTS_IDS <- tidyr::crossing(
  game_events %>% 
    dplyr::distinct(gameId, roundFinal) %>% 
    dplyr::rename(round = "roundFinal"),
  tibble::tibble(role = ROLES))

JOIN_CRITERIA_ROUND_FINAL <- c("gameId" = "gameId", "round" = "roundFinal", "role" = "role")

# Chat?
game_count_chat_events_by_round_get <- function(game_events) {
  chat_counts <- game_events %>%
    dplyr::filter(type == "sent-chat-message") %>%
    dplyr::filter(role != "Server") %>%
    dplyr::group_by(gameId, roundFinal, role) %>%
    dplyr::summarise(chat_message_count = dplyr::n())
  GAME_EVENTS_IDS %>%
    dplyr::left_join(chat_counts, by = JOIN_CRITERIA_ROUND_FINAL) %>%
    tidyr::replace_na(replace = list(chat_message_count = 0))
}

game_count_chat_events_by_round <- game_count_chat_events_by_round_get(game_events)

# SH?
game_invest_system_health_get <- function(player_investments) {
  system_health <- player_investments %>%
    dplyr::filter(name == "finalInvestment") %>%
    dplyr::filter(investment == "systemHealth") %>%
    dplyr::select(gameId, roundFinal, role, sh = value)
  GAME_EVENTS_IDS %>%
    dplyr::left_join(system_health, by = JOIN_CRITERIA_ROUND_FINAL)
}

game_invest_system_health <- game_invest_system_health_get(player_investments)

#
game_system_health_at_round_start_get <- function(game_events) {
  game_events %>%
    dplyr::group_by(gameId, roundFinal) %>%
    dplyr::filter(id == min(id)) %>%
    dplyr::select(id, gameId, roundFinal, systemHealthFinal, phaseFinal) %>%
    dplyr::distinct(gameId, roundFinal, systemHealthFinal) %>%
    dplyr::ungroup()
}

game_system_health_at_round_start <- game_system_health_at_round_start_get(game_events)

# T?
game_count_trade_events_by_round_get <- function(game_events) {
  sent_trade_info_get <- function(payload) {
    trade <- jsonlite::fromJSON(payload)
    list(
      trade_id = trade$id,
      sender = trade$sender$role,
      recipient = trade$recipient$role
    )
  }
  
  accepted_trade_info_get <- function(payload) {
    trade <- jsonlite::fromJSON(payload)
    trade$id
  }
  
  sent_trades <- game_events %>%
    dplyr::filter(type == 'sent-trade-request')
  sent_trades <- sent_trades %>%
    dplyr::bind_cols(purrr::map_dfr(sent_trades$payload, sent_trade_info_get)) %>%
    dplyr::select(id, gameId, roundFinal, trade_id, sender, recipient)
  
  accepted_trades <- game_events %>%
    dplyr::filter(type == 'accepted-trade-request')
  accepted_trades <- accepted_trades %>%
    dplyr::mutate(trade_id = purrr::map_chr(accepted_trades$payload, accepted_trade_info_get)) %>%
    dplyr::select(trade_id)
  
  
  trades <- sent_trades %>%
    dplyr::inner_join(accepted_trades, by = c("trade_id" = "trade_id")) %>%
    dplyr::select(-trade_id) %>%
    tidyr::pivot_longer(cols=dplyr::all_of(c("sender", "recipient")), names_to="trade_role", values_to="role") %>%
    dplyr::group_by(gameId, roundFinal, role) %>%
    dplyr::summarise(trades_accepted_count = dplyr::n())
  trades
}

game_count_trade_events_by_round <- game_count_trade_events_by_round_get(game_events)

# Time-{Phase}?
game_phase_duration_by_round_get <- function(game_events) {
  grouped_events <- game_events %>%
    dplyr::group_by(gameId, roundFinal, phaseFinal) %>%
    dplyr::filter(!(phaseFinal %in% c("defeat", "victory")))
  phase_begin_timestamp <- grouped_events %>%
    dplyr::filter(id == min(id)) %>%
    dplyr::select(id, gameId, round = roundFinal, phase = phaseFinal, timestamp_begin = timestamp)
  phase_end_timestamp <- grouped_events %>%
    dplyr::filter(id == max(id)) %>%
    dplyr::select(id, gameId, round = roundFinal, phase = phaseFinal, timestamp_end = timestamp)
  
  duration <- phase_begin_timestamp %>%
    dplyr::left_join(
      phase_end_timestamp %>% dplyr::rename(id_end = id), 
      by = c("gameId" = "gameId", "round" = "round", "phase" = "phase")) %>%
    dplyr::mutate(duration = timestamp_end - timestamp_begin)
  
  duration %>%
    dplyr::select(gameId, round, phase, duration) %>%
    tidyr::pivot_wider(names_from = phase, names_prefix = "duration_", values_from = duration)
}

game_phase_duration_by_round <- game_phase_duration_by_round_get(game_events)

# points
game_end_player_points_get <- function(game_events) {
  role_points_get <- function(payload) {
    points <- jsonlite::fromJSON(payload)
    points
  }
  
  events_end_game <- game_events %>%
    dplyr::filter(type %in% c("entered-victory-phase", "entered-defeat-phase")) %>%
    dplyr::select(gameId, type, payload)
  
  events_end_game %>%
    dplyr::bind_cols(purrr::map_dfr(events_end_game$payload, role_points_get)) %>%
    dplyr::select(-payload) %>%
    tidyr::pivot_longer(cols = dplyr::all_of(ROLES), names_to="role", values_to="points") %>%
    dplyr::group_by(gameId) %>%
    dplyr::mutate(survived = type == "entered-victory-phase") %>%
    dplyr::mutate(won = (points == max(points)) & survived) %>%
    dplyr::select(-type) %>%
    dplyr::ungroup()
}

game_end_player_points <- game_end_player_points_get(game_events)

# bot, anyBotGroup
game_bot_statistics_get <- function(game_events) {
  partial_bct <- game_events %>% 
    dplyr::filter(type == "bot-control-taken") %>% 
    dplyr::select(gameId, payload) %>%
    dplyr::mutate(role = purrr::map_chr(payload, function(p) jsonlite::fromJSON(p)$role)) %>%
    dplyr::distinct(gameId, role) %>%
    dplyr::mutate(bot = TRUE) 
  PKS %>%
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
