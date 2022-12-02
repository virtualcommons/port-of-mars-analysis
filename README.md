# port-of-mars-analysis

## Layout of tournament round input files

A tournament named 2021-03 should have files arranged to match:

NOTE: this is subject to change as we refine the workflow. The `1, 2, 3` below refer to the tournament round.

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


There is some manual work needed to download the tournament + survey data and set it up in the filesystem to match the above. Data freshly exported from the port of mars server via the [dump.sh script](https://github.com/virtualcommons/port-of-mars/blob/34cc5223353c7966a348ad638cac1e3fedb224bc/dump.sh) need to be merged with the survey data in `surveys/`

Data files archived at OSF should work when uncompressed directly into the input/ directory.

- https://osf.io/vjcpe/

# Running the Workflow

- Launch RStudio
- File -> Open project -> port-of-mars-analysis.Rproj
- After opening the R project file, edit the main.R file in R/main.R and change line 7 tournament_dir <- "2021-03" to match the directory e.g. "2021-11"
- Run main.R
![image](https://user-images.githubusercontent.com/8737685/146257780-1163d160-8348-4009-85bb-f91910ca1f5f.png)

- Check output/ to see if correct outputs have been generated

# Requirements

You will need a recent version of R and [RStudio Desktop](https://posit.co/download/rstudio-desktop/) with `tidyverse` installed (`install.packages("tidyverse")`).

## macos install

use macports to install `R` and `openmpi-clang14`

```
% port install R openmpi-clang14
```

# Important Notes
Avoid saving .Rdata when a dialog prompts to do so. Caching of data may cause unexpected problems when generating output csv files.
