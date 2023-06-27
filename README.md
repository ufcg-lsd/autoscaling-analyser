# Auto-Scaling Simulator

![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white) ![R](https://img.shields.io/badge/r-%23276DC3.svg?style=for-the-badge&logo=r&logoColor=white)

This project implements an Auto-Scaling Simulator. So far, the simulator has the implementation for AWS Simple Scaling and AWS Target Tracking policies of auto-scaling.

## Installation

1.  Install the R software, it can be done for free [here](https://www.r-project.org/). Optionally, you can install the [RStudio IDE](https://www.rstudio.com/products/rstudio/download/), which has all the tools you need to develop using R.

2.  Install the Python programming language (this can be done [here](https://www.python.org/downloads/)) and the [pip module](https://pip.pypa.io/en/stable/installation/).

3.  Install the following R libraries dependencies by typing the next command on R console:

``` r
> install.packages(c("dplyr", "testthat", "yaml", "yardstick", "R.utils", "purrr", "reticulate"))
```

Or you can install under the "packages" tab on R Studio.

4.  Install the Python libraries dependencies using pip:

``` bash
pip install croniter
```

## Usage

You will need to configure your simulation updating the [config.yaml](config.yaml) file. The details of how to modify this file are available [here](https://github.com/ufcg-lsd/autoscaling-analyser/wiki/Configuration).

After updating the config file, run the following command in the root directory of this repository:

``` bash
Rscript src/main.R
```

If instead of updating the existent config.yaml you created a new one, you can pass the path to the new file as an argument, like this:

``` bash
Rscript src/main.R config/file/path/config.yaml
```

The output files will be stored in the output path specified in the configuration file.

## More information

You can find more information in the repository wiki.

-   The [Input](https://github.com/ufcg-lsd/autoscaling-analyser/wiki/Input) page describes required format for the input data.
-   The [Configuration](https://github.com/ufcg-lsd/autoscaling-analyser/wiki/Configuration) section specifies each parameter available in the configuration file and how to edit them.
-   The [Policies](https://github.com/ufcg-lsd/autoscaling-analyser/wiki/Policies) page elucidates the details of the scaling policies that were implemented in the simulator until now.
-   The [Output](https://github.com/ufcg-lsd/autoscaling-analyser/wiki/Output) section details the output files generated by the simulation.
-   The [Metrics](https://github.com/ufcg-lsd/autoscaling-analyser/wiki/Metrics) page shows the details of some metrics that can be automatically calculated for each simulation and how to enable this calculation.
-   Finally, the [Contributing](https://github.com/ufcg-lsd/autoscaling-analyser/wiki/Contributing) page specifies how you can help improve the simulator.

## Organization

The repsitory structure is organized as follows:

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
