library(magrittr)

survey_renames_to_kv <- function(renames) {
  xs <- as.list(renames$src)
  names(xs) <- renames$dest
  xs
}

survey_filter_has_fks <- function(data) {
  data %>%
    dplyr::filter(!is.na(participant_id) & !is.na(invite_id))
}

survey_cultural_renames <- tibble::tribble(
  ~dest, ~src,
  "participant_id", "pid",
  "invite_id", "tid",
  "gender", "gender", 
  "man", "man",
  "cultural__start_date", "StartDate",
  "cultural__end_date", "EndDate",
  "cultural__survey_duration", "Duration (in seconds)",
  "cultural__risk_preference", "Q12",
  "cultural__situation1", "Q5",
  "cultural__situation2", "Q7",
  "cultural__situation3", "Q8",
  "cultural__situation4", "Q9",
  "cultural__situation5", "Q10",
  "cultural__situation6", "Q11",
  "cultural__most_entering", "Q15_1",
  "cultural__least_entering", "Q15_2",
  "cultural__most_in_store", "Q15_3",
  "cultural__fewest_in_store", "Q15_4",
  "common__i_am_a_leader", "Q4_1",
  "common__i_see_myself_as_a_leader", "Q4_2",
  "common__describe_leader", "Q4_3",
  "common__seen_as_leader", "Q4_4",
  "cultural__know_toc", "Q17",
  "cultural__describe_toc", "Q18",
  "cultural__agree_toc", "Q19"
) %>% dplyr::mutate(desc = "", origin = "cultural survey")

survey_cultural_load <- function(prefix) {
  kvs <- survey_renames_to_kv(survey_cultural_renames)
  columns <- names(kvs)
  path <- fs::path(prefix, "cultural.csv")
  headers <- colnames(readr::read_csv(path, n_max=0))
  data <- readr::read_csv(path, skip = 2)
  colnames(data) <- headers
  data %>%
    dplyr::mutate(
      StartDate = lubridate::mdy_hm(StartDate),
      EndDate = lubridate::mdy_hm(EndDate)) %>%
    dplyr::rename(gender = Q2) %>%
    dplyr::mutate(
      man = gender == 2
    ) %>%
    dplyr::rename(!!! kvs) %>%
    dplyr::select(!!! columns) %>%
    survey_filter_has_fks()
}

survey_round_begin_renames <- tibble::tribble(
  ~dest, ~src,
  "participant_id", "pid",
  "invite_id", "tid",
  "pre__start_date", "StartDate",
  "pre__end_end", "EndDate",
  "pre__survey_duration", "Duration (in seconds)",
  "common__i_am_a_leader", "Q2_1",
  "common__i_see_myself_as_a_leader", "Q2_2",
  "common__describe_leader", "Q2_3",
  "common__seen_as_leader", "Q2_4",
  "pre__change_crisis_situations", "Q2_5",
  "pre__change_stress", "Q2_6",
  "pre__solve_problems_creatively", "Q2_7",
  "pre__change_deals_in_uncertain_situations", "Q2_8",
  "pre__try_other_ways_to_play", "Q2_9",
  "pre__adapt_to_my_teammates_play", "Q2_10",
  "pre__takeaways_from_previous_round", "Q3",
  "pre__will_you_do_something_different", "Q4"
) %>% dplyr::mutate(desc = "", origin = "pre game survey")

survey_round_begin_load <- function(prefix) {
  kvs <- survey_renames_to_kv(survey_round_begin_renames)
  columns <- names(kvs)
  path <- fs::path(prefix, "pre.csv")
  headers <- colnames(readr::read_csv(path, n_max=0))
  data <- readr::read_csv(path, skip = 2)
  colnames(data) <- headers
  data %>%
    dplyr::rename(!!! kvs) %>%
    dplyr::select(!!! columns) %>%
    survey_filter_has_fks()
}

survey_round_end_renames <- tibble::tribble(
  ~dest, ~src, ~desc,
  "participant_id", "pid", "",
  "invite_id", "tid", "",
  "post__start_date", "StartDate", "",
  "post__end_date", "EndDate", "",
  "post__survey_duration", "Duration (in seconds)", "",
  "post__leader_role_curator", "leader_role_curator", "",
  "post__leader_role_entrepreneur", "leader_role_entrepreneur", "",
  "post__leader_role_pioneer", "leader_role_pioneer", "",
  "post__leader_role_politician", "leader_role_politician", "",
  "post__leader_role_researcher", "leader_role_researcher", "",
  "post__leader_bc_acting_friendly_and_approachable", "Q1_1", "Why do you consider them to be the leader? - Acting friendly and approachable",
  "post__leader_bc_welfare", "Q1_2", "Why do you consider them to be the leader? - Acting concerned for others' personal welfare",
  "post__leader_bc_supportive", "Q1_3", "Why do you consider them to be the leader? - Acting supportive when talking to others",
  "post__leader_bc_expectations_clear", "Q1_4", "Why do you consider them to be the leader? - Letting others know what was expected of them",
  "post__leader_bc_encourage_opinion_sharing", "Q1_5", "Why do you consider them to be the leader? - Encouraging others to share their opinions",
  "post__leader_bc_definite_goals_and_standards", "Q1_6", "Why do you consider them to be the leader? - Maintaining definite goals and standards with others",
  "post__leader_bc_contribute_task_effectiveness", "Q1_7", "Why do you consider them to be the leader? - Contributing to the effectiveness of the tasks",
  "post__leader_bc_influential_in_final_outcome", "Q1_8", "Why do you consider them to be the leader? - Exerting influence in determining the final outcome of the game",
  "post__leader_bc_exhibited_leadership", "Q1_9", "Why do you consider them to be the leader? - Exhibiting leadership",
  "post__leader_bc_control_over_team_activities", "Q1_10", "Why do you consider them to be the leader? - Exhibiting control over the team’s activities",
  "post__leader_bc_likely_be_vote_leader_on_replay", "Q1_11", "Why do you consider them to be the leader? - Likely to be voted leader if we play this game again.",
  "post__group_adjusts_to_changes_well", "Q3_1", " Group members adjust well to the changes that happen in the game.",
  "post__group_confidence_in_problem_solving", "Q3_2", "When a problem occurs, the members of this group manage to solve it.",
  "post__group_could_work_together_a_long_time", "Q3_3", "The members of this group could work a long time together.",
  "post__group_i_see_achievements_as_a_success", "Q3_4", "I see our group’s achievements in this game as a success.",
  "post__group_i_learned_lessons_from_game", "Q3_5", "I learned important lessons from this game.",
  "post__group_work_promites_my_growth", "Q3_6", "Working in this group promotes my growth.",
  "post__group_we_attained_our_collective_goals", "Q3_7", "The members of this group attain our goals for the game.",
  "post__group_members_played_well", "Q3_8", "The members of this group played the game well.",
  "post__group_was_productive", "Q3_9", "This group is productive.",
  "post__group_social_climate_was_good", "Q3_10", "The social climate in our group is good.",
  "post__group_relationships_were_harmonious", "Q3_11", "In our group, relationships are harmonious.",
  "post__group_we_get_along_with_each_other", "Q3_12", "In our group, we get along with each other."
) %>% dplyr::mutate(origin = "post game survey")

survey_round_end_load <- function(prefix) {
  kvs <- survey_renames_to_kv(survey_round_end_renames)
  columns <- names(kvs)
  path <- fs::path(prefix, "post.csv")
  headers <- colnames(readr::read_csv(path, n_max=0))
  data <- readr::read_csv(path, skip = 2)
  colnames(data) <- headers
  data %>%
    dplyr::mutate(
      leader_role_curator = Q2 == 1,
      leader_role_entrepreneur = Q2 == 2,
      leader_role_pioneer = Q2 == 3,
      leader_role_politician = Q2 == 4,
      leader_role_researcher = Q2 == 5
    ) %>%
    dplyr::rename(!!! kvs) %>%
    dplyr::select(!!! columns) %>%
    survey_filter_has_fks()
}

survey_invite_id_mapper_get <- function(game_tournament_data) {
  tournament_keys <- game_tournament_data %>% 
    dplyr::select(tournament, tournament_round, participant_id, invite_id) %>%
    dplyr::mutate(is_first_round = tournament_round == 1)
  tournament_keys %>%
    dplyr::filter(is_first_round) %>% 
    dplyr::inner_join(
      tournament_keys %>% 
        dplyr::filter(!is_first_round) %>%
        dplyr::mutate(tournament_plus1_round = tournament_round, invite_plus1_id = invite_id) %>%
        dplyr::select(participant_id, tournament_plus1_round, invite_plus1_id), by = c("participant_id")) %>%
    dplyr::select(-is_first_round) %>%
    dplyr::arrange(participant_id)
}

survey_join_keys <- c(
  "participant_id" = "participant_id",
  "invite_id" = "invite_id"
)

survey_tournament_load <- function(tournament_dir, game_tournament_keys) {
  path <- fs::path("input/raw", tournament_dir, "surveys")
  cultural <- survey_cultural_load(path)
  pre <- survey_round_begin_load(path)
  post <- survey_round_end_load(path)
  
  r1 <- game_tournament_keys %>% 
    dplyr::inner_join(cultural, by = survey_join_keys) %>%
    dplyr::left_join(post, by = survey_join_keys) %>%
    dplyr::relocate(tournament, tournament_round)

  invite_id_mapper <- survey_invite_id_mapper_get(game_tournament_keys)
  
  cultural_plus1 <- cultural %>%
    dplyr::inner_join(
      invite_id_mapper %>%
        dplyr::select(participant_id, invite_id, invite_plus1_id)
      , by = survey_join_keys) %>%
    # replace invite_id with invite ids for subsequent rounds
    dplyr::select(-invite_id) %>%
    dplyr::rename(invite_id = invite_plus1_id) %>%
    # common__ prefixes columns also occur in the pre survey so delete them
    # use the presurvey ones
    dplyr::select(-dplyr::starts_with("common__")) 
  
  r2plus <- game_tournament_keys %>%
    dplyr::filter(tournament_round > 1) %>%
    dplyr::left_join(cultural_plus1, by = survey_join_keys) %>%
    dplyr::left_join(pre, by = survey_join_keys) %>%
    dplyr::left_join(post, by = survey_join_keys)

  dplyr::union_all(
    r1,
    r2plus
  )
}
