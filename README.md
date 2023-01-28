# port-of-mars-analysis
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7579645.svg)](https://doi.org/10.5281/zenodo.7579645)

R analysis pipeline for Port of Mars "Mars Madness" tournament data from 2021/2022 archived at https://osf.io/vjcpe/

Originally written by Calvin Pritchard with use cases driven by Marco Janssen. Subsequent contributions from Kelly Claborn, Christine Nguyen, Raksha Balakrishna, and Allen Lee.

## Layout of tournament round input files

NOTE: subject to change as workflow is refined. The `1, 2, 3` below refer to the tournament round, e.g., 1st, 2nd, 3rd, round of the tournament etc.

An input `tournament_dir` of `"2021-11"` should have files arranged to match the below diagram.

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


Manual processing needed to download the tournament + survey data and set up a filesystem structure that matches the above. Data freshly exported from the port of mars server via the [dump.sh script](https://github.com/virtualcommons/port-of-mars/blob/34cc5223353c7966a348ad638cac1e3fedb224bc/dump.sh) need to be merged with the survey data in `surveys/`

Data files archived at OSF should work when uncompressed directly into the input/ directory.

- https://osf.io/vjcpe/

# Running the Workflow

- Launch RStudio
- File -> Open project -> port-of-mars-analysis.Rproj
- After opening the R project file, edit the main.R file in R/main.R and change line 7 tournament_dir <- "2021-03" to match the directory e.g. "2022-02"
- Run main.R

![image](https://user-images.githubusercontent.com/8737685/146257780-1163d160-8348-4009-85bb-f91910ca1f5f.png)

Verify data files placed in `output/` (currently needs to be done manually). A sanity check expected outputs given initial inputs test harness would be ideal or some automated validation routine but may defer to Python analysis pipeline refactor.

# Requirements

You will need a recent version of R and [RStudio Desktop](https://posit.co/download/rstudio-desktop/) with `tidyverse` installed (`install.packages("tidyverse")`).

(NOTE: currently unable to install propery on macOS with apple silicon i.e., M1/M2 chip)

# Important Notes

Avoid saving .Rdata when a dialog prompts to do so. Caching of data may cause unexpected problems when generating output csv files.
