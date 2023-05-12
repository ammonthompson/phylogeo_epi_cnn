#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

# Read data from files
data1 <- read.table(args[1], header=TRUE, row.names=1)
data2 <- read.table(args[2], header=TRUE, row.names=1)

# Get the plot type
plot_type <- as.logical(args[3])

# Calculate ellipse parameters
data1$radius1 <- abs(data1[,3] - data1[,2]) / 2
data2$radius1 <- abs(data2[,3] - data2[,2]) / 2

# Combine data into one data frame
data <- data.frame(estimate1 = data1[,1],
                   estimate2 = data2[,1],
                   radius1 = data1$radius1,
                   radius2 = data2$radius1)

# Calculate limits to include all ellipses
xylim <- c(min(c(data1[,2], data2[,2])), max(c(data1[,3], data2[,3])))

# Function to draw an ellipse
draw_ellipse <- function(center, shape, radius) {
  angles <- seq(0, 2*pi, length.out = 100)
  coords_x <- center[1] + radius[1] * cos(angles)
  coords_y <- center[2] + radius[2] * sin(angles)
  lines(coords_x, coords_y, col=rgb(1 * (radius[2] >= radius[1]), 0, 1 * (radius[2] < radius[1])))
}

# Save the plot to a PDF file
pdf("scatterplot.pdf", width = 10, height = 10)

# Start a plot
plot(x = data$estimate1, y = data$estimate2, xlim = xylim, ylim = xylim, xlab = "CNN CPI", ylab = "Bayesian HPD", type = "n")

# Add ellipses or diamonds
for(i in 1:nrow(data)) {
  if (plot_type) {
    draw_ellipse(center = c(data$estimate1[i], data$estimate2[i]), shape = c(1,1), radius = c(data$radius1[i], data$radius2[i]))
  } else {
    points(data$estimate1[i], data$estimate2[i], pch = 23, col = "black")
    lines(c(data$estimate1[i] - data$radius1[i], data$estimate1[i] + data$radius1[i]), c(data$estimate2[i], data$estimate2[i]), col = "blue")
    lines(c(data$estimate1[i], data$estimate1[i]), c(data$estimate2[i] - data$radius2[i], data$estimate2[i] + data$radius2[i]), col = "red")
  }
}

# Add y = x line
abline(a = 0, b = 1, col = "red", lty = 2)

# Calculate the percent difference between the intervals
percent_diff <- ((2*data$radius1 - 2*data$radius2) / (2*data$radius2)) * 100

# Add a small histogram in the top right corner
par(fig=c(0.7, 0.95, 0.075, 0.4), new=TRUE)
hist(percent_diff, main="Percent difference of intervals", cex.main = 0.9, ylab = "", xlab="")

dev.off()
cat("cnn interval length / phylo interval length: ", mean(data$radius1/data$radius2), "\n")
