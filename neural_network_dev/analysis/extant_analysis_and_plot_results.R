setwd("C:/Users/ammon_work/Desktop/git_repos/epi_geo_simulation/neural_network_dev/analysis")
library(vioplot)
library(expm)
library(BEST)
source("analysis_support_functions.R")
figure_relative_dir = "../../manuscript/figures/"

#### True specified model ########
extant_cnn = read.table("../output/extant_cnn_preds.tsv", header = T, row.names = NULL)
extant_phylo = read.table("../output/extant_phylo_means.tsv", header  = T, row.names = NULL)
extant_labels = read.table("../output/extant_labels.tsv", header = T, row.names = NULL)
make_experiment_figure(extant_cnn, extant_phylo, extant_labels, 
                       file_prefix = paste0(figure_relative_dir, "jpeg_files/extant_figure"))

extant_phylocomp_runtimes = read.table("../output/extant_phylocomp_runtimes.tsv", header = T, row.names = 1)
make_runtime_scatter_plots(extant_phylocomp_runtimes, 
                           file_prefix = paste0(figure_relative_dir, "jpeg_files/phylocomp_runtimes"))

extant_phylocomp_coverage = read.table("../data_files/extant_phylocomp_coverage.txt", header = T, row.names =1)
make_coverage_plot(extant_phylocomp_coverage, file_prefix = paste0(figure_relative_dir, "jpeg_files/extant_phylocomp_coverage"), 
                   n = nrow(extant_labels))


########## misspect extant R0 ###############
extant_miss_R0_cnn_preds = read.table("../output/misspec_R0_cnn_preds.tsv", header = T, row.names = NULL)
extant_miss_R0_phylo_preds = read.table("../output/misspec_R0_phylo_means.tsv", header = T, row.names = NULL)
extant_miss_R0_labels = read.table("../output/misspec_R0_labels.tsv", header = T, row.names= NULL)
make_experiment_figure(extant_miss_R0_cnn_preds, extant_miss_R0_phylo_preds, extant_miss_R0_labels, 
                       file_prefix = paste0(figure_relative_dir, "jpeg_files/extant_misspec_R0_figure"))


########## misspect extant delta ###############
extant_miss_delta_cnn_preds = read.table("../output/misspec_delta_cnn_preds.tsv", header = T, row.names = NULL)
extant_miss_delta_phylo_preds = read.table("../output/misspec_delta_phylo_means.tsv", header = T, row.names = NULL)
extant_miss_delta_labels = read.table("../output/misspec_delta_labels.tsv", header = T, row.names= NULL)
make_experiment_figure(extant_miss_delta_cnn_preds, extant_miss_delta_phylo_preds, extant_miss_delta_labels, 
                       file_prefix = paste0(figure_relative_dir, "jpeg_files/extant_misspec_delta_figure"))


########## misspect extant m ###############
extant_miss_m_cnn_preds = read.table("../output/misspec_migration_cnn_preds.tsv", header = T, row.names = NULL)
extant_miss_m_phylo_preds = read.table("../output/misspec_migration_phylo_means.tsv", header = T, row.names = NULL)
extant_miss_m_labels = read.table("../output/misspec_migration_labels.tsv", header = T, row.names= NULL)
make_experiment_figure(extant_miss_m_cnn_preds, extant_miss_m_phylo_preds, extant_miss_m_labels, 
                       file_prefix = paste0(figure_relative_dir, "jpeg_files/extant_misspec_m_figure"))


######### misspec tree ###################
extant_miss_tree_cnn = read.table("../output/misspec_tree_cnn_preds.tsv", header = T, row.names =NULL)
extant_miss_tree_phylo = read.table("../output/misspec_tree_phylo_means.tsv", header = T, row.names = NULL)
extant_miss_tree_labels = read.table("../output/misspec_tree_labels.tsv", header = T, row.names = NULL)
extant_miss_tree_robfoulds = read.table("../data_files/extant_misspec_tree_proportion_branches_shared.tsv", header = F, row.names = 1)
make_experiment_figure(extant_miss_tree_cnn, extant_miss_tree_phylo, extant_miss_tree_labels,
                       file_prefix = paste0(figure_relative_dir, "jpeg_files/extant_misspec_tree_figure"))
quantile(extant_miss_tree_robfoulds[,1], p = c(0.025, 0.5, 0.975))

########## extant misspec numloc ###############
extant_miss_numloc_cnn_preds = read.table("../output/misspec_numloc_cnn_preds.tsv", header = T, row.names = NULL)
extant_miss_numloc_phylo_preds = read.table("../output/misspec_numloc_phylo_means.tsv", header = T, row.names = NULL)
extant_miss_numloc_labels = read.table("../output/misspec_numloc_labels.tsv", header = T, row.names = NULL)
make_experiment_figure(extant_miss_numloc_cnn_preds, extant_miss_numloc_phylo_preds, extant_miss_numloc_labels, 
                       file_prefix = paste0(figure_relative_dir, "jpeg_files/extant_misspec_numloc_figure"))


######### MTBD CNN real data covid ###############
nadeau2021_cnn_pred = read.table("../output/mtbd_nadeau2021_cnn_preds_full_and_a2.tsv", header =T, row.names = NULL)
nadeau2021_R0_log = read.table("../data_files/other_files/nadeau2021_deathdelay_europe_clade_demeR0.log", header = T, row.names =1)
nadeau2021_root = c(0.3, 0.01, 0.45, 0.23, 0.01)

locations = c("Hubei", "France", "Germany", "Italy", "Other Eur.")
nadeau2021_R0_log = nadeau2021_R0_log[,c(3,1,2,4,5)]

make_mtbd_nadeau_plots(nadeau2021_cnn_pred, nadeau2021_R0_log, nadeau2021_root, 
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




