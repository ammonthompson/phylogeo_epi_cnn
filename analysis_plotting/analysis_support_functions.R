library(vioplot)
library(expm)
library(BEST)

# fig dims
fig_scale = 10


### Functions for analysis

get_rootloc_accuracy <- function(y_pred, y_true){

  return(rowSums(y_pred * y_true))

}

get_ape <- function(y_pred, y_true){

  return(100 * abs(y_pred - y_true)/y_true)

}

summarize_error <- function(cnn_ape, phylo_ape){

  # amount of difference between CNN and posterior mean estimates
  cnn_minus_phylo_ape <- cnn_ape - phylo_ape
  
  parms = c("R0:          ", "sample rate:   ", "migration rate: ")

  cat("mean(CNN APE - post.mean APE) = \n", colMeans(cnn_minus_phylo_ape), "\n\n")
  cat("95% CNN - post.mean APE sample intervals: \n", sapply(seq(ncol(cnn_minus_phylo_ape)), function(i) 
    c(parms[i], quantile((cnn_minus_phylo_ape[,i]), probs = c(0.025,0.975)), "\n")), "\n")

}

plot_error_numtips_relationship <- function(cnn_ape, phylo_ape, numtips){
  xlab = ""
  main = c(expression("R"[0]), expression(delta), "m")
  layout(matrix(seq(6), ncol = 2, byrow = T))
  
  sapply(seq(3), function(i){ 
    if(i == 3) xlab = c("Post. mean APE", "Num tips")
    if(i %% 2 == 1) ylab = "CNN APE"
    
    # plot cnn_ape and phylo_ape relationship and color by num tips
    plot(cnn_ape[,i], phylo_ape[,i], pch = 16, main = main[i], xlab = xlab[1], ylab = "CNN APE",
         col = rgb(numtips[,1]/499, 0, 1 - numtips[,1]/499, 0.75), log = "xy")
    abline(0,1)
    
    # plot cnn_ape - phylo_ape relationship with num tips
    plot(numtips[,1], cnn_ape[,i] - phylo_ape[,i], pch = 16, main = main[i], xlab = xlab[2], 
         ylab = expression("CNN " - " Post. mean APE"))
    abline(h=0, col = rgb(0,0,0,0.5), lwd = 2)
    
    lmod = lm(cnn_ape[,i] - phylo_ape[,i] ~ numtips[,1])
    abline(lmod, col = "red")
    
  })
  layout(1)
}

plot_error_as_function_numtips <- function(cnn_ape, phylo_ape, ref_ape, cnnphylo_numtips, ref_numtips){

    xlab = "Num. tips"
    ylab = ""
    main = c(expression("R"[0]), expression(delta), "m")
    
    layout(matrix(seq(3), ncol = 3, byrow = T))
  
    sapply(seq(3), function(i){
      if(i == 1) ylab = "log APE"
      
      ymax = max(log(c(cnn_ape[,i], phylo_ape[,i], ref_ape[,i])) )
      ymin = min(log(c(cnn_ape[,i], phylo_ape[,i], ref_ape[,i])) )
      
      plot(ref_numtips[,1], log(ref_ape[,i]), pch = 16, xlab = xlab, main = main[i], ylab = ylab,
           ylim = c(ymin, ymax))
      points(cnnphylo_numtips[,1], log(cnn_ape[,i]), pch = 16, col = rgb(0,0,1,0.5))
      points(cnnphylo_numtips[,1], log(phylo_ape[,i]), pch = 16, col = rgb(1,0,0,0.5))
      
      ref_lm = lm(log(ref_ape[,i]) ~ ref_numtips[,1])
      cnn_lm = lm(log(cnn_ape[,i]) ~ cnnphylo_numtips[,1])
      phylo_lm = lm(log(phylo_ape[,i]) ~ cnnphylo_numtips[,1])
      
      abline(ref_lm)
      abline(cnn_lm, col = "blue")
      abline(phylo_lm, col = "red")
    
  })
  layout(1)
}



# figure making
make_experiment_figure <- function(cnn_preds, phylo_preds, labels, file_prefix = NULL){
  
  cnn_rates = cnn_preds[,1:3]
  phylo_rates = phylo_preds[,1:3]
  rates_labels = labels[,1:3]
  
  cnn_root = cnn_preds[,-c(1:3)]
  phylo_root = phylo_preds[,-c(1:3)]
  root_labels = labels[,-c(1:3)]
  
  
  if(!is.null(file_prefix)) jpeg(paste0(file_prefix, ".jpg"), units = "in", quality = 100,
                                 res = 400, width = 1*fig_scale, height = 0.8*fig_scale)
  
  grid = matrix(c(seq(9),10, 10, 11), ncol = 4)
  layout(grid, widths = c(1,1,1,1))
  
  
  make_scatter_plot(cnn_rates, phylo_rates, rates_labels, set_layout = FALSE, panel_label = TRUE)
  
  make_error_difference_boxplot(cnn_rates, phylo_rates, rates_labels, panel_label = TRUE)
  
  make_root_location_plots(cnn_root, phylo_root, root_labels, panel_label = TRUE)
  
  if(! is.null(file_prefix)) dev.off()
  
  layout(1)
  
  
}

make_scatter_plot <- function(cnn_pred, phylo_pred, label = NULL, file_prefix = NULL, file_type = "pdf",
                              panel_label = FALSE, set_layout = TRUE, phylo_row_main_names = NULL){
  
  if(is.null(phylo_row_main_names)) phylo_row_main_names = c(expression("R"["0"]),  expression(delta[""]), expression("m"[""]))
  
  if(!is.null(file_prefix)){
    if(file_type == "pdf"){
      pdf(paste0(file_prefix, ".pdf"), width = (0.25 + 0.25 * ncol(cnn_pred)) * fig_scale, height = 1*fig_scale)
    }else if(file_type == "jpeg"){
      jpeg(paste0(file_prefix, ".jpg"), width = (0.25 + 0.25 * ncol(cnn_pred)) * fig_scale, height = 1*fig_scale, 
           res = 400, quality = 100, units = "in", pointsize = 16)
    }
  }
  
  top_right_mar = par("mar")[c(3,4)] * 0.5
  old_par = par("mar")
  par("mar" = c(par("mar")[1:2], top_right_mar))
  
  if(set_layout){
    if(is.null(label)){
      layout(matrix(seq(ncol(cnn_pred)), nrow = 1))
    }else{
      layout(matrix(seq(ncol(cnn_pred)*3), nrow = 3, byrow = F))
    }
  }
  
  for(i in seq(ncol(cnn_pred))){
    if(!is.null(label)){
      ylabel = ifelse((i == 1), "True value", "")
      plot(cnn_pred[,i], label[,i], xlab = "CNN Prediction", ylab = ylabel,
           main = phylo_row_main_names[i], pch = 16, col = rgb(0,0,1,0.8), cex.main = 1.75, cex.lab = 1.25)
      abline(0,1,col = "black")
      if(i == 1 & panel_label == TRUE){
        pplt <- par("plt")
        adjx <- (0 - pplt[1]) / (pplt[2] - pplt[1])
        liney = par("mar")[3] - 1.75
        mtext("A", side = 3, cex = 1.5, adj = adjx, line = liney)
      }
      
      plot(phylo_pred[,i], label[,i], xlab = "Mean Posterior Estimate", ylab = ylabel,
           main = "", pch = 16, col = rgb(1,0,0,0.8), cex.lab = 1.25)
      abline(0,1,col = "black")
      
    }
    ylabel = ifelse((i == 1), "Mean Posterior Estimate", "")
    
    plot(cnn_pred[,i], phylo_pred[,i], xlab = "CNN Prediction", ylab = ylabel,
         main = "", pch = 16, col = "orange", cex.lab = 1.25)
    abline(0,1,col = "black")
  }
  
  par("mar" = old_par)
  if(set_layout) layout(1)
  if(!is.null(file_prefix)) dev.off()
}





v2_make_scatter_plot <- function(cnn_pred, phylo_pred, label = NULL, file_prefix = NULL, file_type = "pdf",
                              panel_label = FALSE, set_layout = TRUE, phylo_row_main_names = NULL){
  
  if(is.null(phylo_row_main_names)) phylo_row_main_names = c(expression("R"["0"]),  expression(delta[""]), expression("m"[""]))
  
  # if write to file, pdf or jpeg?
  if(!is.null(file_prefix)){
    if(file_type == "pdf"){
      pdf(paste0(file_prefix, ".pdf"), width = (0.2 + 0.25 * ncol(cnn_pred)) * fig_scale, height = 1*fig_scale)
    }else if(file_type == "jpeg"){
      jpeg(paste0(file_prefix, ".jpg"), width = (0.2 + 0.25 * ncol(cnn_pred)) * fig_scale, height = 1*fig_scale, 
           res = 400, quality = 100, units = "in", pointsize = 16)
    }
  }
  
  
  top_right_mar = par("mar")[c(3,4)] * 0.5
  old_par = par("mar")
  par("mar" = c(par("mar")[1:2], top_right_mar))
  
  if(set_layout){
    if(is.null(label)){
      layout(matrix(seq(ncol(cnn_pred)), nrow = 1))
    }else{
      layout(matrix(seq(ncol(cnn_pred)*4), nrow = 4, byrow = F))
    }
  }
  
  for(i in seq(ncol(cnn_pred))){
    if(!is.null(label)){
      ylabel = ifelse((i == 1), "True value", "")
      plot(cnn_pred[,i], label[,i], xlab = "CNN Prediction", ylab = ylabel,
           main = phylo_row_main_names[i], pch = 16, col = rgb(0,0,1,0.8), cex.main = 1.75, cex.lab = 1.25)
      abline(0,1,col = "black")
      
      # place sub-panel label (i.e. A, B, etc.)
      if(i == 1 & panel_label == TRUE){
        pplt <- par("plt")
        adjx <- (0 - pplt[1]) / (pplt[2] - pplt[1])
        liney = par("mar")[3] - 1.75
        mtext("A", side = 3, cex = 1.5, adj = adjx, line = liney)
      }
      
      plot(phylo_pred[,i], label[,i], xlab = "Mean Posterior Estimate", ylab = ylabel,
           main = "", pch = 16, col = rgb(1,0,0,0.8), cex.lab = 1.25)
      abline(0,1,col = "black")
      
    }
    ylabel = ifelse((i == 1), "Mean Posterior Estimate", "")
    
    # CNN vs. post. mean
    plot(cnn_pred[,i], phylo_pred[,i], xlab = "CNN Prediction", ylab = ylabel,
         main = "", pch = 16, col = "orange", cex.lab = 1.25)
    abline(0,1,col = "black")
    
    ylabel = ifelse((i == 1), "Frequency", "")
    # CNN_APE - post.mean_APE
    # hist(get_ape(cnn_pred[,i], label[,i]) - get_ape(phylo_pred[,i], label[,i]),
    #      main = "", breaks = 10, cex.lab = 1.25,
    #      xlab = "CNN APE - Post. mean APE", ylab = ylabel, col = 'dark gray', border = "white")
    
    difference = get_ape(cnn_pred[,i], label[,i]) - get_ape(phylo_pred[,i], label[,i])
    # hist((cnn_pred[,i]-phylo_pred[,i])/label[,i] * 100,
    #      main = "", breaks = 10, cex.lab = 1.25,
    #      xlab = "CNN APE - Post. mean APE", ylab = ylabel, col = 'dark gray', border = "white")
    # abline(v=0, col = "red", lwd = 3)
    
    dbx = boxplot(difference, plot = FALSE)
    upper_cutoff = ifelse(max(dbx$out) < max(dbx$stats), max(dbx$stats), mean(dbx$out[dbx$out > max(dbx$stats)]))
    lower_cutoff = ifelse(min(dbx$out) > min(dbx$stats), min(dbx$stats), mean(dbx$out[dbx$out < min(dbx$stats)]))
    boxplot(NULL, main = "", horizontal = T,
            xlab = expression("CNN " - " Post. mean APE"), outline = F,
            ylim = c(lower_cutoff, upper_cutoff), cex.lab = 1.25)
    
    abline(v=0,col = "red")
    
    difference[which(difference < lower_cutoff, arr.ind = T)] = lower_cutoff
    difference[which(difference > upper_cutoff, arr.ind = T)] = upper_cutoff
    
    outlier_idx = which(difference %in% c(lower_cutoff, upper_cutoff))
    y_jitter = 1 + runif(length(difference), -0.2, 0.2)
    points(difference, y_jitter,  
           col = rgb(1, 0.65, 0, 0.75), pch = 16, cex = 1)
    points(difference[outlier_idx], y_jitter[outlier_idx], 
           cex = 1, lwd = 0.75)
    boxplot(difference, col = rgb(1,0,0,0), border = "black", main = "", horizontal = T,
            xlab = expression("CNN APE  " - " Post. mean APE"), outline = F,
            ylim = c(lower_cutoff, upper_cutoff), cex.lab = 1.25, add = T)
    
    
  }
  
  par("mar" = old_par)
  if(set_layout) layout(1)
  if(!is.null(file_prefix)) dev.off()
}






make_error_difference_boxplot <- function(cnn_pred, phylo_pred, labels, 
                                          whisker = 1,
                                          boxnames = NULL, 
                                          panel_label = FALSE, 
                                          file_prefix = NULL, file_type = "pdf"){
  cnn_pred_error = get_ape(cnn_pred, labels)
  phylo_pred_error = get_ape(phylo_pred, labels)
  difference = cnn_pred_error - phylo_pred_error
  # difference = 100 * (as.matrix(cnn_pred) - as.matrix(phylo_pred))/as.matrix(labels)
  
  if(is.null(boxnames)) boxnames = c(expression("R"[0]), expression(delta[]), expression("m"[]))
  
  # make boxplot
  if(!is.null(file_prefix)){
    if(file_type == "pdf"){
      pdf(paste0(file_prefix, ".pdf"), width = 0.5*fig_scale, height = 0.7*fig_scale)
    }else if(file_type == "jpeg"){
      jpeg(paste0(file_prefix, ".jpg"), width = 0.5*fig_scale, height = 0.7*fig_scale, 
           res = 400, quality = 100, units = "in")
    }
  }
  
  old_mar = par("mar")
  new_mar = old_mar
  new_mar[3] = old_mar[3] * 0.5
  par("mar" = new_mar)
  
  dbx = boxplot(difference, range = whisker, plot = FALSE)
  upper_cutoff = 1.1 * max(abs(dbx$stats))
  lower_cutoff = -upper_cutoff 
  
  boxplot(difference, col = "white", border = "black", main = "",
          ylab = expression("CNN APE  " - " Post. mean APE"), outline = F, xaxt = 'n',
          range = whisker, ylim = c(lower_cutoff, upper_cutoff))
  
  axis(side =1, at = seq(length(boxnames)), labels = boxnames, 
       tick = F, cex.axis = 1.75)
  
  abline(h=0,col = "red")
  
  if(panel_label == TRUE){
    pplt <- par("plt")
    adjx <- (0 - pplt[1]) / (pplt[2] - pplt[1])
    liney = par("mar")[3] - 1.75
    mtext("B", side = 3, cex = 1.5, adj = adjx, line = liney)
  }
  
  
  # plot data points
  difference[which(difference < lower_cutoff, arr.ind = T)] = lower_cutoff
  difference[which(difference > upper_cutoff, arr.ind = T)] = upper_cutoff
  
  for(x in seq(ncol(difference))){
    outlier_idx = which(difference[,x] %in% c(lower_cutoff, upper_cutoff))
    x_jitter = x + runif(nrow(difference), -0.25, 0.25)
    points(x_jitter, difference[,x], 
           col = rgb(1, 0.65, 0, 0.75), pch = 16, cex = 0.75)
    points(x_jitter[outlier_idx], difference[outlier_idx,x],
           cex = 0.75, lwd = 0.75)
  }
  par("mar" = old_mar)
  
  if(!is.null(file_prefix)) dev.off()
}

make_root_location_plots <- function(cnn_pred, phylo_pred, labels, 
                                     panel_label = FALSE, file_prefix = NULL,
                                     file_type = "pdf"){
  
  cnn_acc = get_rootloc_accuracy(cnn_pred, labels)
  phylo_acc = get_rootloc_accuracy(phylo_pred, labels)
  
  brks = seq(0,1,by=0.05)
  
  cnnhist = hist(cnn_acc, breaks = brks, plot = F)
  phylohist = hist(phylo_acc, breaks = brks, plot = F)
  
  ymax = 1.05 * max(cnnhist$counts)
  ymin = -1.05 * max(phylohist$counts)
  bothmax = max(abs(c(ymax, ymin)))
  
  phylohist$counts = -phylohist$counts
  
  
  if(!is.null(file_prefix)){
    if(file_type == "pdf"){
      pdf(paste0(file_prefix, ".pdf"), width = 0.5*fig_scale, height = 0.5 * fig_scale)
    }else if(file_type == "jpeg"){
      jpeg(paste0(file_prefix, ".jpg"), width = 0.5*fig_scale, height = 0.5 * fig_scale, 
           res = 400, quality = 100, units = "in", pointsize = 12)
    }
  }
  
  old_mar = par("mar")
  new_mar = old_mar
  new_mar[3] = old_mar[3] * 0.25
  par("mar" = new_mar)
  
  plot(cnnhist, col = rgb(0,0,1,1), ylim = c(-bothmax, bothmax), main = "", border = "white", axes = F, 
       xlab = "Pr(recovering true outbreak location)", ylab = "Num. trees")
  
  plot(phylohist, col = rgb(1,0,0,1), add = T, border = "white")
  axis(1)
  box()
  
  if(panel_label == TRUE){
    pplt <- par("plt")
    adjx <- (0 - pplt[1]) / (pplt[2] - pplt[1])
    liney = par("mar")[3] - 1.5
    mtext("C", side = 3, cex = 1.5, adj = adjx, line = liney)
  }
  
  tbw = 25
  yaxis_tick_locs = seq(-(tbw + bothmax - bothmax %% tbw), tbw + bothmax - bothmax %% tbw, by = tbw)
  axis(2, at = yaxis_tick_locs, labels = abs(yaxis_tick_locs))
  abline(h=0, col = rgb(0,0,0,0.5))
  
  legend(0.0, 0.75 * bothmax,legend = paste0("Avg. CNN accuracy = ", round(mean(cnn_acc), digits = 2)),
         fill = "blue", border = "white", bty = 'n', cex = 0.8, yjust = 0)
  legend(0.0, -0.75 * bothmax,legend = paste0("Avg. Post. mean accuracy = ", round(mean(phylo_acc), digits = 2)),
         fill = "red", border = "white", bty = 'n', cex = 0.8, yjust = 1)
  par("mar" = old_mar)
  
  if(!is.null(file_prefix)) dev.off()
  
}

make_runtime_scatter_plots <- function(phylo_runtime_numtips_treesize,  
                                       sim_cpu_hours = 1498,
                                       cnn_training_cpu_hours = 2,
                                       file_prefix = NULL){
 #   cnn_time = hr. 0.44 x 10^-3 s, 0.44 ms per tree on average
  jpeg(paste0(file_prefix, ".jpg"), units = "in", quality = 100,
       res = 400, width = 0.75*fig_scale, height = 0.5*fig_scale)
  
  layout(matrix(seq(2), nrow = 1))
  old_mar = par("mar")
  par("mar" = c(old_mar[1:3], 0.4 * old_mar[4]))
  plot(log(phylo_runtime_numtips_treesize$tree_size, 10), log(phylo_runtime_numtips_treesize$phylo_time_min, 10),
       xlab = "log sum branch lengths", ylab = "log run time (minutes)", pch =16, col = rgb(1,0,0,0.5), ylim = c(-8,3))
  points(log(phylo_runtime_numtips_treesize$tree_size, 10), log(phylo_runtime_numtips_treesize$cnn_time_us * 10^-6 / 60 , 10),
         pch = 16, col = rgb(0,0,1,0.5))
  legend(2.8, -2, c("Post. mean", "CNN"), fill = c("red", "blue"),
         border = "white", bty = 'n', cex = 0.75)

  # diagram, how many trees before parity # units hrs
  mean_cnn_rate_per_tree = mean(phylo_runtime_numtips_treesize$cnn_time_us * 10^-6 / 60 / 60) 
  mean_phylo_rate_per_tree = mean(phylo_runtime_numtips_treesize$phylo_time_min / 60 )
  
  num_trees = seq(1,600)
  cnn_times = num_trees * mean_cnn_rate_per_tree + sim_cpu_hours
  phylo_times = num_trees * mean_phylo_rate_per_tree
  
  plot(num_trees, cnn_times, , type = "l", col = "blue", xlab = "number of trees analyzed",
       ylab = "total CPU hours",
       ylim = c(min(c(cnn_times, phylo_times)), max(c(cnn_times, phylo_times))))
  lines(num_trees, phylo_times, col = "red")
  abline(v=num_trees[which.min(abs(cnn_times - phylo_times))])
  
  par('mar' = old_mar)
  dev.off()
  
  print(num_trees[which.min(abs(cnn_times - phylo_times))])

}


# supplemnetal figure making
make_qqplots <- function(cnn_pred, phylo_pred, file_prefix = NULL){
  if(!is.null(file_prefix)) pdf(paste0(file_prefix, ".pdf"), width = fig_scale, height = 0.5*fig_scale)
  old_par = par("mar")
  new_mar = par("mar")
  new_mar[c(4)] = new_mar[c(4)] * 0.1
  par("mar" = new_mar)
  layout(matrix(seq(ncol(cnn_pred)), nrow = 1))
  for(i in seq(ncol(cnn_pred))){
    ylabel <- ifelse(i == 1, "Posterior mean", "")
    qqplot(cnn_pred[,i], phylo_pred[,i],
           main = colnames(cnn_pred)[i],
           xlab = "CNN prediction",
           ylab = ylabel)
    abline(0,1,col = "red")
  }
  par("mar" = old_par)
  layout(1)
  if(!is.null(file_prefix)) dev.off()
}

make_coverage_plot <- function(coverage, hpd = c(0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95),
                               n = 100,pcolor = c("blue", "orange", "red"), 
                               plegend = c(expression("R"[0]), expression(delta), "m"), file_prefix = NULL){
  

  # pdf(paste0(file_prefix, ".pdf"), width = 0.5 * fig_scale, height = 0.6 * fig_scale)
  jpeg(paste0(file_prefix, ".jpg"), units = "in", quality = 100,
       res = 400, width = 0.5*fig_scale, height = 0.6*fig_scale)
  
  boxplot(t(coverage), border ="white", col = "white", xlim = c(0.5, length(hpd) + 0.5), ylim = c(0,1),
          ylab = "observed", xlab= "expected", names = hpd)
  
  sapply(seq(hpd), function(x){
    bsd = 1.96 * sqrt(hpd[x] * (1 - hpd[x]) / n)
    polygon(c(x-0.5, x+0.5, x+0.5, x-0.5), 
            c(hpd[x] - bsd, hpd[x] - bsd, hpd[x] + bsd, hpd[x] + bsd), 
            col = rgb(0,0,0,0.1), border = NA)
  })
  lines(seq(length(hpd)+1)-0.5, c(hpd, rev(hpd)[1]), type = "s")
  sapply(seq(ncol(coverage)), function(x) points(seq(hpd) + runif(hpd, -0.02,0.02), lwd = 1.75,
                                    cex = 1.25, coverage[,x], col = pcolor[x]))
  legend(0.4, 1, legend = plegend, fill = c(pcolor, "red"), cex = 0.75, bty = "n", border = "white")

  dev.off()
}

make_change_in_error_boxplots <- function(true_cnn_pred, true_phylo_pred,
                                          mispec_cnn_pred, mispec_phylo_pred,   
                                          true_labels, mispec_labels, baseline, 
                                          ceiling = 200, whisker = 1.5,
                                          legend = c("CNN, true model", "CNN, misspecified model", 
                                                     "Post. mean, true model", 
                                                     "Post. mean, misspecified model", 
                                                     "Baseline"),
                                          box_at = c(1,2,3,4,5,
                                                     7,8,9,10,11,
                                                     13,14,15,16,17),
                                          file_prefix = NULL){
  # compute errors
  # recover()
  misspec_cnn_error = as.matrix(get_ape(mispec_cnn_pred, mispec_labels))
  true_cnn_error = as.matrix(get_ape(true_cnn_pred, true_labels))
  
  misspec_phylo_error = as.matrix(get_ape(mispec_phylo_pred, mispec_labels))
  true_phylo_error = as.matrix(get_ape(true_phylo_pred, true_labels))
  
  baseline_ape = as.matrix(get_ape(baseline, mispec_labels))
  
  # make vector lengths equal baseline is same length as misspec_error
  maxlength = max(c(length(misspec_cnn_error[,1]), length(true_cnn_error[,1]),
                    length(misspec_phylo_error[,1]), length(true_phylo_error[,1])))
  
  all_data <- c()
  sapply(seq(ncol(misspec_cnn_error)), function(column){
    
    me_cnn <- misspec_cnn_error[,column]
    te_cnn <- true_cnn_error[,column]
    me_phylo <- misspec_phylo_error[,column]
    te_phylo <- true_phylo_error[,column]
    be <- baseline_ape[,column]
    
    length(me_cnn) <- maxlength
    length(te_cnn) <- maxlength
    length(me_phylo) <- maxlength
    length(te_phylo) <- maxlength
    length(be) <- maxlength
    
    all_data <<- cbind(all_data, te_cnn, me_cnn, te_phylo, me_phylo, be)
  })
  
  # xxx
  nc = ncol(baseline_ape)
  num_boxes = 5 * ncol(baseline_ape) 
  
  point_colors = c(rgb(0,0,1,0.5), rgb(0.5,0.5,1,0.5),
                   rgb(1,0,0,0.5), rgb(1,0.5,0.5,0.5), 
                   rgb(0.5,0.5,0.5,0.75) )
  legend.col = c(rgb(0,0,1,1), rgb(0.5,0.5,1,1), 
                 rgb(1,0,0,1), rgb(1,0.5,0.5,1), 
                 rgb(0.5,0.5,0.5,1) )
  pc = rep(point_colors, ncol(baseline_ape))
  
  if(!is.null(file_prefix)) pdf(paste0(file_prefix, ".pdf"), width = fig_scale, height = 0.8 * fig_scale)
  
  plot(NULL, ylim = c(0,ceiling), xlim = c(0.5, num_boxes + 0.5 + 2),
          ylab = "APE", xaxt = 'n', xlab = "Epidemiological rates")
  
  polygon(x = c(0.5,6,6,0.5), y= c(-100, -100, 2*ceiling, 2*ceiling), border = NA, col = rgb(0,0,0,0.05))
  polygon(x = c(12,17.5,17.5,12), y= c(-100, -100, 2*ceiling, 2*ceiling), border = NA, col = rgb(0,0,0,0.05))
  
  boxplot(all_data, col = "white", border = "black", range = whisker, 
          outline = F, at = box_at, add = TRUE, xlab = "", xaxt = 'n')
  axis(side =1, at = c(3,9,15), labels = c(expression("R"[0]), expression(delta), "m"))
  
  legend(0.5, ceiling, legend = legend,
         fill = legend.col, cex = 0.75, bty = "n", border = "white")
  
  # set > ceiling to ceiling and add points to boxplot
  all_data[which(all_data > ceiling, arr.ind = T)] = ceiling
  
  for(x in seq(ncol(all_data))){
    points(box_at[x] + runif(maxlength, -0.25, 0.25), all_data[,x],
           col = pc[x], pch = 16, cex = 0.75)
  }
  
  arrows( x0 = c(0, 7, 15), y0 = rep(-10,3), x1 = c(5,13,17), y1 = rep(-10,3), length = 0)
  if(!is.null(file_prefix)) dev.off()
}


make_error_boxplots <- function(cnn_pred, phylo_pred, baseline, labels,
                                ceiling = 200, whisker = 1.5, type = "box",
                                legend = c("CNN", "Posterior mean", "Baseline"),
                                legend.col = c("blue", "red","gray"),
                                boxnames = NULL, 
                                file_prefix = NULL){

  # make error variables
  cnn_pred_ape    = get_ape(cnn_pred, labels)
  phylo_pred_ape  = get_ape(phylo_pred, labels)
  baseline_ape        = get_ape(baseline, labels)

  # interleave columns
  nc = ncol(baseline_ape)
  num_boxes = 3 * ncol(baseline_ape)
  all_data = cbind(cnn_pred_ape, phylo_pred_ape, baseline_ape)

  col_order = c(1 + seq(0,2) * nc, 2 + seq(0,2) * nc, 3 + seq(0,2) * nc)
  all_data = all_data[,col_order]

  if(is.null(boxnames)) boxnames = c("","","")
  point_colors = c(rgb(0,0,1,0.5),rgb(1,0,0,0.5) ,rgb(0.5,0.5,0.5,0.75) )
  pc = rep(point_colors, ncol(labels))

  if(!is.null(file_prefix)) pdf(paste0(file_prefix, ".pdf"), width = fig_scale, height = 0.8 * fig_scale)
  
  plot(NULL, ylim = c(0,ceiling), xlim = c(0.5, num_boxes+0.5),
          ylab = "APE", xaxt = 'n', xlab = "Epidemiological rates")
  polygon(x = c(0.5,3.5,3.5,0.5), y= c(-100, -100, 2*ceiling, 2*ceiling), border = NA, col = rgb(0,0,0,0.05))
  polygon(x = c(6.5,9.5,9.5,6.5), y= c(-100, -100, 2*ceiling, 2*ceiling), border = NA, col = rgb(0,0,0,0.05))

  boxplot(all_data, col = "white", border = "black", outline = F, range = whisker, add = TRUE, xaxt = 'n')
  axis(side =1, at = c(2,5,8), labels = boxnames)
    


  legend(0.5, ceiling, legend = legend,
         fill = legend.col, cex = 0.75, bty = "n", border = "white")

  # set > ceiling to ceiling and add points to boxplot
  all_data[which(all_data > ceiling, arr.ind = T)] = ceiling

  for(x in seq(ncol(all_data))){
    points(x + runif(nrow(labels), -0.25, 0.25), all_data[,x],
           col = pc[x], pch = 16, cex = 0.75)
  }
  if(!is.null(file_prefix)) dev.off()
  
}


make_ess_plot <- function(ess, cnn_ape, phylo_ape, file_prefix = NULL){
  if(!is.null(file_prefix)) pdf(file = paste0(file_prefix, ".pdf"), width = fig_scale, height = 0.5*fig_scale)
  old_par = par("mar")
  new_mar = par("mar")
  new_mar[c(4)] = new_mar[c(4)] * 0.1
  par("mar" = new_mar)
  layout(matrix(seq(ncol(ess)), nrow = 1))
  for(i in seq(ncol(ess))){
    ylabel = ifelse(i == 1, "CNN APE - mean posterior APE", "")
    dif_ape = cnn_ape[,i] - phylo_ape[,i]
    plot(ess[,i], dif_ape, ylab = ylabel, xlab = "ESS")
    abline(h=0, col = "red")
    linmod = lm(dif_ape ~ ess[,i])
    sumlinmod = summary(linmod)
    abline(linmod, col = "blue")
    text(max(ess[,i]) - 0.5 * (max(ess[,i]) - min(ess[,i])), 
         min(dif_ape) + 0.1 * (max(dif_ape) - min(dif_ape)), 
         label = paste0("slope = ", round(sumlinmod$coefficients[2,1], digits = 4),
                        "\nP = ", round(sumlinmod$coefficients[2,4], digits = 4)))
  }
  par("mar" = old_par)
  layout(1)
  if(!is.null(file_prefix)) dev.off()
}


make_mtbd_nadeau_plots <- function(cnn, nad_rate_post, nad_root_post, 
                                   file_prefix = NULL){
  
  locations = c("Hubei", "France", "Germany", "Italy", "Other Eur.")
  
  if(!is.null(file_prefix)) jpeg(paste0(file_prefix, ".jpeg"), units = "in", 
                                 quality = 100, res = 400, width = 0.85*fig_scale, 
                                height = 0.5 * fig_scale)

  omar = par("mar")
  nmar = omar
  nmar[2] = nmar[2]+0.25
  par("mar" = nmar) 
  layout(cbind(c(1,1),c(1,1),c(1,1),c(2,3),c(2,3)))
  vioplot(nadeau2021_R0_log, border = NA, col = rgb(1, 0.66, 0, 0.8), cex.axis =1.0, 
          cex.names = 1.0, names = locations, ylab = expression("R"[0]), 
          ylim = c(0.5, 4.25), cex.lab = 1.5, rectCol="orange")
  par("mar" = omar)
  
  points(seq(5), cnn[1,1:5], col = rgb(0,0,1,1), pch = 1, lwd = 2, cex = 2)
  points(seq(5), cnn[2,1:5], col = rgb(0,0,1,1), pch = 4, lwd = 2, cex = 2)
  
  #legend
  points(c(0.5, 0.5, 0.5), c(4.2, 4, 3.8), pch = c(15, 1, 4), col = c("orange", "blue", "blue"), 
         cex = 2, lwd = c(1, 3, 3))
  text(c(0.5, 0.5), c(4.2, 4, 3.8), pos = 4, offset = 0.75, cex = 1.0,
       labels = c("Nadeau et al. 2021 posterior", "CNN Full Tree", "CNN A2 Clade"))
  
  
  barplot(unlist(nadeau2021_cnn_pred[2,8:12]), names = locations, col = "blue",
          main = "CNN", cex.names = 1.0, ylab = "Probability", cex.main = 0.9)
  barplot(nadeau2021_root, names = locations, col = "orange", cex.main = 0.9,
          main = "Nadeau et al. 2021", cex.names = 1.0,ylab = "Probability")
  
  layout(1)
  if(!is.null(file_prefix)) dev.off()
  
}


numerical_sim_SIR <- function(gamma, beta, 
                              sim_time = 100,
                              S0 = 1000000,
                              I0 = 1,
                              Imax = 0.1 * S0,
                              dt = 0.1){
  tt <- 0
  i_at_t <- I0
  s_at_t <- S0
  i_history <- matrix(c(tt, I0), ncol = 2)
  while(tt < sim_time && i_at_t < Imax && i_at_t > 0){
    s_at_t <- s_at_t - (beta * i_at_t * s_at_t / S0) * dt
    i_at_t <- i_at_t + (beta * i_at_t * s_at_t / S0 - gamma * i_at_t) * dt
    tt <- tt + dt
    i_history <- rbind(i_history, matrix(c(tt, i_at_t), ncol = 2))
  }
  return(i_history)
}


##################
# BEST FUNCTIONS #
##################
make_phylocomp_BESTplots  <- function(cnn_ape, phylo_ape, param_labels = expression("R"[0], delta[""], "m"[""]), 
                                      file_param_names = c("R0", "delta", "m"), file_prefix = NULL){
  
  num_saved_steps = 20000
  
  num_parms = ncol(cnn_ape)
  
  # run BEST analysis and output BEST summary plots
  pmu <- c()
  log_mean_error = lapply(seq(num_parms), function(col_idx){
    best_list <- list()
    
    best_list[[1]] <- BESTmcmc(log(cnn_ape[,col_idx]), numSavedSteps = num_saved_steps)
    pdf(paste0(file_prefix, "_BEST_output_log_cnn_", file_param_names[col_idx], ".pdf"))
    plotAll(best_list[[1]])
    dev.off()
    
    best_list[[2]] <- BESTmcmc(log(phylo_ape[,col_idx]), numSavedSteps = num_saved_steps)
    pdf(paste0(file_prefix, "_BEST_output_log_phylo_", file_param_names[col_idx], ".pdf"))
    plotAll(best_list[[2]])
    dev.off()
    
    pmu <<- cbind(pmu, exp(best_list[[1]]$mu), exp(best_list[[2]]$mu))
    
    return(best_list)
  })
  
  cnn_phylo_dif_best <- lapply(seq(ncol(cnn_ape)), function(col_idx){
    best_list <- BESTmcmc(cnn_ape[,col_idx] - phylo_ape[,col_idx], numSavedSteps = num_saved_steps)
    pdf(paste0(file_prefix, "_BEST_output_cnn_minus_phylo_", file_param_names[col_idx], ".pdf"))
    plotAll(best_list)
    dev.off()
    
    pmu <<- cbind(pmu, best_list$mu)
    
    return(best_list)
  })
  
   
  ###############
  # make figure #
  ###############
 
  ymax = max(pmu)
  ymin = min(pmu)
  xmin = 0.5
  xmax = 2 * num_parms + 0.5
  
  # pdf(paste0(file_prefix, "_BEST_output_violin_plot_figure.pdf"), width = fig_scale, height = fig_scale)
  jpeg(paste0(file_prefix, "_BEST_output_violin_plot_figure.jpg"), width = 0.8*fig_scale, height = 0.6*fig_scale, 
       units = "in",quality = 100, res = 400)
 
  
  layout(matrix(c(1,1,2), nrow = 1))
  param_names = c(expression("R"[0], delta[], "m"[]))
  
  # plot Panel A vioplots APE for 3 params

  plot(NULL, xlim = c(0.5, 6.5), ylim = c(ymin,ymax), 
       ylab = expression(tilde(mu) ~ "median Absolute Percent Error (APE)"), xaxt = 'n',
       main = "Relative error", xlab = "Parameters", cex.lab = 1.15)
  sapply(seq(1, 2 * num_parms, by=4), function(x){
    polygon(x = c(x - 0.5, x + 1.5, x + 1.5, x - 0.5), y = 2 * c(ymin, ymin, ymax, ymax), border = NA, col = rgb(0,0,0,0.1))
  })
  
  vioplot(pmu[,1:6], col = rep(c("blue","red"), 3), 
          rectCol = "white", lineCol = "white", add = T)
  
  axis(side =1, at = c(1.5,3.5,5.5), cex.axis = 1.5, labels =  param_labels)
  
  abline(h=0, col = rgb(0,1,0,0.5), lwd = 2)
  
  legend(0.25, ymax * 1.05, legend = c("CNN", "Like."),
         fill = c("blue", "red"), cex = 1.25, bty = "n", border = "white")
  
  pplt <- par("plt")
  adjx <- (0 - pplt[1]) / (pplt[2] - pplt[1])
  liney = par("mar")[3] - 1.75
  mtext("A", side = 3, cex = 1.5, adj = adjx, line = liney)
  
  
  # plot panel B vioplots for differences between methods medians
  plot(NULL, xlim = c(0.5, 3.5), ylim = c(ymin,ymax), 
       ylab = expression(tilde(mu) ~ "(CNN APE" - "Like. APE)"), xaxt = 'n',
       main = "Difference between methods", xlab = "Parameters", cex.lab = 1.15)
  vioplot(pmu[,7:9], col = "black", 
          rectCol = "white", lineCol = "white", add = T)
  axis(side =1, at = seq(3), cex.axis = 1.5, labels =  param_labels)

  abline(h=0, col = rgb(0,1,0,0.5), lwd = 2)
  
  mtext("B", side = 3, cex = 1.5, adj = adjx, line = liney)
  
  dev.off()
  
  # print cnn - phylo 95% interval
  sapply(seq(3), function(i) cat(" dif 95% HPI index ", i,  " = ",
                                 (summary(cnn_phylo_dif_best[[i]])[1,5:6]), "\n")) 
  sapply(seq(1, num_parms, by=2), function(i){
    cat("CNN APE 95% HPI index ",(i+1)/2, ' = ', 
        quantile(pmu[,i], prob = c(0.025,0.975)), "\n")
    cat("phylo APE 95% HPI index ", (i+1)/2, ' = ', 
        quantile(pmu[,i+1], prob = c(0.025,0.975)), "\n")
  })
  
  HPI <- lapply(seq(num_parms), function(i){
    rbind(
      quantile(pmu[,2 * i - 1], prob = c(0.025,0.975)),
      quantile(pmu[,2 * i], prob = c(0.025,0.975)),
      quantile(pmu[,6 + i], prob = c(0.025,0.975))
    )
  })
  
  # return the 9 BEST objects
  return(list(cnn_phylo_dif = cnn_phylo_dif_best, 
              cnn_ref_logratio = log_mean_error[[1]], 
              phylo_ref_logratio = log_mean_error[[2]],
              HPI = HPI))
  
}



make_misspec_BESTplots <- function(cnn_ape, phylo_ape, cnn_ref_ape, phylo_ref_ape, file_prefix = NULL){
  
  num_saved_steps = 20000
  params = c("R0", expression(delta), "m")
  
  # run BEST analysis and output BEST summary plots
  cnn_phylo_dif_best <- lapply(seq(ncol(cnn_ape)), function(col_idx){
    best <- BESTmcmc(cnn_ape[,col_idx] - phylo_ape[,col_idx], numSavedSteps = num_saved_steps)
    pdf(paste0(file_prefix, "_BEST_output_cnn_minus_phylo_", params[col_idx], ".pdf"))
    plotAll(best)
    dev.off()
    return(best)
  })
  cat("cnn - phylo mcmc complete \n")
  
  cnn_ref_logratio_best <- lapply(seq(ncol(cnn_ape)), function(col_idx){
    best <- BESTmcmc(log(cnn_ape[,col_idx]), log(cnn_ref_ape[,col_idx]), numSavedSteps = num_saved_steps)
    pdf(paste0(file_prefix, "_BEST_output_log_cnn_minus_log_ref_", params[col_idx], ".pdf"))
    plotAll(best)
    dev.off()
    return(best)
  })
  cat("log cnn and log ref mcmc complete \n")
  
  phylo_ref_logratio_best <- lapply(seq(ncol(cnn_ape)), function(col_idx){
    best <- BESTmcmc(log(phylo_ape[,col_idx]), log(phylo_ref_ape[,col_idx]), numSavedSteps = num_saved_steps)
    pdf(paste0(file_prefix, "_BEST_output_log_phylo_minus_log_ref_", params[col_idx], ".pdf"))
    plotAll(best)
    dev.off()
    return(best)
  })
  cat("log phylo and log ref mcmc complete \n")
  
  # make figure plots
  differences <- cbind(exp(cnn_ref_logratio_best[[1]]$mu1) - exp(cnn_ref_logratio_best[[1]]$mu2),
                       exp(phylo_ref_logratio_best[[1]]$mu1) - exp(phylo_ref_logratio_best[[1]]$mu2),
                       exp(cnn_ref_logratio_best[[2]]$mu1) - exp(cnn_ref_logratio_best[[2]]$mu2),
                       exp(phylo_ref_logratio_best[[2]]$mu1)- exp(phylo_ref_logratio_best[[2]]$mu2),
                       exp(cnn_ref_logratio_best[[3]]$mu1) - exp(cnn_ref_logratio_best[[3]]$mu2),
                       exp(phylo_ref_logratio_best[[3]]$mu1)- exp(phylo_ref_logratio_best[[3]]$mu2),
                       cnn_phylo_dif_best[[1]]$mu, 
                       cnn_phylo_dif_best[[2]]$mu, 
                       cnn_phylo_dif_best[[3]]$mu )
  
  ymax = max(differences)
  ymin = min(differences)
  
  # pdf(paste0(file_prefix, "_BEST_output_posterior_difference_violin_plot.pdf"), width = fig_scale, height = fig_scale)
  jpeg(paste0(file_prefix, "_BEST_output_posterior_difference_violin_plot.jpg"), width = 0.8*fig_scale, height = 0.6*fig_scale, 
       units = "in",quality = 100, res = 400)
  
  
  layout(matrix(c(1,1,2), nrow = 1))
  
  param_names = c(expression("R"[0], delta[], "m"[]))
  
  # Panel A vioplots for sensitivity posteriors medians
  plot(NULL, xlim = c(0.5, 6.5), ylim = c(ymin, ymax), 
       ylab = expression(tilde(mu) ~ "(misspec. APE)" - tilde(mu) ~ "(Ref. APE)"), xaxt = 'n',
       main = "Sensitivity to misspecification", xlab = "Parameters", cex.lab = 1.15)
  
  polygon(x = c(0.5,2.5,2.5,0.5), y= 2 * c(ymin, ymin, ymax, ymax), border = NA, col = rgb(0,0,0,0.1))
  polygon(x = c(4.5,6.5,6.5,4.5), y= 2 * c(ymin, ymin, ymax, ymax), border = NA, col = rgb(0,0,0,0.1))
  
  vioplot(differences[,1:6], col = c(rep(c("blue", "red"), 3)), 
          rectCol = "white", lineCol = "white", add = TRUE)
  
  axis(side =1, at = c(1.5,3.5,5.5), cex.axis = 1.5, labels =  param_names)
  
  legend(0.25, ymax * 1.05, legend = c("CNN", "Like."),
         fill = c("blue", "red"), cex = 1.25, bty = "n", border = "white")
  
  abline(h=0, col = rgb(0,1,0,0.5), lwd = 2)
  
  pplt <- par("plt")
  adjx <- (0 - pplt[1]) / (pplt[2] - pplt[1])
  liney = par("mar")[3] - 1.75
  mtext("A", side = 3, cex = 1.5, adj = adjx, line = liney)
  
  
  # Panel B vioplots for differences between methods medians
  plot(NULL, xlim = c(0.5, 3.5), ylim = c(ymin,ymax), 
       ylab = expression(tilde(mu) ~ "(CNN APE" - "Like. APE)"), xaxt = 'n',
       main = "Difference between methods", xlab = "Parameters", cex.lab = 1.15)
  vioplot(differences[,7:9], col = "black", 
          rectCol = "white", lineCol = "white", add = T)
  axis(side =1, at = seq(3), cex.axis = 1.5, labels =  param_names)
  
  abline(h=0, col = rgb(0,1,0,0.5), lwd = 2)
  
  mtext("B", side = 3, cex = 1.5, adj = adjx, line = liney)
  
  
  
  dev.off()
  
  # print cnn - phylo 95% interval
  sapply(seq(3), function(i) cat("CNN - phylo dif 95% HPI index ", i,  " = ",
                                 summary(cnn_phylo_dif_best[[i]])[1,5:6], "\n")) 
  sapply(c(1,3,5), function(i){
    cat("CNN - ref dif 95% HPI index ",(i+1)/2, ' = ', 
        quantile(differences[,i], prob = c(0.025,0.975)), "\n")
    cat("phylo - ref dif 95% HPI index ", (i+1)/2, ' = ', 
        quantile(differences[,i+1], prob = c(0.025,0.975)), "\n")
  })
  
  HPI <- lapply(seq(3), function(i){
    rbind(
      quantile(differences[,2 * i - 1], prob = c(0.025,0.975)),
      quantile(differences[,2 * i], prob = c(0.025,0.975)),
      quantile(differences[,6 + i], prob = c(0.025,0.975))
    )
  })
  
  # return the 9 BEST objects
  return(list(cnn_phylo_dif = cnn_phylo_dif_best, 
              cnn_ref_logratio = cnn_ref_logratio_best, 
              phylo_ref_logratio = phylo_ref_logratio_best,
              HPI = HPI))
  
}



########################
##### storage ##########
########################
# maybe don't use

old_make_phylocomp_BESTplots  <- function(cnn_ape, phylo_ape, param_labels = expression("R"[0], delta[""], "m"[""]), 
                                          file_param_names = c("R0", "delta", "m"), file_prefix = NULL){
  
  num_saved_steps = 20000
  
  num_parms = ncol(cnn_ape)
  
  # run BEST analysis and output BEST summary plots
  pmu <- c()
  log_mean_error = lapply(seq(num_parms), function(col_idx){
    best_list <- list()
    
    best_list[[1]] <- BESTmcmc(log(cnn_ape[,col_idx]), numSavedSteps = num_saved_steps)
    pdf(paste0(file_prefix, "_BEST_output_log_cnn_", file_param_names[col_idx], ".pdf"))
    plotAll(best_list[[1]])
    dev.off()
    
    best_list[[2]] <- BESTmcmc(log(phylo_ape[,col_idx]), numSavedSteps = num_saved_steps)
    pdf(paste0(file_prefix, "_BEST_output_log_phylo_", file_param_names[col_idx], ".pdf"))
    plotAll(best_list[[2]])
    dev.off()
    
    pmu <<- cbind(pmu, exp(best_list[[1]]$mu), exp(best_list[[2]]$mu))
    
    return(best_list)
  })
  
  cnn_phylo_dif_best <- lapply(seq(ncol(cnn_ape)), function(col_idx){
    best_list <- BESTmcmc(cnn_ape[,col_idx] - phylo_ape[,col_idx], numSavedSteps = num_saved_steps)
    pdf(paste0(file_prefix, "_BEST_output_cnn_minus_phylo_", file_param_names[col_idx], ".pdf"))
    plotAll(best_list)
    dev.off()
    
    pmu <<- cbind(pmu, best_list$mu)
    
    return(best_list)
  })
  
  
  ymax = max(pmu)
  ymin = min(pmu)
  xmin = 0.5
  xmax = 3 * num_parms + 0.5
  
  
  # pdf(paste0(file_prefix, "_BEST_output_violin_plot_figure.pdf"), width = fig_scale, height = fig_scale)
  jpeg(paste0(file_prefix, "_BEST_output_violin_plot_figure.jpg"), width = 0.8*fig_scale, height = 0.8*fig_scale, 
       units = "in",quality = 100, res = 400)
  
  plot(NULL, xlim = c(xmin, xmax), ylim = c(ymin, ymax), ylab = "Absolute Percent Error (APE)", xaxt = 'n',
       main = "Posterior Distributions", xlab = "")
  
  sapply(seq(1, 2 * num_parms, by=4), function(x){
    polygon(x = c(x - 0.5, x + 1.5, x + 1.5, x - 0.5), y = 2 * c(ymin, ymin, ymax, ymax), border = NA, col = rgb(0,0,0,0.1))
  })
  
  vioplot(pmu, col = c(rep(c("blue", "red"), num_parms), rep("black", num_parms)), rectCol = "white", lineCol = "white", 
          add = TRUE)
  
  
  axis(side=1, at=c(seq(1, 2 * num_parms, by = 2) + 0.5, seq(1 + 2 * num_parms, 3 * num_parms)), 
       labels = c(param_labels, param_labels))
  
  legend(2 * num_parms + 0.5, 0.95 * ymax, legend = c(expression("CNN median APE"), 
                                                      expression("Like. median APE"),
                                                      expression("median(CNN APE" - "Like. APE)")),
         fill = c("blue", "red", "black"), cex = 0.8, bty = "n", border = "white")
  
  abline(h=0, col = rgb(0,1,0,0.5), lwd = 2)
  dev.off()
  
  # print cnn - phylo 95% interval
  sapply(seq(3), function(i) cat(" dif 95% HPI index ", i,  " = ",
                                 (summary(cnn_phylo_dif_best[[i]])[1,5:6]), "\n")) 
  sapply(seq(1, num_parms, by=2), function(i){
    cat("CNN APE 95% HPI index ",(i+1)/2, ' = ', 
        quantile(pmu[,i], prob = c(0.025,0.975)), "\n")
    cat("phylo APE 95% HPI index ", (i+1)/2, ' = ', 
        quantile(pmu[,i+1], prob = c(0.025,0.975)), "\n")
  })
  
  HPI <- lapply(seq(num_parms), function(i){
    rbind(
      quantile(pmu[,2 * i - 1], prob = c(0.025,0.975)),
      quantile(pmu[,2 * i], prob = c(0.025,0.975)),
      quantile(pmu[,6 + i], prob = c(0.025,0.975))
    )
  })
  
  # return the 9 BEST objects
  return(list(cnn_phylo_dif = cnn_phylo_dif_best, 
              cnn_ref_logratio = log_mean_error[[1]], 
              phylo_ref_logratio = log_mean_error[[2]],
              HPI = HPI))
  
}

old_make_misspec_BESTplots <- function(cnn_ape, phylo_ape, cnn_ref_ape, phylo_ref_ape, file_prefix = NULL){
  
  num_saved_steps = 20000
  params = c("R0", expression(delta), "m")
  
  # run BEST analysis and output BEST summary plots
  cnn_phylo_dif_best <- lapply(seq(ncol(cnn_ape)), function(col_idx){
    best <- BESTmcmc(cnn_ape[,col_idx] - phylo_ape[,col_idx], numSavedSteps = num_saved_steps)
    pdf(paste0(file_prefix, "_BEST_output_cnn_minus_phylo_", params[col_idx], ".pdf"))
    plotAll(best)
    dev.off()
    return(best)
  })
  cat("cnn - phylo mcmc complete \n")
  
  cnn_ref_logratio_best <- lapply(seq(ncol(cnn_ape)), function(col_idx){
    best <- BESTmcmc(log(cnn_ape[,col_idx]), log(cnn_ref_ape[,col_idx]), numSavedSteps = num_saved_steps)
    pdf(paste0(file_prefix, "_BEST_output_log_cnn_minus_log_ref_", params[col_idx], ".pdf"))
    plotAll(best)
    dev.off()
    return(best)
  })
  cat("log cnn and log ref mcmc complete \n")
  
  phylo_ref_logratio_best <- lapply(seq(ncol(cnn_ape)), function(col_idx){
    best <- BESTmcmc(log(phylo_ape[,col_idx]), log(phylo_ref_ape[,col_idx]), numSavedSteps = num_saved_steps)
    pdf(paste0(file_prefix, "_BEST_output_log_phylo_minus_log_ref_", params[col_idx], ".pdf"))
    plotAll(best)
    dev.off()
    return(best)
  })
  cat("log phylo and log ref mcmc complete \n")
  
  # make figure plots
  differences <- cbind(exp(cnn_ref_logratio_best[[1]]$mu1) - exp(cnn_ref_logratio_best[[1]]$mu2),
                       exp(phylo_ref_logratio_best[[1]]$mu1) - exp(phylo_ref_logratio_best[[1]]$mu2),
                       exp(cnn_ref_logratio_best[[2]]$mu1) - exp(cnn_ref_logratio_best[[2]]$mu2),
                       exp(phylo_ref_logratio_best[[2]]$mu1)- exp(phylo_ref_logratio_best[[2]]$mu2),
                       exp(cnn_ref_logratio_best[[3]]$mu1) - exp(cnn_ref_logratio_best[[3]]$mu2),
                       exp(phylo_ref_logratio_best[[3]]$mu1)- exp(phylo_ref_logratio_best[[3]]$mu2),
                       cnn_phylo_dif_best[[1]]$mu, 
                       cnn_phylo_dif_best[[2]]$mu, 
                       cnn_phylo_dif_best[[3]]$mu )
  
  ymax = max(differences)
  ymin = min(differences)
  
  # pdf(paste0(file_prefix, "_BEST_output_posterior_difference_violin_plot.pdf"), width = fig_scale, height = fig_scale)
  jpeg(paste0(file_prefix, "_BEST_output_posterior_difference_violin_plot.jpg"), width = 0.8*fig_scale, height = 0.8*fig_scale, 
       units = "in",quality = 100, res = 400)
  
  plot(NULL, xlim = c(0.5, 9.5), ylim = c(ymin, ymax), ylab = expression(paste(Delta, "APE")), xaxt = 'n',
       main = "Posterior Distributions", xlab = "")
  
  polygon(x = c(0.5,2.5,2.5,0.5), y= 2 * c(ymin, ymin, ymax, ymax), border = NA, col = rgb(0,0,0,0.1))
  polygon(x = c(4.5,6.5,6.5,4.5), y= 2 * c(ymin, ymin, ymax, ymax), border = NA, col = rgb(0,0,0,0.1))
  
  vioplot(differences, col = c(rep(c("blue", "red"), 3), rep("black", 3) ), 
          rectCol = "white", lineCol = "white", add = TRUE)
  
  axis(side =1, at = c(1.5,3.5,5.5,7,8,9), labels =  c(expression(" R"[0]),
                                                       expression(delta),
                                                       expression(" m"),
                                                       expression(" R"[0]),
                                                       expression(delta),
                                                       expression(" m")))
  
  legend(6.5, 0.95 * ymax, legend = c(expression(Delta ~ "CNN median: " ~ tilde(mu)["CNN"] - tilde(mu)["Ref."]), 
                                      expression(Delta ~ "Like. median: " ~ tilde(mu)["Like."] - tilde(mu)["Ref."]),
                                      expression(Delta ~ tilde(mu) ~ ": " ~ tilde(mu)["(CNN" - "Like.)"])),
         fill = c("blue", "red", "black"), cex = 0.9, bty = "n", border = "white")
  
  abline(h=0, col = rgb(0,1,0,0.5), lwd = 2)
  dev.off()
  
  # print cnn - phylo 95% interval
  sapply(seq(3), function(i) cat("CNN - phylo dif 95% HPI index ", i,  " = ",
                                 summary(cnn_phylo_dif_best[[i]])[1,5:6], "\n")) 
  sapply(c(1,3,5), function(i){
    cat("CNN - ref dif 95% HPI index ",(i+1)/2, ' = ', 
        quantile(differences[,i], prob = c(0.025,0.975)), "\n")
    cat("phylo - ref dif 95% HPI index ", (i+1)/2, ' = ', 
        quantile(differences[,i+1], prob = c(0.025,0.975)), "\n")
  })
  
  HPI <- lapply(seq(3), function(i){
    rbind(
      quantile(differences[,2 * i - 1], prob = c(0.025,0.975)),
      quantile(differences[,2 * i], prob = c(0.025,0.975)),
      quantile(differences[,6 + i], prob = c(0.025,0.975))
    )
  })
  
  # return the 9 BEST objects
  return(list(cnn_phylo_dif = cnn_phylo_dif_best, 
              cnn_ref_logratio = cnn_ref_logratio_best, 
              phylo_ref_logratio = phylo_ref_logratio_best,
              HPI = HPI))
  
}


make_change_in_accuracy_root_location_plots <- function(misspec_pred,
                                                        misspec_labels,
                                                        true_pred,
                                                        true_labels,
                                                        file_prefix = NULL){
  
  misspec_acc = get_rootloc_accuracy(misspec_pred, misspec_labels)
  true_acc = get_rootloc_accuracy(true_pred, true_labels)
  
  brks = seq(0,1,by=0.05)
  hist_colors = c(rgb(0,0.5,1,0.75),rgb(1,0.5,0,0.5) )
  legend.col = c(rgb(0,0.5,1,1),rgb(1,0.5,0,1)  )
  
  misspec_hist = hist(misspec_acc, breaks = brks, plot = F)
  true_hist = hist(true_acc, breaks = brks, plot = F)
  
  ymax = max(c(misspec_hist$counts, true_hist$counts))
  
  if(!is.null(file_prefix)) pdf(paste0(file_prefix, ".pdf"))
  plot(true_hist, col = hist_colors[1], ylim = c(0, ymax), xlab = "Accuracy", main = "")
  plot(misspec_hist, col = hist_colors[2], add = T)
  legend(0,ymax,legend = c(paste0("True model. mean = ", round(mean(true_acc), digits = 2)),
                           paste0("Misspecified model. mean = ", round(mean(misspec_acc), digits = 2))),
         fill = legend.col, border = "white",bty = 'n' )
  if(!is.null(file_prefix)) dev.off()
}


make_norm_error_boxplots <- function(norm_cnn_ape, norm_phylo_ape,
                                     ceiling = 50, whisker = 1.5, type = "box",
                                     legend = c("CNN", "Posterior mean"),
                                     legend.col = c("blue", "red"),
                                     show_boxnames = TRUE){
  # interleave columns
  nc = ncol(norm_cnn_ape)
  num_boxes = 2 * ncol(norm_cnn_ape)
  all_data = cbind(norm_cnn_ape, norm_phylo_ape)
  
  col_order = c(1 + seq(0,1) * nc, 2 + seq(0,1) * nc, 3 + seq(0,1) * nc)
  all_data = all_data[,col_order]
  
  boxplot(all_data, col = "white", border = "black",
          ylim = c(min(all_data), ceiling), xlim = c(0.5, num_boxes + 0.5),
          ylab = "relative error", outline = F,
          range = whisker, xaxt = 'n', horizontal = F)
  
  axis(side =1, at = c(1.5, 3.5, 5.5), labels = c(expression("R"[0]), expression(delta), "m"))
  
  legend(0.5, ceiling, legend = legend,
         fill = legend.col, cex = 0.75, bty = "n", border = "white")
  
  # set > ceiling to ceiling and add points to boxplot
  all_data[which(all_data > ceiling, arr.ind = T)] = ceiling
  
  point_colors = c(rgb(0,0,1,0.5),rgb(1,0,0,0.5))
  pc = rep(point_colors, nc)
  
  for(x in seq(num_boxes)){
    points(x + runif(nrow(all_data), -0.25, 0.25), all_data[,x],
           col = pc[x], pch = 16)
  }
  
  abline(h=c(0,1,2), col = rgb(0,0,0,0.5), lty = c(1,2,3), lwd = 2)
  
}

make_error_difference_hist <- function(cnn_pred, phylo_pred, labels){
  cnn_pred_error = get_ape(cnn_pred, labels)
  phylo_pred_error = get_ape(phylo_pred, labels)
  layout(matrix(seq(ncol(cnn_pred)), nrow = 1))
  for(i in seq(ncol(cnn_pred))){
    ylabel = ifelse(i == 1, "Frequency", "")
    hist(cnn_pred_error[,i] - phylo_pred_error[,i],
         main = colnames(cnn_pred)[i], breaks = 20,
         xlab = "CNN Error - Post. mean Error", ylab = ylabel, axes = F)
    axis(1)
    abline(v=0,col = "red")
  }
  layout(1)

}

get_categorical_crossentropy <- function(y_pred, y_true, inf_tol = 10^-10){

  return( -mean(rowSums(y_true * log(y_pred + inf_tol) + (1 - y_true) * log(1 - y_pred + inf_tol), na.rm = T)))


}


make_overlaid_scatter_plot <- function(cnn_pred, phylo_pred, label){
  layout(matrix(seq(ncol(cnn_pred)), nrow = 1))
  for(i in (seq(ncol(cnn_pred)))){
    plot(cnn_pred[,i], label[,i], pch = 16, col = rgb(0,0,1,0.75),
         ylab = "True", xlab = "CNN Prediction/MAP estimate",
         main = colnames(cnn_pred)[i],
         xlim = c(min(c(cnn_pred[,i], phylo_pred[,i])), max(c(cnn_pred[,i], phylo_pred[,i]))))
    points(phylo_pred[,i], label[,i], pch = 16, col = rgb(1,0,0,0.75))
    legend(min(c(cnn_pred[,i], phylo_pred[,i])), max(label[,i]), legend = c("CNN", "Phylo"),
           fill = c("blue", "red"), cex = 0.75, bty = "n", border = "white")
    abline(0,1, col = "gray")
    arrows(x0 = cnn_pred[,i], y0 = label[,i],
           x1 = phylo_pred[,i], y1 = label[,i], length = 0)
  }
  layout(1)
}


get_auc <- function(prob_correct, step = 0.01, add = F){
  if(!add) plot(NULL, xlim = c(0,1), ylim = c(0,1))
  auc = 0
  
  for(i in seq(0,1,by=step)){
    FP = 1 - i 
    TP = sum(prob_correct > i) / length(prob_correct)
    auc = auc + step * TP
    points(FP, TP)
  }
  
  return(auc)
}
