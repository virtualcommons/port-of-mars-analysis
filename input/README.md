Place port of mars data and qualtrics survey data here to be stitched together.

Format:

Files should be placed something like this:

where games/1 is the first tournament round, games/2 is the second tournament round, etc.

├── raw
│   └── 2022-02
│       ├── games
│       │   ├── 1
│       │   ├── 2
│       │   └── 3
│       └── surveys
│           ├── post.csv
│           ├── pre-after-round1.csv
│           └── pre.csv
└── README.md
- **pre.csv** is the initial survey taken before round 1 starts
- **pre-after-round1.csv** is the second and later survey taken before round 2,3,... starts
- **post.csv** is the exit game survey, univeral across all rounds
