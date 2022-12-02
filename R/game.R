library(magrittr)

#' Load victory points from file
#'
#' @param prefix the directory to the game events file (victoryPoints.csv)
#'
#' @example victory_points_load("input/2021-03/games/1/processed")
victory_points_load <- function(prefix) {
  readr::read_csv(fs::path(prefix, "victoryPoint.csv"))
}


#' Load game events from file
#' 
#' @param prefix the directory to the game events file (gameEvents.csv)
#' 
#' @example game_events_load("input/2021-03/games/1/processed")
game_events_load <- function(prefix) {
  readr::read_csv(fs::path(prefix, "gameEvent.csv")) %>%
    # first record in dump is recorded twice so remove one with improperly serialized snapshot
    dplyr::group_by(id) %>%
    dplyr::filter(stringr::str_starts(payload, "\\[", negate = TRUE)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(dateCreated = stringr::str_remove_all(dateCreated, " GMT\\+0000 \\(Coordinated Universal Time\\)")) %>%
    dplyr::mutate(timestamp = lubridate::parse_date_time(dateCreated, orders="amdYHMS"))
}

game_players_load <- function(prefix) {
  readr::read_csv(fs::path(prefix, "player.csv"))
}

game_player_investments_load <- function(prefix) {
  readr::read_csv(fs::path(prefix, "playerInvestment.csv"))
}

game_keys_get <- function(game_events, players, max_rounds) {
  role_ids <- unique(players$role)
  game_ids <- unique(game_events$gameId)
  rounds <- 1:max_rounds
  
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
      tibble::tibble(role = role_ids)),
    game_round_role_all = tidyr::crossing(
      tibble::tibble(gameId = game_ids),
      tibble::tibble(round = rounds),
      tibble::tibble(role = role_ids)
    )
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

GAME_METADATA <- tibble::tribble(
  ~dest, ~desc, ~is_by_round,
  "tournament", "name of tournament (corresponds to directory tournament input was put into)", FALSE,
  "tournament_round", "round of tournament", FALSE,
  "game_id", "id of game in db", FALSE,
  "role", "role of player", FALSE,
  "participant_id", "id of participant in db and qualtrics", FALSE,
  "invite_id", "id of invite in db and qualtrics", FALSE,
  "chat_message_count", "number of chat messages entered by end of round", TRUE,
  "investment_system_health", "time units of investment into system health in beginning of round", TRUE,
  "system_health", "system health at the beginning of the round", TRUE,
  "trades_accepted_count", "trades accepted by end of round", TRUE,
  "duration_new_round", "duration of new round phase in seconds", TRUE,
  "duration_events", "duration of mars event phase in seconds", TRUE,
  "duration_invest", "duration of invest phase in seconds", TRUE,
  "duration_trade", "duration of trade phase in seconds", TRUE,
  "duration_purchase", "duration of purchase phase in seconds", TRUE,
  "duration_discard", "duration of discard phase in seconds", TRUE,
  "survived", "players survived the game (system health never went to zero)", FALSE,
  "points", "player points at end of game", FALSE,
  "points_end", "player points at end of round", TRUE,
  "won", "player won the game", FALSE,
  "bot", "was role a bot at any point in the game", FALSE,
  "anyBot", "was any role a bot at any point in the game", FALSE,
  "bot_duration", "seconds a bot was active in a game", FALSE,
  "bot_at_end_of_game", "was the bot active at the end of the game", FALSE,
  "purchased_screw_card_small", "player purchased a small screw card", TRUE,
  "purchased_screw_card_large", "player purchased a large screw card", TRUE,
  "round_count", "maximum number of rounds", TRUE
)

game_metadata_expand <- function(max_game_rounds) {
  GAME_METADATA %>%
    dplyr::mutate(round = ifelse(is_by_round, max_game_rounds, 1)) %>%
    dplyr::group_by(dest) %>%
    tidyr::expand(round = seq(round), is_by_round, desc) %>%
    dplyr::mutate(src = dest) %>%
    dplyr::mutate(dest = ifelse(is_by_round, glue::glue("{dest}_round{round}", round = sprintf("%02d", round)), dest)) %>%
    dplyr::select(-c(is_by_round, round)) %>%
    dplyr::relocate(dest, src, desc) %>%
    dplyr::mutate(origin = "game info")
}

game_round_count_get <- function(game_events, game_role) {
  tidyr::crossing(
    game_role,
    game_events %>%
      dplyr::summarize(round_count = max(roundFinal)))
}

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
    dplyr::select(gameId, round, role, availableTimeBlocks, investment_system_health = value) # place additional playerInvestment.csv fields here
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

game_victory_point_by_end_round_get <- function(victory_points, game_events, game_round_role) {
  vp <- game_round_role %>%
    dplyr::left_join(
      game_events %>%
        dplyr::rename(round = roundFinal) %>%
        tidyr::expand(tidyr::nesting(gameId, round), role) %>%
        dplyr::filter(role != 'Server') %>%
        dplyr::left_join(
          victory_points %>%
            dplyr::group_by(gameId, roundFinal, role) %>%
            dplyr::filter(id == max(id)) %>%
            dplyr::filter(dplyr::row_number() == 1) %>%
            dplyr::ungroup() %>%
            dplyr::select(gameId, role, round = roundFinal, points = victoryPoints)
        ) %>%
        dplyr::group_by(gameId, role) %>%
        dplyr::arrange(gameId, round, role) %>%
        tidyr::fill(points, .direction = 'down'),
      by = c("gameId", "round", "role")
    )
  vp
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
    tidyr::pivot_longer(cols = dplyr::all_of(roles), names_to="role", values_to="points_end") %>%
    dplyr::group_by(gameId) %>%
    dplyr::mutate(survived = type == "entered-victory-phase") %>%
    dplyr::mutate(won = (points_end == max(points_end)) & survived) %>%
    dplyr::select(-type) %>%
    dplyr::ungroup()
}

game_bot_duration_get <- function(game_events) {
  add_start_end_if_missing <- function(df) {
    if (!("start" %in% colnames(df))) {
      df <- df %>%
        dplyr::mutate(start = lubridate::Date(nrow(df)))
    }
    if (!("end" %in% colnames(df))) {
      df <- df %>%
        dplyr::mutate(end = lubridate::Date(nrow(df)))
    }
    df
  }
  
  game_role_bot_takeovers <- game_events %>%
    dplyr::filter(type %in% c("bot-control-taken", "bot-control-relinquished")) %>%
    dplyr::arrange(id) %>%
    dplyr::group_by(gameId, role) %>%
    dplyr::filter(id == max(id)) %>%
    dplyr::ungroup() %>%
    dplyr::filter(type == "bot-control-taken") %>%
    dplyr::distinct(gameId, role)
  
  missing_end_events <- tidyr::crossing(game_events %>%
                                          dplyr::group_by(gameId) %>%
                                          dplyr::filter(any(type %in% c("bot-control-taken", "bot-control-relinquished"))) %>%
                                          dplyr::ungroup() %>%
                                          dplyr::filter(type %in% c("entered-defeat-phase", "entered-victory-phase")) %>%
                                          dplyr::mutate(type = "end") %>%
                                          dplyr::select(gameId, type, timestamp),
                                        tibble::tibble(role = setdiff(unique(game_events$role), 'Server'))) %>%
    dplyr::inner_join(game_role_bot_takeovers) %>%
    dplyr::mutate(end_game = TRUE)
  
  bc <- game_events %>%
    dplyr::select(gameId, type, payload, timestamp, role) %>%
    dplyr::filter(type %in% c("bot-control-taken", "bot-control-relinquished")) %>%
    dplyr::mutate(type = dplyr::if_else(type == "bot-control-taken", "start", type)) %>%
    dplyr::mutate(type = dplyr::if_else(type == "bot-control-relinquished", "end", type)) %>%
    dplyr::select(-payload) %>%
    dplyr::group_by(gameId) %>%
    dplyr::filter(any(type == "start")) %>%
    dplyr::mutate(end_game = FALSE) %>%
    dplyr::union_all(missing_end_events) %>%
    dplyr::arrange(gameId, timestamp) %>%
    dplyr::group_by(gameId, role) %>%
    dplyr::mutate(end_game = any(end_game)) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(gameId, role, type) %>%
    dplyr::mutate(n = dplyr::row_number()) %>%
    dplyr::mutate(type = factor(type, levels = c("start", "end"))) %>%
    # https://github.com/tidyverse/tidyr/issues/770
    tidyr::pivot_wider(names_from = "type", values_from = "timestamp") %>%
    add_start_end_if_missing() %>%
    dplyr::mutate(duration = end - start) %>%
    dplyr::group_by(gameId, role) %>%
    dplyr::summarise(bot_duration = ifelse(is.na(sum(duration)), 0, sum(duration)), 
                     bot_at_end_of_game = ifelse(is.na(any(end_game)), FALSE, any(end_game)))
  
  tidyr::crossing(
    game_events %>% dplyr::distinct(gameId),
    game_events %>% dplyr::distinct(role) %>% dplyr::filter(role != 'Server')
  ) %>%
    dplyr::left_join(bc)
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

game_player_discards_by_round_get <- function(game_events) {
  # only include game rounds that have a discard phase
  discard_key <- game_events %>%
    dplyr::filter(role != 'Server') %>%
    dplyr::filter(phaseFinal == 'discard') %>%
    dplyr::rename(round = roundFinal) %>%
    tidyr::expand(tidyr::nesting(gameId, round), role)
  
  discards_by_round <- game_events %>%
    dplyr::mutate(is_discard = type == "discarded-accomplishment") %>%
    dplyr::filter(role != 'Server') %>%
    dplyr::rename(round = roundFinal) %>%
    dplyr::group_by(gameId, round, role) %>%
    dplyr::summarise(discard_count = sum(is_discard))
  
  discard_key %>%
    dplyr::left_join(discards_by_round) %>%
    tidyr::replace_na(list(discard_count = 0))
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
      purchased_screw_card_small = as.logical(max(small_screw_card)),
      purchased_screw_card_large = as.logical(max(large_screw_card))) %>%
    dplyr::rename(round = roundFinal)
  game_round_role %>%
    dplyr::left_join(purchases, by = GAME_JOIN_KEYS$game_round_role) %>%
    tidyr::replace_na(replace = list(purchased_screw_card_small = FALSE, purchased_screw_card_large = FALSE))
}

game_tournament_round_load <- function(tournament_dir, tournament_round, max_game_rounds) {
  base_path <- fs::path("input/", tournament_dir, "games", tournament_round, "processed")
  game_events <- game_events_load(base_path)
  player_investments <- game_player_investments_load(base_path)
  victory_points <- victory_points_load(base_path)
  players <- game_players_load(base_path)
  
  assertthat::assert_that(max(game_events$roundFinal) <= max_game_rounds)
  
  game_keys <- game_keys_get(
    game_events = game_events,
    players = players,
    max_rounds = max_game_rounds
  )
  
  game_role <- game_keys$game_role
  game_round <- game_keys$game_round
  game_round_role <- game_keys$game_round_role
  game_round_role_all <- game_keys$game_round_role_all
  
  round_count <- game_round_count_get(
    game_events = game_events,
    game_role = game_role
  )
  
  chat_event_count_by_round <- game_chat_event_count_by_round_get(
    game_events = game_events,
    game_round_role = game_round_role
  )
  
  invest_system_health_by_round <- game_invest_system_health_by_round_get(
    player_investments = player_investments,
    game_round_role = game_round_role
  )
  
  system_health_at_round_start <- game_system_health_at_round_start_get(game_events)
  
  trades_accepted_count_by_round <- game_trades_accepted_count_by_round_get(
    game_events,
    game_round_role = game_round_role
  )
  
  phase_duration_by_round <- game_phase_duration_by_round_get(game_events)
  
  player_points_by_round <- game_victory_point_by_end_round_get(
    victory_points = victory_points,
    game_events = game_events,
    game_round_role = game_round_role
  )
  
  player_discards_by_round <- game_player_discards_by_round_get(
    game_events = game_events
  )
  
  end_player_points <- game_end_player_points_get(
    game_events,
    roles = game_keys$role
  )
  
  bot_duration <- game_bot_duration_get(game_events)
  
  bot_statistics <- game_bot_statistics_get(
    game_events,
    game_role = game_role
  )
  
  player_used_screw_cards_by_round <- game_player_used_screw_cards_by_round_get(
    game_events,
    game_round_role = game_round_role
  )
  
  assertthat::assert_that(nrow(game_role) == nrow(end_player_points))
  assertthat::assert_that(nrow(game_role) == nrow(bot_duration))
  assertthat::assert_that(nrow(game_role) == nrow(bot_statistics))
  
  assertthat::assert_that(nrow(game_round) == nrow(system_health_at_round_start))
  assertthat::assert_that(nrow(game_round) == nrow(phase_duration_by_round))
  
  assertthat::assert_that(nrow(game_round_role) == nrow(chat_event_count_by_round))
  assertthat::assert_that(nrow(game_round_role) == nrow(invest_system_health_by_round))
  assertthat::assert_that(nrow(game_round_role) == nrow(player_used_screw_cards_by_round))
  assertthat::assert_that(nrow(game_round_role) == nrow(trades_accepted_count_by_round))
  
  game_role_key <- GAME_JOIN_KEYS$game_role
  game_round_key <- GAME_JOIN_KEYS$game_round
  game_round_role_key <- GAME_JOIN_KEYS$game_round_role
  
  player_key_data <- players %>%
    dplyr::select(gameId, participantId, inviteId, role) %>%
    dplyr::rename(
      game_id = gameId,
      participant_id = participantId,
      invite_id = inviteId
    )
  
  game_role_data <- game_role %>%
    dplyr::left_join(
      end_player_points,
      by = game_role_key
    ) %>%
    dplyr::left_join(
      bot_statistics,
      by = game_role_key
    ) %>%
    dplyr::left_join(
      bot_duration,
      by = game_role_key
    )
  
  game_round_role_data <- game_round_role_all %>%
    dplyr::left_join(
      system_health_at_round_start,
      by = game_round_key
    ) %>%
    dplyr::left_join(
      phase_duration_by_round,
      by = game_round_key
    ) %>%
    dplyr::left_join(
      chat_event_count_by_round,
      by = game_round_role_key
    ) %>%
    dplyr::left_join(
      invest_system_health_by_round,
      by = game_round_role_key
    ) %>%
    dplyr::left_join(
      trades_accepted_count_by_round,
      by = game_round_role_key
    ) %>%
    dplyr::left_join(
      player_discards_by_round,
      by = game_round_role_key
    ) %>%
    dplyr::left_join(
      player_used_screw_cards_by_round,
      by = game_round_role_key
    ) %>%
    dplyr::left_join(
      player_points_by_round,
      by = game_round_role_key
    ) %>%
    tidyr::pivot_wider(
      names_from = round,
      names_glue = "{.value}_round{sprintf('%02d', round)}",
      values_from = !c(gameId, round, role)
    )
  
  assertthat::assert_that(nrow(game_role_data) == nrow(game_round_role_data))
  
  game_round_role_data %>%
    dplyr::left_join(game_role_data, by = game_role_key) %>%
    dplyr::mutate(
      tournament = tournament_dir,
      tournament_round = tournament_round  
    ) %>%
    dplyr::left_join(
      round_count,
      by = game_role_key
    ) %>%
    dplyr::rename(game_id = gameId) %>%
    dplyr::left_join(
      player_key_data,
      by = c("game_id", "role")
    ) %>%
    dplyr::relocate(
      tournament,
      tournament_round,
      participant_id,
      invite_id
    )
}

game_tournament_load <- function(tournament_dir, max_game_rounds) {
  tournament_prefix <- fs::path("input/", tournament_dir, "games")
  tournament_rounds <- as.integer(fs::path_file(fs::dir_ls(tournament_prefix)))
  
  dplyr::bind_rows(purrr::map(
    tournament_rounds,
    function(tournament_round) 
      game_tournament_round_load(
        tournament_dir = tournament_dir,
        tournament_round = tournament_round,
        max_game_rounds = max_game_rounds
      )
  ))
}
