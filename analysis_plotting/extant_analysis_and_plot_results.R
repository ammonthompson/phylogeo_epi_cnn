# set working dir to location of script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(vioplot)
library(expm)
source("analysis_support_functions.R")

# figure settings
fig_scale = 10
file_type = "jpg"

# output parent directory
figure_relative_dir = "figures/jpeg_files"

#### UQ calibration ############
caltest_coverage = read.table("../neural_network_dev/uq_and_adequacy/output/validation_CQR_coverage.tsv",
                              header = T, row.names = 1)/100
uncal_test_coverage = read.table("../neural_network_dev/uq_and_adequacy/output/uncalibrated_validation_CQR_coverage.tsv",
                              header = T, row.names = 1)/100

caltest_ci = read.table("../neural_network_dev/uq_and_adequacy/output/validation_CQR_ci.tsv", header = T)
caltest_labels = read.table("../neural_network_dev/uq_and_adequacy/output/validation_CQR_labels.tsv", header = T)

make_coverage_figure(caltest_coverage, uncal_test_coverage, file_prefix = paste0(figure_relative_dir, "/Figure_3_CPI_coverage"), n=5000,
                     title = c("Calibrated qCNN (CPI) Coverage","Uncalibrated qCNN Coverage"), mkfig=T, cx = 1, wh = c(1,1), file_type = file_type)


#### True specified model ########
extant_cnn = read.table("../neural_network_dev/output/extant_cnn_preds.tsv", header = T, row.names = NULL)
extant_phylo = read.table("../neural_network_dev/output/extant_phylo_means.tsv", header  = T, row.names = NULL)
extant_labels = read.table("../neural_network_dev/output/extant_labels.tsv", header = T, row.names = NULL)
extant_phylocomp_runtimes = read.table("../neural_network_dev/output/extant_phylocomp_runtimes.tsv", header = T, row.names = 1)

extant_phylocomp_coverage = read.table("../phylo_analysis/hpd_estimates/extant_phylocomp_coverage.txt", header = T, row.names =1)
cnn_phylocomp_coverage = read.table("../neural_network_dev/uq_and_adequacy/output/phylocomp_CQR_coverage.tsv", header =T, row.names = 1) / 100

extant_phylocomp_ci = read.table("../phylo_analysis/hpd_estimates/extant_phylocomp_0.95.ci", header = T, row.names = 1)
cnn_phylocomp_ci = read.table("../neural_network_dev/uq_and_adequacy/output/phylocomp_CQR_ci.tsv", header = T)

make_ci_width_figure(cnn_phylocomp_ci, extant_phylocomp_ci, extant_labels[,1:3],
                     file_prefix = paste0(figure_relative_dir, "/Figure_S4_phylocomp_ci"), file_type = file_type)

make_experiment_figure(extant_cnn, extant_phylo, extant_labels,
                       file_prefix = paste0(figure_relative_dir, "/Figure_2_extant_figure"),
                       phy_coverage = extant_phylocomp_coverage, cnn_coverage = cnn_phylocomp_coverage, file_type = file_type)

make_runtime_scatter_plots(extant_phylocomp_runtimes,
                           file_prefix = paste0(figure_relative_dir, "/Figure_4_phylocomp_runtimes"), file_type = file_type)


########## misspec extant R0 ###############
extant_miss_R0_cnn_preds = read.table("../neural_network_dev/output/misspec_R0_cnn_preds.tsv", header = T, row.names = NULL)
extant_miss_R0_phylo_preds = read.table("../neural_network_dev/output/misspec_R0_phylo_means.tsv", header = T, row.names = NULL)
extant_miss_R0_labels = read.table("../neural_network_dev/output/misspec_R0_labels.tsv", header = T, row.names= NULL)

extant_miss_R0_phylo_coverage = read.table("../phylo_analysis/hpd_estimates/misspec_R0_coverage_report.txt", header = T, row.names = 1)
cnn_miss_R0_coverage = read.table("../neural_network_dev/uq_and_adequacy/output/missR0_CQR_coverage.tsv", header = T, row.names = 1) / 100

extant_miss_R0_ci = read.table("../phylo_analysis/hpd_estimates/extant_misspec_R0_0.95.ci", header = T, row.names = 1)
cnn_miss_R0_ci = read.table("../neural_network_dev/uq_and_adequacy/output/missR0_CQR_ci.tsv", header = T)

make_ci_width_figure(cnn_miss_R0_ci, extant_miss_R0_ci, extant_miss_R0_labels[,1:3],
                     file_prefix = paste0(figure_relative_dir, "/Figure_S6_missR0_ci"), file_type = file_type)

make_experiment_figure(extant_miss_R0_cnn_preds, extant_miss_R0_phylo_preds, extant_miss_R0_labels,
                       file_prefix = paste0(figure_relative_dir, "/Figure_5_extant_misspec_R0_figure"),
                       phy_coverage = extant_miss_R0_phylo_coverage, cnn_coverage = cnn_miss_R0_coverage, file_type = file_type)


########## misspect extant delta ###############
extant_miss_delta_cnn_preds = read.table("../neural_network_dev/output/misspec_delta_cnn_preds.tsv", header = T, row.names = NULL)
extant_miss_delta_phylo_preds = read.table("../neural_network_dev/output/misspec_delta_phylo_means.tsv", header = T, row.names = NULL)
extant_miss_delta_labels = read.table("../neural_network_dev/output/misspec_delta_labels.tsv", header = T, row.names= NULL)

extant_miss_delta_phylo_coverage = read.table("../phylo_analysis/hpd_estimates/misspec_delta_coverage_report.txt", header = T, row.names = 1)
cnn_miss_delta_coverage = read.table("../neural_network_dev/uq_and_adequacy/output/missDelta_CQR_coverage.tsv", header = T, row.names = 1) / 100

extant_miss_delta_ci = read.table("../phylo_analysis/hpd_estimates/extant_misspec_delta_0.95.ci", header = T, row.names = 1)
cnn_miss_delta_ci = read.table("../neural_network_dev/uq_and_adequacy/output/missDelta_CQR_ci.tsv", header = T)

make_ci_width_figure(cnn_miss_delta_ci, extant_miss_delta_ci, extant_miss_delta_labels[,1:3],
                     file_prefix = paste0(figure_relative_dir, "/Figure_S8_missDelta_ci"), file_type = file_type)

make_experiment_figure(extant_miss_delta_cnn_preds, extant_miss_delta_phylo_preds, extant_miss_delta_labels,
                       file_prefix = paste0(figure_relative_dir, "/Figure_6_extant_misspec_delta_figure"),
                       phy_coverage = extant_miss_delta_phylo_coverage, cnn_coverage = cnn_miss_delta_coverage, file_type = file_type)

########## misspect extant m ###############
extant_miss_m_cnn_preds = read.table("../neural_network_dev/output/misspec_migration_cnn_preds.tsv", header = T, row.names = NULL)
extant_miss_m_phylo_preds = read.table("../neural_network_dev/output/misspec_migration_phylo_means.tsv", header = T, row.names = NULL)
extant_miss_m_labels = read.table("../neural_network_dev/output/misspec_migration_labels.tsv", header = T, row.names= NULL)

extant_miss_m_phylo_coverage = read.table("../phylo_analysis/hpd_estimates/misspec_m_coverage_report.txt", header = T, row.names = 1)
cnn_miss_m_coverage = read.table("../neural_network_dev/uq_and_adequacy/output/missM_CQR_coverage.tsv", header = T, row.names = 1) / 100

extant_miss_m_ci = read.table("../phylo_analysis/hpd_estimates/extant_misspec_m_0.95.ci", header = T, row.names = 1)
cnn_miss_m_ci = read.table("../neural_network_dev/uq_and_adequacy/output/missM_CQR_ci.tsv", header = T)

make_ci_width_figure(cnn_miss_m_ci, extant_miss_m_ci, extant_miss_m_labels[,1:3],
                     file_prefix = paste0(figure_relative_dir, "/Figure_S10_missM_ci"), file_type = file_type)

make_experiment_figure(extant_miss_m_cnn_preds, extant_miss_m_phylo_preds, extant_miss_m_labels,
                       file_prefix = paste0(figure_relative_dir, "/Figure_7_extant_misspec_m_figure"),
                       phy_coverage = extant_miss_m_phylo_coverage, cnn_coverage = cnn_miss_m_coverage, file_type = file_type)

########## extant misspec numloc ###############
extant_miss_numloc_cnn_preds = read.table("../neural_network_dev/output/misspec_numloc_cnn_preds.tsv", header = T, row.names = NULL)
extant_miss_numloc_phylo_preds = read.table("../neural_network_dev/output/misspec_numloc_phylo_means.tsv", header = T, row.names = NULL)
extant_miss_numloc_labels = read.table("../neural_network_dev/output/misspec_numloc_labels.tsv", header = T, row.names = NULL)

extant_miss_numloc_phylo_coverage = read.table("../phylo_analysis/hpd_estimates/misspec_numloc_coverage_report.txt", header = T, row.names = 1)
cnn_miss_numloc_coverage = read.table("../neural_network_dev/uq_and_adequacy/output/missNumLoc_CQR_coverage.tsv", header = T, row.names = 1) / 100

extant_miss_numloc_ci = read.table("../phylo_analysis/hpd_estimates/extant_misspec_numloc_0.95.ci", header = T, row.names = 1)
cnn_miss_numloc_ci = read.table("../neural_network_dev/uq_and_adequacy/output/missNumLoc_CQR_ci.tsv", header = T)

make_ci_width_figure(cnn_miss_numloc_ci, extant_miss_numloc_ci, extant_miss_numloc_labels[,1:3],
                     file_prefix = paste0(figure_relative_dir, "/Figure_S12_missNumloc_ci"), file_type = file_type)

make_experiment_figure(extant_miss_numloc_cnn_preds, extant_miss_numloc_phylo_preds, extant_miss_numloc_labels,
                       file_prefix = paste0(figure_relative_dir, "/Figure_8_extant_misspec_numloc_figure"),
                       phy_coverage = extant_miss_numloc_phylo_coverage, cnn_coverage = cnn_miss_numloc_coverage, file_type = file_type)

######### misspec tree ###################
extant_miss_tree_cnn = read.table("../neural_network_dev/output/misspec_tree_cnn_preds.tsv", header = T, row.names =NULL)
extant_miss_tree_phylo = read.table("../neural_network_dev/output/misspec_tree_phylo_means.tsv", header = T, row.names = NULL)
extant_miss_tree_labels = read.table("../neural_network_dev/output/misspec_tree_labels.tsv", header = T, row.names = NULL)
extant_miss_tree_jaccard = read.table("../neural_network_dev/data_files/extant_misspec_tree_proportion_branches_shared.tsv", header = F, row.names = 1)

extant_miss_tree_phylo_coverage = read.table("../phylo_analysis/hpd_estimates/misspec_tree_coverage_report.txt", header = T, row.names = 1)
cnn_miss_tree_coverage = read.table("../neural_network_dev/uq_and_adequacy/output/missTree_CQR_coverage.tsv", header = T, row.names = 1) / 100

extant_miss_tree_ci = read.table("../phylo_analysis/hpd_estimates/extant_misspec_tree_0.95.ci", header = T, row.names = 1)
cnn_miss_tree_ci = read.table("../neural_network_dev/uq_and_adequacy/output/missTree_CQR_ci.tsv", header = T)

make_ci_width_figure(cnn_miss_tree_ci, extant_miss_tree_ci, extant_miss_tree_labels[,1:3],
                     file_prefix = paste0(figure_relative_dir, "/Figure_S14_missTree_ci"), file_type = file_type)

make_experiment_figure(extant_miss_tree_cnn, extant_miss_tree_phylo, extant_miss_tree_labels,
                       file_prefix = paste0(figure_relative_dir, "/Figure_9_extant_misspec_tree_figure"),
                       phy_coverage = extant_miss_tree_phylo_coverage, cnn_coverage = cnn_miss_tree_coverage, file_type = file_type)

quantile(extant_miss_tree_jaccard[,1], p = c(0.025, 0.5, 0.975))


######### MTBD CNN real data covid ###############
# CNN results and Nadeau paper
cnn_point_preds = read.table("../neural_network_dev/output/mtbd_nadeau2021_cnn_preds_full_and_a2.tsv", header =T, row.names = NULL)
cnn_cpi = read.table("../neural_network_dev/output/nadeau2021_mtbd_95ci.tsv", header =T, row.names = 1)
nadeau2021_rate_params_log = read.table("../real_data_analysis/nadeau2021_deathdelay_rate_params.log", header = T, row.names =1)

nadeau2021_root = c(0.3, 0.01, 0.45, 0.23, 0.01) # see text from Nadeau et al. 2021
nadeau2021_R0_log = nadeau2021_rate_params_log[,1:5]
nadeau2021_m_log = nadeau2021_rate_params_log[,grep(pattern = "migrationRateSMEpi", colnames(nadeau2021_rate_params_log))]
nadeau2021_rho_log = nadeau2021_rate_params_log[,grep(pattern = "samplingProportionSVEpi", colnames(nadeau2021_rate_params_log))]

fig_location_order = c(3,1,2,4,5)
locations = c("Hubei", "France", "Germany", "Italy", "Other Eur.")
nadeau2021_R0_log = nadeau2021_R0_log[,fig_location_order]

make_mtbd_nadeau_plots(cnn_point_preds, nadeau2021_R0_log,
                       cnn_cpi[,1:2], cnn_cpi[,3:4],
                       nadeau2021_root,
                       file_prefix =paste0(figure_relative_dir,
                                           "/Figure_10_nadeau2021_mtbd_compare"), file_type = file_type)

# compare delta and m estimates ( events per infectious period )
gamma_cnn = 0.05 # (arbitrary)
gamma_nadeau = 36.5 # (year^-1)

# scale so rates are in units of recovery + sample period
sample_prop_cnn = cnn_point_preds$sample_rate/(gamma_cnn + cnn_point_preds$sample_rate)
m_cnn = cnn_point_preds$migration_rate/(gamma_cnn + cnn_point_preds$sample_rate)
sample_prop_cnn_ci = cnn_cpi[6,]/(gamma_cnn + cnn_point_preds$sample_rate)
m_prop_cnn_ci = cnn_cpi[7,]/(gamma_cnn + cnn_point_preds$sample_rate)
cnn_prior_m_prop_sample_prop = c(0.0001, 0.005)/(gamma_cnn + cnn_point_preds$sample_rate)

nad_m_prop = nadeau2021_m_log[,-c(2,6,15,19)]/(gamma_nadeau + gamma_nadeau * (nad_sample_proportion_range/(1-nad_sample_proportion_range)))

# make migration and sample rate SI figure
pdf("figures/pdf_files/Figure_S15_nadeau2021_migration_sample_compare.pdf", width = 0.75*fig_scale, height = 1 * fig_scale)
layout(matrix(seq(2), ncol = 1))
# migrations per effective infectious period
vioplot(log(nad_m_prop), rectCol="orange", col = rgb(1, 0.66, 0, 0.8),
        names = rep("", ncol(nad_m_prop)), ylab = "log pairwise migration rate", xlab = "location pairs")
points(c(0.2, 0.4), log(m_cnn), col = rgb(0,0,1,1), cex = 1, lwd = 2, pch = c(16, 4))
arrows(x0 = 0, y0 = log(cnn_prior_m_prop_sample_prop[1]), y1 = log(cnn_prior_m_prop_sample_prop[2]), length = 0, col = "darkgray", lwd = 4)
arrows(x0 = c(0.2, 0.4), y0 = unlist(log(m_prop_cnn_ci[c(1,3)])), y1 = unlist(log(m_prop_cnn_ci[c(2,4)])), length = 0, col = "blue", lwd = 2)

# samples per effective infectious period
vioplot(log(nadeau2021_rho_log[,fig_location_order]), rectCol="orange", col = rgb(1, 0.66, 0, 0.8), names = locations,
        ylab = "log proportion sampled")
points(c(0.5, 0.6), log(sample_prop_cnn), col = rgb(0,0,1,1), cex = 1, lwd = 2, pch = c(16, 4))
arrows(x0 = 0.4, y0 = log(cnn_prior_m_prop_sample_prop[1]), y1 = log(cnn_prior_m_prop_sample_prop[2]), length = 0, col = "darkgray", lwd = 4)
arrows(x0 = c(0.5, 0.6), y0 = unlist(log(sample_prop_cnn_ci[c(1,3)])), y1 = unlist(log(sample_prop_cnn_ci[c(2,4)])), length = 0, col = "blue", lwd = 2)
layout(1)
dev.off()



##############################################
################ BEST analyses ###############
##############################################
## Table S1 uses best_obj$HPI ################
library(BEST) #need to fix rjags here

extant_cnn_ape = get_ape(extant_cnn[,1:3], extant_labels[,1:3])
extant_phylo_ape = get_ape(extant_phylo[,1:3], extant_labels[,1:3])
extant_best = make_phylocomp_BESTplots(extant_cnn_ape, extant_phylo_ape,
                                       file_prefix =  paste0(figure_relative_dir,"/BEST_output/extant"))

extant_R0_cnn_ape = get_ape(extant_miss_R0_cnn_preds[,1:3], extant_miss_R0_labels[,1:3])
extant_R0_phylo_ape = get_ape(extant_miss_R0_phylo_preds[,1:3], extant_miss_R0_labels[,1:3])
extant_R0_best =  make_misspec_BESTplots(extant_R0_cnn_ape, extant_R0_phylo_ape,
                                         extant_cnn_ape, extant_phylo_ape,
                                         file_prefix = paste0(figure_relative_dir,"/BEST_output/extant_misspec_R0"))

extant_delta_cnn_ape = get_ape(extant_miss_delta_cnn_preds[,1:3], extant_miss_delta_labels[,1:3])
extant_delta_phylo_ape = get_ape(extant_miss_delta_phylo_preds[,1:3], extant_miss_delta_labels[,1:3])
extant_delta_best =  make_misspec_BESTplots(extant_delta_cnn_ape, extant_delta_phylo_ape,
                                            extant_cnn_ape, extant_phylo_ape,
                                            file_prefix = paste0(figure_relative_dir,"/BEST_output/extant_misspec_delta"))

extant_m_cnn_ape = get_ape(extant_miss_m_cnn_preds[,1:3], extant_miss_m_labels[,1:3])
extant_m_phylo_ape = get_ape(extant_miss_m_phylo_preds[,1:3], extant_miss_m_labels[,1:3])
extant_m_best =  make_misspec_BESTplots(extant_m_cnn_ape, extant_m_phylo_ape,
                                        extant_cnn_ape, extant_phylo_ape,
                                        file_prefix = paste0(figure_relative_dir,"/BEST_output/extant_misspec_m"))


extant_numloc_cnn_ape = get_ape(extant_miss_numloc_cnn_preds[,1:3], extant_miss_numloc_labels[,1:3])
extant_numloc_phylo_ape = get_ape(extant_miss_numloc_phylo_preds[,1:3], extant_miss_numloc_labels[,1:3])
extant_numloc_best = make_misspec_BESTplots(extant_numloc_cnn_ape, extant_numloc_phylo_ape,
                                            extant_cnn_ape, extant_phylo_ape,
                                            file_prefix = paste0(figure_relative_dir,"/BEST_output/extant_misspec_numloc"))


extant_tree_cnn_ape = get_ape(extant_miss_tree_cnn[,1:3], extant_miss_tree_labels[,1:3])
extant_tree_phylo_ape = get_ape(extant_miss_tree_phylo[,1:3], extant_miss_tree_labels[,1:3])
extant_tree_best = make_misspec_BESTplots(extant_tree_cnn_ape, extant_tree_phylo_ape,
                                            extant_cnn_ape, extant_phylo_ape,
                                            file_prefix = paste0(figure_relative_dir,"/BEST_output/extant_misspec_tree"))




