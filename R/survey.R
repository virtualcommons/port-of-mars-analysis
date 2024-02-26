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

survey_remove_duplicates <- function(data) {
  # remove duplicate survey records for participants
  # should operate data before renaming due to relying on Progress which gets thrown out
  data %>%
    dplyr::arrange(pid, tid, dplyr::desc(Progress), dplyr::desc(EndDate)) %>%
    dplyr::group_by(pid, tid) %>%
    dplyr::slice(1) %>%
    dplyr::ungroup()
}

survey_pre_renames <- tibble::tribble(
  ~dest, ~src, ~desc,
  "participant_id", "pid", "",
  "invite_id", "tid", "",
  "gender", "gender", "",
  "man", "man", "",
  "pre__start_date", "StartDate", "",
  "pre__end_date", "EndDate", "",
  "pre__survey_duration", "Duration (in seconds)", "",
  "pre__risk_preference", "Q12", "How do you see yourself: are you generally a person who is fully prepared to take risks or do you try to avoid taking risks? Please set the slider on the gauge, where the value 0 means: â€˜not at all willing to take risksâ€™ and the value 10 means: â€˜very willing to take risksâ€™.â€",
  "pre__situation1", "Q5", "Situation 1",
  "pre__situation2", "Q7", "Situation 2",
  "pre__situation3", "Q8", "Situation 3",
  "pre__situation4", "Q9", "Situation 4",
  "pre__situation5", "Q10", "Situation 5",
  "pre__situation6", "Q11", "Situation 6",
  "common__i_am_a_leader", "Q4_1", "Please rate the extent to which the following statements describes or does not describe you. - I am a leader",
  "common__i_see_myself_as_a_leader", "Q4_2", "Please rate the extent to which the following statements describes or does not describe you. - I see myself as a leader",
  "common__describe_leader", "Q4_3", "Please rate the extent to which the following statements describes or does not describe you. - If I had to describe myself to others I would include the word â€œleader.â€",
  "common__seen_as_leader", "Q4_4", "Please rate the extent to which the following statements describes or does not describe you. - I prefer being seen by others as a leader.",
  "pre__$choice1", "Q20", "Would you rather receive 100 dollars today or 153.8 dollars in 12 months?",
  "pre__$choice2", "Q22", "Would you rather receive 100 dollars today or 125.4 dollars in 12 months?",
  "pre__$choice3", "Q23", "Would you rather receive 100 dollars today or 112.4 dollars in 12 months?",
  "pre__$choice4", "Q24", "Would you rather receive 100 dollars today or 106.1 dollars in 12 months?",
  "pre__$choice5", "Q25", "Would you rather receive 100 dollars today or 103.0 dollars in 12 months?",
  "pre__$choice6", "Q26", "Would you rather receive 100 dollars today or 109.2 dollars in 12 months?",
  "pre__$choice7", "Q27", "Would you rather receive 100 dollars today or 118.8 dollars in 12 months?",
  "pre__$choice8", "Q28", "Would you rather receive 100 dollars today or 122.1 dollars in 12 months?",
  "pre__$choice9", "Q29", "Would you rather receive 100 dollars today or 115.6 dollars in 12 months?",
  "pre__$choice10", "Q30", "Would you rather receive 100 dollars today or 139.2 dollars in 12 months?",
  "pre__$choice11", "Q31", "Would you rather receive 100 dollars today or 132.3 dollars in 12 months?",
  "pre__$choice12", "Q32", "Would you rather receive 100 dollars today or 128.8 dollars in 12 months?",
  "pre__$choice13", "Q33", "Would you rather receive 100 dollars today or 135.7 dollars in 12 months?",
  "pre__$choice14", "Q34", "Would you rather receive 100 dollars today or 146.4 dollars in 12 months?",
  "pre__$choice15", "Q35", "Would you rather receive 100 dollars today or 142.8 dollars in 12 months?",
  "pre__$choice16", "Q36", "Would you rather receive 100 dollars today or 150.1 dollars in 12 months?",
  "pre__$choice17", "Q37", "Would you rather receive 100 dollars today or 185.0 dollars in 12 months?",
  "pre__$choice18", "Q38", "Would you rather receive 100 dollars today or 201.6 dollars in 12 months?",
  "pre__$choice19", "Q39", "Would you rather receive 100 dollars today or 193.2 dollars in 12 months?",
  "pre__$choice20", "Q40", "Would you rather receive 100 dollars today or 197.4 dollars in 12 months?",
  "pre__$choice21", "Q41", "Would you rather receive 100 dollars today or 189.1 dollars in 12 months?",
  "pre__$choice22", "Q42", "Would you rather receive 100 dollars today or 210.3 dollars in 12 months?",
  "pre__$choice23", "Q43", "Would you rather receive 100 dollars today or 214.6 dollars in 12 months?",
  "pre__$choice24", "Q44", "Would you rather receive 100 dollars today or 205.9 dollars in 12 months?",
  "pre__$choice25", "Q45", "Would you rather receive 100 dollars today or 169.0 dollars in 12 months?",
  "pre__$choice26", "Q46", "Would you rather receive 100 dollars today or 161.3 dollars in 12 months?",
  "pre__$choice27", "Q47", "Would you rather receive 100 dollars today or 157.5 dollars in 12 months?",
  "pre__$choice28", "Q48", ". Would you rather receive 100 dollars today or 165.1 dollars in 12 months?",
  "pre__$choice29", "Q49", "Would you rather receive 100 dollars today or 176.9 dollars in 12 months?",
  "pre__$choice30", "Q50", "Would you rather receive 100 dollars today or 172.9 dollars in 12 months?",
  "pre__$choice31", "Q51", "Would you rather receive 100 dollars today or 180.9 dollars in 12 months?",
  "pre__characteristic1", "Q52_1", "For each of the statements shown, please indicate whether or not
the statement is characteristic of you. If the statement is extremely uncharacteristic of you (not at all like you) click on the left button; if the statement is extremely characteristic of
you (very much like you) click on the right button. And, of
course, click on the options in between, if you fall between the extremes - I consider how things might be in the future, and try to influence those things with my day to day behavior.",
  "pre__characteristic2", "Q52_2", "For each of the statements shown, please indicate whether or not
the statement is characteristic of you. If the statement is extremely uncharacteristic of you (not at all like you) click on the left button; if the statement is extremely characteristic of
you (very much like you) click on the right button. And, of
course, click on the options in between, if you fall between the extremes - Often I engage in a particular behavior in order to achieve outcomes that may not result for many years.",
  "pre__characteristic3", "Q52_3", "For each of the statements shown, please indicate whether or not
the statement is characteristic of you. If the statement is extremely uncharacteristic of you (not at all like you) click on the left button; if the statement is extremely characteristic of
you (very much like you) click on the right button. And, of
course, click on the options in between, if you fall between the extremes - I only act to satisfy immediate concerns, figuring the future will take care of itself.",
  "pre__characteristic4", "Q52_4", "For each of the statements shown, please indicate whether or not
the statement is characteristic of you. If the statement is extremely uncharacteristic of you (not at all like you) click on the left button; if the statement is extremely characteristic of
you (very much like you) click on the right button. And, of
course, click on the options in between, if you fall between the extremes - My behavior is only influenced by the immediate (i.e., a matter of days or weeks) outcomes of my actions.",
  "pre__characteristic5", "Q52_5", "For each of the statements shown, please indicate whether or not
the statement is characteristic of you. If the statement is extremely uncharacteristic of you (not at all like you) click on the left button; if the statement is extremely characteristic of
you (very much like you) click on the right button. And, of
course, click on the options in between, if you fall between the extremes - My convenience is a big factor in the decisions I make or the actions I take.",
  "pre__characteristic6", "Q52_6", "For each of the statements shown, please indicate whether or not
the statement is characteristic of you. If the statement is extremely uncharacteristic of you (not at all like you) click on the left button; if the statement is extremely characteristic of
you (very much like you) click on the right button. And, of
course, click on the options in between, if you fall between the extremes - I am willing to sacrifice my immediate happiness or well-being in order to achieve future outcomes.",
  "pre__characteristic7", "Q52_7", "For each of the statements shown, please indicate whether or not
the statement is characteristic of you. If the statement is extremely uncharacteristic of you (not at all like you) click on the left button; if the statement is extremely characteristic of
you (very much like you) click on the right button. And, of
course, click on the options in between, if you fall between the extremes - I think it is important to take warnings about negative outcomes seriously even if the negative outcome will not occur for many years.",
  "pre__characteristic8", "Q52_8", "For each of the statements shown, please indicate whether or not
the statement is characteristic of you. If the statement is extremely uncharacteristic of you (not at all like you) click on the left button; if the statement is extremely characteristic of
you (very much like you) click on the right button. And, of
course, click on the options in between, if you fall between the extremes - I think it is more important to perform a behavior with important distant consequences than a behavior with less important immediate consequences",
  "pre__characteristic9", "Q52_9", "For each of the statements shown, please indicate whether or not
the statement is characteristic of you. If the statement is extremely uncharacteristic of you (not at all like you) click on the left button; if the statement is extremely characteristic of
you (very much like you) click on the right button. And, of
course, click on the options in between, if you fall between the extremes - I generally ignore warnings about possible future problems because I think the problems will be resolved before they reach crisis level.",
  "pre__characteristic10", "Q52_10", "For each of the statements shown, please indicate whether or not
the statement is characteristic of you. If the statement is extremely uncharacteristic of you (not at all like you) click on the left button; if the statement is extremely characteristic of
you (very much like you) click on the right button. And, of
course, click on the options in between, if you fall between the extremes - I think that sacrificing now is usually unnecessary since future outcomes can be dealt with at a later time.",
  "pre__characteristic11", "Q52_11", "For each of the statements shown, please indicate whether or not
the statement is characteristic of you. If the statement is extremely uncharacteristic of you (not at all like you) click on the left button; if the statement is extremely characteristic of
you (very much like you) click on the right button. And, of
course, click on the options in between, if you fall between the extremes - I only act to satisfy immediate concerns, figuring that I will take care of future problems that may occur at a later date.",
  "pre__characteristic12", "Q52_12", "For each of the statements shown, please indicate whether or not
the statement is characteristic of you. If the statement is extremely uncharacteristic of you (not at all like you) click on the left button; if the statement is extremely characteristic of
you (very much like you) click on the right button. And, of
course, click on the options in between, if you fall between the extremes - Since my day-to-day work has specific outcomes, it is more important to me than behavior that has distant outcomes.",
  "pre__characteristic13", "Q52_13", "For each of the statements shown, please indicate whether or not
the statement is characteristic of you. If the statement is extremely uncharacteristic of you (not at all like you) click on the left button; if the statement is extremely characteristic of
you (very much like you) click on the right button. And, of
course, click on the options in between, if you fall between the extremes - When I make a decision, I think about how it might affect me in the future.",
  "pre__characteristic14", "Q52_14", "For each of the statements shown, please indicate whether or not
the statement is characteristic of you. If the statement is extremely uncharacteristic of you (not at all like you) click on the left button; if the statement is extremely characteristic of
you (very much like you) click on the right button. And, of
course, click on the options in between, if you fall between the extremes - My behavior is generally influenced by future consequences.",
  "pre__CO2", "Q53", "The amount of carbon dioxide, CO2, in the atmosphere is affected by natural processes and by human activity. The concentration of CO2 in the atmosphere has increased from 280 parts per million (ppm) in 1900 to 415 ppm currently. This increase of CO2 concentration is contributing to global warming.
The use of fossil fuels and deforestations lead to about 11.5 Gigaton Carbon (GtC) in recent years. Natural processes gradually remove CO2 from the atmosphere, for example due to plant life, currently about 4 GtC a year. To avoid a dangerous climate change, we need to reduce CO2 emissions. Given the information in this question, what is the maximum amount of emissions from human activities we can allow to start reducing CO2 concentration in the atmosphere.",
  "pre__studentdebt", "Q54_1", "John successfully graduated from ASU. He has student debt totaling $50,000, with an interest rate of 5%. John wants to pay of his student debt in 20 years. What does John need to pay each year to pay off the student loan. - $"
) %>% dplyr::mutate(origin = "pre survey")

survey_pre_load <- function(prefix) {
  kvs <- survey_renames_to_kv(survey_pre_renames)
  columns <- names(kvs)
  path <- fs::path(prefix, "pre.csv")
  headers <- colnames(readr::read_csv(path, n_max=0))
  data <- readr::read_csv(path, skip = 2)
  colnames(data) <- headers
  data %>%
    dplyr::mutate(
      StartDate = lubridate::ymd_hms(StartDate),
      EndDate = lubridate::ymd_hms(EndDate)
    ) %>%
    survey_remove_duplicates() %>%
    dplyr::rename(gender = Q2) %>%
    dplyr::mutate(
      man = gender == 2
    ) %>%
    dplyr::rename(!!! kvs) %>%
    dplyr::select(!!! columns) %>%
    survey_filter_has_fks()
}

survey_pregame_after_round1_renames <- tibble::tribble(
  ~dest, ~src, ~desc,
  "participant_id", "pid", "",
  "invite_id", "tid", "",
  "pregame_after_round1__start_date", "StartDate", "",
  "pregame_after_round1__end_end", "EndDate", "",
  "pregame_after_round1__survey_duration", "Duration (in seconds)", "",
  "pregame_after_round1__i_am_a_leader", "Q2_1", "Please rate the extent to which you agree or disagree with each of the following statements. - I am a leader",
  "pregame_after_round1__i_see_myself_as_a_leader", "Q2_2", "Please rate the extent to which you agree or disagree with each of the following statements. - I see myself as a leader",
  "pregame_after_round1__describe_leader", "Q2_3", "Please rate the extent to which you agree or disagree with each of the following statements. - If I had to describe myself to others I would include the word â€œleader.â€",
  "pregame_after_round1__seen_as_leader", "Q2_4", "Please rate the extent to which you agree or disagree with each of the following statements. - I prefer being seen by others as a leader.",
  "pregame_after_round1__change_crisis_situations", "Q2_5", "Please rate the extent to which you agree or disagree with each of the following statements. - I will change how I handle crisis situations.",
  "pregame_after_round1__change_stress", "Q2_6", "Please rate the extent to which you agree or disagree with each of the following statements. - I will change how I handle stress.",
  "pregame_after_round1__solve_problems_creatively", "Q2_7", "Please rate the extent to which you agree or disagree with each of the following statements. - I will solve problems creatively.",
  "pregame_after_round1__change_deals_in_uncertain_situations", "Q2_8", "Please rate the extent to which you agree or disagree with each of the following statements. - I will change how I deal with uncertain situations.",
  "pregame_after_round1__try_other_ways_to_play", "Q2_9", "Please rate the extent to which you agree or disagree with each of the following statements. - I will try other ways to play the game.",
  "pregame_after_round1__adapt_to_my_teammates_play", "Q2_10", "Please rate the extent to which you agree or disagree with each of the following statements. - I will adapt to my teammates' play.",
  "pregame_after_round1__takeaways_from_previous_round", "Q3", "What are some of your takeaways from the previous round playing this game?",
  "pregame_after_round1__will_you_do_something_different", "Q4", "Will you do something different in this round? Why or why not? If so, what will you change?"
) %>% dplyr::mutate(origin = "pre game after round 1 survey") 

survey_pregame_after_round1_load <- function(prefix) {
  kvs <- survey_renames_to_kv(survey_pregame_after_round1_renames)
  columns <- names(kvs)
  path <- fs::path(prefix, "pre-after-round1.csv")
  headers <- colnames(readr::read_csv(path, n_max=0))
  data <- readr::read_csv(path, skip = 2)
  colnames(data) <- headers
  data %>%
    survey_remove_duplicates() %>%
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
  "post__group_adjusts_to_changes_well", "Q3_1", " Please rate the extent to which you agree or disagree with each of the following statements. - Group members adjust well to the changes that happen in the game.",
  "post__group_confidence_in_problem_solving", "Q3_2", "Please rate the extent to which you agree or disagree with each of the following statements. - When a problem occurs, the members of this group manage to solve it.",
  "post__group_could_work_together_a_long_time", "Q3_3", "Please rate the extent to which you agree or disagree with each of the following statements. - The members of this group could work a long time together.",
  "post__group_i_see_achievements_as_a_success", "Q3_4", "Please rate the extent to which you agree or disagree with each of the following statements. - I see our group's achievements in this game as a success.",
  "post__group_i_learned_lessons_from_game", "Q3_5", "Please rate the extent to which you agree or disagree with each of the following statements. - I learned important lessons from this game.",
  "post__group_work_promites_my_growth", "Q3_6", "Please rate the extent to which you agree or disagree with each of the following statements. - Working in this group promotes my growth.",
  "post__group_we_attained_our_collective_goals", "Q3_7", "Please rate the extent to which you agree or disagree with each of the following statements. - The members of this group attain our goals for the game.",
  "post__group_members_played_well", "Q3_8", "Please rate the extent to which you agree or disagree with each of the following statements. - The members of this group played the game well.",
  "post__group_was_productive", "Q3_9", "Please rate the extent to which you agree or disagree with each of the following statements. - This group is productive.",
  "post__group_social_climate_was_good", "Q3_10", "Please rate the extent to which you agree or disagree with each of the following statements. - The social climate in our group is good.",
  "post__group_relationships_were_harmonious", "Q3_11", "Please rate the extent to which you agree or disagree with each of the following statements. - In our group, relationships are harmonious.",
  "post__group_we_get_along_with_each_other", "Q3_12", "Please rate the extent to which you agree or disagree with each of the following statements. - In our group, we get along with each other.",
  "post__CO2", "Q4", "The amount of carbon dioxide, CO2, in the atmosphere is affected by natural processes and by human activity. The concentration of CO2 in the atmosphere has increased from 280 parts per million (ppm) in 1900 to 415 ppm currently. This increase of CO2 concentration is contributing to global warming. The use of fossil fuels and deforestations lead to about 11.5 Gigaton Carbon (GtC) in recent years. Natural processes gradually remove CO2 from the atmosphere, for example due to plant life, currently about 4 GtC a year. To avoid a dangerous climate change, we need to reduce CO2 emissions. Given the information in this question, what is the maximum amount of emissions from human activities we can allow to start reducing CO2 concentration in the atmosphere.",
  "post__studentdebt", "Q8_1", "John successfully graduated from ASU. He has student debt totaling $50,000, with an interest rate of 5%. John wants to pay of his student debt in 20 years. What does John need to pay each year to pay off the student loan. - $",
  "post__survived", "Q11", "Did your group survived all rounds?",
  "post__successful", "Q12", "What do you think made your group successful?",
  "post__unsuccessful", "Q13", "What do you think caused the unsuccessful attempt of your group to survive all rounds?",
  "post__caseA1", "Q16_1", "Based on the description of Case A, how much would you invest in system health in Round 3 if you are in the role of the Pioneer? - Investment in system health",
  "post__caseA2", "Q17_1", "Based on the description of Case A, how much would you invest in system health in round 3 if you are in the role of the Politician? - Investment in system health",
  "post__caseA3", "Q18", "Based on the description of Case A, what kind of chat message in Round 3 would be closest to your intentions if you are in the role of the Entrepreneur?",
  "post__caseB1", "Q20_1", "Based on the description of Case B, how much would you invest in system health in Round 7 if you are in the role of the Pioneer? - Investment in system health",
  "post__caseB2", "Q21_1", "Based on the description of Case B, how much would you invest in system health in round 7 if you are in the role of the Researcher? - Investment in system health",
  "post__caseB3", "Q22", "Based on the description of Case B, if you are in the role of the Researcher, would you purchase the â€œGrant Funkâ€ accomplishment?",
  "post__caseB4", "Q23", "Based on the description of Case B, what kind of chat message in Round 7 would be closest to your intentions if you are in the role of the Researcher?",
  "post__feedback", "Q7", "Do you have any feedback on your experience with the game today:"
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
    survey_remove_duplicates() %>%
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
  path <- fs::path("input/", tournament_dir, "surveys")
  pre <- survey_pre_load(path)
  post <- survey_round_end_load(path)
  
  r1 <- game_tournament_keys %>% 
    dplyr::inner_join(pre, by = survey_join_keys) %>%
    dplyr::left_join(post, by = survey_join_keys) %>%
    dplyr::relocate(tournament, tournament_round)
  
  invite_id_mapper <- survey_invite_id_mapper_get(game_tournament_keys)
  
  pre_plus1 <- pre %>%
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
  
  # do not attempt to join rpund 2+ responses if the file does not exist or is empty
  pre_after_round1_path <- fs::path(path, "pre-after-round1.csv")
  if (fs::file_exists(pre_after_round1_path) && file.info(pre_after_round1_path)$size > 0) {
    pregame_after_round1 <- survey_pregame_after_round1_load(path)
    r2plus <- game_tournament_keys %>%
      dplyr::filter(tournament_round > 1) %>%
      dplyr::left_join(pre_plus1, by = survey_join_keys) %>%
      dplyr::left_join(pregame_after_round1, by = survey_join_keys) %>%
      dplyr::left_join(post, by = survey_join_keys)
  
    dplyr::bind_rows(r1, r2plus)
  } else {
    return(r1)
  }
}

