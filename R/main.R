source("R/chat_messages.R")
source("R/game.R")
source("R/mars_events.R")
source("R/survey.R")
source("R/tournament.R")

#
# ==== MAIN ENTRY POINT ==== 
# This script stitches together multiple data sources representing all of the
# games within a Port of Mars "tournament". See below for more details on the
# expected filesystem structure. 
#
# ==== select tournament input directory ====
# 
# The input directory should have a structure like the following:
# 
# input                          
# ├── 2021-11                   
# │   ├── games                           
# │   │   ├── 1                       
# │   │   │   ├── processed
# │   │   │   │   ├── accomplishment.csv  
# │   │   │   │   ├── chatMessages.csv
# │   │   │   │   ├── gameEvent.csv
# │   │   │   │   ├── marsEvent.csv     
# │   │   │   │   ├── marsLog.csv     
# │   │   │   │   ├── player.csv   
# │   │   │   │   ├── playerInvestment.csv
# │   │   │   │   └── victoryPoint.csv
# │   │   │   └── raw           
# │   │   │       └── playerInvestment.csv
# │   │   └── 2                       
# │   │       ├── processed
# │   │       │   ├── accomplishment.csv  
# │   │       │   ├── chatMessages.csv
# │   │       │   ├── gameEvent.csv
# │   │       │   ├── marsEvent.csv     
# │   │       │   ├── marsLog.csv     
# │   │       │   ├── player.csv   
# │   │       │   ├── playerInvestment.csv
# │   │       │   └── victoryPoint.csv
# │   │       └── raw           
# │   │           └── playerInvestment.csv
# │   └── surveys                     
# │       ├── post.csv
# │       ├── pre-after-round1.csv        
# │       ├── pre.csv
# │       └── README.md


tournament_dir <- "2021-11"
max_game_rounds <- 15
# max_game_rounds should be inferred ?
tournament <- tournament_load(tournament_dir = tournament_dir, max_game_rounds) 
tournament_codebook <- tournament_codebook_create(max_game_rounds)

tournament_write(tournament = tournament, tournament_dir = tournament_dir)
tournament_codebook_write(tournament_codebook = tournament_codebook, tournament_dir = tournament_dir)
me_write(tournament = tournament_dir)

chat_messages_tournament <- chat_messages_tournament_load(tournament_dir = tournament_dir)
chat_messages_tournament_save(
  chat_messages_tournament = chat_messages_tournament,
  tournament_dir = tournament_dir
)
