# Phylogenetic Analysis Directory

This directory is dedicated to various phylogenetic analyses with an emphasis on the `.Rev` scripts that perform core tasks. 

## Directory Overview

- **sim_experiment_data.tar.gz**: Compressed data files used in simulation experiments.

### HPD Estimates

The `hpd_estimates` directory contains various files related to high posterior density (HPD) estimates, including:
- `.ci` files providing the 95% HPD intervals for various scenarios.
- `postmeans` files showing the posterior means.
- `coverage_report.txt` files detailing the coverage of the estimates.
- `true_value_files`

### Scripts

The `scripts` directory houses the main workhorse scripts for phylogenetic analysis. The most significant among them are the `.Rev` scripts.

#### Key Scripts:
- `analyze_tree_set.sh`: this one analyzes large sets of trees calling the appropriate .Rev script below
- `MTBD_aws_shared_param_tp_script.Rev`
- `home_shared_param_tp_script.Rev`
- `aws_shared_param_tp_script.Rev`
- `aws_shared_param_underPrior_tp_script.Rev`


