# port-of-mars-analysis

## Layout of tournament round input files

A tournament named 2021-03 should have files arranged to match:

NOTE: this is subject to change as we refine the workflow. The `1, 2, 3` below refer to the tournament round.

```
input
└── raw
    └── 2021-03
        ├── games
        │   ├── 1
        │   │   ├── processed
        │   │   │   ├── accomplishment.csv
        │   │   │   ├── chatMessages.csv
        │   │   │   ├── gameEvent.csv
        │   │   │   ├── marsEvent.csv
        │   │   │   ├── player.csv
        │   │   │   ├── playerInvestment.csv
        │   │   │   └── victoryPoint.csv
        │   │   └── raw
        │   │       └── playerInvestment.csv
        │   ├── 2
        │   │   ├── processed
        │   │   │   ├── accomplishment.csv
        │   │   │   ├── chatMessages.csv
        │   │   │   ├── gameEvent.csv
        │   │   │   ├── marsEvent.csv
        │   │   │   ├── player.csv
        │   │   │   ├── playerInvestment.csv
        │   │   │   └── victoryPoint.csv
        │   │   └── raw
        │   │       └── playerInvestment.csv
        │   └── 3
        │       ├── processed
        │       │   ├── accomplishment.csv
        │       │   ├── chatMessages.csv
        │       │   ├── gameEvent.csv
        │       │   ├── marsEvent.csv
        │       │   ├── player.csv
        │       │   ├── playerInvestment.csv
        │       │   └── victoryPoint.csv
        │       └── raw
        │           └── playerInvestment.csv
        └── surveys
            ├── cultural.csv
            ├── post.csv
            └── pre.csv
```


There is some manual work needed to download tournament and survey data and placing it in the filesystem in the manner above.

# Running the Workflow

- Launch RStudio
- File -> Open project -> port-of-mars-analysis.Rproj
- After opening the R project file, edit the main.R file in R/main.R and change line 7 tournament_dir <- "2021-03" to match the directory e.g. "2021-11"
- Run main.R
![image](https://user-images.githubusercontent.com/8737685/146257780-1163d160-8348-4009-85bb-f91910ca1f5f.png)

- Check output/ to see if correct outputs have been generated

# Requirements

You will need a recent version of R with `tidyverse` installed (`install.packages("tidyverse")`).
