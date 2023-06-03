# set working dir to location of script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(vioplot)
library(expm)
library(BEST)
source("analysis_support_functions.R")

# output parent directory
figure_relative_dir = "figures/"

#### UQ calibration ############
caltest_coverage = read.table("../neural_network_dev/uq_and_adequacy/output/validation_CQR_coverage.tsv", 
                              header = T, row.names = 1)/100
caltest_ci = read.table("../neural_network_dev/uq_and_adequacy/output/validation_CQR_ci.tsv", header = T)
caltest_labels = read.table("../neural_network_dev/uq_and_adequacy/output/validation_CQR_labels.tsv", header = T)

make_coverage_plot(caltest_coverage, n=nrow(caltest_ci))
plot_ci_widths(caltest_ci[1:500,], caltest_ci[1:500,], caltest_labels[1:500,])

nn=500
plot(NULL, xlim = c(2,8), ylim = 1.25 * c(min(caltest_ci[1:nn,1] - caltest_labels[1:nn,1]), 
                                       max(caltest_ci[1:nn,2] - caltest_labels[1:nn,1])))
arrows(caltest_labels[1:nn,1], caltest_ci[1:nn,1] - caltest_labels[1:nn,1], caltest_labels[1:nn,1], 
       caltest_ci[1:nn,2] - caltest_labels[1:nn,1], angle = 0)
abline(h=0,col="red")

plot(NULL, xlim = c(0,0.005), ylim = 1.25 * c(min(caltest_ci[1:nn,3] - caltest_labels[1:nn,2]), 
                                       max(caltest_ci[1:nn,4] - caltest_labels[1:nn,2])))
arrows(caltest_labels[1:nn,2], caltest_ci[1:nn,3] - caltest_labels[1:nn,2], caltest_labels[1:nn,2], 
       caltest_ci[1:nn,4] - caltest_labels[1:nn,2], angle = 0)
abline(h=0,col="red")

plot(NULL, xlim = c(0,0.005), ylim = 1.25 * c(min(caltest_ci[1:nn,5] - caltest_labels[1:nn,3]), 
                                       max(caltest_ci[1:nn,6] - caltest_labels[1:nn,3])))
arrows(caltest_labels[1:nn,3], caltest_ci[1:nn,5] - caltest_labels[1:nn,3], caltest_labels[1:nn,3], 
       caltest_ci[1:nn,6] - caltest_labels[1:nn,3], angle = 0)
abline(h=0,col="red")


#### True specified model ########
extant_cnn = read.table("../neural_network_dev/output/extant_cnn_preds.tsv", header = T, row.names = NULL)
extant_phylo = read.table("../neural_network_dev/output/extant_phylo_means.tsv", header  = T, row.names = NULL)
extant_labels = read.table("../neural_network_dev/output/extant_labels.tsv", header = T, row.names = NULL)
extant_phylocomp_runtimes = read.table("../neural_network_dev/output/extant_phylocomp_runtimes.tsv", header = T, row.names = 1)

extant_phylocomp_coverage = read.table("../neural_network_dev/data_files/extant_phylocomp_coverage.txt", header = T, row.names =1)
cnn_phylocomp_coverage = read.table("../neural_network_dev/data_files/fuck_cnn_coverage.tsv", header =T, row.names = 1) / 100

extant_phylocomp_ci = read.table("../phylo_analysis/hpd_estimates/extant_phylocomp_0.95.ci", header = T, row.names = 1)
cnn_phylocomp_ci = read.table("../neural_network_dev/uq_and_adequacy/output/fuck_phylocomp_cnn_95q.tsv", header = T)

plot_ci_widths(cnn_phylocomp_ci, extant_phylocomp_ci, extant_labels[,1:3])

make_experiment_figure(extant_cnn, extant_phylo, extant_labels, 
                       file_prefix = paste0(figure_relative_dir, "jpeg_files/extant_figure"),
                       phy_coverage = extant_phylocomp_coverage, cnn_coverage = cnn_phylocomp_coverage)

make_runtime_scatter_plots(extant_phylocomp_runtimes, 
                           file_prefix = paste0(figure_relative_dir, "jpeg_files/phylocomp_runtimes"))


########## misspect extant R0 ###############
extant_miss_R0_cnn_preds = read.table("../neural_network_dev/output/misspec_R0_cnn_preds.tsv", header = T, row.names = NULL)
extant_miss_R0_phylo_preds = read.table("../neural_network_dev/output/misspec_R0_phylo_means.tsv", header = T, row.names = NULL)
extant_miss_R0_labels = read.table("../neural_network_dev/output/misspec_R0_labels.tsv", header = T, row.names= NULL)

extant_miss_R0_phylo_coverage = read.table("../neural_network_dev/data_files/misspec_R0_coverage_report.txt", header = T, row.names = 1)
cnn_miss_R0_coverage = read.table("../neural_network_dev/data_files/missR0_cnn_coverage.tsv", header = T, row.names = 1) / 100

extant_miss_R0_ci = read.table("../phylo_analysis/hpd_estimates/extant_misspec_R0_0.95.ci", header = T, row.names = 1)
cnn_miss_R0_ci = read.table("../neural_network_dev/uq_and_adequacy/output/missR0_cnn_95q.tsv", header = T)

plot_ci_widths(cnn_miss_R0_ci, extant_miss_R0_ci, extant_miss_R0_labels[,1:3])

make_experiment_figure(extant_miss_R0_cnn_preds, extant_miss_R0_phylo_preds, extant_miss_R0_labels, 
                       file_prefix = paste0(figure_relative_dir, "jpeg_files/extant_misspec_R0_figure"),
                       phy_coverage = extant_miss_R0_phylo_coverage, cnn_coverage = cnn_miss_R0_coverage)


########## misspect extant delta ###############
extant_miss_delta_cnn_preds = read.table("../neural_network_dev/output/misspec_delta_cnn_preds.tsv", header = T, row.names = NULL)
extant_miss_delta_phylo_preds = read.table("../neural_network_dev/output/misspec_delta_phylo_means.tsv", header = T, row.names = NULL)
extant_miss_delta_labels = read.table("../neural_network_dev/output/misspec_delta_labels.tsv", header = T, row.names= NULL)

extant_miss_delta_phylo_coverage = read.table("../neural_network_dev/data_files/misspec_delta_coverage_report.txt", header = T, row.names = 1)
cnn_miss_delta_coverage = read.table("../neural_network_dev/data_files/missDelta_cnn_coverage.tsv", header = T, row.names = 1) / 100

extant_miss_delta_ci = read.table("../phylo_analysis/hpd_estimates/extant_misspec_delta_0.95.ci", header = T, row.names = 1)
cnn_miss_delta_ci = read.table("../neural_network_dev/uq_and_adequacy/output/missDeltacnn_95q.tsv", header = T)

plot_ci_widths(cnn_miss_delta_ci, extant_miss_delta_ci, extant_miss_delta_labels[,1:3])

make_experiment_figure(extant_miss_delta_cnn_preds, extant_miss_delta_phylo_preds, extant_miss_delta_labels, 
                       file_prefix = paste0(figure_relative_dir, "jpeg_files/extant_misspec_delta_figure"),
                       phy_coverage = extant_miss_delta_phylo_coverage, cnn_coverage = cnn_miss_delta_coverage)

########## misspect extant m ###############
extant_miss_m_cnn_preds = read.table("../neural_network_dev/output/misspec_migration_cnn_preds.tsv", header = T, row.names = NULL)
extant_miss_m_phylo_preds = read.table("../neural_network_dev/output/misspec_migration_phylo_means.tsv", header = T, row.names = NULL)
extant_miss_m_labels = read.table("../neural_network_dev/output/misspec_migration_labels.tsv", header = T, row.names= NULL)

extant_miss_m_phylo_coverage = read.table("../neural_network_dev/data_files/misspec_m_coverage_report.txt", header = T, row.names = 1)
cnn_miss_m_coverage = read.table("../neural_network_dev/data_files/missM_cnn_coverage.tsv", header = T, row.names = 1) / 100

extant_miss_m_ci = read.table("../phylo_analysis/hpd_estimates/extant_misspec_m_0.95.ci", header = T, row.names = 1)
cnn_miss_m_ci = read.table("../neural_network_dev/uq_and_adequacy/output/missM_cnn_95q.tsv", header = T)

plot_ci_widths(cnn_miss_m_ci, extant_miss_m_ci, extant_miss_m_labels[,1:3])

make_experiment_figure(extant_miss_m_cnn_preds, extant_miss_m_phylo_preds, extant_miss_m_labels, 
                       file_prefix = paste0(figure_relative_dir, "jpeg_files/extant_misspec_m_figure"),
                       phy_coverage = extant_miss_m_phylo_coverage, cnn_coverage = cnn_miss_m_coverage)

########## extant misspec numloc ###############
extant_miss_numloc_cnn_preds = read.table("../neural_network_dev/output/misspec_numloc_cnn_preds.tsv", header = T, row.names = NULL)
extant_miss_numloc_phylo_preds = read.table("../neural_network_dev/output/misspec_numloc_phylo_means.tsv", header = T, row.names = NULL)
extant_miss_numloc_labels = read.table("../neural_network_dev/output/misspec_numloc_labels.tsv", header = T, row.names = NULL)

extant_miss_numloc_phylo_coverage = read.table("../neural_network_dev/data_files/misspec_numloc_coverage_report.txt", header = T, row.names = 1)
cnn_miss_numloc_coverage = read.table("../neural_network_dev/data_files/missNumLoc_cnn_coverage.tsv", header = T, row.names = 1) / 100

extant_miss_numloc_ci = read.table("../phylo_analysis/hpd_estimates/extant_misspec_numloc_0.95.ci", header = T, row.names = 1)
cnn_miss_numloc_ci = read.table("../neural_network_dev/uq_and_adequacy/output/missNumLoc_cnn_95q.tsv", header = T)

plot_ci_widths(cnn_miss_numloc_ci, extant_miss_numloc_ci, extant_miss_numloc_labels[,1:3])

make_experiment_figure(extant_miss_numloc_cnn_preds, extant_miss_numloc_phylo_preds, extant_miss_numloc_labels, 
                       file_prefix = paste0(figure_relative_dir, "jpeg_files/extant_misspec_numloc_figure"),
                       phy_coverage = extant_miss_numloc_phylo_coverage, cnn_coverage = cnn_miss_numloc_coverage)

######### misspec tree ###################
extant_miss_tree_cnn = read.table("../neural_network_dev/output/misspec_tree_cnn_preds.tsv", header = T, row.names =NULL)
extant_miss_tree_phylo = read.table("../neural_network_dev/output/misspec_tree_phylo_means.tsv", header = T, row.names = NULL)
extant_miss_tree_labels = read.table("../neural_network_dev/output/misspec_tree_labels.tsv", header = T, row.names = NULL)
extant_miss_tree_robfoulds = read.table("../neural_network_dev/data_files/extant_misspec_tree_proportion_branches_shared.tsv", header = F, row.names = 1)

extant_miss_tree_phylo_coverage = read.table("../neural_network_dev/data_files/misspec_tree_coverage_report.txt", header = T, row.names = 1)
cnn_miss_tree_coverage = read.table("../neural_network_dev/data_files/missTree_cnn_coverage.tsv", header = T, row.names = 1) / 100

extant_miss_tree_ci = read.table("../phylo_analysis/hpd_estimates/extant_misspec_tree_0.95.ci", header = T, row.names = 1)
cnn_miss_tree_ci = read.table("../neural_network_dev/uq_and_adequacy/output/missTree_cnn_95q.tsv", header = T)

plot_ci_widths(cnn_miss_tree_ci, extant_miss_tree_ci, extant_miss_tree_labels[,1:3])

make_experiment_figure(extant_miss_tree_cnn, extant_miss_tree_phylo, extant_miss_tree_labels,
                       file_prefix = paste0(figure_relative_dir, "jpeg_files/extant_misspec_tree_figure"),
                       phy_coverage = extant_miss_tree_phylo_coverage, cnn_coverage = cnn_miss_tree_coverage)

quantile(extant_miss_tree_robfoulds[,1], p = c(0.025, 0.5, 0.975))

######### MTBD CNN real data covid ###############
nadeau2021_cnn_pred = read.table("../neural_network_dev/output/mtbd_nadeau2021_cnn_preds_full_and_a2.tsv", header =T, row.names = NULL)
nadeau2021_R0_log = read.table("../real_data_analysis/nadeau2021_deathdelay_europe_clade_demeR0.log", header = T, row.names =1)
nadeau2021_root = c(0.3, 0.01, 0.45, 0.23, 0.01) # see text from Nadeau et al. 2021

nadeau2021_cnn_ci = read.table("../neural_network_dev/output/nadeau2021_mtbd_95ci.tsv", header =T, row.names = 1)

locations = c("Hubei", "France", "Germany", "Italy", "Other Eur.")
nadeau2021_R0_log = nadeau2021_R0_log[,c(3,1,2,4,5)]

make_mtbd_nadeau_plots(nadeau2021_cnn_pred, nadeau2021_R0_log, 
                       nadeau2021_cnn_ci[,1:2], nadeau2021_cnn_ci[,3:4],
                       nadeau2021_root, 
                       file_prefix =paste0(figure_relative_dir, 
                                           "jpeg_files/nadeau2021_mtbd_compare"))





##############################################
################ BEST analyses ###############
##############################################
## Table S1 uses best_obj$HPI ################

extant_cnn_ape = get_ape(extant_cnn[,1:3], extant_labels[,1:3])
extant_phylo_ape = get_ape(extant_phylo[,1:3], extant_labels[,1:3])
extant_best = make_phylocomp_BESTplots(extant_cnn_ape, extant_phylo_ape,
                                       file_prefix =  paste0(figure_relative_dir,"jpeg_files/BEST_output/extant"))

extant_R0_cnn_ape = get_ape(extant_miss_R0_cnn_preds[,1:3], extant_miss_R0_labels[,1:3])
extant_R0_phylo_ape = get_ape(extant_miss_R0_phylo_preds[,1:3], extant_miss_R0_labels[,1:3])
extant_R0_best =  make_misspec_BESTplots(extant_R0_cnn_ape, extant_R0_phylo_ape, 
                                         extant_cnn_ape, extant_phylo_ape,
                                         file_prefix = paste0(figure_relative_dir,"jpeg_files/BEST_output/extant_misspec_R0"))

extant_delta_cnn_ape = get_ape(extant_miss_delta_cnn_preds[,1:3], extant_miss_delta_labels[,1:3])
extant_delta_phylo_ape = get_ape(extant_miss_delta_phylo_preds[,1:3], extant_miss_delta_labels[,1:3])
extant_delta_best =  make_misspec_BESTplots(extant_delta_cnn_ape, extant_delta_phylo_ape, 
                                            extant_cnn_ape, extant_phylo_ape,
                                            file_prefix = paste0(figure_relative_dir,"jpeg_files/BEST_output/extant_misspec_delta"))

extant_m_cnn_ape = get_ape(extant_miss_m_cnn_preds[,1:3], extant_miss_m_labels[,1:3])
extant_m_phylo_ape = get_ape(extant_miss_m_phylo_preds[,1:3], extant_miss_m_labels[,1:3])
extant_m_best =  make_misspec_BESTplots(extant_m_cnn_ape, extant_m_phylo_ape, 
                                        extant_cnn_ape, extant_phylo_ape,
                                        file_prefix = paste0(figure_relative_dir,"jpeg_files/BEST_output/extant_misspec_m"))


extant_numloc_cnn_ape = get_ape(extant_miss_numloc_cnn_preds[,1:3], extant_miss_numloc_labels[,1:3])
extant_numloc_phylo_ape = get_ape(extant_miss_numloc_phylo_preds[,1:3], extant_miss_numloc_labels[,1:3])
extant_numloc_best = make_misspec_BESTplots(extant_numloc_cnn_ape, extant_numloc_phylo_ape,
                                            extant_cnn_ape, extant_phylo_ape,
                                            file_prefix = paste0(figure_relative_dir,"jpeg_files/BEST_output/extant_misspec_numloc"))


extant_tree_cnn_ape = get_ape(extant_miss_tree_cnn[,1:3], extant_miss_tree_labels[,1:3])
extant_tree_phylo_ape = get_ape(extant_miss_tree_phylo[,1:3], extant_miss_tree_labels[,1:3])
extant_tree_best = make_misspec_BESTplots(extant_tree_cnn_ape, extant_tree_phylo_ape,
                                            extant_cnn_ape, extant_phylo_ape,
                                            file_prefix = paste0(figure_relative_dir,"jpeg_files/BEST_output/extant_misspec_tree"))




