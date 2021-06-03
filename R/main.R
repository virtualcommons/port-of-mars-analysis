source("R/chat_messages.R")
source("R/game.R")
source("R/mars_events.R")
source("R/survey.R")
source("R/tournament.R")

tournament_dir <- "2021-03"
tournament <- tournament_load(tournament_dir = tournament_dir, max_game_rounds = 11)
tournament_codebook <- tournament_codebook_create(max_game_rounds = 11)

tournament_write(tournament = tournament, tournament_dir = tournament_dir)
tournament_codebook_write(tournament_codebook = tournament_codebook, tournament_dir = tournament_dir)
me_write(tournament = tournament_dir)

chat_messages_tournament <- chat_messages_tournament_load(tournament_dir = tournament_dir)
chat_messages_tournament_save(
  chat_messages_tournament = chat_messages_tournament,
  tournament_dir = tournament_dir
)
