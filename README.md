# port-of-mars-analysis

## Layout of tournament round input files

A tournament named 2021-03 should have files arranged to match

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


that will mean doenloading the appropiate tournament and survey data and then placing that data into the locations shown above.

# Running the Workflow

You can run the workflow by running `main.R` in RStudio.

# Requirements

You will need a recent version of R with `tidyverse` installed (`install.packages("tidyverse")`).
