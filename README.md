# port-of-mars-analysis
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7579645.svg)](https://doi.org/10.5281/zenodo.7579645)

R analysis pipeline for Port of Mars "Mars Madness" tournament data from 2021/2022 archived at https://osf.io/vjcpe/

Originally written by Calvin Pritchard with use cases driven by Marco Janssen. Subsequent contributions from Kelly Claborn, Christine Nguyen, Raksha Balakrishna, and Allen Lee.

## Layout of tournament round input files

NOTE: this is subject to change as the workflow is refined. 

The `1, 2, 3` below refer to the tournament round, e.g., 1st, 2nd, 3rd, round of the tournament etc.

An input `tournament_dir` of `"2021-11"` should have `games/` and `surveys/` directories with additional raw-ish data files organized like the diagram below:

```
input                          
├── 2021-11                   
│   ├── games                           
│   │   ├── 1                       
│   │   │   ├── processed
│   │   │   │   ├── accomplishment.csv  
│   │   │   │   ├── chatMessages.csv
│   │   │   │   ├── gameEvent.csv
│   │   │   │   ├── marsEvent.csv     
│   │   │   │   ├── marsLog.csv     
│   │   │   │   ├── player.csv   
│   │   │   │   ├── playerInvestment.csv
│   │   │   │   └── victoryPoint.csv
│   │   │   └── raw           
│   │   │       └── playerInvestment.csv
│   │   └── 2                       
│   │       ├── processed
│   │       │   ├── accomplishment.csv  
│   │       │   ├── chatMessages.csv
│   │       │   ├── gameEvent.csv
│   │       │   ├── marsEvent.csv     
│   │       │   ├── marsLog.csv     
│   │       │   ├── player.csv   
│   │       │   ├── playerInvestment.csv
│   │       │   └── victoryPoint.csv
│   │       └── raw           
│   │           └── playerInvestment.csv
│   └── surveys                     
│       ├── post.csv
│       ├── pre-after-round1.csv        
│       ├── pre.csv
│       └── README.md
├── 2022-02                     
│   ├── games      
│   │   ├── 1
│   │   │   ├── processed
│   │   │   │   ├── accomplishment.csv
│   │   │   │   ├── chatMessages.csv
...
```


Manual processing needed to download the tournament + survey data and set up a filesystem structure that matches the above. Data freshly exported from the port of mars server via the [dump.sh script](https://github.com/virtualcommons/port-of-mars/blob/34cc5223353c7966a348ad638cac1e3fedb224bc/dump.sh) need to be merged with survey data exported via Qualtrics and placed in a `surveys/` directory relative to the root `YYYY-MM` date directory as shown above.

Surveys should be exported from Qualtrics by going to the `Data & Analysis` tab and clicking on `Export & Import -> Export Data`. Make sure the option `Use numeric values` is selected in the Download options modal e.g.,

![image](https://github.com/virtualcommons/port-of-mars-analysis/assets/22534/84d84682-a860-464f-a84e-def06352a08d)

File renames:

- initial pregame survey should be renamed `pre.csv`
- post-game survey should be renamed `post.csv`
- pre-game survey after Round 1 should be named `pre-after-round1.csv`

All [data files archived at OSF](https://osf.io/vjcpe/) should be able to processed via the following steps when extracted into the input/ directory (exceptions must be noted in the dataset metadata).

# Running the Workflow

- Launch RStudio
- File -> Open project -> port-of-mars-analysis.Rproj
- After opening the R project file, edit `R/main.R` and change line 7: `tournament_dir <- "2021-03"` to match the output directory e.g. "2022-02"
- Run main.R

![image](https://user-images.githubusercontent.com/8737685/146257780-1163d160-8348-4009-85bb-f91910ca1f5f.png)

Verify data files placed in `output/` manually. A sanity check that compares expected outputs given initial inputs or some other kind of automated validation or test harness would be ideal but this is currently deferred until we have additional support to refactor this code.

# Requirements

You will need a recent version of R and [RStudio Desktop](https://posit.co/download/rstudio-desktop/) with `tidyverse` installed (`install.packages("tidyverse")`).

(NOTE: currently unable to install on macOS with apple M1/M2 chip)

# Important Notes / Troubleshooting

Do not save .Rdata if given dialog prompts to do so. Caching of .Rdata may cause unexpected problems when generating output csv files.
