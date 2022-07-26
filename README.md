# Auto-Scaling Simulator   
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white) ![R](https://img.shields.io/badge/r-%23276DC3.svg?style=for-the-badge&logo=r&logoColor=white)

<img 
  src="https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQVQQd5Aj11dAHIbE0MzK46ll9rGyW8SgXQupbh2gAwdK4ltbPz" align="right" alt="AWS Auto Scaling Logo" width="100" height="100">

### Purpose
The purpose of this project is to implement and simulate auto-scaling policies.  
So far, the simulator has the Simple Scaling and Target Tracking policies from AWS implemented.

### Installation

You can install R software for free [here](https://www.r-project.org/).

We recommend you to use [RStudio IDE](https://www.rstudio.com/products/rstudio/download/)
which has all the tools you need to develop using R.

Install the following library dependencies, on R console:
```
> install.packages("dplyr", "testthat", "yaml", "yardstick", "R.utils", "purrr")
```
Or you can install under the "packages" tab on R Studio.

### Usage

You can run the script on your terminal on the repo root directory, with the following command:
```
$ Rscript src/main.R
```
This will run the simulator with the parameters set on the config file.
If you want to use another config file just pass the config file path on
the second argument like this:
```
$ Rscript src/main.R $config_filepath
```

As a result, output file(s) will be generated based on your config settings.

### Organization

The repo structure is organized as follows:

- **Initial allocated cores**: the amount of cores available initially for your application
to run. During the simulation, the auto scaling algorithm will increase or decrease
this value, based on the boundaries that you set.
- **Lower bound**: The minimum utilization level percentage of your application's cores
- **Upper bound**: The maximum utilization level percentage of your application's cores
- **Step size**: The amount of cores you want to add or remove on each auto scaling operation.

### Data files

You can add more data files to calculate the ADI, storing them on the data
directory.
The file has to be in csv format and is composed of two columns: Cores and timestamp.
Every line of the Cores column is filled with floating numbers,
representing the amount of cores used by a given application in each timestamp.
The timestamp date format is currently up to you, since isn't not used yet by
the algorithm, but it's useful for reference.

| timestamp   | Cores     |
|:------------|:----------| 
| 1617228000  | 12.22     | 
| 1617228060  | 10.10     |   
| 1617228120  | 8.64      |    
| ...         | ...       |

### Organization of the repo
```
.
├── data/
│   ├── Input data.
├── output/
│   ├── Output data.
├── src/
│   ├── Simulator source code.
│   └── policies/
│       ├── Policies source code. 
└── tests/
    ├── Common tests
    ├── simple_scaling_test/
    │   ├── Tests for simple scaling policy
    └── target_tracking_test/
        ├── Tests for target tracking policy
```

### More information

- [Configuration](https://github.com/ufcg-lsd/autoscaling-analyser/wiki/Configuration)
- [Input](https://github.com/ufcg-lsd/autoscaling-analyser/wiki/Input)
- [Output](https://github.com/ufcg-lsd/autoscaling-analyser/wiki/Output)
- [Policies](https://github.com/ufcg-lsd/autoscaling-analyser/wiki/Policies)
- [Metrics](https://github.com/ufcg-lsd/autoscaling-analyser/wiki/Metrics)
- [Contributing](https://github.com/ufcg-lsd/autoscaling-analyser/wiki/Contributing)
