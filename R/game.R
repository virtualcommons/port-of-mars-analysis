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

game_players_load <- function() {
  readr::read_csv("input/raw/2021-03/games/1/processed/player.csv")
}

game_player_investments_load <- function() {
  readr::read_csv("input/raw/2021-03/games/1/processed/playerInvestment.csv")
}

game_keys_get <- function(game_events, players) {
  role_ids <- unique(players$role)
  game_ids <- unique(game_events$gameId)
  
  game_round <- game_events %>% 
    dplyr::distinct(gameId, roundFinal) %>% 
    dplyr::rename(round = "roundFinal")
  
  list(
    role = role_ids,
    game_role = tidyr::crossing(
      tibble::tibble(gameId = game_ids),
      tibble::tibble(role = role_ids)
    ),
    game_round = game_round,
    game_round_role = tidyr::crossing(
      game_round,
      tibble::tibble(role = role_ids))
  )
}

GAME_JOIN_KEYS <- list(
  game_role = c(
    "gameId" = "gameId",
    "role" = "role"
  ),
  
  game_round = c(
    "gameId" = "gameId",
    "round" = "round"
  ),
  
  game_round_role = c(
    "gameId" = "gameId",
    "round" = "round",
    "role" = "role"
  )
)

# Chat? gameId, round
game_chat_event_count_by_round_get <- function(game_events, game_round_role) {
  chat_counts <- game_events %>%
    dplyr::filter(type == "sent-chat-message") %>%
    dplyr::filter(role != "Server") %>%
    dplyr::rename(round = roundFinal) %>%
    dplyr::group_by(gameId, round, role) %>%
    dplyr::summarise(chat_message_count = dplyr::n())
  game_round_role %>%
    dplyr::left_join(chat_counts, by = GAME_JOIN_KEYS$game_round_role) %>%
    tidyr::replace_na(replace = list(chat_message_count = 0))
}

# SH?
game_invest_system_health_by_round_get <- function(player_investments, game_round_role) {
  system_health <- player_investments %>%
    dplyr::filter(name == "finalInvestment") %>%
    dplyr::filter(investment == "systemHealth") %>%
    dplyr::rename(round = roundFinal) %>%
    dplyr::select(gameId, round, role, investment_system_health = value)
  game_round_role %>%
    dplyr::left_join(system_health, by = GAME_JOIN_KEYS$game_round_role)
}

game_system_health_at_round_start_get <- function(game_events) {
  game_events %>%
    dplyr::group_by(gameId, roundFinal) %>%
    dplyr::filter(id == min(id)) %>%
    dplyr::select(gameId, roundFinal, systemHealthFinal) %>%
    dplyr::rename(round = roundFinal, system_health = systemHealthFinal) %>%
    dplyr::ungroup()
}

# T?
game_trades_accepted_count_by_round_get <- function(game_events, game_round_role) {
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
    dplyr::rename(round = roundFinal) %>%
    dplyr::group_by(gameId, round, role) %>%
    dplyr::summarise(trades_accepted_count = dplyr::n())
  game_round_role %>%
    dplyr::left_join(trades, GAME_JOIN_KEYS$game_round_role) %>%
    tidyr::replace_na(replace = list(trades_accepted_count = 0))
}

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
    tidyr::pivot_wider(names_from = phase, names_prefix = "duration_", values_from = duration) %>%
    dplyr::rename(duration_new_round = duration_newRound)
}

# points
game_end_player_points_get <- function(game_events, roles) {
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
    tidyr::pivot_longer(cols = dplyr::all_of(roles), names_to="role", values_to="points") %>%
    dplyr::group_by(gameId) %>%
    dplyr::mutate(survived = type == "entered-victory-phase") %>%
    dplyr::mutate(won = (points == max(points)) & survived) %>%
    dplyr::select(-type) %>%
    dplyr::ungroup()
}

# bot, anyBotGroup
game_bot_statistics_get <- function(game_events, game_role) {
  partial_bct <- game_events %>% 
    dplyr::filter(type == "bot-control-taken") %>% 
    dplyr::select(gameId, payload) %>%
    dplyr::mutate(role = purrr::map_chr(payload, function(p) jsonlite::fromJSON(p)$role)) %>%
    dplyr::distinct(gameId, role) %>%
    dplyr::mutate(bot = TRUE) 
  game_role %>%
    dplyr::left_join(partial_bct, by = GAME_JOIN_KEYS$game_role) %>%
    dplyr::mutate(bot=tidyr::replace_na(bot, FALSE)) %>%
    dplyr::group_by(gameId) %>%
    dplyr::mutate(anyBot = as.logical(max(bot))) %>%
    dplyr::ungroup()
}

# screw card small, screw card large
game_player_used_screw_cards_by_round_get <- function(game_events, game_round_role) {
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
      screw_card_small = as.logical(max(small_screw_card)),
      screw_card_large = as.logical(max(large_screw_card))) %>%
    dplyr::rename(round = roundFinal)
  game_round_role %>%
    dplyr::left_join(purchases, by = GAME_JOIN_KEYS$game_round_role) %>%
    tidyr::replace_na(replace = list(screw_card_small = FALSE, screw_card_large = FALSE))
}

game_round_data_get <- function() {
  game_events <- game_events_load()
  player_investments <- game_player_investments_load()
  players <- game_players_load()
  
  game_keys <- game_keys_get(
    game_events = game_events,
    players = players
  )
  
  game_role <- game_keys$game_role
  game_round <- game_keys$game_round
  game_round_role <- game_keys$game_round_role
  
  game_chat_event_count_by_round <- game_chat_event_count_by_round_get(
    game_events = game_events,
    game_round_role = game_round_role
  )
  
  game_invest_system_health_by_round <- game_invest_system_health_by_round_get(
    player_investments = player_investments,
    game_round_role = game_round_role
  )
  
  game_system_health_at_round_start <- game_system_health_at_round_start_get(game_events)
  
  game_trades_accepted_count_by_round <- game_trades_accepted_count_by_round_get(
    game_events,
    game_round_role = game_round_role
  )
  
  game_phase_duration_by_round <- game_phase_duration_by_round_get(game_events)
  
  game_end_player_points <- game_end_player_points_get(
    game_events,
    roles = game_keys$role
  )
  
  game_bot_statistics <- game_bot_statistics_get(
    game_events,
    game_role = game_role
  )
  
  game_player_used_screw_cards_by_round <- game_player_used_screw_cards_by_round_get(
    game_events,
    game_round_role = game_round_role
  )
  
  stopifnot(nrow(game_role) == nrow(game_end_player_points))
  stopifnot(nrow(game_role) == nrow(game_bot_statistics))

  stopifnot(nrow(game_round) == nrow(game_system_health_at_round_start))
  stopifnot(nrow(game_round) == nrow(game_phase_duration_by_round))
  
  stopifnot(nrow(game_round_role) == nrow(game_chat_event_count_by_round))
  stopifnot(nrow(game_round_role) == nrow(game_invest_system_health_by_round))
  stopifnot(nrow(game_round_role) == nrow(game_player_used_screw_cards_by_round))
  stopifnot(nrow(game_round_role) == nrow(game_trades_accepted_count_by_round))
  
  game_role_key <- GAME_JOIN_KEYS$game_role
  game_round_key <- GAME_JOIN_KEYS$game_round
  game_round_role_key <- GAME_JOIN_KEYS$game_round_role
  
  game_role_data <- game_role %>%
    dplyr::left_join(
      game_end_player_points,
      by = game_role_key
    ) %>%
    dplyr::left_join(
      game_bot_statistics,
      by = game_role_key
    )
  
  game_round_role_data <- game_round_role %>%
    dplyr::left_join(
      game_system_health_at_round_start,
      by = game_round_key
    ) %>%
    dplyr::left_join(
      game_phase_duration_by_round,
      by = game_round_key
    ) %>%
    dplyr::left_join(
      game_chat_event_count_by_round,
      by = game_round_role_key
    ) %>%
    dplyr::left_join(
      game_invest_system_health_by_round,
      by = game_round_role_key
    ) %>%
    dplyr::left_join(
      game_trades_accepted_count_by_round,
      by = game_round_role_key
    ) %>%
    dplyr::left_join(
      game_player_used_screw_cards_by_round,
      by = game_round_role_key
    )
}

game_round_role_data <- game_round_data_get()
