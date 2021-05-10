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
