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

You can run the workflow by running `main.R` in RStudio.

# Requirements

You will need a recent version of R with `tidyverse` installed (`install.packages("tidyverse")`).
