System and Software:
====================

All experiments were run on the following platform with the corresponding software versions:

- **Simulations**: On an AWS EC2 instance running Ubuntu 18.04.6 LTS (GNU/Linux 5.4.0-1092-aws x86_64).
- **Simulation Experiment Results Analyses**:
  - Platform: `x86_64-pc-linux-gnu` (64-bit) on Windows Subsystem for Linux v2.
  - Running under: Ubuntu 20.04.3 LTS.

### Training and Other Large Data Files

- Available in the Dryad repo under DOI: [XXXXXX](https://doi.org/XXXXXX).

### Software and Libraries

- **Beast 2 v2.6.3** with the package MASTER v6.1.2 installed for simulation.
  - Assumes the executable `beast2` is in a directory in your `$PATH`.
  - In a directory in your path, make the following soft link: `ln -s /path/to/bin/beast beast2`
- **R, Rscript v4.1.1** with the following libraries for simulation and analysis:
  - vioplot v0.3.7
  - expm v0.999.6
  - BEST v0.5.4
  - phytools v0.7.90
  - rjson v0.2.20
- **Python3 v3.8.10** with the following packages for machine learning:
  - numpy v1.19.5
  - scipy v1.6.3
  - pandas v1.3.4
  - ete3 v3.1.2
  - matplotlib v3.1.2
  - keras v2.6.0
  - scikit-learn v0.24.2
- **Seq-gen v1.3.2** for simulating genome sequence evolution. Assumes it is in your `$PATH`.
- **RevBayes v1.1.0** for phylogenetic analysis 
  - TensorPhylo plugin (downloaded ~July 2021. Currently at https://bitbucket.org/mrmay/tensorphylo/src/master/) 

Pipeline Overview:
==================

The pipeline is structured to generate and analyze phylogeographic and epidemiological data. Execution begins with the "randomParams_simulation.sh" script, which further invokes the "simulateTreeAndAlignment.sh" script among others.

Directory Structure:
====================

The root contains the simulation scripts for generating the training and testing data. The follwoing directories contain scripts and data for conducting the analysis of the study. The scripts directory contains support scripts for simulation.

1. `neural_network_dev`:
    - Dedicated to neural network development and related utilities.
    - Contains scripts for extracting labels from parameter files, computing means, and version 2 of label extraction.
    - Python Modules:
        - cnn_utilities.py: Functions and utilities related to convolutional neural networks.
    - uq_and_adequacy: Houses utilities for uncertainty quantification and model adequacy.
    - Jupyter Notebooks for training and testing CNNs

2. `phylo_analysis`:
    - Focuses on the analysis of phylogenetic trees and related data.
    - Features Rev scripts for phylogenetic inference, handling and processing tree sets, fixing specific parameters, setting true values, and running IQ-TREE.
    - Python Modules:
        - split_columns.py: A utility to split columns in a dataset.

3. `real_data_analysis`:
    - Pertains to the analysis of real-world data sets from Nadeau et al. 2021.
    - Contains scripts to adjust tree features such as branch lengths, tip ages, and polytomies.

4. `scripts`:
    - General utility scripts for simulation and file processing tasks in the pipeline.
    - Subdirectories include scripts for handling 'cblv' formatted data, generating XML files, extracting migration rates from XML, and more.
    - Python Modules:
        - Several utilities including scripts to handle tree encoding, modify tree structures, and vectorize trees.
    - R Scripts:
        - A suite of R scripts for generating random numbers, adjusting metadata, visualization, and performing specific analyses on population statistics, branch lengths, etc.

Analysis Scripts:
=================

The pipeline also offers a suite of standalone scripts and modules in Python and R for tasks like data visualization, parameter tuning, branch length computation, and more.

Execution:
==========
To initiate the pipeline, execute the "randomParams_simulation.sh" script, which orchestrates the simulation and subsequent analysis.

### Simulation
Simulation settings are passed into the program with a control file like the one in:
./control_files/testing_controlfile.txt

Basic command to simulate training and test trees:

```shell
randomParams_Simulation.sh path/to/control_file.txt num_locations sim_num_from,sim_num_to path/to/output_dir/output_file_prefix
```

### Phylogenetic analysis


### CNN training and testing


### Analysis and Plotting
The final analysis script that generates results and figures for the manuscript is:

analysis_plotting/extant_analysis_and_plot_results.R
