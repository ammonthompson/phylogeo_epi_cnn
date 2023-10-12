# Directory Overview

This directory contains files and scripts related to the analysis of phylogenetic data from the Nadeau 2021 study, with a particular focus on tree transformations and metadata processing.

## Contents

1. **Main Files**: These are primary data files and logs, which might include trees, log files from phylogenetic analyses, and transformed trees.
    - Example: `nadeau2021_deathdelay_europe_clade_demeR0.log`, `A2_tree_0.5dayUnits_nadeau2021.cblv.csv`, etc.

2. **metadata_files**: This sub-directory houses metadata files corresponding to the Nadeau 2021 study. Metadata typically provides additional information about the samples used in the study.
    - Example: `nadeau_2021_A2_metadata.txt`, `nadeau_2021_tree_metadata.txt`, etc.

3. **scripts**: This contains a set of scripts used for various purposes such as tree manipulation, branch length rescaling, and tip age jittering.
    - Example: `jitter_tip_ages.r`, `make_location_nexus_file.sh`, etc.

4. **tree_files**: As the name suggests, this folder stores tree files, both in nexus and newick formats. These might include MCC trees, location-specific trees, and trees with different time units.
    - Example: `nadeau_A2_tree.newick`, `nadeau_2021_full_tree_units_days.newick`, etc.

---

For specific details on individual files or scripts, please refer to internal documentation or contact the lead researcher.

