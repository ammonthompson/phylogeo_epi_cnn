## Basic Setup

All experiments were run on the following platform with the corresponding software versions:

- Platform: `x86_64-pc-linux-gnu` (64-bit) on Window subsystem for Linux v2
- Running under: Ubuntu 20.04.3 LTS

### Software and Libraries

- Beast 2 v2.6.3 with the package MASTER v6.1.2 installed for simulation.
    - Assumes the executable is called `beast2` is in a directory in your `$PATH`. 
    - In a directory in your path make the following soft link: `ln -s /path/to/bin/beast beast2`
- R, Rscript v4.1.1 with the following libraries for simulation and analysis:
    - vioplot v0.3.7
    - expm v0.999.6
    - BEST v0.5.4
    - phytools v0.7.90
    - rjson v0.2.20
- Python3 v3.8.10 with the following packages for machine learning:
    - numpy v1.19.5
    - scipy v1.6.3
    - pandas v1.3.4
    - ete3 v3.1.2
    - matplotlib v3.1.2
    - keras v2.6.0
    - scikit-learn v0.24.2
- If simulating genome sequence evolution: Assumes seq-gen v1.3.2 is in your `$PATH`

### Simulation

Basic command to simulate training and test trees:

```shell
randomParams_Simulation.sh path/to/control_file.txt num_locations sim_num_from,sim_num_to path/to/output_dir/output_file_prefix
```

### Analysis and Plotting
The final analysis script that generates results and figures for the manuscript is:

```shell
analysis_plotting/extant_analysis_and_plot_results.R
```
